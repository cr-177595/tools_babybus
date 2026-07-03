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
	self._layer    = params.layer
	-- 图片节点
	self._imgNode  = params.imgNode
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

----------------------
-- 功能函数
----------------------
-- 环形波纹shader效果
function M:waveEffect(pos)
	local vsh, fsh = "shader/ringWave.vsh", "shader/ringWave.fsh"
    local glProgram = cc.GLProgram:createWithFilenames(vsh, fsh)
    local glProgramState = cc.GLProgramState:getOrCreateWithGLProgram(glProgram)
    self._imgNode:setGLProgramState(glProgramState)

	-- 波纹运行的时间
	local time = 0
	-- 迭代的间隔
	local dt = 1/60
    -- 需要持续的总时间（波纹扩散）
    local totalTime1 = 0.4
	-- 需要持续的总时间（波纹消散）
    local totalTime2 = 0.8
	-- 需要迭代的次数（波纹扩散）
	local count1 = math.floor(totalTime1 / dt)
	-- 需要迭代的次数（波纹消散）
	local count2 = math.floor(totalTime2 / dt)
    -- 波纹强度 0~1
    local strength = 0

	-- 停止环形波纹shader效果
	self:stopWaveEffect()
	-- 波纹扩散和消散
    self._waveEffect = A.line({
        -- 波纹扩散
        A.cycle({
            {"delay", dt},
            {"fn", function ()
                -- 转换为shader坐标，设置为中心点
                local x = pos.x / self._imgNode:cw()
                local y = 1 - pos.y / self._imgNode:ch()
                glProgramState:setUniformVec2("centerP", {x = x, y = y})
			    -- 迭代时间，使波纹扩散
                time = time + dt
                glProgramState:setUniformFloat("time", time)
                -- 波纹强度递增
				strength = math.max(0, strength + (dt / totalTime1))
                glProgramState:setUniformFloat("strength", strength)
            end},
        }, count1),
        -- 波纹消散
        A.cycle({
            {"delay", dt},
            {"fn", function ()
                -- 迭代时间，使波纹继续扩散
                time = time + dt
                glProgramState:setUniformFloat("time", time)
                -- 波纹强度递减
                strength = math.max(0, strength - (dt / totalTime2))
                glProgramState:setUniformFloat("strength", strength)
            end},
        }, count2),
		{"fn", function ()
			self._waveEffect = nil
		end}
    }):at(self)
end

-- 停止环形波纹shader效果
function M:stopWaveEffect()
	if not self._waveEffect then return end
	self:stopAction(self._waveEffect)
	self._waveEffect = nil
end

----------------------
-- 触控函数
----------------------
function M:onTouchBegan(x, y)
	if not self._canTouch then return end
	local pos = self._imgNode:convertToNodeSpace(ccp(x, y))
	-- 环形波纹shader效果
	self:waveEffect(pos)

	return true
end

function M:onTouchMoved(x, y)

end

function M:onTouchEnded(x, y)

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