#!/usr/bin/env lua

function ParseInput()
  local board = {}
  for line in io.lines() do
    local row = {}
    for char in string.gmatch(line, ".") do
      table.insert(row, char)
    end
    table.insert(board, row)
  end
  return board
end

function XmasCnt(board)
  local DIRECTIONS = {{0,1}, {0,-1}, {1,0}, {-1,0}, {1,1}, {-1,-1}, {-1,1}, {1,-1}}
  local NEEDLE = {"X", "M", "A", "S"}
  local rows, cols = #board, #board[1]
  local count = 0
  for r = 1, rows, 1 do
    for c = 1, cols, 1 do
      if board[r][c] ~= "X" then
        goto next_c
      end
      for d = 1, #DIRECTIONS, 1 do
        local x, y = DIRECTIONS[d][1], DIRECTIONS[d][2]
        local found = true
        local dr, dc = r, c
        for i = 2, 4, 1 do
          dr, dc = dr + x, dc + y
          if (dr < 1 or dr > rows or dc < 1 or dc > cols or
              board[dr][dc] ~= NEEDLE[i]) then
            found = false
            break
          end
        end
        if found then count = count + 1 end
      end
      ::next_c::
    end
  end
  return count
end

function X_masCnt(board)
  local OFFSETS = {{0,0}, {0,2}, {1,1}, {2,0}, {2,2}}
  local rows, cols = #board, #board[1]
  local count = 0
  for r = 1, rows-2, 1 do
    for c = 1, cols-2, 1 do
      local found = board[r][c]
      if found ~= "M" and found ~= "S" then
        goto next_c
      end
      for o = 2, #OFFSETS, 1 do
        local dx, dy = OFFSETS[o][1], OFFSETS[o][2]
        found = found .. board[r+dx][c+dy]
      end
      if found == "MSAMS" or found == "SMASM" or found == "SSAMM" or found == "MMASS" then
        count = count + 1
      end
      ::next_c::
    end
  end
  return count
end

function Main()
  local board = ParseInput()
  print("Part1:", XmasCnt(board))
  print("Part2:", X_masCnt(board))
end

-- time cat 2024/input/04.txt | ./2024/04.lua
-- Part1:  2297
-- Part2:  1745
Main()