local Infantry = class("Infantry",function()
    return cc.Node:create()
end)


--create infantry
function Infantry.create(frameCache, infantryName, infantryActTbl, bloodbgName, bloodfgName, sceneNum, seedNum)
    local infantry = Infantry.new()
    infantry:createInfantry(frameCache, infantryName, infantryActTbl, bloodbgName, bloodfgName, sceneNum, seedNum)
    return infantry
end

function Infantry:ctor()
    self.isRunning = false    -- run animation stopped
    self.isAttack = false  -- attack animation stopped
    self.infantryDirection = true  -- face left
    self.infantryName = nil
    self.infantrySprite = nil
    self.infantryBlood = nil
    self.frameCache = nil
    self.infantryActTbl = nil
    self.sceneNum = 1
    self.dis = 10000.0

    self.isHurt = false
    self.isDead = false

    self.word = nil

    self.schedulerID_patrol = nil
    self.schedulerID_follow = nil
    
    self.seedNum = 0
end

function Infantry:getSprite()
    return self.infantrySprite
end

function Infantry:createInfantry(frameCache, infantryName, infantryActTbl, bloodBg, bloodFg, sceneNum, seedNum)
    self.seedNum = seedNum
    --self.infantrySprite = cc.Sprite:create(infantryName)
    self.infantrySprite = cc.Sprite:createWithSpriteFrame(frameCache:getSpriteFrame(infantryName))
    self.infantrySprite:setFlippedX(self.infantryDirection)
    self.infantryName = infantryName
    self.frameCache = frameCache
    self.infantryActTbl = infantryActTbl
    self.sceneNum = sceneNum
    self:addChild(self.infantrySprite)
    --add blood bar
    local ProgressView_node = require("character.ProgressView")
    self.infantryBlood = ProgressView_node.create()
    if(self.infantryDirection) then
        self.infantryBlood:setPosition(cc.p(self.infantrySprite:getPositionX() + 20, self.infantrySprite:getPositionY() + 50))
    else
        self.infantryBlood:setPosition(cc.p(self.infantrySprite:getPositionX() - 20, self.infantrySprite:getPositionY() + 50))
    end

    self.infantryBlood:setBackgroundTexture(bloodBg)
    self.infantryBlood:setForegroundTexture(bloodFg)
    self.infantryBlood:setTotalProgress(50.0 * sceneNum)
    self.infantryBlood:setCurrentProgress(50.0 * sceneNum)
    self:addChild(self.infantryBlood)

    --add fly word
    local FlyWord_node = require("character.FlyWord")
    self.word = FlyWord_node.create("-10", 30, cc.p(0,0))
    self:addChild(self.word, 2)

    local function onNodeEvent(event)
        if "exit" == event then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID_patrol)
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID_follow)
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

function Infantry:runAnimation(frameCache, actName, num, runDirection)
    if(self.infantryDirection ~= runDirection) then
        self.infantryDirection = runDirection
        self.infantrySprite:setFlippedX(runDirection)
    end

    if(self.isRunning or self.isAttack or self.isHurt or self.isDead) then
        return
    end 

    -- add the images into the sprite cache
    --local frameCache = cc.SpriteFrameCache:getInstance()
    --frameCache:addSpriteFrames(plistName,pngName)

    -- use a list to store all the spriteFrameCache
    local frameArray = {}
    for i = 1, num
    do
        local frame = frameCache:getSpriteFrame(string.format("%s%d.png",actName,i))
        table.insert(frameArray,frame)
    end

    local animation = cc.Animation:createWithSpriteFrames(frameArray)
    if(self.infantryDirection ~= runDirection) then
        self.infantryDirection = runDirection
    end

    animation:setDelayPerUnit(0.1)
    animation:setRestoreOriginalFrame(true)
    animation:setLoops(-1)

    -- package the animation into an action
    local act = cc.Animate:create(animation)

    self.isRunning = true
    self.infantrySprite:runAction(act)
end

function Infantry:runEnd()
    if(not self.isRunning) then
        return
    end
    self.infantrySprite:stopAllActions()

    self:removeChild(self.infantrySprite, true)   
    self.infantrySprite = cc.Sprite:createWithSpriteFrame(self.frameCache:getSpriteFrame(self.infantryName))
    self.infantrySprite:setFlippedX(self.infantryDirection)
    self:addChild(self.infantrySprite)
    self.isRunning = false

    if(self.infantryBlood ~= nil) then
        if(self.infantryDirection) then
            self.infantryBlood:setPosition(cc.p(self.infantrySprite:getPositionX() + 20, self.infantrySprite:getPositionY() + 50))  
        else
            self.infantryBlood:setPosition(cc.p(self.infantrySprite:getPositionX() - 20, self.infantrySprite:getPositionY() + 50))
        end 
    end
end

function Infantry:attackAnimation(frameCache, actName, num, runDirection)
    if(self.isAttack or self.isRunning or self.isHurt or self.isDead)then
        return
    end
    -- add the images into the sprite cache
    --local frameCache = cc.SpriteFrameCache:getInstance()
    --frameCache:addSpriteFrames(plistName,pngName)
    -- use a list to store all the spriteFrameCache
    local frameArray = {}
    for i = 1, num
    do
        local frame = frameCache:getSpriteFrame(string.format("%s%d.png",actName,i))
        table.insert(frameArray,frame)
    end

    local animation = cc.Animation:createWithSpriteFrames(frameArray)

    animation:setDelayPerUnit(0.1)
    animation:setRestoreOriginalFrame(true)
    animation:setLoops(1)

    local function attackEnd()
        self:removeChild(self.infantrySprite, true)
        self.infantrySprite = cc.Sprite:createWithSpriteFrame(frameCache:getSpriteFrame(self.infantryName))
        self.infantrySprite:setFlippedX(self.infantryDirection)
        self:addChild(self.infantrySprite)
        self.isAttack = false
    end
    -- package the animation into an action
    local act = cc.Animate:create(animation)
    -- create callback, call attackEnd after attack
    local callFunc = cc.CallFunc:create(attackEnd,{})
    --create continuous action
    local attackAct = cc.Sequence:create(act,callFunc,nil)

    self.isAttack = true
    self.infantrySprite:runAction(attackAct)
end

--AI part
--in the vision range, infantry follows the hero
function Infantry:followRun(hero, map)
    local xDis = hero:getPositionX() - (self:getPositionX() + map:getPositionX())
    local yDis = hero:getPositionY() - (self:getPositionY() + map:getPositionY())
    self.dis = math.sqrt(math.pow(xDis, 2) + math.pow(yDis, 2))

    if(self.dis >= 300.0) then
        return
    end
    if(self.dis <= 70.0) then
        self:runEnd()
        self:judgeAttack() --attack according to the probability
        return
    end
    if(xDis < -40.0) then
        self.infantryDirection = true
        self.infantrySprite:setFlippedX(self.infantryDirection)
        if(self.isAttack)then
            return
        end
        self:setPosition(self:getPositionX() - 1, self:getPositionY())
        local curKey = "infantry"..self.sceneNum.."_run"
        self:runAnimation(self.frameCache, curKey, self.infantryActTbl["run"][curKey], self.infantryDirection)
    elseif(xDis > 40.0) then
        self.infantryDirection = false
        self.infantrySprite:setFlippedX(self.infantryDirection)
        if(self.isAttack)then
            return
        end
        self:setPosition(self:getPositionX() + 1, self:getPositionY())
        local curKey = "infantry"..self.sceneNum.."_run"
        self:runAnimation(self.frameCache, curKey, self.infantryActTbl["run"][curKey], self.infantryDirection)
    elseif(xDis <= 40.0) then
        if(hero:getPositionY() > self:getPositionY()) then
            self.infantrySprite:setFlippedX(self.infantryDirection)
            if(self.isAttack)then
                return
            end
            self:setPosition(self:getPositionX(), self:getPositionY() + 1)
            local curKey = "infantry"..self.sceneNum.."_run"
            self:runAnimation(self.frameCache, curKey, self.infantryActTbl["run"][curKey], self.infantryDirection)
        elseif (hero:getPositionY() < self:getPositionY()) then
            self.infantrySprite:setFlippedX(self.infantryDirection)
            if(self.isAttack)then
                return
            end
            self:setPosition(self:getPositionX(), self:getPositionY() - 1)
            local curKey = "infantry"..self.sceneNum.."_run"
            self:runAnimation(self.frameCache, curKey, self.infantryActTbl["run"][curKey], self.infantryDirection)
        end
    end      

end

function Infantry:judgeAttack()
    math.randomseed(tostring(os.time()):reverse():sub(1, 6) + self.seedNum)
    local probability = math.random()
    if(probability > 0.3) then
        local curKey = "infantry"..self.sceneNum.."_attack"
        self:attackAnimation(self.frameCache, curKey, self.infantryActTbl["attack"][curKey], self.infantryDirection)
    end
end

function Infantry:patrolRun()
    if(self.dis < 300.0) then
        return
    end
    local curKey = "infantry"..self.sceneNum.."_run"
    self:runAnimation(self.frameCache, curKey, self.infantryActTbl["run"][curKey], self.infantryDirection)
    local moveby1 = nil
    if(self.infantryDirection) then
        moveby1 = cc.MoveBy:create(2, cc.p(-60, 0))
        self.infantryDirection = false
    else
        moveby1 = cc.MoveBy:create(2, cc.p(60, 0))
        self.infantryDirection = true
    end


    local function runEnd()
        if(not self.isRunning) then
            return
        end
        self.infantrySprite:stopAllActions()

        self:removeChild(self.infantrySprite, true)   
        self.infantrySprite = cc.Sprite:createWithSpriteFrame(self.frameCache:getSpriteFrame(self.infantryName))
        self.infantrySprite:setFlippedX(self.infantryDirection)
        self:addChild(self.infantrySprite)
        self.isRunning = false
        if(self.infantryBlood ~= nil) then
            if(self.infantryDirection) then
                self.infantryBlood:setPosition(cc.p(self.infantrySprite:getPositionX() + 20, self.infantrySprite:getPositionY() + 50))  
            else
                self.infantryBlood:setPosition(cc.p(self.infantrySprite:getPositionX() - 20, self.infantrySprite:getPositionY() + 50))
            end 
        end  
    end
    -- create callback, call attackEnd after attack
    local callFunc = cc.CallFunc:create(runEnd,{})
    --create continuous action
    local patrolAct = cc.Sequence:create(moveby1,callFunc,nil)

    self:runAction(patrolAct)   
end

function Infantry:startListen(hero, map)

    local function updateMonster()
        if(self.isDead) then
            return
        end    
        local xDis = hero:getPositionX() - (self:getPositionX() + map:getPositionX())
        local yDis = hero:getPositionY() - (self:getPositionY() + map:getPositionY())

        self.dis = math.sqrt(math.pow(xDis, 2) + math.pow(yDis, 2))

        if(self.dis > 300.0) then
            if(not self.isRunning) then
                self:patrolRun()
            end
        end
    end

    local function update()
        if(self.isDead) then
            return
        end    
        if(self.dis < 300.0) then
            self:followRun(hero, map)
        end    
    end

    self.schedulerID_patrol = cc.Director:getInstance():getScheduler():scheduleScriptFunc(updateMonster, 3.0, false)
    self.schedulerID_follow = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update, 0, false)
end

function Infantry:hurtAnimation(frameCache, actName, num, runDirection, isSkil)
    if(self.isHurt or self.isDead)then
        return
    end
    --hurt first
    if(self.isRunning or self.isAttack) then
        self.infantrySprite:stopAllActions()
        self:removeChild(self.infantrySprite, true)
        self.infantrySprite = cc.Sprite:createWithSpriteFrame(frameCache:getSpriteFrame(self.infantryName))
        self.infantrySprite:setFlippedX(self.infantryDirection)
        self:addChild(self.infantrySprite)
        self.isRunning = false
        self.isAttack = false
    end    

    -- add the images into the sprite cache
    --local frameCache = cc.SpriteFrameCache:getInstance()
    --frameCache:addSpriteFrames(plistName,pngName)
    -- use a list to store all the spriteFrameCache
    local frameArray = {}
    for i = 1, num
    do
        local frame = frameCache:getSpriteFrame(string.format("%s%d.png",actName,i))
        table.insert(frameArray,frame)
    end

    local animation = cc.Animation:createWithSpriteFrames(frameArray)

    animation:setDelayPerUnit(2.8 / 14.0)
    animation:setRestoreOriginalFrame(true)
    animation:setLoops(1)

    local function hurtEnd()
        self.isHurt = false
        local bloodVolume = math.random(1,3)
        if isSkill then
            bloodVolume = 10
        end

        self.word:flying(-bloodVolume * 10)
        self.infantryBlood:setCurrentProgress(self.infantryBlood:getCurrentProgress() - 10 * bloodVolume) --test
        if(self.infantryBlood:getCurrentProgress() == 0) then
            local curKey = "infantry"..self.sceneNum.."_dead"
            self:deadAnimation(self.frameCache, curKey, self.infantryActTbl["dead"][curKey], self.infantryDirection)
        end
    end
    -- package the animation into an action
    local act = cc.Animate:create(animation)
    -- create callback, call hurtEnd after hurt
    local callFunc = cc.CallFunc:create(hurtEnd,{})
    --create continuous action
    local hurtAct = cc.Sequence:create(act,callFunc,nil)

    self.infantrySprite:runAction(hurtAct) 
    self.isHurt = true
end

function Infantry:deadAnimation(frameCache, actName, num, runDirection)
    --self.isDead = true

    -- add the images into the sprite cache
    --local frameCache = cc.SpriteFrameCache:getInstance()
    --frameCache:addSpriteFrames(plistName,pngName)
    -- use a list to store all the spriteFrameCache
    local frameArray = {}
    for i = 1, num
    do
        local frame = frameCache:getSpriteFrame(string.format("%s%d.png",actName,i))
        table.insert(frameArray,frame)
    end

    local animation = cc.Animation:createWithSpriteFrames(frameArray)

    animation:setDelayPerUnit(2.8 / 14.0)
    animation:setRestoreOriginalFrame(true)
    animation:setLoops(1)

    local function deadEnd()
        self:removeChild(self.infantrySprite, true)
        --self.infantrySprite = cc.Sprite:create("infantry_dead_status.png")
        self.infantrySprite = cc.Sprite:createWithSpriteFrame(frameCache:getSpriteFrame(actName..num..".png"))
        self.infantrySprite:setFlippedX(self.infantryDirection)
        self:addChild(self.infantrySprite)


        if(self.infantryBlood ~= nil) then
            if(self.infantryDirection)then
                self.infantryBlood:setPosition(self.infantrySprite:getPositionX() + 60, self.infantrySprite:getPositionY())
            else
                self.infantryBlood:setPosition(self.infantrySprite:getPositionX() - 60, self.infantrySprite:getPositionY())
            end
        end
        -- blink before dead
        local blinkAct = cc.Blink:create(0.5,2)  --3 is duration, 6 is times

        local function blinkEnd()
            self:removeAllChildren()
            self.isDead = true
        end
        local callFunc = cc.CallFunc:create(blinkEnd,{})

        local deadBlinkAct = cc.Sequence:create(blinkAct,callFunc,nil)

        self.infantrySprite:runAction(deadBlinkAct) 
    end
    -- package the animation into an action
    local act = cc.Animate:create(animation)
    -- create callback, call deadEnd after dead
    local callFunc = cc.CallFunc:create(deadEnd,{})
    --create continuous action
    local deadAct = cc.Sequence:create(act,callFunc,nil)

    self.infantrySprite:runAction(deadAct) 
end

return Infantry