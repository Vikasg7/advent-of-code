#!/usr/bin/env lua

require("2024.utils")

function ParseInput()
  local rulesTxt, updatesTxt = string.match(io.read("*a"), "(.+)\n\n(.+)")
  local afters, befores = {}, {}
  for x, y in string.gmatch(rulesTxt, "(%d+)|(%d+)") do
    afters[x] = afters[x] or {}
    befores[y] = befores[y] or {}
    table.insert(afters[x], y)
    table.insert(befores[y], x)
  end

  local updates = {}
  for updateTxt in string.gmatch(updatesTxt, "[^\r\n]+") do
    local update = {}
    for page in string.gmatch(updateTxt, "(%d+)") do
      table.insert(update, page)
    end
    table.insert(updates, update)
  end
  return afters, befores, updates
end

function IsValidUpdate(afters, befores, update)
  for p = 1, #update do
    local page = update[p]
    local as, bs = afters[page] or {}, befores[page] or {}
    -- check if pages before p exists in after(as) list 
    for b = 1, p-1 do
      if table.contains(as, update[b]) then return false end
    end
    -- check if pages after p exists in before(bs) list
    for a = p+1, #update do
      if table.contains(bs, update[a]) then return false end
    end
  end
  return true
end

function RightOrderUpdatesSum(afters, befores, updates)
  local sum, wrongUpdates = 0, {}
  for u = 1, #updates do
    local update = updates[u]
    if not IsValidUpdate(afters, befores, update) then
      table.insert(wrongUpdates, update)
      goto next_update
    end
    sum = sum + tonumber(update[math.ceil(#update/2)])
    ::next_update::
  end
  return sum, wrongUpdates
end

function WrongUpdatesSum(afters, updates)
  local sum = 0
  for u = 1, #updates do
    local update = updates[u]
    table.sort(update, function (a, b)
      return table.contains(afters[a] or {}, b)
    end)
    sum = sum + tonumber(update[math.ceil(#update/2)])
  end
  return sum
end

function Main()
  local afters, befores, updates = ParseInput()
  local rightOrderUpdatesSum, wrongUpdates = RightOrderUpdatesSum(afters, befores, updates)
  print("Part1:", rightOrderUpdatesSum)
  print("Part2:", WrongUpdatesSum(afters, wrongUpdates))
end

-- time cat 2024/input/05.txt | ./2024/05.lua
-- Part1:  6612
-- Part2:  4944
Main()