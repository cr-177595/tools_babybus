--[[

	Copyright (c) 2011-2024 baby-bus.com

	TODO:   触控节点
	Author: CR
	Date:   2024.03.13
 
	http://www.babybus.com/

]] 

----------------------
-- 类
----------------------
local M = classSpriteTouch("TouchNode")

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
	-- 触控锁
	self._canTouch = false
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
end

function M:onEnterTransitionFinish()

end

----------------------
-- 功能函数
----------------------

----------------------
-- 触控函数
----------------------
function M:onTouchBegan(x, y)
	if not self._canTouch then return end
	return true
end

function M:onTouchMoved(x, y)

end

function M:onTouchEnded(x, y)

end

return M