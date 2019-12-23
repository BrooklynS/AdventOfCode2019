defmodule Problem22 do

    # Solve ax congruent to b mod m
    # https://www.johndcook.com/blog/2008/12/10/solving-linear-congruences/
    # In the problem's case, a and m are guaranteed to be relatively prime
    # or the increment shuffle won't work. So here we only care about 1st solution
    # and assume inputs will always pass.
    def solveLinearCongruence(a, b, mod) do
        
        cond do
            b == 0 ->
                0
            a == 1 ->
                b 
            true ->
                a = if a < 0 do
                        a + mod
                    else
                        a
                    end

                b = if b > 0 do
                        b - mod
                    else
                        b
                    end
                newA = rem(mod, a)
                newB = rem(-b, a) + a

                y = solveLinearCongruence(newA, newB, a)
                div((mod * y + b), a) + mod |> rem(mod)
        end
    end

    def generateInputFromFile(filepath) do
        {:ok, body} = File.read(filepath)
        String.split(body, ["\n", "\r"]) |> Enum.filter(fn n -> n != "" end)
    end

    def runList(input, count) do
        list = Enum.map(0..count - 1, &(&1))
        inputLength = length(list)

        Enum.reduce(input, list, fn split,acc ->
            incrementMatch = Regex.run(~r/deal with increment ([-,]*\d+)/, split)
            cutMatch = Regex.run(~r/cut ([-,]*\d+)/, split)
            dealNewMatch = Regex.run(~r/deal into new stack/, split)
            cond do
                incrementMatch != nil ->
                    increment = incrementMatch |> Enum.at(1) |> String.to_integer()
                    # To find next index, solve linear congruence to determine prev index.
                    # increment * prevIndex = nextIndex mod length
                    {_, output} = Enum.reduce(acc, {0,[]}, fn _,{curIndex,output} ->

                        prevIndex = solveLinearCongruence(increment, curIndex, inputLength)
                        { 
                            curIndex + 1,
                            Enum.concat(output, [Enum.at(acc, prevIndex)])
                        }
                    end)
                    output
                cutMatch ->
                    cut = cutMatch |> Enum.at(1) |> String.to_integer()
                    {head, tail}= Enum.split(acc, cut)
                    output = Enum.concat(tail, head)
                    output
                  dealNewMatch ->
                    result = acc |> Enum.reverse()
                    result
                true ->
                    acc
            end
        end)
    end
  
    # Run it backwards until we find the period.
    # Assumes input has already been reversed.
    def runItBackwardsGetOrigIndex(input, count, finalIndex) do

        Enum.reduce(input, finalIndex, fn split,acc ->
            incrementMatch = Regex.run(~r/deal with increment ([-,]*\d+)/, split)
            cutMatch = Regex.run(~r/cut ([-,]*\d+)/, split)
            dealNewMatch = Regex.run(~r/deal into new stack/, split)
            cond do
                incrementMatch ->
                    increment = incrementMatch |> Enum.at(1) |> String.to_integer()
                    if(acc == 0) do
                        0
                    else
                        solveLinearCongruence(increment, acc, count)
                    end
                cutMatch ->
                    cut = cutMatch |> Enum.at(1) |> String.to_integer()
                    # Cutting is just shifting mod count. Reverse shift to undo.
                    # Adding count to avoid negative from negative cuts.
                    rem(acc + cut + count, count)
                  dealNewMatch ->
                    # Reverse.
                    (count - 1 - acc)
                true ->
                    acc
            end
        end)
    end

    defp firstIndexOf(list, element) do
        Enum.reduce(list, {-1,0}, fn item,{itemIndex,curIndex} ->

            if itemIndex == -1 do
                if(item == element) do
                    {curIndex,curIndex}
                else
                    { -1, curIndex + 1}
                end
            else
                {itemIndex,curIndex}
            end
        end)
    end

    # modulo power calc
    # see https://awochna.com/2017/04/02/elixir-math.html
    defp moduloPower(a, n, mod) do
        :binary.decode_unsigned(:crypto.mod_pow(a, n, mod))
    end

    # Solve modulo inverse.
    def modInvert(b, mod) do
        solveLinearCongruence(b, 1, mod)
    end

    # Find the coefficients for ax + b mod m
    defp findCoefficients(input, count, reverse) do
        # Run some iterations, see if we can find a pattern.
        result = Enum.reduce(0..100, {0,[]}, fn _,{acc,finalMap} ->
            result = runItBackwardsGetOrigIndex(input, count, acc)
            {result, Enum.concat(finalMap, [result])}
        end) |> elem(1)

        result = if reverse do
            result |> Enum.reverse()
        else
            result
        end

        #result |> inspect |> IO.puts()
        # Solve for Ax + b = C mod m. If we've done the math right, these terms should all be the same.
        factors = Enum.map(2..20, fn index ->
            x2 = Enum.at(result, index)
            x1 = Enum.at(result, index - 1)
            x0 = Enum.at(result, index - 2)
            solveLinearCongruence(x1 - x0, x2 - x1, count)
        end)
        #factors |> inspect |> IO.puts()
        a = Enum.at(factors, 0)

        distances = Enum.map(0..18, fn index ->
            rem(a * Enum.at(result, index) - Enum.at(result, index + 1), count)
        end)
        b = count - Enum.at(distances, 0)

        IO.puts("A: #{a}") 
        IO.puts("B: #{b}")
        # Test to make sure our equation is correct.
        #Enum.map(2..20, fn index ->
        #    IO.puts("Testing: #{rem(a * Enum.at(result, index - 1) + b, count)} #{Enum.at(result, index)}")
        #end)
        { a, b }
    end

    defp findNthTerm(a, b, k, mod, startValue) do
        # So now we basically have a linear congruential random number generator.
        # Nth term can be computed directly.
        # https://math.stackexchange.com/questions/2115756/linear-congruential-generator-for-nkth-can-also-be-computed-with-nth-term
        # x_k = a^k * x_0 + (a ^ k - 1) * b / (a - 1)   mod(p)
        a_power_k = moduloPower(a, k, mod)
        secondTerm = (a_power_k - 1) * b |> rem(mod)
        inverse = modInvert(a - 1, mod)
        (a_power_k * startValue + secondTerm * inverse) |> rem(mod)
    end

    def main() do
        {:ok, body} = File.read("lib/input.txt")
        input = String.split(body, "\r\n")
        
        # Part 1 Original.
        # output = runList(input, 10007)
        # index = firstIndexOf(output, 2019) |> elem(0) |> inspect |> IO.puts()
        # Enum.at(output, index) |> inspect |> IO.puts()
        reverseInput = input |> Enum.reverse()

        # Part2.
        cards    = 119315717514047
        shuffles = 101741582076661
        target = 2020
        { a, b } = findCoefficients(reverseInput, cards, false) 
        result = findNthTerm(a, b, shuffles, cards, target)
        IO.puts("Part2: #{result}")

        # Part1 optimized.
        part1cards = 10007
        part1shuffles = 1
        part1target = 2019
        # Re-reverse the input. Part2 was about working backwards.
        { a, b } = findCoefficients(reverseInput, part1cards, true)
        result = findNthTerm(a, b, part1shuffles, part1cards, part1target)
        IO.puts("Part1: #{result}")
    end

end
