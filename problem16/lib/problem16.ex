defmodule Problem16 do

    def generateListInput(number) do

        generateListInputRecursive(number)
        |> List.flatten()
        |> Enum.reverse()
    end

    def generateListInputRecursive(number) do
        value = rem(number, 10)
        next = div(number, 10)

        if next == 0 do
            [value]
        else
            Enum.concat([value], generateListInputRecursive(next))
        end
    end

    def convertListToNumber(list) do
        
        Enum.reduce(list, 0, fn value,acc ->
            acc * 10 + value
        end)
    end

    defp listToMap(list) do
        Stream.with_index(list, 0) |>
            Enum.reduce(%{}, fn({v, k}, acc) -> Map.put(acc, k, v) end)
    end

    def calcFFT(inputList, pattern) do

        patternLength = length(pattern)
        patternMap = listToMap(pattern)
        Enum.map(0..length(inputList) - 1, fn index ->
            Enum.reduce(inputList, {0, 0}, fn value, {accIndex, accSum} ->
                val2 = Map.get(patternMap, div(accIndex + 1, index + 1) |> rem(patternLength))
                {accIndex + 1, value * val2 + accSum}
            end)
            |> elem(1) |> abs() |> rem(10)
        end)
    end


    # Return a map of the subset sums.
    def generateSubsetSumMap(inputList) do
        
        Enum.reduce(inputList, {0, 0, %{-1 => 0}}, fn element, { index, currSum, subsetSumMap } ->
            newSum = element + currSum
            newMap = Map.put(subsetSumMap, index, newSum)
            newIndex = index + 1
            { newIndex, newSum, newMap }
        end) |> elem(2)
    end

    # Gets the sum of elements in the range.
    def getSumForRange(startIndex, endIndex, subsetSumMap) do

        subsetSumMap[endIndex] - subsetSumMap[startIndex - 1]
    end

    def getInterleaveSum(fftIndex, startIndex, subsetSumMap, totalLength) do

        period = (fftIndex + 1) * 4
        iterations = div(totalLength, period) + 1
        
        Enum.reduce(0..iterations - 1, 0, fn iterationIndex, sum ->
            startIndex = startIndex + period * iterationIndex
            endIndex = startIndex + fftIndex
            cond do
                startIndex >= totalLength ->
                    sum
                endIndex >= totalLength ->
                    sum + getSumForRange(startIndex, totalLength - 1, subsetSumMap)
                true ->
                    sum + getSumForRange(startIndex, endIndex, subsetSumMap)
            end
        end)
    end

    def getInterleaveSum(fftIndex, subsetSumMap, totalLength) do
        
        # Additions
        add = getInterleaveSum(fftIndex, fftIndex, subsetSumMap, totalLength)
        # Subtractions.
        subtract = getInterleaveSum(fftIndex, fftIndex + (fftIndex + 1) * 2, subsetSumMap, totalLength)
        (add - subtract) |> abs |> rem(10)
    end

    # faster fft calc assuming input pattern of [0,1,0,-1]
    def fasterFFT(inputList) do

        # First generate subset sum.
        subsetSumMap = generateSubsetSumMap(inputList)
        totalLength = length(inputList)
        Stream.map(0..length(inputList) - 1, fn index ->
            getInterleaveSum(index, subsetSumMap, totalLength)
        end) |> Enum.to_list()
    end

    # faster fft calc assuming input pattern of [0,1,0,-1]
    def calcNFasterFFTs(inputList, count) do
        IO.puts("CALCING: #{count}")
        if count == 0 do
            inputList
        else
            result = fasterFFT(inputList)
            calcNFasterFFTs(result, count - 1)
        end
    end

    def calcNFFTs(inputList, pattern, count) do
        if count == 0 do
            inputList
        else
            result = calcFFT(inputList, pattern)
            calcNFFTs(result, pattern, count - 1)
        end
    end

    def getMessage(inputList, messageOffset) do
        
        Enum.map(messageOffset..(messageOffset + 7), fn index ->
            Enum.at(inputList, index)
        end)
        |> convertListToNumber()
    end

    defp generateMassiveInput(input, count) do
        Enum.flat_map(1..count, fn _count ->
            input
        end)
    end

    def main() do
        {:ok, body} = File.read("lib/input.txt")
        input = body |> String.to_integer() |> generateListInput()

        # Part1.
        calcNFasterFFTs(input, 100) |> Enum.take(8) |> convertListToNumber() |> inspect |> IO.puts()
        # Part2.
        origInput = generateMassiveInput(input, 10000)
        offset = origInput |> Enum.take(7) |> convertListToNumber()
        origInput |> calcNFasterFFTs(100) |> getMessage(offset) |> inspect |> IO.puts()
    end
end
