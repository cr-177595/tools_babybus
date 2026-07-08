
cc.FileUtils:getInstance():setPopupNotify(false)
cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/")

cc.LuaLoadChunksFromZIP("res/box.bin")
cc.LuaLoadChunksFromZIP("res/bb.bin")




function __G__TRACKBACK__(errorMessage)

    -- 获取场景名称
    local scene = D.getRunningScene()
    local sceneName = "[nullScene]"
    if scene then 
        sceneName = ifnil("[" .. scene.name .. "]", "[noNameScene]")
    end

    release_print("logcat-error———————————————")
    release_print("LUA ERROR: " .. tostring(errorMessage) .. "\n")
    release_print(debug.traceback("", 2))
    release_print("logcat-error———————————————")

    -- bugly
    if buglyReportLuaException then
        buglyReportLuaException(sceneName .. tostring(errorMessage), debug.traceback())
        release_print("---------buglyReportLuaException-----------------")
    end
end

-- [游戏入口]
--[[  
	xpcall(调用函数, 错误捕获函数);  
	lua提供了xpcall来捕获异常  
	xpcall接受两个参数:调用函数、错误处理函数。  
	当错误发生时,Lua会在栈释放以前调用错误处理函数,因此可以使用debug库收集错误相关信息。  
	两个常用的debug处理函数:debug.debug和debug.traceback  
	前者给出Lua的提示符,你可以自己动手察看错误发生时的情况;  
	后者通过traceback创建更多的错误信息,也是控制台解释器用来构建错误信息的函数。  
--]]  
xpcall(function()

    require("config")
	require("cocos.init")
	require("framework.init")
	require "bbframework.init"
	require "game"

    game:startup()
end, __G__TRACKBACK__)