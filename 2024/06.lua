#!/usr/bin/env lua

function ParseInput()
  local board = {}
  local guard_pos = {r=0, c=0}
  local r = 1
  for line in io.lines() do
    local row = {}
    local s = string.find(line, "%^")
    if s then
      guard_pos.r = r
      guard_pos.c = s
    end
    for char in string.gmatch(line, ".") do
      table.insert(row, char)
    end
    table.insert(board, row)
    r = r + 1
  end
  return board, guard_pos
end

function DistinctPosCnt(board, guard_pos)
  local r, c = guard_pos.r, guard_pos.c
  local dr, dc = -1, 0
  local count = 1
  repeat
    if board[r][c] == "." then
      count = count + 1
      board[r][c] = "X"
    elseif board[r][c] == "#" then
      r, c = r - dr, c - dc
      -- turn 90 degree
      dr, dc = dc, -dr
    end
    r, c = r + dr, c + dc
  until r < 1 or r > #board or c < 1 or c > #board[1]
  return count
end

function DetectLoops(board, guard_pos, marker)
  local r, c = guard_pos.r, guard_pos.c
  local dr, dc = -1, 0
  repeat
    local marker_with_direction = string.format("%s-%d-%d", marker, dr, dc)
    if board[r][c] == marker_with_direction then
      return true
    end
    if board[r][c] == "#" then
      r, c = r - dr, c - dc
      -- turn 90 degree
      dr, dc = dc, -dr
    else
      board[r][c] = marker_with_direction
    end
    r, c = r + dr, c + dc
  until r < 1 or r > #board or c < 1 or c > #board[1]
  return false
end

function GhostObstacleCnt(board, guard_pos)
  local count = 0
  for r = 1, #board do
    for c = 1, #board[1] do
      if (r == guard_pos.r and c == guard_pos.c) or
         board[r][c] == "#" then -- ignoring already marked obstacles
        goto next_pos
      end

      board[r][c] = "#"

      if DetectLoops(board, guard_pos, string.format("%d-%d", r, c)) then
        count = count + 1
      end

      board[r][c] = "."

      ::next_pos::
    end
  end
  return count
end

function Main()
  local board, guard_pos = ParseInput()
  print("Part1:", DistinctPosCnt(board, guard_pos))
  print("Part2:", GhostObstacleCnt(board, guard_pos))
end

-- time cat 2024/input/06.txt | ./2024/06.lua
-- Part1:  4789
-- Part2:  1304
Main()