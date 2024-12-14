#!/usr/bin/env lua

require("2024.utils")

function ParseInput()
  local configs = { }
  while true do
    local ax, ay = string.match(io.read("*l") or "", "Button A%: X%+(%d+), Y%+(%d+)")
    if not ax then break end
    local bx, by = string.match(io.read("*l"), "Button B%: X%+(%d+), Y%+(%d+)")
    local  x,  y = string.match(io.read("*l"), "Prize%: X%=(%d+), Y%=(%d+)")
    local _ = io.read("*l")
    table.insert(configs, {ax=tonumber(ax), ay=tonumber(ay), bx=tonumber(bx), by=tonumber(by), x=tonumber(x), y=tonumber(y)})
  end
  return configs
end

function MinimumTokens(config)
  local na = ((config.x * config.by) - (config.y * config.bx)) /
             ((config.ax * config.by) - (config.ay * config.bx))
  local nb = (config.x - na * config.ax) / config.bx
  na = math.floor(na)
  nb = math.floor(nb)
  local x, y = na * config.ax + nb * config.bx, na * config.ay + nb * config.by
  return (x == config.x and y == config.y) and (3 * na + nb) or 0
end

function Silver(configs)
  local tokens = 0
  for _, config in ipairs(configs) do
    tokens = tokens + MinimumTokens(config)
  end
  return tokens
end

PRIZE_BUMP = 10000000000000

function Gold(configs)
  local tokens = 0
  for _, config in ipairs(configs) do
    config.x = config.x + PRIZE_BUMP
    config.y = config.y + PRIZE_BUMP
    tokens = tokens + MinimumTokens(config)
  end
  return tokens
end

function Main()
  local configs = ParseInput()
  print("Part1:", Silver(configs))
  print("Part2:", Gold(configs))
end

-- time cat 2024/input/13.txt | ./2024/13.lua
-- Part1:  36954
-- Part2:  79352015273424
Main()