local em = require 'bencode-push'

local callbacks = {
  push_number = function (level, n)
    print ('level', level, 'number', n)
  end,
  push_len = function (level, length)
    print ('level', level, 'length', length)
  end,
  push_string_fragment = function (level, string)
    print ('level', level, 'fragment', '['..#string..']', string)
  end,
  push_list = function (level)
    print ('level', level, 'list')
  end,
  push_dict = function (level)
    print ('level', level, 'dictionary')
  end,
  push_pop = function (level)
    print ('level', level, 'pop')
  end,
}

local decode = em.decoder(callbacks)

---[[
decode('0:10:abcd')
decode('efghij')
--]]

---[[
decode('li10e')
decode('10:abcd')
decode('efghij')
decode('li20ei30ee')

decode('d3:bar4:spam3:fooi42ee')
--]]
