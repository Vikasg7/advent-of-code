local utils = {}

function table.deep_copy(original)
  local copy = {}
  for k, v in pairs(original) do
    if type(v) == "table" then
      copy[k] = table.deep_copy(v)
    else
      copy[k] = v
    end
  end
  return copy
end

function table.contains(list, needle)
  for i = 1, #list do
    if list[i] == needle then
      return true
    end
  end
  return false
end

return utils