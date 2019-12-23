defmodule Problem17 do
  
  def main() do
    {:ok, body} = File.read("lib/input.txt")
    state = IntComputer.generateProgram(body) |> IntComputer.run()
    to_string state.output |> IO.puts()

    # to_string state.output |> inspect |> IO.puts()
    string = String.split(to_string(state.output), "\n") |>
        Enum.map(fn input -> String.graphemes(input) end)

    width = Enum.at(string, 0) |> length()
    height = string |> length()

    Enum.flat_map(0..(height - 1), fn yIndex ->
        Enum.map(0..(width - 1), fn xIndex ->
            if yIndex > 0 and xIndex > 0 and yIndex < height - 1 and xIndex < width - 1 do
                if Enum.at(string, yIndex) |> Enum.at(xIndex) == "#" and Enum.at(string, yIndex - 1) |> Enum.at(xIndex) == "#" and Enum.at(string, yIndex + 1) |> Enum.at(xIndex) == "#" and Enum.at(string, yIndex) |> Enum.at(xIndex - 1) == "#" and Enum.at(string, yIndex) |> Enum.at(xIndex + 1) == "#" do
                        yIndex * xIndex
                else
                    0
                end
            else
                0
            end
        end)
    end) |> Enum.sum() |> IO.puts()

    # Part 2
    input = "A,A,C,B,C,B,C,A,B,A\nR,8,L,12,R,8\nL,12,L,12,L,10,R,10\nL,10,L,10,R,8\nn\n"
    state = IntComputer.generateProgram(body)
    state = %InstructionState
    {
        state | opcodeMap: Map.put(state.opcodeMap, 0, 2),
        input: to_charlist(input)
    } |> IntComputer.run()

    # to_string state.output |> inspect |> IO.puts()
    string = String.split(to_string(state.output), "\n") |>
        Enum.map(fn input -> to_charlist(input) |> inspect |> IO.puts() end)
  end

end
