local Story = class("Story",function()
    return cc.Scene:create()
end)


--create story
function Story.create(isEnd)
    local story = Story.new()
    story:createStory(isEnd)
    return story
end

function Story:ctor()
    self.isEnd = false
end


function Story:createStory(isEnd)
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local origin = cc.Director:getInstance():getVisibleOrigin()
    self.isEnd = isEnd
    
    local story_str = " 盘古开天辟地，\n 清气上浮为天，\n 浊气下沉为地。\n 西华至妙之气化为昆仑；\n "..
        "东华至玄之气化为东海；\n 北极至恶之气化为幽都；\n 南极至善之气化为世间生灵。\n 大荒版图辽阔，\n 有九黎，巴蜀，中原等区域，\n 幽都恶王祸"
        .."害人间，\n 你已成天选之人拯救苍生！"
    local story_img = "welcome.png"
    if isEnd then
        story_str = "经过这场大战，\n消灭了幽都至恶之气的影响，\n世间生灵免遭毒害。\n西王母移昆仑山于幽都之上,"..
        "\n镇守幽都。\n帝俊则派出司幽设下太古铜门，\n并请十二上仙在门上设立天元地极锁，\n封印了太古铜门，\n幽都乃与大荒世界隔绝。\n"
        .."位居十二上仙之首的广成子游历大荒，\n在巴蜀锁妖塔发现了另一个通往幽都的裂口，\n于是建立了弈剑听雨阁，\n由门下弟子负责镇守这个裂口。"..
        "\n大荒世界归于一片祥和！"
        story_img = "end_story.png"
    end
    
    local function rollEnd()
        local scene = require("scene.GameLogin")
        local loginScene = scene.create()
        cc.SimpleAudioEngine:getInstance():stopMusic()
        cc.Director:getInstance():replaceScene(loginScene)
    end
    -- add button
    local closeItem = cc.MenuItemImage:create("skip.png", "skip.png")
    closeItem:setPosition(cc.p(visibleSize.width - 60, visibleSize.height - 20))
    if isEnd then
        closeItem:setColor(cc.c3b(0,255,255))
    end    
    closeItem:registerScriptTapHandler(rollEnd)
    
    local menu = cc.Menu:create(closeItem)
    menu:setPosition(cc.p(0, 0))
    self:addChild(menu, 1)
    
    -- add background
    local bgSprite = cc.Sprite:create(story_img)
    bgSprite:setPosition(cc.p(visibleSize.width / 2 + origin.x, visibleSize.height / 2 + origin.y))
    self:addChild(bgSprite, 0)
    
    --create story words
    local storyLabel = cc.Label:createWithSystemFont(story_str, "arial", 25)
    storyLabel:setAnchorPoint(cc.p(0, 0))
    storyLabel:setColor(cc.c3b(255,255,0))
    storyLabel:setPosition(cc.p(50, -200))
    
    local clipShap = cc.DrawNode:create()
    local vertices = {cc.p(50, 20), cc.p(400, 20), cc.p(400, 250), cc.p(50, 250)}
    clipShap:drawPolygon(vertices,4,cc.c4f(255,255,255,255),0, cc.c4f(255,255,255,255))
    
    local mclip = cc.ClippingNode:create()
    mclip:setInverted(false)
    mclip:setStencil(clipShap)
    mclip:addChild(storyLabel)
    self:addChild(mclip)
    
    local act = cc.MoveBy:create(10.0, cc.p(20, 300))
    local callFunc = cc.CallFunc:create(rollEnd,{})
    local moveAct = cc.Sequence:create(act,callFunc,nil)
    storyLabel:runAction(moveAct)
    
    return true
end

return Story