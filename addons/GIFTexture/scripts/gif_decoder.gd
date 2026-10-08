@tool
class_name GIFDecoder
extends RefCounted
## Pure-GDScript GIF decoder.
##
## decode() returns a Dictionary:
##   width, height : int
##   frames        : Array[Image]        full-canvas RGBA8, disposal methods applied
##   delays        : PackedFloat32Array  seconds per frame
##   loop_count    : int                 0 = loop forever (NETSCAPE2.0), 1 = play once
## or an empty Dictionary on error.
 
 
static func decode(bytes: PackedByteArray) -> Dictionary:
	if bytes.size() < 13:
		push_error("GIFDecoder: file too small")
		return {}
	var sig := bytes.slice(0, 6).get_string_from_ascii()
	if sig != "GIF87a" and sig != "GIF89a":
		push_error("GIFDecoder: not a GIF file")
		return {}
 
	var width := _u16(bytes, 6)
	var height := _u16(bytes, 8)
	var screen_flags := bytes[10]
	var pos := 13
	if width == 0 or height == 0:
		push_error("GIFDecoder: invalid canvas size")
		return {}
 
	var global_palette := PackedByteArray()
	if screen_flags & 0x80:
		var gct_size := 3 * (1 << ((screen_flags & 7) + 1))
		global_palette = bytes.slice(pos, pos + gct_size)
		pos += gct_size
 
	var canvas := PackedByteArray()
	canvas.resize(width * height * 4) # zero-filled = transparent
	var saved := PackedByteArray()
 
	var frames: Array[Image] = []
	var delays := PackedFloat32Array()
	var loop_count := 1
 
	# Graphic Control Extension state (applies to the next image only)
	var gce_delay := 0.1
	var gce_transparent := -1
	var gce_disposal := 0
 
	# Previous frame, needed to apply its disposal method
	var prev_disposal := 0
	var prev_rect := Rect2i()
 
	while pos < bytes.size():
		var block := bytes[pos]
		pos += 1
 
		if block == 0x3B: # trailer
			break
 
		elif block == 0x21: # extension
			if pos >= bytes.size():
				break
			var label := bytes[pos]
			pos += 1
			if label == 0xF9 and pos + 5 < bytes.size():
				var gce_flags := bytes[pos + 1]
				gce_disposal = (gce_flags >> 2) & 7
				var cs := _u16(bytes, pos + 2)
				# Browsers treat 0/1 cs as 10 cs.
				gce_delay = 0.1 if cs < 2 else cs / 100.0
				gce_transparent = bytes[pos + 4] if (gce_flags & 1) else -1
				pos += 6
			elif label == 0xFF and pos + 12 < bytes.size():
				var app_id := bytes.slice(pos + 1, pos + 12).get_string_from_ascii()
				pos += 1 + bytes[pos]
				if app_id == "NETSCAPE2.0" and pos + 3 < bytes.size() \
						and bytes[pos] >= 3 and bytes[pos + 1] == 1:
					loop_count = _u16(bytes, pos + 2)
				pos = _skip_sub_blocks(bytes, pos)
			else:
				pos = _skip_sub_blocks(bytes, pos)
 
		elif block == 0x2C: # image descriptor
			if pos + 9 > bytes.size():
				break
			var left := _u16(bytes, pos)
			var top := _u16(bytes, pos + 2)
			var fw := _u16(bytes, pos + 4)
			var fh := _u16(bytes, pos + 6)
			var img_flags := bytes[pos + 8]
			pos += 9
 
			var palette := global_palette
			if img_flags & 0x80:
				var lct_size := 3 * (1 << ((img_flags & 7) + 1))
				palette = bytes.slice(pos, pos + lct_size)
				pos += lct_size
			var interlaced := (img_flags & 0x40) != 0
 
			if pos >= bytes.size():
				break
			var min_code := bytes[pos]
			pos += 1
 
			var data := PackedByteArray()
			while pos < bytes.size():
				var chunk_len := bytes[pos]
				pos += 1
				if chunk_len == 0:
					break
				data.append_array(bytes.slice(pos, pos + chunk_len))
				pos += chunk_len
 
			var indices := _lzw_decode(data, min_code, fw * fh)
 
			# Apply the previous frame's disposal before drawing this one.
			if prev_disposal == 2:
				_clear_rect(canvas, width, height, prev_rect)
			elif prev_disposal == 3 and not saved.is_empty():
				canvas = saved
			if gce_disposal == 3:
				saved = canvas.duplicate()
 
			_draw_frame(canvas, width, height, indices, palette,
					left, top, fw, fh, interlaced, gce_transparent)
 
			frames.append(Image.create_from_data(width, height, false,
					Image.FORMAT_RGBA8, canvas))
			delays.append(gce_delay)
 
			prev_disposal = gce_disposal
			prev_rect = Rect2i(left, top, fw, fh)
			gce_delay = 0.1
			gce_transparent = -1
			gce_disposal = 0
 
		else:
			push_warning("GIFDecoder: unknown block 0x%02x, stopping" % block)
			break
 
	if frames.is_empty():
		push_error("GIFDecoder: no frames decoded")
		return {}
 
	return {
		"width": width,
		"height": height,
		"frames": frames,
		"delays": delays,
		"loop_count": loop_count,
	}
 
 
static func _u16(b: PackedByteArray, p: int) -> int:
	return b[p] | (b[p + 1] << 8)
 
 
static func _skip_sub_blocks(b: PackedByteArray, p: int) -> int:
	while p < b.size():
		var n := b[p]
		p += 1
		if n == 0:
			break
		p += n
	return p
 
 
static func _clear_rect(canvas: PackedByteArray, cw: int, ch: int, r: Rect2i) -> void:
	var x0 := maxi(r.position.x, 0)
	var y0 := maxi(r.position.y, 0)
	var x1 := mini(r.end.x, cw)
	var y1 := mini(r.end.y, ch)
	for y in range(y0, y1):
		for x in range(x0, x1):
			var o := (y * cw + x) * 4
			canvas[o] = 0
			canvas[o + 1] = 0
			canvas[o + 2] = 0
			canvas[o + 3] = 0
 
 
static func _draw_frame(canvas: PackedByteArray, cw: int, ch: int,
		indices: PackedByteArray, palette: PackedByteArray,
		left: int, top: int, fw: int, fh: int,
		interlaced: bool, transparent: int) -> void:
	# rows[k] = destination row (within the frame) of the k-th decoded row
	var rows := PackedInt32Array()
	if interlaced:
		for pass_def in [[0, 8], [4, 8], [2, 4], [1, 2]]:
			for r in range(pass_def[0], fh, pass_def[1]):
				rows.append(r)
	else:
		for r in fh:
			rows.append(r)
 
	var pal_size := palette.size()
	for sy in fh:
		var dy := top + rows[sy]
		if dy >= ch:
			continue
		for sx in fw:
			var dx := left + sx
			if dx >= cw:
				break
			var idx := indices[sy * fw + sx]
			if idx == transparent:
				continue
			var p := idx * 3
			if p + 2 >= pal_size:
				continue
			var o := (dy * cw + dx) * 4
			canvas[o] = palette[p]
			canvas[o + 1] = palette[p + 1]
			canvas[o + 2] = palette[p + 2]
			canvas[o + 3] = 255
 
 
static func _lzw_decode(data: PackedByteArray, min_code_size: int,
		pixel_count: int) -> PackedByteArray:
	var out := PackedByteArray()
	out.resize(pixel_count)
	if min_code_size < 1 or min_code_size > 11:
		return out
 
	var clear := 1 << min_code_size
	var eoi := clear + 1
	var prefix := PackedInt32Array()
	prefix.resize(4096)
	var suffix := PackedByteArray()
	suffix.resize(4096)
	for i in clear:
		suffix[i] = i
	var stack := PackedByteArray()
	stack.resize(4097)
 
	var next_code := eoi + 1
	var code_size := min_code_size + 1
	var bit_buf := 0
	var bit_cnt := 0
	var pos := 0
	var out_pos := 0
	var prev := -1
	var first := 0
	var data_size := data.size()
 
	while out_pos < pixel_count:
		while bit_cnt < code_size and pos < data_size:
			bit_buf |= data[pos] << bit_cnt
			pos += 1
			bit_cnt += 8
		if bit_cnt < code_size:
			break # ran out of data
		var code := bit_buf & ((1 << code_size) - 1)
		bit_buf >>= code_size
		bit_cnt -= code_size
 
		if code == clear:
			next_code = eoi + 1
			code_size = min_code_size + 1
			prev = -1
			continue
		if code == eoi:
			break
 
		if prev == -1:
			if code >= clear:
				break # corrupt
			out[out_pos] = code
			out_pos += 1
			first = code
			prev = code
			continue
 
		if code > next_code:
			break # corrupt
 
		var cur := code
		var sp := 0
		if code >= next_code: # KwKwK case
			stack[sp] = first
			sp += 1
			cur = prev
		while cur >= clear:
			stack[sp] = suffix[cur]
			sp += 1
			cur = prefix[cur]
		first = cur
		stack[sp] = cur
		sp += 1
		while sp > 0:
			sp -= 1
			if out_pos < pixel_count:
				out[out_pos] = stack[sp]
				out_pos += 1
 
		if next_code < 4096:
			prefix[next_code] = prev
			suffix[next_code] = first
			next_code += 1
			if next_code == (1 << code_size) and code_size < 12:
				code_size += 1
		prev = code
 
	return out
