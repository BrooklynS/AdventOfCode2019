defmodule Problem08 do

    def findLeastCorrupted(input, width, height) do
        chunks = String.graphemes(input) |>
          Enum.chunk_every(width * height)

        chunkCounts = chunks |> Enum.map(fn chunk ->
            Enum.reduce(chunk, [0,0,0], fn x, acc ->
            [zerocounts, onecounts, twocounts] = acc
            cond do
              x == "0" -> 
                [zerocounts + 1, onecounts, twocounts]
              x == "1" -> 
                [zerocounts, onecounts + 1, twocounts]
              x == "2" ->
                [zerocounts, onecounts, twocounts + 1]
              end
          end)
          end)

          minChunk = Enum.min_by(chunkCounts, fn counts ->
            counts |> Enum.at(0)
          end)
          
          Enum.at(minChunk, 1) * Enum.at(minChunk, 2)
    end
    
    def generateImage(input, width, height) do
        chunks = String.graphemes(input) |>
          Enum.chunk_every(width * height)

        Enum.map(0..width*height - 1, fn position ->
            Enum.reduce(chunks, "2", fn chunk, acc ->
                if acc == "2" do
                    Enum.at(chunk, position)
                else
                    acc
                end
            end)
        end) |>
        Enum.chunk_every(width) |>
        Enum.map(fn chunk -> chunk ++ "\n\r" end)
    end
end

# Part 1
{:ok, input } = File.read("lib/input.txt")
Problem08.findLeastCorrupted(input, 25, 6) |> inspect |> IO.puts()

# Part 2
Problem08.generateImage(input, 25, 6) |> IO.puts()

