--[[

    Copyright (c) 2011-2024 baby-bus.com

    TODO:   按钮层
    Author: CR
    Date:   2023.01.23
 
    http://www.babybus.com/ 

]] 

----------------------
-- 类
----------------------
local M = class("Button", require("app.common.layer.BaseButtonLayer"))

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
    M.super.onRender(self)
end

function M:onNextButton()

end

----------------------
-- 结点析构
----------------------
function M:onDestructor()
    -- [超类调用]
	M.super.onDestructor(self)
end

return M