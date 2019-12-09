defmodule Problem09 do

end

# Part 1
{:ok, input } = File.read("lib/input.txt")
IntComputer.runProgram(input, [1]).output |> inspect |> IO.puts()

# Part 2
IntComputer.runProgram(input, [2]).output |> inspect |> IO.puts()