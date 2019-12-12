defmodule Problem12 do
  
    def parseInput(input_text) do
        positions = String.split(input_text, "\r\n") |>
        Enum.map(fn line ->
            String.split(line, ["<x=", "y=", "z=", " ", ">", ","]) |> 
            Enum.filter(fn item -> item != "" end) |>
            Enum.map(fn char -> String.to_integer(char) end)
        end)

        velocities = Enum.map(1..length(positions), fn _ -> [0, 0, 0] end)
        {positions, velocities}
    end

    def runNSteps({positions, velocities}, steps) do
        if steps == 0 do
            {positions, velocities}
        else
            newValues = update({positions, velocities})
            runNSteps(newValues, steps - 1)
        end
    end

    def getCombinedPeriod(a, b) do
        # Factor out the GCD from both numbers.
        gcd = Integer.gcd(a, b)
        a * div(b, gcd) # Should be equal to b * div(a, gcd).
    end

    def getStepsUntilStateRepeats({positions, velocities}) do
        
        # Zero out the Y and Z components.
        xPositions = Enum.map(positions, fn [x,_y,_z] ->
            [x, 0, 0]
        end)
        xVelocities = Enum.map(velocities, fn [x,_y,_z] ->
            [x, 0, 0]
        end)
        {xPeriod, _xPhase} = getStepsUntilStateRepeats({xPositions, xVelocities}, 0, %{})

        # Zero out the X and Z components.
        yPositions = Enum.map(positions, fn [_x,y,_z] ->
            [0, y, 0]
        end)
        yVelocities = Enum.map(velocities, fn [_x,y,_z] ->
            [0, y, 0]
        end)
        {yPeriod, _yPhase} = getStepsUntilStateRepeats({yPositions, yVelocities}, 0, %{})

        # Zero out the X and Y components.
        zPositions = Enum.map(positions, fn [_x,_y,z] ->
            [0, 0, z]
        end)
        zVelocities = Enum.map(velocities, fn [_x,_y,z] ->
            [0, 0, z]
        end)
        {zPeriod, _zPhase} = getStepsUntilStateRepeats({zPositions, zVelocities}, 0, %{})

        # IO.puts("Calc Complete: #{xPeriod} #{xPhase} #{yPeriod} #{yPhase} #{zPeriod} #{zPhase}")
        # To be periodic/stable, looks like start point/phase is always 0?

        # Calc Period of X/Y, then XY/Z. Some additional adjustment would be needed if phase weren't all 0.
        # Not sure if that's actually possible.
        getCombinedPeriod(xPeriod, yPeriod) |> getCombinedPeriod(zPeriod)
    end
    
    defp getStepsUntilStateRepeats(posVelocityTuple, stepIndex, visitedMap) do
        
        if Map.has_key?(visitedMap, posVelocityTuple) do
            startIndex = Map.get(visitedMap, posVelocityTuple)
            period = stepIndex - startIndex
            { period, startIndex }
        else
            visitedMap = Map.put(visitedMap, posVelocityTuple, stepIndex)
            newPair = update(posVelocityTuple)
            getStepsUntilStateRepeats(newPair, stepIndex + 1, visitedMap)
        end
    end

    def calculateTotalEnergy({positions, velocities}) do
        Enum.map(0..length(positions) - 1, fn index ->
            posSum = Enum.at(positions, index) |> Enum.map(fn x -> abs(x) end) |> Enum.sum()
            velSum = Enum.at(velocities, index) |> Enum.map(fn x -> abs(x) end) |> Enum.sum()
            posSum * velSum
        end) |> Enum.sum()
    end

    defp getAdjustments(body1, body2) do
        cond do
            body1 < body2 ->
                1
            body1 > body2 ->
                -1
            true ->
                0
        end
    end

    # Run one pass of updates.
    defp update({positions, velocities}) do
        # Apply gravity to velocities.
        newVelocities = Enum.zip(positions, velocities)
        |> Enum.map(fn {pos, vel} ->
            [x1, y1, z1] = pos
            Enum.map(positions, fn [x2, y2, z2] ->
                # Okay to compare with self since it will just be 0,0,0.
                [getAdjustments(x1, x2), getAdjustments(y1, y2), getAdjustments(z1, z2)]
            end)
            # Put adjustments into velocity.
            |> Enum.reduce(vel, fn [xAdj, yAdj, zAdj], [xAcc, yAcc, zAcc] ->
                [xAdj + xAcc, yAdj + yAcc, zAdj + zAcc]
            end)
        end)

        # Apply final velocity to positions.
        newPositions = Enum.zip(positions, newVelocities)
        |> Enum.map(fn {[x,y,z],[vx,vy,vz]} ->
            [x + vx, y + vy, z + vz]
        end)

        {newPositions, newVelocities}
    end
end

{:ok, body} = File.read("lib/input.txt")
# Part1
Problem12.parseInput(body) |> Problem12.runNSteps(1000) |> Problem12.calculateTotalEnergy() |> inspect |> IO.puts()
# Part2
Problem12.parseInput(body) |> Problem12.getStepsUntilStateRepeats() |> inspect |> IO.puts()
