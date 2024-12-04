#!/usr/bin/env lua

function ParseInput()
  local as = {}
  local bs = {}
  while true do
    local a, b = io.read("*n", "*n")
    if a == nil or b == nil then
      break
    end
    table.insert(as, a)
    table.insert(bs, b)
  end
  return as, bs
end

function TotalDistance(left, right)
  table.sort(left)
  table.sort(right)
  local diff = 0
  for i = 1, #left, 1 do
    diff = diff + math.abs(left[i] - right[i])
  end
  return diff
end

function Frequencies(list)
  local freqTbl = {}
  for i = 1, #list, 1 do
    local ele = list[i]
    freqTbl[ele] = (freqTbl[ele] or 0) + 1
  end
  return freqTbl
end

function SimilarityScore(left, right)
  local freqs = Frequencies(right)
  local score = 0
  for i = 1, #left, 1 do
    local num = left[i]
    score = score + (num * (freqs[num] or 0))
  end
  return score
end

function Main()
  local left, right = ParseInput()
  print("Part1:", TotalDistance(left, right))
  print("Part2:", SimilarityScore(left, right))
end

-- time cat 2024/input/01.txt | ./2024/01.lua
-- Part1:  2057374
-- Part2:  23177084
Main()