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

CACHE = { }

function BFS(board, start_pos, end_btn)
  local rows, cols = #board, #board[1]

  local start_btn = board[start_pos.r][start_pos.c]
  local key = start_btn .. end_btn
  if CACHE[key] ~= nil then
    local end_pos = (#board > 2 and KEYPAD_POS or REMOTE_POS)[end_btn]
    return end_pos, CACHE[key]
  end

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

    if board[curr.r][curr.c] == end_btn then
      for i = 1, #meta[curr.k].paths do
        meta[curr.k].paths[i] = meta[curr.k].paths[i] .. "A"
      end
      CACHE[key] = meta[curr.k].paths
      return curr, meta[curr.k].paths
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

function Cartesian(xs, ys)
  if #xs == 0 then return ys end
  if #ys == 0 then return xs end
  local zs = { }
  for _, x in ipairs(xs) do
    for _, y in ipairs(ys) do
      table.insert(zs, x .. y)
    end
  end
  return zs
end

function ButtonSequence(board, start_pos, code)
  local paths = { }
  local sub_paths
  for button in string.gmatch(code, ".") do
    start_pos, sub_paths = BFS(board, start_pos, button)
    paths = Cartesian(paths, sub_paths)
  end
  return paths
end

function Complexity(code, RobotCnt)
  local as = ButtonSequence(KEYPAD, KEYPAD_POS["A"], code)
  for i = 1, RobotCnt do
    local plen, bs = math.maxinteger, { }
    for _, a in ipairs(as) do
      for _, b in ipairs(ButtonSequence(REMOTE, REMOTE_POS["A"], a)) do
        if #b == plen then
          table.insert(bs, b)
        elseif #b < plen then
          bs = { b }
          plen = #b
        end
      end
      as = bs
    end
  end
  return #as[1] * tonumber(string.sub(code, 1, #code-1))
end

function TotalComplexity(codes, RobotCnt)
  local sum = 0
  for _, code in ipairs(codes) do
    sum = sum + Complexity(code, RobotCnt)
  end
  return sum
end

function Main()
  local codes = ParseInput()
  print("Part1:", TotalComplexity(codes, 2))
  -- print("Part2:", TotalComplexity(codes, 25))
end

-- time cat 2024/input/21.txt | ./2024/21.lua
-- Part1:  
-- Part2:  
Main()