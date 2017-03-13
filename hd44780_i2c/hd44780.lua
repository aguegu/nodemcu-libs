-- Meta Class
local Hd44780 = {}
Hd44780.__index = Hd44780

setmetatable(Hd44780, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})


-- P7: d7
-- P6: d6
-- P5: d5
-- P4: d4
-- P3: bl
-- P2: em
-- P1: rw
-- P0: rs

function Hd44780.new(addr, sda, scl)
  local self = setmetatable({}, Hd44780)

  self.addr = addr
  self.rs = false
  self.bl = false

  i2c.setup(0, sda, scl, i2c.SLOW)
  return self
end


function Hd44780:emit(val)
  local dt = bit.lshift(val, 4)
  if self.rs then
    dt = bit.set(dt, 0)
  end
  if self.bl then
    dt = bit.set(dt, 3)
  end

  i2c.start(0)
  i2c.address(0, self.addr, i2c.TRANSMITTER)
  i2c.write(0, bit.set(dt, 2), bit.clear(dt, 2))
  i2c.stop(0)
end

function Hd44780:write(dt)
  local dt_h = bit.band(dt, 0xf0)
  local dt_l = bit.lshift(bit.band(dt, 0x0f), 4)

  if self.rs then
    dt_h = bit.set(dt_h, 0)
    dt_l = bit.set(dt_l, 0)
  end
  if self.bl then
    dt_h = bit.set(dt_h, 3)
    dt_l = bit.set(dt_l, 3)
  end

  i2c.start(0)
  i2c.address(0, self.addr, i2c.TRANSMITTER)
  i2c.write(0, bit.set(dt_h, 2), bit.clear(dt_h, 2), bit.set(dt_l, 2), bit.clear(dt_l, 2))
  i2c.stop(0)
end

function Hd44780:init()

  self.rs = false
  self:emit(0x03)
  tmr.delay(4100)

  self:emit(0x03)
  tmr.delay(100)

  self:emit(0x03)
  self:emit(0x02)

  self:write(0x28) -- function set

  self:write(0x08)
  self:write(0x01) -- clear display

  self:write(0x06) -- entry mode

  self:write(0x02) -- home
  tmr.delay(1520)

  self:write(0x0c)

  self:setDisplay(true, false, false)
end

function Hd44780:setDisplay(display, cursor, blink)
  self.rs = false
  local dt = 0x08

  if display then
    dt = bit.bor(dt, 0x04)
  end

  if cursor then
    dt = bit.bor(dt, 0x02)
  end

  if blink then
    dt = bit.bor(dt, 0x01)
  end

  self:write(dt)
end

function Hd44780:setCGRam(address)
  address = address or 0
  self.rs = false
  self:write(0x40 + bit.band(address, 0x3f))
end

function Hd44780:setDDRam(address)
  address = address or 0
  self.rs = false
  self:write(0x80 + bit.band(address, 0x7f))
end

function Hd44780:print(s)
  self.rs = true
  for i=1, #s do
    self:write(string.byte(string.sub(s, i, i)))
  end
end

function Hd44780:writeRam(dt)
  self.rs = true
  for i=1, #dt do
    self:write(dt[i])
  end
end

return Hd44780

-- todo: make writeRam more efficient with i2c
