defmodule Problem15 do

    defp getSubsequentLocation(direction, {x,y}) do
        cond do
            direction == 1 ->
                {x, y + 1}
            direction == 2 ->
                {x, y - 1}
            direction == 3 ->
                {x + 1, y}
            direction == 4 ->
                {x - 1, y}
        end
    end

    # Find the minimum steps to get to the O2 location. Also return the program state
    # that led to this location.
    def getMinSteps(programState, stepCount, visitedMap, {x, y}) do

        # Populate the map with the smallest known distance.
        visitedValue = min(stepCount, Map.get(visitedMap, {x, y}, stepCount))
        visitedMap = Map.put(visitedMap, {x, y}, visitedValue)

        if visitedValue < stepCount do
            # Already visited this location with a lower count, bail.
            {[ count: stepCount, state: programState, success: false], visitedMap}
        else
            # Reset output.
            programState = IntComputer.flushOutput(programState)

            # Go every direction.
            { result, acc } = Enum.map(1..4, &(&1))
            |> Enum.map_reduce(visitedMap, fn direction, acc ->

                # Simulate it.
                nextState = IntComputer.addInput(programState, [direction])
                |> IntComputer.run()

                [result] = nextState.output
                cond do
                    # Bumped the wall. Bad path, bail.
                    result == 0 ->
                        {[ count: stepCount, state: nextState, success: false], acc}
                    # Move was successful. Recurse.
                    result == 1 ->
                        nextDir = getSubsequentLocation(direction, {x,y})
                        getMinSteps(nextState, stepCount + 1, acc, nextDir)
                    # Found the thing.
                    result == 2 ->
                        {[ count: stepCount, state: nextState, success: true], acc}
                end
            end)
            
            # Sort by success, then step count.
            best = Enum.sort(result, fn a, b ->
                cond do
                    a[:success] and b[:success] ->
                        a[:count] < b[:count]
                    a[:success] and not b[:success] ->
                        true
                    not a[:success] and b[:success] ->
                        false
                    true ->
                        a[:count] < b[:count]
                end
            end)
            |> Enum.at(0)

            { best, acc }
        end
    end

    # Find the maximum distance
    def generateFloodFillCounts(programState, stepCount, visitedMap, {x,y}) do

        # Populate the map with the smallest known distance.
        stepValue = min(stepCount, Map.get(visitedMap, {x, y}, stepCount))
        visitedMap = Map.put(visitedMap, {x, y}, stepValue)

        if stepValue < stepCount do
            # Already visited here with a smaller distance.
            visitedMap
        else
            # Reset output.
            programState = IntComputer.flushOutput(programState)

            # Go every direction, don't care about repeating the one we came from.
            Enum.map(1..4, &(&1))
            |> Enum.reduce(visitedMap, fn direction,acc ->

                # Simulate next direction.
                nextState = IntComputer.addInput(programState, [direction])
                |> IntComputer.run()

                [result] = nextState.output
                cond do
                    # Bumped the wall. This path is no good.
                    result == 0 ->
                        acc
                    # Move was successful. Recurse.
                    result == 1 or result == 2 ->
                        nextLocation = getSubsequentLocation(direction, {x,y})
                        generateFloodFillCounts(nextState, stepCount + 1, acc, nextLocation)
                end
            end)
        end
    end

    def main() do
        {:ok, body} = File.read("lib/input.txt")
        baseProgram = IntComputer.generateProgram(body)
        # Part 1.
        { result, _visited } = getMinSteps(baseProgram, 1, %{}, {0,0})
        IO.puts("MinSteps: #{result[:count]}")

        # Part 2. Resume program at O2 location and flood out.
        generateFloodFillCounts(result[:state], 0, %{}, {0,0})
        |> Map.values()
        |> Enum.max()
        |> inspect
        |> IO.puts()
    end
end

