#!/usr/bin/env lua

DIRECTIONS = {
  {dr= 0, dc=-1},
  {dr= 0, dc= 1},
  {dr= 1, dc= 0},
  {dr=-1, dc= 0}
}

function ParseInput()
  local board = { }
  local start_pos, c
  local r = 1
  for line in io.lines() do
    if line == "" then break end
    c = string.find(line, "S")
    if c then
      start_pos = {r=r, c=c}
    end
    local row = { }
    for char in string.gmatch(line, ".") do
      table.insert(row, char)
    end
    table.insert(board, row)
    r = r + 1
  end

  board[start_pos.r][start_pos.c] = "."

  return board, start_pos
end

function PrintBoard(board, path, start_pos)
  local end_pos = table.remove(path, 1)

  for _, node in ipairs(path) do
    board[node.r][node.c] = "*"
  end

  board[start_pos.r][start_pos.c] = "S"
  board[end_pos.r][end_pos.c] = "E"
  for _, row in ipairs(board) do
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

function ByCostAsc(a, b)
  return (a.cost or math.maxinteger) < (b.cost or math.maxinteger)
end

function StepCost(a, b)
  return (a.dr == b.dr and a.dc == b.dc) and 1 or 1001
end

function UniqueId(cols, pos, dir)
  local abs_pos = (pos.r * cols) + pos.c
  local dir_id =  ((dir.dr + 1) * 3) + (dir.dc + 1)
  return abs_pos * 10 + dir_id
end

function AbsPos(cols, pos)
  return (pos.r * cols) + pos.c
end

function CheapestPath(board, start_pos)
  local cols = #board[1]
  start_pos.d = {dr=0, dc=1}
  start_pos.k = AbsPos(cols, start_pos)
  local open = { start_pos }

  local meta = { }
  meta[start_pos.k] = {
    cost=0,
    prev=nil,
    open=true
  }

  local curr, nr, nc, next_cost_via_pos, next, next_cost
  while #open > 0 do
    table.sort(open, function (a, b)
      return (meta[a.k].cost or math.maxinteger) < (meta[b.k].cost or math.maxinteger)
    end)
    curr = table.remove(open, 1)

    if board[curr.r][curr.c] == "E" then
      return meta[curr.k].cost
    end

    for _, offset in ipairs(DIRECTIONS) do
      nr, nc = curr.r + offset.dr, curr.c + offset.dc
      if board[nr][nc] == "#" then
        goto next_offset
      end

      next = {r=nr, c=nc}
      next.d = offset
      next.k = AbsPos(cols, next)
      if not meta[next.k] then
        meta[next.k] = { }
      end

      next_cost_via_pos = meta[curr.k].cost + StepCost(curr.d, next.d)
      next_cost = meta[next.k].cost or math.maxinteger
      if next_cost_via_pos >= next_cost then
        goto next_offset
      end

      meta[next.k].cost = next_cost_via_pos
      meta[next.k].prev = curr
      if not meta[next.k].open then
        table.insert(open, next)
        meta[next.k].open = true
      end
      ::next_offset::
    end
  end

  assert(false, "Couldn't find the E node.")
end

function CountTiles(cols, meta, curr)
  local visited, open = { }, { curr }
  while #open > 0 do
    curr = table.remove(open, 1)
    visited[AbsPos(cols, curr)] = true
    for _, prev in ipairs(meta[curr.k].prev) do
      if not visited[AbsPos(cols, prev)] then
        table.insert(open, prev)
      end
    end
  end
  local tiles = 0
  for _ in pairs(visited) do
    tiles = tiles + 1
  end
  return tiles
end

function AllCheapestPathsTilesCount(board, start_pos)
  local cols = #board[1]
  start_pos.d = {dr=0, dc=1}
  start_pos.k = UniqueId(cols, start_pos, start_pos.d)
  local open = { start_pos }

  local meta = { }
  meta[start_pos.k] = {
    cost=0,
    prev={ },
    open=true
  }

  local curr, nr, nc, next_cost_via_pos, next, next_cost
  while #open > 0 do
    table.sort(open, function (a, b)
      return (meta[a.k].cost or math.maxinteger) < (meta[b.k].cost or math.maxinteger)
    end)
    curr = table.remove(open, 1)

    if board[curr.r][curr.c] == "E" then
      return CountTiles(cols, meta, curr)
    end

    for _, offset in ipairs(DIRECTIONS) do
      nr, nc = curr.r + offset.dr, curr.c + offset.dc
      if board[nr][nc] == "#" then
        goto next_offset
      end

      next = {r=nr, c=nc}
      next.d = offset
      next.k = UniqueId(cols, next, next.d)
      if not meta[next.k] then
        meta[next.k] = { }
      end

      next_cost_via_pos = meta[curr.k].cost + StepCost(curr.d, next.d)
      next_cost = meta[next.k].cost or math.maxinteger
      if next_cost_via_pos > next_cost then
        goto next_offset
      end

      if next_cost_via_pos == next_cost then
        table.insert(meta[next.k].prev, curr)
        goto next_offset
      end

      meta[next.k].cost = next_cost_via_pos
      meta[next.k].prev = { curr }
      if not meta[next.k].open then
        table.insert(open, next)
        meta[next.k].open = true
      end
      ::next_offset::
    end
  end

  assert(false, "Couldn't find the E node.")
end

function Main()
  local board, start_pos = ParseInput()
  print("Part1:", CheapestPath(board, start_pos))
  print("Part2:", AllCheapestPathsTilesCount(board, start_pos))
end

-- time cat 2024/input/16.txt | ./2024/16.lua
-- Part1:  95476
-- Part2:  511
Main()