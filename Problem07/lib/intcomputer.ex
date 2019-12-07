defmodule InstructionState do
    defstruct opcodeMap: %{}, pointer: 0, input: [], input_pointer: 0, output: [], status: :init
end

defmodule IntComputer do

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

    # Fetch ops and advance the instruction pointer.
    defp getOps(opCount, instructionState) do
        {
            # ops with [value, address]
            Stream.map(1..opCount,
                fn offset ->
                    [
                        value: getValueGivenParameterMode(instructionState.opcodeMap, instructionState.pointer, offset),
                        address: instructionState.opcodeMap[offset + instructionState.pointer]]
                end) |>
                Stream.with_index(1) |>
                Enum.reduce(%{}, fn({v, k}, acc) -> Map.put(acc, k, v) end),
            # pointer
            instructionState.pointer + opCount + 1
        }
    end

    # Run the IntComputer with the given state.
    def run(instructionState) do
    
        # command is the last 2 digits, so use remainder 100.
        command = rem(instructionState.opcodeMap[instructionState.pointer], 100)
        # IO.puts("Command: #{command}")
        cond do
            # put op1 + op2 into op3's location.
            command == 1 ->
                { ops, new_pointer } = getOps(3, instructionState)
                newMap = Map.put(instructionState.opcodeMap, ops[3][:address], ops[1][:value] + ops[2][:value])
                
                newState = %{instructionState |
                    opcodeMap: newMap,
                    pointer: new_pointer }

                run(newState)
            # put op1 * op2 into op3's location.
            command == 2 ->
                { ops, new_pointer } = getOps(3, instructionState)
                newMap = Map.put(instructionState.opcodeMap, ops[3][:address], ops[1][:value] * ops[2][:value])
                
                newState = %{instructionState | 
                    opcodeMap: newMap, 
                    pointer: new_pointer }

                run(newState)
            # Take a value from input and put it at the given address.
            command == 3 -> 
                if length(instructionState.input) > instructionState.input_pointer do
                    { ops, new_pointer } = getOps(1, instructionState)
                    inputVal = instructionState.input |> Enum.at(instructionState.input_pointer) 
                    newMap = Map.put(instructionState.opcodeMap, ops[1][:address], inputVal)

                    newState = %{instructionState |
                        opcodeMap: newMap,
                        pointer: new_pointer,
                        input_pointer: instructionState.input_pointer + 1 }

                    run(newState)
                else
                    # not enough input. Return halt status and wait.
                    %{instructionState | status: :wait}
                end
            # Put op1 into the output and pause.
            command == 4 ->
                { ops, new_pointer } = getOps(1, instructionState)

                newState = %{instructionState |
                    pointer: new_pointer,
                    output: Enum.concat(instructionState.output, [ops[1][:value]])}

                run(newState)
            # Jump if true, if op1 is true, jump to op2.
            command == 5 ->
                { ops, new_pointer } = getOps(2, instructionState)
                jump_pointer = cond do
                    ops[1][:value] != 0 ->
                        ops[2][:value]
                    true ->
                        new_pointer
                end

                newState = %{instructionState | pointer: jump_pointer}
                run(newState)

            # Jump if false, if op1 is false, jump to op2.
            command == 6 ->
                { ops, new_pointer } = getOps(2, instructionState)
                jump_pointer = cond do
                    ops[1][:value] == 0 ->
                        # set instruction pointer.
                        ops[2][:value]
                    true ->
                        new_pointer
                end

                newState = %{instructionState | pointer: jump_pointer}
                run(newState)
            # If op1 < op2, stores 1 in the position given by the third parameter. 
            command == 7 ->
                { ops, new_pointer } = getOps(3, instructionState)
                newValue = if ops[1][:value] < ops[2][:value], do: 1, else: 0
                newMap = Map.put(instructionState.opcodeMap, ops[3][:address], newValue)

                newState = %{instructionState | 
                    opcodeMap: newMap, 
                    pointer: new_pointer }
                run(newState)
            # If op1 == op2, stores 1 in the position given by the third parameter. 
            command == 8 ->
                { ops, new_pointer } = getOps(3, instructionState)
                newValue = if ops[1][:value] == ops[2][:value], do: 1, else: 0
                newMap = Map.put(instructionState.opcodeMap, ops[3][:address], newValue)

                newState = %{instructionState | 
                    opcodeMap: newMap, 
                    pointer: new_pointer }
                run(newState)
            # Done, return final output.
            command == 99 ->
                %{instructionState | status: :done}
        end
    end

    # Convert program text to an opcode map.
    defp parseProgram(program_text) do
        String.split(program_text, ",") |> 
            Enum.map(&(String.to_integer(&1))) |>
            listToMap
    end

    # Generate an InstructionState from program text.
    def generateProgram(program_text) do
        %InstructionState
        {
            opcodeMap: parseProgram(program_text)
        }
    end
end