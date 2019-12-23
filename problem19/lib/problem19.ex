defmodule Problem19 do
 
    def getLocation(x, y, program) do
        result = program |> IntComputer.addInput([x, y]) |> IntComputer.run()
        Enum.at(result.output, 0)
    end

    defp findStartingspot(x, y, program) do

        if getLocation(x, y, program) == 1 do
            x
        else
            findStartingspot(x + 1, y, program)
        end
    end

    defp findSpotRecursive(x, y, program) do

        if getLocation(x, y, program) == 1
            and getLocation(x + 99, y, program) == 1
            and getLocation(x + 99, y - 99, program) == 1
            and getLocation(x, y - 99, program) == 1 do
            [ x: x, y: y - 99 ]
        else
            if getLocation(x + 1, y, program) == 1 and getLocation(x + 1, y + 1, program) == 0 do
                findSpotRecursive(x + 1, y, program)
            else
                x = findStartingspot(x, y + 1, program)
                findSpotRecursive(x, y + 1, program)
            end
        end
    end

    def main() do
        {:ok, body} = File.read("lib/input.txt")

        program = IntComputer.generateProgram(body)
        Enum.flat_map(0..49, fn x ->
            Enum.map(0..49, fn y ->
                getLocation(x, y, program)
            end)
        end) |> Enum.sum() |> IO.puts()

        program = IntComputer.generateProgram(body)
        x = findStartingspot(0, 100, program)
        result = findSpotRecursive(x, 100, program)
        (result[:x] * 10000 + result[:y]) |> inspect |> IO.puts()
    end
end
