#!/usr/bin/env lua

require("2024.utils")

function ParseInput()
  local nums = {}
  while true do
    local a = io.read("*n")
    if a == nil then
      break
    end
    nums[tostring(a)] = 1
  end
  return nums
end

function ApplyRule(num)
  if num == "0" then
    return "1"
  end
  local digits = #num
  if digits % 2 == 0 then
    local first_half = string.sub(num, 1, digits/2)
    local second_half = tostring(tonumber(string.sub(num, (digits/2)+1)))
    return first_half, second_half
  else
    return tostring(tonumber(num)*2024)
  end
end

function Blink(nums, times)
  local ping, pong = table.deep_copy(nums), {}
  for _ = 1, times do
    for num, cnt in pairs(ping) do
      local a, b = ApplyRule(num)
      pong[a] = (pong[a] or 0) + cnt
      if b ~= nil then
        pong[b] = (pong[b] or 0) + cnt
      end
      ping[num] = nil
    end
    -- ping will be empty so pong will use it 
    -- for next iteration to avoid memory allocation
    ping, pong = pong, ping
  end
  local sum = 0
  for _, cnt in pairs(ping) do
    sum = sum + cnt
  end
  return sum
end

function Main()
  local nums = ParseInput()
  print("Part1:", Blink(nums, 25))
  print("Part2:", Blink(nums, 75))
end

-- time cat 2024/input/11.txt | ./2024/11.lua
-- Part1:  198075
-- Part2:  235571309320764
Main()