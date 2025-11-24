extends Area2D

@onready var clock = $"../Clock"
@onready var night_barrier = $NightBarrier
@onready var player = $"../Player"


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	update_barrier()


func _process(delta: float) -> void:
	update_barrier()


func _on_body_entered(body: Player):
	body.enter_ocean()
	
	
func _on_body_exited(body: Player):
	body.exit_ocean()

# Turn on barrier at night when player on island
func update_barrier():
	var enabled = not clock.is_day and not player.is_in_ocean
	var collision_shape = night_barrier.get_node_or_null("CollisionShape2D")
	collision_shape.disabled = not enabled
