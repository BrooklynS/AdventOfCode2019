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
        Enum.map(0..length(digits) - 2, fn x -> [first: x, second: x + 1] end) |>
            Enum.filter(fn pair -> Enum.fetch(digits, pair[:first]) == Enum.fetch(digits, pair[:second]) end) |>
            length() > 0
    end

    # Since digits never can decrease, hasTwoOfSame will detect if exactly two digits are adjacent.
    defp hasTwoOfSame(number) do
        digits = getDigitList(number, [])
        Enum.map(0..9, fn x -> getDigitCount(x, digits, 0, 0) end) |>
            Enum.filter(fn x -> x == 2 end) |>
            length() > 0
    end

    defp getDigitCount(targetValue, digits, currentCount, currIndex) do
        cond do
            currIndex < length(digits) ->
                cond do
                    Enum.fetch!(digits, currIndex) == targetValue ->
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
        Enum.map(0..length(digits) - 2, fn x -> [first: x, second: x + 1] end) |>
            Enum.filter(fn pair -> Enum.fetch(digits, pair[:first]) > Enum.fetch(digits, pair[:second]) end) |>
            length() == 0
    end

    def part1 do
        Enum.map(265275..781584, fn x -> x end) |>
            Enum.filter(&hasTwoAdjacentDigits/1) |>
            Enum.filter(&digitsNeverDecrease/1) |>
            length()
    end

    def part2 do
        Enum.map(265275..781584, fn x -> x end) |>
            Enum.filter(&digitsNeverDecrease/1) |>
            Enum.filter(&hasTwoOfSame/1) |>
            length()
    end
end

IO.puts(Problem.part1())
IO.puts(Problem.part2())
