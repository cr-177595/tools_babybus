----------------------
-- 类
----------------------
local M = {}
M.TAG   = "sound"

-- 指定继承关系
setmetatable(M, { __index = function(table, key)
    return bb.SoundBase[key]
end})

----------------------
-- 公共参数
----------------------
-- [公共参数]
-- 常量
-- ..
local bgmusic = nil
-- [操作变量]
-- ..
-- 场景中需要暂停的声音
local scenesounds     = {}
-- 拍照场景音频集合
local takephotosounds = {}
-- 背景音乐集合
local backgroundmusics= {}

-- [工具方法][预加载]
local function preloadMusicBackground(fileName)
    M.preloadMusic("music/" .. fileName)
end

-- [工具方法][背景音乐]
local function playMusicBackground(fileName)
    -- audio.setMusicVolume(1)
    sound.playMusic("music/" .. fileName,true)
end

-- 卸载背景音
function M:unloadMusics()
  self.stopMusic(true)
end

-- 背景音乐淡出
function M:bgMusicFadeOut(time)
    time = time or 0.5
    -- 背景音乐淡出
    local bgMusic = sound.getMusicHandle()
    if bgMusic then
        sound.voiceFadeTo(bgMusic, 0, time)
    end
end

-- 背景音乐淡入
function M:bgMusicFadeIn(time)
    time = time or 0.5
    -- 背景音乐淡入
    local bgMusic = sound.getMusicHandle()
    if bgMusic ~= nil then
        sound.setVolume(bgMusic, 0)
        sound.voiceFadeTo(bgMusic, 1, time)
    end
end


-------------------------------------
-- 背景音乐
-------------------------------------
--[[
    调用示例
    -- 常规背景音乐调用
    function M:playMusic293207002()
        sound:playBgm({
            fileName    = "bgm293207002",
            fadeTime    = nil,
            isEffect    = false,
            isLoop      = false,
            ignoreSound = nil,
        })
    end
    -- 作为音效调用
    sound:playBgm({
        fileName    = "bgm293207002",
        fadeTime    = nil,
        isEffect    = true,
        isLoop      = false,
        ignoreSound = true,
    })
]]
-- 播放背景音乐
function M:playBgm(params)
    if not __GLOBAL_ENABLED_MUSIC__ then return end
    params = params or {}
    
    -- 文件名
    local fileName    = params.fileName
    -- 淡入时长（不传就直接播）
    local fadeTime    = params.fadeTime
    -- 是否作为音效播放
    local isEffect    = ifnil(params.isEffect, false)
    -- 是否循环
    local isLoop      = ifnil(params.isLoop, true)
    -- 是否切场景不被打断
    local ignoreSound = ifnil(params.ignoreSound, true)
    -- 完整播完一次回调
    local callback    = params.callback

    local bgm

    if isEffect then
        bgm = sound.playSound("music/"..fileName..".mp3", isLoop)
    else
        bgm = sound.playMusic("music/"..fileName..".mp3", isLoop)
    end

    if fadeTime then
        sound.setVolume(bgm, 0)
        sound.voiceFadeTo(bgm, 1, fadeTime)
    else
        sound.setVolume(bgm, 1)
    end

    if ignoreSound then
        sound.ignoreSound(bgm)
    end

    if callback then
        sound.setFinishCallback(bgm, callback)
    end

    sound["_"..fileName] = bgm
    sound._curBgm = bgm

    return bgm
end

--[[
    调用示例
    sound:stopBgm({
        fileName = "bgm293207002",
        fadeTime = 0.5,
    })
]]
-- 停止背景音乐
function M:stopBgm(params)
    params = params or {}
    -- 指定文件名
    local fileName = params.fileName
    -- 淡出时长（不传就直接停）
    local fadeTime = params.fadeTime

    -- 获取音乐句柄
    local bgm = fileName and sound["_"..fileName] or sound._curBgm
    if fadeTime then
        sound.voiceFadeTo(bgm, 0, fadeTime, nil, function()
            sound.stopSound(bgm)
        end)
    else
        sound.stopSound(bgm)
    end

    if fileName then
        sound["_"..fileName] = nil
    end
end

return M