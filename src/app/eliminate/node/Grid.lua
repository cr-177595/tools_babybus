--[[

	Copyright (c) 2011-2024 baby-bus.com

	TODO:   地图格子
	Author: CR
	Date:   2025.11.23
 
	http://www.babybus.com/

]] 

----------------------
-- 类
----------------------
local M = classSpriteTouch("Grid")

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
	-- 格子编号
	self._gridId  = params.gridId
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
	self:display("eliminate/grid.png")
end

-- 创建道具
function M:createProp(propType)
	-- 移除旧道具
	self:removeProp()
	-- 创建新道具
	local prop = require("app.eliminate.node.Prop").new({
		layer    = self._layer,
		map      = self._map,
		propType = propType,
		grid     = self,
	}):to(self):p(self:cw()/2, self:ch()/2):unbindTouch()
	self:bindProp(prop)
	return prop
end

----------------------
-- 功能函数
----------------------
-- 绑定道具
function M:bindProp(prop)
	if prop and not tolua.isnull(prop) then
		self._prop = prop
		prop._grid = self
	end
end

-- 设置区域编号
function M:setAreaId(areaId)
	self._areaId = areaId
end

-- 移除道具
function M:removeProp()
	if self._prop and not tolua.isnull(self._prop) then
		self._prop:remove()
		self._prop = nil
	end
end

-- 获取道具类型
function M:getPropType()
	if self._prop and not tolua.isnull(self._prop) then
		return self._prop._propType
	end
	return nil
end

-- 设置选中状态
function M:setSelected(isSelected)
	self._isSelected = isSelected
	if isSelected then
		-- 选中效果：添加高亮边框
		if not self._selectFrame then
			local w, h = self:cw(), self:ch()
			local frame = D.img("eliminate/frame.png"):to(self._layer, 999)
			:scale(0.8):p(self:worldpoint())
			self._selectFrame = frame
		else
			self._selectFrame:show()
		end
	else
		-- 取消选中效果
		if self._selectFrame then
			self._selectFrame:hide()
		end
	end
end

return M