#!/usr/bin/env lua

DIRECTIONS = {
  ["<"]={dr= 0, dc=-1},
  [">"]={dr= 0, dc= 1},
  ["v"]={dr= 1, dc= 0},
  ["^"]={dr=-1, dc= 0}
}

function ParseInput()
  local board, moves = { }, { }
  local robot_pos
  local r = 1

  for line in io.lines() do
    if line == "" then break end
    local c = string.find(line, "%@")
    if c then
      robot_pos = {r=r, c=c}
    end
    local row = { }
    for char in string.gmatch(line, ".") do
      table.insert(row, char)
    end
    table.insert(board, row)
    r = r + 1
  end

  for line in io.lines() do
    for char in string.gmatch(line, ".") do
      table.insert(moves, DIRECTIONS[char])
    end
  end

  board[robot_pos.r][robot_pos.c] = "."

  return board, moves, robot_pos
end

function PrintBoard(board, robot_pos)
  board[robot_pos.r][robot_pos.c] = "@"
  for _, row in ipairs(board) do
    print(table.concat(row, ""))
  end
  board[robot_pos.r][robot_pos.c] = "."
  print("")
end

function SumGPSCoords(board, moves, robot_pos)
  for _, move in ipairs(moves) do
    local nr, nc = robot_pos.r + move.dr, robot_pos.c + move.dc
    if board[nr][nc] == "#" then
      goto next_move
    end

    if board[nr][nc] == "O" then
      local nnr, nnc = nr + move.dr, nc + move.dc
      while board[nnr][nnc] == "O" do
        nnr, nnc = nnr + move.dr, nnc + move.dc
      end
      if board[nnr][nnc] ~= "." then
        goto next_move
      end
      board[nr][nc] = "."
      board[nnr][nnc] = "O"
    end

    robot_pos.r, robot_pos.c = nr, nc

    ::next_move::
  end

  local sum = 0
  for r = 1, #board do
    for c = 1, #board[1] do
      if board[r][c] == "O" then
        sum = sum + (((r-1) * 100) + (c-1))
      end
    end
  end

  return sum
end

function ScaleUp(board, robot_pos)
  local scaled_board = { }
  for _,row in ipairs(board) do
    local scaled_row = { }
    for _,char in ipairs(row) do
      if char == "#" or char == "." then
        table.insert(scaled_row, char)
        table.insert(scaled_row, char)
      elseif char == "O" then
        table.insert(scaled_row, "[")
        table.insert(scaled_row, "]")
      end
    end
    table.insert(scaled_board, scaled_row)
  end
  local scaled_robot_pos = {r=robot_pos.r, c=(robot_pos.c*2)-1}
  return scaled_board, scaled_robot_pos
end

function SumGPSCoordsScaled(board, moves, robot_pos)
  local nr, nc, idx
  for _, move in ipairs(moves) do
    -- shortcuting early for performance boost
    nr, nc = robot_pos.r + move.dr, robot_pos.c + move.dc
    if board[nr][nc] == "#" then
      goto next_move
    end

    if board[nr][nc] == "." then
      robot_pos.r, robot_pos.c = nr, nc
      goto next_move
    end

    -- finding the movable boxes
    local q, seen, seen_cnt = {}, {}, 0
    table.insert(q, robot_pos)

    while #q > 0 do
      local pos = table.remove(q, 1)
      idx = (pos.r * #board[1]) + pos.c
      if seen[idx] then
        goto next_pos
      end
      seen[idx] = pos
      seen_cnt = seen_cnt + 1

      nr, nc = pos.r + move.dr, pos.c + move.dc
      if board[nr][nc] == "#" then
        goto next_move
      end

      if board[nr][nc] == "." then
        goto next_pos
      end

      if board[nr][nc] == "[" then
        table.insert(q, {r=nr, c=nc})
        table.insert(q, {r=nr, c=nc+1})
      end

      if board[nr][nc] == "]" then
        table.insert(q, {r=nr, c=nc})
        table.insert(q, {r=nr, c=nc-1})
      end
      ::next_pos::
    end

    -- moving the box
    while seen_cnt ~= 0 do
      for _, pos in pairs(seen) do
        nr, nc = pos.r + move.dr, pos.c + move.dc
        -- checking if new pos is not seen
        if not seen[(nr * #board[1]) + nc] then
          board[nr][nc], board[pos.r][pos.c] = board[pos.r][pos.c], board[nr][nc]
          -- removing the seen/moved pos
          seen[(pos.r * #board[1]) + pos.c] = nil
          seen_cnt = seen_cnt - 1
        end
      end
    end

    -- moving robot
    robot_pos.r, robot_pos.c = robot_pos.r + move.dr, robot_pos.c + move.dc

    ::next_move::
  end

  local sum = 0
  for r = 1, #board do
    for c = 1, #board[1] do
      if board[r][c] == "[" then
        sum = sum + (((r-1) * 100) + (c-1))
      end
    end
  end

  return sum
end

function Main()
  local board, moves, robot_pos = ParseInput()
  local scaled_board, scaled_robot_pos = ScaleUp(board, robot_pos)
  print("Part1:", SumGPSCoords(board, moves, robot_pos))
  print("Part2:", SumGPSCoordsScaled(scaled_board, moves, scaled_robot_pos))
end

-- time cat 2024/input/15.txt | ./2024/15.lua
-- Part1:  1446158
-- Part2:  1446175
Main()