--[[

    Copyright (c) 2011-2025 baby-bus.com
    TODO:	骨骼基类
    Author: CR
    Date:   2025.06.13
    http://www.babybus.com/

]] 

local M = classArmatureTouch("BaseBone")

----------------------
-- 公共参数
----------------------
-- [常量]
-- ..

----------------------
-- 构造方法
----------------------
--[[--

构造方法，定义节点实例初始化逻辑

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
    -- 皮肤编号
    self._skinId  = params.skinId
    -- 缩放系数
	self._scale   = params.scale or 1
    -- 初始坐标
    self._initPos = params.initPos or ccp(0, 0)
end

----------------------
-- 节点渲染 
----------------------
--[[--

实体渲染，处理实体节点加载、事件绑定等相关操作

]]
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
    -- 骨骼换装信息
    local skinConfig = {
        -- 骨头名称
        bones = {
            [1]  = "",
            [2]  = "",
            [3]  = "",
            [4]  = "",
            [5]  = "",
            [6]  = "",
            [7]  = "",
            [8]  = "",
            [9]  = "",
            [10] = "",
        },
        -- 纹理名称
        skins = {
            [1] = {
                [1]  = "",
                [2]  = "",
                [3]  = "",
                [4]  = "",
                [5]  = "",
                [6]  = "",
                [7]  = "",
                [8]  = "",
                [9]  = "",
                [10] = "",
            },
            [2] = {
                [1]  = "",
                [2]  = "",
                [3]  = "",
                [4]  = "",
                [5]  = "",
                [6]  = "",
                [7]  = "",
                [8]  = "",
                [9]  = "",
                [10] = "",
            },
        }
    }

    self._skinConfig = skinConfig
end

-- 换装
function M:changeSkin(skinId)
    if not skinId and not self._skinId then return end
    self._skinId = skinId or self._skinId
    
	for k, bone in pairs(self._skinConfig.bones) do
		local skin = self._skinConfig.skins[self._skinId][k]
		if skin == "hide" then
			-- 隐藏骨头
			self:hideBone(bone)
		elseif skin == "no" then
			-- 无需换装
		elseif skin and isstring(skin) then
			-- 直接换装
			self:getBone(bone):change(skin)
		elseif skin and istable(skin) then
			-- 索引换装
			for i, v in pairs(skin) do
				self:changeBoneIndex(bone, v, i - 1)
			end
		end
	end
end

-- 骨骼内部索引换装(骨头，图片路径， 索引)
--[[ — 
    @boneName:骨头名称
    @fileName:换装名字
    @index   :图层索引         （索引顺序为：0、1、2、3、4...）
]]--
function M:changeBoneIndex(boneName, fileName, index)
    -- 换装图片 装载器
    local skin = ccs.Skin:create()
    -- 内部换装
    skin:initWithSpriteFrameName(fileName..".png")
    -- 外部换装
    -- skin:initWithFile(filePath)

    local bone = self._armature:getBone(boneName)
    if bone and not tolua.isnull(bone) then
        bone:addDisplay(skin, index)
    end
end

-- 获取骨骼动作的时间
function M:getAnimationTime(animationName)
    return self:getAnimation():getDuration(animationName) / 24
end

-- 只显示列表中的骨头
function M:showBoneByList(anim, list)
    self:show()

    if anim then
        self:play(anim)
    end

    for i, boneName in ipairs(T.keys(self._armature:getBoneDic())) do
		if T.contains(list, boneName) then
			self:showBone(boneName)
		else
			self:hideBone(boneName)
		end
    end
end

----------------------
-- 动画
----------------------
function M:breathe()
    self:play("")
end

----------------------
-- 动画回调 
----------------------
function M:movementHandler(evtType, moveId)
	if evtType == 1 then
		if moveId == "" then
            self:play("")
		elseif moveId == "" then
            self:play("")
		end
	elseif evtType == 2 then
		if moveId == "" then
            self:play("")
		elseif moveId == "" then
            self:play("")
        end
	end
end

return M