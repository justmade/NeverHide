local RoguelikeMap  = {}

local RandomHandler = require("app.data.RandomHandler")
 
local EMPTY = "-"

local DOOR =  "D"
--Ξ♠♥Ψ▒°☣
local WALL = "▒"

local CHEST_BOX = "❀"

local BOSS = "♠"

local HEART = "♥"

local ATTACK = "Ψ"

local WATER = "Ξ" 

local ROOM = " "

local PLAYER = "@"

function RoguelikeMap:new(_width,_height)
	math.randomseed(os.time())
	self:init(_width,_height)
end 

function RoguelikeMap:init(_width,_height)
	self.width = _width
	self.height = _height
	self.dungeons = {}
	self.walls = {}

	self.randomHandler = RandomHandler:new()
	self.randomHandler:init()

	for i=1,_height do
		self.dungeons[i] = {}
		for j=1,_width do
			self.dungeons[i][j] = EMPTY
		end
	end
	self:createNewRoom()
	self:dungeonsToString()

	for i=1,30 do
		self:findWall()
	end
	self:dungeonsToString()
		
	-- local sf=string.format
	-- local answer
	-- io.write("What\'s your action?=>")
	-- answer = io.read()
	-- while answer do
	-- 	os.execute("clear")
	-- 	self:playerAction(answer)
	-- 	self:playDungeonsToString()
	-- 	answer = io.read()
	-- end
end

function RoguelikeMap:playerAction(action)
	local deltaX = 0 
	local deltaY = 0
	if action == 'w' then 
		self.dungeons[self.playerPos.x][self.playerPos.y] = ROOM 
		deltaX = 1
		deltaY = 0
	elseif action == 's' then
		self.dungeons[self.playerPos.x][self.playerPos.y] = ROOM 
		deltaX = -1
		deltaY = 0
	elseif action == 'a' then
		self.dungeons[self.playerPos.x][self.playerPos.y] = ROOM 
		deltaX = 0
		deltaY = -1
	elseif action == 'd' then
		self.dungeons[self.playerPos.x][self.playerPos.y] = ROOM 
		deltaX = 0
		deltaY = 1
	elseif action == 'm' then
		self:dungeonsToString()
	end
	if self.dungeons[self.playerPos.x + deltaX][self.playerPos.y + deltaY] ~= WALL then
		self.playerPos.x = self.playerPos.x + deltaX
		self.playerPos.y = self.playerPos.y + deltaY
	end
	self.dungeons[self.playerPos.x][self.playerPos.y] = PLAYER 
	
end

function RoguelikeMap:createNewRoom()
	local roomWidth = math.random(3,self.width/4)
	local roomHeight = math.random(3,self.height/4)
	-- local X = math.random(1,self.width-roomWidth)
	-- local Y = math.random(1,self.height-roomHeight)
	local X = 1
	local Y = 1
	
	for j =Y,Y + roomHeight do
		for i = X,X + roomWidth do
			if i == X or j == Y or i == X + roomWidth or j == Y + roomHeight then 
				self.dungeons[j][i] = WALL
			else
				self.dungeons[j][i] = ROOM
			end			
		end
	end

	self.playerPos = {x =Y + 1,y = X + 1 }
	self.dungeons[self.playerPos.x][self.playerPos.y] = PLAYER 

	local wall = {startX = X , startY = Y , wallWidth = roomWidth , wallHeight = roomHeight}
	print(X,Y,roomWidth,roomHeight)
	table.insert(self.walls,wall)

	-- local direct = self:randomDirection()
	-- local door 
	-- local xL
	-- local yL
	-- if direct == "UP" then
	-- 	door = {math.random(startX + 1 , startX + roomWidth -1),startY + roomHeight}
	-- elseif direct == "DOWN" then
	-- 	door = {math.random(startX + 1 , startX + roomWidth -1),startY}
	-- elseif direct == "LEFT" then
	-- 	door = {startX , math.random(startY + 1 , startY + roomHeight -1)}
	-- elseif direct == "RIGHT" then
	-- 	door = {startX + roomWidth , math.random(startY + 1 , startY + roomHeight -1)}
	-- end
	-- self.dungeons[door[1]][door[2]] = DOOR

end

function RoguelikeMap:findWall()
	local randomWall = math.random(1,#self.walls)
	print("randomWall",randomWall)
	local target = self.walls[randomWall]
	local direct = self:randomDirection()
	local startX 
	local startY
	local roomWidth 
	local roomHeight 
	local doorX
	local doorY
	local xChange 
	local yChange
	print("direct",direct)
	local states = self:juadeBoundary(target)
	if states[direct] == 0 then 
		print("ff")
		self:findWall()
	else
		if direct == "UP" then
			startX = math.random(target.startX , target.startX + math.abs(target.wallWidth) - 3)
			startY = target.startY + target.wallHeight 
			roomWidth = math.random(3,self.width - startX)
			roomHeight = math.random(3,self.height - startY)
			doorX = startX + 1
			doorY = startY
			yChange = 1
			xChange = 0
		elseif direct == "DOWN" then
			startX = math.random(target.startX , target.startX +  math.abs(target.wallWidth) - 3)
			startY = target.startY
			roomWidth = math.random(3,self.width - startX)
			roomHeight = math.random(-1 * startY + 1 ,-3)
			doorX = startX + 1
			doorY = startY
			yChange = -1
			xChange = 0
		elseif direct == "LEFT" then
			startX = target.startX
			startY = math.random(target.startY , target.startY + math.abs(target.wallHeight) - 3)
			roomWidth = math.random(-1 * startX + 1,-3)
			roomHeight =  math.random(3,self.height - startY)
			doorX = startX
			doorY = startY + 1
			yChange = 0
			xChange = -1
		elseif direct == "RIGHT" then
			startX = target.startX + target.wallWidth
			startY = math.random(target.startY , target.startY + math.abs(target.wallHeight) - 3)
			roomWidth = math.random(3,self.width-startX)
			roomHeight =  math.random(3,self.height - startY)
			doorX = startX
			doorY = startY + 1
			yChange = 0
			xChange = 1
		end

		local changeJ = math.abs(roomHeight)/roomHeight 
		local changeI = math.abs(roomWidth)/roomWidth

		roomHeight =math.floor(math.max(math.min(roomHeight,self.height/8),self.height*-1/8))
		roomWidth =math.floor(math.max(math.min(roomWidth,self.width/8),self.width*-1/8))

		if changeJ > 0 then 
			changeJ = 1
		else
			changeJ = -1
		end

		if changeI > 0 then 
			changeI = 1
		else
			changeI = -1
		end

		print(startX,startY,roomWidth,roomHeight)

		for j = startY + yChange , startY + roomHeight , changeJ  do
			for i = startX + xChange,startX + roomWidth,changeI do
				if self.dungeons[j][i] ~= EMPTY then
					print("EMPTY")
					self:findWall()
					return 
				end
			end
		end

		for j = startY  , startY + roomHeight , changeJ  do
			for i = startX ,startX + roomWidth,changeI do
				if i == doorX and j == doorY then 
					self.dungeons[j][i] = DOOR
				elseif i == startX or j == startY or i == startX + roomWidth or j == startY + roomHeight then 
					self.dungeons[j][i] = WALL
				else
					self.dungeons[j][i] = ROOM
				end	
			end
		end

		if changeJ > 0 then changeJ = 0 end  
		if changeI > 0 then changeI = 0 end

		local wall = {startX = startX - changeI * roomWidth, startY = startY - changeJ * roomHeight , 
		wallWidth =  math.abs(roomWidth) , wallHeight =  math.abs(roomHeight)}

		local itemX = math.random(wall.startX + 1 , wall.startX + wall.wallWidth - 1)
		local itemY = math.random(wall.startY + 1 , wall.startY + wall.wallHeight - 1)
		local element =  self.randomHandler:getRandomElement()
		if element == WATER then 
			for i=wall.startX + 1,wall.startX + wall.wallWidth - 1 do
				self.dungeons[itemY][i] = element
			end
		else
			self.dungeons[itemY][itemX] = element
		end

		-- self.dungeons[itemY][itemX] = self.randomHandler:getRandomElement()


		
		table.insert(self.walls,wall)

	end

	
	return true
end

function RoguelikeMap:juadeBoundary(target)
	local startX = target.startX 
	local startY = target.startY  
	local wallWidth = target.wallWidth 
	local wallHeight = target.wallHeight
	local states = {}
	if self.height - (startY + wallHeight) >= 2 then
		states.UP = 1
	else
		states.UP = 0
	end

	if startY > 2 then 
		states.DOWN = 1
	else
		states.DOWN = 0
	end

	if startX > 2 then 
		states.LEFT = 1
	else
		states.LEFT = 0
	end

	if self.width - (startX + wallWidth) >= 2 then
		states.RIGHT = 1
	else
		states.RIGHT = 0
	end

	return states

end

function RoguelikeMap:randomDirection()
	local i = math.random(1,4)
	if i == 1 then
		return "UP"
	elseif i == 2 then
		return "DOWN"
	elseif i == 3 then
		return "LEFT"
	elseif i == 4 then
		return "RIGHT"
	end
end

function RoguelikeMap:dungeonsToString()
	local s = ""
	for i=#self.dungeons, 1 , -1 do
		for j=1, #self.dungeons[i], 1 do
			s = s .. self.dungeons[i][j]
		end
		s = s .. '\n'
	end
	print(s)
end

function RoguelikeMap:playerInfo()
	local info = '\n'.. "+ : " .. 1 .. '\n' .. "o : " .. 1 .. '\n' 
	print(info)
end

function RoguelikeMap:playDungeonsToString()
	local startX = math.max(self.playerPos.x - 5,1)
	local endX = math.min(self.playerPos.x + 5,self.width + 1)

	local startY = math.max(self.playerPos.y - 5,1)
	local endY = math.min(self.playerPos.y + 5,self.height + 1)
	local s = "\n\n\t"
	for i=endX, startX , -1 do
		for j=startY, endY, 1 do
			if i == endX or i == startX then 
				s = s .. '/'
			elseif j == startY or j == endY then 
				s = s .. '|'
			else
				s = s .. self.dungeons[i][j]
			end
			
		end
		s = s .. '\n'..'\t'
	end
	self:playerInfo()
	print(s)
end

function RoguelikeMap:getMapData()
	return self.dungeons
end

return RoguelikeMap


