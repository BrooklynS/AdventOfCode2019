defmodule Problem05Test do
  use ExUnit.Case
  doctest Problem05

  test "cmptest1" do 
      cmptest1 = "3,9,8,9,10,9,4,9,99,-1,8"
      assert Problem05.runSequence(cmptest1, [7]) == [0]
      assert Problem05.runSequence(cmptest1, [8]) == [1]
      assert Problem05.runSequence(cmptest1, [9]) == [0]
    end

  test "cmptest2" do 
      cmptest2 = "3,9,7,9,10,9,4,9,99,-1,8"
      assert Problem05.runSequence(cmptest2, [7]) == [1]
      assert Problem05.runSequence(cmptest2, [8]) == [0]
      assert Problem05.runSequence(cmptest2, [9]) == [0]
  end

  test "cmptest3" do 
      cmptest3 = "3,3,1108,-1,8,3,4,3,99"
      assert Problem05.runSequence(cmptest3, [7]) == [0]
      assert Problem05.runSequence(cmptest3, [8]) == [1]
      assert Problem05.runSequence(cmptest3, [9]) == [0]
  end
    
  test "cmptest4" do 
      cmptest4 = "3,3,1107,-1,8,3,4,3,99"
      assert Problem05.runSequence(cmptest4, [7]) == [1]
      assert Problem05.runSequence(cmptest4, [8]) == [0]
      assert Problem05.runSequence(cmptest4, [9]) == [0]
  end

  test "jumptest1" do 
      jumptest1 = "3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9"
      assert Problem05.runSequence(jumptest1, [0]) == [0]
      assert Problem05.runSequence(jumptest1, [9999]) == [1]
  end

  test "jumptest2" do 
      jumptest2 = "3,3,1105,-1,9,1101,0,0,12,4,12,99,1"
      assert Problem05.runSequence(jumptest2, [0]) == [0]
      assert Problem05.runSequence(jumptest2, [-50]) == [1]
  end

  test "calctest" do 
      calctest = "3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99"
      assert Problem05.runSequence(calctest, [0]) == [999]
      assert Problem05.runSequence(calctest, [8]) == [1000]
      assert Problem05.runSequence(calctest, [9]) == [1001]
  end
end
