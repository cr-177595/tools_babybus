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

-- [操作变量]
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

end

function M:onEnterTransitionFinish()

end

-- 加载结点[快捷按钮]
function M:loadQuickBtn()
	-- 添加结点
    local button = U.loadScaleButton({
    	-- 按钮图片
        imagename      = "g/button/btn_album.png",                
        -- 父亲节点（选填)
        parent         = self,                     
        -- 层深度（选填)
        zorder         = 10000,                      
        -- 缩放起始效果(默认0.7)
        scaleBegan     = 0.6,                       
        -- 缩放结束效果(默认1.0)
        scaleEnd       = 1.0,                       
        -- 位置(默认返回键位置)
        pos            = ccp(getButtonX_Right() - 100, 180),             
        -- 缩放时间（默认1.0）
        scaleTime      = 0.2,      
        -- 点击音效
        tabsound 	   = "",                 
        -- 点击事件
        fnClicked      = function()
        	game:enterScene("quick")
        end
    })
    self._button = button
    button:unbindTouch()
    self:line({
        {"delay", .1},
        {"fn", function()
            button:bindTouch()
        end}
    })
end

----------------------
-- 结点析构
----------------------
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