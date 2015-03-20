
local WorldScene = class("WorldScene",function()
    return cc.Scene:create()
end)

function WorldScene.create(sceneNum, isSound)
    local scene = WorldScene.new()
    -- Nodes
    --background
    --scene:addChild(scene:bgLayer())
    scene.sceneNum = sceneNum
    scene.isSound = isSound
    --load characters
    local pFrameCache = cc.SpriteFrameCache:getInstance()
    pFrameCache:addSpriteFrames("character.plist","character.png")
    scene.pFrameCache = pFrameCache
    
    local worldMap_node = scene:addMap()
    scene:addChild(worldMap_node, 0)
    
    --play music
    if isSound then
        scene:playBgMusic()
    end
    
    -- rocker
    local hrocker_layer = scene:addRocker()
    scene:addChild(hrocker_layer, 2)
    
    --hero
    local hero_node = scene:addHero()
    scene:addChild(hero_node, 1)
    hero_node:setEffectSound(isSound)
    --button
    local attackBtn_node = scene:addButton()
    scene:addChild( attackBtn_node, 2)
    
    --skill button
    local killSkillBtn_layer = scene:addKillSkillBtn(hero_node)
    scene:addChild(killSkillBtn_layer, 2)
    
    local cureSkillBtn_layer = scene:addCureSkillBtn(hero_node)
    scene:addChild(cureSkillBtn_layer, 2)
    
    --blood bar
    local bloodBar_node, skillBar_node = scene:addProgressBar()
    scene:addChild(bloodBar_node, 2)
    scene:addChild(skillBar_node, 2)
    
    --low blood warnning
    scene:addLowBloodWarnning()
    
    --boss
    local boss_node = scene:addBoss()
    -- scene:addChild(boss_node)
    worldMap_node:addChild(boss_node)
    boss_node:startListen(hero_node, worldMap_node)
    
    local infrantries = scene:addInfantries()
    for i = 1, #(infrantries) 
    do
        worldMap_node:addChild(infrantries[i])
        infrantries[i]:startListen(hero_node, worldMap_node)
    end
    
        
    --pause menu
    local closeMenu = scene:addCloseItem(boss_node, infrantries, hero_node, worldMap_node)
    scene:addChild(closeMenu, 1)

    local param = {hrocker_layer, hero_node, worldMap_node, attackBtn_node, bloodBar_node, 
        skillBar_node, boss_node, killSkillBtn_layer, cureSkillBtn_layer, infrantries}
    --logic part
    --rocker control/button control
    scene:update(param)

    return scene
end


function WorldScene:ctor()
    self.visibleSize = cc.Director:getInstance():getVisibleSize()
    self.origin = cc.Director:getInstance():getVisibleOrigin()
    self.schedulerID = nil
    self.sceneNum = 1
    self.sceneWidth = 1920
    self.pFrameCache = nil
    self.bossName = {"boss1_run2.png", "boss2_run1.png", "boss3_run1.png"}
    self.bossAct = {run = {boss1_run = 8, boss2_run = 8, boss3_run = 8},
                    attack = {boss1_attack = 6, boss2_attack = 5, boss3_attack = 46},
                    hurt = {boss1_hurt = 8, boss2_hurt = 2, boss3_hurt = 5},
                    dead = {boss1_dead = 4, boss2_dead = 3, boss3_dead = 2}}
    self.infantryName = {"infantry1_run1.png", "infantry2_run1.png", "infantry3_run6.png"}
    self.infantryAct = {run = {infantry1_run = 8, infantry2_run = 6, infantry3_run = 8},
        attack = {infantry1_attack = 5, infantry2_attack = 5, infantry3_attack = 6},
        hurt = {infantry1_hurt = 2, infantry2_hurt = 2, infantry3_hurt = 3},
        dead = {infantry1_dead = 3, infantry2_dead = 3, infantry3_dead = 3}}   
    self.infantryOne = 5 
    self.infantryTwo = 5 
    self.infantryThree = 5 
    self.lowBloodSprite = nil 
    self.isSound = false
end

function WorldScene:playBgMusic()
    cc.SimpleAudioEngine:getInstance():stopMusic()
    local bgMusicPath = cc.FileUtils:getInstance():fullPathForFilename("background.mp3") 
    cc.SimpleAudioEngine:getInstance():playMusic(bgMusicPath, true)
end

function WorldScene:stopBgMusic()
    cc.SimpleAudioEngine:getInstance():stopMusic()
end

-- create bg
function WorldScene:bgLayer()
    local layerWorld = cc.Layer:create()
    -- add in farm background
    local bg = cc.Sprite:create("background.jpg")
    bg:setPosition(self.origin.x + self.visibleSize.width / 2, self.origin.y + self.visibleSize.height / 2)
    layerWorld:addChild(bg, 0)

    local function onNodeEvent(event)
        if "exit" == event then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
        end
    end
    layerWorld:registerScriptHandler(onNodeEvent)
    return layerWorld
end

function WorldScene:addHero()
    --hero
    local Hero_node = require("character.Hero")
    local hero_node = Hero_node.create(self.pFrameCache, "hero_attack12.png")
    hero_node:setPosition(cc.p(200,200))
    return hero_node
end

function WorldScene:addRocker()
    --rocker
    local Hrocker_layer = require("layout.HRocker")
    local hrocker_layer = Hrocker_layer.create(cc.p(90, 90))
    hrocker_layer:startRocker(true)
    return hrocker_layer
end

function WorldScene:addButton()
    --button
    local MControlButton_node = require("layout.MControlButton")
    local mControlButton_node = MControlButton_node.create("attack.png")
    mControlButton_node:setScale(0.9,0.9)
    mControlButton_node:setPosition(cc.p(self.visibleSize.width - 60, 80))
    return mControlButton_node
end

function WorldScene:addMap()
    --map
    local WorldMap_node = require("layout.WorldMap")
    local sceneName = "scene"..self.sceneNum..".png"
    local worldMap_node = WorldMap_node.create(sceneName, self.visibleSize)
    local mapSprite = cc.Sprite:create(sceneName)
    self.sceneWidth = mapSprite:getContentSize().width

    --local function onNodeEvent(event)
        --if "exit" == event then
            --cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
        --end
    --end
    --worldMap_node:registerScriptHandler(onNodeEvent)
    return worldMap_node
end

function WorldScene:addProgressBar()

    local ProgressView_node = require("character.ProgressView")
    --blood bar
    local bloodBar = ProgressView_node.create()
    bloodBar:setPosition(cc.p(100.0,430.0))
    bloodBar:setScale(0.5)
    -- bloodBar:setBackgroundTexture("blood_back.png")
    bloodBar:setForegroundTexture("blood.png")
    bloodBar:setTotalProgress(100.0)
    bloodBar:setCurrentProgress(100.0)
    
    --skill bar
    local skillBar = ProgressView_node.create()
    skillBar:setPosition(cc.p(bloodBar:getPositionX(), bloodBar:getPositionY()))
    skillBar:setScale(0.5)
    -- bloodBar:setBackgroundTexture("blood_back.png")
    skillBar:setForegroundTexture("skill.png")
    skillBar:setTotalProgress(100.0)
    skillBar:setCurrentProgress(100.0)
    
    --frame
    local statusFrame = cc.Sprite:create("status_frame.png")
    statusFrame:setPosition(bloodBar:getPositionX() - 11, bloodBar:getPositionY())
    statusFrame:setScale(0.5)
    local avator = cc.Sprite:create("avator.png")
    avator:setPosition(bloodBar:getPositionX() - 81, bloodBar:getPositionY())
    avator:setScale(0.3)
    self:addChild(statusFrame, 2)
    self:addChild(avator, 2)

    return bloodBar,skillBar
end

function WorldScene:addLowBloodWarnning()
    self.lowBloodSprite = cc.Sprite:create("lowBlood.png") 
    self.lowBloodSprite:setVisible(false)
    self.lowBloodSprite:setPosition(self.visibleSize.width / 2, self.visibleSize.height / 2)
    self:addChild(self.lowBloodSprite, 1)
end

function WorldScene:addBoss()
    local Boss_node = require("character.Boss")
    local boss_node = Boss_node.create(self.pFrameCache, self.bossName[self.sceneNum], self.bossAct, "blood_back.png", "blood_fore.png", self.sceneNum)
    boss_node:setPosition(cc.p(self.sceneWidth - 150,self.visibleSize.height / 2))
    return boss_node
end

function WorldScene:addInfantries()
    --add infantry according to sceneNum
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))   --generate random seed by os time
    --add infantry type 1
    local numOfInfantry1 = math.random(2, 6)

    --add infantry type 2
    local numOfInfantry2 = math.random(2, 6)

    --add infantry type 3
    local numOfInfantry3 = math.random(2, 6)
    if(self.sceneNum == 1) then
        numOfInfantry1 = numOfInfantry1 + 7
    elseif(self.sceneNum == 2) then
        numOfInfantry2 = numOfInfantry2 + 7
    else
        numOfInfantry3 = numOfInfantry3 + 7
    end
    local Infantry_node = require("character.Infantry")
    local infantries = {}
    local totalnum = numOfInfantry1 + numOfInfantry2 + numOfInfantry3
    for i = 1, totalnum 
    do
        local coordX = math.random(self.visibleSize.width - 150, self.sceneWidth - 100)
        local coordY = math.random(self.visibleSize.height - 360, self.visibleSize.height - 180)
        local infantry_node = nil
        if (i <= numOfInfantry1) then
            infantry_node = Infantry_node.create(self.pFrameCache, self.infantryName[1], self.infantryAct, "blood_back1.png", "blood_fore1.png", 1, i)
        elseif (i <= numOfInfantry1 + numOfInfantry2) then
            infantry_node = Infantry_node.create(self.pFrameCache, self.infantryName[2], self.infantryAct, "blood_back1.png", "blood_fore1.png", 2, i)
        else
            infantry_node = Infantry_node.create(self.pFrameCache, self.infantryName[3], self.infantryAct, "blood_back1.png", "blood_fore1.png", 3, i)
        end
        infantry_node:setScale(0.7)
        infantry_node:setPosition(cc.p(coordX, coordY))
        table.insert(infantries, infantry_node)
    end
    self.infantryOne = numOfInfantry1 
    self.infantryTwo = numOfInfantry2 
    self.infantryThree = numOfInfantry3 
    return infantries
end

function WorldScene:addKillSkillBtn(hero)
    --skill button
    local SkillButton_layer = require("layout.SkillButton")
    local skillButton_layer = SkillButton_layer.create("kill_fore.png", "kill_back.png", 10)
    skillButton_layer:setPosition(cc.p(self.visibleSize.width - 120, 60))
    skillButton_layer:startSkill(hero)
    return skillButton_layer
end

function WorldScene:addCureSkillBtn(hero)
    --skill button
    local SkillButton_layer = require("layout.SkillButton")
    local skillButton_layer = SkillButton_layer.create("cure_fore.png", "cure_back.png", 20)
    skillButton_layer:setPosition(cc.p(self.visibleSize.width - 170, 60))
    skillButton_layer:startSkill(hero)
    return skillButton_layer
end

function WorldScene:addCloseItem(boss_node, infrantries, hero, map)
    local function menuPauseCB()
        local renderTexture = cc.RenderTexture:create(self.visibleSize.width, self.visibleSize.height + 50)
        -- snapshot
        renderTexture:begin()
        self:visit()
        renderTexture:endToLua()

        -- pause
        local GamePause_layer = require("scene.GamePause")
        cc.Director:getInstance():pushScene(GamePause_layer.create(renderTexture, self.sceneNum, self.isSound, boss_node, infrantries, hero, map))
        --cc.SimpleAudioEngine:getInstance():stopMusic()
        cc.SimpleAudioEngine:getInstance():pauseAllEffects()
    end
    local closeItem = cc.MenuItemImage:create("pause_normal.png","pause_clicked.png")
    closeItem:setScale(0.7)
    closeItem:setPosition(cc.p(self.origin.x + self.visibleSize.width - closeItem:getContentSize().width / 2, 
    self.origin.y + self.visibleSize.height - 20))
    closeItem:registerScriptTapHandler(menuPauseCB)

    local menu = cc.Menu:create(closeItem)
    menu:setPosition(cc.p(0, 0))
    
    return menu
end

function WorldScene:update(paramTbl)
    --get Param
    local rocker = paramTbl[1]
    local hero =  paramTbl[2]
    local map =  paramTbl[3]
    local attackBtn =  paramTbl[4]
    local bldbar =  paramTbl[5]
    local skillbar = paramTbl[6] 
    local boss =  paramTbl[7] 
    local killBtn =  paramTbl[8] 
    local cureBtn =  paramTbl[9]
    local infrantries = paramTbl[10]
    -- moving hero at every frame
    local function tick()
        if rocker.rockerDirection == 2 then
            hero:runAnimation(self.pFrameCache, "hero_run", 8, rocker.rockerRun)
            if(hero:getPositionX() <= self.visibleSize.width - 8 and hero:judegWalk()) then
                if (not hero:judgePosition(self.visibleSize) or map:judgeMap(hero,self.visibleSize))then          
                    local x, y = hero:getPosition()
                    hero:setPosition(cc.p(x + 1,y))
                else
                    map:MoveMap(hero, self.visibleSize)   
                end    
            end
        elseif rocker.rockerDirection == 3 then
            hero:runAnimation(self.pFrameCache, "hero_run", 8, rocker.rockerRun)
            if(hero:getPositionY() <= self.visibleSize.height - 170 and hero:judegWalk()) then
                local x, y = hero:getPosition()
                hero:setPosition(cc.p(x,y + 1))
            end
        elseif rocker.rockerDirection == 4 then
            hero:runAnimation(self.pFrameCache, "hero_run", 8, rocker.rockerRun)
            if(hero:getPositionX() >= 8 and hero:judegWalk()) then
                if (not hero:judgePosition(self.visibleSize) or map:judgeMap(hero,self.visibleSize))then          
                    local x, y = hero:getPosition()
                    hero:setPosition(cc.p(x - 1,y))
                else
                    map:MoveMap(hero, self.visibleSize)   
                end    
            end
        elseif rocker.rockerDirection == 5 then    
            hero:runAnimation(self.pFrameCache, "hero_run", 8, rocker.rockerRun)
            if(hero:getPositionY() >= 100 and hero:judegWalk()) then
                local x, y = hero:getPosition()
                hero:setPosition(cc.p(x,y - 1))
            end
        else
            hero:runEnd()
        end

        -- attack
        if(attackBtn.isTouch)then
            if(hero.isAttack or hero.isKilling or hero.isCuring)then
                return
            end
            
            hero:attackAnimation(self.pFrameCache, "hero_attack", 12, rocker.rockerRun)
        end
        
        --skill
        if(killBtn.isSkilling and killBtn.skillCount == 0 and skillbar:getCurrentProgress() >= 30) then
            if(hero.isAttack or hero.isKilling or hero.isCuring) then
                return
            end
            killBtn.skillCount = killBtn.skillCount + 1
            hero:killAnimation(self.pFrameCache, "hero_kill", 12, rocker.rockerRun)      
            skillbar:setCurrentProgress(skillbar:getCurrentProgress() - 30)
        end
        
        if(cureBtn.isSkilling and cureBtn.skillCount == 0 and skillbar:getCurrentProgress() >= 40) then
            if(hero.isAttack or hero.isCuring or hero.isSkilling) then
                return
            end
            cureBtn.skillCount = cureBtn.skillCount + 1
            hero:cureAnimation(self.pFrameCache, "hero_cure", 4, rocker.rockerRun)
            skillbar:setCurrentProgress(skillbar:getCurrentProgress() - 40)
            bldbar:setCurrentProgress(100)
        end

        -- recover status
        skillbar:setCurrentProgress(skillbar:getCurrentProgress() + 0.005)
        bldbar:setCurrentProgress(bldbar:getCurrentProgress() + 0.005)

        if(hero.isAttack or hero.isKilling) then
            if(not boss.isDead) then
                math.randomseed(tostring(os.time()):reverse():sub(1, 6))
                local probability = math.random()
                if(probability < 0.5) then
                    return
                end
                if(math.abs(hero:getPositionY() - boss:getPositionY() - map:getPositionY()) < 30) then  -- in the acttack area
                    --detect if collision
                    local heroRect = cc.rect(hero:getPositionX(), hero:getPositionY(), 
                        hero:getSprite():getContentSize().width - 70, hero:getSprite():getContentSize().height - 30)
                local bossRect = cc.rect(boss:getPositionX() + map:getPositionX(), boss:getPositionY() + map:getPositionY(), 
                    boss:getSprite():getContentSize().width - 30, boss:getSprite():getContentSize().height - 20)
                    if(self:isRectCollision(heroRect, bossRect)) then
                        local curKey = "boss"..self.sceneNum.."_hurt"
                    boss:hurtAnimation(self.pFrameCache, curKey, self.bossAct["hurt"][curKey], boss.bossDirection, hero.isKilling)
                    end
                end 
            end
        end
        
        if(boss.isAttack and not boss.isDead) then
            bldbar:setCurrentProgress(bldbar:getCurrentProgress() - 0.1)
            if(bldbar:getCurrentProgress() == 0) then
                local function onNodeEvent(event)
                    if "exit" == event then
                        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
                    end
                end
                self:registerScriptHandler(onNodeEvent)
                --hero dead animation
                local scene = require("scene.GameDead")
                local deadScene = scene.create(self.sceneNum, self.isSound)
                cc.Director:getInstance():replaceScene(deadScene)
                cc.SimpleAudioEngine:getInstance():stopAllEffects()
            elseif(bldbar:getCurrentProgress() <= 20) then
                self.lowBloodSprite:setVisible(true)
            else
                self.lowBloodSprite:setVisible(false)
            end
        end
        
        
        
        if(boss.isDead) then
            local function onNodeEvent(event)
                if "exit" == event then
                    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
                end
            end
            self:registerScriptHandler(onNodeEvent)
            if(self.sceneNum < 3) then
                local sceneNext = require("scene.WorldScene")
                local nextWorldScene = sceneNext.create(self.sceneNum + 1, self.isSound)
                cc.Director:getInstance():replaceScene(nextWorldScene)
            else
                local scene = require("scene.Story")
                local storyScene = scene.create(true)
                cc.Director:getInstance():replaceScene(storyScene)
            end
        end
        
        --deal with infrantries
        for i = 1, #(infrantries) 
        do
            if(infrantries[i].isAttack and not infrantries[i].isDead) then
                bldbar:setCurrentProgress(bldbar:getCurrentProgress() - 0.02)
                if(bldbar:getCurrentProgress() == 0) then
                    local function onNodeEvent(event)
                        if "exit" == event then
                            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
                        end
                    end
                    self:registerScriptHandler(onNodeEvent)
                    --hero dead animation
                    local scene = require("scene.GameDead")
                    local deadScene = scene.create(self.sceneNum, self.isSound)
                    cc.Director:getInstance():replaceScene(deadScene)
                    cc.SimpleAudioEngine:getInstance():stopAllEffects()
                 elseif(bldbar:getCurrentProgress() <= 20) then
                    self.lowBloodSprite:setVisible(true)
                else
                    self.lowBloodSprite:setVisible(false)
                end
            end
            
            if(hero.isAttack or hero.isKilling) then
                local attackRange = 60
                if hero.isKilling then
                    attackRange = 100
                end

                if(not infrantries[i].isDead) then
                    if(math.abs(hero:getPositionY() - infrantries[i]:getPositionY()  - map:getPositionY() ) < attackRange and
                        math.abs(hero:getPositionX() - infrantries[i]:getPositionX()  - map:getPositionX()) < attackRange) then  -- in the acttack area
                        --detect if collision
                        local heroRect = cc.rect(hero:getPositionX(), hero:getPositionY(), 
                            hero:getSprite():getContentSize().width - 70, hero:getSprite():getContentSize().height - 30)
                        local infrantryRect = cc.rect(infrantries[i]:getPositionX() + map:getPositionX(), infrantries[i]:getPositionY() + map:getPositionY(), 
                            infrantries[i]:getSprite():getContentSize().width - 30, infrantries[i]:getSprite():getContentSize().height - 20)
                        if(self:isRectCollision(heroRect, infrantryRect)) then
                            local curKey = ""
                            if(i <= self.infantryOne) then
                                curKey = "infantry1_hurt"
                            elseif(i <= self.infantryOne + self.infantryTwo) then
                                curKey = "infantry2_hurt"
                            else
                                curKey = "infantry3_hurt"
                            end
                            infrantries[i]:hurtAnimation(self.pFrameCache, curKey, self.infantryAct["hurt"][curKey], infrantries[i].infantryDirection, hero.isKilling)
                        end
                    end 
                end
            end
            
        end
    end
    
    self.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(tick, 0, false)
end

function WorldScene:isRectCollision(rect1, rect2)
    local x1 = rect1.x           --rect center x
    local y1 = rect1.y           --rect center y
    local w1 = rect1.width       --rect width
    local h1 = rect1.height      --rect height
    local x2 = rect2.x           --rect center x
    local y2 = rect2.y           --rect center y
    local w2 = rect2.width       --rect width
    local h2 = rect2.height      --rect height
    
    if(x1 + w1*0.5 < x2 - w2*0.5) then   --rect1 is on the left side of rect2
        return false
    elseif(x1 - w1*0.5 > x2 + w2*0.5) then  --rect1 is on the right side of rect2
        return false
    elseif(y1 + h1*0.5 < y2 - h2*0.5) then  --rect1 is on the bottom of rect2
        return false
    elseif(y1 - h1*0.5 > y2 + h2*0.5) then  --rect1 is on the top of rect2
        return false
    end
    return true
end

return WorldScene
