--[[

	Copyright (c) 2011-2024 baby-bus.com

	TODO:   通用结算
	Author: CR
	Date:   2024.03.13
 
	http://www.babybus.com/

]] 

----------------------
-- 类
----------------------
local M = classSpriteTouch("BaseSettlement")

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
	-- 难度总数
	self._levelCount = ifnil(params.levelCount, 25)
	-- 当前难度
	self._curLevel 	 = ifnil(params.curLevel, 1)
	-- 下一难度
	self._nextLevel  = ifnil(params.nextLevel, 2)
	-- 回调
	self.callback    = params.callback
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
	-- 初始化数据
	self:initData()
	-- 加载机器
	self:loadMachine()
end

-- 加载显示
function M:loadDisplay()
	self:size(V.w, V.h)
end

-- 初始化数据
function M:initData()
	-- 题目节点边界值（创建与销毁的边界值）
	self._borderY 	 = 100
	-- 题目节点之间的间距
	self._spaceY 	 = 70
	-- 总移动量
	self._totalDisY  = self._spaceY * (self._nextLevel - self._curLevel + self._levelCount)
	-- 剩余移动量
	self._remainDisY = self._totalDisY
end

-- 加载机器
function M:loadMachine()
	local machine = D.img("settlement/machine/1.png"):to(self)
	:a(ccp(0.5, 0)):p(V.w_2, 90 + Y_OFFSET):scale(0):bindTouch()
	self._machine = machine
	-- 前层
	local front = D.img("settlement/machine/front.png"):to(machine, 100):p(machine:cw()/2, machine:ch()/2)
	-- 加载标题牌子
	self:loadBrand()
	-- 加载电流
	self:loadElectrics()
	-- 加载彩灯
	self:loadColorLamps()
	-- 加载指针
	self:loadPointers()
	-- 加载显示框
	self:loadFrame()
	-- 加载题目节点
	self:loadTopics()
end

-- 加载标题牌子
function M:loadBrand()
	local path = "settlement/machine/brand/"
	-- 牌子
	local brand = D.img(path.."1.png"):to(self._machine, 110):p(209, 293):bindTouch()
	self._brand = brand
	-- 标题
	if device.language == "zh" then
		brand._title = D.img(path.."title.png"):to(brand):p(brand:cw()/2, brand:ch()/2 + 2)
	end
	-- 牌子灯
	local posTab = {
		ccp(6.1, 37.7), ccp(18.1, 58.4), ccp(42.4, 59.2), ccp(64.9, 67.5),
		ccp(92.6, 67.5), ccp(118.6, 67.5), ccp(139.5, 60.1), ccp(169.2, 58.4),
		ccp(180.1, 37.6), ccp(170.0, 18.2), ccp(140.0, 16.9), ccp(118.6, 9.5),
		ccp(92.6, 9.5), ccp(64.9, 9.5), ccp(43.3, 17.1), ccp(19.0, 17.7),
	}
	brand._lamps = {}
	for i, pos in pairs(posTab) do
		local node = D.img(path.."lamp/0.png"):to(brand):p(pos):bindTouchLocate()
		table.insert(brand._lamps, node)
	end
	-- 星星
	local posTab = {
		ccp(29, 39), ccp(156, 39),
	}
	brand._stars = {}
	for i, pos in pairs(posTab) do
		local star = D.img(path.."star.png"):to(brand):p(pos):scale(0):hide():bindTouchLocate()
		table.insert(brand._stars, star)
	end
end

-- 加载电流
function M:loadElectrics()
	local path = "settlement/machine/electric/"
	-- 管子
	local tube1 = D.img(path.."tube.png"):to(self._machine, -10):p(50, 159):flipX(true)
	local tube2 = D.img(path.."tube.png"):to(self._machine, -10):p(364, 159)
	-- 电流
	local info = {
		{pos = ccp(-7, 162),  flipX = true},
		{pos = ccp(421, 162), flipX = false},
	}
	self._electrics = {}
	for i, v in pairs(info) do
		local node = D.img(path.."1/1.png"):to(self._machine, -20):p(v.pos):flipX(v.flipX)
		table.insert(self._electrics, node)
	end
	-- 播放蓝色电流
	self:playBlueElectric()
end

-- 加载彩灯
function M:loadColorLamps()
	local path = "settlement/machine/colorlamp/"
	local info = {
		{pos = ccp(71, 275),  flipX = true},
		{pos = ccp(345, 275), flipX = false},
	}
	self._colorLamps = {}
	for i, v in pairs(info) do
		local node = D.img(path.."1.png"):to(self._machine, 110):p(v.pos):flipX(v.flipX)
		table.insert(self._colorLamps, node)
	end
end

-- 加载指针
function M:loadPointers()
	local path = "settlement/machine/pointer.png"
	local info = {
		{pos = ccp(38, 152),  flipX = false},
		{pos = ccp(376, 152), flipX = true},
	}
	self._pointers = {}
	for i, v in pairs(info) do
		local node = D.img(path):to(self._machine, 110):a(ccp(0.35, 0.6)):p(v.pos):bindTouchLocate()
		table.insert(self._pointers, node)
		if v.flipX then
			node:scaleX(-node:scaleX())
		end
		-- CommonFun:bindTouchAnchorLocate(node)
	end
end

-- 加载显示框
function M:loadFrame()
	local path = "settlement/machine/frame/"
	-- 外框
	local frame = D.img(path.."1.png"):to(self._machine, 90):p(207, 150):bindTouch()
	self._frame = frame
	-- 底图
	frame._base = D.img(path.."base.png"):to(frame):p(frame:cw()/2, frame:ch()/2)
	-- 外框的中心坐标
	frame._cp = ccp(frame:cw()/2, frame:ch()/2)

    -- 裁切纹理
    local mask = D.img(path.."base.png"):p(frame._cp)
    local clip = CCNodeExtend.extend(CCClippingNode:create(mask)):unbindTouch()
	self._clip = clip
    -- 子节点透明度跟随父节点
	clip:setCascadeOpacityEnabled(true)
    -- 模版
    clip:setStencil(mask)
    -- 设置遮罩模式[false:显示模板区域，true:显示模板外区域]
    clip:setInverted(false)
    -- 设置ALPHA的测试参考值
    clip:setAlphaThreshold(0)
	clip:to(frame, 1):unbindTouch()
end

-- 加载题目节点
function M:loadTopics()
	-- 正常的题目节点集合
	self._topics1 = {
		self:createTopicNormal(self:getDownLevel(self._curLevel), -self._spaceY),
		self:createTopicNormal(self._curLevel, 0),
		self:createTopicNormal(self:getUpLevel(self._curLevel), self._spaceY),
	}
	-- 高亮的题目节点集合
	self._topics2 = {
		self:createTopicHighLight(self:getDownLevel(self._curLevel), -self._spaceY),
		self:createTopicHighLight(self._curLevel, 0),
		self:createTopicHighLight(self:getUpLevel(self._curLevel), self._spaceY),
	}
end

-- 创建正常的题目节点
function M:createTopicNormal(level, offsetPy)
	local path = "settlement/topic/normal/"
	-- 题目文本
	local label = D.img(path.."label/"..level..".png")
	-- 空节点尺寸
	local w = label:size().width + 60
	local h = label:size().height
	-- 空节点
	local node = D.img():size(cc.size(w, h)):to(self._frame, -1)
	:p(ccpAdd(self._frame._cp, ccp(0, offsetPy))):scale(0):bindTouch()
	node._level = level
	node._scl = 1.2
	-- 题目文本
	label:to(node):a(ccp(0, 0.5)):p(58, h/2)
	-- 难度节点
	local levelNode = self:createLevelNode(path.."num/", level):to(node, 2):a(ccp(0, 0.5)):p(3, h/2)
	-- 设置缩放
	self:setTopicScale(node)
	-- 包围盒调试
	-- CommonFun:loadHelp(node)
	return node
end

-- 创建高亮的题目节点
function M:createTopicHighLight(level, offsetPy)
	local path = "settlement/topic/highlight/"
	-- 题目文本
	local label = D.img(path.."label/"..level..".png")
	-- 空节点尺寸
	local w = label:size().width + 86
	local h = label:size().height
	-- 空节点
	local node = D.img():size(cc.size(w, h)):to(self._clip)
	:p(ccpAdd(self._frame._cp, ccp(0, offsetPy))):scale(0):bindTouch()
	node._level = level
	node._scl = 0.8
	-- 题目文本
	label:to(node):a(ccp(0, 0.5)):p(79, h/2)
	-- 难度节点
	local levelNode = self:createLevelNode(path.."num/", level):to(node, 2):a(ccp(0, 0.5)):p(4, h/2)
	node._levelNode = levelNode
	-- 设置缩放
	self:setTopicScale(node)
	-- 包围盒调试
	-- CommonFun:loadHelp(node)
	return node
end

-- 创建难度节点
function M:createLevelNode(path, num)
	-- 空节点
    local node = D.img(path.."empty.png"):bindTouchLocate()
	node._num = num
    -- 十位数字
    local ten = math.floor(num / 10)
    -- 个位数字
    local unit = num % 10

	local lv = D.img(path.."lv.png"):to(node):p(node:cw()*0.22, node:ch()/2)
    local num1 = D.img(path..ten..".png"):to(node):p(node:cw()*0.57, node:ch()/2)
    local num2 = D.img(path..unit..".png"):to(node):p(node:cw()*0.8, node:ch()/2)

    -- 只有个位时不显示十位
    if ten < 1 then
        num1:hide()
		num2:show():p(num1:point())
    end
	-- 包围盒调试
	-- CommonFun:loadHelp(node)
    return node
end

----------------------
-- 功能函数
----------------------
-- 结算进场
function M:enter()
	if not self._mask then
		self._mask = U.loadNodeMask({
			contentSize = cc.size(V.w, V.h),
			opacity     = 0,
		}):to(self, -100):p(V.w_2, V.h_2):unbindTouch()
	end
	self._mask:line({
		{"fadeTo", 0.3, 150},
		{"fn", function ()
			-- 机器进场
			self:enterMachine()
		end}
	})
end

-- 机器进场
function M:enterMachine()
	self._machine:line({
		{"easing", "ElasticOut", {"scaleTo", 0.5, 1}, 0.5},
		{"fn", function ()
			-- 启动
			self:turnOn()
		end}
	})
	self._brand:line({
		{"moveBy", 0.15, ccp(0, 40)},
		{"moveBy", 0.1, ccp(0, -40)},
	})
	self._brand:line({
		{"scaleTo", 0.1, 1.15},
		{"scaleTo", 0.2, 0.9},
		{"scaleTo", 0.1, 1.15},
		{"scaleTo", 0.1, 1},
	})
end

-- 启动
function M:turnOn()
	self._isTurnOn = true
	-- 播放指针动作
	self:playPointer()
	-- 播放牌子灯效1
	self:playBrandLamp1()
	-- 调度更新
	self:update()
end

-- 播放蓝色电流
function M:playBlueElectric()
	local path = "settlement/machine/electric/"
	for i, v in pairs(self._electrics) do
		v:cycle({
			{"imagerange", path.."1/", 1, 3, 1/20},
		})
	end
end

-- 播放黄色电流
function M:playYellowElectric()
	local path = "settlement/machine/electric/"
	for i, v in pairs(self._electrics) do
		v:stopAllActions()
		v:cycle({
			{"imagerange", path.."2/", 1, 3, 1/30},
		})
	end
end

-- 播放指针动作
function M:playPointer()
	for i, v in pairs(self._pointers) do
		v:cycle({
			{"rotateTo", 0.1, 20},
			{"rotateTo", 0.1, -20},
		})
	end
end

-- 停止指针动作
function M:stopPointer()
	for i, v in pairs(self._pointers) do
		v:stopAllActions()
		v:line({
			{"rotateTo", 0.1, 15},
			{"easing", "ElasticOut", {"rotateTo", 0.7, 0}, 0.3},
		})
	end
end

-- 播放牌子灯效1
function M:playBrandLamp1()
	if self._badge and self._badge._isEnter then
		return 
	end

	-- 亮灯索引
	self._lampIndex = ifnil(self._lampIndex, 0) + 1
	if self._lampIndex > #self._brand._lamps then
		self._lampIndex = 1
	end

	local path = "settlement/machine/brand/lamp/"
	local time = 1/20
	self:line({
		{"delay", time},
		{"fn", function ()
			for i, v in pairs(self._brand._lamps) do
				if i == self._lampIndex then
					v:display(path.."1.png")
				else
					v:display(path.."0.png")
				end
			end
			self:playBrandLamp1()
		end}
	})
end

-- 播放牌子灯效2
function M:playBrandLamp2(tag)
	tag = ifnil(tag, 0) + 1

	local path = "settlement/machine/brand/lamp/"
	local time = 1/30
	self:line({
		{"delay", time},
		{"fn", function ()
			for i, v in pairs(self._brand._lamps) do
				if tag % 2 == 1 then
					if i % 2 == 1 then
						v:display(path.."1.png")
					else
						v:display(path.."0.png")
					end
				else
					if i % 2 == 1 then
						v:display(path.."0.png")
					else
						v:display(path.."1.png")
					end
				end
			end
			self:playBrandLamp2(tag)
		end}
	})
end

-- 播放彩灯效果
function M:playColorLamp()
	local path = "settlement/machine/colorlamp/"
	local time = 1/30
	for i, v in pairs(self._colorLamps) do
		v:cycle({
			{"imagerange", path, 0, 3, time},
		})
	end
end

-- 播放星星效果
function M:playStar()
	for i, v in pairs(self._brand._stars) do
		v:line({
			{"show"},
			{"easing", "ElasticOut", {"scaleTo", 0.8, 1}, 0.3},
		})
	end
end

-- 停止运行
function M:turnOff()
	self._isTurnOn = false
	self._speed = 0
	-- 停止调度更新
	self:stopUpdate()
	-- 题目节点位置校正
	self:correctTopics()
	-- 停止指针动作
	self:stopPointer()

	if self._nextLevel > self._curLevel then
		-- 徽章进场前
		self:enterBadgeBefore()
	elseif self._nextLevel == self._curLevel then
		-- 播放语音[vzx293051002]难度不变，继续加油！
		if soundVoice.playEffectvzx293051002 then
			soundVoice:playEffectvzx293051002()
		end
		self:line({
			{"delay", soundVoice:T("vzx293051002")},
			{"fn", function ()
				self:over()
			end}
		})
	elseif self._nextLevel < self._curLevel then
		self:over()
	end
end

-- 题目节点位置校正
function M:correctTopics()
	local posTab = {
		ccpAdd(self._frame._cp, ccp(0, -self._spaceY)),
		self._frame._cp,
		ccpAdd(self._frame._cp, ccp(0, self._spaceY)),
	}
	local fn = function (topics)
		for i, v in pairs(topics) do
			local pos = posTab[i]
			v:stopAllActions()
			-- 获取题目节点的缩放
			local sclX, sclY = self:getTopicScaleXY(v, pos)
			v:line({
				{"scaleTo", 0.15, sclX * 1.1, sclY * 1.1},
				{"scaleTo", 0.15, sclX * 0.9, sclY * 0.9},
				{"scaleTo", 0.1, sclX * 1.05, sclY * 1.05},
				{"scaleTo", 0.05, sclX, sclY},
			})
			v:line({
				{"moveTo", 0.15, ccpAdd(pos, ccp(0, 5))},
				{"moveTo", 0.15, ccpAdd(pos, ccp(0, -5))},
				{"moveTo", 0.1, ccpAdd(pos, ccp(0, 3))},
				{"moveTo", 0.05, pos},
			})
		end
	end
	fn(self._topics1)
	fn(self._topics2)
end

-- 徽章进场前
function M:enterBadgeBefore()
	-- 播放语音[vzx293051001]太棒了！成功升级更高难度。
	if soundVoice.playEffectvzx293051001 then
		soundVoice:playEffectvzx293051001()
	end

	local levelNode = self._topics2[2]._levelNode
	levelNode:line({
		{"delay", 1},
		{"fn", function ()
			CommonFun:changeAnchorP(levelNode, ccp(0.5, 0.5))
			levelNode:p(ccpAdd(levelNode:point(), ccp(8, 0)))
		end},
		{"union", {
			{"scaleTo", 0.7, 1.2},
			{"rotateTo", 0.7, 20},
		}},
		{"fn", function ()
			CommonFun:slowAction(self._topics2[2], 0.08, 0.8)
			-- 徽章进场
			self:enterBadge()
		end},
		{"union", {
			{"easing", "ElasticOut", {"scaleTo", 0.7, 0}, 0.3},
			{"easing", "ElasticOut", {"rotateTo", 0.7, 0}, 0.3},
		}},
		{"hide"},
	})
end

-- 徽章进场
function M:enterBadge()
	local path = "settlement/badge/"
	local levelNode = self._topics2[2]._levelNode
	-- 徽章
	local pos = ccpAdd(levelNode:worldpoint(), ccp(-10, 0))
	local badge = D.img(path..self:getBadgeColorId()..".png"):to(self, 999):p(pos):scale(0):rotate(30)
	self._badge = badge
	-- 徽章上的等级
	badge._levelNode = self:createLevelNode(path.."num/", self._topics2[2]._level):to(badge):scale(1.1):p(badge:cw()/2, badge:ch()/2)
	if badge._levelNode._num < 10 then
		badge._levelNode:p(ccpAdd(badge._levelNode:point(), ccp(5, 0)))
	end
	-- 光效
	local light = D.img(path.."light/1.png"):to(badge, -1):scale(0.8):p(badge:cw()/2, badge:ch()/2)
	light:cycle({
		{"rotateBy", 1, 60}
	})
	-- 闪烁
	local bling = D.img(path.."bling/1.png"):to(badge):p(badge:cw()/2, badge:ch()/2)
	bling:line({
		{"imagerange", path.."bling/", 1, 17, 1/10},
		{"remove"},
	})
	-- 徽章进场
	badge:line({
		{"union", {
			{"easing", "ElasticOut", {"scaleTo", 0.7, 1}, 0.3},
			{"easing", "ElasticOut", {"rotateTo", 0.7, 0}, 0.3},
		}},
		{"fn", function ()
			badge._isEnter = true
			-- 播放星星效果
			self:playStar()
			-- 播放牌子灯效2
			self:playBrandLamp2()
			-- 播放彩灯效果
			self:playColorLamp()
			-- 播放黄色电流
			self:playYellowElectric()
		end},
		{"delay", 1.2},
		{"fn", function ()
			light:stopAllActions()
			light:union({
				{"rotateBy", 0.2, -20},
				{"scaleTo", 0.2, 0},
			})
		end},
		{"delay", 0.2},
		{"union", {
			{"jumpTo", 0.3, ccp(V.w_2 - 30, V.h - 30), 10, 1},
			{"scaleTo", 0.3, 1.2},
		}},
		{"easing", "ElasticOut", {"scaleTo", 0.5, 0.8}, 0.3},
		{"fn", function ()
			self:over()
		end}
	})
end

-- 结束
function M:over()
	if self.callback then
		self.callback()
	end
	-- self._machine:line({
	-- 	{"easing", "backIn", {"scaleTo", 0.5, 0}},
	-- 	{"hide"},
	-- 	{"fn", function ()
	-- 		self._mask:line({
	-- 			{"fadeTo", 0.3, 0},
	-- 			{"fn", function ()
	-- 				if self.callback then
	-- 					self.callback()
	-- 				end
	-- 				self:remove()
	-- 			end}
	-- 		})
	-- 	end}
	-- })
end

----------------------
-- 获取 节点/属性
----------------------
-- 获取上方的难度
function M:getUpLevel(level)
	local level = level + 1
	if level > self._levelCount then
		level = 1
	end
	return level
end

-- 获取下方的难度
function M:getDownLevel(level)
	local level = level - 1
	if level < 1 then
		level = self._levelCount
	end
	return level
end

-- 获取徽章颜色编号
function M:getBadgeColorId()
	local colorId

	if T.contains({1, 2}, self._nextLevel) then
		colorId = 1
	elseif T.contains({3, 4, 5, 6, 7}, self._nextLevel) then
		colorId = 2
	elseif T.contains({8, 9, 10, 11}, self._nextLevel) then
		colorId = 3
	elseif T.contains({12, 13, 14, 15, 16, 17, 18, 19, 20, 21}, self._nextLevel) then
		colorId = 4
	elseif T.contains({22, 23, 24, 25}, self._nextLevel) then
		colorId = 5
	end

	return colorId
end

-- 获取题目节点的Y轴偏移量
function M:getOffsetPy(node)
	local offsetPy = node:py() - self._frame._cp.y
	return offsetPy
end

-- 获取每一帧的位移量
function M:getFpsY()
	local fpsY = 10 * self._speed
	return fpsY
end

-- 获取题目节点的缩放
function M:getTopicScaleXY(node, pos)
    local dis = PT.distance(pos, self._frame._cp)
    local ratioX = (100 - dis/3) / 100
    local ratioY = (100 - dis*2/3) / 100
	return node._scl * ratioX, node._scl * ratioY
end

----------------------
-- 移动方法
----------------------
-- 调度更新
function M:update()
	if self._update then return end
	self._update = A.cycle({
		{"delay", 1/60},
		{"fn", function ()
			self:refresh()
		end},
	}):at(self)
end

-- 停止调度更新
function M:stopUpdate()
	if not self._update then return end
	self:stopAction(self._update)
	self._update = nil
end

-- 刷新当前状态
function M:refresh()
	-- 边界差值（新创建的节点坐标要加上差值，不然定位会有偏差）
	local diffY = self:getOffsetPy(self._topics1[3]) - (self._borderY - self._spaceY)
	-- 在边界处创建新的题目节点
	if diffY <= 0 then
		self._topics1 = {
			self._topics1[2],
			self._topics1[3],
			self:createTopicNormal(self:getUpLevel(self._topics1[3]._level), self._borderY + diffY)
		}
		self._topics2 = {
			self._topics2[2],
			self._topics2[3],
			self:createTopicHighLight(self:getUpLevel(self._topics2[3]._level), self._borderY + diffY)
		}
	end

	-- 设置速度
	self:setSpeed()

	-- 设置题目节点的状态
	local fn = function (topics)
		for i, v in pairs(topics) do
			if v and not tolua.isnull(v) then
				-- 设置题目节点缩放
				self:setTopicScale(v)
				-- 设置题目节点位置
				self:setTopicPy(v)
			end
		end
	end
	fn(self._topics1)
	fn(self._topics2)

	self._remainDisY = self._remainDisY - self:getFpsY()
	if self._remainDisY <= 0 then
		self:turnOff()
	end

	-- print(self._remainDisY, self._speed)
end

-- 设置题目节点的缩放
function M:setTopicScale(node)
    local dis = PT.distance(node:point(), self._frame._cp)
    local ratioX = 1 - dis/3/self._borderY
    local ratioY = 1 - dis*2/3/self._borderY
    node:scaleX(node._scl * ratioX):scaleY(node._scl * ratioY)
end

-- 设置速度
function M:setSpeed()
	-- 进度
	local progress = 1 - self._remainDisY / self._totalDisY

	if self._remainDisY <= 350 then
        self._speed = self._speed * 0.95
		return
	end

    if progress < 0.1 then
        self._speed = 0.5 + (progress / 0.2) * (1 - 0.5)
    else
        self._speed = 2
    end
end

-- 设置题目节点位置
function M:setTopicPy(node)
	local fpsY = self:getFpsY()
	node:py(node:py() - fpsY)

	-- 到达下边界时移除节点
	if self:getOffsetPy(node) <= -self._borderY then
		node:remove()
	end
end

return M