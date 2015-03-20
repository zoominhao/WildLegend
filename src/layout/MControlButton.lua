local MControlButton = class("MControlButton",function()
    return cc.Node:create()
end)

--enum
local tagForTouch =
{
    touch_begin = 1,
    touch_down = 2,
    touch_up = 3
}


--create button   
function MControlButton.create(pngName, buttonTitle, num)
    local mControlButton = MControlButton.new()
    mControlButton:createButton(pngName, buttonTitle, num)
    return mControlButton
end

function MControlButton:ctor()
   self.controlBtn = nil
   self.isTouch = false
end

--pngName image name for button; buttonTitle title on button; num transparent 0-100
function MControlButton:createButton(pngName, buttonTitle, num)
    buttonTitle = buttonTitle or "0"
    num = num or 0
    -- get the size of btn png
    local btn = ccui.Scale9Sprite:create(pngName)
    local pngHeight = btn:getContentSize().height
    local pngWidth = btn:getContentSize().width
    --btn:release()
    
    -- display size
    local rect = cc.rect(0, 0, pngWidth, pngHeight)
    local rectInsets = cc.rect(1, 1, 1, 1) 
    
    -- button title
    local title = cc.Label:createWithTTF(buttonTitle,"fonts/Marker Felt.ttf",pngHeight - 10)
    title:setOpacity(num)  
    
    -- normal state
    local btnNormal = ccui.Scale9Sprite:create(pngName,rect,rectInsets)
    
    -- create button
    self.controlBtn = cc.ControlButton:create(title, btnNormal)
    self:addChild(self.controlBtn)
    --bind event
    self:bindButtonEvent()
end

function MControlButton:bindButtonEvent()
    if(not self.controlBtn) then
        return
    end
    -- 当鼠标处于按下并曾经点中按钮时，触发一次
    local function touchDownAction(touch, event)
        self.isTouch = true
        return true
    end
    
    -- 当鼠标处于按下并曾经点中按钮的状态下，鼠标进入按钮范围，则触发一次
    local function touchDragEnter(touch, event)
        return true
    end
    
    -- 当鼠标处于按下并曾经点中按钮的状态下，鼠标离开按钮范围，则触发一次
    local function touchDragExit(touch, event)
        return true
    end
    
    -- 当鼠标处于按下并曾经点中按钮的状态下，鼠标进入按钮范围，则触发，只要达到条件，就不断触发
    local function touchDragInside(touch, event)
        return true
    end
    
    -- 当鼠标处于按下并曾经点中按钮的状态下，鼠标离开按钮范围，则触发，只要达到条件，就不断触发
    local function touchDragOutside(touch, event)
        return true
    end

    -- 当鼠标处于按下并曾经点中的状态下，鼠标松开且在按钮范围内，则触发一次
    local function touchUpInside(touch, event)
        self.isTouch = false
        return true
    end
    
    -- 当鼠标处于按下并曾经点中按钮的状态下，鼠标松开且在按钮范围外，则触发一次
    local function touchUpOutside(touch, event)
        return true
    end
    
    -- 暂时没有发现能用鼠标触发这个事情的操作，看了注释，应该是有其它事情中断按钮事情而触发的
    local function touchCancel(touch, event)
        return true
    end
    
    
    
    self.controlBtn:registerControlEventHandler(touchDownAction,cc.CONTROL_EVENTTYPE_TOUCH_DOWN)
    self.controlBtn:registerControlEventHandler(touchDragEnter,cc.CONTROL_EVENTTYPE_DRAG_ENTER)
    self.controlBtn:registerControlEventHandler(touchDragExit,cc.CONTROL_EVENTTYPE_DRAG_EXIT)
    self.controlBtn:registerControlEventHandler(touchDragInside,cc.CONTROL_EVENTTYPE_DRAG_INSIDE)
    self.controlBtn:registerControlEventHandler(touchDragOutside,cc.CONTROL_EVENTTYPE_DRAG_OUTSIDE)
    self.controlBtn:registerControlEventHandler(touchUpInside,cc.CONTROL_EVENTTYPE_TOUCH_UP_INSIDE)
    self.controlBtn:registerControlEventHandler(touchUpOutside,cc.CONTROL_EVENTTYPE_TOUCH_UP_OUTSIDE)
    self.controlBtn:registerControlEventHandler(touchCancel,cc.CONTROL_EVENTTYPE_TOUCH_CANCEL)
end


return MControlButton


