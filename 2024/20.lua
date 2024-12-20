#!/usr/bin/env lua

DIRECTIONS = {
  {dr= 0, dc=-1},
  {dr= 0, dc= 1},
  {dr= 1, dc= 0},
  {dr=-1, dc= 0}
}

function ParseInput()
  local board, tracks = { }, { }

  local r, start_pos, end_pos = 1, { }, { }
  for line in io.lines() do
    local s = string.find(line, "S")
    if s then
      start_pos.r, start_pos.c = r, s
    end

    local c, row = 1, { }
    for char in string.gmatch(line, ".") do
      if char == "." or char == "S" or char == "E" then
        table.insert(tracks, {r=r, c=c})
      end
      table.insert(row, {r=r, c=c, v=char})
      c = c + 1
    end

    table.insert(board, row)
    r = r + 1
  end

  return board, tracks, start_pos, end_pos
end

function InBounds(rows, cols, r, c)
  return r > 0 and c > 0 and r <= rows and c <= cols
end

function AbsPos(cols, pos)
  return ((pos.r - 1) * cols) + pos.c
end

function UniqueId(cols, cheat_head, cheat_tail)
  return AbsPos(cols, cheat_head) * 100000 + AbsPos(cols, cheat_tail)
end

function FillDistance(board, start_pos)
  board[start_pos.r][start_pos.c].d = 0
  local open = { board[start_pos.r][start_pos.c] }

  local curr, nr, nc, next
  while #open > 0 do
    curr = table.remove(open, 1)

    if board[curr.r][curr.c].v == "E" then
      return
    end

    for _, offset in ipairs(DIRECTIONS) do
      nr, nc = curr.r + offset.dr, curr.c + offset.dc
      next = board[nr][nc]

      if next.v == "#" or
         next.d ~= nil then -- if distance is set, meaning it is already seen
        goto next_offset
      end

      next.d = (curr.d or 0) + 1
      table.insert(open, next)
      ::next_offset::
    end
  end

  error("Unreachable: Couldn't find E node")
end

function TwoPSCheatsCount(board, tracks)
  local rows, cols = #board, #board[1]
  local count = 0
  local cheat_offsets = { {dr=0,dc=2}, {dr=2,dc=0}, {dr=1,dc=1}, {dr=-1,dc=1} }
  local nr, nc
  for _, track in ipairs(tracks) do
    for _, offset in ipairs(cheat_offsets) do
      nr, nc = track.r + offset.dr, track.c + offset.dc

      if not InBounds(rows, cols, nr, nc) or
         board[nr][nc].v == "#" then
        goto next_offset
      end

      if math.abs(board[track.r][track.c].d - board[nr][nc].d) - 2 >= 100 then
        count = count + 1
      end

      ::next_offset::
    end
  end
  return count
end

function TwentyPSCheatsCount(board, tracks)
  local rows, cols = #board, #board[1]
  local count = 0
  local cheat_offsets = { {dr=1,dc=1}, {dr=1,dc=-1}, {dr=-1,dc=1}, {dr=-1,dc=-1} }
  local nr, nc, dc, src, dst, cheat
  local seen = { }

  for _, track in ipairs(tracks) do
    src = board[track.r][track.c]
    for radius = 2, 20 do
      for dr = 0, radius do
        dc = radius - dr
        for _, offset in ipairs(cheat_offsets) do
          nr, nc = src.r + (offset.dr * dr), src.c + (offset.dc * dc)

          if not InBounds(rows, cols, nr, nc) then
            goto next_offset
          end

          dst = board[nr][nc]

          if dst.v == "#" then
            goto next_offset
          end

          if src.d - dst.d - radius >= 100 then
            cheat = UniqueId(cols, src, dst)
            if not seen[cheat] then
              count = count + 1
            end
            seen[cheat] = true
          end

          ::next_offset::
        end
      end
    end
  end
  return count
end

function Main()
  local board, tracks, start_pos = ParseInput()
  FillDistance(board, start_pos)

  print("Part1:", TwoPSCheatsCount(board, tracks))
  print("Part2:", TwentyPSCheatsCount(board, tracks))
end

-- time cat 2024/input/20.txt | ./2024/20.lua
-- Part1:  1351
-- Part2:  966130
Main()