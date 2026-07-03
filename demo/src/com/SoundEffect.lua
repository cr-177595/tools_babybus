local M = {}

--------------------------
-- 公共方法
--------------------------
-- 播放音效
function M:playSound(fileName, isCycle)
    local isCycle = ifnil(isCycle, false)
    local nowSound = sound.playSound("effect/".. fileName ..".mp3", isCycle)
	-- if nowSound == -1 then
	-- 	print("没有音效文件", fileName)
	-- else
	-- 	print("音效文件", fileName)
	-- end
    self._nowSound = nowSound
    return nowSound
end

-- 停止当前音效
function M:stopNowSound()
    if self._nowSound then 
        sound.stopSound(self._nowSound)
        self._nowSound = nil 
    end 
end

-- 音效淡出
function M:sndFadeOut(handler, time)
    time = time or 0.5
	sound.voiceFadeTo(handler, 0, time)
end

-- 音效淡入
function M:sndFadeIn(handler, time)
    time = time or 0.5
	sound.setVolume(handler, 0)
	sound.voiceFadeTo(handler, 1, time)
end

--------------------------
-- 通用音效
--------------------------
-- 示例 播放通用点击音效
function M:playEffect17901001()
    return self:playSound("17901001")
end
-- 播放音效[sfx14700001]点击
function M:playEffectsfx14700001()
	return self:playSound("sfx14700001")
end
-- 播放音效[sfx23305011]打钩键掉落音效
function M:playEffectsfx23305011()
    return self:playSound("sfx23305011")
end
-- 播放音效[sfx23305012]打钩键收起
function M:playEffectsfx23305012()
    return self:playSound("sfx23305012")
end
-- 播放音效[sfx293000047]打钩键出现
function M:playEffectsfx293000047()
	return self:playSound("sfx293000047")
end
-- 播放音效[sfx293000081]打勾按钮待机蓝色光圈音效
function M:playEffectsfx293000081()
	return self:playSound("sfx293000081")
end

return M