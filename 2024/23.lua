#!/usr/bin/env lua

require("2024.utils")

function ParseInput()
  local network_map = { }
  for a,b in string.gmatch(io.read("*a"), "(%S+)-(%S+)") do
    if not network_map[a] then network_map[a] = { } end
    if not network_map[b] then network_map[b] = { } end
    table.insert(network_map[a], b)
    table.insert(network_map[b], a)
  end
  return network_map
end

function CountSetOfThree(network_map)
  local count, set, seen = 0, { }, { }
  for node, edges in pairs(network_map) do
    for i = 1, #edges do
      for j = 2, #edges do
        if table.contains(network_map[edges[i]], edges[j]) then
          if string.find(    node, "^t") or
             string.find(edges[i], "^t") or
             string.find(edges[j], "^t") then
            set[1], set[2], set[3] = node, edges[i], edges[j]
            table.sort(set)
            local key = table.concat(set, "")
            if not seen[key] then
              count = count + 1
              seen[key] = true
            end
          end
        end
      end
    end
  end
  return count
end

function CountSetOfThreeImproved(network_map)
  local count = 0
  for a, bs in pairs(network_map) do
    for _, b in pairs(bs) do
      for _, c in pairs(network_map[b]) do
        if (a < b and b < c) and -- make sure set is sorted
           table.contains(bs, c) and
           (string.find(a, "^t") or
            string.find(b, "^t") or
            string.find(c, "^t")) then
          count = count + 1
        end
      end
    end
  end
  return count
end

-- Checks if `node` is connected with all members of `set`
function ConnectedWith(network_map, node, set)
  local haystack = network_map[node]
  for _, needle in pairs(set) do
    if needle ~= node and
       not table.contains(haystack, needle) then
      return false
    end
  end
  return true
end

function ConnectedSet(network_map, start_node)
  local set, open = { start_node }, { start_node }
  while #open > 0 do
    local node = table.remove(open, 1)
    for _, edge in pairs(network_map[node]) do
      if edge == node or
         node > edge or
         table.contains(set, edge) or
         not ConnectedWith(network_map, edge, set) then
          goto next_edge
      end
      table.insert(set, edge)
      table.insert(open, edge)
      ::next_edge::
    end
  end
  return set
end

function FindPassword(network_map)
  local maxl, ans = 0, nil
  for node in pairs(network_map) do
    local set = ConnectedSet(network_map, node)
    if #set < maxl then goto next_node end
    maxl = #set
    ans = set
    ::next_node::
  end
  table.sort(ans)
  return table.concat(ans, ",")
end

function Main()
  local network_map = ParseInput()
  print("Part1:", CountSetOfThreeImproved(network_map))
  print("Part2:", FindPassword(network_map))
end

-- time cat 2024/input/23.txt | ./2024/23.lua
-- Part1:  1108
-- Part2:  ab,cp,ep,fj,fl,ij,in,ng,pl,qr,rx,va,vf
Main()