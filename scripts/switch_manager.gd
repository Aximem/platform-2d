extends Node

signal switch_activated(id: int, color: String)

func _ready():
	switch_activated.connect(_on_switch_activated)
	
func _on_switch_activated(id: int, color: String):
	var question = GameData.question_data[id]
	var correct_answer = question["correct_answer"]
	if correct_answer == color:
		print("Correct")
	else:
		print("Incorrect")
	
