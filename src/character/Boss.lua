local Boss = class("Boss",function()
    return cc.Node:create()
end)



--create hero
function Boss.create(frameCache, bossName, bossActTbl, bloodbgName, bloodfgName, sceneNum)
    local boss = Boss.new()
    boss:createBoss(frameCache, bossName, bossActTbl, bloodbgName, bloodfgName, sceneNum)
    return boss
end

function Boss:ctor()
    self.isRunning = false    -- run animation stopped
    self.isAttack = false  -- attack animation stopped
    self.bossDirection = true  -- face left
    self.bossName = nil
    self.bossSprite = nil
    self.bossBlood = nil
    self.frameCache = nil
    self.bossActTbl = nil
    self.sceneNum = 1
    self.dis = 10000.0
    
    self.isHurt = false
    self.isDead = false
    
    self.word = nil
    
    self.schedulerID_patrol = nil
    self.schedulerID_follow = nil
end

function Boss:getSprite()
    return self.bossSprite
end

function Boss:createBoss(frameCache, bossName, bossActTbl, bloodBg, bloodFg, sceneNum)
    --self.bossSprite = cc.Sprite:create(bossName)
    self.bossSprite = cc.Sprite:createWithSpriteFrame(frameCache:getSpriteFrame(bossName))
    self.bossSprite:setFlippedX(self.bossDirection)
    self.frameCache = frameCache
    self.bossActTbl = bossActTbl
    self.bossName = bossName
    self.sceneNum = sceneNum
    self:addChild(self.bossSprite)
    --add blood bar
    local ProgressView_node = require("character.ProgressView")
    self.bossBlood = ProgressView_node.create()
    if(self.bossDirection) then
        self.bossBlood:setPosition(cc.p(self.bossSprite:getPositionX() + 20, self.bossSprite:getPositionY() + 50))
    else
        self.bossBlood:setPosition(cc.p(self.bossSprite:getPositionX() - 20, self.bossSprite:getPositionY() + 50))
    end
    
    self.bossBlood:setBackgroundTexture(bloodBg)
    self.bossBlood:setForegroundTexture(bloodFg)
    local bloodScale = (sceneNum - 1) / 3 + 1
    self.bossBlood:setTotalProgress(300.0 * sceneNum)
    self.bossBlood:setCurrentProgress(300.0 * sceneNum)
    self:addChild(self.bossBlood)
    
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

function Boss:runAnimation(frameCache, actName, num, runDirection)
    if(self.bossDirection ~= runDirection) then
        self.bossDirection = runDirection
        self.bossSprite:setFlippedX(runDirection)
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
    if(self.bossDirection ~= runDirection) then
        self.bossDirection = runDirection
    end

    animation:setDelayPerUnit(0.1)
    animation:setRestoreOriginalFrame(true)
    animation:setLoops(-1)

    -- package the animation into an action
    local act = cc.Animate:create(animation)

    self.isRunning = true
    self.bossSprite:runAction(act)
end

function Boss:runEnd()
    if(not self.isRunning) then
        return
    end
    self.bossSprite:stopAllActions()

    self:removeChild(self.bossSprite, true)   
    self.bossSprite = cc.Sprite:createWithSpriteFrame(self.frameCache:getSpriteFrame(self.bossName))
    self.bossSprite:setFlippedX(self.bossDirection)
    self:addChild(self.bossSprite)
    self.isRunning = false
    
    if(self.bossBlood ~= nil) then
        if(self.bossDirection) then
            self.bossBlood:setPosition(cc.p(self.bossSprite:getPositionX() + 20, self.bossSprite:getPositionY() + 50))  
        else
            self.bossBlood:setPosition(cc.p(self.bossSprite:getPositionX() - 20, self.bossSprite:getPositionY() + 50))
        end 
    end
end

function Boss:attackAnimation(frameCache, actName, num, runDirection)
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
        self:removeChild(self.bossSprite, true)
        self.bossSprite = cc.Sprite:createWithSpriteFrame(frameCache:getSpriteFrame(self.bossName))
        self.bossSprite:setFlippedX(self.bossDirection)
        self:addChild(self.bossSprite)
        self.isAttack = false
    end
    -- package the animation into an action
    local act = cc.Animate:create(animation)
    -- create callback, call attackEnd after attack
    local callFunc = cc.CallFunc:create(attackEnd,{})
    --create continuous action
    local attackAct = cc.Sequence:create(act,callFunc,nil)

    self.isAttack = true
    self.bossSprite:runAction(attackAct)
end

--AI part
--in the vision range, boss follows the hero
function Boss:followRun(hero, map)
    local xDis = hero:getPositionX() - (self:getPositionX() + map:getPositionX())
    local yDis = hero:getPositionY() - (self:getPositionY() + map:getPositionY())
    self.dis = math.sqrt(math.pow(xDis, 2) + math.pow(yDis, 2))

    if(self.dis >= 400.0) then
        return
    end
    if(self.dis <= 100.0) then
        self:runEnd()
        self:judgeAttack() --attack according to the probability
        return
    end
    if(xDis < -50.0) then
        self.bossDirection = true
        self.bossSprite:setFlippedX(self.bossDirection)
        if(self.isAttack)then
            return
        end
        self:setPosition(self:getPositionX() - 1, self:getPositionY())
        local curKey = "boss"..self.sceneNum.."_run"
        self:runAnimation(self.frameCache, curKey, self.bossActTbl["run"][curKey], self.bossDirection)
    elseif(xDis > 50.0) then
        self.bossDirection = false
        self.bossSprite:setFlippedX(self.bossDirection)
        if(self.isAttack)then
            return
        end
        self:setPosition(self:getPositionX() + 1, self:getPositionY())
        local curKey = "boss"..self.sceneNum.."_run"
        self:runAnimation(self.frameCache, curKey, self.bossActTbl["run"][curKey], self.bossDirection)
    elseif(xDis <= 50.0) then
        if(hero:getPositionY() > self:getPositionY()) then
            self.bossSprite:setFlippedX(self.bossDirection)
            if(self.isAttack)then
                return
            end
            self:setPosition(self:getPositionX(), self:getPositionY() + 1)
            local curKey = "boss"..self.sceneNum.."_run"
            self:runAnimation(self.frameCache, curKey, self.bossActTbl["run"][curKey], self.bossDirection)
        elseif (hero:getPositionY() < self:getPositionY()) then
            self.bossSprite:setFlippedX(self.bossDirection)
            if(self.isAttack)then
                return
            end
            self:setPosition(self:getPositionX(), self:getPositionY() - 1)
            local curKey = "boss"..self.sceneNum.."_run"
            self:runAnimation(self.frameCache, curKey, self.bossActTbl["run"][curKey], self.bossDirection)
        end
    end      
     
end

function Boss:judgeAttack()
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))
    local probability = math.random()
    if(probability > 0.3) then
        local curKey = "boss"..self.sceneNum.."_attack"
        self:attackAnimation(self.frameCache, curKey, self.bossActTbl["attack"][curKey], self.bossDirection)
    end
end

function Boss:patrolRun()
    if(self.dis < 400.0) then
        return
    end
    local curKey = "boss"..self.sceneNum.."_run"
    self:runAnimation(self.frameCache, curKey, self.bossActTbl["run"][curKey], self.bossDirection)
    local moveby1 = nil
    if(self.bossDirection) then
        moveby1 = cc.MoveBy:create(2, cc.p(-100, 0))
        self.bossDirection = false
    else
        moveby1 = cc.MoveBy:create(2, cc.p(100, 0))
        self.bossDirection = true
    end
      
     
    local function runEnd()
        if(not self.isRunning) then
            return
        end
        self.bossSprite:stopAllActions()

        self:removeChild(self.bossSprite, true)   
        self.bossSprite = cc.Sprite:createWithSpriteFrame(self.frameCache:getSpriteFrame(self.bossName))
        self.bossSprite:setFlippedX(self.bossDirection)
        self:addChild(self.bossSprite)
        self.isRunning = false
        if(self.bossBlood ~= nil) then
            if(self.bossDirection) then
                self.bossBlood:setPosition(cc.p(self.bossSprite:getPositionX() + 20, self.bossSprite:getPositionY() + 50))  
            else
                self.bossBlood:setPosition(cc.p(self.bossSprite:getPositionX() - 20, self.bossSprite:getPositionY() + 50))
            end 
        end  
    end
    -- create callback, call attackEnd after attack
    local callFunc = cc.CallFunc:create(runEnd,{})
    --create continuous action
    local patrolAct = cc.Sequence:create(moveby1,callFunc,nil)

    self:runAction(patrolAct)   
end

function Boss:startListen(hero, map)
    local function updateMonster()
  
        if(self.isDead) then
            return
        end    
        local xDis = hero:getPositionX() - (self:getPositionX() + map:getPositionX())
        local yDis = hero:getPositionY() - (self:getPositionY() + map:getPositionY())
        
        self.dis = math.sqrt(math.pow(xDis, 2) + math.pow(yDis, 2))
        
        if(self.dis > 400.0) then
            if(not self.isRunning) then
                self:patrolRun()
            end
        end
    end
    
    local function update()
        if(self.isDead) then
            return
        end    
        if(self.dis < 400.0) then
            self:followRun(hero, map)
        end    
    end
    
    self.schedulerID_patrol = cc.Director:getInstance():getScheduler():scheduleScriptFunc(updateMonster, 3.0, false)
    self.schedulerID_follow = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update, 0, false)
end

function Boss:hurtAnimation(frameCache, actName, num, runDirection, isSkill)
    if(self.isHurt or self.isDead)then
        return
    end
    --hurt first
    if(self.isRunning or self.isAttack) then
        self.bossSprite:stopAllActions()
        self:removeChild(self.bossSprite, true)
        self.bossSprite = cc.Sprite:createWithSpriteFrame(frameCache:getSpriteFrame(self.bossName))
        self.bossSprite:setFlippedX(self.bossDirection)
        
        self:addChild(self.bossSprite)
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
        self.bossBlood:setCurrentProgress(self.bossBlood:getCurrentProgress() - 3 * bloodVolume) --test
        if(self.bossBlood:getCurrentProgress() == 0) then
            local curKey = "boss"..self.sceneNum.."_dead"
            self:deadAnimation(self.frameCache, curKey, self.bossActTbl["dead"][curKey], self.bossDirection)
        end
    end
    -- package the animation into an action
    local act = cc.Animate:create(animation)
    -- create callback, call hurtEnd after hurt
    local callFunc = cc.CallFunc:create(hurtEnd,{})
    --create continuous action
    local hurtAct = cc.Sequence:create(act,callFunc,nil)

    self.bossSprite:runAction(hurtAct) 
    self.isHurt = true
end

function Boss:deadAnimation(frameCache, actName, num, runDirection)
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
        self:removeChild(self.bossSprite, true)
        self.bossSprite = cc.Sprite:createWithSpriteFrame(frameCache:getSpriteFrame(actName..num..".png"))
        self.bossSprite:setFlippedX(self.bossDirection)
        self:addChild(self.bossSprite)

        if(self.bossBlood ~= nil) then
            local xOffset = 20
            local yOffset = 50
            if(self.sceneNum == 1) then 
                xOffset = 20
                yOffset = 50 
            elseif(self.sceneNum == 2) then 
                xOffset = 60
                yOffset = 50 
            elseif(self.sceneNum == 3) then
                xOffset = 20
                yOffset = 50 
            end
            if(self.bossDirection)then
                self.bossBlood:setPosition(self.bossSprite:getPositionX() + xOffset, self.bossSprite:getPositionY() + yOffset)
            else
                self.bossBlood:setPosition(self.bossSprite:getPositionX() - xOffset, self.bossSprite:getPositionY() + yOffset)
            end
        end
        -- blink before dead
        local blinkAct = cc.Blink:create(3,6)  --3 is duration, 6 is times
        
        local function blinkEnd()
            self:removeAllChildren()
            self.isDead = true
        end
        local callFunc = cc.CallFunc:create(blinkEnd,{})

        local deadBlinkAct = cc.Sequence:create(blinkAct,callFunc,nil)

        self.bossSprite:runAction(deadBlinkAct) 
    end
    -- package the animation into an action
    local act = cc.Animate:create(animation)
    -- create callback, call deadEnd after dead
    local callFunc = cc.CallFunc:create(deadEnd,{})
    --create continuous action
    local deadAct = cc.Sequence:create(act,callFunc,nil)

    self.bossSprite:runAction(deadAct) 
end

return Boss