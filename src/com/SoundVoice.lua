local M = {}

--------------------------
-- 公共方法
--------------------------
-- 播放音效
function M:playSound(fileName, isCycle)
    local isCycle = ifnil(isCycle, false)
    local nowSound = sound.playSound("effect/".. fileName ..".mp3", isCycle)
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

function M:playEffectdownloading()
	print("正在下载")
	return self:playSound("003")
end

TIME = {}
-- 获取时长
function M:getVoiceTime(fileName, t)
	--if TIME[fileName] then return TIME[fileName] end
    local t = t or 2
    local time = NV.soundDuration("effect/"..fileName..".mp3", t)
	TIME[fileName] = time
    return time
end
M.T = M.getVoiceTime

--------------------------
-- 语音
--------------------------
-- 播放配音[v147001]宝宝启蒙入门课
function M:playEffectv147001()
	return self:playSound("v147001")
end

return M