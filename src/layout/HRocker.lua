local HRocker = class("HRocker",function()
    return cc.Layer:create()
end)

--enum
local tagForHRocker =
{
    tag_rocker = 1,
    tag_rockerBG = 2
}

local tagDirection =
{
    rocker_stay = 1,
    rocker_right = 2,
    rocker_up = 3,
    rocker_left = 4,
    rocker_down = 5
}

--create rocker
function HRocker.create(rocker_pos)
    local hrocker = HRocker.new()
    hrocker:addChild(hrocker:createRockerBG(rocker_pos),0,tagForHRocker.tag_rockerBG)
    hrocker:addChild(hrocker:createRocker(rocker_pos),1,tagForHRocker.tag_rocker)
    return hrocker
end

function HRocker:ctor()
    self.rockerBGPosition = nil
    self.rockerBGR = nil
    self.rockerDirection = 0
    self.isCanMove = false
    self.rockerRun = false
end

function HRocker:createRockerBG(rocker_pos)
    local rocker_bg = cc.Sprite:create("Direction_bc.png")
    rocker_bg:setPosition(rocker_pos)
    rocker_bg:setVisible(false)
    rocker_bg:setScale(0.8)
    self.rockerBGPosition = rocker_pos
    self.rockerBGR = rocker_bg:getContentSize().width*0.5
    return rocker_bg
end

function HRocker:createRocker(rocker_pos)
    local rocker = cc.Sprite:create("Direction_bt.png")
    rocker:setPosition(rocker_pos)
    rocker:setVisible(false)
    rocker:setScale(0.8)
    return rocker
end

-- start(display rocker and touch listener)
function HRocker:startRocker(_isStopOther)
    local rocker = self:getChildByTag(tagForHRocker.tag_rocker)
    rocker:setVisible(true)
    local rocker_bg = self:getChildByTag(tagForHRocker.tag_rockerBG)
    rocker_bg:setVisible(true)
    
    local function onTouchBegan(touch, event)
        local point = touch:getLocation()
        local rocker = self:getChildByTag(tagForHRocker.tag_rocker)

        if(cc.rectContainsPoint(rocker:getBoundingBox(),point)) then
            self.isCanMove = true
        end
        return true
    end
    
    local function onTouchMoved(touch, event)
        if(not self.isCanMove)then
            return 
        end
        local point = touch:getLocation()
        local rocker = self:getChildByTag(tagForHRocker.tag_rocker)
        local angle = self:getRad(self.rockerBGPosition,point)
        -- whether the distance is greater than the radius of the bg circle
        if(math.sqrt(math.pow((self.rockerBGPosition.x - point.x),2) + math.pow((self.rockerBGPosition.y - point.y),2)) >= self.rockerBGR) then
            rocker:setPosition(cc.pAdd(self:getAnglePosition(self.rockerBGR,angle),cc.p(self.rockerBGPosition.x, self.rockerBGPosition.y)))
        else
            rocker:setPosition(point)
        end

        if(angle >= -math.pi / 4 and angle < math.pi / 4) then
            self.rockerDirection = tagDirection.rocker_right
            self.rockerRun = false
        elseif(angle >= math.pi / 4 and angle < math.pi * 3 / 4)then
            self.rockerDirection = tagDirection.rocker_up
        elseif((angle >= math.pi * 3 / 4 and angle < math.pi) or (angle >= -math.pi and angle < -math.pi * 3 / 4))then
            self.rockerDirection = tagDirection.rocker_left
            self.rockerRun = true
        elseif(angle >= -math.pi * 3 / 4 and angle < -math.pi / 4) then
            self.rockerDirection = tagDirection.rocker_down
        end
    end
    
    local function onTouchEnded(touch, event)
        if(not self.isCanMove) then
            return
        end

        local rocker_bg = self:getChildByTag(tagForHRocker.tag_rockerBG)
        local rocker = self:getChildByTag(tagForHRocker.tag_rocker)
        rocker:stopAllActions()
        rocker:runAction(cc.MoveTo:create(0.08,cc.p(rocker_bg:getPosition())))
        self.isCanMove = false
        self.rockerDirection = tagDirection.rocker_stay
    end
    
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

-- stop(hiden rocker and cancel listener)
function HRocker:stopRocker(_isStopOther)
    local rocker = self:getChildByTag(tagForHRocker.tag_rocker)
    rocker:setVisible(false)
    local rocker_bg = self:getChildByTag(tagForHRocker.tag_rockerBG)
    rocker_bg:setVisible(false)
end

-- get angle between rocker and touch point
function HRocker:getRad(pos1, pos2)
	local px1 = pos1.x
	local py1 = pos1.y
	local px2 = pos2.x
	local py2 = pos2.y
	
	xdis = px2 - px1
	ydis = py2 - py1
	dis = math.sqrt(math.pow(xdis,2) + math.pow(ydis,2))
	cosAngle = xdis / dis
	rad = math.acos(cosAngle)
	--attention: when touch y < rocker y, we need to get the opposite value
	if (py2 < py1) then
	   rad = -rad
	end
	
	return rad
end

function HRocker:getAnglePosition(r, angle)
    return cc.p(r * math.cos(angle), r * math.sin(angle))
end


return HRocker