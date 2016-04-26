
local MainScene = class("MainScene", cc.load("mvc").ViewBase)

local GameScene = import(".GameScene")
local NeverHideApp = import(".neverhide.NeverHideApp")

function MainScene:onCreate()
    -- -- add background image
    -- display.newSprite("MainSceneBg.jpg")
    --     :move(display.center)
    --     :addTo(self)
    --
    -- -- add play button
    -- local playButton = cc.MenuItemImage:create("PlayButton.png", "PlayButton.png")
    --     :onClicked(function()
    --         self:getApp():enterScene("PlayScene")
    --     end)
    -- cc.Menu:create(playButton)
    --     :move(display.cx, display.cy - 200)
    --     :addTo(self)

    -- local sp = display.newSprite()
    -- self:addChild(sp)
    -- self:setTouchEnabled(true)
    -- self:setTouchMode(cc.TOUCH_MODE_ALL_AT_ONCE)
    -- self:addNodeEventListener(cc.NODE_TOUCH_EVENT,function(event) dump(event) return  end)

  -- display.runScene(GameScene:new())
  --  local n = require("app.scenes.neverhide.NeverHideApp"):new();
   self:addChild(NeverHideApp:new());

end

return MainScene
