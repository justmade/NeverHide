local BlockData = class("BlockData")

BlockData.GROUND = "ground"

BlockData.CEIL = "ceil"

BlockData.NORMAL = "normal"

BlockData.DIAMOND = "diamond"


function BlockData:ctor (rect , type , colorID , tiledID)
    self.blockRect = rect
    self.blockType = type
    self.colorID   = tonumber(colorID)
    self.tiledID   = tiledID
end

function BlockData:getRect()
    return self.blockRect
end

function BlockData:getType()
    return self.blockType
end

function BlockData:getColorID()
    return self.colorID
end

function BlockData:getTiledID()
    return self.tiledID
end

return BlockData
