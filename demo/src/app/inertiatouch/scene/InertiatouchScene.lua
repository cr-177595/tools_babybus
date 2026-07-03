--[[

	Copyright (c) 2011-2024 baby-bus.com

	TODO:   场景
	Author: CR
	Date:   2023.01.23
 
	http://www.babybus.com/ 

]] 

----------------------
-- 类
----------------------
local M = classScene("Inertiatouch")

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
    -- 横向/纵向
	self._type = params.type or 1
end

----------------------
-- 视图渲染
----------------------
--[[--

视图渲染，处理视图结点加载、事件绑定等相关操作

]]
function M:onRender()

end

-- 响应安卓返回键
function M:onKeypadBackHandler()
	self:getButtonLayer():onBackButton()
end

----------------------
-- 结点析构
----------------------
--[[--

视图析构，处理视图结点卸载、事件解除绑定等相关操作

]]
function M:onDestructor()
  	M.super.onDestructor(self)
end

----------------------
-- 模板方法
----------------------
--[[--

获得层名称集合, 用于动态定义该场景需要加载的层

### Returns: 
-   string...       	层名称1, 层名称2, ...

]]
function M:getLayerNames()
    return "main", "button"
end

--[[--

获得获得信息集合, 用于动态定义该场景需要加载的资源(纹理, 帧等)

### Returns: 
-   string|table...    	帧名称1|{资源名称,类型,自动清理,图片后缀(包含.)}, ...

]]
function M:getResourceNames()
    return 
end

----------------------
-- 验证
----------------------
-- 验证参数
function M:assertParameters(params)

end

return M