# ############################################################################ #
# Copyright © 2015-present inkle Ltd.
# Copyright © 2019-present Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

const Utils = preload("res://addons/inkgd/runtime/extra/utils.gd")

# (String) -> Dictionary<String, Variant>
static func text_to_dictionary(text):
	return Reader.new(text).to_dictionary()

# (String) -> Dictionary<String, Variant>
static func text_to_array(text):
	return Reader.new(text).to_array()

class Reader:

	# (String) -> Reader
	func _init(text):
		_text = text
		_offset = 0

		skip_whitespace()

		_root_object = read_object()

	# () -> Dictionary<String, Variant>
	func to_dictionary():
		return _root_object

	# () -> Array<Variant>
	func to_array():
		return _root_object

	# (String) -> bool
	func is_number_char(c):
		if c.length() > 1: return

		return c.is_valid_integer() || c == "." || c == "-" || c == "+" || c == 'E' || c == 'e'

	# (String) -> bool
	func is_first_number_char(c):
		if c.length() > 1: return

		return c.is_valid_integer() || c == "-" || c == "+"

	# () -> Variant
	func read_object():
		var current_char = _text[_offset]

		if current_char == "{":
			return read_dictionary()

		elif current_char == "[":
			return read_array()

		elif current_char == "\"":
			return read_string()

		elif is_first_number_char(current_char):
			return read_number()

		elif try_read("true"):
			return true

		elif try_read("false"):
			return false

		elif try_read("null"):
			return null

		Utils.throw_exception("Unhandled object type in JSON: " + _text.substr(_offset, 30))
		return JsonError.new()

	# () -> Dictionary<String, Variant>
	func read_dictionary():
		var dict = {} # Dictionary<String, Variant>

		if !expect("{"):
			return null

		skip_whitespace()

		if try_read("}"):
			return dict

		var first_time = true
		while first_time || try_read(","):
			first_time = false

			skip_whitespace()

			var key = read_string()
			if !expect(key != null, "dictionary key"):
				return null

			skip_whitespace()

			if !expect(":"):
				return null

			skip_whitespace()

			var val = read_object()
			if !expect(val != null, "dictionary value"):
				return null

			dict[key] = val

			skip_whitespace()

		if !expect("}"):
			return null

		return dict

	# () -> Array<Variant>
	func read_array():
		var list = []

		if !expect("["):
			return null

		skip_whitespace()

		if try_read("]"):
			return list

		var first_time = true
		while first_time || try_read(","):
			first_time = false

			skip_whitespace()

			var val = read_object()

			list.append(val)

			skip_whitespace()

		if !expect("]"):
			return null

		return list

	# () -> String
	func read_string():
		if !expect("\""):
			return null

		var sb = ""

		while(_offset < _text.length()):
			var c = _text[_offset]

			if c == "\\":
				_offset += 1
				if _offset >= _text.length():
					Utils.throw_exception("Unexpected EOF while reading string")
					return null
				c = _text[_offset]
				match c:
					"\"", "\\", "/":
						sb += c
					"n":
						sb += "\n"
					"t":
						sb += "\t"
					"r", "b", "f":
						pass
					"u":
						if _offset + 4 >= _text.length():
							Utils.throw_exception("Unexpected EOF while reading string")
							return null
						var digits = _text.substr(_offset + 1, 4)

						var json_parse_result = JSON.parse("\"\\u" + digits + "\"")
						if json_parse_result.error != OK:
							Utils.throw_exception("Invalid Unicode escape character at offset " + (_offset - 1))
							return null

						sb += json_parse_result.result
						_offset += 4

						break
					_:
						Utils.throw_exception("Invalid Unicode escape character at offset " + (_offset - 1))
						return null
			elif c == "\"":
				break
			else:
				sb += c

			_offset += 1

		if !expect("\""):
			return null
		return sb

	# () -> Variant
	func read_number():
		var start_offset = _offset

		var is_float = false

		while(_offset < _text.length()):
			var c = _text[_offset]
			if (c == "." || c == "e" || c == "E"): is_float = true
			if is_number_char(c):
				_offset += 1
				continue
			else:
				break

			_offset += 1

		var num_str = _text.substr(start_offset, _offset - start_offset)

		if is_float:
			if num_str.is_valid_float():
				return float(num_str)
		else:
			if num_str.is_valid_integer():
				return int(num_str)

		Utils.throw_exception("Failed to parse number value: " + num_str)
		return JsonError.new()

	# (String) -> bool
	func try_read(text_to_read):
		if _offset + text_to_read.length() > _text.length():
			return false

		var i = 0
		while (i < text_to_read.length()):
			if text_to_read[i] != _text[_offset + i]:
				return false

			i += 1


		_offset += text_to_read.length()

		return true


	# (bool | String, String) -> bool
	func expect(condition_or_expected_str, message = null):
		var _condition = false

		if condition_or_expected_str is String:
			_condition = try_read(condition_or_expected_str)
		elif condition_or_expected_str is bool:
			_condition = condition_or_expected_str

		if !_condition:
			if message == null:
				message = "Unexpected token"
			else:
				message = "Expected " + message

			message += str(" at offset ", _offset)

			Utils.throw_exception(message)
			return false

		return true

	func skip_whitespace():
		while _offset < _text.length():
			var c = _text[_offset]
			if c == " " || c == "\t" || c == "\n" || c == "\r":
				_offset += 1
			else:
				break

	var _text = null # String
	var _offset = 0 # int

	var _root_object # Variant

class Writer:
	# ######################################################################## #
	# Imports
	# ######################################################################## #

	var StringWriter = load("res://addons/inkgd/runtime/extra/string_writer.gd")
	var StateElement = load("res://addons/inkgd/runtime/extra/state_element.gd")

	# (String) -> Writer
	func _init():
		self._writer = StringWriter.new()

	# (FuncRef) -> void
	func write_object(inner):
		write_object_start()
		inner.call_func(self)
		write_object_end()

	func write_object_start():
		start_new_object(true)
		self._state_stack.push_front(StateElement.new(StateElement.State.OBJECT))
		self._writer.write("{")

	func write_object_end():
		assert_that(self.state == StateElement.State.OBJECT)
		self._writer.write("}")
		self._state_stack.pop_front()

	# These two methods don't need to be implemented in GDScript.
	#
	# public void WriteProperty(string name, Action<Writer> inner)
	# public void WriteProperty(int id, Action<Writer> inner)

	# Also include:
	# void WriteProperty<T>(T name, Action<Writer> inner)
	# (String, Variant) -> void
	func write_property(name, content):
		if (content is String || content is int || content is bool):
			write_property_start(name)
			write(content)
			write_property_end()
		elif content is FuncRef:
			write_property_start(name)
			content.call_func(self)
			write_property_end()
		else:
			push_error("Wrong type for 'content': " + str(content))

	# These two methods don't need to be implemented in GDScript.
	#
	# public void WritePropertyStart(string name)
	# public void WritePropertyStart(int id)

	# () -> void
	func write_property_end():
		assert_that(self.state == StateElement.State.PROPERTY)
		assert_that(self.child_count == 1)
		self._state_stack.pop_front()

	# (String) -> void
	func write_property_name_start():
		assert_that(self.state == StateElement.State.OBJECT)

		if self.child_count > 0:
			self._writer.write(',')

		self._writer.write('"')

		increment_child_count()

		self._state_stack.push_front(StateElement.new(StateElement.State.PROPERTY))
		self._state_stack.push_front(StateElement.new(StateElement.State.PROPERTY_NAME))

	# () -> void
	func write_property_name_end():
		assert_that(self.state == StateElement.State.PROPERTY_NAME)

		self._writer.write('":')

		self._state_stack.pop_front()

	# (String) -> void
	func write_property_name_inner(string):
		assert_that(self.state == StateElement.State.PROPERTY_NAME)
		self._writer.write(string)

	# (Variant) -> void
	func write_property_start(name):
		assert_that(self.state == StateElement.State.OBJECT)

		if self.child_count > 0:
			self._writer.write(',')

		self._writer.write('"')
		self._writer.write(str(name))
		self._writer.write('":')

		increment_child_count()

		_state_stack.push_front(StateElement.new(StateElement.State.PROPERTY))

	# () -> void
	func write_array_start():
		start_new_object(true)
		_state_stack.push_front(StateElement.new(StateElement.State.ARRAY))
		_writer.write("[")

	# () -> void
	func write_array_end():
		assert_that(self.state == StateElement.State.ARRAY)
		_writer.write("]")
		_state_stack.pop_front()

	# This method didn't exist as-is in the original implementation.
	# (Variant) -> void
	func write(content):
		if content is int:
			write_int(content)
		elif content is float:
			write_float(content)
		elif content is String:
			write_string(content)
		elif content is bool:
			write_bool(content)
		else:
			push_error("Wrong type for 'content': " + str(content))

	# (int) -> void
	func write_int(i):
		start_new_object(false)
		_writer.write(str(i))

	# (float) -> void
	func write_float(f):
		start_new_object(false)

		var float_str = str(f)

		# We could probably use 3.402823e+38, but keeping
		# ±3.4e+38 for compatibility with the reference implementation.
		if float_str == "inf":
			_writer.write("3.4e+38")
		elif float_str == "-inf":
			_writer.write("-3.4e+38")
		elif float_str == "nan":
			_writer.write("0.0")
		else:
			_writer.write(float_str)
			# The exponent part is defensive as Godot doesn't seem to convert
			# floats to string in such a way.
			if !("." in float_str) && !("e" in float_str) && !("E" in float_str):
				_writer.write(".0")

	# (String, bool) -> void
	func write_string(string, escape = true):
		start_new_object(false)
		_writer.write('"')
		if escape:
			write_escaped_string(string)
		else:
			_writer.write(string)
		_writer.write('"')

	# (bool) -> void
	func write_bool(b):
		start_new_object(false)
		_writer.write("true" if b else "false")

	# () -> void
	func write_null():
		start_new_object(false)
		_writer.write("null")

	# () -> void
	func write_string_start():
		start_new_object(true)
		_state_stack.push_front(StateElement.new(StateElement.State.STRING))
		_writer.write('"')

	# () -> void
	func write_string_end():
		assert_that(state == StateElement.State.STRING)
		_writer.write('"')
		_state_stack.pop_front()

	# (string, bool) -> void
	func write_string_inner(string, escape = true):
		assert_that(self.state == StateElement.State.STRING)
		if escape:
			write_escaped_string(string)
		else:
			_writer.write(string)

	# (String) -> void
	func write_escaped_string(string):
		for c in string:
			if c < ' ':
				match c:
					"\n":
						_writer.write("\\n")
					"\t":
						_writer.write("\\t")
			else:
				match c:
					'\\', '"':
						_writer.write("\\")
						_writer.write(c)
					_:
						_writer.write(c)

	# (bool) -> void
	func start_new_object(container):
		if container:
			assert_that(self.state == StateElement.State.NONE || self.state == StateElement.State.PROPERTY || self.state == StateElement.State.ARRAY)
		else:
			assert_that(self.state == StateElement.State.PROPERTY || self.state == StateElement.State.ARRAY)

		if self.state == StateElement.State.ARRAY && self.child_count > 0:
			_writer.write(",")

		if self.state == StateElement.State.PROPERTY:
			assert_that(self.child_count == 0)

		if self.state == StateElement.State.ARRAY || self.state == StateElement.State.PROPERTY:
			increment_child_count()

	var state setget , get_state # StateElement.State
	func get_state():
		if _state_stack.size() > 0:
			return _state_stack.front().type
		else:
			return StateElement.State.NONE

	var child_count setget , get_child_count # int
	func get_child_count():
		if _state_stack.size() > 0:
			return _state_stack.front().child_count
		else:
			return 0

	# () -> void
	func increment_child_count():
		assert_that(_state_stack.size() > 0)
		var curr_el = _state_stack.pop_front()
		curr_el.child_count += 1
		_state_stack.push_front(curr_el)

	# (bool) -> void
	func assert_that(condition):
		if OS.is_debug_build(): return

		if !condition:
			push_error("Assert failed while writing JSON")
			assert(condition)

	# () -> String
	func to_string():
		return _writer.to_string()

	var _state_stack = [] # Array<StateElement>
	var _writer # StringWriter


class JsonError:
	func init():
		pass
