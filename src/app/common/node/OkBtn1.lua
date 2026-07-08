--[[

    Copyright (c) 2011-2025 baby-bus.com
    TODO:	打勾按钮（带绳子）
    Author: CR
    Date:   2025.06.13
    http://www.babybus.com/

]]

local M = classSpriteTouch("OkBtn")

--------------------------
-- 构造函数
--------------------------
function M:ctor(params)
    -- [超类调用]
    M.super.ctor(self, params)

	-- 父节点
	self._parent	= params.emptyNode
	-- 坐标
	self._pos 		= params.pos or ccp(860 + X_OFFSET, 750 + Y_OFFSET*0.83)
	-- 按钮图片
	self._btnImg 	= params.btnImg or "common/ok_3.png"
	-- 绳子图片
	self._ropeImg 	= params.ropeImg or "common/ok_4.png"
end

--------------------------
-- 渲染
--------------------------
--[[--

实体渲染，处理实体结点加载、事件绑定等相关操作

]]
function M:onRender()
    -- [超类调用]
    M.super.onRender(self)

	-- 加载显示
    self:loadDisplay()
	-- 加载按钮
	self:loadButton()
	-- 加载光效
	self:loadLight()
end

-- 加载显示
function M:loadDisplay()
	self:display(self._ropeImg):anchor(ccp(0.5, 0.9)):p(self._pos):rotate(-90)
end

-- 加载按钮
function M:loadButton()
    local btn = U.loadScaleButton({
        -- 按钮图片
        imagename      = self._btnImg,                
        -- 父节点
        parent         = self,                     
        -- 层级
        zorder         = 10,                      
        -- 缩放起始效果
        scaleBegan     = 1,
        -- 缩放结束效果
        scaleEnd       = 1,                       
        -- 位置
        pos            = ccp(6, 0),
        -- 缩放时间
        scaleTime      = 0.2,      
        -- 点击音效
        tabsound       = "effect/sfx23305012.mp3",
        issubmit       = false,
        fnBegan        = function()
			self:union({
				{"moveby", 0.1, ccp(0, -40)},
				{"scaleto", 0.1, 0.9, 1.05},
			})
        end,           
        -- 点击事件
        fnClicked      = function()
        	self:stopAllActions()
			self:line({
				{"scaleto", 0.1, 0.8, 0.8},
			})
			self:quit()
        end,
    })
    self._btn = btn
end

-- 加载光效
function M:loadLight()
    self._light = D.img("common/oklight.png"):to(self._btn, -1):p(self._btn:cw()/2, self._btn:ch()/2):hide():scale(0):opacity(0)
	self._light:cycle({
		{"rotateBy", 4, 360},
    })
	-- 粒子
    self._par = P.newParticle("particle/zhangshi1.plist"):to(self._btn):p(self._btn:cw()/2, self._btn:ch()/2):hide()
	self._par:setPositionType(kCCPositionTypeRelative)
	self._par:stopSystem()
end

--------------------------
-- 功能函数
--------------------------
-- 进场
function M:enter()
	if self._isEnter then return end
	self._isEnter = true

	self._par:show():resetSystem()
	self._light:show():union({
		{"easing", "backout", {"scaleTo", 0.2, 1}},
		{"fadeTo", 0.2, 255}
	})
	-- 播放音效[sfx23305011]打钩键掉落音效
	soundEffect:playEffectsfx23305011()

	self:stopAllActions()
	self:unbindTouch()
	self:show():p(self._pos):rotate(-90):scale(1)
	self:line({
		{ "easing", "backout", { "rotateTo", 0.7, 0,},},
		{"fn" , function()
			self:bindTouch()
			self:cycle({
				{"rotateby" , 0.5 , 4},
				{"rotateby" , 0.5 , -4},
				{"rotateby" , 0.5 , -4},
				{"rotateby" , 0.5 , 4},		
			})
		end},		
	})
end

-- 退场
function M:quit()
	if not self._isEnter then return end
	self._isEnter = false
	
	self:unbindTouch()
	self:line({
		{"easing", "backout", {"moveTo", 0.5, ccp(self._pos.x, V.h + self:ch() + 50)}},
		{"fn" , function()
			self:scale(1)
		end},	
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

return M