defmodule Problem11 do

    def runRobot(input_text) do
        program = IntComputer.generateProgram(input_text)
        # Robot angle will be:
        # Left 0
        # Up 1
        # Right 2
        # Down 3
        acc = %{robotX: 0, robotY: 0, robotAngle: 1, paintedPanels: %{}}
        finalState = runProgramRecursive(program, acc)
        Enum.map(finalState.paintedPanels, fn {_k, v} ->
            Enum.reduce(v, 0, fn _, acc -> acc + 1 end)
        end) |> Enum.sum()
    end

    def part2(input_text) do
        program = IntComputer.generateProgram(input_text)
        # Robot angle will be:
        # Left 0
        # Up 1
        # Right 2
        # Down 3
        acc = %{robotX: 0, robotY: 0, robotAngle: 1, paintedPanels: %{}, defaultInput: 1}
        finalState = runProgramRecursive(program, acc)
        
        # Find Min/Max X so we can draw in a grid.
        minX = Enum.map(finalState.paintedPanels, fn {xLoc, _value} -> xLoc end) |> Enum.min()
        maxX = Enum.map(finalState.paintedPanels, fn {xLoc, _value} -> xLoc end) |> Enum.max()
        
        minY = Enum.map(finalState.paintedPanels, fn {_key, value} ->
            value |> Map.keys() |> Enum.min()
        end) |> Enum.min()

        maxY = Enum.map(finalState.paintedPanels, fn {_key, value} ->
            value |> Map.keys() |> Enum.max()
        end) |> Enum.max()

        Enum.map(maxY..minY, fn y ->
            Enum.map(minX..maxX, fn x ->
                xMap = Map.get(finalState.paintedPanels, x, %{})
                color = Map.get(xMap, y, 0)
                cond do
                    color == 1 ->
                        "X"
                    true ->
                        " "
                end
            end) ++ "\r\n"
        end) |> IO.puts()
    end

    defp runProgramRecursive(program, acc) do
        
        xMap = Map.get(acc.paintedPanels, acc.robotX, %{})
        # black (0) by default if unset.
        currentColor = if Map.has_key?(acc, :defaultInput) do
            acc.defaultInput
        else
            Map.get(xMap, acc.robotY, 0)
        end
        programState = IntComputer.run(%{program | input: Enum.concat(program.input, [currentColor])})
        robotPaintedColor = Enum.at(programState.output, 0)
        turn = Enum.at(programState.output, 1)

        # Replace color in the map.
        updatedMap = Map.put(xMap, acc.robotY, robotPaintedColor)
        newPanels = Map.put(acc.paintedPanels, acc.robotX, updatedMap)

        newAngle = if turn == 0 do
            rem(acc.robotAngle - 1 + 4, 4)
        else
            rem(acc.robotAngle + 1, 4)
        end

        # Update X.
        newX = cond do
        newAngle == 0 ->
            acc.robotX - 1
        newAngle == 2 ->
            acc.robotX + 1
        true ->
            acc.robotX
        end

        # Update Y.
        newY = cond do
        newAngle == 1 ->
            acc.robotY + 1
        newAngle == 3 ->
            acc.robotY - 1
        true ->
            acc.robotY
        end

        # Generate new state.
        acc = %{robotX: newX, robotY: newY, robotAngle: newAngle, paintedPanels: newPanels}
        if(programState.status == :done) do
            acc
        else
            # Keep running, clear output.
            runProgramRecursive(%{programState | output: []}, acc)
        end
    end
end

{:ok, body} = File.read("lib/input.txt")
Problem11.runRobot(body) |> inspect |> IO.puts()

Problem11.part2(body)