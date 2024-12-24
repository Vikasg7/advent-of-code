#!/usr/bin/env lua

require("2024.utils")

DIRECTIONS = {
  {dr= 0, dc=-1},
  {dr= 0, dc= 1},
  {dr= 1, dc= 0},
  {dr=-1, dc= 0}
}

KEYPAD = {
  {"7", "8" , "9"},
  {"4", "5" , "6"},
  {"1", "2" , "3"},
  {nil, "0" , "A"},
}

KEYPAD_POS = {
  ["7"]={r=1,c=1},
  ["8"]={r=1,c=2},
  ["9"]={r=1,c=3},
  ["4"]={r=2,c=1},
  ["5"]={r=2,c=2},
  ["6"]={r=2,c=3},
  ["1"]={r=3,c=1},
  ["2"]={r=3,c=2},
  ["3"]={r=3,c=3},
  ["0"]={r=4,c=2},
  ["A"]={r=4,c=3},
}

REMOTE = {
  { nil, "^", "A" },
  { "<", "v", ">" }
}

REMOTE_POS = {
  ["^"]={r=1,c=2},
  ["A"]={r=1,c=3},
  ["<"]={r=2,c=1},
  ["v"]={r=2,c=2},
  [">"]={r=2,c=3}
}

DIRECTION_BUTTONS = { "<", ">", "v", "^" }

function ParseInput()
  local codes = { }

  for code in io.lines() do
    table.insert(codes, code)
  end

  return codes
end

function InBounds(rows, cols, r, c)
  return r > 0 and c > 0 and r <= rows and c <= cols
end

function AbsPos(cols, pos)
  return ((pos.r - 1) * cols) + pos.c
end

function UniqueId(cols, src, dst)
  local a = ((src.r - 1) * cols) + src.c
  local b = ((dst.r - 1) * cols) + dst.c
  return a * 10 + b
end

function ShortestPaths(board, start_pos, end_pos)
  local rows, cols = #board, #board[1]
  start_pos.k = AbsPos(cols, start_pos)
  local open = { start_pos }

  local meta = { }
  meta[start_pos.k] = {
    paths={ "" },
    plen=0,
    seen=true
  }

  while #open > 0 do
    local curr = table.remove(open, 1)

    if curr.r == end_pos.r and curr.c == end_pos.c then
      for i = 1, #meta[curr.k].paths do
        meta[curr.k].paths[i] = meta[curr.k].paths[i] .. "A"
      end
      return meta[curr.k].paths
    end

    for i, offset in ipairs(DIRECTIONS) do
      local nr, nc = curr.r + offset.dr, curr.c + offset.dc

      if not InBounds(rows, cols, nr, nc) or
         board[nr][nc] == nil then
        goto next_offset
      end

      local next = {r=nr, c=nc }
      next.k = AbsPos(cols, next)

      if not meta[next.k] then
        meta[next.k] = {
          paths={ "" },
          plen=0,
          seen=false
        }
      end

      if meta[curr.k].plen+1 < meta[next.k].plen or
         meta[next.k].plen == 0 then
        meta[next.k].paths = { }
        meta[next.k].plen = meta[curr.k].plen + 1
      end

      for _, path in ipairs(meta[curr.k].paths) do
        table.insert(meta[next.k].paths, path .. DIRECTION_BUTTONS[i])
      end

      if not meta[next.k].seen then
        meta[next.k].seen = true
        table.insert(open, next)
      end
      ::next_offset::
    end
  end

  error("Unreachable: Couldn't find E node")
end

function PrecomputeShortestPaths(board, btn_pos_map)
  local map = { }
  for btnX, posX in pairs(btn_pos_map) do
    for btnY, posY in pairs(btn_pos_map) do
      if btnX == btnY then
        map[btnX .. btnY] = { "A" }
      else
        map[btnX .. btnY] = ShortestPaths(board, posX, posY)
      end
    end
  end
  return map
end


function CacheKey(_, btnX, btnY, depth)
  return btnX..btnY..depth
end

CalcMinPathLength = MemoizeWith(CacheKey, function (board_paths, btnX, btnY, depth)
  local key = btnX .. btnY
  if depth == 1 then
    return #board_paths[key][1]
  end
  local minlen = math.maxinteger
  for _, path in ipairs(board_paths[key]) do
    local len, x = 0, "A"
    for y in string.gmatch(path, ".") do
      len = len + CalcMinPathLength(board_paths, x, y, depth-1)
      x = y
    end
    minlen = math.min(minlen, len)
  end
  return minlen
end)

function MinPathLen(board_paths, code, depth)
  local len, x = 0, "A"
  for y in string.gmatch(code, ".") do
    len = len + CalcMinPathLength(board_paths, x, y, depth)
    x = y
  end
  return len
end

function Complexity(keypad_paths, remote_paths, code, depth)
  local total_len, a = 0, "A"
  for b in string.gmatch(code, ".") do
    local minlen = math.maxinteger
    for _, path in ipairs(keypad_paths[a .. b]) do
      local len = MinPathLen(remote_paths, path, depth)
      minlen = math.min(minlen, len)
    end
    total_len = total_len + minlen
    a = b
  end
  return total_len * tonumber(string.sub(code, 1, #code-1))
end

function TotalComplexity(keypad_paths, remote_paths, codes, RobotCnt)
  local sum = 0
  for _, code in ipairs(codes) do
    sum = sum + Complexity(keypad_paths, remote_paths, code, RobotCnt)
  end
  return sum
end

function Main()
  local codes = ParseInput()
  local keypad_paths = PrecomputeShortestPaths(KEYPAD, KEYPAD_POS)
  local remote_paths = PrecomputeShortestPaths(REMOTE, REMOTE_POS)
  print("Part1:", TotalComplexity(keypad_paths, remote_paths, codes, 2))
  print("Part1:", TotalComplexity(keypad_paths, remote_paths, codes, 25))
end

-- time cat 2024/input/21.txt | ./2024/21.lua
-- Part1:  238078
-- Part2:  293919502998014
Main()