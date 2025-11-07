extends Node2D

@export var path_color: Color = Color(0.82, 0.447, 0.0, 1.0)
@export var path_width: float = 3.0
@export var show_paths: bool = false

# Cache NavigationAgents for quick access
var agents: Array = []


func _ready() -> void:
	#Collect all units with NavigationAgents
	set_process(true)
	update_agent_list()

func _process(_delta: float) -> void:
		queue_redraw()
	
func _draw() -> void:
		draw_path()


func update_agent_list():
	agents.clear()
	for unit in get_tree().get_nodes_in_group("Units"):
		var agent = unit.get_node_or_null("NavigationAgent2D")
		if agent:
			#print(agent)
			agents.append(agent)
			
func draw_path():
	if show_paths:
		for agent in agents:
			if not is_instance_valid(agent):
				continue
			if not agent.is_navigation_finished():
				var path_points = agent.get_current_navigation_path()
				if path_points.size() >= 2:
					for i in range(path_points.size() - 1):
						var from = path_points[i]
						var to = path_points[i + 1]
						draw_line(from, to, path_color, path_width)
