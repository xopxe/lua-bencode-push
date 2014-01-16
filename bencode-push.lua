local M = {}

-------------------------------------------------------
-- replace these with you callbacks
M.push_number = function (level, n)
  print ('level', level, 'number', n)
end
M.push_len = function (level, length)
  print ('level', level, 'length', length)
end
M.push_string_fragment = function (level, string)
  print ('level', level, 'fragment', '['..#string..']', string)
end
M.push_list = function (level)
  print ('level', level, 'list')
end
M.push_dict = function (level)
  print ('level', level, 'dictionary')
end
M.push_pop = function (level)
  print ('level', level, 'pop')
end
-------------------------------------------------------

local pos, level = 1, 0
local s, machine, emb_any
local str_length = 0

local function to_state(f)
  machine = f
  return machine()
end

local accum_number = 0
local function emb_int()
  if pos > #s then return end
  local ch = s:sub(pos, pos)
  pos = pos + 1
  if ch == 'e' then
    M.push_number(level, accum_number)
    accum_number = 0
    return to_state(emb_any);
  end
  accum_number = 10*accum_number + tonumber(ch)
  return emb_int()
end

local function emb_str ()
  if pos > #s then return end
  if str_length > #s-pos+1 then
    local fragment = s:sub(pos, -1)
    M.push_string_fragment(level, fragment)
    str_length = str_length - #fragment
    pos = #s+1
    return emb_str()
  else
    if str_length>0 then 
      M.push_string_fragment(level, s:sub(pos, pos+str_length-1)) 
    end
    M.push_string_fragment(level, '')
    pos = pos + str_length
    return to_state(emb_any)
  end
end

--local buf_length = ''
local function emb_len()
  if pos > #s then return end
  local ch = s:sub(pos, pos)
  pos = pos + 1
  if ch == ':' then
    M.push_len(level, str_length)
    return to_state(emb_str)
  end
  str_length = 10*str_length + tonumber(ch)
  return emb_len()
end

local function emb_list ()
  M.push_list(level)
  level = level + 1
  return to_state(emb_any)
end

local function emb_dict ()
  M.push_dict(level)
  level = level + 1
  return to_state(emb_any)
end

emb_any = function ()
  if pos > #s then return end
  local ch = s:sub(pos, pos)
  
  if ch == 'i' then
    pos = pos + 1
    return to_state(emb_int)
  elseif ch == 'd' then
    pos = pos + 1
    return to_state(emb_dict)
  elseif ch == 'l' then
    pos = pos + 1
    return to_state(emb_list)
  elseif ch == 'e' then
    pos, level = pos + 1, level - 1
    M.push_pop(level)
    return to_state(emb_any)
  elseif ch>='0' and ch<='9' then
    str_length = 0
    return to_state(emb_len)
  end
  error() --TODO
end

machine = emb_any

M.decode = function (in_s)
  s, pos = in_s, 1
  return machine()
end


return M

