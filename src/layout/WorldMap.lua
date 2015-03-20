local WorldMap = class("WorldMap",function()
    return cc.Node:create()
end)

--create button   
function WorldMap.create(mapName, windowSize)
    local worldMap = WorldMap.new()
    worldMap:createMap(mapName, windowSize)
    return worldMap
end

function WorldMap:ctor()
   self.map = nil
end

function WorldMap:createMap(mapName, windowSize)
    self.map = cc.Sprite:create(mapName)
    self.map:setAnchorPoint(cc.p(0,0))
    self:setAnchorPoint(cc.p(0,0))
    self:addChild(self.map)
end

function WorldMap:MoveMap(hero, visibleSize)
	if(hero:getPositionX() == visibleSize.width/2)then -- when sprite in the middle, the map starts to move
	   if(hero.heroDirection)then
	       self:setPosition(self:getPositionX() + 1, self:getPositionY())
	   else    
	       self:setPosition(self:getPositionX() - 1, self:getPositionY())
	   end
	end
end

function WorldMap:judgeMap(hero, visibleSize)
    if((self:getPositionX() == -(self.map:getContentSize().width - visibleSize.width) and not hero.heroDirection)
        or (self:getPositionX() == 0 and hero.heroDirection))then -- out of range
	   return true
	else
	   return false
	end   
end

return WorldMap