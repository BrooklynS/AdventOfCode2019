defmodule Problem10 do

    defp hasLineOfSightToAsteroid(parsedMap, currX, currY, targetX, targetY) do

        cond do
            # Skip if target is not an asteroid.
            parsedMap |> Enum.at(targetY) |> Enum.at(targetX) != "#" ->
                false
            # Skip self.
            targetX == currX && targetY == currY ->
                false
            true ->
                # Draw a ray to the target location.
                {xInc, yInc, iterations} = cond do
                targetX == currX ->
                    {0, if(targetY > currY) do 1 else -1 end, abs(targetY - currY)}
                targetY == currY ->
                    {if(targetX > currX) do 1 else -1 end, 0, abs(targetX - currX)}
                true ->
                    # Divide out gcd of each number to generate a slope.
                    divisor = Integer.gcd(targetY - currY, targetX - currX)
                    xRatio = div(targetX - currX, divisor)
                    yRatio = div(targetY - currY, divisor)
                    {xRatio, yRatio, div(targetX - currX, xRatio)}
                end
                Enum.reduce(1..iterations, 0, fn pos, acc ->
                    # Blocked
                    if(parsedMap |> Enum.at(pos * yInc + currY) |> Enum.at(pos * xInc + currX) == "#") do
                        acc + 1
                    else
                        acc
                    end
                end) == 1
                # we include the final location in the iteration, so if there is exactly 1 asteroid, we have line of sight.
        end
    end

    defp getVisibleAsteroidCount(parsedMap, currX, currY, width, height) do

        # Skip if we're not an asteroid.
        if(parsedMap |> Enum.at(currY) |> Enum.at(currX) != "#") do
            0
        else
            # Find all other asteroids that are in line of sight.
            Enum.flat_map(0..width - 1, fn x ->
                Enum.map(0..height - 1, fn y ->
                    hasLineOfSightToAsteroid(parsedMap, currX, currY, x, y)
                end)
            end) |> Enum.reduce(0, fn hasSight, acc -> if hasSight == true do acc + 1 else acc end end)
        end
    end

    def findBestAsteroidStation(input) do
        
        parsedMap = String.split(input, "\r\n") |>
        Enum.map(fn x -> String.graphemes(x) end)

        height = parsedMap |> length()
        width = Enum.at(parsedMap, 0) |> length()
        
        Enum.flat_map(0..width - 1, fn x ->
            Enum.map(0..height - 1, fn y ->
                {x, y, getVisibleAsteroidCount(parsedMap, x, y, width, height)}
            end)
        end) |> Enum.max_by(fn {_x,_y,count} -> count end)
    end


    defp mapAsteroids(parsedMap, stationX, stationY, targetX, targetY) do
        
        # Skip if target is not an asteroid.
        cond do
            parsedMap |> Enum.at(targetY) |> Enum.at(targetX) != "#" ->
                nil
            # Skip self.
            targetX == stationX && targetY == stationY ->
                nil
            true ->
                # Just use squared value.
                dist = (targetY - stationY) * (targetY - stationY) + (targetX - stationX) * (targetX - stationX)
                # organize "angle" to start at 0 and go clockwise from where Pi/4 normally would be on unit circle.
                # atan2 is [0, pi] for positive Y, [-pi, 0) for negative y. Convert to [0, 2pi)
                angle = :math.atan2(stationY - targetY, targetX - stationX)
                angle = if angle < 0 do
                    angle + :math.pi() * 2.0
                else
                    angle
                end
                # Convert to clockwise.
                angle = :math.pi() * 2.0 - angle
                # Put 0 at 12 o'clock.
                angle = angle + :math.pi() / 2.0
                angle = if(angle >= :math.pi() * 2.0) do
                    angle - :math.pi() * 2.0
                else
                    angle
                end
                x = targetX
                y = targetY
                %{dist: dist, angle: angle, x: x, y: y}
        end
    end

    def findNthZappedAsteroid(input, zapCount) do
        parsedMap = String.split(input, "\r\n") |>
        Enum.map(fn x -> String.graphemes(x) end)

        height = parsedMap |> length()
        width = Enum.at(parsedMap, 0) |> length()
        {bestStationX, bestStationY, _} = findBestAsteroidStation(input)

        asteroidsToZap = Enum.flat_map(0..width - 1, fn x ->
            Enum.map(0..height - 1, fn y ->
                mapAsteroids(parsedMap, bestStationX, bestStationY, x, y)
            end)
        end) |> Enum.filter(fn x -> x != nil end)

        asteroidsByAngle = Enum.group_by(asteroidsToZap, fn collection -> collection.angle end)

        zappedAsteroids = Enum.flat_map(asteroidsByAngle, fn {_, groupedList} ->
            # Sort by distance, smallest first.
            Enum.sort(groupedList, fn a,b -> a.dist < b.dist end) |>
            # wrap repeated angles around 2 PI.
            Enum.with_index(0) |>
            Enum.map(fn {element,index} ->
                Map.put(element, :angle, element.angle + :math.pi() * 2.0 * index)
            end)
        end) |> Enum.sort(fn a,b -> a.angle < b.angle end)

        nthAsteroid = Enum.at(zappedAsteroids, zapCount - 1)
        nthAsteroid.x * 100 + nthAsteroid.y
   end
end

# Part 1
{:ok, input } = File.read("lib/input.txt")
Problem10.findBestAsteroidStation(input) |> inspect |> IO.puts()

Problem10.findNthZappedAsteroid(input, 200) |> inspect |> IO.puts()
