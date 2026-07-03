----------------------------------------------------------------
----------------------------------------------------------------
----------------------------------------------------------------
----------------------- ！！！注意！！！---------------------------
------------------config配置只能在此文件中修改----------------------
------------------不要在项目中使用，不然打PP------------------------
----------------------------------------------------------------
----------------------------------------------------------------
----------------------------------------------------------------
-- 载入自定义配置
require("bbframework.config")
CC_USE_DEPRECATED_API = true
-- 0 - disable debug info, 1 - less debug info, 2 - verbose debug info
DEBUG = 0

-- display FPS stats on screen
DEBUG_FPS = false

-- dump memory info every 10 seconds
DEBUG_MEM = false

-- load deprecated API
LOAD_DEPRECATED_API = false

-- load shortcodes API
LOAD_SHORTCODES_API = true

-- screen orientation
CONFIG_SCREEN_ORIENTATION = "landscape"

ENABLE_PRINT = true
-- auto scale mode
CC_DESIGN_RESOLUTION = {
    width = 960,
    height = 540,
    autoscale = "FIXED_HEIGHT"
}

IS_ADAPTIVE = true
IS_HEIGHT_MUL_FACTOR = true
----------------------
-- 游戏配置信息
----------------------
CONFIG_SCREEN_WIDTH  = CC_DESIGN_RESOLUTION.width
CONFIG_SCREEN_HEIGHT = CC_DESIGN_RESOLUTION.height



----------------------
-- 事件配置
----------------------
-- 事件[服务器]
ENABLED_EI_SERVER           = true

-- 事件[盒子]
ENABLED_EI_BOX              = true
-- 事件[大数据]
ENABLED_EI_BIGDATA          = false
-- 事件[休息]
ENABLED_EI_REST             = true
-- 事件[通用数据]
ENABLED_EI_BASIC            = false

-- 事件[体验数据]
ENABLED_EI_EXPERIENCE       = false

-- 事件[TV-视频]
ENABLED_EI_TV_VIDEO         = false

-- 事件[大数据] - 调试
ENABLED_EI_BIGDATA_DEBUG    = false
-- 事件[大数据] - 内部测试
ENABLED_EI_BIGDATA_ITLTEST  = false
-- 事件[大数据] - 大数据ID
ENABLED_EI_BIGDATA_ID       = 0
-- 事件[大数据] - 上传域名
ENABLED_EI_BIGDATA_UPLOAD_DOMAIN = nil

-- 事件[盒子] - 动画跳转
ENABLED_EI_BOX_ANIM_TRANSIT = true
-- 事件[盒子] - 跳过巴士
ENABLED_EI_BOX_SKIP_BUS     = false
-- 事件[盒子] - 懒加载
ENABLED_EI_BOX_LAZY         = false

ENABLED_DS_TK = false


----------------------
-- 发布语言
----------------------
LANG_LIMIT_CHINESE          = false                    
I18N_SOUND_ZHT_USE_ZH  		= false              
LANG_ALLOWS                 = { "es", "ar", "en", "fr", "id", "ko", "pt", "ru", "th", "vi", "zht", "ja", "zh"}       
IS_FULL_SCREEN = true
SCREEN_ORIENTATION = ORIENTATION_LANDSCAPE 


ENABLE_PRINT = true