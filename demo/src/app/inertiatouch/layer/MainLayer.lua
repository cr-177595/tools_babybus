--[[

Copyright (c) 2012-2019 Baby-Bus.com

http://www.baby-bus.com/LizardMan/

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

]]

--[[!--

场景层类，定义层相关操作方法及逻辑实现。

-   定义场景层功能方法。

]]

----------------------
-- 类
----------------------
local M = classLayerTouch("Main")

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
    -- 横向/纵向 
	self._type = self:getScene()._type
end

----------------------
-- 结点渲染
----------------------
--[[--

视图渲染，处理视图结点加载、事件绑定等相关操作

]]
function M:onRender()
    M.super.onRender(self)
    -- 加载背景
    self:loadBg()
    -- 加载底图
    self:loadBase()
    -- 加载上层
    self:loadFront()
    -- 加载惯性触控节点
    self:loadTouchNode()
end

function M:onEnterTransitionFinish()

end

-- 加载背景
function M:loadBg()
    local bg = U.loadNodeMask({ 
        contentSize = cc.size(V.w, V.h),
        color       = COLOR3_GRAY,
        opacity     = 255,
    }):to(self):p(V.w_2, V.h_2)
    self._bg = bg
end

-- 加载底图
function M:loadBase()
    local infos = {
        -- 横向
        [1] = {anc = ccp(0, 0.5), pos = ccp(-300, V.h_2), sca = 3},
        -- 纵向
        [2] = {anc = ccp(0.5, 0), pos = ccp(V.w_2, -300), sca = 3},
    }
    local info = infos[self._type]
    
    local base = D.img("inertiatouch/base.png"):to(self, 10)
    :a(info.anc):p(info.pos):scale(info.sca)
    self._base = base
end

-- 加载上层纹理
function M:loadFront()
    local infos = {
        -- 横向
        [1] = {anc = ccp(0, 0.5), pos = ccp(0, V.h_2), sca = 3},
        -- 纵向
        [2] = {anc = ccp(0.5, 0), pos = ccp(V.w_2, 0), sca = 3},
    }
    local info = infos[self._type]

    local front = D.img("inertiatouch/front.png"):to(self, 20)
    :a(info.anc):p(info.pos):scale(info.sca)
    self._front = front
end

-- 加载惯性触控节点
function M:loadTouchNode()
    --[[
        【参数解析】
        type        （选填项）  移动类型，1:横向移动 2:纵向移动
        nodes       （必填项）  移动对象集合，支持单/多对象
        ratios      （选填项）  位移系数集合，对应每个对象，用于多对象移动时的视觉偏移效果
        limitOffset （必填项）  位移量限制
        buffer      （选填项）  缓冲区大小
        moveEndFn   （选填项）  移动结束回调
    ]]
    local touchNode = require("app.inertiatouch.node.InertiaTouch").new({
        type        = self._type,
        nodes       = {self._base, self._front},
        ratios      = {1, 1.5},
        limitOffset = self._type == 1 and (-1600 + X_OFFSET) or (-1800 + Y_OFFSET/2),
        buffer      = 400,
        moveEndFn   = function ()
            print("******移动结束事件******")
        end
    }):to(self, 100):size(V.w, V.h):p(V.w_2, V.h_2)
    self._touchNode = touchNode
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

----------------------
-- 过度动画开始之前的调用
----------------------
--[[--

1.资源释放，退出场景前的操作准备
2.处理视图结点卸载、事件解除绑定等相关操作

]]
function M:onExitTransitionStart()

end

return M