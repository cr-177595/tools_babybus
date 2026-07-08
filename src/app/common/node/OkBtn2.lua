--[[

    Copyright (c) 2011-2025 baby-bus.com
    TODO:	打勾按钮（不带绳子）
    Author: CR
    Date:   2025.06.13
    http://www.babybus.com/

]]

local M = classSpriteTouch("OkBtn")

----------------------
-- 公共参数
----------------------
-- [常量]
-- ..

-- [操作变量]
-- ..

----------------------
-- 构造方法
----------------------
--[[--

构造方法，定义结点实例初始化逻辑

### Parameters:
-   table **params**    参数集合

### Return: 
-   object              对象实例

]]
function M:ctor(params)
    -- [超类调用]
    M.super.ctor(self, params)

	-- 父节点
	self._parent = params.parent
	-- 资源路径
	self._img 	 = params.img or "common/okbtn/btn.png"
	-- 初始大小
	self._scale  = params.scale or 1
end

----------------------
-- 渲染 
----------------------
--[[--

实体渲染，处理实体结点加载、事件绑定等相关操作

]]
function M:onRender()
    -- [超类调用]
    M.super.onRender(self)

	-- 加载显示
	self:loadDisplay()
	-- 加载光效
	self:loadLight()
end

-- 加载显示
function M:loadDisplay()
	self:display(self._img)
end

-- 加载光效
function M:loadLight()
	self._light = D.img("common/okbtn/1.png"):to(self, 5):p(70.5, 35.2):scale(1.5):opacity(0)
	local par = P.newParticle("particle/dagou1.plist"):to(self):p(self:cw()/2, self:ch()/2):hide()
    par:setPositionType(kCCPositionTypeRelative)
    self._par = par
	self._par:stopSystem()
end

----------------------
-- 功能函数 
----------------------
-- 进场
function M:enter()
	if self._isEnter then return end
	self._isEnter = true
	self:unbindTouch()

	self:scale(0)
	soundVoice:stopNowSound()
	-- 播放语音[v293207023]完成后点点打钩。
	soundVoice:playEffectv293207023()
	-- 播放音效[sfx293000047]打钩键出现
	soundEffect:playEffectsfx293000047()
	self:line({
		{"show"},
		{"easing", "backout", {"scaleTo", 0.5, 1}},
		{"fn", function()
			self._par:show()
			self._par:resetSystem()
		end},
		{"scaleTo", 0.1, 0.98},
		{"scaleTo", 0.1, 1},
		{"fn" , function()
			self:bindTouch()
			self:openGuide()
		end},		
	})
end

-- 退场
function M:quit()
	if not self._isEnter then return end
	self._isEnter = false

	self:unbindTouch()
	self:stop()
	self:line({
		{"easing", "backin", {"scaleTo", 0.25, 0}},
		{"hide"}
	})

	if self._parent and self._parent.okBtnEvent then
		self._parent:okBtnEvent()
	else
		self:okBtnEvent()
	end
end

-- OK按钮事件
function M:okBtnEvent()
	print("OK按钮事件未重写")
end

----------------------
-- 引导 
----------------------
-- 光圈引导
function M:openGuide()
	if not self._isEnter then return end
	if self._guideAct then return end
	-- 
	self._guideAct = A.cycle({
		{"delay", 3},
		{"fn", function()
			-- 光效动作
			self:lightAction()
		end},
		{"delay", 0.5}
	}):at(self)
end

-- 停止光圈引导
function M:stopGuide()
	if self._guideAct then
		self:stopAction(self._guideAct)
    	self._guideAct = nil
    	self:scale(1)
	end
end

-- 光效动作
function M:lightAction()
	self._light:line({
		{"fadeIn", 0.3},
		{"fadeOut", 0.5}
	})
	
	self:line({
		{"scaleTo", 0.2, 1.15},
		{"fn", function()
			self:lightWave()
		end},
		{"scaleTo", 0.1, 1},
		{"fn", function()
			self:lightWave()
		end},
		{"scaleTo", 0.2, 1.15},
		{"scaleTo", 0.1, 1},
	})
end

-- 光波
function M:lightWave()
	local light = D.img("common/okbtn/2.png"):p(55.5, 61.5):to(self, 30)
	CommonFun:resetParent(light, self._parent)
	light:opacity(0):z(9999)
	soundEffect:playEffectsfx293000081()
	light:line({
		{"union", {
			{"easing", "sineinout", {"scaleTo", .8, 1.5}},
			{"line", {
				{"fadeTo", 0.2, 255},
				{"delay", 0.5},
				{"fadeTo", 0.4, 0}
			}}
		}},
		{"remove"},
	})
end

----------------------
-- 触控函数 
----------------------
function M:onTouchBegan(x, y)
	self:stopGuide()
	self._parent:stopGuide()
	soundEffect:playEffectsfx23305012()
	self._par:stopSystem()
	-- 点击动作
	self:line({
		{"scaleTo", 0.1, self._scale * 1.1}
	})

	return true 
end

function M:onTouchEnded(x, y)
	self:quit()
end

return M