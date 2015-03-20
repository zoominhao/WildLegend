local GameDead = class("GameDead",function()
    return cc.Scene:create()
end)

--create rocker
function GameDead.create(sceneNum, isSound)
    local scene = GameDead.new()
    scene:createMenu(sceneNum, isSound)
    return scene
end

function GameDead:ctor()
    self.sceneNum = 1
    self.isSound = false
end

function GameDead:createMenu(sceneNum, isSound)
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local origin =  cc.Director:getInstance():getVisibleOrigin()

    self.sceneNum = sceneNum
    self.isSound = isSound
    local frameCache = cc.SpriteFrameCache:getInstance()
    frameCache:addSpriteFrames("dead_scene.plist","dead_scene.png")

    -- continue button
    local function menuRestartCB()
        local scene = require("scene.WorldScene")
        local worldScene = scene.create(sceneNum, self.isSound)
        cc.Director:getInstance():replaceScene(worldScene)
    end

    local function menuExitCB()
        cc.SimpleAudioEngine:getInstance():stopMusic()
        cc.SimpleAudioEngine:getInstance():stopAllEffects()
        local scene = require("scene.GameLogin")
        local loginScene = scene.create()
        cc.Director:getInstance():replaceScene(loginScene)
    end



    local restartItem = cc.MenuItemSprite:create(cc.Sprite:createWithSpriteFrame(frameCache:getSpriteFrame("dead_continue.png"))
        ,cc.Sprite:createWithSpriteFrame(frameCache:getSpriteFrame("dead_continue.png")))  
    restartItem:setPosition(cc.p(visibleSize.width / 2, visibleSize.height / 2 + 30))
    restartItem:registerScriptTapHandler(menuRestartCB)
    restartItem:setScale(0.6)

    local exitItem = cc.MenuItemSprite:create(cc.Sprite:createWithSpriteFrame(frameCache:getSpriteFrame("dead_exit.png"))
        ,cc.Sprite:createWithSpriteFrame(frameCache:getSpriteFrame("dead_exit.png")))  
    exitItem:setPosition(cc.p(visibleSize.width / 2, visibleSize.height / 2 - 30))
    exitItem:registerScriptTapHandler(menuExitCB)
    exitItem:setScale(0.6)
    

    local menu = cc.Menu:create(restartItem, exitItem)
    menu:setPosition(cc.p(0,0))
    self:addChild(menu, 2)

    --local back_btns_frame = cc.Sprite:create("back_pause.png")
    local back_btns_frame = cc.Sprite:createWithSpriteFrame(frameCache:getSpriteFrame("dead_bg.jpg"))
    back_btns_frame:setPosition(cc.p(visibleSize.width / 2, visibleSize.height / 2))
    self:addChild(back_btns_frame)

    return true
end

return GameDead
