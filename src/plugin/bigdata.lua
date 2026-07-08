--[[

Copyright (c) 2012-2019 baby-bus.com

http://www.baby-bus.com/LizardMan/

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

]]

--[[!--

大数据数据定义类，定义大数据映射等相关数据结构。

]]

----------------------
-- 大数据映射
----------------------
-- 事件[大数据] - 大数据ID
ENABLED_EI_BIGDATA_ID       = 10001
-- 事件[大数据] - 数据映射
if true then 
    ENABLED_EI_BIGDATA_MAPPER = {}
    ENABLED_EI_BIGDATA_MAPPER['滑屏次数'] = '011'
    ENABLED_EI_BIGDATA_MAPPER['无效点击'] = '012'
    ENABLED_EI_BIGDATA_MAPPER['停留时间'] = '013'
    ENABLED_EI_BIGDATA_MAPPER['计算数字'] = '014'
    ENABLED_EI_BIGDATA_MAPPER['场景:1' .. '难度:2']  = '099'
end