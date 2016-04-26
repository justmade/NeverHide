--
-- Author: Sty
-- Date: 2015-07-23 13:53:46
--
local HeroUpgradeEffect = class("HeroUpgradeEffect",function ()
	return display.newNode()
end)

local HeroUpgradeStreamer = import(".HeroUpgradeStreamer")

local Vector2D = require("app.scenes.neverhide.Vector2D")

function HeroUpgradeEffect:ctor()
	self.balls = {}
	self.numBalls = 100
	self.fl = 250
	self.vpX =0
	self.vpY =0
	self.gravity = -0.042
	self.gravityX = 0.989
	self.floor = -100
	self.bounce = -0.6
	self.currentAI = 1
	self.fScale = 0
	self.container = display.newBatchNode("blood.png")
	self.distroyCount = 0
	self.hasClean = false
	-- display.addSpriteFrames("color_streamer.plist","color_streamer.png")
	self:addChild(self.container)

	self:init()
end

function HeroUpgradeEffect:init()

	-- self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT,handler(self,self.onCreate))
	-- self:scheduleUpdate()
	-- self.currentAI = 1

	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT,handler(self,self.onRender))
	self:scheduleUpdate()
	self.currentIndex = 1
end

function HeroUpgradeEffect:onCreate()
	if self.currentAI < self.numBalls/10 then
		for i=1,10 do
		local ball = HeroUpgradeStreamer.new()
		ball.ypos = math.random(-1200,-1000)/10
		ball.xpos = math.random(-500,500)/10
		ball.vx = math.random(-500,500)/100
		ball.vy = math.random(5000,15000)/1000

		ball.vy = ball.vy * ball.vy / 15

		ball.vz = math.random(-100,100)/100
		--ball.mass = math.random(4,10)/10
		ball:setSpeed(ball.vx,ball.vy)
		ball:setPos(ball.xpos,ball.ypos)
		--ball:setScale(1 - (ball.vz/2))
		table.insert(self.balls,ball)
		-- ball:retain()
		self.container:addChild(ball)
		self.container:setVisible(false)

		-- self:addChild(ball)
		end
		self.currentAI = self.currentAI + 1
	end
end

function HeroUpgradeEffect:onRender()
	self:onCreate()
	self.container:setVisible(true)
	self.currentIndex = self.currentIndex + 1
	for i=#self.balls,1,-1 do
		self:move(self.balls[i])
	end
end

function HeroUpgradeEffect:move(_ball)
	local s = _ball.speed:magnitude()
	local dragMagnitude = 0.0069 * s * s ;
	local drag = Vector2D.new(_ball.speed.x, _ball.speed.y)
	drag:mult(-1)
	drag:normalize()
	drag:mult(dragMagnitude)
	drag:mult(_ball.mass)
	drag:mult(math.abs(_ball:getScaleX()))

	_ball.speed:add(drag)
	_ball.speed:add({x = 0 , y = self.gravity})

	_ball.vector2D:add(_ball.speed)
	_ball.zpos = _ball.zpos + _ball.vz;

	local r = _ball.speed.x
	_ball:setRotation(r + _ball:getRotation())
	_ball:setOpacity(_ball:getOpacity() * 0.995)
	-- _ball:setScaleX(math.sin(math.pi * 2 * self.currentIndex/(_ball.mass * 80)))

    if _ball.zpos > - self.fl then
        -- self.fScale = self.fl/(self.fl + _ball.zpos)
        self.fScale = 1
        _ball:setPositionX(self.vpX + _ball.vector2D.x * self.fScale)
        _ball:setPositionY(self.vpX + _ball.vector2D.y * self.fScale)
    else
        _ball:setVisible(false)
    end

	if _ball.vector2D.y <= self.floor then
		self.distroyCount = self.distroyCount + 1
		_ball.ypos = self.floor
		_ball:setVisible(false)

		for i=#self.balls,1,-1 do
			local v = self.balls[i]
			if v == _ball then
				table.remove(self.balls,i)
				if #self.balls <= 0 then
					self:destroy()
				end
			end
		end
	end
end

function HeroUpgradeEffect:destroy()
	if self.hasClean == false then
        print("clean")
		self.hasClean = true
		self:removeNodeEventListener(cc.NODE_ENTER_FRAME_EVENT)
		self:unscheduleUpdate()
        for i=1,#self.balls do
          self.balls[i]:removeFromParent()
        end
		self.container:removeFromParent()
		-- self.container = nil
		-- self.balls = nil
	end
end


return HeroUpgradeEffect
