#!/usr/bin/env lua

function ParseInput()
  local secret_nums = { }
  for line in io.lines() do
    table.insert(secret_nums, tonumber(line))
  end
  return secret_nums
end

function Evolve(num)
  num = ((num *   64) ~ num) % 16777216
  num = ((num //  32) ~ num) % 16777216
  num = ((num * 2048) ~ num) % 16777216
  return num
end

function SumNSecretNums(secret_nums, n)
  local sum = 0
  for _, secret_num in ipairs(secret_nums) do
    for _ = 1, n do
      secret_num = Evolve(secret_num)
    end
    sum = sum + secret_num
  end
  return sum
end

function UniqueId(seq)
  local key = 0
  for _, val in ipairs(seq) do
    key = key * 11 + (val + 10) -- Shift by 10 and interpret as base-11
  end
  return key
end

function MaximizeBananas(secret_nums, n)
  local seq_to_total = { }
  for _, secret_num in ipairs(secret_nums) do
    local prev = secret_num % 10
    local seq = { 0 }
    local seen = { }
    local next
    for _ = 1, 4 do
      secret_num = Evolve(secret_num)
      next = secret_num % 10
      table.insert(seq, next - prev)
      prev = next
    end
    for _ = 5, n do
      table.remove(seq, 1)
      local key = UniqueId(seq)
      if not seen[key] then
        seen[key] = true
        seq_to_total[key] = (seq_to_total[key] or 0) + prev
      end
      secret_num = Evolve(secret_num)
      next = secret_num % 10
      table.insert(seq, next - prev)
      prev = next
    end
  end

  local max = 0
  for _, total in pairs(seq_to_total) do
    max = math.max(max, total)
  end

  return max
end

function Main()
  local secret_nums = ParseInput()
  print("Part1:", SumNSecretNums(secret_nums, 2000))
  print("Part2:", MaximizeBananas(secret_nums, 2000))
end

-- time cat 2024/input/22.txt | ./2024/22.lua
-- Part1:  16299144133
-- Part2:  1896
Main()