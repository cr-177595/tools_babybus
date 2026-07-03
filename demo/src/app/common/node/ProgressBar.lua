--[[

	Copyright (c) 2011-2024 baby-bus.com

	TODO:   进度条
	Author: CR
	Date:   2024.01.23
 
	http://www.babybus.com/

]] 

----------------------
-- 类
----------------------
local M = classSpriteTouch("ProgressBar")

----------------------
-- 公共参数
----------------------
-- [常量]
-- ..

----------------------
-- 构造方法
----------------------
--[[--

构造方法，定义视图实例初始化逻辑

### Parameters:
-   table **params**    参数集合

### Return: 
-   object              对象实例

]]
function M:ctor(params)
    -- [超类调用]
	M.super.ctor(self, params)
    -- 主层
    self._layer  	 = params.layer
	-- 视图节点
	self._viewNode   = params.viewNode
	-- 资源前缀
	self._imgPre 	 = "common/progressbar/"
	-- 数字
	self._num    	 = 0
	-- 当前进度值
	self._curPercent = 0/100
	-- 每次进度值增量
	self._addPercent = 1/6
	-- 进场坐标
	self._enterPos 	 = params.enterPos
	-- 退场坐标
	self._quitPos  	 = params.quitPos
end

----------------------
-- 结点渲染
----------------------
--[[--

视图渲染，处理视图结点加载、事件绑定等相关操作

]]
function M:onRender()
    -- [超类调用]
    M.super.onRender(self)
	-- 加载显示
	self:loadDisplay()
	-- 创建数字节点
	self:createNumNode(self._num)
end

function M:onEnterTransitionFinish()
	
end

-- 加载显示
function M:loadDisplay()
	self:display(self._imgPre.."frame.png")
	-- 图标
	self._icon = D.img(self._imgPre.."icon.png"):to(self, 90):p(self:cw()/2 + 2, 320.2)
	-- 后层
	self._base = D.img(self._imgPre.."base.png"):to(self, -20):a(ccp(0.5, 0)):p(24.8, -4.8)
	-- 颜色条
	self._bar = U.loadProgressBar({
        imgName       = self._imgPre.."bar.png",
        mode          = kCCProgressTimerTypeBar,
        midpoint      = ccp(0, 0),
        barChangeRate = ccp(0, 1),
        isAutoRun     = false,
    }):to(self, -10):p(self:cw()/2, self:ch()/2)
	-- 进度条粒子
	self._par = P.newParticle("particle/jindutiaotongyong.plist"):to(self._bar, 100):p(self._bar:cw()/2, 0):scale(0.7):hide()
	self._par:setPositionType(kCCPositionTypeGrouped)
end

-- 创建数字节点
function M:createNumNode(num)
	local offsetPTab = {
		[0] = ccp(-1, 0),
		[1] = ccp(-3, 0),
		[2] = ccp(-1, 2),
		[3] = ccp(-1, 0),
		[4] = ccp(-3, 1),
		[5] = ccp(-1, 0),
		[6] = ccp(-2, 1),
		[7] = ccp(1, -1),
		[8] = ccp(-1, 1),
		[9] = ccp(-1, 0),
	}
	local offsetP = offsetPTab[num]
	local numNode = U.loadNodeMask({ 
        contentSize = cc.size(100, 100),
        color       = COLOR3_WHITE,
        opacity     = 0,
    }):p(ccpAdd(ccp(self._icon:cw()/2, self._icon:ch()/2), offsetP)):to(self._icon):scale(1):unbindTouch()
	self._numNode = numNode

	-- 数字节点坐标配置 按照个、十、百位顺序
	local cw, ch = numNode:cw(), numNode:ch()
	local posConfig = {
		{ccp(cw/2, ch/2)},
		{ccp(cw*5/7, ch/2), ccp(cw*2/7, ch/2)},
		{ccp(cw*4/5, ch/2), ccp(cw/2, ch/2), ccp(cw*1/5, ch/2)},
	}

	local posTab
	if num < 10 then
		posTab = posConfig[1]
	elseif num < 100 then
		posTab = posConfig[2]
	elseif num >= 100 then
		posTab = posConfig[3]
	end
	-- 个、十、百位数
	local numTab = {num%10, math.floor(num/10)%10, math.floor(num/100)}
	for i, pos in pairs(posTab) do
		local number = D.img(self._imgPre.."num/"..numTab[i]..".png"):to(numNode, 2):p(pos)
	end
end

----------------------
-- 功能函数
----------------------
-- 进场
function M:enter(fn)
	-- 播放音效[sfx233022022]进度条出现
	soundEffect:playEffectsfx233022022()
	self:line({
		{"easing", "backOut", {"moveTo", 0.4, self._enterPos}},
		{"fn", function ()
			if fn then fn() end
		end}
	})
end

-- 退场
function M:quit(fn)
	self:line({
		{"easing", "backIn", {"moveTo", 0.4, self._quitPos}},
		{"fn", function ()
			if fn then fn() end
		end}
	})
end

-- 进度条上涨
function M:raise(time)
	time = ifnil(time, 0.5)
	self._curPercent = self._curPercent + self._addPercent
	local value = 100 * self._curPercent
	self._bar:progressTo({time = time, value = value})

	-- 改变数字
	self:changeNumNode(self._num + 1)
	self._par:stopAllActions()
	self._par:show():line({
		{"moveTo", time, ccp(self._par:px(), self._bar:ch() * self._curPercent)},
		{"fn", function ()
			if self._curPercent > 99/100 then
				self._par:stopSystem()
			end
		end}
	})
end

-- 改变数字
function M:changeNumNode(num)
	-- 播放音效[sfx293209001]进度条+1
	soundEffect:playEffectsfx293209001()
	
	self._num = num
	if self._numNode then
		self._numNode:remove()
	end
	-- 创建数字节点
	self:createNumNode(self._num)

	-- 数字变化时的炸开特效
	local effect = D.img("common/progressbar/effect/1.png"):to(self._icon):scale(1.3):p(self._icon:cw()/2 - 2, self._icon:ch()/2)
	effect:line({
        {"imagerange", "common/progressbar/effect/", 1, 22, 1/20},
		{"remove"},
	})
end

-- 进度条减少 #subPercent 百分比减量
function M:reduce(subPercent, time)
	subPercent = ifnil(subPercent, 10/100)
	time = ifnil(time, 0.5)
	self._curPercent = self._curPercent - subPercent
	local value = 100 * self._curPercent
	self._bar:progressTo({time = time, value = value})

	self._par:line({
		{"moveTo", time, ccp(self._par:px(), self._bar:ch() * self._curPercent)},
		{"fn", function ()
			if self._curPercent < 1/100 then
				self._par:stopSystem()
				-- 退出
				self:quitIcon()
			end
		end}
	})
end

-- 退出
function M:quitIcon()
	if not self._icon._isEnter then return end
	self._icon._isEnter = false
	self._icon:line({
		{"easing", "backIn", {"scaleTo", 0.5, 0}},
		{"hide"}
	})
end

-- 重置进度
function M:reset()
	self._curPercent = 0/100
	self._bar:progressTo({time = 0, value = 0})
end

-- 获取进度线的世界坐标
function M:getLineWpos()
	local pos = ccpAdd(self._bar:worldpoint(), ccp(0, self._bar:ch() * self._curPercent + 10))
	return pos
end

-- 获取图标的世界坐标
function M:getIconWpos()
	local pos = self._icon:worldpoint()
	return pos
end

----------------------
-- 结点析构
----------------------
--[[--

视图析构，处理视图结点卸载、事件解除绑定等相关操作

]]
function M:onDestructor()
    -- [超类调用]
	M.super.onDestructor(self)
end

return M