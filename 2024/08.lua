#!/usr/bin/env lua

function ParseInput()
  local antenna_graph = {}
  local r, c = 1, 1
  for line in io.lines() do
    c = 1
    for char in string.gmatch(line, ".") do
      if char ~= "." then
        if not antenna_graph[char] then antenna_graph[char] = {} end
        table.insert(antenna_graph[char], {r, c})
      end
      c = c + 1
    end
    r = r + 1
  end
  return antenna_graph, r-1, c-1
end

function InBounds(rows, cols, x, y)
  return x > 0 and y > 0 and x <= rows and y <= cols
end

function AssociatedTblLength(tbl)
  local count = 0
  for _ in pairs(tbl) do
    count = count + 1
  end
  return count
end

function AntiNodeCount(antenna_graph, rows, cols)
  local antinodes = {}
  for _, coords in pairs(antenna_graph) do
    for i = 1, #coords - 1 do
      local x, y = coords[i][1], coords[i][2] -- Antenna1
      for j = i+1, #coords do
        local xx, yy = coords[j][1], coords[j][2] -- Antenna2
        local dx, dy = xx - x, yy - y -- distance (Antenna2 - Antenna2)
        local ax, ay = x - dx, y - dy -- AntiNode1
        local aax, aay = xx + dx, yy + dy -- AntiNode2
        if InBounds(rows, cols, ax, ay) then
          antinodes[(ax*cols)+ay] = true
        end
        if InBounds(rows, cols, aax, aay) then
          antinodes[(aax*cols)+aay] = true
        end
      end
    end
  end
  return AssociatedTblLength(antinodes)
end

function AntiNodeCountWithResonantHarmonics(antenna_graph, rows, cols)
  local antinodes = {}
  for _, coords in pairs(antenna_graph) do
    for i = 1, #coords - 1 do
      local x, y = coords[i][1], coords[i][2] -- Antenna1
      for j = i+1, #coords do
        local xx, yy = coords[j][1], coords[j][2] -- Antenna2
        local dx, dy = xx - x, yy - y -- distance (Antenna2 - Antenna2)
        local ax, ay, aax, aay = x, y, xx, yy
        while InBounds(rows, cols, ax, ay) do
          antinodes[(ax*cols)+ay] = true
          ax, ay = ax - dx, ay - dy -- AntiNode1
        end
        while InBounds(rows, cols, aax, aay) do
          antinodes[(aax*cols)+aay] = true
          aax, aay = aax + dx, aay + dy -- AntiNode2
        end
      end
    end
  end
  return AssociatedTblLength(antinodes)
end

function Main()
  local antenna_graph, rows, cols = ParseInput()
  print("Part1:", AntiNodeCount(antenna_graph, rows, cols))
  print("Part2:", AntiNodeCountWithResonantHarmonics(antenna_graph, rows, cols))
end

-- time cat 2024/input/08.txt | ./2024/08.lua
-- Part1:  273
-- Part2:  1017
Main()