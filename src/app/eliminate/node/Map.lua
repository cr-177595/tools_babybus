--[[

	Copyright (c) 2011-2024 baby-bus.com

	TODO:   地图
	Author: CR
	Date:   2025.11.23
 
	http://www.babybus.com/

]] 

----------------------
-- 类
----------------------
local M = classSpriteTouch("Map")

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
	-- 格子边长
	self._gridLen = params.gridLen or 85
	-- 行数
	self._countA = params.countA or 7
	-- 列数
	self._countB = params.countB or 7
	-- 选中的格子集合
	self._selectGrids = {}
	-- 当前选中的格子
	self._selectedGrid = nil
	-- 是否正在处理中
	self._isProcessing = false
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
    -- 加载格子
    self:loadGrids()
end

function M:onEnterTransitionFinish()
    -- 初始化道具
    self:initProps()
end

-- 加载显示
function M:loadDisplay()
	self:size(cc.size(self._gridLen * self._countB, self._gridLen * self._countA))
end

-- 加载格子
function M:loadGrids()
    -- 格子集合（行列表）
    self._gridTab = {}
    -- 格子集合（数组）
    self._grids = {}
    for a = 1, self._countA do
        for b = 1, self._countB do
            local pos = ccp((b - 0.5) * self._gridLen, (self._countA - a + 0.5) * self._gridLen)
            local grid = require("app.eliminate.node.Grid").new({
                layer   = self._layer,
                map     = self,
	            gridId  = {a, b},
            }):to(self):p(pos):unbindTouch()
            self._gridTab[a] = ifnil(self._gridTab[a], {})
            self._gridTab[a][b] = grid
            table.insert(self._grids, grid)
            -- 绘制边框线
            self:createBorderLine(grid, 3)
        end
    end
end

-- 绘制边框线
function M:createBorderLine(node, c, color)
	-- 矩形宽高
	local w, h = node:cw(), node:ch()
	-- 线条粗细
	local c	   = ifnil(c, 1)
	-- 线条颜色
	local color = ifnil(color, COLOR3_BLACK)

	local info = {
		{size = cc.size(w, c), pos = ccp(w/2, h)},
		{size = cc.size(w, c), pos = ccp(w/2, 0)},
		{size = cc.size(c, h), pos = ccp(0, h/2)},
		{size = cc.size(c, h), pos = ccp(w, h/2)},
	}
	node._borderLines = {}
	for i, v in pairs(info) do
		local line = U.loadNodeMask({
			contentSize = v.size,
			color       = color,
			opacity     = 255
		}):to(node, 999):p(v.pos):unbindTouch()
		table.insert(node._borderLines, line)
	end
end

----------------------
-- 功能函数
----------------------
-- 初始化道具
function M:initProps()
	for a = 1, self._countA do
		for b = 1, self._countB do
			local grid = self:getGridById({a, b})
			-- 生成不会立即消除的道具
			local propType = self:getSafePropType(a, b)
			grid:createProp(propType)
		end
	end
end

-- 获取安全的道具类型（不会立即形成三消）
function M:getSafePropType(a, b)
	-- 5种类型
	local propType = math.random(1, 5)
	local tryIndex = 0
	local maxTry = 20
	
	while tryIndex < maxTry do
		-- 检查横向
		local canUse = true
		if b >= 3 then
			local grid1 = self:getGridById({a, b - 1})
			local grid2 = self:getGridById({a, b - 2})
			if grid1 and grid2 then
				local type1 = grid1:getPropType()
				local type2 = grid2:getPropType()
				if type1 and type1 == type2 and type1 == propType then
					canUse = false
				end
			end
		end
		
		-- 检查纵向
		if canUse and a >= 3 then
			local grid1 = self:getGridById({a - 1, b})
			local grid2 = self:getGridById({a - 2, b})
			if grid1 and grid2 then
				local type1 = grid1:getPropType()
				local type2 = grid2:getPropType()
				if type1 and type1 == type2 and type1 == propType then
					canUse = false
				end
			end
		end
		
		if canUse then
			return propType
		end
		
		-- 重新随机
		propType = math.random(1, 5)
		tryIndex = tryIndex + 1
	end
	
	return propType
end

-- 生成新道具
function M:createNewProp(grid)
	local propType = math.random(1, 5)
	return grid:createProp(propType)
end

-- 检测并消除
function M:checkAndEliminate()
	if self._isProcessing then return end
	
	local matches = self:findAllMatches()
	if #matches > 0 then
		self._isProcessing = true
		self:eliminateMatches(matches)
	else
		self._isProcessing = false
	end
end

-- 查找所有匹配项
function M:findAllMatches()
	-- 匹配项集合
	local matches = {}
	-- 已标记的格子集合
	local processedGrids = {}
	
	-- 检查横向匹配
	for a = 1, self._countA do
		for b = 1, self._countB - 2 do
			-- 检查起始位置是否已被处理
			local startKey = a .. "_" .. b
			if not processedGrids[startKey] then
				local grid1 = self:getGridById({a, b})
				local grid2 = self:getGridById({a, b + 1})
				local grid3 = self:getGridById({a, b + 2})
				
				if grid1 and grid2 and grid3 then
					local type1 = grid1:getPropType()
					local type2 = grid2:getPropType()
					local type3 = grid3:getPropType()
					
					-- 必须都不是null且类型相同
					if type1 ~= nil and type1 == type2 and type2 == type3 then
						local match = {grid1, grid2, grid3}
						-- 继续查找更多相同的
						for b2 = b + 3, self._countB do
							local gridNext = self:getGridById({a, b2})
							if gridNext and gridNext:getPropType() == type1 then
								table.insert(match, gridNext)
							else
								break
							end
						end
						table.insert(matches, match)
						-- 标记所有格子为已处理
						for _, grid in ipairs(match) do
							local key = grid._gridId[1] .. "_" .. grid._gridId[2]
							processedGrids[key] = true
						end
					end
				end
			end
		end
	end
	
	-- 检查纵向匹配
	for b = 1, self._countB do
		for a = 1, self._countA - 2 do
			-- 检查起始位置是否已被处理
			local startKey = a .. "_" .. b
			if not processedGrids[startKey] then
				local grid1 = self:getGridById({a, b})
				local grid2 = self:getGridById({a + 1, b})
				local grid3 = self:getGridById({a + 2, b})
				
				if grid1 and grid2 and grid3 then
					local type1 = grid1:getPropType()
					local type2 = grid2:getPropType()
					local type3 = grid3:getPropType()
					
					-- 必须都不是null且类型相同
					if type1 ~= nil and type1 == type2 and type2 == type3 then
						local match = {grid1, grid2, grid3}
						-- 继续查找更多相同的
						for a2 = a + 3, self._countA do
							local gridNext = self:getGridById({a2, b})
							if gridNext and gridNext:getPropType() == type1 then
								table.insert(match, gridNext)
							else
								break
							end
						end
						table.insert(matches, match)
						-- 标记所有格子为已处理
						for _, grid in ipairs(match) do
							local key = grid._gridId[1] .. "_" .. grid._gridId[2]
							processedGrids[key] = true
						end
					end
				end
			end
		end
	end
	
	return matches
end

-- 消除匹配的道具
function M:eliminateMatches(matches)
	-- 需要消除的道具数量
	local count = 0
	-- 已完成消除的道具数量
	local done = 0
	
	for _, match in ipairs(matches) do
		for _, grid in ipairs(match) do
			if grid._prop and not tolua.isnull(grid._prop) then
				count = count + 1
				grid._prop:eliminate(function()
					done = done + 1
					grid._prop = nil
					if done == count then
						self._isProcessing = false
						self:dropProps()
					end
				end)
			end
		end
	end
	
	if count == 0 then
		self._isProcessing = false
	end
end

-- 道具下落（分三步：1.让现有道具下落 2.生成新道具 3.判断是否继续消除）
function M:dropProps()
	local emptyCount = 0
	
	for b = 1, self._countB do
		local empty = 0
		
		-- 从下往上扫描，统计空格子数量，让上方道具下落
		for a = self._countA, 1, -1 do
			local grid = self:getGridById({a, b})
			if grid then
				if not grid._prop or tolua.isnull(grid._prop) then
					empty = empty + 1
				else
					if empty > 0 then
						-- 将道具向下移动空格数
						local target = self:getGridById({a + empty, b})
						if target then
							local prop = grid._prop
							grid._prop = nil
							target:bindProp(prop)
							CommonFun:resetParent(prop, target, 10)
							prop:moveTo(ccp(target:cw()/2, target:ch()/2), 0.3)
						end
					end
				end
			end
		end
		
		emptyCount = emptyCount + empty
		
		-- 在顶部生成新道具填补空位
		for i = 1, empty do
			local grid = self:getGridById({i, b})
			if grid and (not grid._prop or tolua.isnull(grid._prop)) then
				local prop = self:createNewProp(grid)
				-- 将道具放在上方，然后掉落下来
				prop:py(prop:py() + self._gridLen * empty)
				prop:moveTo(ccp(grid:cw()/2, grid:ch()/2), 0.3 + i * 0.05)
			end
		end
	end
	
	-- 计算所有下落动画的总时长
	local time = 0.3
	if emptyCount > 0 then
		time = 0.3 + (emptyCount - 1) * 0.05 + 0.3
	end
	
	-- 等待动画完成后，判断是否有新的匹配（继续消除）
	self:line({
		{"delay", time},
		{"fn", function()
			local matches = self:findAllMatches()
			if #matches > 0 then
				self._isProcessing = true
				self:eliminateMatches(matches)
			else
				self._isProcessing = false
			end
		end}
	})
end

-- 交换两个格子的道具
function M:swapGridProps(grid1, grid2, callback)
	if not grid1 or not grid2 then return end
	if not grid1._prop or not grid2._prop then return end
	
	local prop1 = grid1._prop
	local prop2 = grid2._prop
	
	-- 交换引用
	grid1._prop = prop2
	grid2._prop = prop1
	prop1._grid = grid2
	prop2._grid = grid1
	
	-- 移动道具
	CommonFun:resetParent(prop1, grid2, 10)
	CommonFun:resetParent(prop2, grid1, 10)
	
	local swapCount = 0
	prop1:swapTo(ccp(grid2:cw()/2, grid2:ch()/2), 0.2, function()
		swapCount = swapCount + 1
		if swapCount == 2 and callback then
			callback()
		end
	end)
	
	prop2:swapTo(ccp(grid1:cw()/2, grid1:ch()/2), 0.2, function()
		swapCount = swapCount + 1
		if swapCount == 2 and callback then
			callback()
		end
	end)
end

-- 检查两个格子是否相邻
function M:judgeAdjacent(grid1, grid2)
	if not grid1 or not grid2 then return false end
	
	local id1 = grid1._gridId
	local id2 = grid2._gridId
	
	-- 横向相邻
	if id1[1] == id2[1] and math.abs(id1[2] - id2[2]) == 1 then
		return true
	end
	
	-- 纵向相邻
	if id1[2] == id2[2] and math.abs(id1[1] - id2[1]) == 1 then
		return true
	end
	
	return false
end

-- 检查能否消除
function M:judgeCanEliminate(grid1, grid2)
	-- 临时交换
	local prop1 = grid1._prop
	local prop2 = grid2._prop
	grid1._prop = prop2
	grid2._prop = prop1
	
	-- 检查是否有匹配
	local matches = self:findAllMatches()
	local canEliminate = #matches > 0
	
	-- 恢复
	grid1._prop = prop1
	grid2._prop = prop2
	
	return canEliminate
end

--------------------------
-- 获取属性、节点
--------------------------
-- 根据格子编号获取格子
function M:getGridById(gridId)
    if self._gridTab[gridId[1]] and self._gridTab[gridId[1]][gridId[2]] then
        return self._gridTab[gridId[1]][gridId[2]]
    end
end

--------------------------
-- 触控函数
--------------------------
function M:onTouchBegan(x, y)
	if self._isProcessing then return true end
	
    for i, grid in pairs(self._grids) do
        if TH.isTouchInside(grid, x, y) and grid._prop then
            if not self._selectedGrid then
				-- 第一次选中
				self._selectedGrid = grid
				grid:setSelected(true)
			else
				-- 第二次选中
				if grid == self._selectedGrid then
					-- 点击同一个格子，取消选中
					grid:setSelected(false)
					self._selectedGrid = nil
				else
					-- 点击不同格子
					if self:judgeAdjacent(self._selectedGrid, grid) then
						if self:judgeCanEliminate(self._selectedGrid, grid) then
							self._isProcessing = true
							local g1 = self._selectedGrid
							g1:setSelected(false)
							self._selectedGrid = nil
							
							self:swapGridProps(g1, grid, function()
								self._isProcessing = false
								self:checkAndEliminate()
							end)
						else
							self._isProcessing = true
							local g1 = self._selectedGrid
							local g2 = grid
							g1:setSelected(false)
							self._selectedGrid = nil
							
							self:swapGridProps(g1, g2, function()
								self:swapGridProps(g2, g1, function()
									self._isProcessing = false
								end)
							end)
						end
					else
						self._selectedGrid:setSelected(false)
						self._selectedGrid = grid
						grid:setSelected(true)
					end
				end
			end
            break
        end
    end
    return true
end

return M