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
	-- 主层
	self._layer = params.layer
	-- 模型节点
	self._model = params.model
	-- 编号
	self._id 	= params.id
	-- 文本
	self._label = params.label
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
	self:display("sprite3d/btn.png")
	-- 文本
	local label = U.loadLabelTTF({
		text        = string.format("%s", self._label), 
		fontSize    = 25, 
		color       = COLOR3_BLACK,
		position    = ccp(self:cw()/2, self:ch()/2),
	}):to(self)
end

----------------------
-- 功能函数
----------------------
-- 重置模型的旋转数据
function M:resetModelR3D()
	self._model._r3D = cc.vec3(0, 0, 0)
    self._model:setRotation3D(self._model._r3D)
end

----------------------
-- 触控函数
----------------------
function M:onTouchBegan(x, y)
	for i, btn in pairs(self._layer._btns) do
		btn:color(COLOR3_WHITE)
	end
	self:color(COLOR3_RED)
	self:stopAllActions():scale(0.9)
	self:one({"scaleTo", 0.15, 1})
	return self["onTouchBegan"..self._id](self)
end

-- 触控事件（正视图）
function M:onTouchBegan1()
	local model = self._model
	local r3D = self._model._r3D
	
	self._layer:stopAllActions()
	self._layer:cycle({
		{"delay", 1/30},
		{"fn", function ()
			r3D.x = r3D.x > 0 and r3D.x - 1 or 0
			r3D.y = r3D.y > 0 and r3D.y - 1 or 0
			r3D.z = r3D.z > 0 and r3D.z - 1 or 0
			model:setRotation3D(r3D)

			if r3D.x == 0 and r3D.y == 0 and r3D.z == 0 then
				self._layer:stopAllActions()
			end
		end}
	})
end

-- 触控事件（俯视图）
function M:onTouchBegan2()
	local model = self._model
	local r3D = self._model._r3D
	
	self._layer:stopAllActions()
	self._layer:cycle({
		{"delay", 1/30},
		{"fn", function ()
			r3D.x = r3D.x < 90 and r3D.x + 1 or 90
			r3D.y = r3D.y > 0 and r3D.y - 1 or 0
			r3D.z = r3D.z > 0 and r3D.z - 1 or 0
			model:setRotation3D(r3D)
			
			if r3D.x == 0 and r3D.y == 90 and r3D.z == 0 then
				self._layer:stopAllActions()
			end
		end}
	})
end

-- 触控事件（左视图）
function M:onTouchBegan3()
	local model = self._model
	local r3D = self._model._r3D
	
	self._layer:stopAllActions()
	self._layer:cycle({
		{"delay", 1/30},
		{"fn", function ()
			r3D.x = r3D.x > 0 and r3D.x - 1 or 0
			r3D.y = r3D.y < 90 and r3D.y + 1 or 90
			r3D.z = r3D.z > 0 and r3D.z - 1 or 0
			model:setRotation3D(r3D)
			
			if r3D.x == 0 and r3D.y == 90 and r3D.z == 0 then
				self._layer:stopAllActions()
			end
		end}
	})
end

-- 触控事件（X轴旋转）
function M:onTouchBegan4()
	-- 重置模型的旋转数据
	self:resetModelR3D()
	
	local model = self._model
	local r3D = self._model._r3D
	
	self._layer:stopAllActions()
	self._layer:cycle({
		{"delay", 1/30},
		{"fn", function ()
			r3D.x = r3D.x + 1
			model:setRotation3D(r3D)
		end}
	})
end

-- 触控事件（Y轴旋转）
function M:onTouchBegan5()
	-- 重置模型的旋转数据
	self:resetModelR3D()

	local model = self._model
	local r3D = self._model._r3D
	
	self._layer:stopAllActions()
	self._layer:cycle({
		{"delay", 1/30},
		{"fn", function ()
			r3D.y = r3D.y + 1
			model:setRotation3D(r3D)
		end}
	})
end

-- 触控事件（Z轴旋转）
function M:onTouchBegan6()
	-- 重置模型的旋转数据
	self:resetModelR3D()

	local model = self._model
	local r3D = self._model._r3D

	self._layer:stopAllActions()
	self._layer:cycle({
		{"delay", 1/30},
		{"fn", function ()
			r3D.z = r3D.z + 1
			model:setRotation3D(r3D)
		end}
	})
end

return M