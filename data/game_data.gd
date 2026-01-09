extends Node
class_name GameData

const BULLET_DAMAGE = 10
const ENNEMY_HEALTH_POINT = 100

const PNJ_DIALOGUES = {
	0: {
		"question": [
			"Pour aller plus loin dans l'aventure, tu vas devoir trouver le mot de passe.",
			"Je t'aide un peu c'est un adjectif qu'on cherche ici.",
			"On doit lever la tête pour me regarder.\nLes portes trop basses ne sont pas mes amies.\nAux échecs, il existe un titre très respecté avec ce mot.",
		],
		"answer": {
			"value": "grand",
			"correct": "Oui Grand, Bravo ! Tu peux continuer ton aventure.",
			"incorrect": "Non, je vais répéter."
		}
	}
}
