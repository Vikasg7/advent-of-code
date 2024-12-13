#!/usr/bin/env lua

function ParseInput()
  local map = {}
  local trailheads = {}
  local r = 1
  for line in io.lines() do
    local c = 1
    local row = {}
    for char in string.gmatch(line, ".") do
      if char == "0" then
        table.insert(trailheads, {r=r, c=c})
      end
      table.insert(row, tonumber(char))
      c = c + 1
    end
    table.insert(map, row)
    r = r + 1
  end
  return map, trailheads
end

function InBounds(rows, cols, x, y)
  return x > 0 and y > 0 and x <= rows and y <= cols
end

DIRECTIONS = {{1,0}, {0,1}, {0,-1}, {-1,0}}

function GetNeighbors(map, neighbors, pos)
  local height = map[pos.r][pos.c]
  for _, offset in pairs(DIRECTIONS) do
    local r, c = pos.r + offset[1], pos.c + offset[2]
    if not InBounds(#map, #map[1], r, c) then
      goto next_direction
    end
    local neibor_height = map[r][c]
    if (neibor_height - height) == 1 then
      table.insert(neighbors, {r=r, c=c})
    end
    ::next_direction::
  end
end

function TrailheadScore(map, pos)
  local neighbors = {pos}
  local sum = 0
  local visited = {}
  while #neighbors ~= 0 do
    pos = table.remove(neighbors, 1)
    if map[pos.r][pos.c] == 9 then
      local key = string.format("%d-%d", pos.r, pos.c)
      if not visited[key] then
        sum = sum + 1
        visited[key] = true
      end
    end
    GetNeighbors(map, neighbors, pos)
  end
  return sum
end

function TrailheadRating(map, pos)
  local neighbors = {pos}
  local sum = 0
  while #neighbors ~= 0 do
    pos = table.remove(neighbors, 1)
    if map[pos.r][pos.c] == 9 then
      sum = sum + 1
    end
    GetNeighbors(map, neighbors, pos)
  end
  return sum
end

function MeasureTrailheads(map, trailheads, measure_fn)
  local sum = 0
  for _, trailhead in pairs(trailheads) do
    sum = sum + measure_fn(map, trailhead)
  end
  return sum
end

function Main()
  local map, trailheads = ParseInput()
  print("Part1:", MeasureTrailheads(map, trailheads, TrailheadScore))
  print("Part1:", MeasureTrailheads(map, trailheads, TrailheadRating))
end

-- time cat 2024/input/10.txt | ./2024/10.lua
-- Part1:  694
-- Part2:  1497
Main()