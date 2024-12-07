#!/usr/bin/env lua

function ParseInput()
  local board = {}
  local guardPos = {r=0, c=0}
  local r = 1
  for line in io.lines() do
    local row = {}
    local c = 1
    for char in string.gmatch(line, ".") do
      if char == "^" then
        guardPos.r = r
        guardPos.c = c
      end
      table.insert(row, char)
      c = c + 1
    end
    table.insert(board, row)
    r = r + 1
  end
  return board, guardPos
end

function DistinctPosCnt(board, guardPos)
  local r, c = guardPos.r, guardPos.c
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

function IsObstacleOnRight(obstacles, r, c, dr, dc)
  dr, dc = dc, -dr -- turning right
  for o = 1, #obstacles do
    local obstacle, direction = table.unpack(obstacles[o])
    local y, x = obstacle[1], obstacle[2]
    local m, n = direction[1], direction[2]
    -- making sure we hit the same obstacle from the same direction
    if not (dr == m and dc == n) then goto next_obstacle end
    if dr == 0 then
      if y == r and ((x - c) * dc) > 0 then
        return true
      end
    elseif dc == 0 then
      if x == c and ((y - r) * dr) > 0 then
        return true
      end
    end
    ::next_obstacle::
  end
  return false
end

function GhostObstacleCnt(board, guardPos)
  local r, c = guardPos.r, guardPos.c
  local dr, dc = -1, 0
  local newObsCnt = 0
  local obstacles = {}
  local obsCnt = 0
  repeat
    if board[r][c] == "#" then
      table.insert(obstacles, {{r, c}, {dr, dc}})
      obsCnt = obsCnt + 1
      r, c = r - dr, c - dc
      -- turn 90 degree
      dr, dc = dc, -dr
    end
    local nr, nc = r+dr, c+dc
    if obsCnt > 2 and
       not (nr == guardPos.r and nc == guardPos.c) and
       not (nr < 1 or nr > #board or nc < 1 or nc > #board[1]) and
       board[nr][nc] ~= "#" and
       IsObstacleOnRight(obstacles, r, c, dr, dc) then
      newObsCnt = newObsCnt + 1
    end
    r, c = r + dr, c + dc
  until r < 1 or r > #board or c < 1 or c > #board[1]
  return newObsCnt
end

function Main()
  local board, guardPos = ParseInput()
  print("Part1:", DistinctPosCnt(board, guardPos))
  -- part2 doesn't work and I don't care
  print("Part2:", GhostObstacleCnt(board, guardPos))
end

-- time cat 2024/input/06.txt | ./2024/06.lua
-- Part1:  4789
-- Part2:  
Main()