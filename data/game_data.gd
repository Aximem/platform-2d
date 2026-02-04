extends Node
class_name GameData

const BULLET_DAMAGE = 10
const ENNEMY_HEALTH_POINT = 100

const PNJ_DIALOGUES = {
	0: {
		"question": [
			"Pour aller plus loin dans l'aventure, tu vas devoir trouver le mot de passe.",
			"Je peux être en couleur ou en noir et blanc, et je ne change jamais.\nJe ressemble à la réalité, mais je ne suis pas vivante.\nJe peux être rangée dans un album ou sur un téléphone.",
		],
		"answer": {
			"value": "photo",
			"correct": "Oui Photo, Bravo ! Tu peux continuer ton aventure.",
			"incorrect": "Non, je vais répéter."
		}
	},
	1: {
		"question": [
			"Encore moi, tu vas devoir trouver le dernier mot de passe.",
			"J’arrive sans prévenir et je fais souvent sourire.\nJe fait dire « Oh ! » ou « Waouh ! » quand on me découvre.\nJe me passe souvent lors d’un anniversaire ou d’une fête.",
		],
		"answer": {
			"value": "surprise",
			"correct": "Oui Suprise, Bravo ! Photo Surprise !",
			"incorrect": "Non, je te donne un indice supplémentaire."
		}
	},
	2: {
		"question": [
			"J’entre dans une pièce plongée dans le noir, la lumière s’allume et tout le monde crie ce mot !",
			"J’arrive sans prévenir et je fais souvent sourire.\nJe fait dire « Oh ! » ou « Waouh ! » quand on me découvre.\nJe me passe souvent lors d’un anniversaire ou d’une fête.",
		],
		"answer": {
			"value": "surprise",
			"correct": "Oui Suprise, Bravo ! Photo Surprise !",
			"incorrect": "Non, je vais répéter."
		}
	}
}
