# ############################################################################ #
# Copyright © 2019-present Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends "res://addons/gut/test.gd"

# ############################################################################ #
# Imports
# ############################################################################ #

var InkRuntime = load("res://addons/inkgd/runtime.gd")
var Story = load("res://addons/inkgd/runtime/story.gd")

# ############################################################################ #

func before_all():
    InkRuntime.init(get_tree().root)

func after_all():
    InkRuntime.deinit(get_tree().root)

func after_each():
    var InkRuntime = get_tree().root.get_node("__InkRuntime")

    InkRuntime.should_interrupt = false

func test_arithmetic():
    var story = Story.new(load_file("arithmetic"))
    assert_eq(story.continue_maximally(), "36\n2\n3\n2\n2.333333\n8\n8\n")

func test_basic_string_literals():
    var story = Story.new(load_file("basic_string_literals"))
    assert_eq(story.continue_maximally(), "Hello world 1\nHello world 2.\n")

func test_basic_tunnel():
    var story = Story.new(load_file("basic_tunnel"))
    assert_eq(story.continue(), "Hello world\n")

func test_blanks_in_inline_sequences():
    var story = Story.new(load_file("blanks_in_inline_sequences"))
    assert_eq(story.continue_maximally(), "1. a\n2.\n3. b\n4. b\n---\n1.\n2. a\n3. a\n---\n1. a\n2.\n3.\n---\n1.\n2.\n3.\n")

func test_call_stack_evaluation():
    var story = Story.new(load_file("call_stack_evaluation"))
    assert_eq(story.continue(), "8\n")

func test_choice_count():
    var story = Story.new(load_file("choice_count"))
    assert_eq(story.continue(), "2\n")

func test_choice_diverts_to_done():
    var story = Story.new(load_file("choice_diverts_to_done"))
    story.continue()

    assert_eq(story.current_choices.size(), 1)
    story.choose_choice_index(0)

    assert_eq(story.continue(), "choice")
    assert_false(story.has_error)

func test_choice_with_brackets_only():
    var story = Story.new(load_file("choice_with_brackets_only"))
    story.continue()

    assert_eq(story.current_choices.size(), 1)
    assert_eq(story.current_choices[0].text, "Option")
    story.choose_choice_index(0)

    assert_eq(story.continue(), "Text\n")

func test_compare_divert_targets():
    var story = Story.new(load_file("compare_divert_targets"))
    assert_eq(story.continue_maximally(), "different knot\nsame knot\nsame knot\ndifferent knot\nsame knot\nsame knot\n")

func test_complex_tunnels():
    var story = Story.new(load_file("complex_tunnels"))
    assert_eq(story.continue_maximally(), "one (1)\none and a half (1.5)\ntwo (2)\nthree (3)\n")

func test_conditional_choice():
    var story = Story.new(load_file("conditional_choices"))
    story.continue_maximally()

    assert_eq(story.current_choices.size(), 4)
    assert_eq(story.current_choices[0].text, "one")
    assert_eq(story.current_choices[1].text, "two")
    assert_eq(story.current_choices[2].text, "three")
    assert_eq(story.current_choices[3].text, "four")

func test_conditionals():
    var story = Story.new(load_file("conditionals"))
    assert_eq(story.continue_maximally(), "true\ntrue\ntrue\ntrue\ntrue\ngreat\nright?\n")

func test_const():
    var story = Story.new(load_file("const"))
    assert_eq(story.continue(), "5\n")

func test_default_simple_gather():
    var story = Story.new(load_file("default_simple_gather"))
    assert_eq(story.continue(), "x\n")

func test_divert_in_conditional():
    var story = Story.new(load_file("divert_in_conditional"))
    assert_eq(story.continue_maximally(), "")

func test_divert_to_weave_points():
    var story = Story.new(load_file("divert_to_weave_points"))
    assert_eq(story.continue_maximally(), "gather\ntest\nchoice content\ngather\nsecond time round\n")

func test_else_branches():
    var story = Story.new(load_file("else_branches"))
    assert_eq(story.continue_maximally(), "other\nother\nother\nother\n")

func test_empty():
    var story = Story.new(load_file("empty"))
    assert_eq(story.continue_maximally(), "")

func test_empty_multiline_conditional_branch():
    var story = Story.new(load_file("empty_multiline_conditional_branch"))
    assert_eq(story.continue(), "")

func test_all_switch_branches_fail_is_clean():
    var story = Story.new(load_file("all_switch_branches_fail_is_clean"))
    story.continue()

    assert_eq(story.state.evaluation_stack.size(), 0)

func test_trivial_condition():
    var story = Story.new(load_file("trivial_condition"))
    story.continue()

    assert_false(story.has_error)

# NOTE: These tests are different from the original C# test suite,
# but they match the behaviour found in Inky. This will need
# to be investigated.
func test_conditional_choice_in_weave():
    var story = Story.new(load_file("conditional_choice_in_weave"))

    assert_eq(story.continue_maximally(), "start\n")
    assert_eq(story.current_choices.size(), 1)
    assert_eq(story.current_choices[0].text, "go to a stitch")

    story.choose_choice_index(0)

    assert_eq(story.continue_maximally(), "result\n")

func test_conditional_choice_in_weave_2():
    var story = Story.new(load_file("conditional_choice_in_weave_2"))

    assert_eq(story.continue(), "first gather\n")
    assert_eq(story.current_choices.size(), 2)

    story.choose_choice_index(0)

    assert_eq(story.continue_maximally(), "the main gather\n")
    assert_eq(story.current_choices.size(), 0)
    assert_true(story.has_error)
# #############

func test_default_choice():
    var story = Story.new(load_file("default_choices"))

    assert_eq(story.continue(), "")
    assert_eq(story.current_choices.size(), 2)

    story.choose_choice_index(0)
    assert_eq(story.continue(), "After choice\n")

    assert_eq(story.current_choices.size(), 1)

    story.choose_choice_index(0)
    assert_eq(story.continue_maximally(), "After choice\nThis is default.\n")

func test_end():
    var story = Story.new(load_file("end"))

    assert_eq(story.continue_maximally(), "hello\n")

func test_end2():
    var story = Story.new(load_file("end2"))

    assert_eq(story.continue_maximally(), "hello\n")

func test_escape_character():
    var story = Story.new(load_file("escape_character"))

    assert_eq(story.continue_maximally(), "this is a '|' character\n")

func test_factorial_by_reference():
    var story = Story.new(load_file("factorial_by_reference"))

    assert_eq(story.continue_maximally(), "120\n")

func test_factorial_recursive():
    var story = Story.new(load_file("factorial_recursive"))

    assert_eq(story.continue_maximally(), "120\n")

func test_gather_choice_same_line():
    var story = Story.new(load_file("gather_choice_same_line"))

    story.continue()
    assert_eq(story.current_choices[0].text, "hello")

    story.choose_choice_index(0)
    story.continue()

    assert_eq(story.current_choices[0].text, "world")

func test_gather_read_count_with_initial_sequence():
    var story = Story.new(load_file("gather_read_count_with_initial_sequence"))

    assert_eq(story.continue(), "seen test\n")

func test_has_read_on_choice():
    var story = Story.new(load_file("has_read_on_choice"))
    story.continue_maximally();

    assert_eq(story.current_choices.size(), 1)
    assert_eq(story.current_choices[0].text, "visible choice")

func test_hello_world():
    var story = Story.new(load_file("hello_world"))

    assert_eq(story.continue(), "Hello world\n")

func test_implicit_inline_glue():
    var story = Story.new(load_file("implicit_inline_glue"))

    assert_eq(story.continue(), "I have five eggs.\n")

func test_implicit_inline_glue_b():
    var story = Story.new(load_file("implicit_inline_glue_b"))

    assert_eq(story.continue_maximally(), "A\nX\n")

func test_implicit_inline_glue_c():
    var story = Story.new(load_file("implicit_inline_glue_c"))

    assert_eq(story.continue_maximally(), "A\nC\n")

func test_include():
    var story = Story.new(load_file("include"))

    assert_eq(story.continue_maximally(), "This is include 1.\nThis is include 2.\nThis is the main file.\n")

func test_increment():
    var story = Story.new(load_file("increment"))

    assert_eq(story.continue_maximally(), "6\n5\n")

func test_knot_do_not_gather():
    var story = Story.new(load_file("knot_do_not_gather"))

    assert_eq(story.continue(), "g\n")

func test_knot_thread_interaction():
    var story = Story.new(load_file("knot_thread_interaction"))

    assert_eq(story.continue_maximally(), "blah blah\n")

    assert_eq(story.current_choices.size(), 2)
    assert_true(story.current_choices[0].text.find("option") != -1)
    assert_true(story.current_choices[1].text.find("wigwag") != -1)

    story.choose_choice_index(1)
    assert_eq(story.continue(), "wigwag\n")
    assert_eq(story.continue(), "THE END\n")
    assert_false(story.has_error)

func test_knot_thread_interaction_2():
    var story = Story.new(load_file("knot_thread_interaction_2"))

    assert_eq(story.continue_maximally(), "I’m in a tunnel\nWhen should this get printed?\n")
    assert_eq(story.current_choices.size(), 1)
    assert_eq(story.current_choices[0].text, "I’m an option")

    story.choose_choice_index(0)
    assert_eq(story.continue_maximally(), "I’m an option\nFinishing thread.\n")
    assert_false(story.has_error)

func test_leading_newline_multiline_sequence():
    var story = Story.new(load_file("leading_newline_multiline_sequence"))

    assert_eq(story.continue(), "a line after an empty line\n")

func test_literal_unary():
    var story = Story.new(load_file("literal_unary"))

    assert_eq(story.continue_maximally(), "-1\n0\n1\n")

func test_logic_in_choices():
    var story = Story.new(load_file("logic_in_choices"))

    story.continue_maximally()

    assert_eq(story.current_choices[0].text, "'Hello Joe, your name is Joe.'")
    story.choose_choice_index(0)
    assert_eq(story.continue_maximally(), "'Hello Joe,' I said, knowing full well that his name was Joe.\n")

func test_multiple_constant_references():
    var story = Story.new(load_file("multiple_constant_references"))

    assert_eq(story.continue(), "success\n")

func test_multi_thread():
    var story = Story.new(load_file("multi_thread"))

    assert_eq(story.continue_maximally(), "This is place 1.\nThis is place 2.\n")
    story.choose_choice_index(0)
    assert_eq(story.continue_maximally(), "choice in place 1\nThe end\n")
    assert_false(story.has_error)

func test_nested_include():
    var story = Story.new(load_file("nested_include"))

    assert_eq(story.continue_maximally(), "The value of a variable in test file 2 is 5.\nThis is the main file\nThe value when accessed from knot_in_2 is 5.\n");

func test_nested_pass_by_reference():
    var story = Story.new(load_file("nested_pass_by_reference"))

    assert_eq(story.continue_maximally(), "5\n625\n");

func test_non_text_in_choice_inner_content():
    var story = Story.new(load_file("non_text_in_choice_inner_content"))

    story.continue()
    story.choose_choice_index(0)

    assert_eq(story.continue(), "option text. Conditional bit. Next.\n");

func test_once_only_choices_can_link_back_to_self():
    var story = Story.new(load_file("once_only_choices_can_link_back_to_self"))

    story.continue_maximally()

    assert_eq(story.current_choices.size(), 1)
    assert_eq(story.current_choices[0].text, "First choice")

    story.choose_choice_index(0)
    story.continue_maximally()

    assert_eq(story.current_choices.size(), 1)
    assert_eq(story.current_choices[0].text, "Second choice")

    story.choose_choice_index(0)
    story.continue_maximally()

    assert_false(story.has_error)

func test_once_only_choices_with_own_content():
    var story = Story.new(load_file("once_only_choices_with_own_content"))

    story.continue_maximally()

    assert_eq(story.current_choices.size(), 3)

    story.choose_choice_index(0)
    story.continue_maximally()

    assert_eq(story.current_choices.size(), 2)

    story.choose_choice_index(0)
    story.continue_maximally()

    assert_eq(story.current_choices.size(), 1)

    story.choose_choice_index(0)
    story.continue_maximally()

    assert_eq(story.current_choices.size(), 0);

func test_print_num():
    var story = Story.new(load_file("print_num"))

    assert_eq(
        story.continue_maximally(),
        ". four .\n. fifteen .\n. thirty-seven .\n. one hundred and one .\n. two hundred and twenty-two .\n. one thousand two hundred and thirty-four .\n"
    )

func test_quote_character_significance():
    var story = Story.new(load_file("quote_character_significance"))

    assert_eq(story.continue_maximally(), "My name is \"Joe\"\n")

func test_same_line_divert_is_inline():
    var story = Story.new(load_file("same_line_divert_is_inline"))

    assert_eq(story.continue(), "We hurried home to Savile Row as fast as we could.\n")

func test_should_not_gather_due_to_choice():
    var story = Story.new(load_file("should_not_gather_due_to_choice"))

    story.continue_maximally()
    story.choose_choice_index(0)

    assert_eq(story.continue_maximally(), "opt\ntext\n")

func test_shuffle_stack_muddying():
    var story = Story.new(load_file("shuffle_stack_muddying"))

    story.continue()

    assert_eq(story.current_choices.size(), 2)

func test_simple_glue():
    var story = Story.new(load_file("simple_glue"))

    assert_eq(story.continue(), "Some content with glue.\n")

func test_sticky_choices_stay_sticky():
    var story = Story.new(load_file("sticky_choices_stay_sticky"))

    story.continue_maximally()
    assert_eq(story.current_choices.size(), 2)

    story.choose_choice_index(0)
    story.continue_maximally()
    assert_eq(story.current_choices.size(), 2)

func test_string_constants():
    var story = Story.new(load_file("string_constants"))

    assert_eq(story.continue(), "hi\n")

func test_string_in_choices():
    var story = Story.new(load_file("strings_in_choices"))

    story.continue_maximally()

    assert_eq(story.current_choices.size(), 1)
    assert_eq(story.current_choices[0].text, "test1 \"test2 test3\"")

    story.choose_choice_index(0)
    assert_eq(story.continue(), "test1 test4\n")

func test_string_type_coercion():
    var story = Story.new(load_file("string_type_coercion"))

    assert_eq(story.continue_maximally(), "same\ndifferent\n")

func test_temporaries_at_global_scope():
    var story = Story.new(load_file("temporaries_at_global_scope"))

    assert_eq(story.continue(), "54\n")

func test_thread_done():
    var story = Story.new(load_file("thread_done"))

    assert_eq(story.continue_maximally(), "This is a thread example\nHello.\nThe example is now complete.\n")

func test_tunnel_onwards_after_tunnel():
    var story = Story.new(load_file("tunnel_onwards_after_tunnel"))

    assert_eq(story.continue_maximally(), "Hello...\n...world.\nThe End.\n")

func test_tunnel_vs_thread_behaviour():
    var story = Story.new(load_file("tunnel_vs_thread_behaviour"))

    assert_false(story.continue_maximally().find("Finished tunnel") != -1)
    assert_eq(story.current_choices.size(), 2)

    story.choose_choice_index(0)

    assert_true(story.continue_maximally().find("Finished tunnel") != -1)
    assert_eq(story.current_choices.size(), 3)

    story.choose_choice_index(2)

    assert_true(story.continue_maximally().find("Done.") != -1)

func test_unbalanced_weave_indentation():
    var story = Story.new(load_file("unbalanced_weave_indentation"))

    story.continue_maximally()

    assert_eq(story.current_choices.size(), 1)
    assert_eq(story.current_choices[0].text, "First")

    story.choose_choice_index(0)
    assert_eq(story.continue_maximally(), "First\n")
    assert_eq(story.current_choices.size(), 1)
    assert_eq(story.current_choices[0].text, "Very indented")

    story.choose_choice_index(0)
    assert_eq(story.continue_maximally(), "Very indented\nEnd\n")
    assert_eq(story.current_choices.size(), 0)

func test_variable_declaration_in_conditional():
    var story = Story.new(load_file("variable_declaration_in_conditional"))

    assert_eq(story.continue(), "5\n")

func test_variable_divert_target():
    var story = Story.new(load_file("variable_divert_target"))

    assert_eq(story.continue(), "Here.\n")

func test_variable_get_set_api():
    var story = Story.new(load_file("variable_get_set_api"))

    assert_eq(story.continue_maximally(), "5\n")
    assert_eq(story.variables_state.get("x"), 5)

    story.variables_state.set("x", 10)
    story.choose_choice_index(0)
    assert_eq(story.continue_maximally(), "10\n")
    assert_eq(story.variables_state.get("x"), 10)

    story.variables_state.set("x", 8.5);
    story.choose_choice_index(0);
    assert_eq(story.continue_maximally(), "8.5\n")
    assert_eq(story.variables_state.get("x"), 8.5)

    story.variables_state.set("x", "a string")
    story.choose_choice_index(0)
    assert_eq(story.continue_maximally(), "a string\n")
    assert_eq(story.variables_state.get("x"), "a string")

    assert_eq(story.variables_state.get("z"), null)

    story.variables_state.set("x", [])
    var InkRuntime = get_tree().root.get_node("__InkRuntime")
    assert_true(InkRuntime.should_interrupt)

func test_variable_observer():
    var story = Story.new(load_file("variable_observer"))

    self._test_variable_observer_current_var_value = 0
    self._test_variable_observer_observer_call_count = 0

    story.observe_variable("testVar", self, "_variable_observer_test")
    story.continue_maximally()

    assert_eq(self._test_variable_observer_current_var_value, 15)
    assert_eq(self._test_variable_observer_observer_call_count, 1)
    assert_eq(story.current_choices.size(), 1)

    story.choose_choice_index(0)
    story.continue()

    assert_eq(self._test_variable_observer_current_var_value, 25)
    assert_eq(self._test_variable_observer_observer_call_count, 2)

func test_variable_pointer_ref_from_knot():
    var story = Story.new(load_file("variable_pointer_ref_from_knot"))

    assert_eq(story.continue(), "6\n")

func test_variable_swap_recurse():
    var story = Story.new(load_file("variable_swap_recurse"))

    assert_eq(story.continue_maximally(), "1 2\n")

func test_variable_tunnel():
    var story = Story.new(load_file("variable_tunnel"))

    assert_eq(story.continue_maximally(), "STUFF\n")

func test_weave_gathers():
    var story = Story.new(load_file("weave_gathers"))

    story.continue_maximally()

    assert_eq(story.current_choices.size(), 2)
    assert_eq(story.current_choices[0].text, "one")
    assert_eq(story.current_choices[1].text, "four")

    story.choose_choice_index(0)
    story.continue_maximally()

    assert_eq(story.current_choices.size(), 1)
    assert_eq(story.current_choices[0].text, "two")

    story.choose_choice_index(0)
    assert_eq(story.continue_maximally(), "two\nthree\nsix\n")

func test_weave_options():
    var story = Story.new(load_file("weave_options"))

    story.continue_maximally()

    assert_eq(story.current_choices[0].text, "Hello.")

    story.choose_choice_index(0)
    assert_eq(story.continue(), "Hello, world.\n")

func test_whitespace():
    var story = Story.new(load_file("whitespace"))

    assert_eq(story.continue_maximally(), "Hello!\nWorld.\n")

func test_temp_global_conflict():
    var story = Story.new(load_file("temp_global_conflict"))

    assert_eq(story.continue(), "0\n")

func test_thread_in_logic():
    var story = Story.new(load_file("thread_in_logic"))

    assert_eq(story.continue(), "Content\n")

func test_temp_usage_in_options():
    var story = Story.new(load_file("temp_usage_in_options"))

    story.continue()

    assert_eq(story.current_choices.size(), 1)
    assert_eq(story.current_choices[0].text, "1")
    story.choose_choice_index(0)

    assert_eq(story.continue_maximally(), "1\nEnd of choice\nthis another\n");

    assert_eq(story.current_choices.size(), 0);

func test_evaluating_ink_functions_from_game():
    var story = Story.new(load_file("evaluating_ink_functions_from_game"))

    story.continue()

    var returned_divert_target = story.evaluate_function("test")

    assert_eq("somewhere.here", returned_divert_target)

func test_evaluating_ink_functions_from_game_2():
    var story = Story.new(load_file("evaluating_ink_functions_from_game_2"))

    var text_output = null
    var func_result = story.evaluate_function("func1", null, true)

    assert_eq(func_result["output"], "This is a function\n")
    assert_eq(func_result["result"], 5)

    assert_eq(story.continue(), "One\n")

    func_result = story.evaluate_function("func2", null, true)
    assert_eq(func_result["output"], "This is a function without a return value\n")
    assert_eq(func_result["result"], null)

    assert_eq(story.continue(), "Two\n")

    func_result = story.evaluate_function("add", [1, 2], true)
    assert_eq(func_result["output"], "x = 1, y = 2\n")
    assert_eq(func_result["result"], 3)

    assert_eq(story.continue(), "Three\n")

func test_evaluating_function_variable_state_bug():
    var story = Story.new(load_file("evaluating_function_variable_state_bug"))

    assert_eq(story.continue(), "Start\n")
    assert_eq(story.continue(), "In tunnel.\n")

    var func_result = story.evaluate_function("function_to_evaluate")
    assert_eq(func_result, "RIGHT")

    assert_eq(story.continue(), "End\n")

func test_external_binding():
    var story = Story.new(load_file("external_binding"))

    story.bind_external_function("message", self, "_external_binding_message")
    story.bind_external_function("multiply", self, "_external_binding_multiply")
    story.bind_external_function("times", self, "_external_binding_times")

    assert_eq(story.continue(), "15\n")

    assert_eq(story.continue(), "knock knock knock\n")

    assert_eq(_test_external_binding_message, "MESSAGE: hello world")

func test_done_stops_thread():
    var story = Story.new(load_file("done_stops_thread"))

    assert_eq(story.continue_maximally(), "")

func test_left_right_glue_matching():
    var story = Story.new(load_file("left_right_glue_matching"))

    assert_eq(story.continue_maximally(), "A line.\nAnother line.\n")

func test_set_non_existant_variable():
    var story = Story.new(load_file("set_non_existant_variable"))

    assert_eq(story.continue(), "Hello world.\n")

    story.variables_state.set("y", "earth")
    var InkRuntime = get_tree().root.get_node("__InkRuntime")
    assert_true(InkRuntime.should_interrupt)

func test_tags():
    var story = Story.new(load_file("tags"))

    var global_tags = ["author: Joe", "title: My Great Story"]
    var knot_tags = ["knot tag"]
    var knot_tag_when_continued_twice_tags = ["end of knot tag"]
    var stitch_tags = ["stitch tag"]

    assert_eq(story.global_tags, global_tags)
    assert_eq(story.continue(), "This is the content\n")
    assert_eq(story.current_tags, global_tags)

    assert_eq(story.tags_for_content_at_path("knot"), knot_tags)
    assert_eq(story.tags_for_content_at_path("knot.stitch"), stitch_tags)

    story.choose_path_string("knot")
    assert_eq(story.continue(), "Knot content\n")
    assert_eq(story.current_tags, knot_tags)
    assert_eq(story.continue(), "")
    assert_eq(story.current_tags, knot_tag_when_continued_twice_tags)

func test_tunnel_onwards_divert_override():
    var story = Story.new(load_file("tunnel_onwards_divert_override"))

    assert_eq(story.continue_maximally(), "This is A\nNow in B.\n")

func test_list_basic_operations():
    var story = Story.new(load_file("list_basic_operations"))

    assert_eq(story.continue_maximally(), "b, d\na, b, c, e\nb, c\n0\n1\n1\n")

func test_list_mixed_items():
    var story = Story.new(load_file("list_mixed_items"))

    assert_eq(story.continue_maximally(), "a, y, c\n")

func test_more_list_operations():
    var story = Story.new(load_file("more_list_operations"))

    assert_eq(story.continue_maximally(), "1\nl\nn\nl, m\nn\n")

func test_empty_list_origin():
    var story = Story.new(load_file("empty_list_origin"))

    assert_eq(story.continue_maximally(), "a, b\n")

func test_empty_list_origin_after_assignment():
    var story = Story.new(load_file("empty_list_origin_after_assignment"))

    assert_eq(story.continue_maximally(), "a, b, c\n")

func test_list_save_load():
    var story = Story.new(load_file("list_save_load"))

    assert_eq(story.continue_maximally(), "a, x, c\n")

    var saved_state = story.state.to_json()

    story = Story.new(load_file("list_save_load"))

    story.state.load_json(saved_state)

    story.choose_path_string("elsewhere")
    assert_eq(story.continue_maximally(), "a, x, c, z\n")

func test_weave_within_sequence():
    var story = Story.new(load_file("weave_within_sequence"))

    story.continue()

    assert_eq(story.current_choices.size(), 1)

    story.choose_choice_index(0)

    assert_eq(story.continue_maximally(), "choice\nnextline\n")

func test_tunnel_onwards_divert_after_with_arg():
    var story = Story.new(load_file("tunnel_onwards_divert_after_with_arg"))

    assert_eq(story.continue_maximally(), "8\n")

func test_various_default_choices():
    var story = Story.new(load_file("various_default_choices"))

    assert_eq(story.continue_maximally(), "1\n2\n3\n")

func test_tunnel_onwards_with_param_default_choice():
    var story = Story.new(load_file("tunnel_onwards_with_param_default_choice"))

    assert_eq(story.continue_maximally(), "8\n")

func test_read_count_variable_target():
    var story = Story.new(load_file("read_count_variable_target"))

    assert_eq(story.continue_maximally(), "Count start: 0 0 0\n1\n2\n3\nCount end: 3 3 3\n")

func test_divert_targets_with_parameters():
    var story = Story.new(load_file("divert_targets_with_parameters"))

    assert_eq(story.continue_maximally(), "5\n")

func test_tags_on_choice():
    var story = Story.new(load_file("tags_on_choice"))

    story.continue()
    story.choose_choice_index(0)

    var txt = story.continue()
    var tags = story.current_tags

    assert_eq(txt, "Hello")
    assert_eq(tags.size(), 1)
    assert_eq(tags[0], "hey")

func test_string_contains():
    var story = Story.new(load_file("string_contains"))

    assert_eq(story.continue_maximally(), "1\n0\n1\n1\n")

func test_evaluation_stack_leaks():
    var story = Story.new(load_file("evaluation_stack_leaks"))

    assert_eq(story.continue_maximally(), "else\nelse\nhi\n")
    assert_eq(0, story.state.evaluation_stack.size())

func test_game_ink_back_and_forth():
    _game_ink_back_and_forth_story = Story.new(load_file("game_ink_back_and_forth"))

    _game_ink_back_and_forth_story.bind_external_function("gameInc", self, "_game_ink_back_and_forth_game_inc")
    var final_result = _game_ink_back_and_forth_story.evaluate_function("topExternal", [5], true)

    assert_eq(final_result.result, 7)
    assert_eq(final_result.output, "In top external\n")

func test_newlines_with_string_eval():
    var story = Story.new(load_file("newlines_with_string_eval"))

    assert_eq(story.continue_maximally(), "A\nB\nA\n3\nB\n")

func test_newlines_trimming_with_func_external_fallback():
    var story = Story.new(load_file("newlines_trimming_with_func_external_fallback"))
    story.allow_external_function_fallbacks = true

    assert_eq(story.continue_maximally(), "Phrase 1\nPhrase 2\n")

func test_multiline_logic_with_glue():
    var story = Story.new(load_file("multiline_logic_with_glue"))

    assert_eq(story.continue_maximally(), "a b\na b\n")

func test_newline_at_start_of_multiline_conditional():
    var story = Story.new(load_file("newline_at_start_of_multiline_conditional"))

    assert_eq(story.continue_maximally(), "X\nx\n")

func test_temp_not_found():
    var story = Story.new(load_file("temp_not_found"))

    assert_eq(story.continue_maximally(), "0\nhello\n")
    assert_true(story.has_warning)

func test_top_flow_terminator_should_not_kill_thread_choices():
    var story = Story.new(load_file("top_flow_terminator_should_not_kill_thread_choices"))

    assert_eq(story.continue(), "Limes\n")
    assert_eq(story.current_choices.size(), 1)

func test_newline_consistency():
    var story = Story.new(load_file("newline_consistency_1"))
    assert_eq(story.continue_maximally(), "hello world\n")

    story = Story.new(load_file("newline_consistency_2"))
    story.continue()
    story.choose_choice_index(0)
    assert_eq(story.continue_maximally(), "hello world\n")

    story = Story.new(load_file("newline_consistency_3"))
    story.continue()
    story.choose_choice_index(0)
    assert_eq(story.continue_maximally(), "hello\nworld\n")

func test_list_random():
    var story = Story.new(load_file("list_random"))

    while story.can_continue:
        var result = story.continue()
        assert_true(result == "B\n" || result == "C\n" || result == "D\n")

func test_turns():
    var story = Story.new(load_file("turns"))

    var i = 0
    while i < 10:
        assert_eq(str(i, "\n"), story.continue())
        story.choose_choice_index(0)

        i += 1

func test_logic_lines_with_newlines():
    var story = Story.new(load_file("logic_lines_with_newlines"))

    assert_eq(story.continue_maximally(), "text1\ntext 2\ntext1\ntext 2\n")

func test_floor_ceiling_and_casts():
    var story = Story.new(load_file("floor_ceiling_and_casts"))

    assert_eq(story.continue_maximally(), "1\n1\n2\n0.666667\n0\n1\n")

func test_fallback_choice_on_thread():
    var story = Story.new(load_file("fallback_choice_on_thread"))

    assert_eq(story.continue(), "Should be 1 not 0: 1.\n")

func test_clean_callstack_reset_on_path_choice():
    var story = Story.new(load_file("clean_callstack_reset_on_path_choice"))

    assert_eq("The first line.\n", story.continue())

    story.choose_path_string("SomewhereElse")

    assert_eq("somewhere else\n", story.continue_maximally())

func test_end_of_content():
    var story = Story.new(load_file("end_of_content"))

    story.continue_maximally()
    assert_false(story.has_error)

func test_path_to_self():
    var story = Story.new(load_file("path_to_self"))

    story.continue()
    story.choose_choice_index(0)

    story.continue()
    story.choose_choice_index(0)

    assert_true(story.can_continue)

func test_empty_sequence_content():
    var story = Story.new(load_file("empty_sequence_content"))

    assert_eq(story.continue_maximally(), "Wait for it....\nSurprise!\nDone.\n")

func test_identifiers_can_start_with_number():
    var story = Story.new(load_file("identifiers_can_start_with_number"))

    assert_eq(story.continue_maximally(), "512x2 = 1024\n512x2p2 = 1026\n")

func test_read_count_across_callstack():
    var story = Story.new(load_file("read_count_across_callstack"))

    assert_eq(story.continue_maximally(), "1) Seen first 1 times.\nIn second.\n2) Seen first 1 times.\n")

func test_read_count_across_threads():
    var story = Story.new(load_file("read_count_across_threads"))

    assert_eq(story.continue_maximally(), "1\n1\n")

func test_read_count_dot_separated_path():
    var story = Story.new(load_file("read_count_dot_separated_path"))

    assert_eq(story.continue_maximally(), "hi\nhi\nhi\n3\n")

func test_turns_since_nested():
    var story = Story.new(load_file("turns_since_nested"))

    assert_eq(story.continue_maximally(), "-1 = -1\n")

    assert_eq(story.current_choices.size(), 1);
    story.choose_choice_index(0);

    assert_eq(story.continue_maximally(), "stuff\n0 = 0\n");

    assert_eq(story.current_choices.size(), 1);
    story.choose_choice_index(0);

    assert_eq(story.continue_maximally(), "more stuff\n1 = 1\n");

func test_turns_since_with_variable_target():
    var story = Story.new(load_file("turns_since_with_variable_target"))

    assert_eq(story.continue_maximally(), "0\n0\n")

    story.choose_choice_index(0)
    assert_eq(story.continue_maximally(), "1\n")

func test_turns_since():
    var story = Story.new(load_file("turns_since"))

    assert_eq(story.continue_maximally(), "-1\n0\n");

    story.choose_choice_index(0)
    assert_eq(story.continue_maximally(), "1\n");

    story.choose_choice_index(0)
    assert_eq(story.continue_maximally(), "2\n");

func test_visit_counts_when_choosing():
    var story = Story.new(load_file("visit_counts_when_choosing"))

    assert_eq(story.state.visit_count_at_path_string("TestKnot"), 0)
    assert_eq(story.state.visit_count_at_path_string("TestKnot2"), 0)

    story.choose_path_string("TestKnot")

    assert_eq(story.state.visit_count_at_path_string("TestKnot"), 1)
    assert_eq(story.state.visit_count_at_path_string("TestKnot2"), 0)

    story.continue()

    assert_eq(story.state.visit_count_at_path_string("TestKnot"), 1)
    assert_eq(story.state.visit_count_at_path_string("TestKnot2"), 0)

    story.choose_choice_index(0)

    assert_eq(story.state.visit_count_at_path_string("TestKnot"), 1)
    assert_eq(story.state.visit_count_at_path_string("TestKnot2"), 0)

    story.continue()

    assert_eq(story.state.visit_count_at_path_string("TestKnot"), 1)
    assert_eq(story.state.visit_count_at_path_string("TestKnot2"), 1)

func test_knot_stitch_gather_counts():
    var story = Story.new(load_file("knot_stitch_gather_counts"))

    assert_eq(story.continue_maximally(), "1 1\n2 2\n3 3\n1 1\n2 1\n3 1\n1 2\n2 2\n3 2\n1 1\n2 1\n3 1\n1 2\n2 2\n3 2\n")

func test_list_range():
    var story = Story.new(load_file("list_range"))

    assert_eq(story.continue_maximally(), "Pound, Pizza, Euro, Pasta, Dollar, Curry, Paella\nEuro, Pasta, Dollar, Curry\nTwo, Three, Four, Five, Six\nPizza, Pasta\n")

func test_choice_thread_forking():
    var story = Story.new(load_file("choice_thread_forking"))

    story.continue()
    var saved_state = story.state.to_json()

    story = Story.new(load_file("choice_thread_forking"))
    story.state.load_json(saved_state)

    story.choose_choice_index(0)
    story.continue_maximally()

    assert_false(story.has_warning)

func test_warn_variable_not_found():
    var story1 = Story.new(load_file("warn_variable_not_found_1"))

    story1.continue()

    var save_state = story1.state.to_json()

    var story2 = Story.new(load_file("warn_variable_not_found_2"))
    story2.state.load_json(save_state)
    story2.continue()

    assert_true(story2.has_warning)

    for warning in story2.current_warnings:
        if warning.find("not found") != -1:
            return

    assert_true(false, "Ink did not warn about missing variables.")

# ############################################################################ #

var _test_variable_observer_current_var_value = 0
var _test_variable_observer_observer_call_count = 0

func _variable_observer_test(var_name, new_value):
    self._test_variable_observer_current_var_value = new_value
    self._test_variable_observer_observer_call_count += 1

# ############################################################################ #

var _test_external_binding_message = null

func _external_binding_message(arg):
    _test_external_binding_message = "MESSAGE: " + arg

func _external_binding_multiply(arg1, arg2):
    return arg1 * arg2;

func _external_binding_times(number_of_times, string_value):
    var result = ""

    var i = 0
    while (i < number_of_times):
        result += string_value
        i += 1

    return result;

# ############################################################################ #

var _game_ink_back_and_forth_story = null

func _game_ink_back_and_forth_game_inc(x):
    x += 1
    x = _game_ink_back_and_forth_story.evaluate_function ("inkInc", [x])
    return x

# ############################################################################ #

func load_file(file_name):
    var data_file = File.new()
    var path = "res://test/fixture/compiled/" + file_name + ".ink.json"
    if data_file.open(path, File.READ) != OK:
        return null

    var data_text = data_file.get_as_text()
    data_file.close()

    return data_text
