defmodule Problem14 do
    
    # Parse text input into [reactants: %{"name" => quantity, "name2' => quantity ...}, product: %{"name", quantity}]
    def parseReactionList(input) do
        String.split(input, ["\r","\n"])
        |> Enum.filter(fn string -> string != "" end)
        |> Enum.map(fn string -> 
            [reactantString, productString] = String.split(string, " => ")
            # Parse rightg side.
            [productCountString, productString] = String.split(productString, " ")
            count = String.to_integer(productCountString)
            productMap = %{productString => count}
            # Parse left side.
            reactantMap = String.split(reactantString, ", ")
            |> Enum.map(fn reactant ->
                [countString, reactantString] = String.split(reactant, " ")
                [ count: String.to_integer(countString), reactant: reactantString ]
            end)
            |> Enum.reduce(%{}, fn x,acc -> Map.put(acc, x[:reactant], x[:count]) end)

            [ reactants: reactantMap, product: productMap ]
        end)
    end
    
    # Given a list of reactions, calculate the amount of ore needed to make 1 fuel.
    def calculateOreNeeded(input) do

        reactionList = parseReactionList(input)
        {oreCount, _leftovers} = calculateOreRecursive("FUEL", 1, reactionList, %{})
        oreCount
    end
    
    # Recursively calculate ore for each step along the way, tracking leftover reactants.
    defp calculateOreRecursive(targetElement, neededQuantity, reactionList, leftovers) do
        
        availableAmount = Map.get(leftovers, targetElement, 0)
        # Borrow from whatever is already available.
        {neededQuantity, leftovers} = if availableAmount >= neededQuantity do
            { 0, Map.put(leftovers, targetElement, availableAmount - neededQuantity) }
        else
            { neededQuantity - availableAmount, Map.put(leftovers, targetElement, 0) }
        end

        # End condition.
        if targetElement == "ORE" do
            {neededQuantity, leftovers}
        else
            # Hopefully there is only 1. If not, this becomes an optimization problem.
            reaction = Enum.filter(reactionList, fn pairMap -> Map.has_key?(pairMap[:product], targetElement) end)
            |> Enum.at(0)

            amountProduced = reaction[:product][targetElement]
            # Determine how many reactions are needed. If it does amountProduced does not divide quantity evenly,
            # one additional reaction will be needed, creating leftovers.
            reactionsNeeded = div(neededQuantity, amountProduced) + if rem(neededQuantity, amountProduced) == 0 do
                0
            else
                1
            end
            leftover = reactionsNeeded * amountProduced - neededQuantity
            leftovers = Map.put(leftovers, targetElement, Map.get(leftovers, targetElement, 0) + leftover)

            # Walk through each reactant and recursively calculate the amount of ore needed.
            # Leftovers need to be in the accumulator since the leftovers from the first reactants can
            # affect the remaining reactants.
            # Accumulator is {oreCount, leftovers}.
            Enum.reduce(reaction[:reactants], {0, leftovers}, fn {reactantName, reactantQuantity}, {accOreCount, accLeftovers} ->
                
                {oreCount, leftovers} = calculateOreRecursive(reactantName,
                    reactionsNeeded * reactantQuantity, 
                    reactionList,
                    accLeftovers)

                {oreCount + accOreCount, leftovers}
            end)
        end
    end

    # Determine how much fuel can be generated for a given amount of Ore.
    def calculateFuelGivenOre(input, target) do
        
        reactionList = parseReactionList(input)
        calculateFuelGivenOreRecursive(target, 1, 0, reactionList, -1)
    end

    # Recursively guess and check to find the amount of fuel less than the target.
    defp calculateFuelGivenOreRecursive(target, currFuel, prevFuel, reactionList, upperBound) do

        {oreCount, _} = calculateOreRecursive("FUEL", currFuel, reactionList, %{})
        if oreCount > target do
            if currFuel == prevFuel or currFuel == prevFuel + 1 do
                # End condition.
                prevFuel
            else
                range = div(currFuel - prevFuel, 2)
                # Always at least add 1.
                amountToAdd = if range == 0 do
                    range + 1
                else
                    range
                end
                # Reduce currFuel, keep prev the same.
                calculateFuelGivenOreRecursive(target, prevFuel + amountToAdd, prevFuel, reactionList, currFuel)
            end
        else
            # Increase currFuel by multiplying by 2.
            # If upperBound has been set and this exceeds it, just use the upperBound.
            nextFuel = currFuel * 2
            nextFuel = if upperBound != -1 and nextFuel >= upperBound do
                upperBound
            else
                nextFuel
            end
            
            calculateFuelGivenOreRecursive(target, nextFuel, currFuel, reactionList, upperBound)
        end
    end

    def main() do
        # Part 1
        {:ok, body} = File.read("lib/input.txt")
        Problem14.calculateOreNeeded(body) |> inspect |> IO.puts()
        # Part 2
        Problem14.calculateFuelGivenOre(body, 1000000000000000) |> inspect |> IO.puts()
    end
end