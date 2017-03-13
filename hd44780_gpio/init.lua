Hd44780 = require "hd44780"

BAR_PATTERN = {
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x1f, 0x1f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x1f, 0x1f, 0x00, 0x00, 0x00,
  0x1f, 0x1f, 0x00, 0x1f, 0x1f, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x1f, 0x1f,
  0x1f, 0x1f, 0x00, 0x00, 0x00, 0x00, 0x1f, 0x1f,
  0x00, 0x00, 0x00, 0x1f, 0x1f, 0x00, 0x1f, 0x1f,
  0x1f, 0x1f, 0x00, 0x1f, 0x1f, 0x00, 0x1f, 0x1f,
}

lcd = Hd44780(1, 2, 5, 6, 7, 8)
lcd:init()

lcd:setCGRam()
lcd:writeRam(BAR_PATTERN)

lcd:setDDRam()
lcd:print('Hello, world.')
lcd:setDDRam(0x40)
lcd:writeRam({0, 1, 2, 3, 4, 5, 6, 7})
