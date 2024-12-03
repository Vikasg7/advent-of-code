#!/usr/bin/env lua

function ParseInput()
  local reports = {}
  for line in io.lines() do
    local report = {}
    for level in string.gmatch(line, "%S+") do
      table.insert(report, tonumber(level))
    end
    table.insert(reports, report)
  end
  return reports
end

function SafeReportCount(reports)
  local count = #reports
  for i = 1, #reports, 1 do
    local report = reports[i]
    local direction = report[1] - report[2]
    for j = 1, #report-1, 1 do
      local diff = report[j] - report[j+1]
      local absDiff = math.abs(diff)
      local isSafe = absDiff >= 1 and absDiff <= 3 and (direction*diff) > 0
      if not isSafe then
        count = count - 1
        break
      end
    end
  end
  return count
end

function IsReportSafe(report, j, k, direction, unsafeRepCnt)
  while j <= #report-1 and k <= #report do
    local jth, kth = report[j], report[k]
    local diff = jth - kth
    local absDiff = math.abs(diff)
    local isSafe = absDiff >= 1 and absDiff <= 3 and (direction*diff > 0)
    if not isSafe then
      unsafeRepCnt = unsafeRepCnt + 1
      if unsafeRepCnt > 1 then
        return false
      end
      local lj, lk, rj, rk
      if j-1 < 1 then
        lj, lk, rj, rk = j, k+1, k, k+1
      else
        lj, lk, rj, rk = j-1, k, j, k+1
      end
      local isLeftSafe  = IsReportSafe(report, lj, lk, direction, unsafeRepCnt)
      local isRightSafe = IsReportSafe(report, rj, rk, direction, unsafeRepCnt)
      return isLeftSafe or isRightSafe
    end
    j = k
    k = k + 1
  end
  return true
end

function GuessDirection(report)
  local direction = report[1] - report[#report]
  return direction >= 0 and 1 or -1
end

function SafeReportCountImproved(reports)
  local count = 0
  for i = 1, #reports, 1 do
    local report = reports[i]
    local direction = GuessDirection(report)
    if IsReportSafe(report, 1, 2,  direction, 0) or
       IsReportSafe(report, 1, 2, -direction, 0) then
      count = count + 1
    end
  end
  return count
end

function Main()
  local reports = ParseInput()
  print("Part1:", SafeReportCount(reports))
  print("Part2:", SafeReportCountImproved(reports))
end

-- cat 2024/input/02.txt | ./2024/02.lua
-- Part1:  598
-- Part2:  634
Main()