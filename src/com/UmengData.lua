local M = {}

--------------------------
-- 自定义采集
--------------------------
-- 首页-play键 示例
function M.recordakc001()
    DA.sendEventWithAge("akc001", "", "首页-play键")
end 

--[友盟]bbqmrmk001
function M.recordbbqmrmk001()
    DA.sendDataStatistics("bbqmrmk001", "PLAY键点击")
end

--[友盟]bbqmrmk002
function M.recordbbqmrmk002()
    DA.sendDataStatistics("bbqmrmk002", "选择界面")
end

-- 场景名、模块信息转换
local moudle = {
    colorclassify   = {"2颜色", "3颜色分类"},
    colorjigsaw     = {"2颜色", "2颜色匹配"},
    colorpaint      = {"2颜色", "1认颜色"},
    sizematch       = {"3大小", "1大小匹配"},
    sizepair        = {"3大小", "3大小配对"},
    sizepuzzle      = {"3大小", "2大小拼图"},
    numline         = {"4数字", "3连数字"},
    numpuzzle       = {"4数字", "1认数字"},
    numwrite        = {"4数字", "2写数字"},
    shapefeed       = {"1形状", "2形状匹配"},
    shapeline       = {"1形状", "1认形状"},
    shapepuzzle     = {"1形状", "3形状组合"},

    illustrated     = {"5图鉴", "1图鉴"}
}

-- 一进入该模块界面就发送（包括在选择界面主动点击和在游戏界面自动跳转的）
-- [友盟]bbqmrmk003 
-- 二级明细 1形状，2颜色，3大小，4数字
-- 三级明细
-- 1形状：1认形状，2形状匹配，3形状组合
-- 2颜色：1认颜色，2颜色匹配，3颜色分类
-- 3大小：1大小匹配，2大小拼图，3大小配对
-- 4数字：1认数字，2写数字，3连数字
function M.recordbbqmrmk003(sceneName)
    sceneName = S.lower(sceneName)
    if not moudle[sceneName] or sceneName == "illustrated" then return end
    DA.sendDataStatistics("bbqmrmk003", "模块进入数", moudle[sceneName][1], moudle[sceneName][2])
end

-- 完成该模块时发送
-- [友盟]bbqmrmk004 
function M.recordbbqmrmk004(sceneName)
    if not moudle[sceneName] or sceneName == "illustrated" then return end
    DA.sendDataStatistics("bbqmrmk004", "模块完成数", moudle[sceneName][1], moudle[sceneName][2])
end

-- 主动点击该模块时发送 包括图鉴
-- [友盟]bbqmrmk005 
function M.recordbbqmrmk005(sceneName)
    if not moudle[sceneName] then return end
    DA.sendDataStatistics("bbqmrmk005", "主动点击模块数", moudle[sceneName][1], moudle[sceneName][2])
end

-- [友盟]bbqmrmk006
-- 1-1,1-2, 2-1,2-2, 3-1,3-2
-- 每次玩颜色分类总共三轮，当用户完成该轮时，先发送完成的是第几轮，
-- 然后若用户无错误操作就完成则发送1，若用户错误操作＞2，则发送2（这里的错误操作，指的是确实把物体放在错误框里的，如果只是在空白区域就不算错误操作）；
-- 即如果在完成第一轮时有过3次错误操作，则发送1-2
function M.recordbbqmrmk006(str)
    DA.sendDataStatistics("bbqmrmk006", "颜色分类情况", str)
end

--------------------------
-- 时长采集
--------------------------
function M.recordGameplayBegin()
    DA.sendPageBegin("场景时长-play页面") 
end
function M.recordGameplayEnd()
    DA.sendPageEnd("场景时长-play页面")
end

-- 形状
function M.recordShapelineBegin()
    DA.sendPageBegin("场景时长-认形状页面") 
end
function M.recordShapelineEnd()
    DA.sendPageEnd("场景时长-认形状页面")
end

function M.recordShapefeedBegin()
    DA.sendPageBegin("场景时长-形状匹配页面") 
end
function M.recordShapefeedEnd()
    DA.sendPageEnd("场景时长-形状匹配页面")
end

function M.recordShapepuzzleBegin()
    DA.sendPageBegin("场景时长-形状组合页面") 
end
function M.recordShapepuzzleEnd()
    DA.sendPageEnd("场景时长-形状组合页面")
end

-- 颜色
function M.recordColorpaintBegin()
    DA.sendPageBegin("场景时长-认颜色页面") 
end
function M.recordColorpaintEnd()
    DA.sendPageEnd("场景时长-认颜色页面")
end

function M.recordColorjigsawBegin()
    DA.sendPageBegin("场景时长-颜色匹配页面") 
end
function M.recordColorjigsawEnd()
    DA.sendPageEnd("场景时长-颜色匹配页面")
end

function M.recordColorclassifyBegin()
    DA.sendPageBegin("场景时长-颜色分类页面") 
end
function M.recordColorclassifyEnd()
    DA.sendPageEnd("场景时长-颜色分类页面")
end

-- 大小
function M.recordSizematchBegin()
    DA.sendPageBegin("场景时长-大小匹配页面") 
end
function M.recordSizematchEnd()
    DA.sendPageEnd("场景时长-大小匹配页面")
end

function M.recordSizepuzzleBegin()
    DA.sendPageBegin("场景时长-大小拼图页面") 
end
function M.recordSizepuzzleEnd()
    DA.sendPageEnd("场景时长-大小拼图页面")
end

function M.recordSizepairBegin()
    DA.sendPageBegin("场景时长-大小配对页面") 
end
function M.recordSizepairEnd()
    DA.sendPageEnd("场景时长-大小配对页面")
end

-- 数字
function M.recordNumpuzzleBegin()
    DA.sendPageBegin("场景时长-认数字页面") 
end
function M.recordNumpuzzleEnd()
    DA.sendPageEnd("场景时长-认数字页面")
end

function M.recordNumwriteBegin()
    DA.sendPageBegin("场景时长-写数字页面") 
end
function M.recordNumwriteEnd()
    DA.sendPageEnd("场景时长-写数字页面")
end

function M.recordNumlineBegin()
    DA.sendPageBegin("场景时长-连数字页面") 
end
function M.recordNumlineEnd()
    DA.sendPageEnd("场景时长-连数字页面")
end

-- 图鉴
function M.recordIllustratedBegin()
    DA.sendPageBegin("场景时长-图鉴页面") 
end
function M.recordIllustratedEnd()
    DA.sendPageEnd("场景时长-图鉴页面")
end

--------------------------
-- 关卡采集
--------------------------
-- 关卡开始调用
function M.ugStartLevel(level, desc)
    DA.ugStartLevel(level, desc)
end

-- 关卡完成调用
function M.ugFinishLevel(level, desc)
    DA.ugFinishLevel(level, desc)
end

return M