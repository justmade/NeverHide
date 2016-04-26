local Role = class("Role", function()
    return display.newNode("Role")
end)

local Vector2D = require("app.scenes.neverhide.Vector2D")

function Role:ctor(x,y,mass)
  self.position = Vector2D.new(x,y)
  self.mass     = 1

  self.speed    = Vector2D.new(0,0);
	self.acceleration = Vector2D.new(0,0);


  -- local drawSp = display.newDrawNode()
  self.height = 30
  -- drawSp:drawLine(cc.p(10,10) , cc.p(20,20) , 2 , cc.c4f(1.0,1.0,1.0,1.0))
  -- drawSp:drawRect({0,0,self.height,self.height},{fillColor = cc.c4f(1.0,0,0,1.0)})
  self.sp = display.newSprite("gfx/blood.png")
  self:addChild(self.sp)
  self.sp:setScale(30/20);
  self.sp:setAnchorPoint(cc.p(0.5,0))
end

function Role:onUpdate()
  self.speed:add(self.acceleration)
  self.position:add(self.speed)
  self:setPositionX(self.position.x)
  self:setPositionY(self.position.y)

  self.acceleration:mult(0)
end

function Role:applyFroce(v)
  self.acceleration:add(v)
end

--设置水平方向的速度
function Role:setHSpeed(v)
  self.speed.x = v.x
end

function Role:playAnimation()
  local ac = cc.FadeOut:create(1)
  self.sp:runAction(ac)
end

function Role:displayRole()
  self.sp:setOpacity(255)
end

function Role:getHeight()
    return self.height
end

function Role:onEnter()

end

return Role
