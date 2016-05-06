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
local BlockData   = require("app.data.BlockData")


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
    --天花板下降的距离
    self.ceilOffset = 0;

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
  local MapInfo     = require("app.data.mapdata.stymap"..self.currentLevel)
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
  -- self:setRoleByPosX(self.role:getPositionX())
  self:resetUpGround();

  local function sortRectByPosX(a,b)
    return a:getRect().x < b:getRect().x
  end

  table.sort(self.downGroundRects , sortRectByPosX)
  table.sort(self.upGroundRects , sortRectByPosX)
  self.role:setPosX(40)
  self.role:setPosY(300)
  -- scheduleUpdate()
  self:scheduleUpdate(handler(self, self.update))
  -- self.currentEnterFrame = scheduler.scheduleUpdate(handler(self,self.update))
end



function NeverHideApp:resetUpGround()
  self.ceilOffset = 0
  self.upContainer:setPositionY(self.levelHeight * self.cellGap);
  for i,v in ipairs(self.upAllGroundRects) do
    local rect = v:getRect()
    rect.y =  rect.y +self.levelHeight * self.cellGap
  end
end

--根据tiled地图绘制
function NeverHideApp:drawTiledMap(data,container)
  for i,v in ipairs(data) do
    if v ~= 0 then
      local id = v-1;
      local index = i-1;
      local posX = (index % self.levelWidth) * self.cellGap
      local posY = self.levelHeight * self.cellGap -  math.floor(index / self.levelWidth) * self.cellGap - self.cellGap
      local tX   = id % 7
      local tY   = math.floor(id / 7)
      local grassLeft = display.newSprite("gfx/mapsheet.png")
      grassLeft:setTextureRect(cc.rect(tX * (self.cellGap+2) , tY *(self.cellGap+2) ,self.cellGap,self.cellGap));
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
          local posY = self.levelHeight * self.cellGap -  math.floor(index / self.levelWidth) * self.cellGap - self.cellGap
          local r = cc.rect(posX,posY,self.cellGap,self.cellGap)
          local bd
          if self.downGroundRects[index % self.levelWidth +1 ] == nil then
            bd = BlockData.new(r,BlockData.GROUND);
            self.downGroundRects[index % self.levelWidth +1] = bd
          else
            bd = BlockData.new(r,BlockData.NORMAL);
          end
          table.insert(self.allGroundRects , bd)
        end
    end
end

--查找上层路面的最低点
function NeverHideApp:findUpGround()
  self.upGroundRects = {}
  self.upAllGroundRects = {}
  for i,v in ipairs(self.upData) do
      if v ~= 0 then
        local index = i-1;
        local posX = (index % self.levelWidth) * self.cellGap
        local posY = self.levelHeight * self.cellGap -  math.floor(index / self.levelWidth) * self.cellGap - self.cellGap
        local r    = cc.rect(posX,posY,self.cellGap,self.cellGap)
        local bd = BlockData.new(r,BlockData.CEIL);
        self.upGroundRects[index % self.levelWidth +1] = bd
        table.insert(self.upAllGroundRects , bd)
      end
  end
end

function NeverHideApp:closingUpGroud()
    self.ceilOffset = self.ceilOffset - 1;
    local posY = self.upContainer:getPositionY()
    self.upContainer:setPositionY(posY - 1)
    for i,v in ipairs(self.upAllGroundRects) do
      local rect = v:getRect();
      rect.y = rect.y - 1
    end
end



--人物与障碍碰撞
function NeverHideApp:onRoleCollisionGround()
  self.role:applyFroce(Vector2D.new(0,-2))
  --上下左右 用于标记那个方向上已经进行过碰撞检测了
  local collisionState = {0,0,0,0}

  for i,v in ipairs(self.allGroundRects) do
    local blockRect = v:getRect();
    local blockType = v:getType();

    local state = Collision.rectIntersectsRect(cc.rect(self.role:getPositionX() - 20 , self.role:getPositionY() - 5 , 40,30),blockRect)
    -- 与砖面上面的碰撞只发生在地面砖块上
    if state == "top" and collisionState[1] ~= 1 and self.role:jumpState() == false and blockType == BlockData.GROUND then
      print("state",state,i);
      collisionState[1] = 1
      self.role.speed.y = 0
      self.role:applyFroce(Vector2D.new(0,2))
      local rX = self.role:getPositionX()
      self.role:setPosY(blockRect.y + blockRect.height)
    elseif state == "left" and collisionState[3] ~= 1 then
      collisionState[3] = 1
      self.role:applyFroce(Vector2D.new(-5,0))
      self.role:setHSpeed(0)
    elseif state == "right" and collisionState[4] ~= 1 then
      collisionState[4] = 1
      self.role:applyFroce(Vector2D.new(5,0))
      self.role:setHSpeed(0)
   end
  end
end

--检测上方的路面是否和人物碰到
function NeverHideApp:onRoleCollisionCeil()
    local collisionState = {0,0,0,0}

  for i,v in ipairs(self.upAllGroundRects) do
      local blockRect = v:getRect();
      local blockType = v:getType();

      local state = Collision.rectIntersectsRect(cc.rect(self.role:getPositionX() - 20 , self.role:getPositionY() - 5 , 40,40),blockRect)
      if state == "bottom" and collisionState[1] ~= 1 then
        print("state",state,i);
        collisionState[1] = 1
        self.role.speed.y = 0
        self.role:applyFroce(Vector2D.new(0,-3))
        -- local rX = self.role:getPositionX()
        -- self.role:setPosY(blockRect.y + blockRect.height)
      elseif state == "left" and collisionState[3] ~= 1 then
        collisionState[3] = 1
        self.role:applyFroce(Vector2D.new(-5,0))
        self.role:setHSpeed(0)
      elseif state == "right" and collisionState[4] ~= 1 then
        collisionState[4] = 1
        self.role:applyFroce(Vector2D.new(5,0))
        self.role:setHSpeed(0)
     end
  end
end

--返回是否是地面表层的砖块
function NeverHideApp:findeRectInGround(rect)
  for i,v in ipairs(self.downGroundRects) do
    if v == rect then
      return true
    end
  end
  return false
end

function NeverHideApp:addTouchListener()
    self.touchController = TouchController.new()
    self:addChild(self.touchController)
end




--根据任务的X坐标查找到对应地面的Y坐标 设置位置
function NeverHideApp:setRoleByPosX(posx)

  for i,v in ipairs(self.downGroundRects) do
    if posx <= (v.x + v.width) then
        self.role:setPosY(v.y + v.height)
        -- print("setRoleByPosX" , v.y + v.height)
        break
    end
  end
end

function NeverHideApp:update(dt)
  local isHit = self:onRoleCollisionCeil(self.role)
  --
  -- if isHit then
  --     self:unscheduleUpdate()
  -- end
  --
  --

  if self:checkGoundHit() then
      print("checkGoundHit")
      self:unscheduleUpdate()
      -- self.currentLevel = self.currentLevel + 1
      -- if   self.currentLevel > 3 then  self.currentLevel = 1 end
      self:resetMap()
  end
  self:onRoleCollisionGround();
  local mV = self.touchController.moveVec;
  local jV = self.touchController.jumpVec
  self.role:applyFroce(jV)
  self.role:applyFroce(mV:Mult(mV , 5));

  self.role:onUpdate();
  jV:mult(0)

  self:closingUpGroud();
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




--判断垂直方向上，上下矩形是否有碰撞
function NeverHideApp:checkGoundHit()
    -- for i,v in ipairs(self.upAllGroundRects) do
    --    for j,k in ipairs(self.allGroundRects) do
    --       local upRect = v:getRect()
    --       local downRect = k:getRect();
    --       local b = cc.rectIntersectsRect(upRect , downRect)
    --       if b then return b end
    --    end
    -- end
    -- return false

    for i,v in ipairs(self.upGroundRects) do
      local upRect = v:getRect()
      local downRect = self.downGroundRects[i]:getRect()
      local b = cc.rectIntersectsRect(upRect , downRect)
      if b then return b end
    end
    return false
end







return NeverHideApp
