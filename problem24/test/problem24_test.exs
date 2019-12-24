defmodule Problem24Test do
    use ExUnit.Case
    doctest Problem24

    test "getBiodiversityScore" do
        #   .....
        #   .....
        #   .....
        #   #....
        #   .#...
        
        testMap = %{ 3 => %{0 => true}, 4 => %{1 => true}} 
        assert Problem24.getBiodiversityScore(testMap, 5) == 2129920
    end

    
    test "getBugCountWithDepth" do
        
        testMap = %{ 3 => %{0 => true, 3 => true}, 4 => %{1 => true}}
        depthMap = Map.put(%{}, 0, testMap) |> Map.put(1, testMap) |> Map.put(2,testMap)
        assert Problem24.getTotalBugCount(depthMap) == 9
    end
end
