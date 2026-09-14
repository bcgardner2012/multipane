extends Control
class_name BeetleGameBug

# Override this class with the specific bug you want to use

enum BugPartType {
	BODY,
	HEAD,
	LEG,
	EYE,
	ANTENNA,
	TAIL
}

class BugPart:
	var count: int
	var type: BugPartType
	var prereq # BugPartType or null
	
	func _init(_count: int, _type: BugPartType, _prereq):
		self.count = _count
		self.type = _type
		self.prereq = _prereq

var parts: Array[BugPart]
var built = {
	BugPartType.BODY: 0,
	BugPartType.HEAD: 0,
	BugPartType.LEG: 0,
	BugPartType.EYE: 0,
	BugPartType.ANTENNA: 0,
	BugPartType.TAIL: 0
}

@export var color: Color

func _ready() -> void:
	$Background.color = color
	$Body.self_modulate = color
	_init_parts()

func is_complete() -> bool:
	for val in BugPartType.values():
		# check part against the number currently built
		if parts[val].count != built[val]:
			return false
	return true

func increment(part_type: BugPartType) -> bool:
	var part = parts[part_type]
	if part.prereq != null and built[part.prereq] <= 0:
		# prereq not built, can't continue
		return false
	if part.count == built[part_type]:
		# already built all of this part, can't build more
		return false
	
	# To simplify logic, just call all parts something from this enum, whether
	# correct or not (fyi, beetles don't have tails)
	match part_type:
		BugPartType.BODY:
			$Body.visible = true
		BugPartType.HEAD:
			$Head.visible = true
		BugPartType.LEG:
			$Legs.get_child(built[part_type]).visible = true
		BugPartType.EYE:
			$Eyes.get_child(built[part_type]).visible = true
		BugPartType.ANTENNA:
			$Antennas.get_child(built[part_type]).visible = true
		BugPartType.TAIL:
			$Tail.visible = true
	
	built[part_type] += 1
	return true

# Override these

# keep parts in enum order
func _init_parts() -> void:
	pass
