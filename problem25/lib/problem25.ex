defmodule Problem25 do

    defp runProgramRecursive(programState) do

        newState = IntComputer.run(programState)
        asciiOutput = newState.output |> Enum.filter(fn char -> char <= 255 end)
        otherOutput = newState.output |> Enum.filter(fn char -> char > 255 end)
        IO.puts(asciiOutput)
        if(length(otherOutput) > 0) do
            IO.puts(otherOutput |> inspect)
        end

        if newState.status != :done do
            result = IO.gets("") |> to_charlist
            IntComputer.flushOutput(newState)
            |> IntComputer.addInput(result)
            |> runProgramRecursive()
        else
            newState
        end
    end

    def main() do
        {:ok, body} = File.read("lib/input.txt")
        programState = IntComputer.generateProgram(body)
        |> runProgramRecursive
    end
end
