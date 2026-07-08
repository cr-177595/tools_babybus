--[[

	Copyright (c) 2011-2024 baby-bus.com

	TODO:   惯性触控节点类
	Author: CR
	Date:   2024.03.13
 
	http://www.babybus.com/

]] 

----------------------
-- 类
----------------------
local M = classSpriteTouch("InertiaTouch")

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
    -- 移动类型 1:横向移动 2:纵向移动
    self._type     = params.type or 1
    -- 移动对象集合，支持单/多对象
    self._nodes    = params.nodes
    -- 第一个对象，第一个对象作为参照对象
    self._node     = self._nodes[1]
    -- 位移系数集合，对应每个对象
    self._ratios   = params.ratios or {}
    -- 位移量限制
    self._limitOffset = params.limitOffset
    -- 缓冲区大小
    self._buffer   = params.buffer or 400
    -- 移动结束回调
    self.moveEndFn = params.moveEndFn or function () end
	-- 触控锁
	self._canTouch = true
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
end

function M:onEnterTransitionFinish()
    -- 初始化移动对象的初始位置
    for i, v in pairs(self._nodes) do
        -- 左/下边界坐标
        v._pos1 = ifnil(v._pos1, v:point())
        -- 右/上边界坐标
        if self._type == 1 then
            v._pos2 = ccpAdd(v._pos1, ccp(self._limitOffset * self._ratios[i], 0))
        elseif self._type == 2 then
            v._pos2 = ccpAdd(v._pos1, ccp(0, self._limitOffset * self._ratios[i]))
        end
    end
end

----------------------
-- 功能函数
----------------------
-- 刷新移动对象的位置 #dev 刷新的位移量
function M:refreshNodesPos(dev)
    -- 计算相对于初始位置的偏移量
    local offset = self:getOffset(dev)
    -- 缓冲区阻力，边界限制
    if offset > 0 and offset <= self._buffer then
        dev = dev/5
        offset = self:getOffset(dev)
    elseif offset >= self._buffer then
        offset = self._buffer
    elseif offset < self._limitOffset and offset >= self._limitOffset - self._buffer then
        dev = dev/5
        offset = self:getOffset(dev)
    elseif offset <= self._limitOffset - self._buffer then
        offset = self._limitOffset - self._buffer
    end
    -- 刷新移动对象的位置
    for i, v in pairs(self._nodes) do
        if self._type == 1 then
            v:px(v._pos1.x + offset * self._ratios[i])
        else
            v:py(v._pos1.y + offset * self._ratios[i])
        end
    end
end

-- 获取相对于初始位置的偏移量
function M:getOffset(dev)
    dev = ifnil(dev, 0)
    local offset
    if self._type == 1 then
        offset = self._node:px() + dev - self._node._pos1.x
    elseif self._type == 2 then
        offset = self._node:py() + dev - self._node._pos1.y
    end
    return offset
end

-- 获取最后一次触控移动到触控结束的时间
function M:getTimeWithLastMoveToEnd()
    if self._lastMoveTime then
        return os.clock() - self._lastMoveTime
    else
        return os.clock() - self._startTime
    end
end

-- 惯性移动动作
function M:inertiaMoveAct(speed)
    if self._inertiaMoveAct then return end
    self._inertiaMoveAct = A.cycle({
        {"delay", 1/60},
        {"fn", function ()
            -- 计算本帧的位移量
            local dev = speed / 200
            -- 刷新移动对象的位置
            self:refreshNodesPos(dev, true)
            -- 速度递减
            speed = speed * 0.9

            if self:judgeInBuffer() and math.abs(speed) < 2000 then
                self:stopInertiaMoveAct()
                -- 回弹动作
                self:inertiaBackAct()
            elseif math.abs(speed) < 10 then
                -- 如果速度减小到接近0，则停止惯性移动
                speed = 0
                self:stopInertiaMoveAct()
                -- 移动结束回调
                self.moveEndFn()
            end
		end}
	}):at(self)
end

-- 停止惯性移动动作
function M:stopInertiaMoveAct()
	if not self._inertiaMoveAct then return end
	self:stopAction(self._inertiaMoveAct)
	self._inertiaMoveAct = nil
end

-- 回弹动作
function M:inertiaBackAct()
    local offset = self:getOffset()
    -- 回弹时间
    local time = 0.4
    -- local dis
    -- if offset > 0 and offset <= self._buffer then
    --     dis = PT.distance(self._node:point(), self._node._pos1)
    -- elseif offset < self._limitOffset and offset >= self._limitOffset - self._buffer then
    --     dis = PT.distance(self._node:point(), self._node._pos2)
    -- end
    -- time = dis/800
    
    for i, v in pairs(self._nodes) do
        local pos
        local ratio = self._ratios[i] or 1
        if offset > 0 and offset <= self._buffer then
            if self._type == 1 then
                pos = ccp(v._pos1.x, v:py())
            elseif self._type == 2 then
                pos = ccp(v:px(), v._pos1.y)
            end
        elseif offset < self._limitOffset and offset >= self._limitOffset - self._buffer then
            if self._type == 1 then
                pos = ccp(v._pos1.x + self._limitOffset * ratio, v:py())
            elseif self._type == 2 then
                pos = ccp(v:px(), v._pos1.y + self._limitOffset * ratio)
            end
        end
        v:line({
            {"easing", "sineInOut", {"moveTo", time, pos}},
            {"fn", function ()
                if i == #self._nodes then
                -- 移动结束回调
                self.moveEndFn()
                end
            end}
        })
    end
end

-- 判断是否在缓冲区
function M:judgeInBuffer()
    local offset = self:getOffset()
    if offset > 0 and offset <= self._buffer then
        return true
    elseif offset < self._limitOffset and offset >= self._limitOffset - self._buffer then
        return true
    end
end

----------------------
-- 触控函数
----------------------
function M:onTouchBegan(x, y)
	if not self._canTouch then return end

    -- 记录开始触控的X/Y坐标
    self._startXY = self._type == 1 and x or y
    -- 总位移量初始化为0
    self._dis = 0
    -- 位移量初始化为0
    self._dev = 0
    -- 记录触控开始的时刻
    self._startTime = os.clock()
    -- 停止当前的惯性移动动作
    self:stopInertiaMoveAct()

	return true
end

function M:onTouchMoved(x, y)
    -- 获取当前触控的X/Y坐标
    local xy = self._type == 1 and x or y
    -- 计算当前触控移动的位移量
    local dev = xy - self._startXY
    -- 刷新移动对象的位置
    self:refreshNodesPos(dev)
    -- 判断当前移动的方向与上次移动的方向是否相同
    if self._dev * dev >= 0 then
        -- 方向相同，总位移量累加
        self._dis = self._dis + dev
    else
        -- 方向相反，重置总位移量、开始的时刻
        self._dis = dev
        self._startTime = os.clock()
    end
    -- 刷新移动的位移量
    self._dev = dev
    -- 刷新开始触控的X/Y坐标
    self._startXY = xy
    -- 记录最后一次触控移动的时刻
    self._lastMoveTime = os.clock()
end

function M:onTouchEnded(x, y)
    -- 计算触控持续的时间
    local touchTime = os.clock() - self._startTime
    -- 计算触控结束时的速度
    local speed = self._dis / touchTime

    if self:judgeInBuffer() then
        -- 松手时如果在缓冲区，则执行回弹动作
        self:inertiaBackAct()
    elseif self:getTimeWithLastMoveToEnd() < 0.007 then
        -- 如果最后一次触控移动到触控结束的时间小于0.007秒，则执行惯性移动
        self:inertiaMoveAct(speed)
    else
        -- 移动结束回调
        self.moveEndFn()
    end
    -- 清除触控相关参数
    self._startXY = nil
    self._dis = nil
    self._dev = nil
    self._startTime = nil
    self._lastMoveTime = nil
end

return M