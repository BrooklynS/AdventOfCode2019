defmodule Problem06Test do
  use ExUnit.Case
  doctest Problem06

  test "Part1" do
    assert Problem06.getOrbitCount("test/testinput.txt") == 42
  end

  test "Part2" do
    assert Problem06.getSantaDistance("test/testsanta.txt") == 4
  end
end
