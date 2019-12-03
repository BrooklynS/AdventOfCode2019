defmodule Problem01 do

    defp calcFuel(input) do
        fuel = div(input, 3) - 2
        cond do
            fuel < 0 ->
                0
            true ->
                fuel
        end
    end

    defp calcFuelRecursive(element) do
        # Calc fuel until it is reduced to 0.
        cond do
            element == 0 ->
                0
            true ->
                fuel = calcFuel(element)
                fuel + calcFuelRecursive(fuel)
        end
    end

    # Generate an integer list from string file input.
    defp parseInput(fileName) do
        {:ok, body} = File.read(fileName)
        String.split(body, "\r\n") |> 
            # Convert strings to integer.
            Enum.map(fn x -> String.to_integer(x) end)
    end

    defp part1 do
        parseInput("input.txt") |>
        Enum.map(fn x -> calcFuel(x) end) |>
        Enum.sum()
    end

    defp part2 do
        # Convert strings to integer.
        parseInput("input.txt") |>
        # Calculate the fuel recursively.
        Enum.map(fn x -> calcFuelRecursive(x) end) |>
        # Recursively sum items in the integer list.
        Enum.sum()
    end

    def main do
        IO.puts(part1())
        IO.puts(part2())
    end
end

Problem01.main()