-- Rocks-n-Blaster -- #LD48 -- by <weldale@gmail.com>

function love.conf(t)
  t.title = "Rocks-n-Blaster"
  t.identity = "Rocks-n-Blaster"
  t.author = "Alexander Weld <weldale@gmail.com>"
  t.modules.physics = false -- don't need that
  
  --t.screen.width      = 800
  --t.screen.height     = 600

  t.screen.width      = 320
  t.screen.height     = 240


  t.console = false
end