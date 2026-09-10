extends BeetleGameBug
class_name BeetleGameBeetle

func _init_parts() -> void:
	parts = [
		BugPart.new(1, BugPartType.BODY, null),
		BugPart.new(1, BugPartType.HEAD, BugPartType.BODY),
		BugPart.new(6, BugPartType.LEG, BugPartType.BODY),
		BugPart.new(2, BugPartType.EYE, BugPartType.HEAD),
		BugPart.new(2, BugPartType.ANTENNA, BugPartType.HEAD),
		BugPart.new(1, BugPartType.TAIL, BugPartType.BODY)
	]
