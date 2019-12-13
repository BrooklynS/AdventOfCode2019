defmodule Problem13 do

    @blockmap %{
        0 => :empty,
        1 => :wall,
        2 => :block,
        3 => :paddle,
        4 => :ball,
    }

    @tiles %{
        empty: " ",
        wall: "#",
        block: "=",
        paddle: "_",
        ball: "O",
    }

    def extractGameState(output) do
        Enum.chunk_every(output, 3)
        |> Enum.map(fn [x, y, tileid] ->
            if(x == -1 and y == 0) do
                %{x: x, y: y, score: tileid, tileid: -1}
            else
                %{x: x, y: y, tileid: @blockmap[tileid]}
            end
        end)
    end

    def getNumberOfBlockTiles(programState) do
        
        extractGameState(programState.output)
        |> Enum.reduce(0, fn state, acc ->
            if(state.tileid == :block) do
                acc + 1
            else
                acc
            end
        end)
    end

    # Simulate the next state, finding an input that survies.
    def findNextState(programState) do

        [-1,0,1] |> Enum.filter(fn input ->
            nextState = IntComputer.addInput(programState, [input])
                |> IntComputer.run()
            previewGameState = extractGameState(nextState.output) 
            nextBall = previewGameState
            |> Enum.filter(fn x -> x.tileid == :ball end)
            |> Enum.at(-1)

            nextPaddle = previewGameState
            |> Enum.filter(fn x -> x.tileid == :paddle end)
            |> Enum.at(-1)

            # make sure ball got bounced up.
            nextBall.y < nextPaddle.y
        end) |> Enum.at(0)
    end

    # Find an input that keeps the ball alive.
    def cheatInput(programState) do

        if(programState.output == []) do
            [0]
        else
            gameState = extractGameState(programState.output)
            ball = gameState
            |> Enum.filter(fn x -> x.tileid == :ball end)
            |> Enum.at(-1)

            paddle = gameState
            |> Enum.filter(fn x -> x.tileid == :paddle end)
            |> Enum.at(-1)

            # About to die, check all possible states and find one to keep alive.
            if ball.y == paddle.y - 1 do
                [findNextState(programState)]
            else
                # Just follow the ball around.
                cond do
                    paddle.x < ball.x ->
                        [1]
                    paddle.x > ball.x ->
                        [-1]
                    true ->
                        0
                end
            end
        end
    end

    # Draw the tiles.
    defp drawState(programState) do
        gameState = extractGameState(programState.output)

        gameWidth = Enum.map(gameState, fn state -> state.x end) |> Enum.max()
        gameHeight = Enum.map(gameState, fn state -> state.y end) |> Enum.max()

        lookup = Enum.reduce(gameState, %{}, fn state,acc ->
            curr = Map.get(acc, state.x, %{})
            curr = Map.put(curr, state.y, state)
            Map.put(acc, state.x, curr)
        end)
        Enum.map(0..gameHeight, fn yIndex ->
            Enum.map(0..gameWidth, fn xIndex ->
                @tiles[lookup[xIndex][yIndex].tileid]
            end) ++ "\r\n"
        end) |> IO.puts()

        if Map.has_key?(lookup, -1) do
            score = lookup[-1][0].score
            IO.puts("SCORE: #{score}")
        end
    end


    # Run the game to completion.
    def runGameLoop(currState) do
        
        input = cheatInput(currState)

        newState = currState 
        |> IntComputer.addInput(input)
        |> IntComputer.run()

        drawState(newState)

        cond do
            newState.status == :done ->
                IO.puts("DONE")
            true ->
                runGameLoop(newState)
        end
    end

    def playGame(program_text) do
        state = IntComputer.generateProgram(program_text)
        # Inject 2 at memory location 0.
        newState = %InstructionState{ state | opcodeMap: Map.put(state.opcodeMap, 0, 2)}

        runGameLoop(newState)
    end
end

{:ok, body} = File.read("lib/input.txt")
# Part 2
Problem13.playGame(body)

# Part1
IO.puts("Part1: ")
Problem13.getNumberOfBlockTiles(IntComputer.runProgram(body, [])) |> inspect |> IO.puts()

