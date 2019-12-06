defmodule Problem do

    defp getDigitList(x, acc) do
        cond do
            x > 0 ->
                acc = [rem(x, 10) | acc]
                getDigitList(div(x, 10), acc)
            true ->
                acc
        end
    end
    
    defp hasTwoAdjacentDigits(x) do
        digits = getDigitList(x, [])
        Stream.map(0..length(digits) - 2, &([first: &1, second: &1 + 1])) |>
            Stream.filter(fn pair -> Enum.at(digits, pair[:first]) == Enum.at(digits, pair[:second]) end) |>
            Enum.to_list() |>
            length() > 0
    end

    # Since digits never can decrease, hasTwoOfSame will detect if exactly two digits are adjacent.
    defp hasTwoOfSame(number) do
        digits = getDigitList(number, [])
        Stream.map(0..9, &getDigitCount(&1, digits, 0, 0)) |>
            Stream.filter(&(&1 == 2)) |>
            Enum.to_list() |>
            length() > 0
    end

    defp getDigitCount(targetValue, digits, currentCount, currIndex) do
        cond do
            currIndex < length(digits) ->
                cond do
                    Enum.at(digits, currIndex) == targetValue ->
                        getDigitCount(targetValue, digits, currentCount + 1, currIndex + 1)
                    true ->
                        getDigitCount(targetValue, digits, currentCount, currIndex + 1)
                end
            true ->
                currentCount
        end
    end

    defp digitsNeverDecrease(x) do
        digits = getDigitList(x, [])
        Stream.map(0..length(digits) - 2, &([first: &1, second: &1 + 1])) |>
            Stream.filter(&(Enum.at(digits, &1[:first]) > Enum.at(digits, &1[:second]))) |>
            Enum.to_list() |>
            length() == 0
    end

    def part1 do
        Stream.map(265275..781584, &(&1)) |>
            Stream.filter(&hasTwoAdjacentDigits/1) |>
            Stream.filter(&digitsNeverDecrease/1) |>
            Enum.to_list() |>
            length()
    end

    def part2 do
        Stream.map(265275..781584, &(&1)) |>
            Stream.filter(&digitsNeverDecrease/1) |>
            Stream.filter(&hasTwoOfSame/1) |>
            Enum.to_list() |>
            length()
    end
end

IO.puts(Problem.part1())
IO.puts(Problem.part2())
