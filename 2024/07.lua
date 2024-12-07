#!/usr/bin/env lua

function ParseInput()
  local equations = {}
  for line in io.lines() do
    local row = {}
    for char in string.gmatch(line, "[^: ]+") do
      table.insert(row, tonumber(char))
    end
    table.insert(equations, row)
  end
  return equations
end

function IsValidEquation(equation, ops, acc, i)
  if i > #equation then return acc == equation[1] end
  if acc > equation[1] then return false end
  for o = 1, #ops do
    local op = ops[o]
    if IsValidEquation(equation, ops, op(acc, equation[i]), i+1) then
      return true
    end
  end
  return false
end

ADD = function (x, y) return x + y end
MULT = function (x, y) return x * y end
CONCAT = function (x, y) return x * 10 ^ (math.floor(math.log(y, 10)) + 1) + y end

function TotalCalibrationResult(equations, ops)
  local sum = 0
  for e = 1, #equations do
    local equation = equations[e]
    if IsValidEquation(equation, ops, equation[2], 3) then
      sum = sum + equation[1]
    end
  end
  return sum
end

function Main()
  local equations = ParseInput()
  print("Part1:", TotalCalibrationResult(equations, {ADD, MULT}))
  print("Part2:", TotalCalibrationResult(equations, {ADD, MULT, CONCAT}))
end

-- time cat 2024/input/07.txt | ./2024/07.lua
-- Part1:  5030892084481
-- Part2:  91377448644679
Main()