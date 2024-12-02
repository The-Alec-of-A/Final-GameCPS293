extends Node

var gameStarted: bool
var playerBody: CharacterBody2D
var playerAlive: bool
var playerDamageZone: Area2D
var playerDamageAmount: int

var enemyBody: CharacterBody2D
var enemyDamageZone: Area2D
var enemyDamageAmount: int

var attackType: String
