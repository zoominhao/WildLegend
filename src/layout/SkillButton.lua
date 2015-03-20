local SkillButton = class("SkillButton",function()
    return cc.Layer:create()
end)

--create hero
function SkillButton.create(foreName, backName, cdtime)
    local skillButton = SkillButton.new()
    skillButton:createSkillButton(foreName, backName, cdtime)  
    return skillButton
end

function SkillButton:ctor()
    self.foreground = nil   --light image
    self.background = nil   --dark image
    self.progressTimer = nil  --skill effect  
    self.isSkilling = false
    self.skillCount = 0
    self.cdtime = 0
end


function SkillButton:createSkillButton(foreName, backName, cdtime)
    self.foreground = cc.Sprite:create(foreName)
    self:addChild(self.foreground, 1)
    self.background = cc.Sprite:create(backName)
    self.progressTimer = cc.ProgressTimer:create(self.background)
    self:addChild(self.progressTimer, 2)
    self.cdtime = cdtime
    return true
end

function SkillButton:skillAnimation()
    --cd effect
    self.progressTimer:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
    local waitTime = cc.ProgressTo:create(self.cdtime, 100)
    --call back
    local function skillEnd()
        self.progressTimer:setVisible(false)
        self.progressTimer:setPercentage(0)
        self.isSkilling = false
        self.skillCount = 0
    end
    local callFunc = cc.CallFunc:create(skillEnd,{})
    local act = cc.Sequence:create(waitTime,callFunc,nil)
    self.progressTimer:setVisible(true)
    self.isSkilling = true
    self.progressTimer:runAction(act) 
end

function SkillButton:startSkill(hero)
    local function onTouchBegan(touch, event)
        return true   --must return true to support touch
    end
    --local function onTouchMoved(touch, event)
    --end
    local function onTouchEnded(touch, event)
        if(self.isSkilling or hero.isSkilling) then
            return
        end
        
        local touchPoint = touch:getLocation()
        touchPoint = self.foreground:convertToNodeSpaceAR(touchPoint)
        if(cc.rectContainsPoint(self.foreground:getBoundingBox(),touchPoint)) then
            self:skillAnimation()
        end
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    --listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

return SkillButton
