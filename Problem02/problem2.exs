defmodule Problem02 do

    defp listToMap(list) do
        Stream.with_index(list, 0) |>
            Enum.reduce(%{}, fn({v, k}, acc) -> Map.put(acc, k, v) end)
    end

    defp processStateMachine(opcodeMap, startIndex) do
        command = opcodeMap[startIndex]
        
        cond do
            # Add 1 and 2, puting into 3's location.
            command == 1 ->
                op1 = opcodeMap[opcodeMap[startIndex + 1]]
                op2 = opcodeMap[opcodeMap[startIndex + 2]]
                position = opcodeMap[startIndex + 3]
                newMap = Map.put(opcodeMap, position, op1 + op2)
                processStateMachine(newMap, startIndex + 4)
            # Multiply elements at positions 1 and 2, puting into 3's location.
            command == 2 ->
                op1 = opcodeMap[opcodeMap[startIndex + 1]]
                op2 = opcodeMap[opcodeMap[startIndex + 2]]
                position = opcodeMap[startIndex + 3]
                newMap = Map.put(opcodeMap, position, op1 * op2)
                processStateMachine(newMap, startIndex + 4)
            command == 99 ->
                opcodeMap
        end
    end

    defp getMatch(orig_input, target, noun, verb) do
        
        newValue = orig_input |> 
            Map.put(1, noun) |>
            Map.put(2, verb) |>
            processStateMachine(0) |>
            Map.get(0)

        cond do
            newValue != target ->
                # worship the god of random.
                getMatch(orig_input,
                    target,
                    Enum.random(0..map_size(orig_input) - 1),
                    Enum.random(0..map_size(orig_input) - 1))
            true ->
                ({ noun, verb })
        end
    end

    # Generate an integer list from string file input.
    defp parseInput(fileName) do
        {:ok, body} = File.read(fileName)
        String.split(body, ",") |> 
            # Convert strings to integer.
            Enum.map(fn x -> String.to_integer(x) end) |>
            listToMap
    end

    defp part1 do
        parseInput("input.txt") |>
            # Replace position 1 with value 12.
            Map.put(1, 12) |>
            # Replace position 2 with value 2.
            Map.put(2, 2) |>
            # Run through the state machine.
            processStateMachine(0) |>
            #Return value at position 0.
            Map.get(0)
    end

    defp part2 do
        desired_output = 19690720
        orig_input = parseInput("input.txt")
        { noun, verb } = getMatch(orig_input, desired_output, 0, 0)
        noun * 100 + verb
    end

    def main do
        IO.puts(part1())
        IO.puts(part2())
    end
end

Problem02.main()