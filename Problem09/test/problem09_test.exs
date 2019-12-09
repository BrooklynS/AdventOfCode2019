defmodule Problem09Test do
  use ExUnit.Case
  doctest Problem09

  test "part1 copy" do
    input = "109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99"
    state = IntComputer.generateProgram(input)
    assert IntComputer.run(state).output == [109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99]
  end

  test "part1 16-digit number" do
    input = "1102,34915192,34915192,7,4,7,99,0"
    state = IntComputer.generateProgram(input)
    assert IntComputer.run(state).output |> Enum.at(0) == 1219070632396864
  end

  test "part1 largenumber" do
    input = "104,1125899906842624,99"
    state = IntComputer.generateProgram(input)
    assert IntComputer.run(state).output |> Enum.at(0) == 1125899906842624
  end
end
