local GameChoose = class("GameChoose",function()
    return cc.Scene:create()
end)

--create rocker
function GameChoose.create(isSound)
    local scene = GameChoose.new()
    scene:createMenu(isSound)
    return scene
end

function GameChoose:ctor()
    self.isSound = nil
end

function GameChoose:createMenu(isSound)
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local origin =  cc.Director:getInstance():getVisibleOrigin()

    self.isSound = isSound
    local frameCache = cc.SpriteFrameCache:getInstance()
    frameCache:addSpriteFrames("choose_scene.plist","choose_scene.png")

    -- continue button
    local function menuContinueCB()
        cc.Director:getInstance():popScene()
    end

    local function menuScene1CB()
        local scene = require("scene.WorldScene")
        local worldScene = scene.create(1, self.isSound)
        cc.Director:getInstance():replaceScene(worldScene)
    end
    
    local function menuScene2CB()
        local scene = require("scene.WorldScene")
        local worldScene = scene.create(2, self.isSound)
        cc.Director:getInstance():replaceScene(worldScene)
    end
    
    local function menuScene3CB()
        local scene = require("scene.WorldScene")
        local worldScene = scene.create(3, self.isSound)
        cc.Director:getInstance():replaceScene(worldScene)
    end

  

    local quitItem = cc.MenuItemSprite:create(cc.Sprite:createWithSpriteFrame(frameCache:getSpriteFrame("choose_close.png"))
        ,cc.Sprite:createWithSpriteFrame(frameCache:getSpriteFrame("choose_close.png")))  
    quitItem:setPosition(cc.p(visibleSize.width / 2 + 190, visibleSize.height / 2 + 113))
    quitItem:registerScriptTapHandler(menuContinueCB)

    local scene1Item = cc.MenuItemSprite:create(cc.Sprite:createWithSpriteFrame(frameCache:getSpriteFrame("choose_scene1.png"))
        ,cc.Sprite:createWithSpriteFrame(frameCache:getSpriteFrame("choose_scene1.png"))) 
    scene1Item:setPosition(cc.p(visibleSize.width / 2 - 140, visibleSize.height / 2 - 27))
    scene1Item:registerScriptTapHandler(menuScene1CB)

    local scene2Item = cc.MenuItemSprite:create(cc.Sprite:createWithSpriteFrame(frameCache:getSpriteFrame("choose_scene2.png"))
        ,cc.Sprite:createWithSpriteFrame(frameCache:getSpriteFrame("choose_scene2.png")))
    scene2Item:setPosition(cc.p(visibleSize.width / 2 - 5, visibleSize.height / 2 - 27))
    scene2Item:registerScriptTapHandler(menuScene2CB)

    local scene3Item = cc.MenuItemSprite:create(cc.Sprite:createWithSpriteFrame(frameCache:getSpriteFrame("choose_scene3.png"))
        ,cc.Sprite:createWithSpriteFrame(frameCache:getSpriteFrame("choose_scene3.png")))
    scene3Item:setPosition(cc.p(visibleSize.width / 2 + 130, visibleSize.height / 2 - 27))
    scene3Item:registerScriptTapHandler(menuScene3CB)

    local menu = cc.Menu:create(quitItem, scene1Item, scene2Item, scene3Item)
    menu:setPosition(cc.p(0,0))
    self:addChild(menu, 2)

    --local back_btns_frame = cc.Sprite:create("back_pause.png")
    local back_btns_frame = cc.Sprite:createWithSpriteFrame(frameCache:getSpriteFrame("choose_bg.png"))
    back_btns_frame:setPosition(cc.p(visibleSize.width / 2, visibleSize.height / 2))
    self:addChild(back_btns_frame)

    return true
end

return GameChoose
