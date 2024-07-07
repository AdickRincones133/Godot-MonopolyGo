extends Node3D

var section1_positions = []
var section2_positions = []
var section3_positions = []
var static_body = null

var static_body_transform = Transform3D()
var is_interpolating = false
var target_position = Vector3.ZERO
var position_queue = []
var current_index = 0
var current_section = 1  
var awaiting_section_choice = false  

# Called when the node enters the scene tree for the first time.
func _ready():
	for child in self.get_children():
		if child.name.begins_with("Section1"):
			section1_positions.append(child.global_transform.origin)
		elif child.name.begins_with("Section2"):
			section2_positions.append(child.global_transform.origin)
		elif child.name.begins_with("Section3"):
			section3_positions.append(child.global_transform.origin)

	static_body = get_node("/root/Node3D/StaticBody3D")
	if static_body:
		static_body_transform = static_body.global_transform
	else:
		print("StaticBody3D node not found!")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_interpolating and static_body:
		var current_position = static_body_transform.origin
		var direction = (target_position - current_position).normalized()
		var speed = 1.0
		var new_position = current_position + direction * speed * delta

		static_body_transform.origin = new_position
		static_body.global_transform = static_body_transform

		if new_position.distance_to(target_position) < 0.01:
			static_body_transform.origin = target_position
			static_body.global_transform = static_body_transform
			if position_queue.size() > 0:
				target_position = position_queue.pop_front()
			else:
				is_interpolating = false
				if current_section == 1 and (current_index == 7 or current_index == 21 or current_index == 35 or current_index == 49):
					handle_special_position(current_index)
				elif current_section == 2 and (current_index == 5 or current_index == 16 or current_index == 26 or current_index == 36):
					handle_special_position_section2(current_index)
				elif current_section == 3 and (current_index == 4 or current_index == 5 or current_index == 10 or current_index == 16 or current_index == 22):
					handle_special_position_section3(current_index)

# Handles special positions and allows the user to choose the next section
func handle_special_position(index):
	if index in [7, 21, 35, 49]:
		print("Has caído en la casilla %d, elige tu movimiento." % index)
		print("Click izquierdo para continuar en sección 1, click derecho para cambiar a sección 2.")
		awaiting_section_choice = true

# Handles special positions in section 2 and allows the user to choose the next section
func handle_special_position_section2(index):
	if index in [5, 16, 26, 36]:
		print("Has caído en la casilla %d de la sección 2, elige tu movimiento." % index)
		print("Click izquierdo para continuar en sección 2, click derecho para cambiar a sección 3.")
		awaiting_section_choice = true

# Handles special positions in section 3 and allows the user to choose the next section
func handle_special_position_section3(index):
	if index in [4, 5, 10, 16, 22]:
		print("Has caído en la casilla %d de la sección 3, elige tu movimiento." % index)
		print("Click izquierdo para continuar en sección 3, click derecho para retroceder a sección 2.")
		awaiting_section_choice = true

# Detects mouse clicks and prints a random number between 1 and 6
func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if awaiting_section_choice:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if current_section == 1:
					continue_in_section1()
				elif current_section == 2:
					continue_in_section2()
				elif current_section == 3:
					continue_in_section3()
			elif event.button_index == MOUSE_BUTTON_MIDDLE:
				if current_section == 2:
					switch_back_to_previous_section()
				elif current_section == 3:
					switch_back_to_previous_section()
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				if current_section == 1:
					switch_to_section2()
				elif current_section == 2:
					switch_to_section3()

		elif not is_interpolating:
			var random_number = randi() % 6 + 1
			print(random_number)

			for i in range(random_number):
				current_index += 1
				if current_section == 1:
					if current_index >= section1_positions.size():
						current_index = 0
					position_queue.append(section1_positions[current_index])
				elif current_section == 2:
					if current_index >= section2_positions.size():
						current_index = 0
					position_queue.append(section2_positions[current_index])
				elif current_section == 3:
					if current_index >= section3_positions.size():
						current_index = 0
					position_queue.append(section3_positions[current_index])

			if position_queue.size() > 0:
				target_position = position_queue.pop_front()
				is_interpolating = true

# Continues in section 1
func continue_in_section1():
	awaiting_section_choice = false
	start_interpolating()

# Continues in section 2
func continue_in_section2():
	awaiting_section_choice = false
	start_interpolating()

# Continues in section 3
func continue_in_section3():
	awaiting_section_choice = false
	start_interpolating()

# Switches to section 2
func switch_to_section2():
	awaiting_section_choice = false
	current_section = 2

	# Determine starting index in section 2 based on the current index in section 1
	if current_index == 7:
		current_index = 5
	elif current_index == 21:
		current_index = 16
	elif current_index == 35:
		current_index = 26
	elif current_index == 49:
		current_index = 36
	else:
		current_index = 0  # Fallback in case something goes wrong

	# Clear position queue and add new position for interpolation
	position_queue.clear()
	position_queue.append(section2_positions[current_index])
	start_interpolating()

# Switches to section 3
func switch_to_section3():
	awaiting_section_choice = false
	current_section = 3

	# Determine starting index in section 3 based on the current index in section 2
	if current_index == 5:
		current_index = 4
	elif current_index == 16:
		current_index = 10
	elif current_index == 26:
		current_index = 16
	elif current_index == 36:
		current_index = 22
	else:
		current_index = 0  # Fallback in case something goes wrong

	# Clear position queue and add new position for interpolation
	position_queue.clear()
	position_queue.append(section3_positions[current_index])
	start_interpolating()

# Switches back to the previous section
func switch_back_to_previous_section():
	awaiting_section_choice = false

	if current_section == 2:
		current_section = 1
		if current_index == 5:
			current_index = 7
		elif current_index == 16:
			current_index = 21
		elif current_index == 26:
			current_index = 35
		elif current_index == 36:
			current_index = 49
		else:
			current_index = 0 # Fallback in case something goes wrong

		position_queue.clear()
		position_queue.append(section1_positions[current_index])
		start_interpolating()

	elif current_section == 3:
		current_section = 2
		if current_index == 4:
			current_index = 5
		elif current_index == 10:
			current_index = 16
		elif current_index == 16:
			current_index = 26
		elif current_index == 22:
			current_index = 36
		else:
			current_index = 0 # Fallback in case something goes wrong

		position_queue.clear()
		position_queue.append(section2_positions[current_index])
		start_interpolating()


# Starts the interpolation process if there are positions in the queue
func start_interpolating():
	if position_queue.size() > 0:
		target_position = position_queue.pop_front()
		is_interpolating = true
	else:
		is_interpolating = false
