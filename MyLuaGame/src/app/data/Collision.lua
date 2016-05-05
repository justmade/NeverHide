local Collision = {}

--用于碰撞检测，返回的值是表明 A在B的方位
function Collision.rectIntersectsRect(rectA,rectB)
  local vx = (rectA.x + rectA.width) - (rectB.x + rectB.width)
  local vy = (rectA.y + rectA.height) - (rectB.y + rectB.height)

  local offsetX
  if vx < 0 then
    offsetX = rectA.width + rectB.width - ((rectB.x -  rectA.x) + rectB.width)
  else
    offsetX = rectA.width + rectB.width - ((rectA.x -  rectB.x) + rectA.width)
  end
  local offsetY
  if vy < 0 then
    offsetY = rectA.height + rectB.height - ((rectB.y -  rectA.y) + rectB.height)
  else
    offsetY = rectA.height + rectB.height - ((rectA.y -  rectB.y) + rectA.height)
  end



  if offsetX > 0 and offsetY > 0 then
    --如果Y轴方向上重叠的部分在10个像素的话 ，说明在上方 此处还需要修改
    if offsetX >= offsetY or offsetY <= 10 then
      if vy > 0 then
        --Top
        return "top"
      else
        return "bottom"
        --Bottom
      end
    else
      if vx < 0 then
          --LEFT
          return "left"
      else
          --RIGHT
          return "right"
      end
    end
  else
    return "nothing"
  end
end

return Collision
