local BlockData = class("BlockData")

BlockData.GROUND = "ground"

BlockData.CEIL = "ceil"

BlockData.NORMAL = "normal"


function BlockData:ctor (rect , type , id)
    self.blockRect = rect
    self.blockType = type
    self.colorID   = id
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

return BlockData
