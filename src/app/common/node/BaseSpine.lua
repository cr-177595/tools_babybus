--[[

    Copyright (c) 2011-2025 baby-bus.com
    TODO:	Spine骨骼基类
    Author: CR
    Date:   2025.03.26
    http://www.babybus.com/

]] 

local M = classSpine("BaseSpine")

----------------------
-- 构造方法
----------------------
function M:ctor(params)
    -- [超类调用]
	M.super.ctor(self, params)
    
    -- 主层
    self._layer    = params.layer
    -- 皮肤编号
    self._skinId   = params.skinId
    -- 缩放系数
	self._scale    = params.scale or 1
    -- 初始坐标
    self._initPos  = params.initPos or ccp(0, 0)
    -- 进场坐标
    self._enterPos = params.enterPos
    -- 退场坐标
    self._quitPos  = params.quitPos
end

----------------------
-- 节点渲染
----------------------
function M:onRender()
    -- [超类调用]
	M.super.onRender(self)

    -- 子节点透明度跟随父节点(设父节点)
    self:setCascadeOpacityEnabled(true)
    -- 初始化皮肤配置
    self:initSkinConfig()
    -- 初始换装
    self:changeSkin()
    -- 缩放
	self:scale(self._scale):p(self._initPos)
end

----------------------
-- 功能函数
----------------------
-- 初始化皮肤配置
function M:initSkinConfig()
    local skinConfig = {
        [1] = {
            "",
            "",
            "",
        },
        [2] = {
            "",
            "",
            "",
        },
    }
    self._skinConfig = skinConfig
end

-- 换装
function M:changeSkin(skinId)
    if not skinId and not self._skinId then return end
    self._skinId = skinId or self._skinId

    local skeleton = self:getSkeleton()
    local skeletonData = self:getSkeletonData()
    local newSkin = bb.si.Spine:createSkin("skin")

    for i, v in pairs(self._skinConfig[self._skinId]) do
        newSkin:addSkin(skeletonData:findSkin(v))
    end
    
    skeleton:setSkin(newSkin)
    skeleton:setSlotsToSetupPose()
end

---------------------------------------------------------------------------

-- 获取动画时长
---@param animationName string 动作名称
---@param animationName table 动作名称列表
function M:getAnimationTime(animationName)
    local skeletonData = self:getSkeletonData()
    local time = 0

    -- 单个动画名转化为动画列表，统一处理
    if type(animationName) == "string" then
        animationName = {animationName}
    end

    for i, v in pairs(animationName) do
        local animation = skeletonData:findAnimation(v)
        time = time + animation:getDuration()
    end

    return time
end

---------------------------------------------------------------------------

-- 添加动画
---@param animationName string 动作名称
---@param isLoop bool 是否循环
---@param trackIndex number 动作轨道 ID
---@param mixDuration number 动作过渡时间
---@param delay number 延迟时间
function M:add(animationName, isLoop, trackIndex, mixDuration, delay)
    return self:addAnimation(animationName, isLoop, trackIndex, mixDuration, delay)
end

---------------------------------------------------------------------------

-- 隐藏插槽
function M:hideSlot(name)
    if not self["_slot_"..name] then
        -- 获取记录插槽
        local slot = self:findSlot(name)
        if slot then
            self["_slot_"..name] = slot:getAttachment()
            -- 隐藏插槽
            slot:setAttachment(nil)
        end
    end
end

-- 显示插槽
function M:showSlot(name)
    if self["_slot_"..name] then
        -- 获取记录插槽
        local slot = self:findSlot(name)
        if slot then
            -- 显示插槽
            slot:setAttachment(self["_slot_"..name])
            -- 清空记录
            self["_slot_"..name] = nil
        end
    end
end

---------------------------------------------------------------------------

-- 只隐藏传参表中的插槽
function M:onlyHideSlots(slots)
    local part = bb.si.Spine.createWithSkeleton(self:getSkeleton())
    for i, slot in pairs(slots) do
        local slotIndex = part:findSlot(slot):getData():getIndex()
        -- 只显示对应区间的插槽
        part:setSlotsRange(slotIndex, 0)
    end
end

---------------------------------------------------------------------------

-- 隐藏骨骼（动画有变更骨骼部件位置这个接口就无效） #boneName 一般有前缀G_
function M:hideBone(boneName)
    local bone = self:findBone(boneName)
    if not self["_bone"..boneName] then
        self["_bone"..boneName] = bone:getX()
    end
    -- 将骨骼位置设置到屏幕之外，达到隐藏效果
    bone:setX(999999)
end

-- 显示骨骼
function M:showBone(boneName)
    if self["_bone"..boneName] then
        local bone = self:findBone(boneName)
        if bone then
            bone:setX(self["_bone"..boneName])
            self["_bone"..boneName] = nil
        end
    end
end

---------------------------------------------------------------------------

-- 设置当前缩放系数
function M:setCurScale(scale)
    self:scale(scale)
    self._scale = scale
    return self
end

-- 设置初始坐标
function M:setInitPos(pos)
    self:p(pos)
    self._initPos = pos
    return self
end

---------------------------------------------------------------------------

-- 骨骼位置跟随
function M:updateFollow(node, boneName, offsetPos)
    offsetPos = offsetPos or ccp(0, 0)
    -- 骨骼
    local bone = self:findBone(boneName)
    -- 调度节点
    local scheduleNode = U.loadNode():to(self)
    self._scheduleNode = scheduleNode
    -- 移除后自动消除
    scheduleNode:scheduleUpdateWithPriorityLua(function (dt)
        local worldpoint = self:convertToWorldSpace(ccp(bone:getWorldX(), bone:getWorldY()))
        if node._offsetPos then
            worldpoint = ccpAdd(worldpoint, node._offsetPos)
        else
            worldpoint = ccpAdd(worldpoint, offsetPos)
        end
        node:p(node:getParent():convertToNodeSpace(worldpoint))
	end, 0)
end

-- 停止骨骼位置跟随
function M:stopUpdateFollow()
    if self._scheduleNode and not tolua.isnull(self._scheduleNode) then
        self._scheduleNode:remove()
        self._scheduleNode = nil
    end
end

---------------------------------------------------------------------------

-- 加载前层身体部件
---@param slot string 插槽名
---@param rangeNum number 区间索引数量
---@param zor number 层级
---@param needUpdate boolean 是否需要调度器刷新部件位置
function M:loadBodyPart(slot, rangeNum, zor, needUpdate)
    rangeNum = rangeNum or 0
    local part = bb.si.Spine.createWithSkeleton(self:getSkeleton())
    -- 起点索引
    local startIndex = part:findSlot(slot):getData():getIndex()
    -- 终点索引
    local endIndex = startIndex + rangeNum
    -- 只显示对应区间的插槽
    part:setSlotsRange(startIndex, endIndex)
    -- 设置位置、缩放
    part:to(self:getParent(), zor):p(self:point()):scale(self:scale()):rotate(self:rotate())

    if needUpdate then
        -- 需要调度器位置跟随的部件存进集合
        self._bodyParts = ifnil(self._bodyParts, {})
        table.insert(self._bodyParts, part)
    end

    return part
end

-- 调度器刷新部件位置
function M:updateParts()
    local scheduleNode = U.loadNode():to(self)
    self._scheduleNode = scheduleNode
    scheduleNode:scheduleUpdateWithPriorityLua(function (dt)
        if istable(self._bodyParts) then
            for i, v in pairs(self._bodyParts) do
                v:p(self:point()):scale(self:scale()):rotate(self:rotate())
            end
        end
	end, 0)
end

-- 停止调度器刷新部件位置
function M:stopUpdateParts()
    if self._scheduleNode and not tolua.isnull(self._scheduleNode) then
        self._scheduleNode:remove()
        self._scheduleNode = nil
    end
end

-- 移除所有身体部件
function M:removeBodyParts()
    if istable(self._bodyParts) then
        for i, v in pairs(self._bodyParts) do
            v:remove()
        end
    end
    self._bodyParts = nil
end

----------------------
-- 动画回调 
----------------------
-- 动画开始回调
function M:onAnimationStart(entry)
    -- print(entry.type, entry.animation)
    if entry.animation == "" then
        self:play("")
    elseif entry.animation == "" then
        self:play("")
    end
end

-- 动画完成回调（如果循环播放动画则该事件会多次触发）
function M:onAnimationComplete(entry)
    -- print(entry.type, entry.animation)
    if entry.animation == "" then
        self:play("")
    elseif entry.animation == "" then
        self:play("")
    end
end

-- 动画打断回调
function M:onAnimationInterrupt(entry)
	-- print(entry.type, entry.animation)
end

-- 动画结束回调（既可能缘于动画播放中断亦可能是非循环动画播放完成）
function M:onAnimationEnd(entry)
    -- print(entry.type, entry.animation)
end

-- 动画释放回调
function M:onAnimationDispose(entry)
    -- print(entry.type, entry.animation)
end

-- 动画自定义事件回调
function M:onUserDefinedEvent(entry, event)
    -- print(event.name, event.data)
end

return M