using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading;

namespace ConsoleApp7
{
    class MapLocation
    {
        public bool IsWall;
        public bool HasPortal;
        public string PortalName;
        public int x;
        public int y;
        public bool IsStart;
        public bool IsEnd;
        public int PortalDepthModifier;

        public void Merge(MapLocation other)
        {
        }

        public bool CanTakePortal(int currentDepth)
        {
            if (IsStart || IsEnd)
            {
                return false;
            }

            return currentDepth + PortalDepthModifier >= 0;
        }

        public bool CanWallify()
        {
            return !IsWall && !HasPortal && !IsStart && !IsEnd;
        }

        public void MakeWall()
        {
            IsWall = true;
        }
    }

    class MinStepsResult
    {
        public int Steps;
        public bool Success;
    }

    class Program
    {
        static MinStepsResult GetMinSteps(List<List<MapLocation>> map,
            int currStepCount,
            Dictionary<int, Dictionary<int, int>> visitedLocations,
            MapLocation current, MapLocation target)
        {
            int visitedValue = currStepCount;
            int x = current.x;
            int y = current.y;
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
                var currLoc = map[y][x];
                var locations = new List<MapLocation> { map[y + 1][x], map[y - 1][x], map[y][x + 1], map[y][x - 1] };
                if (map[y][x].HasPortal)
                {
                    // Super inefficient, just traverse the whole thing to find portals.
                    var portals = map.SelectMany(loc => loc.Where(location => location.PortalName == currLoc.PortalName
                    && location != currLoc)).ToList();
                    locations.AddRange(portals);
                }

                foreach (var location in locations)
                {
                    if (location.x == target.x && location.y == target.y)
                    {
                        results.Add(new MinStepsResult
                        {
                            Steps = currStepCount + 1,
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
                        results.Add(GetMinSteps(map, currStepCount + 1, visitedLocations, location, target));
                    }
                }

                results.Sort(CompareResults());
                finalResult = results.First();
            }

            return finalResult;
        }

        static MinStepsResult GetMinStepsWithDepth(List<List<MapLocation>> map,
            int currStepCount,
            List<Dictionary<int, Dictionary<int, int>>> visitedLocations,
            MapLocation current, MapLocation target, int currentDepth, int maxDepth)
        {
            int visitedValue = currStepCount;
            if (visitedLocations.Count <= currentDepth)
            {
                visitedLocations.Add(new Dictionary<int, Dictionary<int, int>>());
            }
            var visited = visitedLocations[currentDepth];

            int x = current.x;
            int y = current.y;

            if (visited.ContainsKey(x))
            {
                if (visited[x].ContainsKey(y))
                {
                    visitedValue = Math.Min(visitedValue, visited[x][y]);
                }
            }
            else
            {
                visited[x] = new Dictionary<int, int>();
            }

            visited[x][y] = visitedValue;

            var finalResult = new MinStepsResult();
            if (visitedValue < currStepCount || currentDepth > maxDepth)
            {
                // Already visited this location with a lower count, bail.
                finalResult.Success = false;
                finalResult.Steps = currStepCount;
            }
            else
            {
                var results = new List<MinStepsResult>();
                var currLoc = map[y][x];
                var locations = new List<MapLocation> { map[y + 1][x], map[y - 1][x], map[y][x + 1], map[y][x - 1] };
                foreach (var location in locations)
                {
                    if (location.x == target.x && location.y == target.y && currentDepth == 0)
                    {
                        results.Add(new MinStepsResult
                        {
                            Steps = currStepCount + 1,
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
                        results.Add(GetMinStepsWithDepth(map, currStepCount + 1, visitedLocations, location, target, currentDepth, maxDepth));
                    }
                }

                if (currLoc.HasPortal && currLoc.CanTakePortal(currentDepth))
                {
                    // Super inefficient, just traverse the whole thing to find portals.
                    var portalExit = map.SelectMany(loc => loc.Where(location => location.PortalName == currLoc.PortalName && currLoc != location)).FirstOrDefault();
                    if (portalExit != null)
                    {
                        var modifier = currLoc.PortalDepthModifier;
                        results.Add(GetMinStepsWithDepth(map, currStepCount + 1, visitedLocations, portalExit, target, currentDepth + modifier, maxDepth));
                    }
                }

                results.Sort(CompareResults());
                finalResult = results.First();
            }

            return finalResult;
        }

        private static Comparison<MinStepsResult> CompareResults()
        {
            return (a, b) =>
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
            };
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
                            var location = map[y][x];
                            if (location.CanWallify())
                            {
                                map[y][x] = new MapLocation() { IsWall = true };
                                anyUpdated = true;
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
                    else if (location.HasPortal)
                    {
                        sb.Append(location.PortalName[0]);
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

        static List<List<MapLocation>> GenerateMap(string inputPath, string startPortal, string endPortal)
        {
            var map = new List<List<MapLocation>>();

            var input = new List<string>();
            // Open the text file using a stream reader.
            using (StreamReader sr = new StreamReader(inputPath))
            {
                string line = "";
                while ((line = sr.ReadLine()) != null)
                {
                    input.Add(line);
                }
            }

            int height = input.Count;
            int width = input[0].Length;

            // Extract walls.
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

                    if (character == '#' || character == ' ' || char.IsUpper(character))
                    {
                        location.IsWall = true;
                    }
                    list.Add(location);
                }
                map.Add(list);
            }

            // Extract portal information.
            for (int y = 1; y < height - 1; ++y)
            {
                for (int x = 1; x < width - 1; ++x)
                {
                    var character = input[y][x];
                    if (char.IsUpper(character))
                    {
                        // Is there an adjacent empty space?
                        var locations = new List<MapLocation> { map[y + 1][x], map[y - 1][x], map[y][x + 1], map[y][x - 1] };
                        if (!map[y + 1][x].IsWall)
                        {
                            var location = map[y + 1][x];
                            var portalName = string.Format("{0}{1}", input[y - 1][x], character);
                            location.HasPortal = true;
                            location.PortalName = portalName;
                        }
                        else if (!map[y - 1][x].IsWall)
                        {
                            var location = map[y - 1][x];
                            var portalName = string.Format("{0}{1}", character, input[y + 1][x]);
                            location.HasPortal = true;
                            location.PortalName = portalName;
                        }
                        else if (!map[y][x + 1].IsWall)
                        {
                            var location = map[y][x + 1];
                            var portalName = string.Format("{0}{1}", input[y][x - 1], character);
                            location.HasPortal = true;
                            location.PortalName = portalName;
                        }
                        else if (!map[y][x - 1].IsWall)
                        {
                            var location = map[y][x - 1];
                            var portalName = string.Format("{0}{1}", character, input[y][x + 1]);
                            location.HasPortal = true;
                            location.PortalName = portalName;
                        }
                    }
                }
            }

            // Determine if portals are innies or outies.
            var portals = map.SelectMany(location => location.Where(loc => loc.HasPortal)).ToList();
            foreach (var portal in portals)
            {
                if (portal.y == 2 || portal.y == height - 3 || portal.x == 2 || portal.x == width - 3)
                {
                    portal.PortalDepthModifier = -1;
                }
                else
                {
                    portal.PortalDepthModifier = 1;
                }

                if (portal.PortalName == startPortal)
                {
                    portal.IsStart = true;
                }
                if (portal.PortalName == endPortal)
                {
                    portal.IsEnd = true;
                }
            }

            return map;
        }

        private static MinStepsResult FindOptimumPath(string inputPath, string startPortal, string endPortal)
        {
            var map = GenerateMap(inputPath, startPortal, endPortal);
            ConstructDeadEnds(map);
            // DrawMap(map);
            var startLoc = map.SelectMany(loc => loc.Where(location => location.IsStart)).Single();
            var endLoc = map.SelectMany(loc => loc.Where(location => location.IsEnd)).Single();
            var minSteps = GetMinSteps(map, 0, new Dictionary<int, Dictionary<int, int>>(), startLoc, endLoc);
            return minSteps;
        }

        private static MinStepsResult FindOptimumPathWithDepth(string inputPath, string startPortal, string endPortal)
        {
            var map = GenerateMap(inputPath, startPortal, endPortal);
            ConstructDeadEnds(map);
            DrawMap(map);
            var startLoc = map.SelectMany(loc => loc.Where(location => location.IsStart)).Single();
            var endLoc = map.SelectMany(loc => loc.Where(location => location.IsEnd)).Single();
            var locationCache = new List<Dictionary<int, Dictionary<int, int>>>();
            var portals = map.SelectMany(loc => loc.Where(location => location.HasPortal)).ToList();
            int maxDepth = 2;
            var result = new MinStepsResult { Success = false };
            while(!result.Success)
            {
                result = GetMinStepsWithDepth(map, 0, locationCache, startLoc, endLoc, 0,  maxDepth);
                maxDepth += 5;
            } 
            return result;
        }

        private static void Run()
        {
            Console.WriteLine("Test1: " + FindOptimumPath("../../test1.txt", "AA", "ZZ").Steps);
            Console.WriteLine("Test2: " + FindOptimumPath("../../test2.txt", "AA", "ZZ").Steps);
            Console.WriteLine("Test3: " + FindOptimumPathWithDepth("../../test3.txt", "AA", "ZZ").Steps);
            Console.WriteLine("PART1: " + FindOptimumPath("../../input.txt", "AA", "ZZ").Steps);
            Console.WriteLine("PART2: " + FindOptimumPathWithDepth("../../input.txt", "AA", "ZZ").Steps);
            Console.ReadKey();
        }

        static void Main(string[] args)
        {
            // Because of the lazy recursive search implementation, increase stack size.
            var thread = new Thread(Run, 0x8000000);
            thread.Start();
            thread.Join();
        }

    }
}
