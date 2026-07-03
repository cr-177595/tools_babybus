--[[

	Copyright (c) 2011-2024 baby-bus.com

	TODO:   消消乐道具
	Author: CR
	Date:   2025.11.23
 
	http://www.babybus.com/

]] 

----------------------
-- 类
----------------------
local M = classSpriteTouch("Prop")

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
    self._layer   = params.layer
	-- 地图
	self._map	  = params.map
	-- 道具类型（1-7）
	self._propType = params.propType
	-- 所属格子
	self._grid    = params.grid
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
end

function M:onEnterTransitionFinish()

end

-- 加载显示
function M:loadDisplay()
	self:display("eliminate/prop/"..self._propType..".png")
end

----------------------
-- 功能函数
----------------------
-- 移动到目标位置
function M:moveTo(targetPos, time, callback)
	local time = time or 0.3
	self:stopAllActions()
	self:line({
		{"easing", "backOut", {"moveTo", time, targetPos}},
		{"fn", function()
			if callback then callback() end
		end}
	})
end

-- 交换动画
function M:swapTo(targetPos, time, callback)
	local time = time or 0.2
	self:stopAllActions()
	self:line({
		{"moveTo", time, targetPos},
		{"fn", function()
			if callback then callback() end
		end}
	})
end

-- 消除动画
function M:eliminate(callback)
	self:stopAllActions()
	self:line({
		{"scaleTo", 0.2, 0},
		{"fadeOut", 0.2},
		{"fn", function()
			self:remove()
			if callback then callback() end
		end}
	})
end

return M
