local BlockData = class("BlockData")

BlockData.GROUND = "ground"

BlockData.CEIL = "ceil"

BlockData.NORMAL = "normal"


function BlockData:ctor (rect , type)
    self.blockRect = rect
    self.blockType = type
end

function BlockData:getRect()
    return self.blockRect
end

function BlockData:getType()
    return self.blockType
end

return BlockData
