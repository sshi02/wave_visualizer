extends Node

var fd_load

# input params
var result_folder : String
var vessel_folder : String
var mglob : int
var nglob : int
var dx : float
var dy : float
var total_t : float
var dt : float
var num_vessel: int

# sim params
var num_eta = 0
var min_eta = 9223372036854775807
var max_eta = 0
var cur_mesh = PlaneMesh.new()
var surf_tool = SurfaceTool.new()
var data_tool = MeshDataTool.new()
var array_plane

# init of simulation
func _ready():
	fd_load = get_node("FD_load")
	fd_load.log_file_finish.connect(_on_finish_log_file_path)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_finish_log_file_path():
	print("Finished FD_load")
	#print(fd_load.get("log_file"))
	analyzeLOG(fd_load.get("log_file"))
	debug_print()

func analyzeLOG(path):
	var log = FileAccess.open(path, FileAccess.READ)
	var regex = RegEx.new()
	regex.compile("(\\w+\\s*=\\s*\\w+\\.*\\w*)|(\\w+\\s*:\\s*\\.*\\w*/+)")
	
	while not log.eof_reached():
		var ln = log.get_line()
		if "STATISTICS" in ln:	#END OF FILE Case 2
			break
		if not "!" in ln:
			var parsed = regex.search_all(ln)
			if parsed:
				for result in parsed:
					var key : String
					var val : String
					if ('=' in result.get_string()):
						key = result.get_string().get_slice("=", 0).strip_edges(true, true)
						val = result.get_string().get_slice("=", 1).strip_edges(true, true)
					else:
						key = result.get_string().get_slice(":", 0).strip_edges(true, true)
						val = result.get_string().get_slice(":", 1).strip_edges(true, true)
					
					# DEBUG OUTPUT
					#print("Key: " + key + ", " + "Val: " + val)
					match key:
						"Mglob":
							mglob = int(val)
						"Nglob":
							nglob = int(val)
						"DX":
							dx = float(val)
						"DY":
							dy = float(val)
						"TOTAL_TIME":
							total_t = float(val)
						"PLOT_INTV":
							dt = float(val)
						"RESULT_FOLDER":
							result_folder = val
						"VESSEL_FOLDER":
							vessel_folder = val
						"NumVessel":
							num_vessel = int(val)

func readETA(path):
	var dir = DirAccess.open(path.split("LOG.txt")[0] + result_folder)
	print(path.split("LOG.txt")[0])
	
	# num_eta / frames calc iteration
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir() && "eta_" in file_name:
				var cur_eta_num = int(file_name.split("_")[1])
				if cur_eta_num > max_eta:
					max_eta = cur_eta_num
				if cur_eta_num < min_eta:
					min_eta = cur_eta_num
				num_eta += 1
			file_name = dir.get_next()
		print("Finish")
	else:
		print("An error occurred when trying to access the path.")
	if (mglob != 0 && nglob != 0):
		print("Making Mesh")
		cur_mesh.size = Vector2(mglob, nglob)
		cur_mesh.subdivide_depth = mglob - 1
		cur_mesh.subdivide_width = nglob - 1
		$surface.mesh = cur_mesh
		print($surface.mesh.size)
		var ins = MeshInstance3D.new()
		add_child(ins)
		ins.position = Vector3(0, 0, 0)
		var sphere = SphereMesh.new()
		sphere.radius = 0.1
		sphere.height = 0.2
		ins.mesh = sphere
	pass
	
# debug func
func debug_print():
	print("result folder: " + result_folder)
	print("vessel folder: " + vessel_folder)
	print("mglob, nglob")
	print(mglob)
	print(nglob)
	print("dx, dy")
	print(dx)
	print(dy)
	print("total_t, dt")
	print(total_t)
	print(dt)
	print("vessel num")
	print(num_vessel)
