#!/usr/bin/env lua

require("2024.utils")

function ParseInput()
  local wire_values = { }
  for line in io.lines() do
    if line == "" then break end
    local wire, value = string.match(line, "(%S+): (%d)")
    wire_values[wire] = tonumber(value)
  end

  local operations, formulas = { }, { }
  for line in io.lines() do
    local wl, op, wr, wo = string.match(line, "(%S+) (%S+) (%S+) %-%> (%S+)")
    local fn = op == "AND" and AND or
               op == "OR"  and OR  or
               op == "XOR" and XOR or
               nil
    assert(fn ~= nil)
    table.insert(operations, {wl=wl, fn=fn, wr=wr, wo=wo})
    formulas[wo] = {op, wl, wr}
  end

  return wire_values, operations, formulas
end

AND = function (x, y) return x & y end
OR  = function (x, y) return x | y end
XOR = function (x, y) return x ~ y end

function Execute(wire_values, operation)
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
    if not Execute(wire_values, operation) then
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

function VerifyZ(formulas, wire, num)
  if not formulas[wire] then return false end
  local op, x, y = table.unpack(formulas[wire])
  if op ~= "XOR" then return false end
  if num == 0 then
    return (x == "x00" and y == "y00") or
           (x == "y00" and y == "x00")
  end
  return (VerifyIntermediateXOR(formulas, x, num) and VerifyCarryBit(formulas, y, num)) or
         (VerifyIntermediateXOR(formulas, y, num) and VerifyCarryBit(formulas, x, num))
end

function VerifyIntermediateXOR(formulas, wire, num)
  if not formulas[wire] then return false end
  local op, x, y = table.unpack(formulas[wire])
  if op ~= "XOR" then return false end
  local xwire, ywire = MakeWire("x", num), MakeWire("y", num)
  return (x == xwire and y == ywire) or
         (x == ywire and y == xwire)
end

function VerifyCarryBit(formulas, wire, num)
  if not formulas[wire] then return false end
  local op, x, y = table.unpack(formulas[wire])
  if num == 1 then
    if op ~= "AND" then return false end
    return (x == "x00" and y == "y00") or
           (x == "y00" and y == "x00")
  end
  if op ~= "OR" then return false end
  return (VerifyDirectCarry(formulas, x, num - 1) and VerifyRecarry(formulas, y, num - 1)) or
         (VerifyDirectCarry(formulas, y, num - 1) and VerifyRecarry(formulas, x, num - 1))
end

function VerifyDirectCarry(formulas, wire, num)
  if not formulas[wire] then return false end
  local op, x, y = table.unpack(formulas[wire])
  if op ~= "AND" then return false end
  local xwire, ywire = MakeWire("x", num), MakeWire("y", num)
  return (x == xwire and y == ywire) or
         (x == ywire and y == xwire)
end

function VerifyRecarry(formulas, wire, num)
  if not formulas[wire] then return false end
  local op, x, y = table.unpack(formulas[wire])
  if op ~= "AND" then return false end
  return (VerifyIntermediateXOR(formulas, x, num) and VerifyCarryBit(formulas, y, num)) or
         (VerifyIntermediateXOR(formulas, y, num) and VerifyCarryBit(formulas, x, num))
end

function MakeWire(char, num)
  return char..string.format("%02d", num)
end

function Verify(formulas, num)
  return VerifyZ(formulas, MakeWire("z", num), num)
end

function Progress(formulas, baseline)
  local i = baseline

  while true do
    if not Verify(formulas, i) then
      break
    end
    i = i + 1
  end

  return i
end

function FindSwaps(formulas)
  local baseline, swaps = 0, { }
  for _ = 1, 4 do
    baseline = Progress(formulas, baseline)
    for x in pairs(formulas) do
      for y in pairs(formulas) do
        if x == y then goto next_y end
        formulas[x], formulas[y] = formulas[y], formulas[x]
        local new_baseline = Progress(formulas, baseline)
        if new_baseline > baseline then
          baseline = new_baseline
          table.insert(swaps, x)
          table.insert(swaps, y)
          goto next_swap
        end
        formulas[x], formulas[y] = formulas[y], formulas[x]
        ::next_y::
      end
    end
    ::next_swap::
  end
  table.sort(swaps)
  return table.concat(swaps, ",")
end

function Main()
  local wire_values, operations, formulas = ParseInput()
  print("Part1:", ZDecimalOutput(wire_values, operations))
  print("Part2:", FindSwaps(formulas))
end

-- time cat 2024/input/24.txt | ./2024/24.lua
-- Part1:  57588078076750
-- Part2:  kcd,pfn,shj,tpk,wkb,z07,z23,z27
Main()