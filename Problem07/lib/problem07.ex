defmodule Problem07 do

    defp permuteNoRepeat(input, curDepth, maxDepth, offset) do
        cond do
            curDepth == maxDepth ->
                input
            curDepth == 0 ->
                newInput = Enum.map(offset..offset + maxDepth - 1, fn x -> [x] end)
                permuteNoRepeat(newInput, curDepth + 1, maxDepth, offset)
            true ->
                Enum.flat_map(offset..offset + maxDepth - 1, fn phase ->
                    Enum.filter(input, fn phaseList ->
                        Enum.all?(phaseList, fn item -> item != phase end)
                    end) |> Enum.map(fn phaseList -> List.flatten([phase | phaseList]) end)
                 end) |>
                    permuteNoRepeat(curDepth + 1, maxDepth, offset)
        end
    end

    defp runAmpInternal(program, phases) do

        context = 
        [
            ampA: %{program | input: [Enum.at(phases, 0)]},
            ampB: %{program | input: [Enum.at(phases, 1)]},
            ampC: %{program | input: [Enum.at(phases, 2)]},
            ampD: %{program | input: [Enum.at(phases, 3)]},
            ampE: %{program | input: [Enum.at(phases, 4)]}
        ]
        runAmpLoopRecursive(context, 0)
    end

    defp runAmpLoopRecursive(context, prevOutput) do

        resultA = IntComputer.run(%{context[:ampA] | input: Enum.concat(context[:ampA].input, [prevOutput])})
        resultB = IntComputer.run(%{context[:ampB] | input: Enum.concat(context[:ampB].input, [List.last(resultA.output)])})
        resultC = IntComputer.run(%{context[:ampC] | input: Enum.concat(context[:ampC].input, [List.last(resultB.output)])})
        resultD = IntComputer.run(%{context[:ampD] | input: Enum.concat(context[:ampD].input, [List.last(resultC.output)])})
        resultE = IntComputer.run(%{context[:ampE] | input: Enum.concat(context[:ampE].input, [List.last(resultD.output)])})

        if(resultE.status != :done) do
            context = 
            [
                ampA: resultA,
                ampB: resultB,
                ampC: resultC,
                ampD: resultD,
                ampE: resultE,
            ]   
            runAmpLoopRecursive(context, List.last(resultE.output))
        else
            List.last(resultE.output)
        end
    end

        def runAmpProgram(program_text, input) do
        program = IntComputer.generateProgram(program_text)
        runAmpInternal(program, input)
    end

    def maximizeAmpOutput(program_text) do
        program = IntComputer.generateProgram(program_text)

        permuteNoRepeat([], 0, 5, 0) |>
            Enum.map(&(runAmpInternal(program, &1))) |>
            Enum.max()
    end

    def maximizePart2AmpOutput(program_text) do
        program = IntComputer.generateProgram(program_text)

        permuteNoRepeat([], 0, 5, 5) |>
            Enum.map(&(runAmpInternal(program, &1))) |>
            Enum.max()
    end
end

# Part 1
{:ok, input } = File.read("lib/input.txt")
Problem07.maximizeAmpOutput(input) |> inspect |> IO.puts()

# Part 2
Problem07.maximizePart2AmpOutput(input) |> inspect |> IO.puts()