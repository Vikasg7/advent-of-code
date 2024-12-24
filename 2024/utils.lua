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

function math.is_integer(num)
  return num == math.floor(num)
end

function Memoize(fn)
  local cache = { }

  return function (key, ...)
    if cache[key] ~= nil then
      return cache[key]
    end

    local val = fn(key, ...)
    cache[key] = val
    return val
  end
end

function MemoizeWith(keyfn, fn)
  local cache = { }

  return function (...)
    local key = keyfn(...)
    if cache[key] ~= nil then
      return cache[key]
    end

    local val = fn(...)
    cache[key] = val
    return val
  end
end

function table.join(t1, t2)
  table.move(t2, 1, #t2, #t1 + 1, t1)
end

return utils