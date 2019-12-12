defmodule Problem12Test do
  use ExUnit.Case
  doctest Problem12

    test "correct after update" do
        positions = [[-1,0,2],[2,-10,-7],[4,-8,8],[3,5,-1]]
        velocities = [[0,0,0],[0,0,0],[0,0,0],[0,0,0]]

        {newPos, newVel} = Problem12.runNSteps({positions,velocities}, 1)
        assert newPos == [[2,-1,1],[3,-7,-4],[1,-7,5],[2,2,0]]
        assert newVel == [[3,-1,-1],[1,3,3],[-3,1,-3],[-1,-3,1]]
    end

    test "correct after 100 steps" do
        positions = [[-8,-10,0],[5,5,10],[2,-7,3],[9,-8,-3]]
        velocities = [[0,0,0],[0,0,0],[0,0,0],[0,0,0]]

        {newPos, newVel} = Problem12.runNSteps({positions,velocities}, 100)
        assert newPos == [[8, -12, -9],[13, 16, -3],[-29, -11, -1],[16, -13, 23]]
        assert newVel == [[-7, 3, 0],[3, -11, -5],[-3, 7, 4],[7, 1, 1]]
    end

    test "energy calculation" do
        positions = [[-8,-10,0],[5,5,10],[2,-7,3],[9,-8,-3]]
        velocities = [[0,0,0],[0,0,0],[0,0,0],[0,0,0]]

        {newPos, newVel} = Problem12.runNSteps({positions,velocities}, 100)
        assert Problem12.calculateTotalEnergy({newPos, newVel}) == 1940
    end

    test "find number of states until repeat" do
        positions = [[-1, 0, 2],[2, -10, -7],[4, -8, 8],[3, 5, -1]]
        velocities = [[0,0,0],[0,0,0],[0,0,0],[0,0,0]]

        assert Problem12.getStepsUntilStateRepeats({positions, velocities}) == 2772
    end

    test "find number of states until repeat big" do
        positions = [[-8,-10,0],[5,5,10],[2,-7,3],[9,-8,-3]]
        velocities = [[0,0,0],[0,0,0],[0,0,0],[0,0,0]]

        assert Problem12.getStepsUntilStateRepeats({positions, velocities}) == 4686774924
    end

    test "get combined period" do
        assert Problem12.getCombinedPeriod(3, 6) == 6
        assert Problem12.getCombinedPeriod(19, 23) == 437
        assert Problem12.getCombinedPeriod(6, 21) == 42
        assert Problem12.getCombinedPeriod(24, 60) == 120
    end
end
