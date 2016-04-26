local GameScene = class("GameScene", function()
    return display.newScene("GameScene")
end)

function GameScene:ctor()
  local img = display.newSprite('MainSceneBg.jpg')


  local sp = display.newLayer()
  self:addChild(sp)
  sp:setTouchEnabled(true)
  sp:addChild(img)
  -- sp:setTouchMode(cc.TOUCH_MODE_ALL_AT_ONCE)
  -- sp:registerScriptTouchHandler(function(state, ...) ）
  print("GameScene")
  sp:onTouch(function(event) dump(event) return true end , true,true)
  -- sp:onTouchBegn()
end

return GameScene
