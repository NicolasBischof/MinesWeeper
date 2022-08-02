extends Node

enum GameTypes {SQUARE = 0, HEXAGONAL = 1}
var game_type := GameTypes.SQUARE
var game_id := 2


var games := [
	[
		{"size": "Small",  "mines": 10, "dimensions": Vector2i(9, 9)},
		{"size": "Medium", "mines": 40, "dimensions": Vector2i(16, 16)},
		{"size": "Large",  "mines": 99, "dimensions": Vector2i(30, 16)}
	],
	[
		{"size": "Small",  "mines": 15, "maximal_radius": 11},
		{"size": "Medium", "mines": 60, "maximal_radius": 19},
		{"size": "Large",  "mines": 110, "maximal_radius": 25}
	]
]

var size:String:
	get: return games[game_type][game_id].size
var mines:int:
	get: return games[game_type][game_id].mines
var dimensions:Vector2i:
	get: return games[game_type][game_id].dimensions
var maximal_radius:int:
	get: return games[game_type][game_id].maximal_radius


func game_is_square() -> bool:
	return game_type == GameTypes.SQUARE

