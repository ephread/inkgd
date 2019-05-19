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

    # (String) -> bool
    func is_number_char(c):
        if c.length() > 1: return

        return c.is_valid_integer() || c == "." || c == "-" || c == "+"

    # () -> Variant
    func read_object():
        var current_char = _text[_offset]

        if current_char == "{":
            return read_dictionary()

        elif current_char == "[":
            return read_array()

        elif current_char == "\"":
            return read_string()

        elif is_number_char(current_char):
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

        if !expect("{"): return null

        skip_whitespace()

        if try_read("}"):
            return dict

        var first_time = true
        while first_time || try_read(","):
            first_time = false

            skip_whitespace()

            var key = read_string()
            if !expect(key != null, "dictionary key"): return null

            skip_whitespace()

            if !expect(":"): return null

            skip_whitespace()

            var val = read_object()
            if !expect(val != null, "dictionary value"): return null

            dict[key] = val

            skip_whitespace()

        if !expect("}"): return null

        return dict

    # () -> Array<Variant>
    func read_array():
        var list = []

        if !expect("["): return null

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

        if !expect("]"): return null

        return list

    # () -> String
    func read_string():
        if !expect("\""): return null

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

        if !expect("\""): return null
        return sb

    # () -> Variant
    func read_number():
        var start_offset = _offset

        var is_float = false

        while(_offset < _text.length()):
            var c = _text[_offset]
            if c == ".": is_float = true
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

        Utils.throw_exception("Failed to parse number value")
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

class JsonError:
    func init():
        pass
