--
-- Author: Sty
-- Date: 2015-07-23 14:03:21
--
local HeroUpgradeStreamer = class("HeroUpgradeStreamer",function(nodeType)
   local index = math.random(1,8)

    local sprite = display.newSprite("gfx/blood.png")
    sprite:setScale(0.5)
    return sprite
end)

local Vector2D = require("app.scenes.neverhide.Vector2D")

function HeroUpgradeStreamer:ctor()
	local i = math.random(1,8)


	self.xpos = 0
	self.ypos = 0
	self.zpos = 0
	self.vx = 0
	self.vy = 0
	self.vz = 0
	self.mass = math.random(1,100)/100

end

function HeroUpgradeStreamer:setSpeed(_x,_y)
	self.speed = Vector2D.new(_x,_y)
end

function HeroUpgradeStreamer:setPos(_x,_y)
	self.vector2D = Vector2D.new(_x,_y)
end

return HeroUpgradeStreamer
