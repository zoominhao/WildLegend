local Hero = class("Hero",function()
    return cc.Node:create()
end)


--create hero
function Hero.create(frameCache, heroName)
    local hero = Hero.new()
    hero:addChild(hero:createHero(frameCache, heroName))
    return hero
end

function Hero:ctor()
    self.isRunning = false    -- run animation stopped
    self.isAttack = false  -- attack animation stopped
    self.heroDirection = false  -- face right
    self.heroName = nil
    self.frameCache = nil
    self.heroSprite = nil
    
    self.isKilling = false
    self.isCuring = false
    
    self.isEffectSound = false
end


function Hero:setEffectSound(isSound)
    self.isEffectSound = isSound
end

function Hero:getSprite()
    return self.heroSprite
end

function Hero:createHero(frameCache, heroName)
    self.heroSprite = cc.Sprite:createWithSpriteFrame(frameCache:getSpriteFrame(heroName))
    self.heroName = heroName
    self.frameCache = frameCache
    return self.heroSprite
end

--run, attack, dead, hurt...
--eachName is the common name for each small image in pngName, num is the number of images
function Hero:runAnimation(frameCache, actName, num, runDirection)
    if(self.heroDirection ~= runDirection) then
       self.heroDirection = runDirection
       self.heroSprite:setFlippedX(runDirection)
    end
    
    if(self.isRunning or self.isAttack or self.isKilling or self.isCuring) then
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
    if(self.heroDirection ~= runDirection) then
        self.heroDirection = runDirection
    end
    
    animation:setLoops(-1)
    animation:setDelayPerUnit(0.1)
    
    -- package the animation into an action
    local act = cc.Animate:create(animation)
    
    self.heroSprite:runAction(act)
    self.isRunning = true
end

function Hero:runEnd()
    if(not self.isRunning) then
       return
    end
    self.heroSprite:stopAllActions()
    
    self:removeChild(self.heroSprite, true)   
    self.heroSprite = cc.Sprite:createWithSpriteFrame(self.frameCache:getSpriteFrame(self.heroName))
    self.heroSprite:setFlippedX(self.heroDirection)
    self:addChild(self.heroSprite)
    self.isRunning = false
end

function Hero:attackAnimation(frameCache, actName, num, runDirection)
    if(self.isAttack)then
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
    if(self.heroDirection ~= runDirection) then
        self.heroDirection = runDirection
    end
    
    animation:setLoops(1)
    animation:setDelayPerUnit(0.1)
    local effectID = nil
    if self.isEffectSound then
        local effectPath = cc.FileUtils:getInstance():fullPathForFilename("attack.mp3")
        effectID = cc.SimpleAudioEngine:getInstance():playEffect(effectPath, true)
    end
   
    
    local function attackEnd()
        self:removeChild(self.heroSprite, true)
        self.heroSprite = cc.Sprite:createWithSpriteFrame(frameCache:getSpriteFrame(self.heroName))
        self.heroSprite:setFlippedX(self.heroDirection)
        self:addChild(self.heroSprite)
        if self.isEffectSound then
            cc.SimpleAudioEngine:getInstance():stopEffect(effectID)
        end
        self.isAttack = false
    end
    -- package the animation into an action
    local act = cc.Animate:create(animation)
    -- create callback, call attackEnd after attack
    local callFunc = cc.CallFunc:create(attackEnd,{})
    --create continuous action
    local attackAct = cc.Sequence:create(act,callFunc,nil)
    
    self.isAttack = true
    self.heroSprite:runAction(attackAct)
end


function Hero:judgePosition(visibleSize)
    if(self:getPositionX()~= visibleSize.width / 2)then --whether in the middle position 
        return false
    else
        return true
    end        
end

function Hero:judegWalk()
    if(self.isAttack or self.isKilling or self.isCuring) then
        return false
    else
        return true
    end 
end

function Hero:killAnimation(frameCache, actName, num, runDirection)
    self.heroSprite:stopAllActions()
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
    if(self.heroDirection ~= runDirection) then
        self.heroDirection = runDirection
    end

    animation:setDelayPerUnit(0.1)
    animation:setRestoreOriginalFrame(true)
    animation:setLoops(4)
    
    local effectID = nil
    if self.isEffectSound then
        local effectPath = cc.FileUtils:getInstance():fullPathForFilename("kill.mp3")
        effectID = cc.SimpleAudioEngine:getInstance():playEffect(effectPath, true)
    end
    local function killEnd()
        self:removeChild(self.heroSprite, true)
        self.heroSprite = cc.Sprite:createWithSpriteFrame(frameCache:getSpriteFrame(self.heroName))
        self.heroSprite:setFlippedX(self.heroDirection)
        self:addChild(self.heroSprite)
        --self.isAttack = false
        if self.isEffectSound then
            cc.SimpleAudioEngine:getInstance():stopEffect(effectID)
        end
        self.isKilling = false
    end
    -- package the animation into an action
    local act = cc.Animate:create(animation)
    -- create callback, call skillEnd after skill
    local callFunc = cc.CallFunc:create(killEnd,{})
    --create continuous action
    local skillAct = cc.Sequence:create(act,callFunc,nil)

    --self.isAttack = true
    self.isKilling = true
    self.heroSprite:runAction(skillAct)
end

function Hero:cureAnimation(frameCache, actName, num, runDirection)
    self.heroSprite:stopAllActions()
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
    if(self.heroDirection ~= runDirection) then
        self.heroDirection = runDirection
    end

    animation:setDelayPerUnit(0.1)
    animation:setRestoreOriginalFrame(true)
    animation:setLoops(4)
    
    local effectID = nil
    if self.isEffectSound then
        local effectPath = cc.FileUtils:getInstance():fullPathForFilename("cure.mp3")
        effectID = cc.SimpleAudioEngine:getInstance():playEffect(effectPath, true)
    end
    local function cureEnd()
        self:removeChild(self.heroSprite, true)
        self.heroSprite = cc.Sprite:createWithSpriteFrame(frameCache:getSpriteFrame(self.heroName))
        self.heroSprite:setFlippedX(self.heroDirection)
        self:addChild(self.heroSprite)
        --self.isAttack = false
        if self.isEffectSound then
            cc.SimpleAudioEngine:getInstance():stopEffect(effectID)
        end
        self.isCuring = false
    end
    -- package the animation into an action
    local act = cc.Animate:create(animation)
    -- create callback, call skillEnd after skill
    local callFunc = cc.CallFunc:create(cureEnd,{})
    --create continuous action
    local skillAct = cc.Sequence:create(act,callFunc,nil)

    --self.isAttack = true
    self.isCuring = true
    self.heroSprite:runAction(skillAct)
end

return Hero
