-- Meta Class
local Hd44780 = {}
Hd44780.__index = Hd44780

setmetatable(Hd44780, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function Hd44780.new(rs, em, d4, d5, d6, d7)
  local self = setmetatable({}, Hd44780)

  self.pin_rs = rs
  self.pin_em = em
  self.pin_d4 = d4
  self.pin_d5 = d5
  self.pin_d6 = d6
  self.pin_d7 = d7

  return self
end

function Hd44780:emit(dt)
  gpio.write(self.pin_d4, bit.band(bit.rshift(dt, 0), 0x01))
  gpio.write(self.pin_d5, bit.band(bit.rshift(dt, 1), 0x01))
  gpio.write(self.pin_d6, bit.band(bit.rshift(dt, 2), 0x01))
  gpio.write(self.pin_d7, bit.band(bit.rshift(dt, 3), 0x01))

  gpio.write(self.pin_em, 1)
  tmr.delay(5)
  gpio.write(self.pin_em, 0)
end

function Hd44780:write(dt)
  self:emit(bit.rshift(dt, 4))
  self:emit(dt)
end

function Hd44780:init()
  gpio.mode(self.pin_rs, gpio.OUTPUT)
  gpio.mode(self.pin_em, gpio.OUTPUT)
  gpio.mode(self.pin_d4, gpio.OUTPUT)
  gpio.mode(self.pin_d5, gpio.OUTPUT)
  gpio.mode(self.pin_d6, gpio.OUTPUT)
  gpio.mode(self.pin_d7, gpio.OUTPUT)

  gpio.write(self.pin_em, 0)
  gpio.write(self.pin_rs, 0)

  self:emit(0x03)
  tmr.delay(4100)

  self:emit(0x03)
  tmr.delay(100)

  self:emit(0x03)
  self:emit(0x02)

  self:write(0x28) -- function set

  self:setDisplay(false, false, false)
  self:write(0x01) -- clear display

  self:write(0x06) -- entry mode

  self:write(0x02) -- home
  tmr.delay(1520)

  self:setDisplay(true, false, false) -- display control
end

function Hd44780:setDisplay(display, cursor, blink)
  gpio.write(self.pin_rs, 0)
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
  gpio.write(self.pin_rs, 0)
  self:write(0x40 + bit.band(address, 0x3f))
end

function Hd44780:setDDRam(address)
  address = address or 0
  gpio.write(self.pin_rs, 0)
  self:write(0x80 + bit.band(address, 0x7f))
end

function Hd44780:print(s)
  gpio.write(self.pin_rs, 1)
  for i=1, #s do
    self:write(string.byte(string.sub(s, i, i)))
  end
end

function Hd44780:writeRam(dt)
  gpio.write(self.pin_rs, 1)
  for i=1, #dt do
    self:write(dt[i])
  end
end

return Hd44780
