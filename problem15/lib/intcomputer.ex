defmodule InstructionState do
    defstruct opcodeMap: %{}, pointer: 0, input: [], input_pointer: 0, output: [], status: :init, relative_base: 0
end

defmodule IntComputer do

    defp listToMap(list) do
        Stream.with_index(list, 0) |>
            Enum.reduce(%{}, fn({v, k}, acc) -> Map.put(acc, k, v) end)
    end

    defp getParameterMode(instructionState, offset) do
        
        startIndex = instructionState.pointer
        opcodeMap = instructionState.opcodeMap

        power = Enum.map(1..offset, &(&1)) |>
            Enum.reduce(10, fn _x, acc -> acc * 10 end)

        div(opcodeMap[startIndex], power) |> rem(10)
    end

    defp getValueGivenParameterMode(instructionState, offset, parameterMode) do
        
        startIndex = instructionState.pointer
        opcodeMap = instructionState.opcodeMap
        cond do
            # Position Mode
            parameterMode == 0 ->
                Map.get(opcodeMap, opcodeMap[startIndex + offset], 0)
            # Immediate Mode
            parameterMode == 1 ->
                Map.get(opcodeMap, startIndex + offset, 0)
            # Relative Position Mode
            parameterMode == 2 ->
                Map.get(opcodeMap, opcodeMap[startIndex + offset] + instructionState.relative_base, 0)
        end
    end

    defp getWriteValueGivenParameterMode(instructionState, offset, parameterMode) do
        
        startIndex = instructionState.pointer
        opcodeMap = instructionState.opcodeMap
        cond do
            # Position Mode
            parameterMode == 0 ->
                opcodeMap[startIndex + offset]
            # Immediate Mode
            parameterMode == 1 ->
                -99999999
            # Relative Position Mode
            parameterMode == 2 ->
                opcodeMap[startIndex + offset] + instructionState.relative_base
        end
    end

    # Fetch ops and advance the instruction pointer.
    defp getOps(opCount, instructionState) do
        ops = {
            # ops with [value, address]
            Stream.map(1..opCount,
                fn offset ->
                    paramMode = getParameterMode(instructionState, offset)
                    [
                        value: getValueGivenParameterMode(instructionState, offset, paramMode),
                        raw: instructionState.opcodeMap[offset + instructionState.pointer],
                        write_address: getWriteValueGivenParameterMode(instructionState, offset, paramMode),
                        paramMode: paramMode
                    ]
                end) |>
                Stream.with_index(1) |>
                Enum.reduce(%{}, fn({v, k}, acc) -> Map.put(acc, k, v) end),
            # pointer
            instructionState.pointer + opCount + 1
        }
        ops
    end

    # Run the IntComputer with the given state.
    def run(instructionState) do

        # command is the last 2 digits, so use remainder 100.
        command = rem(instructionState.opcodeMap[instructionState.pointer], 100)
        cond do
            # put op1 + op2 into op3's location.
            command == 1 ->
                { ops, new_pointer } = getOps(3, instructionState)
                newMap = Map.put(instructionState.opcodeMap, ops[3][:write_address], ops[1][:value] + ops[2][:value])
                
                newState = %{instructionState |
                    opcodeMap: newMap,
                    pointer: new_pointer }

                run(newState)
            # put op1 * op2 into op3's location.
            command == 2 ->
                { ops, new_pointer } = getOps(3, instructionState)
                newMap = Map.put(instructionState.opcodeMap, ops[3][:write_address], ops[1][:value] * ops[2][:value])
                
                newState = %{instructionState | 
                    opcodeMap: newMap, 
                    pointer: new_pointer }

                run(newState)
            # Take a value from input and put it at the given address.
            command == 3 -> 
                if length(instructionState.input) > instructionState.input_pointer do
                    { ops, new_pointer } = getOps(1, instructionState)
                    inputVal = instructionState.input |> Enum.at(instructionState.input_pointer)
                    newMap = Map.put(instructionState.opcodeMap, ops[1][:write_address], inputVal)

                    newState = %{instructionState |
                        opcodeMap: newMap,
                        pointer: new_pointer,
                        input_pointer: instructionState.input_pointer + 1 }

                    run(newState)
                else
                    # not enough input. Return halt status and wait.
                    # input can be cleared at this time.
                    %{instructionState | status: :wait, input_pointer: 0, input: []}
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
                newMap = Map.put(instructionState.opcodeMap, ops[3][:write_address], newValue)

                newState = %{instructionState | 
                    opcodeMap: newMap, 
                    pointer: new_pointer }
                run(newState)
            # If op1 == op2, stores 1 in the position given by the third parameter. 
            command == 8 ->
                { ops, new_pointer } = getOps(3, instructionState)
                newValue = if ops[1][:value] == ops[2][:value], do: 1, else: 0
                newMap = Map.put(instructionState.opcodeMap, ops[3][:write_address], newValue)

                newState = %{instructionState | 
                    opcodeMap: newMap, 
                    pointer: new_pointer }
                run(newState)
            # Adjust relative base by op1.
            command == 9 ->
                { ops, new_pointer } = getOps(1, instructionState)
                new_base = ops[1][:value] + instructionState.relative_base
                newState = %{instructionState | 
                    relative_base: new_base, 
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

    # Add more input to the program state.
    def addInput(programState, newInput) do
        %InstructionState
        {
            programState | input: Enum.concat(programState.input, newInput)
        }
    end

    # Flush the output.
    def flushOutput(programState) do
        %InstructionState
        {
            programState | output: []
        }
    end

    # Generate and run from program text.
    def runProgram(program_text, input) do
        run(%InstructionState
        {
            opcodeMap: parseProgram(program_text),
            input: input
        })
    end
end

