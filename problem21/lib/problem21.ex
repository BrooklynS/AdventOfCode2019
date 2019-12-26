defmodule Problem21 do

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

    defp runFromInstructionList(programState, code) do
        String.split(code, "\r")
        |> Enum.map(&(to_charlist(&1)))
        |> Enum.reduce(programState, fn input,acc ->
            acc |> IntComputer.addInput(input)
        end)
        |> runProgramRecursive()
    end

    def main() do
        {:ok, body} = File.read("lib/input.txt")
        programState = IntComputer.generateProgram(body);

        # Read instructions from program text and apply each to the initial state.
        {:ok, code} = File.read("lib/program1.txt")
        runFromInstructionList(programState, code)

        # Program 2.
        {:ok, code} = File.read("lib/program2.txt")
        runFromInstructionList(programState, code)
    end

end
