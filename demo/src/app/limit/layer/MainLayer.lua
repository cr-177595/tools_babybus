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
    -- 加载触控节点
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

-- 加载触控节点
function M:loadTouchNode()
    -- local touchNode1 = require("app.limit.node.TouchNode1").new({
    -- }):to(self, 100):p(300, V.h_2)
    -- self._touchNode1 = touchNode1
    -- CommonFun:loadHelp(touchNode1)
    -- CommonFun:setRotate(touchNode1)

    local touchNode2 = require("app.limit.node.TouchNode2").new({
    }):to(self, 100):p(660, V.h_2)
    self._touchNode2 = touchNode2
    CommonFun:loadHelp(touchNode2)
    CommonFun:setRotate(touchNode2)
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