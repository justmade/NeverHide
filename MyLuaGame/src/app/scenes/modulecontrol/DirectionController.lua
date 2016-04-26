--
-- Author: Sty
-- Date: 2015-12-04 14:58:11
--
local DirectionController = class("DirectionController", function()
    return display.newNode("DirectionController")
end)

local speed = 4

--主场景，目标玩家，地图格子数组
function DirectionController:ctor(contentGroup,target,mapGrids)
	self.mapGrids = mapGrids
	self.target = target
	contentGroup:setTouchEnabled(true)
    contentGroup:setTouchMode(cc.TOUCH_MODE_ALL_AT_ONCE)
    contentGroup:addNodeEventListener(cc.NODE_TOUCH_EVENT,function(event) return self:onTouch(event) end)
    self.contentGroup = contentGroup
    self:addEnterFrame()
end

function DirectionController:onTouch(event)
	local point = event.points["0"]

	if event.name == "began" then
		self.startX = point.x
    	self.startY = point.y
    	self:scheduleUpdate()
    elseif event.name == "moved" then
    	local vx = point.x - self.startX 
    	local vy = point.y - self.startY 

    	local angle = math.atan2(vy, vx) *  180 / math.pi + 180
    	self.dirAngle = angle
    	-- print(angle)
    	-- self:judgeDirection(angle)
    else
    	self:unscheduleUpdate()
    end

	return true
end

function DirectionController:addEnterFrame()
	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT,handler(self,self.onRender))
end

function DirectionController:removeEnterFrame()
	self:removeNodeEventListener(cc.NODE_ENTER_FRAME_EVENT)
end

function DirectionController:onRender()
	self:judgeDirection(self.dirAngle)
end


--反向移动的是地图
function DirectionController:judgeDirection(angle)
	if not self.dirAngle then
		return true
	end 
	local px,py = self.contentGroup:getPosition()
	local tx,ty = self.target:getPosition()
	if angle 	 <= 22.5 then 
		-- print("left")
		px = px + speed
		tx = tx - speed
	elseif angle <= 22.5 + 45 then 
		px = px + speed
		py = py + speed
		tx = tx - speed
		ty = ty - speed
		-- print("leftd")
	elseif angle <= 22.5 + 45 * 2 then 
		-- print("d")
		py = py + speed
		ty = ty - speed
	elseif angle <= 22.5 + 45 * 3 then
		px = px - speed
		py = py + speed
		tx = tx + speed
		ty = ty - speed
		-- print("rd")
	elseif angle <= 22.5 + 45 * 4 then 
		px = px - speed
		tx = tx + speed
		-- print("r")
	elseif angle <= 22.5 + 45 * 5 then 
		px = px - speed
		py = py - speed
		tx = tx + speed
		ty = ty + speed
		-- print("ur")
	elseif angle <= 22.5 + 45 * 6 then 
		py = py - speed
		ty = ty + speed
		-- print("u")
	elseif angle <= 22.5 + 45 * 7 then
		px = px + speed
		py = py - speed 
		tx = tx - speed
		ty = ty + speed 
		-- print("ul")
	elseif angle >  22.5 + 45 * 7 then 	
		-- print("left")
		px = px + speed
		tx = tx - speed
	end 

	local i,j = self:convertToIndex(tx, ty)
	if self:judgeGridByIndex(i,j) then 
		self.contentGroup:setPosition(px, py)
		self.target:setPosition(tx, ty)
	end 
	
end

--检测该下标的对象
function DirectionController:judgeGridByIndex(i,j)
	if self.mapGrids[i][j] then 

		if self.mapGrids[i][j]:getGridType() == RandomList.WALL then 
			return false
		else 
			return true
		end 
	end
	return true
end

--将坐标转换成下标
function DirectionController:convertToIndex(x,y)
	local indexJ = math.ceil((x - 5)/32)
	local indexI = math.ceil((y - 32)/32)
	return indexI,indexJ
end

return DirectionController