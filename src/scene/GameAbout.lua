local GameAbout = class("GameAbout",function()
    return cc.Scene:create()
end)

function GameAbout.create()
    local loginScene = GameAbout.new()
    loginScene:loadUI()
    return loginScene
end    

function GameAbout:ctor()
    
end

function GameAbout:loadUI()
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local origin = cc.Director:getInstance():getVisibleOrigin()

    -- load ui made by cocos studio 
    local layout = ccs.GUIReader:getInstance():widgetFromJsonFile("About_1.json")
    layout:setScale(1.0,0.95)
    local uiLayer = cc.Layer:create()

    self:addChild(uiLayer)
    uiLayer:addChild(layout)
    self:uiEvent(layout)

    return true
end

function GameAbout:uiEvent(layout)
    --exit
    local function touchReturnEvent(sender,eventType)
        if eventType == ccui.TouchEventType.began then
            local scene = require("scene.GameLogin")
            self.loginScene = scene.create()
            cc.Director:getInstance():replaceScene(self.loginScene)
        end
    end

    local returnButton = layout:getChildByName("Back_Login")
    returnButton:addTouchEventListener(touchReturnEvent)
end

return GameAbout