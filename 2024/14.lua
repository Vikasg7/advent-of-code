#!/usr/bin/env lua

function ParseInput()
  local robots = { }
  for line in io.lines() do
    local c, r, vc, vr = string.match(line, "p%=(%d+),(%d+) v%=(%-?%d+),(%-?%d+)")
    table.insert(robots, {pos={r=tonumber(r), c=tonumber(c)}, vel={r=tonumber(vr), c=tonumber(vc)}})
  end
  return robots
end

function SafetyFactor(robots)
  local rows, cols = 103, 101
  local midr, midc = math.ceil(rows/2), math.ceil(cols/2)
  local q1, q2, q3, q4 = 0, 0, 0, 0

  for _, robot in ipairs(robots) do
    local nr = (robot.pos.r + (robot.vel.r * 100)) % rows
    local nc = (robot.pos.c + (robot.vel.c * 100)) % cols
    nr, nc = nr + 1, nc + 1

    if (nr == midr) or (nc == midc) then
      goto next_robot
    end

    q1 = q1 + ((nr < midr and nc < midc) and 1 or 0)
    q2 = q2 + ((nr < midr and nc > midc) and 1 or 0)
    q3 = q3 + ((nr > midr and nc < midc) and 1 or 0)
    q4 = q4 + ((nr > midr and nc > midc) and 1 or 0)
    ::next_robot::
  end

  return q1 * q2 * q3 * q4
end

function SecondsElapsedTillEasterEgg(robots)
  local rows, cols = 103, 101
  local sec = 1
  local visited = { }

  while true do
    for _, robot in ipairs(robots) do
      robot.pos.r = ((robot.pos.r + robot.vel.r) % rows) + 1
      robot.pos.c = ((robot.pos.c + robot.vel.c) % cols) + 1
    end

    for _, robot in ipairs(robots) do
      local key = (robot.pos.r * cols) + robot.pos.c
      if visited[key] == sec then
        goto next_second
      end
      visited[key] = sec
    end
    break
    ::next_second::
    sec = sec + 1
  end

  return sec
end

function Main()
  local robots = ParseInput()
  print("Part1:", SafetyFactor(robots))
  print("Part2:", SecondsElapsedTillEasterEgg(robots))
end

-- time cat 2024/input/14.txt | ./2024/14.lua
-- Part1:  218965032
-- Part2:  7037
Main()