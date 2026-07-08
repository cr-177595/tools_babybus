--[[   Copyright (c) 2012-2021 baby-bus.com

   TODO:    地球仪
   Author:  CR
   Date:    2022年05月19日10:24:01
   
   http://www.baby-bus.com/
   
]]
----------------------
-- 类
----------------------
local M = classSpriteTouch("Earth")

----------------------
-- 公共参数
----------------------
-- [常量]
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

    -- 自转时间
    self._time = 0
end

----------------------
-- 结点渲染 
----------------------
--[[--

实体渲染，处理实体结点加载、事件绑定等相关操作

]]
function M:onRender()
    -- [超类调用]
    M.super.onRender(self)
    -- 加载显示
    self:loadDisplay()
    -- 加载球体
    self:loadBall()
end

-- 加载显示
function M:loadDisplay()
    -- 基座
    self:display("earth/base.png")
end

-- 加载球体
function M:loadBall()
    local ball = D.imgsz("earth/map.png", cc.size(225, 225)):p(125, 180):to(self):rotate(20)
    self._ball = ball
    -- 球体绑定shader
    self:shaderBallRoll(ball)
end

----------------------
-- 功能函数
----------------------
-- 球体滚动shader
function M:shaderBallRoll(node)
	local vsh, fsh = "shader/ballRoll.vsh", "shader/ballRoll.fsh"
    local glProgram = cc.GLProgram:createWithFilenames(vsh, fsh)
    node:setGLProgram(glProgram)
    node:setProgramFloat("u_time", 0)
    local ratio = node:width() / node:height()
    node:setProgramFloat("u_ratio", 1 / ratio)
end

----------------------
-- 触控
----------------------
function M:onTouchBegan(x, y)
    self._isInTouch = false
    if self._ball:isTouchInside(x, y) then
        self._ball:stopAllActions()
        self._startX = x
        self._dis = 0
        self._isInTouch = true
    end
    return true
end

function M:onTouchMoved(x, y)
    if not self._isInTouch then return end
    local dis = x - self._startX
    self._startX = x
    self._dis = dis / 10
    self._time = self._time + self._dis * 1/60
    self._ball:setProgramFloat("u_time", self._time)
end

function M:onTouchEnded(x, y)
    if not self._isInTouch then return end
    self._dis = math.abs(self._dis) < 0.02 and 0.4 or self._dis
    self._ball:cycle({
        {"delay", 1/60},
        {"fn", function()
            self._dis = self._dis * 0.98
            self._time = self._time + self._dis * 1/60
            self._ball:setProgramFloat("u_time", self._time)
            if math.abs(self._dis) < 0.1 then
                self._ball:stopAllActions()
            end
        end }
    })
end

return M