defmodule Problem23 do
    
    defp generateOutputRecursiveWithNAT(allStates, currNat, allNATSends) do

        # Run each computer until its halting points.
        runState = Enum.reduce(allStates, %{}, fn {index,state},acc ->
            result = IntComputer.run(state)
            Map.put(acc, index, result)
        end)

        # Gather all outputs.
        allOutputs = Enum.flat_map(runState, fn {_,state} ->
            state.output |> Enum.chunk_every(3)
        end)

        # Is there a NAT packet? Update. Use last.
        currNat = Enum.reduce(allOutputs, currNat, fn [index,x,y],acc ->
            if(index == 255) do
                [index,x,y]
            else
                acc
            end
        end)

        # Flush outputs.
        runState = Enum.reduce(runState, %{}, fn {index,state},acc ->
            Map.put(acc, index, state |> IntComputer.flushOutput())
        end)

        # Apply acquired inputs to remaining states.
        runState = Enum.reduce(allOutputs, runState, fn command,acc ->
            [index, x, y] = command

            if Map.has_key?(acc, index) do
                current = Map.get(acc, index)
                updated = IntComputer.addInput(current, [x, y])
                Map.put(acc, index, updated)
            else
                # invalid address, probably NAT packet.
                acc
            end
        end)

        # If all are idle, put nat packet into 0's input.
        { runState, allNATSends } = if length(allOutputs) == 0 and currNat != [] do
            [_, x, y] = currNat
            # Push into machine 0.
            updatedState = IntComputer.addInput(Map.get(runState, 0), [x, y])
            outInstructions = Map.put(runState, 0, updatedState)
            newSends = Enum.concat(allNATSends, [y])
            { outInstructions, newSends }
        else
            { runState, allNATSends}
        end

        # Add -1 for any empty input lists.
        runState = Enum.reduce(runState, %{}, fn {index,state},acc ->
            if length(state.input) == 0 do
                Map.put(acc, index, IntComputer.addInput(state, [-1]))
            else
                Map.put(acc, index, state)
            end
        end)

        # Last two nat sends match? Done.
        if allNATSends |> length() >= 2 and (allNATSends |> Enum.at(-1) == allNATSends |> Enum.at(-2)) do
            allNATSends
        else
            generateOutputRecursiveWithNAT(runState, currNat, allNATSends)
        end
    end

    def main() do
        numComputers = 50
        {:ok, body} = File.read("lib/input.txt")
        defaultInstructionState = IntComputer.generateProgram(body)

        # Generate initial program states with input for all 50 computers.
        allStates = Enum.reduce(0..numComputers - 1, %{}, fn index,acc->
            state = IntComputer.addInput(defaultInstructionState, [index])
            Map.put(acc, index, state)
        end)

        result = generateOutputRecursiveWithNAT(allStates, [], [])
        # Part 1. First element.
        IO.puts("Part1: #{result |> Enum.at(0)}")
        # Part 2. Last element.
        IO.puts("Part2: #{result |> Enum.at(-1)}")
    end
end
