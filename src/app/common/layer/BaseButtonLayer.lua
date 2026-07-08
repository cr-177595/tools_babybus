--[[

Copyright (c) 2012-2020 Baby-Bus.com
Author: cxy
Date: 2021-1-13

]]
--[[!--

场景层类，定义层相关操作方法及逻辑实现。

-   定义场景层功能方法。

]]

----------------------
-- 类 -- 按钮层基类
----------------------
local M = classLayerTouch("Button")


----------------------
-- 公共参数
----------------------
-- [常量]
-- ..
local scaleTime = 0.2
local scaleEnd 	= 1


-- [操作变量]
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
end








----------------------
-- 结点渲染
----------------------
--[[--

视图渲染，处理视图结点加载、事件绑定等相关操作

]]
function M:onRender()
    -- -- 加载返回按钮
    -- self:loadBackButton()
    -- -- 跳过按钮
    -- self:loadSkipBtn()
end


function M:loadTimeScaleButton()
    local posX   = V.w_2 - 300
    local posY   = V.h - 40
    local button = D.img("g/button/btn_play.png"):to(self, 22222):scale(0.75):p(posX, posY):bindTouch()

    function button:onTouchBegan(x, y)

        self:scale(0.5*0.8,0.1)
        return true
    end
    function button:onTouchEnded(x,y)
        if not self._setTime then
            cc.Director:getInstance():getScheduler():setTimeScale(6)
            self._setTime = true
            self:display("g/button/btn_pause.png")

        else
            cc.Director:getInstance():getScheduler():setTimeScale(1)
            self._setTime = false
            self:display("g/button/btn_play.png")
        end
        self:scale(0.5)
    end
end


function M:loadSkipBtn()
    local button = U.loadScaleButton({
        imagename   = "g/button/btn_backforward.png",       -- 按钮图片     
        parent      = self,                                 -- 父亲节点（选填)
        pos         = cc.p(getButtonX_Right(), V.h - 60), -- 位置(默认返回键位置)
        issubmit    = false                                 -- 是否只点击一次
    })
    self._skipButton = button

    -- 点击松手判断是否在按钮范围内
    function button:onTouchEnded(x, y)
        GLOBAL_TOUCH_LOCK = true
        A.line({
            {"easing","Out", {"scaleTo", scaleTime, scaleEnd},1},
            {"fn", function()
                if TH.isTouchInside(self, x, y) then
                    A.stopAll()
                    self:line({
                        {"delay", 1/30},
                        {"fn", function()
                            SceneController:enterNextMoudleScene(true)
                            -- 记录场景状态（玩一半不玩了）
                            local sceneName = string.sub(string.lower(self:getScene().name), 1, -6)
                            if SceneController._sceneState[sceneName] then
                                SceneController._sceneState[sceneName][1] = 1
                            end
                        end},
                    })
                else
                    GLOBAL_TOUCH_LOCK = false
                end
           end},
        }):at(self)
    end
end

-- 跳过按钮 各场景重写此方法
function M:btnSkipEvent()
    print("跳过按钮未重写")
end


-- 加载结点[快捷按钮]
function M:loadQuickBtn()
    local button = U.loadScaleButton({
        imagename 	= "common/beta.png",					-- 按钮图片     
        parent 		= self,									-- 父亲节点（选填)
        pos 		= cc.p(V.w_2 + 300, V.h - 38),	-- 位置(默认返回键位置)
        issubmit 	= false 								-- 是否只点击一次
        -- tabsound 	= "",								-- 点击音效
    }):scale(0.75)
    self._quickButton = button

    -- 点击松手判断是否在按钮范围内
    function button:onTouchEnded(x, y)
        GLOBAL_TOUCH_LOCK = true
        A.line({
            {"easing","Out", {"scaleTo", scaleTime, scaleEnd * 0.75},1},
            {"fn", function()
				GLOBAL_TOUCH_LOCK = false
				if TH.isTouchInside(self, x, y) then
					CUtil:enterSceneWithLoadMould("quick")
				end
           end},
        }):at(self)
    end
end

-- 加载返回按钮
function M:loadBackButton()
	local button = U.loadScaleButton({
        imagename 	= "g/button/btn_back.png",			-- 按钮图片
        parent 		= self,								-- 父亲节点（选填)
        pos 		= cc.p(getButtonX_Left(),V.h - 60),	-- 位置(默认返回键位置)
        issubmit 	= false,							-- 是否只点击一次
    })

    self._backButton = button

    -- 点击松手判断是否在按钮范围内
    function button:onTouchEnded(x, y)
        GLOBAL_TOUCH_LOCK = true
        A.line({
            {"easing","Out", {"scaleTo", scaleTime, scaleEnd},1},
            {"fn", function()
				if TH.isTouchInside(self, x, y) then
                    A.stopAll()
                    self:line({
                        {"delay", 1/30},
                        {"fn", function()
                            self:getParent():btnBackEvent()
                        end},
                    })
                else
                    GLOBAL_TOUCH_LOCK = false
				end
           end},
        }):at(self)
    end
end

-- 点击返回键事件
function M:btnBackEvent()
    -- 记录场景状态（玩一半不玩了）
    local sceneName = string.sub(string.lower(self:getParent().name), 1, -6)
    if SceneController._sceneState[sceneName] then
        SceneController._sceneState[sceneName][1] = 1
    end

    CUtil:enterSceneWithLoadMould("select", {fromSceneName = self:getParent().name})
end


-- 广告区域
function M:loadAdArea()
    local mask = U.loadNodeMask({
        contentSize = cc.size(576, 76), 
        color       = COLOR3_GREY,
        opacity     = 80
    }):to(self, -1):anchor(cc.p(0.5, 1)):p(V.w_2, V.h)
    mask:cycle({
        {"delay", 0.1},
        {"fn", function()
            if IS_AD_ON then
                mask:show()
            else
                mask:hide()
            end
        end},
    })
end


----------------------
-- 结点析构
----------------------
function M:onDestructor()
    -- [超类调用]
	M.super.onDestructor(self)
end

function M:onExitTransitionStart()
    -- R.removeAllTextures()
end

return M