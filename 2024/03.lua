#!/usr/bin/env lua

function MultSum(instructions)
  local sum = 0
  for x, y in string.gmatch(instructions, "mul%((%d+),(%d+)%)") do
    sum = sum + (tonumber(x) * tonumber(y))
  end
  return sum
end

function DoMultSum(instructions)
  local i, sum, enabled = 1, 0, true
  while i <= #instructions do
    if (string.sub(instructions, i, i+3) == "do()") then
      enabled = true
      i = i + 3
    elseif (string.sub(instructions, i, i+6) == "don't()") then
      enabled = false
      i = i + 6
    elseif (string.sub(instructions, i, i+3) == "mul(") then
      local s, e, x, y = string.find(instructions, "mul%((%d+),(%d+)%)", i)
      if s == i then
        if (enabled) then
          sum = sum + (tonumber(x) * tonumber(y))
        end
        assert(e, "e can't be nil")
        i = e
      end
    end
    i = i + 1
  end
  return sum
end

function Main()
  local instructions = io.read("*a")
  print("Part1:", MultSum(instructions))
  print("Part2:", DoMultSum(instructions))
end

-- time cat 2024/input/03.txt | ./2024/03.lua
-- Part1:  164730528
-- Part2:  70478672
Main()