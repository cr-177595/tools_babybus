----------------------
-- 游戏初始化
----------------------
-- 类初始化
game        = class("game", bb.GameBase).new()
-- 日志标识
game.TAG    = "game"

----------------------
-- 定义公共类
----------------------
-- 声音
sound 		= require("com.sound")
-- 音效管理
soundEffect = require("com.SoundEffect")
-- 语音管理
soundVoice 	= require("com.SoundVoice")
-- umeng数据
umengOP 	= require("com.UmengData")
-- 骨骼类
DragonBone  = bb.si.DragonBone
-- 按钮层基类
BaseButton 	= require("app.common.layer.BaseButtonLayer")
-- 配置表
require("com.DataConfig")
-- 通用方法
CommonFun    = require("com.CommonFun")
-- 刚体工具
ZBox2D       = require("com.ZBox2D")
