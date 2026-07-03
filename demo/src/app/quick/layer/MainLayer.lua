--[[--==============================================

Copyright (c) 2018-08-13 Baby-Bus.com

http://www.baby-bus.com/ All rights reserved!

--]]--==============================================



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
	--是否为二级页面
	self._isSecondPage = false
	-- 按钮集合
	self._btns 		   = {}
end

----------------------
-- 结点渲染
----------------------
--[[--

视图渲染，处理视图结点加载、事件绑定等相关操作

]]
function M:onRender()
	-- 背景颜色
	self:loadBg()
	-- 项目配置表【主要在这里配置】
	self:init()
	-- 加载返回按钮
	self:loadBackBtn()
	-- 加本地xml清空按钮
	self:loadUStoreClearButton():to(self, 10)
	-- 加载阶段选择按钮
	-- self:loadChoosePhaseBtn()
	-- 加载阶段1的场景按钮
	self:loadBtns(1)
end

-- 背景颜色（需要颜色自己设）
function M:loadBg()
	U.loadLayer({color = ccc4(48, 160, 235, 255)}):to(self)
end

-- 项目配置表【主要在这里配置】
function M:init()
	-- 阶段名称（阶段二集合记得加上阶段一的）
	self._stageString = {"一", "二"}
	-- 阶段1的{场景名, 场景名对应的标签名, 需要传的值} (一列8个)
	self._scenes1 = {
		{"eliminate",	"消消乐"},
		{"sprite3d",	"3D模型精灵"},
		{"earth",		"shader地球仪"},
		{"settlement", 	"滚轮"},
		{"limit", 	 	"顶点计算区域限制"},
	}
	-- 阶段2的场景名{场景名, 场景名对应的标签名}
	self._scenes2 = {
		-- {"", "", {}},
		-- {"", "", {}},
	}
end

----------------------
-- 按钮添加
----------------------
-- 加载阶段选择按钮
function M:loadChoosePhaseBtn()
	-- 按钮图片资源（正常状态，点击状态，禁用状态(可不用)），默认使用框架资源
	local ButtonImages = {
     	normal 	= "g/setting/btn_lang_box0.png",
        pressed = "g/setting/btn_lang_box1.png",
	}
	local string = self._stageString
	local px = {
				{V.w / 2},
				{V.w / 2 - 150, V.w / 2 + 150},
				{V.w / 2 - 300, V.w / 2 , V.w / 2 + 300}
			}
	for k,v in pairs(string) do
		local btn = cc.ui.UIPushButton.new(ButtonImages, {scale9 = true})
	    btn:addTo(self)
	    btn:pos(px[#string][k], V.h / 2)
	    btn:setButtonSize(200, 100)
		--按钮标签
	    btn.lable = U.loadLabelTTF({ 
		        text        = '阶段' .. v, 
		        fontSize    = 20, 
		        color       = COLOR3_WHITE,
		        position    = ccp(px[#string][k], V.h / 2),
		    }):to(self, 100)
	    table.insert(self._btns, btn)
	end
	-- 按钮点击
	self:choosePhaseBtnClicked()
end

-- 加载返回按钮
function M:loadBackBtn()
    local back = D.img('g/button/btn_back.png'):p(getButtonX_Left(), V.h - 60):to(self, 11):bindTouch({
		fnBegan = function( target, x, y )
			if target._isTouch then return end
			target._isTouch = true
			target:line({
				{"scaleTo", 0.1, 0.8},
				{"scaleTo", 0.1, 1},
				{"fn", function()
					target._isTouch = false
					if self._isSecondPage then
						game:enterScene('quick')
					else
						bb.si.DragonBone.removeAll()
			            R.removeAllTextures()
			            R.removeAllFrames()
						game:enterScene('gameplay')
					end 
				end}
			})
    	end,
    	pnCool = true, 
    	coolTime = 1,
    })
end

-- 加载清除UStore按钮
function M:loadUStoreClearButton(pos)
	local pos = ifnil(pos, cc.p(getButtonX_Right(), V.h - 60))

    -- 节点
    local node    = D.img("g/button/btn_delete.png"):p(pos):bindTouchHandled(function(target)
        target:line({
        	{"scaleto", .1, .6},
        	{"scaleto", .1, 1}
        	})
        ST.clearUStore()
    end)

    return node
end

----------------------
-- 按钮逻辑
----------------------
-- 选择阶段按钮点击逻辑
function M:choosePhaseBtnClicked()
	for k,v in pairs(self._btns) do
		v:onButtonClicked(function()
			--隐藏阶段按钮
			for i,v1 in pairs(self._btns) do
				v1:hide()
				v1.lable:hide()
			end
			self:loadBtns(k)
			--进入二级页面
	    	self._isSecondPage = true
		end)
	end
end

-- 阶段n内容按钮逻辑 #id 阶段
function M:loadBtns(id)
	if id == 2 then
		self._level = 2
 		local lb = U.loadLabelTTF({ 
	        text        = string.format("关卡%s", self._level), 
	        fontSize    = 20, 
	        color       = COLOR3_RED,
	        position    = ccp(V.w_2 + 380, V.h_2 - 70),
	    }):scale(1.4):to(self, 111)
		lb:bindTouch({
	    	fnBegan = function(target, x, y)
	    		self._level = self._level < 10 and self._level + 1 or 2
	    		lb:setString(string.format("关卡%s", self._level))
	    	end
	    })
	end

	local scenes = {self._scenes1, self._scenes2}

	local num 	=  math.ceil(#scenes[id] / 8)
	local px 	= {
			{V.w / 2},
			{V.w / 2 - 150, V.w / 2 + 150},
			{V.w / 2 - 300, V.w / 2 , V.w / 2 + 300},
			{V.w / 2 - 350, V.w / 2 - 110 , V.w / 2 + 110, V.w / 2 + 350}
		}
	-- 显示左边列的标签名，点击进入对应场景名的场景
	for i,v in ipairs(scenes[id]) do
 		local lb = U.loadLabelTTF({ 
	        text        = string.format("%s", v[2]), 
	        fontSize    = 20, 
	        color       = COLOR3_WHITE,
	        position    = ccp(px[num][math.ceil(i / 8)], V.h - 100  - 60 * ((i - 1) % 8) - Y_OFFSET),
	    }):scale(1.4):to(self, 111)

 		if v[2] ~= "" then
			lb:bindTouch({
		    	pnSubmit = true,
		    	rectFactorY = 1.5,
		    	fnBegan = function(target, x, y)
		    		target:line({
		    			{"scaleTo", 0.1, 1.1},
		    			{"scaleTo", 0.1, 1.4},
						{"fn", function()
							game:enterScene(v[1], v[3])
		    			end}
		    		})
		    	end
		    })
		end
 	end
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

return M