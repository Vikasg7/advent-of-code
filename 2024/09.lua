#!/usr/bin/env lua

require("2024.utils")

function ParseInput()
  local disk_map = {}
  local input = io.read("*l")
  local idx = 0
  for char in string.gmatch(input, ".") do
    table.insert(disk_map, {
      idx=math.ceil(idx/2),
      len=tonumber(char),
      contain_files=(idx % 2) == 0;
    })
    idx = idx + 1
  end
  return disk_map
end

function PrintDiskMap(disk_map)
  local disk_repr = {}
  for _, block in pairs(disk_map) do
    if block.contain_files then
      for _ = 1, block.len do
        table.insert(disk_repr, block.idx)
      end
    else
      for _ = 1, block.len do
        table.insert(disk_repr, ".")
      end
    end
  end
  print(table.concat(disk_repr, ""))
end

function MoveBlocks(disk_map)
  local idxL = 1
  local idxR = #disk_map % 2 == 1 and #disk_map or #disk_map - 1
  local i, sum = 0, 0
  while idxL <= #disk_map do
    local block = disk_map[idxL]
    if block.contain_files then
      if (block.len == 0) then
        break
      end
      for _ = 1, block.len do
        sum = sum + (block.idx * i)
        i = i + 1
      end
    else
      for _ = 1, block.len do
        local rightmost_block = disk_map[idxR]
        if (rightmost_block.len == 0) then
          idxR = idxR - 2
          rightmost_block = disk_map[idxR]
        end
        if idxR < idxL then
          break
        end
        rightmost_block.len = rightmost_block.len - 1
        sum = sum + (rightmost_block.idx * i)
        i = i + 1
      end
    end
    idxL = idxL + 1
  end
  return sum
end

function MoveFiles(disk_map)
  local idxR = disk_map[#disk_map].contain_files and #disk_map or #disk_map - 1
  local idxL
  while idxR > 1 do
    local rblock = disk_map[idxR]
    if not rblock.contain_files then
      goto next_rblock
    end
    idxL = 1
    while idxL < idxR do
      local lblock = disk_map[idxL]
      if lblock.contain_files or
         lblock.len < rblock.len then
        goto next_lblock
      end
      if lblock.len == rblock.len then
        disk_map[idxL], disk_map[idxR] = disk_map[idxR], disk_map[idxL]
        goto next_rblock
      end
      if lblock.len > rblock.len then
        table.insert(disk_map, idxL, {
          idx=rblock.idx,
          len=rblock.len,
          contain_files=true
        })
        lblock.len = lblock.len - rblock.len
        rblock.contain_files = false
        goto next_rblock
      end
      ::next_lblock::
      idxL = idxL + 1
    end
    ::next_rblock::
    idxR = idxR - 1
  end

  local sum, i = 0, 0
  for _, block in pairs(disk_map) do
    if not block.contain_files then
      i = i + block.len
      goto next_block
    end
    for _ = 1, block.len do
      sum = sum + (block.idx * i)
      i = i + 1
    end
    ::next_block::
  end
  return sum
end

function Main()
  local disk_map = ParseInput()
  local disk_map_copy = table.deep_copy(disk_map)
  print("Part1:", MoveBlocks(disk_map))
  print("Part2:", MoveFiles(table.deep_copy(disk_map_copy)))
end

-- time cat 2024/input/09.txt | ./2024/09.lua
-- Part1:  6463499258318
-- Part2:  6493634986625
Main()