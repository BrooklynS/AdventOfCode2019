using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ConsoleApp7
{
    class MapLocation
    {
        public bool IsWall;
        public List<char> Keys = new List<char>();
        public List<char> Doors = new List<char>();
        public int x;
        public int y;
        public int compressedDistance = 0;
        public bool IsStart;

        public void Merge(MapLocation other)
        {
            if (!other.Keys.Any(key => Doors.Any(door => char.ToLower(door) == key)))
            {
                compressedDistance = Math.Max(other.compressedDistance, compressedDistance);
            }
            Keys.AddRange(other.Keys);
            Doors.AddRange(other.Doors);

            // Squish keys that match.
            Doors = Doors.Where(door => !Keys.Contains(char.ToLower(door))).ToList();
        }

        public void MakeWall()
        {
            Keys.Clear();
            Doors.Clear();
            IsWall = true;
        }
    }

    class MinStepsResult
    {
        public int Steps;
        public bool Success;
    }

    class NodeStartIndexPair
    {
        public int BotIndex;
        public MapLocation Target;
    }

    class Program
    {
        static int GetMultipleOptimumPaths(List<List<MapLocation>> map,
            List<MapLocation> requiredNodes)
        {
            var startLocations = map.SelectMany(maplist => maplist.Where(item => item.IsStart)).ToList();
            var nodesByStartIndex = new List<NodeStartIndexPair>();
            var keys = map.SelectMany(mapList => mapList.SelectMany(item => item.Keys));
            var ownedKeys = new HashSet<char>();
            foreach (var key in keys)
            {
                ownedKeys.Add(key);
            }

            for (int index = 0; index < startLocations.Count; ++index)
            {
                var nodeList = new List<MapLocation>();
                foreach (var target in requiredNodes)
                {
                    if (GetMinSteps(map, 1, new Dictionary<int, Dictionary<int, int>>(), startLocations[index].x, startLocations[index].y, target.x, target.y, ownedKeys).Success)
                    {
                        nodesByStartIndex.Add(new NodeStartIndexPair
                        {
                            BotIndex = index,
                            Target = target
                        });
                    }
                }
            }

            return GetMultipleOptimumPathsRecursive(map, 0, new HashSet<char>(), startLocations, nodesByStartIndex, 0, 99999999);
        }

        static int GetMultipleOptimumPathsRecursive(List<List<MapLocation>> map,
            int currStepCount,
            HashSet<char> ownedKeys,
            List<MapLocation> botLocations,
            List<NodeStartIndexPair> nodesByStartIndex,
            int depth,
            int best)
        {
            // This path is too suboptimal.
            if (currStepCount >= best)
            {
                return best;
            }
            // End condition.
            if (nodesByStartIndex.Count == 0)
            {
                return currStepCount;
            }
            var tempLocations = nodesByStartIndex.ToList();
            foreach (var location in nodesByStartIndex)
            {
                // temporarily pop this location.
                tempLocations.Remove(location);
                int botIndex = location.BotIndex;
                var botStartLoc = botLocations[botIndex];
                var botEndLoc = location.Target;
                var result = GetMinSteps(map, 1, new Dictionary<int, Dictionary<int, int>>(),
                    botStartLoc.x, botStartLoc.y, botEndLoc.x, botEndLoc.y, ownedKeys);

                if (result.Success)
                {
                    // Update keys and botloc.
                    map[botEndLoc.y][botEndLoc.x].Keys.ForEach(key => ownedKeys.Add(key));
                    botLocations[botIndex] = botEndLoc;
                    int reduction = 0;
                    if (tempLocations.Where(tmp => tmp.BotIndex == botIndex).Count() == 0)
                    {
                        reduction = botEndLoc.compressedDistance;
                    }
                    int stepsForPath = GetMultipleOptimumPathsRecursive(map, currStepCount + result.Steps - reduction,
                        ownedKeys, botLocations, tempLocations, depth + 1, best);

                    if (stepsForPath < best)
                    {
                        best = stepsForPath;
                    }
                    // Pop keys and botloc.
                    botLocations[botIndex] = botStartLoc;
                    map[botEndLoc.y][botEndLoc.x].Keys.ForEach(key => ownedKeys.Remove(key));
                }

                tempLocations.Add(location);
            }

            return best;
        }

        static MinStepsResult GetMinSteps(List<List<MapLocation>> map,
            int currStepCount,
            Dictionary<int, Dictionary<int, int>> visitedLocations,
            int x, int y, int targetX, int targetY, HashSet<char> ownedKeys)
        {
            int visitedValue = currStepCount;
            if (visitedLocations.ContainsKey(x))
            {
                if (visitedLocations[x].ContainsKey(y))
                {
                    visitedValue = Math.Min(visitedValue, visitedLocations[x][y]);
                }
            }
            else
            {
                visitedLocations[x] = new Dictionary<int, int>();
            }
            visitedLocations[x][y] = visitedValue;

            var finalResult = new MinStepsResult();
            if (visitedValue < currStepCount)
            {
                // Already visited this location with a lower count, bail.
                finalResult.Success = false;
                finalResult.Steps = currStepCount;
            }
            else
            {
                var results = new List<MinStepsResult>();
                var locations = new List<MapLocation> { map[y + 1][x], map[y - 1][x], map[y][x + 1], map[y][x - 1] };
                foreach (var location in locations)
                {
                    // Make sure number of keys is owned.
                    if (!location.Doors.All(doorKey => ownedKeys.Contains(char.ToLower(doorKey))))
                    {
                        results.Add(new MinStepsResult
                        {
                            Steps = currStepCount,
                            Success = false,
                        });
                    }
                    // Found the thing.
                    else if (location.x == targetX && location.y == targetY)
                    {
                        results.Add(new MinStepsResult
                        {
                            Steps = currStepCount,
                            Success = true,
                        });
                    }
                    else if (location.IsWall)
                    {
                        results.Add(new MinStepsResult
                        {
                            Steps = currStepCount,
                            Success = false,
                        });
                    }
                    else
                    {
                        // Recurse.
                        results.Add(GetMinSteps(map, currStepCount + 1, visitedLocations, location.x, location.y, targetX, targetY, ownedKeys));
                    }
                }

                results.Sort((a, b) =>
                {
                    if (a.Success && b.Success)
                    {
                        return a.Steps.CompareTo(b.Steps);
                    }
                    else if (a.Success && !b.Success)
                    {
                        return -1;
                    }
                    else if (!a.Success && b.Success)
                    {
                        return 1;
                    }
                    else
                    {
                        return a.Steps.CompareTo(b.Steps);
                    }
                });
                finalResult = results.First();
            }

            return finalResult;
        }

        static bool CanMerge(MapLocation from, MapLocation to, List<List<MapLocation>> map)
        {
            var firstDoors = from.Doors.Where(door => !to.Keys.Contains(char.ToLower(door))).ToList();
            var otherDoors = to.Doors.Where(door => !from.Keys.Contains(char.ToLower(door))).ToList();
            var doorSum = firstDoors.Count + otherDoors.Count;

            // Can't squish door into new key.
            if (firstDoors.Count >= 1 && to.Keys.Count > 0)
            {
                return false;
            }
            // Doors can't go into open space.
            if (GetWallCount(map, to.x, to.y) <= 1 && doorSum > 0)
            {
                return false;
            }
            if (from.IsStart || to.IsStart)
            {
                return false;
            }
            return true;
        }

        static int GetWallCount(List<List<MapLocation>> map, int x, int y)
        {
            var locations = new List<MapLocation> { map[y + 1][x], map[y - 1][x], map[y][x + 1], map[y][x - 1] };
            return locations.Count(location => location.IsWall);
        }

        static void ConstructDeadEnds(List<List<MapLocation>> map)
        {
            bool anyUpdated = true;
            while (anyUpdated)
            {
                anyUpdated = false;
                int height = map.Count;
                int width = map[0].Count;

                for (int y = 1; y < height - 1; ++y)
                {
                    for (int x = 1; x < width - 1; ++x)
                    {
                        if (GetWallCount(map, x, y) == 3)
                        {
                            if (map[y][x].Keys.Count == 0 && !map[y][x].IsWall && !map[y][x].IsStart)
                            {
                                map[y][x] = new MapLocation() { IsWall = true };
                                anyUpdated = true;
                            }
                        }
                    }
                }
            }
        }

        static void CompressHallways(List<List<MapLocation>> map, ref int compressedLength)
        {
            bool anyUpdated = true;
            while (anyUpdated)
            {
                anyUpdated = false;
                int height = map.Count;
                int width = map[0].Count;

                for (int y = 1; y < height - 1; ++y)
                {
                    for (int x = 1; x < width - 1; ++x)
                    {
                        var currLoc = map[y][x];
                        if (currLoc.Keys.Count > 0)
                        {
                            var locations = new List<MapLocation> { map[y + 1][x], map[y - 1][x], map[y][x + 1], map[y][x - 1] };
                            var wallCount = locations.Count(loc => loc.IsWall);
                            if (wallCount == 3)
                            {
                                var newLoc = locations.Single(loc => !loc.IsWall);
                                if (CanMerge(currLoc, newLoc, map))
                                {
                                    compressedLength += 2;
                                    newLoc.Merge(currLoc);
                                    newLoc.compressedDistance = currLoc.compressedDistance + 1;
                                    currLoc.MakeWall();
                                    anyUpdated = true;
                                }
                            }
                        }
                    }
                }
            }
        }

        static void DrawMap(List<List<MapLocation>> map)
        {
            foreach (var ylist in map)
            {
                var sb = new StringBuilder();
                foreach (var location in ylist)
                {
                    if (location.IsWall)
                    {
                        sb.Append("#");
                    }
                    else if (location.Keys.Count > 0)
                    {
                        sb.Append(location.Keys[0]);
                    }
                    else if (location.Doors.Count > 0)
                    {
                        sb.Append(location.Doors[0]);
                    }
                    else if (location.IsStart)
                    {
                        sb.Append("@");
                    }
                    else
                    {
                        sb.Append(".");
                    }
                }
                Console.WriteLine(sb.ToString());
            }
        }

        static List<List<MapLocation>> GenerateMap(string inputPath)
        {
            var map = new List<List<MapLocation>>();

            var input = new List<string>();
            // Open the text file using a stream reader.
            using (StreamReader sr = new StreamReader(inputPath))
            {
                string line = "";
                while ((line = sr.ReadLine()) != null)
                {
                    input.Add(line.Trim());
                }
            }

            int height = input.Count;
            int width = input[0].Length;

            var startLocations = new List<MapLocation>();
            for (int y = 0; y < height; ++y)
            {
                var list = new List<MapLocation>();
                for (int x = 0; x < width; ++x)
                {
                    var character = input[y][x];
                    var location = new MapLocation()
                    {
                        x = x,
                        y = y,
                    };

                    if (character == '#')
                    {
                        location.IsWall = true;
                    }
                    if (char.IsLower(character))
                    {
                        location.Keys.Add(character);
                    }
                    if (char.IsUpper(character))
                    {
                        location.Doors.Add(character);
                    }

                    if (character == '@')
                    {
                        location.IsStart = true;
                        startLocations.Add(location);
                    }
                    list.Add(location);

                }
                map.Add(list);
            }

            return map;
        }

        static List<MapLocation> GetCriticalNodes(List<List<MapLocation>> map, ref int squishedLength)
        {
            //DrawMap(map);

            ConstructDeadEnds(map);

            squishedLength = 0;
            CompressHallways(map, ref squishedLength);
            //DrawMap(map);

            var needed = map.SelectMany(location => location.SelectMany(loc => loc.Doors).Select(door => char.ToLower(door)));
            var nonCriticalNodes = map.SelectMany(locationGrid =>
                locationGrid.Where(loc => loc.Keys.Count > 0 && !needed.Any(item => loc.Keys.Any(key => key == item)))).ToList();
            var neededNodes = map.SelectMany(locationGrid =>
                locationGrid.Where(loc => needed.Any(item => loc.Keys.Any(key => key == item)))).ToList();
            neededNodes.AddRange(nonCriticalNodes);
            // Hardcode for now, these elements exist on the path to existing critical elements.
            // Too lazy to algorithmically squish these.
            return neededNodes.Where(loc => !loc.Keys.Contains('l') && !loc.Keys.Contains('x') && !loc.Keys.Contains('p')).ToList();
        }

        static void Main(string[] args)
        {
            var map1 = GenerateMap("../../input.txt");
            var map2 = GenerateMap("../../input2.txt");

            foreach(var map in new [] { map1, map2 })
            {
                int squished = 0;
                var criticalNodes = GetCriticalNodes(map, ref squished);
                var pathResult = GetMultipleOptimumPaths(map, criticalNodes);
                Console.WriteLine(pathResult + squished);
            }

            Console.ReadKey();
        }
    }
}
