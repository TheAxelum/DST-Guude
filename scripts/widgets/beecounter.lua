local Widget = require "widgets/widget"
local Text = require "widgets/text"

BeeWidget = Class(Widget, function(self, owner)    
	Widget._ctor(self, "BeeWidget")    
	self.owner = owner    
	self.base_scale = 0.5    
	self:SetScaleMode(SCALEMODE_PROPORTIONAL)    
	self:SetHAnchor(ANCHOR_LEFT)
	self:SetVAnchor(ANCHOR_BOTTOM)
	self:SetPosition(60,20,0)  
	self.text = self:AddChild(Text(NUMBERFONT, 14 / self.base_scale))
end)

function BeeWidget:Update(val)
	self.text:SetString(val)
end

return BeeWidget
