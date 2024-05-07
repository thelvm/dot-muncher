class_name LevelParameters
extends Resource

@export_enum("Hunt", "Scatter") var intial_state: int

@export_range(0, 120) var hunt_time: int
@export_range(0, 120) var scatter_time: int
@export_range(0, 120) var panic_time: int
