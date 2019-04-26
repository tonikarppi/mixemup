import itertools

import pytest

import mixemup


def test_read_names_file():
    file_path = "examples/names.txt"
    lines = mixemup.read_lines(file_path)
    expected_lines = ["bob", "alice", "john", "jack", "sally"]
    for line, expected in zip(lines, expected_lines):
        assert line == expected
    with pytest.raises(StopIteration):
        next(lines)


def test_read_mkdir_file():
    file_path = "examples/mkdir.txt"
    lines = mixemup.read_lines(file_path)
    expected_lines = [
        "-m 666",
        "-p",
        "-v",
        "-Z",
        "--context CTX",
        "--help",
        "--version",
    ]
    for line, expected in zip(lines, expected_lines):
        assert line == expected
    with pytest.raises(StopIteration):
        next(lines)


@pytest.mark.parametrize(
    "strings", [(), ("a"), ("a", "b"), ("a", "b", "c"), ("a", "b", "c", "d")]
)
def test_combine_strings_num_combinations(strings):
    combinations = mixemup.combine_strings(strings)
    num_combinations = sum(1 for c in combinations)

    expected_length = 0
    for i in range(num_combinations + 1):
        expected_length += sum(1 for i in itertools.combinations(strings, i))

    assert num_combinations == expected_length


@pytest.mark.parametrize("delimiter", ["x", "xy", "xyz"])
def test_combine_strings_delimiter(delimiter):
    strings = ["a", "b", "c"]
    combinations_custom = mixemup.combine_strings(strings, delimiter)
    combinations_default = mixemup.combine_strings(strings)
    for custom, default in zip(combinations_custom, combinations_default):
        assert custom.split(delimiter) == default.split(" ")


@pytest.mark.parametrize("min_parts", range(1, 4))
def test_combine_strings_min_parts_in_range(min_parts):
    strings = ["a", "b", "c"]
    combinations = list(mixemup.combine_strings(strings, min_parts=min_parts))
    assert len(combinations[0].split(" ")) == min_parts


def test_combine_strings_min_parts_zero():
    strings = ["a", "b", "c"]
    combinations = list(mixemup.combine_strings(strings, min_parts=0))
    assert combinations[0] == ""


def test_combine_strings_min_parts_negative():
    strings = ["a", "b", "c"]
    with pytest.raises(ValueError):
        next(mixemup.combine_strings(strings, min_parts=-1))


@pytest.mark.parametrize("max_parts", range(1, 4))
def test_combine_strings_max_parts_in_range(max_parts):
    strings = ["a", "b", "c"]
    combinations = list(mixemup.combine_strings(strings, max_parts=max_parts))
    assert len(combinations[-1].split(" ")) == max_parts


def test_combine_strings_max_parts_zero():
    strings = ["a", "b", "c"]
    combinations = list(mixemup.combine_strings(strings, max_parts=0))
    assert combinations[-1] == ""


def test_combine_strings_max_parts_negative():
    strings = ["a", "b", "c"]
    with pytest.raises(ValueError):
        next(mixemup.combine_strings(strings, max_parts=-1))
