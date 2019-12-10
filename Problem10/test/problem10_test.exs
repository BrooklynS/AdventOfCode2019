defmodule Problem10Test do
  use ExUnit.Case
  doctest Problem10

    test "test1" do
        {:ok, input } = File.read("test/test1.txt")
        assert Problem10.findBestAsteroidStation(input) == {3, 4, 8}
    end

    test "test2" do
        {:ok, input } = File.read("test/test2.txt")
        assert Problem10.findBestAsteroidStation(input) == {5, 8, 33}
    end

    test "test3" do
        {:ok, input } = File.read("test/test3.txt")
        assert Problem10.findBestAsteroidStation(input) == {1, 2, 35}
    end

    test "test4" do
        {:ok, input } = File.read("test/test4.txt")
        assert Problem10.findBestAsteroidStation(input) == {6, 3, 41}
    end

    test "test5" do
        {:ok, input } = File.read("test/test5.txt")
        assert Problem10.findBestAsteroidStation(input) == {11, 13, 210}
    end

    test "part2test1" do
        {:ok, input } = File.read("test/test5.txt")
        assert Problem10.findNthZappedAsteroid(input, 10) == 1208
        assert Problem10.findNthZappedAsteroid(input, 200) == 802
        assert Problem10.findNthZappedAsteroid(input, 299) == 1101
    end
end
