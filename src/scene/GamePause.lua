local GamePause = class("GamePause",function()
    return cc.Scene:create()
end)

--create rocker
function GamePause.create(sqr, sceneNum, isSound,  boss_node, infrantries, hero, map)
    local scene = GamePause.new()
    scene:createMenu(sqr, sceneNum, isSound,  boss_node, infrantries, hero, map)
    return scene
end

function GamePause:ctor()
    self.sceneNum = 1
    self.isSound = false
end

function GamePause:createMenu(sqr, sceneNum, isSound,  boss_node, infrantries, hero, map)
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local origin =  cc.Director:getInstance():getVisibleOrigin()
   
    self.sceneNum = sceneNum
    self.isSound = isSound
   
    local frameCache = cc.SpriteFrameCache:getInstance()
    frameCache:addSpriteFrames("pause_scene.plist","pause_scene.png")

    -- continue button
    local function menuContinueCB()
        cc.Director:getInstance():popScene()
        boss_node:startListen(hero, map)
        for i = 1, #(infrantries) 
        do
            infrantries[i]:startListen(hero, map)
        end
        cc.SimpleAudioEngine:getInstance():resumeAllEffects()
    end

    local function menuRestartCB()
        local scene = require("scene.WorldScene")
        local worldScene = scene.create(self.sceneNum, self.isSound)
        cc.Director:getInstance():replaceScene(worldScene)
    end

    local function menuLoginCB()
        local scene = require("scene.GameLogin")
        local loginScene = scene.create()
        cc.SimpleAudioEngine:getInstance():stopMusic()
        cc.Director:getInstance():replaceScene(cc.TransitionPageTurn:create(1, loginScene, true))
    end
   
    local function menuChooseCB()
        local GameChoose_layer = require("scene.GameChoose")
        cc.Director:getInstance():pushScene(GameChoose_layer.create(self.isSound))
    end
   
    local quitItem = cc.MenuItemSprite:create(cc.Sprite:createWithSpriteFrame(frameCache:getSpriteFrame("pause_close.png"))
        ,cc.Sprite:createWithSpriteFrame(frameCache:getSpriteFrame("pause_close.png")))
    quitItem:setScale(0.4)    
    quitItem:setPosition(cc.p(visibleSize.width / 2 - 87.5, visibleSize.height / 2 + 114))
    quitItem:registerScriptTapHandler(menuContinueCB)

    local chooseItem = cc.MenuItemSprite:create(cc.Sprite:createWithSpriteFrame(frameCache:getSpriteFrame("pause_choose.png"))
        ,cc.Sprite:createWithSpriteFrame(frameCache:getSpriteFrame("pause_choose.png")))
    chooseItem:setScale(0.6)    
    chooseItem:setPosition(cc.p(visibleSize.width / 2, visibleSize.height / 2 + 50))
    chooseItem:registerScriptTapHandler(menuChooseCB)

    local restartItem = cc.MenuItemSprite:create(cc.Sprite:createWithSpriteFrame(frameCache:getSpriteFrame("pause_restart.png"))
        ,cc.Sprite:createWithSpriteFrame(frameCache:getSpriteFrame("pause_restart.png")))
    restartItem:setScale(0.6)
    restartItem:setPosition(cc.p(visibleSize.width / 2, visibleSize.height / 2))
    restartItem:registerScriptTapHandler(menuRestartCB)

    local loginItem = cc.MenuItemSprite:create(cc.Sprite:createWithSpriteFrame(frameCache:getSpriteFrame("pause_login.png"))
        ,cc.Sprite:createWithSpriteFrame(frameCache:getSpriteFrame("pause_login.png")))
    loginItem:setScale(0.6)    
    loginItem:setPosition(cc.p(visibleSize.width / 2, visibleSize.height / 2 - 50))
    loginItem:registerScriptTapHandler(menuLoginCB)

    local menu = cc.Menu:create(quitItem, chooseItem,restartItem,loginItem)
    menu:setPosition(cc.p(0,0))
    self:addChild(menu, 2)
    -- user the snapshot sqr texture to create sprite, and add sprite into GamePause scene
    -- get the window size
    local back_sqr = cc.Sprite:createWithTexture(sqr:getSprite():getTexture())
    back_sqr:setPosition(cc.p(visibleSize.width / 2, visibleSize.height / 2 + 25))
    back_sqr:setFlippedY(true)        --reverse for the UI coordinate is different from OpenGL
    back_sqr:setColor(cc.c3b(125.0,125.0,125.0))
    back_sqr:setOpacity(128)
    self:addChild(back_sqr)
    
    -- add buttons frame
    --local back_btns_frame = cc.Sprite:create("back_pause.png")
    local back_btns_frame = cc.Sprite:createWithSpriteFrame(frameCache:getSpriteFrame("pause_bg.png"))
    back_btns_frame:setPosition(cc.p(visibleSize.width / 2, visibleSize.height / 2 + 20))
    back_btns_frame:setScale(0.4)
    self:addChild(back_btns_frame)

    return true
end

return GamePause
