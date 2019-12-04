defmodule Problem do

    # Parse path string for {x, y} offsets.
    defp parsePathString(path) do
        direction = String.slice(path, 0..0)
        count = String.slice(path, 1..-1) |> String.to_integer()
        
        cond do 
            direction == "R" ->
                { count, 0 }
            direction == "L" ->
                { -count, 0 }
            direction == "U" ->
                { 0, count }
            direction == "D" ->
                { 0, -count }
        end
    end

    # Generate a map of {x, y} coordinates.
    defp appendWireMap(offset, x, y, acc, start_distance) do
        { xoff, yoff } = offset
        distance = start_distance + abs(xoff) + abs(yoff)
        coord = { x + xoff, y + yoff }
        cond do
            xoff > 0 ->
                newOffset = {xoff - 1, 0}
                appendWireMap(newOffset, x, y, Map.put(acc, coord, distance), start_distance)
            xoff < 0 ->
                newOffset = {xoff + 1, 0}
                appendWireMap(newOffset, x, y, Map.put(acc, coord, distance), start_distance)
            yoff > 0 ->
                newOffset = {0, yoff - 1}
                appendWireMap(newOffset, x, y, Map.put(acc, coord, distance), start_distance)
            yoff < 0 ->
                newOffset = {0, yoff + 1}
                appendWireMap(newOffset, x, y, Map.put(acc, coord, distance), start_distance)
            true -> 
                acc
        end
    end

    defp generateWireMap(offset, state) do
        { xoff, yoff } = offset
        { x, y, acc, start_distance } = state
        final_distance = start_distance + abs(xoff) + abs(yoff)
        final_x = x + xoff
        final_y = y + yoff
        { final_x, final_y, appendWireMap(offset, x, y, acc, start_distance), final_distance }
    end

    # Returns a map with all the locations.
    defp parseWirePath(pathList) do
        {_, _, wireMap, _ } = Enum.map(pathList, &parsePathString/1) |>
            Enum.reduce({0, 0, %{}, 0}, &generateWireMap/2)
        wireMap
    end

    # Split the two wire lines into two string lists.
    defp parseInput(fileName) do
        {:ok, body} = File.read(fileName)
        String.split(body, "\r\n") |>
            Enum.map(fn x -> String.split(x, ",") end)
    end

    defp getManhattanDistance(coordTuple) do
        { xpos, ypos } = coordTuple
        abs(xpos) + abs(ypos)
    end

    defp getShortestManhattanIntersection(path1, path2) do

        Enum.filter(Map.keys(path1), fn key -> Map.has_key?(path2, key) end) |>
            Enum.map(&getManhattanDistance/1) |>
            Enum.min()
    end

    defp getShortestSignalDistance(path1, path2) do

        Enum.filter(Map.keys(path1), fn key -> Map.has_key?(path2, key) end) |>
            Enum.map(fn key -> path1[key] + path2[key] end) |>
            Enum.min()
    end


    def part1 do
        wireMaps = parseInput("input.txt") |>
            Enum.map(&parseWirePath/1)

        getShortestManhattanIntersection(Enum.at(wireMaps, 0), Enum.at(wireMaps, 1))
    end

    def part2 do
        wireMaps = parseInput("input.txt") |>
            Enum.map(&parseWirePath/1)

        getShortestSignalDistance(Enum.at(wireMaps, 0), Enum.at(wireMaps, 1))
    end

end

IO.puts(Problem.part1())
IO.puts(Problem.part2())
