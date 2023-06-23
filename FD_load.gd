extends FileDialog

# log file path set and get init
var log_file:
	set(path):
		log_file = path
	get:
		return log_file
		
signal log_file_finish

# Called when the node enters the scene tree for the first time.
func _ready():
	file_selected.connect(_on_file_selected)
	init_FD_load()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func init_FD_load() :
	access = 2
	#object.current_dir = "/"
	current_dir = "C:/Users/steve/Documents/FUNWAVE-TVD/simple_cases/vessel_island_beach"
	title = "Open LOG.txt file"
	size = Vector2(500, 500)
	file_mode = FileDialog.FILE_MODE_OPEN_FILE
	initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
	mode = Window.MODE_WINDOWED
	print("init load window")

func _on_file_selected(path) :
	set("log_file", path)
	print(get("log_file"))
	log_file_finish.emit()
	

