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
    -- 加载3D模型
    self:load3DModel()
    -- 加载按钮节点
    self:loadBtns()
    -- 加载测试节点
    -- self:loadTestNode()
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

-- 加载3D模型
function M:load3DModel()
    -- c3b模型文件
    -- local model = cc.Sprite3D:create("3d/boss.c3b")
    -- obj模型文件
    local model = cc.Sprite3D:create("3d/boss.obj", "3d/boss.png")
    self:addChild(model)
    -- 坐标
    model:setPosition(V.w_2, V.h_2)
    -- model:setPositionZ(100)
    -- 缩放
    model:setScale(27) 
    -- 初始化旋转
    model:setRotation3D(cc.vec3(0, 0, 0))
    model._r3D = cc.vec3(0, 0, 0)

    self._model = model
end

-- 加载按钮节点
function M:loadBtns()
    local info = {
        {id = 1, label = "正视图",  pos = ccp(100 + X_OFFSET/2, V.h*11/12)},
        {id = 2, label = "俯视图",  pos = ccp(100 + X_OFFSET/2, V.h*9/12)},
        {id = 3, label = "侧视图",  pos = ccp(100 + X_OFFSET/2, V.h*7/12)},
        {id = 4, label = "X轴旋转", pos = ccp(100 + X_OFFSET/2, V.h*5/12)},
        {id = 5, label = "Y轴旋转", pos = ccp(100 + X_OFFSET/2, V.h*3/12)},
        {id = 6, label = "Z轴旋转", pos = ccp(100 + X_OFFSET/2, V.h*1/12)},
    }
    self._btns = {}
    for i, v in pairs(info) do
        local btn = require("app.sprite3d.node.Btn").new({
            layer = self,
            model = self._model,
            id    = v.id,
            label = v.label,
        }):to(self, 999):p(v.pos)
        table.insert(self._btns, btn)
    end
end

-- 加载测试节点
function M:loadTestNode()
    local btn = require("app.sprite3d.node.Btn").new({
        label = "测试节点",
    }):to(self._model):scale(1/35):setPosition(5, 5)
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