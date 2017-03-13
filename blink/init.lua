LED_BOARD = 0
LED_CHIP = 4

s = gpio.LOW

function blink ()
  s = bit.bxor(s, 1)
  gpio.write(LED_BOARD, s)
end

gpio.mode(LED_BOARD, gpio.OUTPUT)

tm = tmr.create()
tm:register(1000, tmr.ALARM_AUTO, blink)
tm:start()
