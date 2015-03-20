local GameLogin = class("GameLogin",function()
    return cc.Scene:create()
end)

function GameLogin.create()
    local loginScene = GameLogin.new()
    loginScene:loadUI()
    return loginScene
end    

function GameLogin:ctor()
   self.isSound = true
   self.isClick = true
end

function GameLogin:loadUI()
	local visibleSize = cc.Director:getInstance():getVisibleSize()
	local origin = cc.Director:getInstance():getVisibleOrigin()
	
	-- load ui made by cocos studio 
    local layout = ccs.GUIReader:getInstance():widgetFromJsonFile("Login/Login_1.ExportJson")
    layout:setScale(1.0,0.95)
    local uiLayer = cc.Layer:create()
    
    self:addChild(uiLayer)
    uiLayer:addChild(layout)
    self:uiEvent(layout)
    
    return true
end

function GameLogin:uiEvent(layout)
    --enter
    local function touchEnterEvent(sender,eventType)
        if eventType == ccui.TouchEventType.began then
            if self.isClick then
                local scene = require("scene.WorldScene")
                self.worldScene = scene.create(1, self.isSound)
                cc.Director:getInstance():replaceScene(self.worldScene)
                self.isClick = false
            end    
        end
    end

    local enterButton = layout:getChildByName("enterBtn")
    enterButton:addTouchEventListener(touchEnterEvent)
    
    --exit
    local function touchExitEvent(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            cc.Director:getInstance():endToLua()
        end
    end

    local exitButton = layout:getChildByName("exitBtn")
    exitButton:addTouchEventListener(touchExitEvent)
    
    --set
    local function touchAboutEvent(sender,eventType)
        if eventType == ccui.TouchEventType.began then
            local scene = require("scene.GameAbout")
            self.aboutScene = scene.create()
            cc.Director:getInstance():replaceScene(self.aboutScene)
        elseif eventType == ccui.TouchEventType.moved then
            print("Touch Move")
        elseif eventType == ccui.TouchEventType.ended then
            print("Touch Up")
        elseif eventType == ccui.TouchEventType.canceled then
            print("Touch Cancelled")
        end
    end

    local aboutButton = layout:getChildByName("aboutBtn")
    aboutButton:addTouchEventListener(touchAboutEvent)
    
    local function selectedStateEvent(sender,eventType)
        if eventType == ccui.CheckBoxEventType.selected then
            self.isSound = false
        elseif eventType == ccui.CheckBoxEventType.unselected then
            self.isSound = true
        end
    end

    local checkbox = layout:getChildByName("sound")
    checkbox:addEventListener(selectedStateEvent)
end

return GameLogin