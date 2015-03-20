local FlyWord = class("FlyWord",function()
    return cc.Node:create()
end)


--create hero
function FlyWord.create(word, fontSize, begin)
    local flyWord = FlyWord.new()
    if(flyWord and flyWord:createFlyWord(word,fontSize,begin)) then
        --flyWord:release()
        return flyWord
    end
    return nil
end

function FlyWord:ctor()
    self.begin = nil
    self.labelttf = nil
end

function FlyWord:createFlyWord(word, fontSize, begin)
    --init
    self.begin = begin
  
    self.labelttf = cc.Label:createWithSystemFont(word, "Marker Felt", fontSize)
    --set color
    self.labelttf:setColor(cc.c3b(255,0,0))
    self:addChild(self.labelttf)
    self:setPosition(cc.p(begin.x, begin.y))
    
    --unvisible
    self:setVisible(false)
    
    return true
end

function FlyWord:flying(word)
    self.labelttf:setString(word)
    local moveAct = cc.MoveBy:create(0.5, cc.p(0, 70))
    
    local function flyEnd()
        --self:removeAllChildren(true)
        --self:removeFromParent(true)
        self:setVisible(false)
        self:setPosition(cc.p(self.begin.x, self.begin.y))
    end
    local callFunc = cc.CallFunc:create(flyEnd,{})
    local act = cc.Sequence:create(moveAct,callFunc,nil)
    self:setVisible(true)
    self:runAction(act) 
end


return FlyWord
