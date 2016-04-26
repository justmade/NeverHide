local PosInfo = class("PosInfo")

function PosInfo:ctor (_startPos , _endPos)
    self.startPos = cc.p(_startPos.x , _startPos.y )
    self.endPos   = cc.p(_endPos.x  , _endPos.y )
end

function PosInfo:getRect()
    local rec = cc.Rect(self.startPos.x-1 ,0, self.endPos.x - self.startPos.x +2, display.height)
    return rec
end

return PosInfo
