#!/usr/bin/env lua

function ParseInput()
  local patterns, designs, pattern_maxlen = { }, { }, 0

  for pattern in string.gmatch(io.read("*l") .. ", ", "(%S+), ") do
    pattern_maxlen = math.max(#pattern, pattern_maxlen)
    patterns[pattern] = true
  end

  local _ = io.read("*l")

  for design in io.lines() do
    table.insert(designs, design)
  end

  return patterns, designs, pattern_maxlen
end

function Memoize(fn)
  local cache = { }

  return function (key, ...)
    if cache[key] ~= nil then
      return cache[key]
    end

    local val = fn(key, ...)
    cache[key] = val
    return val
  end
end

Is_Possible = Memoize(function (design, patterns, pattern_maxlen)
  if design == "" then
    return true
  end

  for i = 1, math.min(#design, pattern_maxlen) do
    local head = string.sub(design, 1, i)
    local tail = string.sub(design, i + 1)

    if patterns[head] and Is_Possible(tail, patterns, pattern_maxlen) then
      return true
    end
  end

  return false
end)

function PossibleDesigns(patterns, pattern_maxlen, designs)
  local count = 0

  for _, design in ipairs(designs) do
    if Is_Possible(design, patterns, pattern_maxlen) then
      count =  count + 1
    end
  end

  return count
end

Ways = Memoize(function (design, patterns, pattern_maxlen)
  if design == "" then
    return 1
  end

  local count = 0
  for i = 1, math.min(#design, pattern_maxlen) do
    local head = string.sub(design, 1, i)
    local tail = string.sub(design, i + 1)

    if patterns[head] then
      count = count + Ways(tail, patterns, pattern_maxlen)
    end
  end

  return count
end)

function PossibleWays(patterns, pattern_maxlen, designs)
  local count = 0

  for _, design in ipairs(designs) do
    count =  count + Ways(design, patterns, pattern_maxlen)
  end

  return count
end

function Main()
  local patterns, designs, pattern_maxlen = ParseInput()
  print("Part1:", PossibleDesigns(patterns, pattern_maxlen, designs))
  print("Part2:", PossibleWays(patterns, pattern_maxlen, designs))
end

-- time cat 2024/input/19.txt | ./2024/19.lua
-- Part1:  365
-- Part2:  730121486795169
Main()