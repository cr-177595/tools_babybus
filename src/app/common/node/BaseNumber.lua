--[[

    Copyright (c) 2011-2025 baby-bus.com
    TODO:	数字基类
    Author: CR
    Date:   2025.06.13
    http://www.babybus.com/

]]

local M = classSprite("BaseNumber")

----------------------
-- 公共参数
----------------------
-- [常量]
-- ..

----------------------
-- 构造方法
----------------------
function M:ctor(params)
    -- [超类调用]
    M.super.ctor(self, params)

    -- 资源路径前缀
    self._imgPre = params.imgPre or "common/num/"
    -- 数字编号
    self._num    = params.num
    -- 颜色
    self._color  = params.color or ccc3(255, 255, 255)
    -- 尺寸
    self._size   = params.size
    -- 缩放系数
    self._scale  = params.scale or 1
    -- 是否直接显示
    self._isDisplay = ifnil(params.isDisplay, true)
end

----------------------
-- 节点渲染
----------------------
function M:onRender()
    -- [超类调用]
    M.super.onRender(self)

    if self._isDisplay then
        -- 加载显示
        self:loadDisplay()
    end
end

-- 加载显示
function M:loadDisplay()
    -- 子节点透明度跟随父节点(设父节点)
    self:setCascadeOpacityEnabled(true)
    -- 改变数字显示
    self:changeNum(self._num)
    -- 缩放
    self:scale(self._scale)

    return self
end

----------------------
-- 功能函数
----------------------
-- 设置尺寸
function M:setSize()
    if self._size then
        self:size(self._size)
    else
        local temp = D.img(self._imgPre.."0.png")
        local len = self._num < 10 and 1 or (self._num < 100 and 2 or 3)
        local w = temp:cw() * len
        local h = temp:ch()
        temp:remove()
        self:size(w, h)
    end
end

-- 改变数字显示
function M:changeNum(num)
    num = ifnil(num, self._num)
    self._num = num
    -- 设置尺寸
    self:setSize()

    if not self._nodes then
        self._nodes = {}
        for i = 1, 3 do
            local node = D.img(self._imgPre.."0.png"):to(self):color(self._color)
            table.insert(self._nodes, node)
        end
    end

    -- 百位数、十位数、个位数 存表
    local nums = {math.floor(self._num / 100), math.floor(self._num / 10) % 10, num % 10}
    -- 获取数字节点的坐标
    local posTab = self:getPosTab()

    for i, node in pairs(self._nodes) do
        node:p(posTab[i])
        node:display(self._imgPre..nums[i]..".png")
        -- 小于10隐藏百位和十位
        if num < 10 and i <= 2 then
            node:hide()
        -- 小于100隐藏百位
        elseif num < 100 and i == 1 then
            node:hide()
        else
            node:show()
        end
    end
end

-- 获取数字节点的坐标
function M:getPosTab()
    local w, h = self:cw(), self:ch()
    if self._num < 10 then
        return {ccp(w/2, h/2), ccp(w/2, h/2), ccp(w/2, h/2)}
    elseif self._num < 100 then
        return {ccp(w*1/4, h/2), ccp(w*1/4, h/2), ccp(w*3/4, h/2)}
    elseif self._num < 200 then
        return {ccp(w*0.12, h/2), ccp(w*0.45, h/2), ccp(w*0.8, h/2)}
    else
        return {ccp(w*1/6, h/2), ccp(w*1/2, h/2), ccp(w*5/6, h/2)}
    end
end

-- 切换资源路径
function M:changeImgPre(imgPre)
    self._imgPre = imgPre
    self:changeNum(self._num)
end

return M