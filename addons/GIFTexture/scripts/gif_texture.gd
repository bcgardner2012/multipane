@tool
class_name GIFTexture
extends ImageTexture
## An ImageTexture that plays back an animated GIF.
##
## Works anywhere a normal texture does (Sprite2D, TextureRect, 3D materials,
## shader sampler2D uniforms). It updates itself once per rendered frame.
##
## Usage:
##   var tex := GIFTexture.from_file("res://anim.gif")
##   $Sprite2D.texture = tex
 
signal frame_changed(index: int)
signal finished ## emitted when a non-looping GIF reaches its last frame
 
## Full-canvas, same-size, RGBA8 frames.
@export var frames: Array[Image] = []:
	set(value):
		frames = value
		_rebuild()
## Seconds each frame is shown. Must match frames in length.
@export var delays := PackedFloat32Array()
@export var loop := true
@export_range(0.0, 10.0, 0.01, "or_greater") var speed_scale := 1.0
@export var playing := true
 
var _index := 0
var _elapsed := 0.0
var _last_usec := 0
var _connected := false
 
 
static func from_file(path: String) -> GIFTexture:
	var bytes := FileAccess.get_file_as_bytes(path)
	if bytes.is_empty():
		push_error("GIFTexture: couldn't read '%s' (%s)" % [path, error_string(FileAccess.get_open_error())])
		return null
	return from_buffer(bytes)
 
 
static func from_buffer(bytes: PackedByteArray) -> GIFTexture:
	var d := GIFDecoder.decode(bytes)
	if d.is_empty():
		return null
	var tex := GIFTexture.new()
	tex.delays = d["delays"]
	tex.loop = d["loop_count"] != 1
	tex.frames = d["frames"] # setter builds the texture, so assign last
	return tex
 
 
func get_frame_count() -> int:
	return frames.size()
 
 
func get_frame() -> int:
	return _index
 
 
func get_duration() -> float:
	var total := 0.0
	for d in delays:
		total += d
	return total
 
 
func play() -> void:
	_last_usec = Time.get_ticks_usec() # don't count time spent paused
	playing = true
 
 
func pause() -> void:
	playing = false
 
 
func stop() -> void:
	playing = false
	set_frame(0)
 
 
func set_frame(index: int) -> void:
	if frames.is_empty():
		return
	index = clampi(index, 0, frames.size() - 1)
	_elapsed = 0.0
	if index != _index:
		_index = index
		update(frames[_index])
		frame_changed.emit(_index)
 
 
func _rebuild() -> void:
	_index = 0
	_elapsed = 0.0
	if frames.is_empty():
		return
	set_image(frames[0])
	_last_usec = Time.get_ticks_usec()
	if not _connected:
		var tree := Engine.get_main_loop() as SceneTree
		if tree:
			tree.process_frame.connect(_tick)
			_connected = true
 
 
func _tick() -> void:
	var now := Time.get_ticks_usec()
	var dt := (now - _last_usec) / 1_000_000.0
	_last_usec = now
	if not playing or frames.size() < 2 or delays.size() != frames.size():
		return
 
	_elapsed += dt * maxf(speed_scale, 0.0)
	var start := _index
	while _elapsed >= maxf(delays[_index], 0.01):
		_elapsed -= maxf(delays[_index], 0.01)
		if _index == frames.size() - 1:
			if loop:
				_index = 0
			else:
				_elapsed = 0.0
				playing = false
				finished.emit()
				break
		else:
			_index += 1
 
	if _index != start:
		update(frames[_index])
		frame_changed.emit(_index)
