#!/usr/bin/env lua

require("2024.utils")

function ParseInput()
  local wire_values = { }
  for line in io.lines() do
    if line == "" then break end
    local wire, value = string.match(line, "(%S+): (%d)")
    wire_values[wire] = tonumber(value)
  end

  local operations = { }
  for line in io.lines() do
    local wl, op, wr, wo = string.match(line, "(%S+) (%S+) (%S+) %-%> (%S+)")
    local fn = op == "AND" and AND or
               op == "OR"  and OR  or
               op == "XOR" and XOR or
               nil
    table.insert(operations, {wl=wl, fn=fn, wr=wr, wo=wo})
  end

  return wire_values, operations
end

AND = function (x, y) return x & y end
OR  = function (x, y) return x | y end
XOR = function (x, y) return x ~ y end

function Perform(wire_values, operation)
  local wl, wr, wo = wire_values[operation.wl], wire_values[operation.wr], wire_values[operation.wo]
  if not wl or not wr or wo ~= nil then
    return false
  end
  wire_values[operation.wo] = operation.fn(wl, wr)
  return true
end

function Simulate(wire_values, operations)
  while #operations > 0 do
    local operation = table.remove(operations, 1)
    if not Perform(wire_values, operation) then
      table.insert(operations, operation)
    end
  end
end

function ZDecimalOutput(wire_values, operations)
  Simulate(wire_values, operations)
  local zs = { }
  for k, v in pairs(wire_values) do
    if string.find(k, "^z") then
      local i = tonumber(string.sub(k, 2))
      assert(i ~= nil)
      zs[i+1] = v
    end
  end
  table.reverse(zs)
  local zbin = table.concat(zs)
  return tonumber(zbin, 2)
end

function Main()
  local wire_values, operations = ParseInput()
  local wire_values_copy, operations_copy = table.deep_copy(wire_values), table.deep_copy(operations)
  print("Part1:", ZDecimalOutput(wire_values, operations))
  -- print("Part2:", FindPassword(network_map))
end

-- time cat 2024/input/24.txt | ./2024/24.lua
-- Part1:  57588078076750
-- Part2:  
Main()