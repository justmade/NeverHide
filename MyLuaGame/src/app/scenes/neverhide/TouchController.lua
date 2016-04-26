local TouchController = class("TouchController", function()
    return display.newNode("TouchController")
end)

local Vector2D = import(".Vector2D")

function TouchController:ctor()
    self.moveVec = Vector2D.new(0,0)
    self.jumpVec = Vector2D.new(0,0)
    self.moveState = 0;

    self.btnJump = display.newSprite("gfx/controller_jump.png")
    self.btnLeft = display.newSprite("gfx/controller_left.png")
    self.btnRight = display.newSprite("gfx/controller_right.png")

    self:addChild(self.btnJump)
    self:addChild(self.btnLeft)
    self:addChild(self.btnRight)

    self.btnLeft:setAnchorPoint(cc.p(0,0))
    self.btnRight:setAnchorPoint(cc.p(0,0))
    self.btnJump:setAnchorPoint(cc.p(0,0))

    self.btnJump:setOpacity(120)
    self.btnLeft:setOpacity(120)
    self.btnRight:setOpacity(120)

    self.btnJump:setPositionX(self.btnJump:getBoundingBox().size.width/2 + 50)
    self.btnRight:setPositionX(display.width - self.btnRight:getBoundingBox().size.width - 50)
    self.btnLeft:setPositionX(self.btnRight:getPositionX() - self.btnLeft:getBoundingBox().size.width - 50)

    self.btnJump:setPositionY(50)
    self.btnRight:setPositionY(50)
    self.btnLeft:setPositionY(50)


    self.btnJump:setTouchEnabled(true)
    self.btnJump:setTouchMode(cc.TOUCH_MODE_ALL_AT_ONCE)
    self.btnJump:addNodeEventListener(cc.NODE_TOUCH_EVENT,
      function(event)
        return self:onJump(event)
      end)

    self:setTouchEnabled(true)
    self:setTouchMode(cc.TOUCH_MODE_ALL_AT_ONCE)
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT,
      function(event)
            dump(event)
            return true
        -- return self:onTouch(event)
      end)
end

function TouchController:onTouch(event)
  -- dump(event)
  local point = event.points["0"]
  local rightRect = self.btnRight:getBoundingBox();
  local leftRect = self.btnLeft:getBoundingBox();
  if rightRect:containsPoint(cc.p(point.x , point.y)) then
      self.moveState = 1
      self.moveVec.x = 1
  end

  if leftRect:containsPoint(cc.p(point.x , point.y)) then
      self.moveState = -1
      self.moveVec.x = -1
  end

  if event.name == "began" then

  elseif event.name == "moved" then

  elseif event.name == "ended" then
    self.moveState = 0
    self.moveVec.x = 0
  end
  return true
end

function TouchController:onJump(event)
  print("jump")
  if event.name == "began" then
    self.jumpVec.y = 20
  elseif event.name == "moved" then

  elseif event.name == "ended" then

  end
  return true
end

return TouchController
