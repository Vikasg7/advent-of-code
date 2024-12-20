#!/usr/bin/env lua

DIRECTIONS = {
  {dr= 0, dc=-1},
  {dr= 0, dc= 1},
  {dr= 1, dc= 0},
  {dr=-1, dc= 0}
}

function ParseInput()
  local bytes = { }

  for line in io.lines() do
    local c, r = string.match(line, "(%d+),(%d+)")
    table.insert(bytes, {r=tonumber(r)+1, c=tonumber(c)+1})
  end

  return bytes
end

function PrintBoard(board, path, start_pos, end_pos)
  for _, node in pairs(path) do
    board[node.r][node.c] = "*"
  end

  board[start_pos.r][start_pos.c] = "S"
  board[end_pos.r][end_pos.c] = "E"

  for _, row in pairs(board) do
    print(table.concat(row, ""))
  end

  print("")
end

function TracePath(meta, curr, start_pos)
  local path = { curr }
  while not (curr.r == start_pos.r and curr.c == start_pos.c) do
    curr = meta[curr.k].prev
    table.insert(path, curr)
  end
  return path
end

function AbsPos(cols, pos)
  return ((pos.r - 1) * cols) + pos.c
end

function Coords(cols, absPos)
  local r = math.floor((absPos - 1) / cols)
  local c = (absPos - 1) % cols
  return r+1, c+1
end

function InBounds(rows, cols, x, y)
  return x > 0 and y > 0 and x <= rows and y <= cols
end

function MinSteps(size, bytes, start_pos, end_pos, n)
  local rows, cols = size, size

  local corruptions = { }
  for _, byte in ipairs(bytes) do
    if n == 0 then break end
    corruptions[AbsPos(cols, byte)] = true
    n = n - 1
  end

  start_pos.k = AbsPos(cols, start_pos)
  local open = { start_pos }

  local meta = { }
  meta[start_pos.k] = {
    dist=0,
    seen=true,
    prev=nil
  }

  local curr, nr, nc, next
  while #open > 0 do
    curr = table.remove(open, 1)

    if curr.r == end_pos.r and curr.c == end_pos.c then
      return meta[curr.k].dist
    end

    for _, offset in ipairs(DIRECTIONS) do
      nr, nc = curr.r + offset.dr, curr.c + offset.dc
      if not InBounds(rows, cols, nr, nc) then
        goto next_offset
      end

      next = {r=nr, c=nc}
      next.k = AbsPos(cols, next)

      if corruptions[next.k] then
        goto next_offset
      end

      if not meta[next.k] then
        meta[next.k] = { }
      end

      if meta[next.k].seen then
        goto next_offset
      end

      meta[next.k].dist = meta[curr.k].dist + 1
      meta[next.k].seen = true
      meta[next.k].prev = nil

      table.insert(open, next)

      ::next_offset::
    end
  end

  return false
end

function FirstByte(size, bytes, n, start_pos, end_pos)
  local l, h = n+1, #bytes

  while l < h do
    local m = (l + h) // 2
    if MinSteps(size, bytes, start_pos, end_pos, m) then
      l = m + 1
    else
      h = m
    end
  end

  return bytes[l].c-1 .. "," .. bytes[l].r-1
end

function Main()
  local size, n = 71, 1024
  local bytes = ParseInput()
  local start_pos, end_pos = {r=1, c=1}, {r=size, c=size}
  print("Part1:", MinSteps(size, bytes, start_pos, end_pos, n))
  print("Part2:", FirstByte(size, bytes, n, start_pos, end_pos))
end

-- time cat 2024/input/18.txt | ./2024/18.lua
-- Part1:  360
-- Part2:  58,62
Main()