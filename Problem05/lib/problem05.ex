defmodule Problem05 do

    defp listToMap(list) do
        Stream.with_index(list, 0) |>
            Enum.reduce(%{}, fn({v, k}, acc) -> Map.put(acc, k, v) end)
    end

    defp getValueGivenParameterMode(opcodeMap, startIndex, offset) do
        parameterModePower = Enum.map(1..offset, &(&1)) |>
            Enum.reduce(10, fn _x, acc -> acc * 10 end)
        parameterMode = div(opcodeMap[startIndex], parameterModePower) |> rem(10)
 
        cond do
            parameterMode == 0 ->
                opcodeMap[opcodeMap[startIndex + offset]]
            true ->
                opcodeMap[startIndex + offset]
        end
    end

    defp getOps(opCount, opcodeMap, currIndex) do
        {
            # ops with [value, address]
            Stream.map(1..opCount,
                fn offset ->
                    [
                        value: getValueGivenParameterMode(opcodeMap, currIndex, offset),
                        address: opcodeMap[offset + currIndex]]
                end) |>
                Stream.with_index(1) |>
                Enum.reduce(%{}, fn({v, k}, acc) -> Map.put(acc, k, v) end),
            # stackpointer
            currIndex + opCount + 1
        }
    end

    defp processInstructions(opcodeMap, currIndex, inputList, outputList) do
    
        # command is the last 2 digits, so use remainder 100.
        command = rem(opcodeMap[currIndex], 100)
        # IO.puts("Command: #{command}")
        cond do
            # put op1 + op2 into op3's location.
            command == 1 ->
                { ops, stackpointer } = getOps(3, opcodeMap, currIndex)
                newMap = Map.put(opcodeMap, ops[3][:address], ops[1][:value] + ops[2][:value])
                processInstructions(newMap, stackpointer, inputList, outputList)
            # put op1 * op2 into op3's location.
            command == 2 ->
                { ops, stackpointer } = getOps(3, opcodeMap, currIndex)
                newMap = Map.put(opcodeMap, ops[3][:address], ops[1][:value] * ops[2][:value])
                processInstructions(newMap, stackpointer, inputList, outputList)
            # Take a value from input and put it at the given address.
            command == 3 ->
                { ops, stackpointer } = getOps(1, opcodeMap, currIndex)
                # pop item from input, place it at op1 address
                [head | tail] = inputList
                newMap = Map.put(opcodeMap, ops[1][:address], head)
                processInstructions(newMap, stackpointer, tail, outputList)
            # Put op1 into the output.
            command == 4 ->
                { ops, stackpointer } = getOps(1, opcodeMap, currIndex)
                outputList = [ops[1][:value] | outputList]
                processInstructions(opcodeMap, stackpointer, inputList, outputList)
            # Jump if true, if op1 is true, jump to op2.
            command == 5 ->
                { ops, stackpointer } = getOps(2, opcodeMap, currIndex)
                cond do
                    ops[1][:value] != 0 ->
                        # set instruction pointer.
                        processInstructions(opcodeMap, ops[2][:value], inputList, outputList)
                    true ->
                        processInstructions(opcodeMap, stackpointer, inputList, outputList)
                end
            # Jump if false, if op1 is false, jump to op2.
            command == 6 ->
                { ops, stackpointer } = getOps(2, opcodeMap, currIndex)
                cond do
                    ops[1][:value] == 0 ->
                        # set instruction pointer.
                        processInstructions(opcodeMap, ops[2][:value], inputList, outputList)
                    true ->
                        processInstructions(opcodeMap, stackpointer, inputList, outputList)
                end
            # If op1 < op2, stores 1 in the position given by the third parameter. 
            command == 7 ->
                { ops, stackpointer } = getOps(3, opcodeMap, currIndex)
                newValue = if ops[1][:value] < ops[2][:value], do: 1, else: 0
                newMap = Map.put(opcodeMap, ops[3][:address], newValue)
                processInstructions(newMap, stackpointer, inputList, outputList)
            # If op1 == op2, stores 1 in the position given by the third parameter. 
            command == 8 ->
                { ops, stackpointer } = getOps(3, opcodeMap, currIndex)
                newValue = if ops[1][:value] == ops[2][:value], do: 1, else: 0
                newMap = Map.put(opcodeMap, ops[3][:address], newValue)
                processInstructions(newMap, stackpointer, inputList, outputList)
            command == 99 ->
                # Done, return final output.
                outputList
        end
    end

    def runSequence(command, input) do
        String.split(command, ",") |> 
            Enum.map(&(String.to_integer(&1))) |>
            listToMap |>
            processInstructions(0, input, [])
    end
end

input = "3,225,1,225,6,6,1100,1,238,225,104,0,1102,88,66,225,101,8,125,224,101,-88,224,224,4,224,1002,223,8,223,101,2,224,224,1,224,223,223,1101,87,23,225,1102,17,10,224,101,-170,224,224,4,224,102,8,223,223,101,3,224,224,1,223,224,223,1101,9,65,225,1101,57,74,225,1101,66,73,225,1101,22,37,224,101,-59,224,224,4,224,102,8,223,223,1001,224,1,224,1,223,224,223,1102,79,64,225,1001,130,82,224,101,-113,224,224,4,224,102,8,223,223,1001,224,7,224,1,223,224,223,1102,80,17,225,1101,32,31,225,1,65,40,224,1001,224,-32,224,4,224,102,8,223,223,1001,224,4,224,1,224,223,223,2,99,69,224,1001,224,-4503,224,4,224,102,8,223,223,101,6,224,224,1,223,224,223,1002,14,92,224,1001,224,-6072,224,4,224,102,8,223,223,101,5,224,224,1,223,224,223,102,33,74,224,1001,224,-2409,224,4,224,1002,223,8,223,101,7,224,224,1,223,224,223,4,223,99,0,0,0,677,0,0,0,0,0,0,0,0,0,0,0,1105,0,99999,1105,227,247,1105,1,99999,1005,227,99999,1005,0,256,1105,1,99999,1106,227,99999,1106,0,265,1105,1,99999,1006,0,99999,1006,227,274,1105,1,99999,1105,1,280,1105,1,99999,1,225,225,225,1101,294,0,0,105,1,0,1105,1,99999,1106,0,300,1105,1,99999,1,225,225,225,1101,314,0,0,106,0,0,1105,1,99999,107,677,677,224,1002,223,2,223,1006,224,329,101,1,223,223,108,677,677,224,1002,223,2,223,1005,224,344,101,1,223,223,1007,677,677,224,1002,223,2,223,1006,224,359,101,1,223,223,1107,226,677,224,1002,223,2,223,1006,224,374,1001,223,1,223,8,677,226,224,1002,223,2,223,1006,224,389,101,1,223,223,1108,677,677,224,1002,223,2,223,1005,224,404,1001,223,1,223,7,226,226,224,1002,223,2,223,1006,224,419,101,1,223,223,1107,677,677,224,1002,223,2,223,1005,224,434,101,1,223,223,107,226,226,224,102,2,223,223,1005,224,449,101,1,223,223,107,677,226,224,1002,223,2,223,1006,224,464,1001,223,1,223,8,226,677,224,102,2,223,223,1006,224,479,1001,223,1,223,108,677,226,224,102,2,223,223,1005,224,494,1001,223,1,223,1108,677,226,224,1002,223,2,223,1005,224,509,1001,223,1,223,1107,677,226,224,1002,223,2,223,1005,224,524,101,1,223,223,1008,226,226,224,1002,223,2,223,1006,224,539,101,1,223,223,1008,226,677,224,1002,223,2,223,1005,224,554,1001,223,1,223,7,226,677,224,1002,223,2,223,1005,224,569,101,1,223,223,1007,677,226,224,1002,223,2,223,1006,224,584,1001,223,1,223,7,677,226,224,102,2,223,223,1006,224,599,101,1,223,223,1007,226,226,224,102,2,223,223,1006,224,614,101,1,223,223,1008,677,677,224,1002,223,2,223,1006,224,629,101,1,223,223,108,226,226,224,102,2,223,223,1006,224,644,101,1,223,223,1108,226,677,224,1002,223,2,223,1005,224,659,101,1,223,223,8,226,226,224,1002,223,2,223,1005,224,674,101,1,223,223,4,223,99,226"
IO.puts("Part1:")
Problem05.runSequence(input, [1]) |> inspect |> IO.puts()
IO.puts("Part2:")
Problem05.runSequence(input, [5]) |> inspect |> IO.puts()

