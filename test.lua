local em = require 'bencode-push'

---[[
em.decode('0:10:abcd')
em.decode('efghij')
--]]

---[[
em.decode('li10e')
em.decode('10:abcd')
em.decode('efghij')
em.decode('li20ei30ee')

em.decode('d3:bar4:spam3:fooi42ee')
--]]
