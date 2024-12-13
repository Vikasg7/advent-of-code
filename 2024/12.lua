#!/usr/bin/env lua

require("2024.utils")

function ParseInput()
  local garden = {}
  for line in io.lines() do
    local row = {}
    for char in string.gmatch(line, ".") do
      table.insert(row, char)
    end
    table.insert(garden, row)
  end
  return garden
end

function InBounds(rows, cols, x, y)
  return x > 0 and y > 0 and x <= rows and y <= cols
end

function AddNeighbors(garden, queue, plot)
  for _, offset in ipairs(DIRECTIONS) do
    local adj_plot = {r=plot.r + offset[1], c=plot.c + offset[2]}
    if InBounds(#garden, #garden[1], adj_plot.r, adj_plot.c) and
       garden[plot.r][plot.c] == garden[adj_plot.r][adj_plot.c] then
      table.insert(queue, adj_plot)
    end
  end
end

function CalcPerimeter(garden, plot)
  local perimeter = 0
  for _, offset in ipairs(DIRECTIONS) do
    local adj_plot = {r=plot.r + offset[1], c=plot.c + offset[2]}
    if not InBounds(#garden, #garden[1], adj_plot.r, adj_plot.c) or
       garden[plot.r][plot.c] ~= garden[adj_plot.r][adj_plot.c] then
      perimeter = perimeter + 1
    end
  end
  return perimeter
end

function GetRegion(garden, queue, visited, plot)
  local region = {}
  table.insert(queue, plot)
  while #queue > 0 do
    plot = table.remove(queue, 1)
    local key = string.format("%d-%d", plot.r, plot.c)
    if visited[key] then
      goto next_plot
    end
    table.insert(region, plot)
    visited[key] = true
    AddNeighbors(garden, queue, plot)
    ::next_plot::
  end
  return region
end

function CalcSides(garden, plot)
  local plot_type = garden[plot.r][plot.c]
  local L, R, T, B, TL, TR, BL, BR
  L =  InBounds(#garden, #garden[1], plot.r  , plot.c-1 ) and garden[plot.r  ][plot.c-1] == plot_type
  R =  InBounds(#garden, #garden[1], plot.r  , plot.c+1 ) and garden[plot.r  ][plot.c+1] == plot_type
  T =  InBounds(#garden, #garden[1], plot.r-1, plot.c   ) and garden[plot.r-1][plot.c  ] == plot_type
  B =  InBounds(#garden, #garden[1], plot.r+1, plot.c   ) and garden[plot.r+1][plot.c  ] == plot_type
  TL = InBounds(#garden, #garden[1], plot.r-1, plot.c-1 ) and garden[plot.r-1][plot.c-1] == plot_type
  TR = InBounds(#garden, #garden[1], plot.r-1, plot.c+1 ) and garden[plot.r-1][plot.c+1] == plot_type
  BL = InBounds(#garden, #garden[1], plot.r+1, plot.c-1 ) and garden[plot.r+1][plot.c-1] == plot_type
  BR = InBounds(#garden, #garden[1], plot.r+1, plot.c+1 ) and garden[plot.r+1][plot.c+1] == plot_type

  local external_edges =
    ((not L and not TL and not T) and 1 or 0) +
    ((not L and not BL and not B) and 1 or 0) +
    ((not R and not TR and not T) and 1 or 0) +
    ((not R and not BR and not B) and 1 or 0)

  local internal_edges =
    ((T and R and not TR) and 1 or 0) +
    ((B and R and not BR) and 1 or 0) +
    ((B and L and not BL) and 1 or 0) +
    ((T and L and not TL) and 1 or 0)

  local diagonal_edges =
    ((not T and not R and TR) and 1 or 0) +
    ((not B and not R and BR) and 1 or 0) +
    ((not B and not L and BL) and 1 or 0) +
    ((not T and not L and TL) and 1 or 0)

  return external_edges + internal_edges + diagonal_edges
end

DIRECTIONS = {{1,0}, {0,1}, {0,-1}, {-1,0}}

function FenceCost(garden, calc_perimeter)
  local visited, queue = {}, {}
  local total_cost = 0
  for r = 1, #garden do
    for c = 1, #garden[1] do
      local region = GetRegion(garden, queue, visited, {r=r, c=c})
      local area, perimeter = #region, 0
      for _, plot in ipairs(region) do
        perimeter = perimeter + calc_perimeter(garden, plot)
      end
      total_cost = total_cost + (area * perimeter)
    end
  end
  return total_cost
end

function Main()
  local garden = ParseInput()
  print("Part1:", FenceCost(garden, CalcPerimeter))
  print("Part2:", FenceCost(garden, CalcSides))
end

-- time cat 2024/input/12.txt | ./2024/12.lua
-- Part1:  1434856
-- Part2:  891106
Main()