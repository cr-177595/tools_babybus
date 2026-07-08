----------------------
-- 游戏版本定义
----------------------
-- 设置版本（此处的版本与config.lua中的版本不同，此处版本为游戏实际版本(可能已经增量更新)，config.lua中的版本为游戏的发布版本）
CUR_VERSION = "9.9.9"

----------------------
-- 强制覆写定义
----------------------
-- 设置发布驱动模型
if isandroid() then
	DEVICE_MODEL = "x2"
end
-- FIXME: 在此处可以覆盖定义config.lua中声明的变量，因为在进行打包时config.lua文件锁定不受增量包影响
-- 设置驱动模型(注：开发状态下请取消注释下一行代码)
if ismac() or iswin() then
	DEVICE_MODEL = "x4"
end
-- 设置语言
device.language = "zh"
-- DEVICE_MODEL = "x2"

----------------------
-- 模块[game]定义 
----------------------
-- [游戏初始化]
require("game_init")

-- 启动游戏
-- 包含内容：(1)配置游戏启动相关参数 (2)重置游戏缓存数据 (3)预加载资源 (4)..
function game:startup()
	if NV.getDebug() or ismac() or iswin() then
		-- 游戏速度控制
		-- U.loadDebugConsole()
        DEBUG_MODLE = 1
	end
    -- 启动应用层开场
    self:run()

	-- demo模版
	-- game:enterScene("template")
	
	-- quick界面
	game:enterScene("quick")

	-- 3D模型精灵
	-- game:enterScene("sprite3d")

	-- shader地球仪
	-- game:enterScene("earth")

	-- 消消乐
	game:enterScene("eliminate")
end