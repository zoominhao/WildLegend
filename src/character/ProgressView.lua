local ProgressView = class("ProgressView",function()
    return cc.Node:create()
end)

--create button   
function ProgressView.create()
    local progressView = ProgressView.new()
    return progressView
end

function ProgressView:ctor()
    self.progressBackground = nil  --blood background
    self.progressForeground = nil  --blood foreground
    self.totalProgress = 0.0       --total blood
    self.currentProgress = 0.0     --current blood
    self.scale = 1.0               --zoomin scale
end

--set blood background
function ProgressView:setBackgroundTexture(bgName)
    self.progressBackground = cc.Sprite:create(bgName)
    self:addChild(self.progressBackground)
end

--set blood foreground
function ProgressView:setForegroundTexture(fgName)
    self.progressForeground = cc.Sprite:create(fgName)
    self.progressForeground:setAnchorPoint(cc.p(0.0,0.5))
    self.progressForeground:setPosition(cc.p(-self.progressForeground:getContentSize().width * 0.5, 0))
    self:addChild(self.progressForeground)
end

--set total blood
function ProgressView:setTotalProgress(total)
    if(self.progressForeground == nil) then
        return
    end
    self.scale = self.progressForeground:getContentSize().width / total
    self.totalProgress = total
end

--set current blood
function ProgressView:setCurrentProgress(progress)
    if(self.progressForeground == nil) then
        return
    end
    if(progress < 0.0) then
        progress = 0.0
    end
    if(progress > self.totalProgress) then
        progress = self.totalProgress
    end
    self.currentProgress = progress  
    local rectWidth = progress * self.scale

    local from = self.progressForeground:getTextureRect()
    local rect = cc.rect(from.x,from.y,rectWidth,self.progressForeground:getContentSize().height)
    self:setForegroundTextureRect(rect)    
end

--set foreground blood display length
function ProgressView:setForegroundTextureRect(rect)
    self.progressForeground:setTextureRect(rect)
end

--get current blood
function ProgressView:getCurrentProgress()
    return self.currentProgress
end    

--get total blood
function ProgressView:getTotalProgress()
    return self.totalProgress
end

return ProgressView