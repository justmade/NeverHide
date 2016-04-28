local NeverHideApp = class("NeverHideApp", function()
    return display.newScene("NeverHideApp")
end)

local scheduler   = cc.Scheduler
local Role        = require("app.scenes.neverhide.Role")
local PosInfo     = require("app.scenes.neverhide.PosInfo")
local BloodEffect = require("app.scenes.neverhide.HeroUpgradeEffect")
local Vector2D    = require("app.scenes.neverhide.Vector2D")
local TouchController = import(".TouchController")
local Collision   = require("app.data.Collision")


function NeverHideApp:ctor()
    self.safeArea  = {}
    self.speed     = 2
    self.cellGap   = 50
    --存储所有生成的矩形
    self.allPos    = {}
    self.levelWidth = 0
    self.levelHeight = 0
    self.upData = {}
    self.downData = {}
    self.downSpeed = 3;
    self.currentLevel = 1;
    self.playerSpeed = Vector2D.new(5,0)
    self.moveSpeed = Vector2D.new(0,0)
    self:onEnter();

end

function NeverHideApp:onEnter()


  math.randomseed(os.time())
  local bg = display.newSprite("gfx/bg.png")
  self:addChild(bg)
  bg:setAnchorPoint(cc.p(0,0))

  local r = Role.new(40,300);
  self:addChild(r)
  self.role = r

  self.downContainer = display.newSprite();
  self.upContainer = display.newSprite();

  self:addChild(self.upContainer);
  self:addChild(self.downContainer);

  self:resetMap()
  self:addTouchListener()

end

--读取新的地图
function NeverHideApp:resetMap()
  self.downContainer:removeAllChildrenWithCleanup(true)
  self.upContainer:removeAllChildrenWithCleanup(true)
  local MapInfo     = require("app.data.mapdata.Level"..self.currentLevel)
  --获取tield地图
  local t = MapInfo.layers
  self.upData   = t[1].data;
  self.downData = t[2].data;
  self.levelWidth = t[1].width;
  self.levelHeight = t[1].height;
  self:drawTiledMap(self.upData , self.upContainer);
  self:drawTiledMap(self.downData , self.downContainer);

  self:findGround()
  self:findUpGround();
  self:setRoleByPosX(self.role:getPositionX())
  self:resetUpGround();

  local function sortRectByPosX(a,b)
    return a.x < b.x
  end

  table.sort(self.downGroundRects , sortRectByPosX)
  table.sort(self.upGroundRects , sortRectByPosX)
  -- scheduleUpdate()
  self:scheduleUpdate(handler(self, self.update))
  -- self.currentEnterFrame = scheduler.scheduleUpdate(handler(self,self.update))
end



function NeverHideApp:resetUpGround()
  local oriY = self.upContainer:getPositionY();
  self.upContainer:setPositionY(oriY + self.levelHeight * self.cellGap);
  for i,v in ipairs(self.upGroundRects) do
    v.y = v.y + self.levelHeight * self.cellGap
  end
end

--根据tiled地图绘制
function NeverHideApp:drawTiledMap(data,container)
  for i,v in ipairs(data) do
    if v ~= 0 then
      local id = v-1;
      local index = i-1;
      local posX = (index % self.levelWidth) * self.cellGap
      local posY = self.levelHeight * self.cellGap -  math.floor(index / self.levelWidth) * self.cellGap
      local tX   = id % 5
      local tY   = math.floor(id / 5)
      local grassLeft = display.newSprite("gfx/ground.png")
      grassLeft:setTextureRect(cc.rect(tX * self.cellGap , tY * self.cellGap ,self.cellGap,self.cellGap));
      grassLeft:setPosition(posX,posY)
      grassLeft:setAnchorPoint(cc.p(0,0))
      container:addChild(grassLeft);
    end
  end
end

--找到下层的路面
function NeverHideApp:findGround()
    --下层路面每个地形的rect数组
    self.downGroundRects = {}
    self.allGroundRects = {}
    for i,v in ipairs(self.downData) do
        if v ~= 0 then
          local index = i-1;
          local posX = (index % self.levelWidth) * self.cellGap
          local posY = self.levelHeight * self.cellGap -  math.floor(index / self.levelWidth) * self.cellGap
          table.insert(self.allGroundRects , cc.rect(posX,posY,self.cellGap,self.cellGap))
          if self.downGroundRects[index % self.levelWidth +1 ] == nil then
              self.downGroundRects[index % self.levelWidth +1] = cc.rect(posX,posY,self.cellGap,self.cellGap)
          end
        end
    end
end

--查找上层路面的最低点
function NeverHideApp:findUpGround()
  self.upGroundRects = {}
  for i,v in ipairs(self.upData) do
      if v ~= 0 then
        local index = i-1;
        local posX = (index % self.levelWidth) * self.cellGap
        local posY = self.levelHeight * self.cellGap -  math.floor(index / self.levelWidth) * self.cellGap
        self.upGroundRects[index % self.levelWidth +1] = cc.rect(posX,posY,self.cellGap,self.cellGap)
      end
  end
end

function NeverHideApp:onGameUpdate()
  self.role:applyFroce(Vector2D.new(0,-2))
  --上下左右 用于标记那个方向上已经进行过碰撞检测了
  local collisionState = {0,0,0,0}
  for i,v in ipairs(self.allGroundRects) do
    local state = Collision.rectIntersectsRect(cc.rect(self.role:getPositionX() - 15 , self.role:getPositionY()-10 , 30,30),v)

    --  if cc.rectContainsPoint(v , cc.p(self.role:getPositionX() , self.role:getPositionY()-10)) then
    if state == "top" and collisionState[1] ~= 1 and self.role:jumpState() == false then
      collisionState[1] = 1
        -- print("state",state,i);
        self.role.speed.y = 0
        self.role:applyFroce(Vector2D.new(0,2))
        local rX = self.role:getPositionX()
        self:setRoleByPosX(rX)
      --  break
    elseif state == "left" and collisionState[3] ~= 1 then
      collisionState[3] = 1
        -- print("state",state,i);
        self.role:applyFroce(Vector2D.new(-5,0))
        -- self.role:applyFroce(Vector2D.new(0,2))
        self.role:setPosX(v.x - 30)
    elseif state == "right" and collisionState[4] ~= 1 then
        print("state",state,i);
      collisionState[4] = 1
      self.role:applyFroce(Vector2D.new(5,0))
      self.role:setPosX(v.x + v.width + 15)
   end
  end
end

function NeverHideApp:addTouchListener()
    self.touchController = TouchController.new()
    self:addChild(self.touchController)
end


function NeverHideApp:onTouch(event)
  dump(event)
	local point = event.points["0"]
	if event.name == "began" then
      self.touchX = point.x
      self.touchY = point.y
      if self.touchX < display.width/2 then
          self.role:applyFroce(Vector2D.new(0,30))
          return true;
      end
      -- self.role:setPositionX(point.x)
      -- local y =  self.role:getPositionY()
      -- self.role:setPositionY(y + 50);
  elseif event.name == "moved" then
      -- self.role:setPositionX(point.x)
      if point.x - self.touchX > 10 then
        self.moveState = 1
        self.moveSpeed = self.playerSpeed:Mult(self.playerSpeed , 1);
      elseif point.x - self.touchX < -10 then
        self.moveState = -1
        self.moveSpeed = self.playerSpeed:Mult(self.playerSpeed , -1);
      else

      end
      self.touchX = point.x
      self.touchY = point.y
  elseif event.name == "ended" then
      self.moveSpeed:mult(0);
  else

  end


  -- local rX = self.role:getPositionX()
  -- self:setRoleByPosX(rX)
	return true
end


--根据任务的X坐标查找到对应地面的Y坐标 设置位置
function NeverHideApp:setRoleByPosX(posx)
  for i,v in ipairs(self.downGroundRects) do
    if posx <= (v.x + v.width) then
        self.role:setPosY(v.y + v.height)
        break
    end
  end
end

function NeverHideApp:update(dt)
  local isHit = self:checkSafeArea(self.role)

  if isHit then
    self:getResult(true)
    scheduler.unscheduleGlobal(self.currentEnterFrame)
  end


  if self:checkGoundHit() then
      scheduler.unscheduleGlobal(self.currentEnterFrame)
      self.currentLevel = self.currentLevel+1
      if self.currentLevel >3 then
          self.currentLevel =1
      end
      scheduler.performWithDelayGlobal(handler(self,self.resetMap), 1)
  end
  self:onGameUpdate();
  local mV = self.touchController.moveVec;
  local jV = self.touchController.jumpVec
  self.role:applyFroce(jV)
  self.role:applyFroce(mV:Mult(mV , 5));

  -- self:onGameUpdate();
  self.role:onUpdate();
  jV:mult(0)
end

--墙壁合并中
function NeverHideApp:onWallClosing()
  for i=1,#self.upLines do
      self.upLines[i].y = self.upLines[i].y - self.speed
  end
  self:onDrawLine(self.upLines)

  for i=1,#self.downLines do
      self.downLines[i].y = self.downLines[i].y + self.speed
  end
  self:onDrawLine(self.downLines)
  self.role:setPositionY(self.downLines[1].y)
end

--获取结果
function NeverHideApp:getResult(isFailed)
    if isFailed then
      local effect = BloodEffect.new();
      self:addChild(effect)
      effect:setPosition(cc.p(self.role:getPositionX() , self.role:getPositionY() + 100))
      self.role:playAnimation()
      -- self:resetGame()
      local resetTimer =  scheduler.performWithDelayGlobal(handler(self,self.resetGame), 1)
    end
end

function NeverHideApp:resetGame(dt)
    self.role:displayRole()
    self:resetUpGround()
    self.currentEnterFrame = scheduler.scheduleUpdateGlobal(handler(self,self.update))
end

function NeverHideApp:createUpLine()
  -- self.totalLength = 800;
  self.startPos = cc.p(1,display.height/self.cellGap -4);
  self.endPos   = cc.p(display.width/self.cellGap -1 ,display.height/self.cellGap -4);
  self.upLines  = {}
  --凸起起始点
  local p1      = cc.p(math.random(self.startPos.x, self.endPos.x - 2) , self.startPos.y);
  --凸起对面点
  local p2      = cc.p(math.random(p1.x + 1 , p1.x + 2) ,self.startPos.y + math.random(1,3));


  for i = 1,math.floor(display.width/self.cellGap)+1 do
    table.insert(self.upLines , cc.p(i,math.floor(display.height/self.cellGap)-4))
    print("createUpLine",i)
  end

  -- local p3      = cc.p(p1.x , p2.y);
  --
  -- local p4      = cc.p(p2.x , p1.y);
  --
  -- self.drawNode:drawLine(self.startPos,p1,2,self.lineColor);
  -- self.drawNode:drawLine(p1,p3,2,self.lineColor);
  -- self.drawNode:drawLine(p3,p2,2,self.lineColor);
  -- self.drawNode:drawLine(p2,p4,2,self.lineColor);
  -- self.drawNode:drawLine(p4,self.endPos,2,self.lineColor);
  --
  -- self.upLines = {self.startPos,p1,p3,p2,p4,self.endPos}
  --
  local pInfo = PosInfo.new(p1,p2)
  self.allPos = {pInfo}
  --
  -- -- table.insert(self.safeArea , pInfo)
  -- self.safeArea = {pInfo}

  self:generateLine();
end


--将生成的矩形安装X轴排序
-- function NeverHideApp:sortRectByPosX(a,b)
--   return a.x < b.x
-- end



--判断垂直方向上，上下矩形是否有碰撞
function NeverHideApp:checkGoundHit()
    for i,v in ipairs(self.upGroundRects) do
        local upRect = v
        local downRect = self.downGroundRects[i]
        local b = cc.rectIntersectsRect(upRect , downRect)
        return b
    end
end

--检测上方的路面是否和人物碰到
function NeverHideApp:checkSafeArea(_role)
    for i,v in ipairs(self.upGroundRects) do
        local rect = v;
        --80为碰撞区域调整的位置，FixME
        local b =  cc.rectContainsPoint(rect , cc.p(_role:getPositionX() , _role:getPositionY() + 80))
        if b then return b end
    end
    return false
end



function NeverHideApp:onDrawLine(drawTable)
    for i=1,#drawTable do
        -- self.drawNode:drawLine(drawTable[i],drawTable[i+1],2,self.lineColor);
        -- if (i - 3) % 4 == 0 then
        --   local grassLeft = display.newSprite("gfx/wall_1.png")
        --   self:addChild(grassLeft)
        --   grassLeft:setPosition(drawTable[i].x * 50 , drawTable[i].y * 50);
        -- elseif i % 4 == 0  then
        --   local grassLeft = display.newSprite("gfx/wall_3.png")
        --   self:addChild(grassLeft)
        --   grassLeft:setPosition(drawTable[i].x * 50 , drawTable[i].y * 50);
        -- else
        --   local grassLeft = display.newSprite("gfx/wall_2.png")
        --   self:addChild(grassLeft)
        --   grassLeft:setPosition(drawTable[i].x * 50 , drawTable[i].y * 50);
        -- end
        local grassLeft = display.newSprite("gfx/ground.png")
        grassLeft:setTextureRect(cc.rect(50,0,50,50));
        self:addChild(grassLeft)
        grassLeft:setPosition(drawTable[i].x * 50 , drawTable[i].y * 50)
    end
end


return NeverHideApp
