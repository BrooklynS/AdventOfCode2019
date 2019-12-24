defmodule Problem24 do

    # Calculate the Biodiversity score for the given map.
    # Iterate by row index first, then by column indexes.
    # If a bug is present, add 2^(index) to the score.
    # Index starts at 0.
    def getBiodiversityScore(map, squareSize) do

        Enum.reduce(0..squareSize*squareSize, {1,0}, fn index,{power,score} ->
            x = rem(index, squareSize)
            y = div(index, squareSize)
            value = Map.get(map, y, %{}) |> Map.get(x, false)
            addAmount = if value == true do
                power
            else
                0
            end

            {power * 2, score + addAmount}
        end) |> elem(1)
    end

    # Find the number of adjacent bugs to a square.
    defp getAdjacentBugCount(map, y, x) do

        locations = [[y: y + 1, x: x], [y: y - 1, x: x], [y: y, x: x + 1], [y: y, x: x - 1]]
        Enum.reduce(locations, 0, fn location,acc ->
            if Map.get(map, location[:y], %{}) |> Map.get(location[:x], false) do
                acc + 1
            else
                acc
            end
        end)
    end

    # Simulate all the bugs on the map and return a map with the new state.
    defp simulateBugs(map, squareSize) do
        
        Enum.reduce(0..squareSize*squareSize - 1, %{}, fn index,acc ->
            x = rem(index, squareSize)
            y = div(index, squareSize)
            isBug = map[y][x]
            adjBugCount = getAdjacentBugCount(map, y, x)

            newValue = cond do
                # A bug dies (becoming an empty space) unless there is exactly one bug adjacent to it.
                (isBug == true) and (adjBugCount != 1) ->
                    false
                # An empty space becomes infested with a bug if exactly one or two bugs are adjacent to it.
                (isBug == false) and (adjBugCount == 1 or adjBugCount == 2) ->
                    true
                # Nothing happens.
                true ->
                    isBug
            end

            existing = Map.get(acc, y, %{})
            newXMap = Map.put(existing, x, newValue)
            Map.put(acc, y, newXMap)
        end)
    end

    # gets an element from the nested map at z, y, x.
    # return false if out of bounds.
    defp getFromNestedMap(nestedMap, z, y, x) do
        nestedMap |> Map.get(z, %{}) |> Map.get(y, %{}) |> Map.get(x, false)
    end

    # Fetch the bug count from a square.
    defp getBugCountFromSquare(nestedMap, z, y, x) do
        if getFromNestedMap(nestedMap, z, y, x) == true do
            1
        else
            0
        end
    end

    # Gets the bug count using the recursive nested map scheme.
    defp getAdjacentBugCountDepth(nestedMap, z, y, x, squareSize) do

        midpoint = div(squareSize, 2)
        locations = [[y: y + 1, x: x], [y: y - 1, x: x], [y: y, x: x + 1], [y: y, x: x - 1]]
        Enum.reduce(locations, 0, fn location,acc ->
            targetx = location[:x]
            targety = location[:y]

            addAmount = cond do
                # Get square above midpoint at higher depth.
                targety < 0 ->
                    getBugCountFromSquare(nestedMap, z - 1, midpoint - 1, midpoint)
                # Get square below midpoint at higher depth.
                targety >= squareSize ->
                    getBugCountFromSquare(nestedMap, z - 1, midpoint + 1, midpoint)
                # Get square to the left of midpoint in higher depth.
                targetx < 0 ->
                    getBugCountFromSquare(nestedMap, z - 1, midpoint, midpoint - 1)
                # Get square to the right of midpoint in higher depth.
                targetx >= squareSize ->
                    getBugCountFromSquare(nestedMap, z - 1, midpoint, midpoint + 1)
                # Going into a midpoint, need to determine from which direction we started.
                targetx == midpoint and targety == midpoint ->
                    cond do
                        # Use entire right side of lower depth.
                        x > midpoint ->
                            Enum.reduce(0..squareSize - 1, 0, fn y,acc ->
                                acc + getBugCountFromSquare(nestedMap, z + 1, y, squareSize - 1)
                            end)
                        # Use entire left side of lower depth.
                        x < midpoint ->
                            Enum.reduce(0..squareSize - 1, 0, fn y,acc ->
                                acc + getBugCountFromSquare(nestedMap, z + 1, y, 0)
                            end)
                        # Use entire bottom side of lower depth.
                        y > midpoint ->
                            Enum.reduce(0..squareSize - 1, 0, fn x,acc ->
                                acc + getBugCountFromSquare(nestedMap, z + 1, squareSize - 1, x)
                            end)
                        # Use entire top side of lower depth.
                        y < midpoint ->
                            Enum.reduce(0..squareSize - 1, 0, fn x,acc ->
                                acc + getBugCountFromSquare(nestedMap, z + 1, 0, x)
                            end)
                    end
                # Boring square. Just get its count.
                true ->
                    getBugCountFromSquare(nestedMap, z, targety, targetx)
            end

            acc + addAmount
        end)
    end

    # Simulate all the bugs across the depth map and return a map with the updated state.
    defp simulateBugsWithDepth(nestedMap, squareSize) do
        
        midpoint = div(squareSize, 2)

        Enum.reduce(nestedMap, %{}, fn {depth,_yMap},outMap ->
            newYMap = Enum.reduce(0..squareSize*squareSize - 1, %{}, fn index,acc ->
                x = rem(index, squareSize)
                y = div(index, squareSize)
                isBug = nestedMap[depth][y][x]
                adjBugCount = getAdjacentBugCountDepth(nestedMap, depth, y, x, squareSize)
                # IO.puts("GET ADJACENT: z: #{depth} y: #{y} x: #{x} isBug:#{isBug} Count: #{adjBugCount}")
                newValue = cond do
                    # There can never be a bug in the middle square.
                    # Always return false.
                    x == midpoint and y == midpoint ->
                        false
                    # A bug dies (becoming an empty space) unless there is exactly one bug adjacent to it.
                    (isBug == true) and (adjBugCount != 1) ->
                        false
                    # An empty space becomes infested with a bug if exactly one or two bugs are adjacent to it.
                    (isBug == false) and (adjBugCount == 1 or adjBugCount == 2) ->
                        true
                    # Nothing happens. Keep the same.
                    true ->
                        isBug
                end

                existing = Map.get(acc, y, %{})
                newXMap = Map.put(existing, x, newValue)
                Map.put(acc, y, newXMap)
            end)
            Map.put(outMap, depth, newYMap)
        end)
    end

    # Count all the bugs in a z,y,x map. Midpoint is guaranteed to be false by other functions.
    def getTotalBugCount(nestedMap) do
        Enum.reduce(nestedMap, 0, fn {_, yMap},accSum ->
            accSum + Enum.reduce(yMap, 0, fn {_,xMap},ySum ->
                ySum + Enum.reduce(xMap, 0, fn {_,value},xSum ->
                    if value do
                        xSum + 1
                    else
                        xSum
                    end
                end)
            end)
        end)
    end

    # Create an empty map with no bugs.
    defp generateEmptyMap(squareSize) do
        Enum.reduce(0..squareSize - 1, %{}, fn y,yacc->
            xmap = Enum.reduce(0..squareSize - 1, %{}, fn x,xacc->
                Map.put(xacc, x, false)
            end)
            Map.put(yacc, y, xmap)
        end)
    end

    # Append maps to each end of the depth.
    # This is lazy because it always adds a map, even if needed, so
    # computation time grows more than it should.
    defp generateExtraMaps(nestedMap, squareSize) do
        maxDepth = Map.keys(nestedMap) |> Enum.max()
        minDepth = Map.keys(nestedMap) |> Enum.min()

        Map.put(nestedMap, maxDepth + 1, generateEmptyMap(squareSize)) |>
        Map.put(minDepth - 1, generateEmptyMap(squareSize))
    end

    # Draw the map.
    defp drawNestedMap(nestedMap, squareSize) do

        Enum.map(nestedMap, fn {_,yMap} ->
            Enum.map(0..squareSize - 1, fn y ->
                Enum.reduce(0..squareSize - 1, "", fn index,string->
                    char = if yMap[y][index] do
                        "#"
                    else
                        "."
                    end
                    string <> char
                end)  <> "\n\r" |> IO.puts()
            end)
            IO.puts("")
        end)
    end

    # Simulate the bugs numSimulations times with the list of maps keyed by depth.
    defp simulateBugsNTimesWithDepth(nestedMap, squareSize, numSimulations) do

        if numSimulations == 0 do
            # drawNestedMap(nestedMap, squareSize)
            getTotalBugCount(nestedMap)
        else
            # Add to the bottom depth if needed, then simulate.
            newMap = generateExtraMaps(nestedMap, squareSize)
            |> simulateBugsWithDepth(squareSize)

            simulateBugsNTimesWithDepth(newMap, squareSize, numSimulations - 1)
        end
    end

    # Simualate the bugs until a duplicate score occurs.
    defp simulateBugsRecursive(map, squareSize, scores) do

        newMap = simulateBugs(map, squareSize)
        newScore = getBiodiversityScore(newMap, squareSize)
        if Enum.any?(scores, fn score -> score == newScore end) do
            newScore
        else
            simulateBugsRecursive(newMap, squareSize, [newScore | scores])
        end
    end

    def main() do
        {:ok, body} = File.read("lib/input.txt")
        input = String.split(body, "\r\n")
        |> Enum.map(fn string -> String.graphemes(string) end)

        squareSize = length(input)
        # Create a lookup map of [y][x] = true if bug is present.
        map = Enum.reduce(0..squareSize - 1, %{}, fn y,yacc->
            xmap = Enum.reduce(0..squareSize - 1, %{}, fn x,xacc->
                character = Enum.at(input, y) |> Enum.at(x)
                isBug = (character == "#")
                Map.put(xacc, x, isBug)
            end)
            Map.put(yacc, y, xmap)
        end)

        # Part1. Find first duplicate score.
        result = simulateBugsRecursive(map, squareSize, [])
        IO.puts("Part1: #{result |> inspect}")

        # Part2.
        # Place this map at depth (z) of 0.
        nestedMap = Map.put(%{}, 0, map)
        result = simulateBugsNTimesWithDepth(nestedMap, squareSize, 200)
        IO.puts("Part2: #{result |> inspect}")
    end
end
