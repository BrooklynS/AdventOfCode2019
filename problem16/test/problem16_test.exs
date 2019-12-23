defmodule Problem16Test do
  use ExUnit.Case
  doctest Problem16


  test "input to number" do
    assert Problem16.convertListToNumber([1,2,3,4,5,6,7,8,9,0]) == 1234567890
  end

  test "gen list" do
    assert Problem16.generateListInput(1234567890) == [1,2,3,4,5,6,7,8,9,0]
  end

  test "after 1 phase" do
    assert Problem16.calcFFT([1, 2, 3, 4, 5, 6, 7, 8], [0, 1, 0, -1]) == Problem16.generateListInput(48226158)
  end

  test "after 100 phases" do
    assert Problem16.calcNFFTs(Problem16.generateListInput(80871224585914546619083218645595), [0, 1, 0, -1], 100) |> Enum.take(8) == Problem16.generateListInput(24176176)
    assert Problem16.calcNFFTs(Problem16.generateListInput(19617804207202209144916044189917), [0, 1, 0, -1], 100) |> Enum.take(8) == Problem16.generateListInput(73745418)
    assert Problem16.calcNFFTs(Problem16.generateListInput(69317163492948606335995924319873), [0, 1, 0, -1], 100) |> Enum.take(8) == Problem16.generateListInput(52432133)
  end

   test "faster ffts" do
    input = Problem16.generateListInput(12345678910)
    origFFT = Problem16.calcFFT(input, [0, 1, 0, -1])
    fastFFT = Problem16.fasterFFT(input)
    assert origFFT -- fastFFT == []
  end

   test "faster ffts n times" do
    input = Problem16.generateListInput(12345678910)
    origFFT = Problem16.calcNFFTs(input, [0, 1, 0, -1], 100)
    fastFFT = Problem16.calcNFasterFFTs(input, 100)
    assert origFFT -- fastFFT == []
  end
end
