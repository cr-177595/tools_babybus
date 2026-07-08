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
local M = classSpriteTouch("TouchNode2")

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
	self._canTouch = true
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

-- 加载显示
function M:loadDisplay()
	self:display("limit/1.png")
end

function M:onEnterTransitionFinish()

end

----------------------
-- 功能函数
----------------------
-- 根据顶点集合限制移动区域
function M:limitMoveByVertices()
    -- 定义顶点集合
    local vertices = {
		ccp(0, 0),
		ccp(self:cw()/2, 0),
		ccp(self:cw()/2, self:ch()),
	}

    -- 广告位限制
    local limitY = NEED_BANNER and V.h - 80 or V.h

    for i, v in ipairs(vertices) do
        local wpos = self:convertToWorldSpace(v)
        if wpos.x < 0 then
            self:px(self:px() - wpos.x)
        elseif wpos.x > V.w then
            self:px(self:px() - (wpos.x - V.w))
        end

        if wpos.y < 0 then
            self:py(self:py() - wpos.y)
        elseif wpos.y > limitY then
            self:py(self:py() - (wpos.y - limitY))
        end
    end
end

----------------------
-- 触控函数
----------------------
function M:onTouchBegan(x, y)
	if not self._canTouch then return end
	return true
end

function M:onTouchMoved(x, y)
	self:p(x, y)
	self:limitMoveByVertices()
end

function M:onTouchEnded(x, y)

end

return M