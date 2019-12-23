defmodule Problem22Test do
  use ExUnit.Case
  doctest Problem22

    test "test1" do
        input = Problem22.generateInputFromFile("test/test1.txt")

        assert Problem22.runList(input, 10) == [0, 3, 6, 9, 2, 5, 8, 1, 4, 7]
    end

    test "increment 3" do
        assert Problem22.runList(["deal with increment 3"], 10) == [0, 7, 4, 1, 8, 5, 2, 9, 6, 3]
    end

    test "increment 3 reverse" do
        assert Problem22.runList(["deal with increment 3", "deal into new stack"], 10) == [3, 6, 9, 2, 5, 8, 1, 4, 7, 0]
    end

    test "cut" do
        assert Problem22.runList(["cut 3"], 10) == [3, 4, 5, 6, 7, 8,9, 0, 1, 2]
    end

    test "cut negative" do
        assert Problem22.runList(["cut -2"], 10) == [8, 9, 0, 1, 2, 3, 4, 5, 6, 7]
    end

    test "test2" do
        input = Problem22.generateInputFromFile("test/test2.txt")
        assert Problem22.runList(input, 10) == [3, 0, 7, 4, 1, 8, 5, 2, 9, 6]
    end

    test "test3" do
        input = Problem22.generateInputFromFile("test/test3.txt")
        assert Problem22.runList(input, 10) == [6, 3, 0, 7, 4, 1, 8, 5, 2, 9]
    end

    
    test "test4" do
        input = Problem22.generateInputFromFile("test/test4.txt")
        assert Problem22.runList(input, 10) == [9, 2, 5, 8, 1, 4, 7, 0, 3, 6]
    end

    test "congruence" do
        assert Problem22.solveLinearCongruence(7,13,100) == 59
        assert Problem22.solveLinearCongruence(2,3,5) == 4
        assert Problem22.solveLinearCongruence(17,3,29) == 7
    end

    test "modular invert" do
        assert Problem22.modInvert(3, 26) == 9
    end
end
