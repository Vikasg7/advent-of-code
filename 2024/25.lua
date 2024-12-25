#!/usr/bin/env lua

function ParseInput()
  local locks, keys = { }, { }
  local grid = { }

  for line in io.lines() do
    if line == "" then
      local target = grid[1][1] == 1 and locks or keys
      table.insert(target, GetHeights(grid))
      grid = { }
      goto next_line
    end
    local row = { }
    for char in string.gmatch(line, ".") do
      table.insert(row, char == "#" and 1 or 0)
    end
    table.insert(grid, row)
    ::next_line::
  end

  local target = grid[1][1] == 1 and locks or keys
  table.insert(target, GetHeights(grid))

  return locks, keys
end

function GetHeights(grid)
  local heights = { }
  for c = 1, #grid[1] do
    local height = 0
    for r = 1, #grid do
      height = height + grid[r][c]
    end
    table.insert(heights, height)
  end
  return heights
end

function CanFit(key, lock)
  assert(#key == #lock)
  for i = 1, #key do
    if key[i] + lock[i] > 7 then
      return false
    end
  end
  return true
end

function PairCount(locks, keys)
  local count = 0
  for _, lock in ipairs(locks) do
    for _, key in ipairs(keys) do
      if CanFit(key, lock) then
        count = count + 1
      end
    end
  end
  return count
end

function Main()
  local locks, keys = ParseInput()
  print("Part1:", PairCount(locks, keys))
  -- print("Part2:", FindPassword(network_map))
end

-- time cat 2024/input/25.txt | ./2024/25.lua
-- Part1:  3356
-- Part2:  
Main()