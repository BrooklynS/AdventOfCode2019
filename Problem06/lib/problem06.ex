defmodule Problem06 do

    defp getOrbitCounts([], orbit_counts) do
        orbit_counts
    end
    
    defp getOrbitCounts(list, orbit_counts) do
        rightKeys = Enum.reduce(list, %{}, fn x,acc ->
            Map.put(acc, Enum.at(x, 1), Map.get(acc, Enum.at(x, 1), 0) + 1)
        end) |> Map.keys() |> MapSet.new()

        leftKeys = Enum.reduce(list, %{}, fn x,acc ->
            Map.put(acc, Enum.at(x, 0), Map.get(acc, Enum.at(x, 0), 0) + 1)
        end) |> Map.keys() |> MapSet.new()

        rootNodes = MapSet.difference(leftKeys, rightKeys)
        { popElements, list } = Enum.split_with(list, fn [left, _right] ->
                Enum.any?(rootNodes, fn rootNode -> rootNode == left end)
                end)
        
        orbit_counts = Enum.reduce(popElements, orbit_counts, fn [left, right], acc ->
           Map.put(acc, right, Map.get(acc, left, 0) + 1)
            end)
    
        getOrbitCounts(list, orbit_counts)
    end

    defp getNextNode(list, currNode) do
        Enum.filter(list, fn [_, right] -> right == currNode end) |> Enum.at(0) |> Enum.at(0)
    end

    defp getSantaDistance(list, orbit_counts, san_node, you_node, dist) do
        cond do
            san_node == you_node ->
                dist
            orbit_counts[you_node] < orbit_counts[san_node] ->
                # advance san
                getSantaDistance(list, orbit_counts, getNextNode(list, san_node), you_node, dist + 1)
            true ->
                # advance you
                getSantaDistance(list, orbit_counts, san_node, getNextNode(list, you_node), dist + 1)
        end
    end

    def getOrbitCount(fileName) do
        {:ok, body} = File.read(fileName)
        String.split(body, "\r\n") |>
            Enum.map(fn x -> String.split(x, ")") end) |>
            getOrbitCounts(%{}) |>
            Enum.reduce(0, fn {_k, v}, acc -> v + acc end)
    end

    def getSantaDistance(fileName) do
        {:ok, body} = File.read(fileName)
        orbit_list = String.split(body, "\r\n") |>
            Enum.map(fn x -> String.split(x, ")") end) 
        orbit_counts = getOrbitCounts(orbit_list, %{})

        san_node = Enum.filter(orbit_list, fn [_, right] -> right == "SAN" end) |> Enum.at(0) |> Enum.at(0)
        you_node = Enum.filter(orbit_list, fn [_, right] -> right == "YOU" end) |> Enum.at(0) |> Enum.at(0)
        getSantaDistance(orbit_list, orbit_counts, san_node, you_node, 0)
    end
end

Problem06.getOrbitCount("lib/input.txt") |> inspect |> IO.puts()
Problem06.getSantaDistance("lib/input.txt") |> inspect |> IO.puts()

