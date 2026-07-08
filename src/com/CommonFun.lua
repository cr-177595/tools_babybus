
local M = {}

---------------------------------------------------------------------------
----------------------------------通用方法----------------------------------
---------------------------------------------------------------------------

--[[
    调用示例
    local info = {
        {text = 3,     scl = 1, pos = ccp(10, py)},
        {text = "mul", scl = 1, pos = ccp(20, py)},
        {text = 5,     scl = 1, pos = ccp(30, py)},
        {text = "equ", scl = 1, pos = ccp(40, py)},
        {text = 15,    scl = 1, pos = ccp(50, py)},
    }
]]
-- 加载等式
function M:loadEquation(parent, imgPre, info)
    -- 等式节点集合
    local equationNodes = {}
    -- 资源前缀
    local imgPre = imgPre or "common/num/"

    for i, v in pairs(info) do
        local text  = v.text
        local color = ifnil(v.color, COLOR3_WHITE)
        local zor   = ifnil(v.zor, 10)
        local scl   = ifnil(v.scl, 1)
        local pos   = v.pos

        local node
        if type(text) == "number" then
            node = require("app.common.node.BaseNumber").new({
                imgPre    = imgPre,
                num       = text,
                color     = color,
                isDisplay = false,
            }):loadDisplay()
        elseif T.contains({"add", "sub", "mul", "div", "equ"}, text) then
            node = D.img(imgPre..text..".png"):color(color)
        elseif string.sub(text, 1, 6) == "numBox" then
            local boxType = v.boxType or 1
            local num = tonumber(string.sub(text, 7))
            -- 数字框
            node = U.loadSpriteScale9({ 
                imgName     = "common/box/"..boxType..".png",
                contentSize = v.size,
            })
            node:setCascadeOpacityEnabled(true)
            node._numNode = require("app.common.node.BaseNumber").new({
                imgPre    = imgPre,
                num       = num,
                color     = color,
            }):to(node):p(node:cw()/2, node:ch()/2)
        elseif text == "queBox" then
            local boxType = v.boxType or 2
            -- 问号框
            node = U.loadSpriteScale9({ 
                imgName     = "common/box/"..boxType..".png",
                contentSize = v.size,
            })
            node:setCascadeOpacityEnabled(true)
            local color = v.color or ccc3(250, 76, 62)
            node._queNode = D.img("common/num/que.png"):to(node):color(color):p(node:cw()/2, node:ch()/2)
            node._queNode._color = color
        else
            node = U.loadLabelTTF({
                text     = text,
                fontSize = math.floor(30 * scl),
                color    = color,
            })
        end
        node:to(parent, zor):scale(scl):p(pos)
        node._scale = scl
        table.insert(equationNodes, node)
    end
    
    return equationNodes
end

---------------------------------------------------------------------------

-- 创建自动适配内容的通用选项框
function M:createOptionFrame(params)
    -- 内容资源前缀
    local itemImgPre = params.itemImgPre or "common/num/"
    -- 内容信息
    local info = params.info
    -- 内容的间距
    local spacing = params.spacing or 2
    -- 框在内容尺寸基础上增加宽高
    local offsetSize = params.offsetSize or cc.size(20, 36)
    -- 颜色
    local color = params.color or COLOR3_WHITE
    -- 缩放系数
    local scale = params.scale or 1
    -- 边框样式
    local boxType = params.boxType or 3

    -- 计算框的整体尺寸
    local w, h = 0, 0
    -- 所有内容节点的总宽度
    local sumItemsWidth = 0
    -- 内容节点集合
    local nodes = {}
    for i, v in pairs(info) do
        local node = CommonFun:createOptionItem(itemImgPre, v, color)
        table.insert(nodes, node)
        w = w + node:cw()*node:scaleX() + spacing
        h = node:ch()*node:scaleY()
        sumItemsWidth = sumItemsWidth + node:cw()*node:scaleX() + (i < #info and spacing or 0)
    end
    w = w + offsetSize.width
    h = h + offsetSize.height

    -- 创建框容器
    local frame = U.loadSpriteScale9({
        imgName     = "common/box/"..boxType..".png",
        contentSize = cc.size(w, h),
    }):scale(scale)
    frame:setCascadeOpacityEnabled(true)
    frame._scale = scale
    frame._nodes = nodes
    
    -- 计算起始位置使所有选项整体居中
    local curPx = (w - sumItemsWidth) / 2
    for i, v in pairs(nodes) do
        v:to(frame):p(curPx + v:cw()*v:scaleX()/2, h/2)
        curPx = curPx + v:cw()*v:scaleX() + spacing
    end

    return frame
end

-- 创建选项内容节点
function M:createOptionItem(imgPre, v, color)
    color = color or COLOR3_WHITE
    
    local node
    if type(v) == "userdata" then
        node = v
        node:color(color)
    elseif type(v) == "number" then
        node = require("app.common.node.BaseNumber").new({
            imgPre    = imgPre,
            num       = v,
            color     = color,
            isDisplay = false,
        }):loadDisplay()
    elseif T.contains({"add", "sub", "mul", "div", "equ"}, v) then
        node = D.img(imgPre..v..".png"):color(color)
    else
        -- 自定义路径的图片
        node = D.img(imgPre..v..".png"):color(color)
    end

    -- CommonFun:loadHelp(node)

    return node
end

---------------------------------------------------------------------------

--[[
    调用示例
    CommonFun:createClippingNode({
        parent = parent,
        byNode = node,
    })
]]
-- 创建裁切节点（根据节点、图片、尺寸，方式三选一）
function M:createClippingNode(params)
    -- 父节点
    local parent = params.parent
    -- 根据图片的纹理
    local byImage  = params.byImage
    -- 根据节点的纹理
    local byNode   = params.byNode
    -- 根据尺寸
    local bySize   = params.bySize
    -- ALPHA阈值
    local alphaThreshold = params.alphaThreshold or 0
    -- 是否透明度跟随裁切节点
    local isFollowOpacity = ifnil(params.isFollowOpacity, true)

    -- 裁切模板
    local stencil
    -- 创建方式三选一
    if byImage then
        -- 根据图片的纹理
        stencil = D.img(byImage):p(parent:cw()/2, parent:ch()/2)
    elseif byNode then
        -- 根据节点的纹理
        local texture = CommonFun:createTexture(byNode)
        stencil = D.img(texture):p(parent:cw()/2, parent:ch()/2)
    elseif bySize then
        -- 根据尺寸
        stencil = cc.NodeExtend.extend(cc.DrawNode:create())
        stencil:drawSolidRect(ccp(0, 0), ccp(bySize.width, bySize.height), cc.c4f(1, 1, 1, 1))
    end
    
    local clip = cc.NodeExtend.extend(cc.ClippingNode:create(stencil))
    clip:setStencil(stencil)
    -- 设置遮罩模式[false:显示模板区域，true:显示模板外区域]
    clip:setInverted(false)
    -- 设置ALPHA阈值
    clip:setAlphaThreshold(alphaThreshold)
    clip:to(parent)
    -- 子节点透明度跟随父节点
    clip:setCascadeOpacityEnabled(isFollowOpacity)

    return clip
end

-- RenderTexture创建节点纹理
function M:createTexture(node)
	node:show()
    local cw, ch = node:cw(), node:ch()
    local render = cc.NodeExtend.extend(cc.RenderTexture:create(cw, ch)):p(node:point()):hide()
	render:begin()
	local oldSclX, oldSclY, oldP = node:scaleX(), node:scaleY(), node:point()
	node:scaleX(1):scaleY(-1):p(ccp(cw/2, ch/2)):visit()
	node:scaleX(oldSclX):scaleY(oldSclY):p(oldP)
	render:endToLua()
    
    return render:getSprite():getTexture()
end

---------------------------------------------------------------------------

--[[
    调用示例
    local collisionNode = CommonFun:judgeCollisionNode({
        -- 触控的节点
        node  = self._touchNode,
        -- 被碰撞的目标节点集合
        nodes = self._decNodes,
        -- 至少要达到的相交面积值（像素面积）
        mustAreaValue = 100,
    })
]]
-- 与多个节点做碰撞检测（优先取相交面积最大的碰撞节点）
function M:judgeCollisionNode(params)
    -- 被碰撞的节点
	local node	= params.node
    -- 被碰撞的目标节点集合
	local nodes = params.nodes
    -- 至少要达到的相交面积值（像素面积）
    local mustAreaValue = params.mustAreaValue or 1

    -- 相交面积的数据
    local data = {}
    for i, v in pairs(nodes) do
        local areaValue
        if node == v then
            -- 自身视为相交面积为0
            areaValue = 0
        else
            local rect1 = node:getBoundingBoxWorld()
            local rect2 = v:getBoundingBoxWorld()
            -- 判断两个包围盒是否相交
            if cc.rectIntersectsRect(rect1, rect2) then
                local intersectRect = cc.rectIntersection(rect1, rect2)
                areaValue = intersectRect.width * intersectRect.height
            else
                areaValue = 0
            end
        end
        table.insert(data, {node = v, areaValue = areaValue})
    end

    -- 输出相交面积最大的目标节点
    local collisionNode
    local maxAreaValue = 0
    for i, v in ipairs(data) do
        if v.areaValue > maxAreaValue then
            maxAreaValue  = v.areaValue
            collisionNode = v.node
        end
    end

    if maxAreaValue < mustAreaValue then
        collisionNode = nil
    end

    return collisionNode
end

---------------------------------------------------------------------------

--[[
    调用示例
    -- 开始引导（语音引导1次后，后续只做反馈不播语音）
    CommonFun:openGuide({
        layer      = self,
        voiceGuideLimit = 1,
        time       = 10,
        delayTime  = delayTime,
        voice      = "ven293003007",
        guideNodes = self._equationNodes,
        fbType     = 2,
    })
    -- 停止引导
    CommonFun:stopGuide(layer)
]]
-- 开启引导
function M:openGuide(params)
    -- 挂载引导的节点
    local layer      = params.layer or D.getRunningScene():getMainLayer()
    -- 引导语音次数限制
    local voiceGuideLimit = params.voiceGuideLimit or math.huge
    -- 达到引导语音次数限制后，是否继续做无语音的引导反馈
    local noVoiceGuideAfterLimit = ifnil(params.noVoiceGuideAfterLimit, true)
    -- 是否累加引导次数
    local addGuideNum = ifnil(params.addGuideNum, true)
    -- 无操作引导间隔时间
    local time       = params.time or 10
    -- 引导语音（单条语音：string / 语音列表：table）
    local voice      = params.voice
    -- 语音时长
    local voiceTime  = CommonFun:getVoiceTime(voice)
    -- 首次播语音标识
    local isFirst    = true
    -- 首次播语音时的回调
    local firstFn    = params.firstFn
    -- 开始播语音时的回调
    local fn         = params.fn
    -- 播语音结束时的回调
    local endFn      = params.endFn
    -- 缩放引导的节点集合
    local guideNodes = params.guideNodes or {}
    if guideNodes and type(guideNodes) ~= "table" then
        guideNodes = {guideNodes}
    end
    -- 缩放反馈类型（0:不缩放 1:轮流缩放 2:同时缩放两次 3:随机一件物品缩放两次）
    local fbType     = params.fbType or 0
    -- 缩放反馈时长
    local fbTime     = params.fbTime or fbType == 1 and 0.25*#guideNodes or 0.5
    -- 缩放反馈音效
    local fbSnd      = params.fbSnd or "sfx233000028"
    -- 缩放反馈在语音中触发的时间比例（0-1）
    local fbRatio    = params.fbRatio or 0
    -- 缩放反馈时的回调
    local fbFn       = params.fbFn

    -- 起始延迟时间（不能大于间隔时间）
    local delayTime1 = params.delayTime or time
    delayTime1 = delayTime1 < time and delayTime1 or time
    -- 末尾延迟时间（间隔时间和起始延迟时间的差值，以确保间隔时间不受起始延迟时间影响）
    local delayTime2 = time - delayTime1

    if layer._guideAct then return end
	layer._guideAct = A.cycle({
		{"delay", delayTime1},
		{"fn", function()
            -- 记录引导次数
            if addGuideNum then
                layer._guideNum = ifnil(layer._guideNum, 0) + 1
            end
            -- 播放语音
            if layer._guideNum <= voiceGuideLimit then
                CommonFun:playVoiceSequence(voice)
            end
            -- 首次优先执行firstFn
            if isFirst then
                isFirst = false
                if firstFn then firstFn() return end
            end
            if fn then fn() end
		end},
        {"delay", voiceTime * fbRatio},
        {"fn", function ()
            -- 缩放反馈
            layer._guideNodes = guideNodes
            if self["feedback"..fbType] then
                self["feedback"..fbType](self, guideNodes, fbSnd)
            end
            if fbFn then fbFn() end
        end},
        {"delay", voiceTime * (1 - fbRatio)},
        -- 避免无语音时，最后一次的缩放反馈被停止引导给打断
        {"delay", voiceTime == 0 and fbTime or 0},
        {"fn", function ()
            if layer._guideNum and layer._guideNum >= voiceGuideLimit then
                CommonFun:stopGuide(layer)
                if noVoiceGuideAfterLimit then
                    params.voice = nil
                    params.delayTime = params.time
                    CommonFun:openGuide(params)
                end
            end
            if endFn then endFn() end
        end},
        {"delay", delayTime2},
	}):at(layer)
end

-- 停止引导
function M:stopGuide(layer)
	if layer._guideAct then
        layer:stopAction(layer._guideAct)
        layer._guideAct = nil
    end

    if type(layer._guideNodes) == "table" then
        for i, v in pairs(layer._guideNodes) do
            if v and v._feedbackAct then
                v:stopAction(v._feedbackAct)
                v._feedbackAct = nil
                v:scaleX(v._sclX):scaleY(v._sclY)
            end
        end
        layer._guideNodes = nil
    end
end

-- 获取语音时长
function M:getVoiceTime(voice)
    if not voice then return 0 end
    
    -- 单条语音编号转化为语音列表处理
    if type(voice) == "string" then
        voice = {voice}
    end
    local voiceTime = 0
    for i, v in pairs(voice) do
        voiceTime = voiceTime + soundVoice:T(v)
    end

    return voiceTime
end

-- 播放语音队列（语音回调衔接，stopNowSound即可中断）
---@param voice string/table 语音名称/语音名称列表
---@param callback function 语音结束回调
function M:playVoiceSequence(voice, callback)
    if not voice then return end
    soundVoice:stopNowSound()
    
    -- 单条语音编号转化为语音列表处理
    if type(voice) == "string" then
        voice = {voice}
    end

    local curIndex = 0
    local function playNext()
        curIndex = curIndex + 1
        local handle = soundVoice["playEffect"..voice[curIndex]](soundVoice)

        if curIndex < #voice then
            sound.setFinishCallback(handle, playNext)
        else
            sound.setFinishCallback(handle, callback)
        end
    end

    playNext()
end

-- 缩放反馈1（轮流缩放）
function M:feedback1(guideNodes, snd, strength)
    if not guideNodes then return end
    if type(guideNodes) ~= "table" then
        guideNodes = {guideNodes}
    end

    for i, v in pairs(guideNodes) do
        if v and not tolua.isnull(v) then
            -- 缩放强度
            local strength = strength or v._strength or 1.2
            v._sclX = v._sclX or v:scaleX()
            v._sclY = v._sclY or v:scaleY()
            v._feedbackAct = A.line({
                {"delay", (i - 1) * 0.25},
                {"fn", function ()
                    if snd then
                        soundEffect["playEffect"..snd](soundEffect)
                    end
                end},
                {"scaleTo", 0.15, v._sclX * strength, v._sclY * strength},
                {"scaleTo", 0.1, v._sclX, v._sclY},
            }):at(v)
        end
    end
end

-- 缩放反馈2（同时缩放两次）
function M:feedback2(guideNodes, snd, strength)
    if not guideNodes then return end
    if type(guideNodes) ~= "table" then
        guideNodes = {guideNodes}
    end

    for i, v in pairs(guideNodes) do
        if v and not tolua.isnull(v) then
            -- 缩放强度
            local strength = strength or v._strength or 1.2
            v._sclX = v._sclX or v:scaleX()
            v._sclY = v._sclY or v:scaleY()
            v._feedbackAct = A.cycle({
                {"fn", function ()
                    if i == 1 and snd then
                        soundEffect["playEffect"..snd](soundEffect)
                    end
                end},
                {"scaleTo", 0.15, v._sclX * strength, v._sclY * strength},
                {"scaleTo", 0.1, v._sclX, v._sclY},
            }, 2):at(v)
        end
    end
end

-- 缩放反馈3（随机一件物品缩放两次）
function M:feedback3(guideNodes, snd, strength)
    if not guideNodes then return end
    if type(guideNodes) ~= "table" then
        guideNodes = {guideNodes}
    end

    local v = T.random(guideNodes)
    -- 缩放强度
    local strength = strength or v._strength or 1.2
    v._sclX = v._sclX or v:scaleX()
    v._sclY = v._sclY or v:scaleY()
    v._feedbackAct = A.cycle({
        {"fn", function ()
            soundEffect["playEffect"..snd](soundEffect)
        end},
        {"scaleTo", 0.15, v._sclX * strength, v._sclY * strength},
        {"scaleTo", 0.1, v._sclX, v._sclY},
    }, 2):at(v)
end

---------------------------------------------------------------------------

--[[
    调用示例
    -- 手指点击引导
    CommonFun:openGuideHand({
        delayTime = 0,
        voice     = "voice1" or {"voice1", "voice2"...},
        handPos   = pos1,
    })
    -- 手指滑动引导（语音引导1次后，后续只做手指反馈不播语音）
    CommonFun:openGuideHand({
        voiceGuideLimit = 1,
        time          = 10,
        delayTime     = delayTime,
        voice         = "ven293003006",
        handPos       = handPos,
        movePos       = movePos,
    })
    -- 手指划圈引导
    CommonFun:openGuideHand({
        voiceGuideLimit = 1
        delayTime     = 0,
        voice         = "voice1" or {"voice1", "voice2"...},
        handPos       = pos1,
        centerPos     = pos2,
        angle         = -360,
        fn            = function ()
            item:one({"rotateBy", 1.5, 360})
        end
    })
    -- 停止手指引导
    CommonFun:stopGuideHand()
]]
-- 手指引导
function M:openGuideHand(params)
    -- 挂载引导的节点
    local layer      = params.layer or D.getRunningScene():getMainLayer()
    -- 引导次数限制
    local voiceGuideLimit = params.voiceGuideLimit or math.huge
    -- 达到引导语音次数限制后，是否继续做无语音的引导反馈
    local noVoiceGuideAfterLimit = ifnil(params.noVoiceGuideAfterLimit, true)
    -- 是否累加引导次数
    local addGuideNum = ifnil(params.addGuideNum, true)
    -- 无操作引导间隔时间
    local time	     = params.time or 3
    -- 引导语音（单条语音：string / 语音列表：table）
    local voice      = params.voice
    -- 语音时长
    local voiceTime  = CommonFun:getVoiceTime(voice)
    -- 首次播语音标识
    local isFirst    = true
    -- 首次播语音时的回调
    local firstFn    = params.firstFn
    -- 开始播语音时的回调
    local fn         = params.fn
    -- 播语音结束时的回调
    local endFn      = params.endFn
    -- 是否需要拖尾
    local needStreak = ifnil(params.needStreak, true)
    -- 层级
    local zor        = params.zor or 99999
    -- 手的位置
    local handPos    = params.handPos or ccp(V.w_2, V.h_2)
    -- 手移动的目标位置（滑动引导，不传则默认为点击引导）
    local movePos    = params.movePos or handPos
    -- 圆心位置（划圈引导）
    local centerPos  = params.centerPos
    -- 旋转角度（划圈引导）
    local angle      = params.angle
    -- 手移动的时长
    local moveTime   = params.moveTime

    -- 起始延迟时间（不能大于间隔时间）
    local delayTime1 = params.delayTime or time
    delayTime1 = delayTime1 < time and delayTime1 or time
    -- 末尾延迟时间（间隔时间和起始延迟时间的差值，以确保间隔时间不受起始延迟时间影响）
    local delayTime2 = time - delayTime1

    if layer._guideHand then return end

    local imgPre = "common/mouldtool/handguide/"
    layer._guideHand = D.img(imgPre.."1.png"):to(layer, zor):a(ccp(0.1, 0.9)):opacity(0):p(handPos):hide()

	layer._guideHand:cycle({
		{"delay", delayTime1},
		{"fn", function()
	        -- 手移动动作
	        local moveHandAct
	        if centerPos and angle then
	        	moveTime = params.moveTime or 1.5
	        	-- 划圈引导动作
	        	moveHandAct = A.actionCircleMove({
	        	    pointCenter = centerPos,
	        	    angle 		= angle,
	        	    time 		= moveTime,
	        	})
	        elseif movePos then
	        	moveTime = params.moveTime or (handPos == movePos and 0) or 0.5
	        	-- 滑动引导动作
	        	moveHandAct = {"moveTo", moveTime, movePos}
	        end

            -- 手完整动作
		    layer._guideHand:display(imgPre.."1.png"):show():p(handPos)
            layer._guideHand:line({
		        {"fadeIn", 0.1},
		        {"image", imgPre, 3, 0.1},
		        {"fn", function()
		        	if needStreak then
		        		-- 加载拖尾  拖尾渐隐时间(秒), 最小的片段长度, 渐隐条带的宽度, 片段颜色值, 纹理图片的文件名。
                        local motionStreak = cc.MotionStreak:create(0.5, 1, 30, cc.c3b(255, 255, 255), imgPre.."light.png")
                        layer._motionStreak = cc.NodeExtend.extend(motionStreak):to(layer, zor - 1)
		        		layer._motionStreak:cycle({
		        			{"fn", function()
		        				if layer._motionStreak and not tolua.isnull(layer._motionStreak) then
		        					layer._motionStreak:setPosition(ccpAdd(layer._guideHand:point(), ccp(0, -25)))
		        				end
		        			end},
		        			{"delay", 1/60},
		        		})
		        	end
		        end},
		        moveHandAct,
		        A.reverse({"image", imgPre, 3, 0.2}),
                {"fn", function()
		        	if layer._motionStreak and not tolua.isnull(layer._motionStreak) then
		        		layer._motionStreak:remove()
		        		layer._motionStreak = nil
		        	end
		        end},
                {"fadeOut", 0.2},
            })
		end},
        {"fn", function ()
            -- 记录引导次数
            if addGuideNum then
                layer._guideNum = ifnil(layer._guideNum, 0) + 1
            end
            -- 播放语音
            CommonFun:playVoiceSequence(voice)
            -- 首次优先执行firstFn
            if isFirst then
                isFirst = false
                if firstFn then firstFn() return end
            end
            if fn then fn() end
        end},
        {"delay", math.max(voiceTime, 1.2)},
        {"fn", function ()
            if layer._guideNum and layer._guideNum >= voiceGuideLimit then
                CommonFun:stopGuideHand(layer)
                if noVoiceGuideAfterLimit then
                    params.voice = nil
                    params.delayTime = params.time
                    CommonFun:openGuideHand(params)
                end
            end
            if endFn then endFn() end
        end},
        {"delay", delayTime2},
	})
end

-- 停止手指引导
function M:stopGuideHand(layer)
    layer = layer or D.getRunningScene():getMainLayer()

	if layer._motionStreak and not tolua.isnull(layer._motionStreak) then
		layer._motionStreak:remove()
		layer._motionStreak = nil
	end

	if layer._guideHand and not tolua.isnull(layer._guideHand) then
		layer._guideHand:stopAllActions()
		layer._guideHand:remove()
		layer._guideHand = nil
	end
end

---------------------------------------------------------------------------

--[[
    调用示例
    -- 清晰过渡到模糊
    CommonFun:vagueShader({
        node      = node,
        zor       = 10,
        time      = 0.25,
        initSize  = 0,
        endSize   = 15,
    })
    -- 模糊过渡到清晰
    CommonFun:vagueShader({
        node      = node,
        zor       = 10,
        time      = 0.5,
        initSize  = 15,
        endSize   = 0,
    })
]]
-- 实时模糊渲染Shader
function M:vagueShader(params)
    params = params or {}
    -- 渲染对象
    local node       = params.node
    -- 父节点
    local parent     = params.parent or node:getParent()
    -- 层级
    local zor        = ifnil(params.zor, 999999)
    -- 过渡时长
    local time       = ifnil(params.time, 1)
    -- 初始模糊度
    local initSize   = ifnil(params.initSize, 0)
    -- 最终模糊度
    local endSize    = ifnil(params.endSize, 15)
    -- 设置帧率
    local fps        = ifnil(params.fps, 30)
    -- 每帧变化的模糊度
    local perSize    = (endSize - initSize) / (time * fps)
    -- 模糊渲染Shader文件
    local vert, frag = CommonFun:getVagueShaderFile()
    
    if node._updateVagueAct then
        -- 停止实时模糊渲染Shader
        self:stopVagueShader(node)
    end

    local glProgram = cc.GLProgram:createWithByteArrays(vert, frag)
    local glProgramState = cc.GLProgramState:getOrCreateWithGLProgram(glProgram)
    local spritePhoto = nil
    local win_size = cc.p(V.w, V.h)
    local render_texture = cc.RenderTexture:create(V.w, V.h)
    render_texture:begin()
    node:visit()
    render_texture:endToLua()
    local  photo_texture = render_texture:getSprite():getTexture()
    spritePhoto = cc.Sprite:createWithTexture(photo_texture)
    spritePhoto:addTo(parent, zor):pos(V.w_2, V.h_2):setAnchorPoint(cc.p(0.5, 0.5)):setScaleY(-1)
    spritePhoto:setGLProgram(glProgram)
    spritePhoto:setGLProgramState(glProgramState)

	node._updateVagueAct = A.cycle({
		{"fn", function()
            render_texture = cc.RenderTexture:create(V.w, V.h)
            spritePhoto:hide()
            render_texture:begin()
            node:visit()
            render_texture:endToLua()
            photo_texture = render_texture:getSprite():getTexture()
            spritePhoto:show()
            spritePhoto:setTexture(photo_texture)

            node._blurSize = ifnil(node._blurSize, initSize)

            -- 变模糊判断
            local judge1 = initSize < endSize and node._blurSize < endSize
            -- 变清晰判断
            local judge2 = initSize > endSize and node._blurSize > endSize

            if judge1 or judge2 then
                -- 设置模糊度
                node._blurSize = node._blurSize + perSize
                glProgramState:setUniformVec2("blurSize",{
                    x = node._blurSize,
                    y = -node._blurSize,
                })
            end
            if node._blurSize <= 0 then
                -- 停止实时模糊渲染
                CommonFun:stopVagueShader(node)
            end
		end},
		{"delay", 1/fps},
	}):at(node)
    node._spritePhoto = spritePhoto
    
    return spritePhoto
end

-- 停止实时模糊渲染Shader
function M:stopVagueShader(node)
    if node._updateVagueAct then
        node:stopAction(node._updateVagueAct)
        node._updateVagueAct = nil
    end
    if node._spritePhoto then
        node._spritePhoto:removeFromParent()
        node._spritePhoto = nil
    end
    if node._blurSize then
        node._blurSize = nil
    end
end

-- 获取模糊渲染Shader文件
function M:getVagueShaderFile()
    -- 顶点着色器
    local vert = [[
		attribute vec4 a_position;
        attribute vec2 a_texCoord;
        attribute vec4 a_color;
        #ifdef GL_ES
        varying lowp vec4 v_fragmentColor;
        varying mediump vec2 v_texCoord;
        #else
        varying vec4 v_fragmentColor;
        varying vec2 v_texCoord;
        #endif
        void main()
        {
            gl_Position = CC_PMatrix * a_position;
            v_fragmentColor = a_color;
            v_texCoord = a_texCoord;
        }
	]]
	-- 像素着色器
    local frag = [[
        #ifdef GL_ES
        precision mediump float;
        #endif
        varying vec4 v_fragmentColor;
		varying vec2 v_texCoord;
		uniform vec2 blurSize;
	
        void main()
        {
			vec4 sum = vec4(0.0);
			sum += texture2D(CC_Texture0, v_texCoord - 0.0004 * blurSize) * 0.05;
			sum += texture2D(CC_Texture0, v_texCoord - 0.0003 * blurSize) * 0.09;
			sum += texture2D(CC_Texture0, v_texCoord - 0.0002 * blurSize) * 0.12;
			sum += texture2D(CC_Texture0, v_texCoord - 0.0001 * blurSize) * 0.15;
			sum += texture2D(CC_Texture0, v_texCoord) * 0.16;
			sum += texture2D(CC_Texture0, v_texCoord + 0.0001 * blurSize) * 0.15;
			sum += texture2D(CC_Texture0, v_texCoord + 0.0002 * blurSize) * 0.12;
			sum += texture2D(CC_Texture0, v_texCoord + 0.0003 * blurSize) * 0.09;
			sum += texture2D(CC_Texture0, v_texCoord + 0.0004 * blurSize) * 0.05;

			gl_FragColor = sum * v_fragmentColor;
		}
    ]]

    return vert, frag
end

---------------------------------------------------------------------------

-- 多洞窥引导（RenderTexture动态过渡） #nodes 节点集合 #time 过渡时间
function M:guideHole(layer, nodes, time)
    -- 初始化
    for i, node in pairs(nodes) do
        -- 洞窥位置
        node._holePos = node._holePos or node:worldpoint()
        -- 起始缩放大小
        node._staScl  = node._staScl or 3
        -- 最终缩放大小
        node._endScl  = node._endScl or 0.6
        -- 初始化用于计算的变量
        node._curScl  = node._staScl
    end

    -- 调度器刷新，洞窥过渡效果
    local time = time or 0.25
    local fps  = 60
    local num  = time * fps
    local curOpacity = 0
    
    layer._guideHoleUpdate = A.cycle({
        {"delay", 1/fps},
        {"fn", function ()
            -- 生成用于创建洞窥纹理的信息，存放每个洞窥的位置、缩放大小
            local holesInfo = {}
            for i, node in pairs(nodes) do
                node._curScl = node._curScl - (node._staScl - node._endScl) / num
                table.insert(holesInfo, {pos = node._holePos, scale = node._curScl})
            end
            -- 创建洞窥纹理
            local texture = CommonFun:createHoleTexture(layer, holesInfo)
            -- 计算渐变透明度
            curOpacity = curOpacity + 255 / num

            if not layer._guideHole then
                layer._guideHole = D.img(texture):to(layer, 999)
            end
            layer._guideHole:setTexture(texture):p(V.w_2, V.h_2):scaleY(-1):opacity(curOpacity)
        end}
    }, math.ceil(num)):at(layer)
end

-- 获取洞窥遮罩的纹理 #holesInfo 用于创建洞窥纹理的信息，存放每个洞窥的位置、缩放大小
function M:createHoleTexture(layer, holesInfo)
    -- 创建RenderTexture(涂抹区域)
    local render = cc.NodeExtend.extend(cc.RenderTexture:create(V.w, V.h)):to(layer, 999):p(V.w_2, V.h_2)
	-- 遮罩
	local mask	= U.loadNodeMask({
        contentSize = cc.size(V.w, V.h),
        opacity     = 180,
    }):a(ccp(0.5, 0)):p(V.w_2, 0):unbindTouch()
	mask:retain()
    -- 洞窥
    local holes = {}
    for i, info in pairs(holesInfo) do
        local hole = D.img("common/click/hole.png"):p(info.pos):scale(info.scale)
        hole:retain()
        hole:setBlendFunc(GL_ZERO, GL_ONE_MINUS_SRC_ALPHA)
        table.insert(holes, hole)
    end
	-- 绘制事件
    render:begin()
	mask:visit()
    for i, hole in pairs(holes) do
        hole:visit()
    end
	render:endToLua()

    -- 获取纹理
    local texture = render:getSprite():getTexture()
    
    -- 删除用于绘制的临时节点
    render:remove()
    mask:remove()
    for i, hole in pairs(holes) do
        hole:remove()
    end

    return texture
end

-- 移除多洞窥引导
function M:removeGuideHole(layer)
    -- 移除洞窥调度器
    if layer._guideHoleUpdate then
        layer:stopAction(layer._guideHoleUpdate)
        layer._guideHoleUpdate = nil
    end
    -- 淡出并移除洞窥遮罩节点
    if layer._guideHole and not tolua.isnull(layer._guideHole) then
        layer._guideHole:line({
            {"fadeOut", 0.15},
            {"fn", function ()
                layer._guideHole:remove()
                layer._guideHole = nil
            end}
        })
    end
end

---------------------------------------------------------------------------

-- 绘制矩形的边框线
function M:createBorders(node, c, color)
	-- 矩形宽高
	local w, h  = node:cw(), node:ch()
	-- 线条粗细
	local c 	= c or 1
	-- 线条颜色
	local color = color or COLOR3_BLACK

	local info = {
		{size = cc.size(w, c), pos = ccp(w/2, h)},
		{size = cc.size(w, c), pos = ccp(w/2, 0)},
		{size = cc.size(c, h), pos = ccp(0, h/2)},
		{size = cc.size(c, h), pos = ccp(w, h/2)},
	}

	node._borders = {}
	for i, v in pairs(info) do
		local line = U.loadNodeMask({
			contentSize = v.size,
			color       = color,
			opacity     = 255
		}):to(node, 999):p(v.pos):unbindTouch()
		table.insert(node._borders, line)
	end
end

---------------------------------------------------------------------------

-- 拍照导图1（RenderTexture）
function M:takePhoto(node)
    local size = node:size()
    -- 创建RenderTexture对象
    local renderTexture = cc.RenderTexture:create(size.width, size.height)
    -- 开始捕捉节点内容
    renderTexture:begin()
    -- 绘制指定的节点及其子节点到RenderTexture上
    node:visit()
    -- 结束捕捉
    renderTexture:endToLua()
    -- 保存到文件
    local fileName = "screenshot.png"
    local fullPath = cc.FileUtils:getInstance():getWritablePath()..fileName
    if renderTexture:saveToFile(fileName, cc.IMAGE_FORMAT_PNG) then
        print("Image saved to", fullPath)
    end
end

-- 拍照导图2（bb.UShot）
function M:takePhoto(node)
    local cw, ch = node:cw(), node:ch()
    local path = SO.shot({
        renderBackground = false,
        rect   = rectForPointSize(ccp(cw/2, ch/2), cc.size(cw, ch)),
        nodes  = {node},
    })
end

---------------------------------------------------------------------------

-- 判断是否每日首次
function M:judgeDateFirst()
	if not ST.getString("LAST_GAME_DATE") then
		ST.setString("LAST_GAME_DATE", "0000-00-00")
	end
	if ST.getString("LAST_GAME_DATE") ~= os.date("%Y-%m-%d") then
		ST.setString("LAST_GAME_DATE", os.date("%Y-%m-%d"))
		return true
	else
		return false
	end
end

---------------------------------------------------------------------------

-- 获取两个形状的最小正角度差 #angleInterval 角度间隔（例：正方形每旋转90度看起来相同，所以正方形角度间隔为90度）
function M:getMinAngleDiff(angle1, angle2, angleInterval)
    angleInterval = ifnil(angleInterval, 360)
    local angleDiff = math.abs(angle1 - angle2) % angleInterval
    local minAngleDiff = math.min(angleDiff, angleInterval - angleDiff)
    return minAngleDiff
end

-- 获取节点的数学角度，且为非负数最小值
function M:getNodeAngle(node)
    local angle = -node:rotate()
    angle = angle % 360
    return angle
end

---------------------------------------------------------------------------
----------------------------------通用动作----------------------------------
---------------------------------------------------------------------------

-- 线段伸展效果
function M:sproutLines(layer, nodes, speed)
    local speed = ifnil(speed, 2)
    local fps = 60
    local progress = 0
    local act = A.cycle({
        {"fn", function ()
            progress = progress + 1/fps
            for i, v in pairs(nodes) do
                v._initW = ifnil(v._initW, v:cw())
                v:opacity(255)
                v:setTextureRect(cc.rect(0, 0, v._initW * progress, v:ch()))
            end
        end},
        {"delay", 1/fps/speed},
    }, fps):at(layer)
    return act
end

---------------------------------------------------------------------------

-- 开始下雨
function M:startRain(layer, num1, num2, speed, isPlaySnd)
    num1  = num1 or 5
    num2  = num2 or 7
    speed = speed or 1
    isPlaySnd = ifnil(isPlaySnd, true)

	if layer._rainAct then return end

	layer._rains = {}
	layer._rainAct = A.cycle({
		{"fn", function ()
			self:rain(layer, num1, num2)
		end},
		{"delay", 0.25/speed},
	}):at(layer)

    if not layer._rainSnd and isPlaySnd then
        -- 播放音效[sfx293105020]下雨声
        layer._rainSnd = soundEffect:playEffectsfx293105020()
    end
end

-- 下雨
function M:rain(layer, num1, num2)
	-- 每排生成几道雨水
	local count = math.random(num1, num2)
	for i = 1, count do
		local pos = ccp(V.w*1.5 * i / count, V.h + 100)
		pos = ccpAdd(pos, ccp(math.random(-60, 60), math.random(-60, 60)))
		local endPos = ccpAdd(pos, ccp(-V.h, -(V.h + 100)))
		local scl = math.random(7, 9) / 10
		local rain = D.img("opening/effect/rain/"..math.random(1, 3)..".png"):to(layer, 99)
		:rotate(35):p(pos):scale(scl):opacity(200)
		table.insert(layer._rains, rain)
		rain:line({
			{"delay", i%2 == 0 and 0.05 or 0},
			{"easing", "sineIn", {"moveTo", 0.8, endPos}},
			{"fn", function ()
				T.removeOrder(layer._rains, rain)
				rain:remove()
			end}
		})
	end
end

-- 停止下雨 #isStopSnd 是否停止音效 #isRemoveAll 是否立即全部移除
function M:stopRain(layer, isStopSnd, isRemoveAll)
    isStopSnd = ifnil(isStopSnd, true)

	if not layer._rainAct then return end

    layer:stopAction(layer._rainAct)
    layer._rainAct = nil


    if layer._rainSnd and isStopSnd then
        sound.voiceFadeTo(layer._rainSnd, 0, 1)
        layer._rainSnd = nil
    end

    if isRemoveAll then
        for i, v in pairs(layer._rains) do
            v:remove()
        end
    end
    layer._rains = {}
end

---------------------------------------------------------------------------

-- 拼装放置效果
function M:place()
	local pos = ccp(100, 100)
	self:line({
		{"union", {
			{"moveTo", 0.25, ccp(pos.x, pos.y + 100)},
			{"scaleTo", 0.25, self._scale*1.3},
			{"rotateTo", 0.25, 0},
		}},
		{"union", {
			{"moveTo", 0.02, pos},
			{"scaleTo", 0.02, self._scale},
		}},
		{"hide"},
	})
end

-- 震动
function M:quake(layer, speed, offsetP, fn)
    speed = speed or 1
    offsetP = ifnil(offsetP, ccp(0, -70))
	layer:line({
		{"moveBy", 0.1/speed, offsetP},
		{"easing", "ElasticOut", {"moveBy", 0.5/speed, ccp(-offsetP.x, -offsetP.y)}, 0.2},
        {"fn", function ()
            if fn then fn() end
        end}
    })
end

-- 平滑可控的屏幕震动效果
function M:shakeAct(params)
    params = params or {}
    -- 节点
    local node      = params.node
    -- 震动总时长
    local totalTime = params.time or 1
    -- 震动速度
    local speed     = params.speed or 1
    -- 震动强度
    local strength  = params.strength or 1
    -- 节点的原坐标
    local oldPos    = node:point()
    -- 剩下的时长
    local time      = totalTime
    -- 每次震动的时长
    local t         = 1/15/speed
    -- 动作方法
    local actFn
    actFn = function (strength)
        node._shakeAct = A.line({
            {"moveBy", t/4, ccp(10 * strength, 0)},
            {"moveBy", t/4, ccp(0, -10 * strength)},
            {"moveBy", t/4, ccp(-10 * strength, 0)},
            {"moveBy", t/4, ccp(0, 10 * strength)},
            {"fn", function ()
                time = time - t
                -- 时间到就停止
                if time <= 0 then
                    node._shakeAct = nil
                    node:p(oldPos)
                    return
                end
                -- 快结束时幅度变小
                if time/totalTime <= 1/3 then
                    strength = strength*4/5
                end
                actFn(strength)
            end}
        }):at(node)
    end
    -- 执行动作
    actFn(strength)
end

---------------------------------------------------------------------------

-- 植物呼吸动作
function M:breathe1(node, strength, speed)
    local strength = strength or 1
    local speed    = speed or 1
    local time     = math.random(5, 8)/10/speed

    node:cycle({
        {"skewTo",  time, 3 * strength, 0},
        {"skewTo",  time, 0 * strength, 0},
        {"skewTo",  time, -3 * strength, 0},
        {"skewTo",  time, 0 * strength, 0},
    })
end

-- 缩放呼吸动作
function M:breathe2(node, strength, speed)
    local scale    = node:scaleX()
    local strength = strength or 1
    local speed    = speed or 1
    local time     = math.random(15, 20)/10/speed

    node:cycle({
        {"scaleTo", time, (1 + 0.1 * strength) * scale},
        {"scaleTo", time, scale},
    })
end

-- 云朵呼吸
function M:breathe3(node, strength, speed)
    local scale    = node:scaleX()
    local strength = strength or 1
    local speed    = speed or 1
    local offsetX  = math.random(20, 40)/10 * strength
    local time     = math.random(30, 40)/10/speed

    node:cycle({
        {"union", {
            {"scaleto", time, scale * 1.2},
            {"moveBy",  time, ccp(offsetX, 0)},
        }},
        {"union", {
            {"scaleto", time, scale},
            {"moveBy",  time, ccp(-offsetX, 0)},
        }},
    })
end

-- 藤条呼吸动作
function M:breathe4(node, strength, speed)
    local scale    = node:scaleX()
    local strength = strength or 1
    local ratio    = 1 + 0.1 * strength
    local speed    = speed or 1
    local time     = math.random(50, 65)/100/speed

	node:cycle({
		{"skewto", time, -3 * ratio, 0},
		{"skewto", time, 0, 0},
		{"skewto", time, 3 * ratio, 0},
		{"skewto", time, 0, 0},
	})
    node:cycle({
		{"scaleto", time, scale},
		{"scaleto", time, scale, scale * ratio},
	})
end

-- 泡泡呼吸动作
function M:breathe5(node, strength, speed)
    local scaleX   = node:scaleX()
    local scaleY   = node:scaleY()
    local strength = strength or 1
    local speed    = speed or 1
    local time     = math.random(10, 14)/10/speed

    node:cycle({
        {"easing", "sineInOut", {"union", {
            {"moveBy", time, ccp(0, 5)},
            {"scaleTo", time, 0.95/strength*scaleX, 1.05*strength*scaleY},
        }}},
        {"union", {
            {"moveBy", time, ccp(0, -5)},
            {"scaleTo", time, 1.05*strength * scaleX, 0.95/strength*scaleY},
        }},
    })
end

-- 上下轻微移动缩放呼吸动作
function M:breathe6(node, strength, speed)
    local scale    = node:scaleX()
    local strength = strength or 1
    local speed    = speed or 1
    local time     = math.random(15, 20)/10/speed

    node:cycle({
        {"easing", "sineIn", {"union", {
                {"moveBy", time, ccp(0, 5 + strength)},
                {"scaleTo", time, (1 + 0.1 * strength) * scale},
            },
        }},
        {"easing", "sineIn", {"union", {
                {"moveBy", time, ccp(0, -5 - strength)},
                {"scaleTo", time, scale},
            }},
        },
    })
end

-- 上下轻微移动呼吸动作
function M:breathe6(node, strength, speed)
    local scale    = node:scaleX()
    local strength = strength or 5
    local speed    = speed or 1.5
    local time     = math.random(15, 20)/10/speed

    node:cycle({
        {"easing", "sineIn", {"moveBy", time, ccp(0, 5 + strength)}},
        {"easing", "sineIn", {"moveBy", time, ccp(0, -5 - strength)}},
    })
end

---------------------------------------------------------------------------
-----------------------------------待整理-----------------------------------
---------------------------------------------------------------------------

--[[
    调用示例
    local info = {
    	-- 一棵树
    	{
            tag = 1, pos = ccp(1887.9, 464.5),
            bodyPoints = { ccp(-2, 5), ccp(-2, 20), ccp(80, 20), ccp(80, 5) }
    	},
    	-- 树林
    	{
            tag = 14, pos = ccp(2111.4, 537.4), zor = 1,
            multBodyPoints = {
    	        { ccp(0, 5), ccp(-100, 100), ccp(-100, 640), ccp(300, 640), ccp(300, 5) },
    	        { ccp(-100, 475), ccp(-280, 475), ccp(-320, 510), ccp(-320, 640), ccp(-100, 640) },
            }
    	},
    }
    self._plants = self:createNodes({
    	info   = info,
    	imgPre = self._imgPre.."plant/",
    })
]]
-- 创建物体节点
function M:createNodes(params)
	params = params or {}
	local info   = params.info
	local imgPre = params.imgPre
	local nodes = {}
	for i, v in pairs(info) do
		local tag = v.tag
		local pos = v.pos
		local sca = v.sca or 1
		local anc = v.anc or ccp(0.5, 0)
		local zor = v.zor or (10000 - pos.y) * 10
        -- 物体节点
		local node = D.img(imgPre..tag..".png"):to(self, zor):p(pos):scale(sca):a(anc)
		table.insert(nodes, node)
		-- 给物体节点创建刚体
		if v.bodyPoints or v.multBodyPoints then
			self:createNodeBody({
				node 		   = node,
				bodyPoints 	   = v.bodyPoints,
				multBodyPoints = v.multBodyPoints,
			})
		end
	end
	return nodes
end

-- 创建物体的刚体
function M:createNodeBody(params)
	params = params or {}
	-- 绑定的节点
	local node = params.node
	-- 一个刚体的点集
	local bodyPoints 	 = params.bodyPoints
	-- 多个刚体的点集
	local multBodyPoints = params.multBodyPoints
	
	-- 创建刚体的方法
	local createFn = function (points)
		node._body = ZBox2D.createBody({
			userData      = node,
			-- 坐标
			pos           = node:point(),
			-- 静态刚体
			type 		  = b2_staticBody,
			-- 固定角度
			fixedRotation =  true,
			shape         = {
				{
					shapeType = EShape.POLYGON,
					points 	  = points
				},
			},
		})
	end

	if bodyPoints then
		createFn(bodyPoints)
	elseif multBodyPoints then
		for i, v in pairs(multBodyPoints) do
			createFn(v)
		end
	end
end

---------------------------------------------------------------------------

-- 尾迹寻踪
function M:followMove()
    for i, v in pairs(self._followRoles) do
		if v and not tolua.isnull(v) then
			-- 被跟随的角色
			local role = i == 1 and self._role or self._followRoles[i - 1]
			-- 记录轨迹
			table.insert(v._moveTrackTab, {
				-- 坐标
				pos = ccpAdd(role:point(), ccp(0, -1)),
				-- 是否镜像
				isFlipX = role._bone:isFlipX(),
			})

			local max, index = 20, 1
			if #v._moveTrackTab > max then
				table.remove(v._moveTrackTab, 1)
				if v._moveTrackTab[index] then
					local pos 	  = v._moveTrackTab[index].pos
					local isFlipX = v._moveTrackTab[index].isFlipX
					v:p(pos)
					v._bone:flipX(isFlipX)
				end
			end
		end
    end
end

-- 开启移动监听
function M:startMoveSchedule()
    if self._moveSchedule then return end
    self._moveSchedule = A.cycle({
        {"delay", 1/60},
        {"fn", function()
            self:followMove()
        end},
    }):at(self)
end

-- 关闭移动监听
function M:stopMoveSchedule()
    if not self._moveSchedule then return end
    self:stopAction(self._moveSchedule)
    self._moveSchedule = nil
end

---------------------------------------------------------------------------

-- 旋转物体区域限制demo
function M:touchMoveRotateLimitDemo()
    local scene, layer = game:enterDemoScene()
    local rect  = U.loadNodeMask({
    	contentSize	= cc.size(200, 100),
    	color		= ccc3(255, 255, 255),
    	opacity		= 100
    }):to(layer):pc():bindTouch()
    tools:setRotate(rect)
    local pos = {
    	ccp(0, 0), ccp(200, 0), ccp(100, 100)
    }
    local t = {}
    for i, v in ipairs(pos) do
    	local node = D.img("common/beta.png"):to(rect):p(v):scale(0.2)
    	table.insert(t, node)
    end

    function rect:onTouchBegan(x, y)
    	rect:p(x, y)
    	return true
    end

    function rect:onTouchMoved(x, y)
    	rect:p(x, y)
    	for i,v in ipairs(t) do
    		local wpos = v:worldpoint()
    		if wpos.x < 0 then
    			rect:px(rect:px() - wpos.x)
    		elseif wpos.x > V.w then
    			rect:px(rect:px() - (wpos.x - V.w))
    		end
    		if wpos.y < 0 then
    			rect:py(rect:py() - wpos.y)
    		elseif wpos.y > V.h then
    			rect:py(rect:py() - (wpos.y - V.h))
    		end
    	end
    end
end

---------------------------------------------------------------------------
----------------------------------公共方法----------------------------------
---------------------------------------------------------------------------

-- 可视化调试节点锚点
function M:bindTouchAnchorLocate(parent)
    local box = parent:getBoundingBox()
    local node = U.loadNodeMask({
        contentSize = cc.size(5, 5),
        color = ccc3(0, 255, 0)
        }):to(parent, 9999):bindTouch():opacity(255)
        :p(parent:cw() * parent:a().x, parent:ch() * parent:a().y)  
    node:setTouchCascadeDetected(true)
    local tools = self
    function node:onTouchBegan(x, y, touches)
        local pos = parent:convertToNodeSpace(ccp(x, y))
        node:p(pos)
        return true
    end
    function node:onTouchMoved(x, y, touches)
        local pos = parent:convertToNodeSpace(ccp(x, y))
        node:p(pos)
    end
    function node:onTouchEnded(x, y, touches)
        local pos = parent:convertToNodeSpace(ccp(x, y))
        node:p(pos)
        local anchor = ccp(pos.x / parent:cw(), pos.y / parent:ch())
        print(string.format("当前锚点:  ccp(%.2f, %.2f)",anchor.x, anchor.y))
    end
    return parent
end

-- 更换锚点，保持位置不变
function M:changeAnchorP(node, newAP)
    local dx    = newAP.x * node:cw()
    local dy    = newAP.y * node:ch()
    local offset    = node:convertToWorldSpace(ccp(dx, dy))
    local pos       = node:getParent():convertToWorldSpace(node:point())
    offset          = ccpSub(offset, pos)

    node:px(node:px() + offset.x)
    node:py(node:py() + offset.y)
    node:a(newAP)
end

-- 重置父节点
function M:resetParent(node, parent, order)
    -- 层级
    order = ifnil(order, 10)
    -- 坐标
    local pos           = nil
    -- 缩放大小
    local scaleSizeX     = 1
    local scaleSizeY     = 1
    -- 旋转角度
    local rotateSize     = 0

    local nodeParent = node:getParent()
    local wPoint     = node:convertToWorldSpaceAR(ccp(0, 0))
    local nPoint     = parent:convertToNodeSpace(wPoint)

    scaleSizeX       = node:scaleX() * node:getParent():scaleX() / parent:scaleX()
    scaleSizeY       = node:scaleY() * node:getParent():scaleY() / parent:scaleY()
    rotateSize       = node:rotate() + node:getParent():rotate() - parent:rotate()

    node:retain() 
    node:removeFromParent()
    node:to(parent, order):p(nPoint):rotate(rotateSize)
    node:scaleX(scaleSizeX):scaleY(scaleSizeY)
    node:release()
end

-- 显示包围盒 
function M:loadHelp(node)
    local isCascade = node:isTouchCascadeDetected()
    -- 区域系数x
    local factorX   = 1.0
    -- 区域系数y
    local factorY   = 1.0
    -- 区域偏移x
    local offsetX   = 0
    -- 区域偏移y
    local offsetY   = 0
    if node:existsProperty("rectFactorX") then 
        factorX = tonumber(node:getProperty("rectFactorX"))
    end
    if node:existsProperty("rectFactorY") then 
        factorY = tonumber(node:getProperty("rectFactorY"))
    end
    if node:existsProperty("rectOffsetX") then 
        offsetX = tonumber(node:getProperty("rectOffsetX"))
    end
    if node:existsProperty("rectOffsetY") then 
        offsetY = tonumber(node:getProperty("rectOffsetY"))
    end
    local box = ND.getBoundingBox({ 
        node                = node, 
        isCascade           = isCascade, 
        isConvertToWorld    = isConvertToWorld,
        factorX             = factorX,
        factorY             = factorY,
        offsetX             = offsetX,
        offsetY             = offsetY,
    })
    local pos = node:convertToNodeSpace(ccp(box.x, box.y))
    local rect  = U.loadNodeMask({
        contentSize    = cc.size(box.width, box.height),
        color          = ccc3(125,0,0),
        opacity        = 100
    }):to(node):p(pos):a(ccp(0, 0)):unbindTouch()
    
    local rect  = U.loadNodeMask({
        contentSize    = node:getContentSize(),
        color          = ccc3(0,125,0),
        opacity        = 100
    }):to(node):p(0, 0):a(ccp(0, 0)):unbindTouch()
end

-- 横向Q弹动作
--[[
    node    :   [必选]执行动作对象
    amplitude:   [可选]强度
    time    :   [可选]时间
]]
function M:slowAction(node, time, amplitude, callback)
    if not node or tolua.isnull(node) then return end
    if node._slowAct then
        node:stopAction(node._slowAct)
        node._slowAct = nil
    end

    amplitude = amplitude or 1
    time      = time or 0.1

    local sclx = node:scaleX()
    local scly = node:scaleY()
    node._slowAct = A.line({
        {"scaleBy", time, 1 + 0.1 * amplitude, 1 - 0.1 * amplitude},
        {"scaleBy", time, 1 + 0.05 * amplitude, 1 - 0.05 * amplitude},
        {"scaleTo", time, sclx, scly},
        {"scaleBy", time, 1 + 0.05 * amplitude, 1 - 0.05 * amplitude},
        {"scaleTo", time, sclx, scly},
        {"fn", function()
            if callback then
                callback()
            end

            node._slowAct = nil
        end},
    }):at(node)
end

-- 猫咪添加旋转按钮方法
function M:setRotate(node)
    local aNode  = U.loadNodeMask({
        contentSize = cc.size(40, 40),
        color       = ccc3(255,0,0),
        opacity     = 255
    }):to(node, 999):p(node:cw()/2, node:ch()):bindTouch()
    U.loadLabelTTF({ 
        text        = "旋转", 
        fontSize    = 20, 
        color       = COLOR3_WHITE,
        position    = ccp(aNode:cw()/ 2, aNode:ch()/2),
    }):to(aNode)
    aNode._node = node
    node._setRotateNode = aNode
    -- 触控区域跟随副节点缩放
    function aNode:isTouchCascadeDetected()
        return true
    end
    function aNode:onTouchBegan(x, y)
        aNode._move = false
        aNode._startPos = ccp(x, y)
        aNode._startSc = node:scale()
        return true
    end
    function aNode:onTouchMoved(x, y)
        aNode._move = true
        local pos = node:convertToNodeSpace(ccp(x, y))
        aNode:p(pos)
        local angle = PT.quadAngle(node:worldpoint(), aNode:worldpoint())
        node:rotate(270 - angle)
    end
    function aNode:onTouchEnded(x, y)
        print(string.format("当前角度:  %.2f", aNode._node:rotate()))
    end
end

return M