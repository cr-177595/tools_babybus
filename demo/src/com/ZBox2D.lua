--[[ 

    Copyright (c) 2012-2020 baby-bus.com

    -- TODO：    Box2D物理引擎工具类[Box2D]
    -- Author：  yao
    -- Date：    2020年09月16日 

--]]--

local M = {}
M.TAG   = "Box2D"


--------------------------
-- box2D常量、变量定义 
--------------------------
-- 物理世界
M.currentPhysicsWorld = nil
-- 圆周率
M.PI                  = math.pi     -- 3.1415926                    
-- 像素/米（用于将opengl坐标转换成box2D坐标的比例尺）
PTM_RATIO             = 32            
-- 角度换算成弧度[math.rad(angle)]
TO_PI                 = M.PI / 180
-- 弧度换算成角度[math.deg(radian)]
TO_D                  = 180 / M.PI



--[[    
    定义刚体类型枚举
--]]
if not EBodyType then
    EBodyType = {
        -- 静态刚体(不会移动)
        STATIC    = b2_staticBody or 0,
        -- 动态刚体(默认值)
        DYNAMIC    = b2_dynamicBody or 1,
        -- 平台刚体
        KINEMATIC = b2_kinematicBody or 2,
    }
    EBodyType.TAG    = "EBodyType"

    --------------------------
    -- 转成字符串
    --------------------------
    function EBodyType.toString(enumValue)
        local result    = "Dynamic"
        if enumValue == EBodyType.STATIC then
            result = "Static"
        elseif enumValue == EBodyType.KINEMATIC then
            result = "Kinematic"
        end
        return result
    end

    --------------------------
    -- 转成枚举
    --------------------------
    function EBodyType.toEnumByString(enumString)
        enumString    = string.lower(enumString)
        local result    = EBodyType.DYNAMIC
        if enumString == "static" then
            result = EBodyType.STATIC
        elseif enumString == "kinematic" then
            result = EBodyType.KINEMATIC
        end

        return result
    end
end



--[[    
    定义形状枚举
--]]
if not EShape then
    EShape    = {
        -- 点
        DOT        = 0,
        -- 圆
        CIRCLE     = 1,
        -- 线
        LINE       = 2,
        -- 边 
        EDGE       = 3,
        -- 三角形
        TRIANGLE   = 4,
        -- 矩形 
        RECTANGLE  = 5,
        -- 多边形
        POLYGON    = 6,
        -- 链条
        CHAIN      = 7, 
        -- 默认
        DEFAULT    = -1,
    }
    EShape.TAG    = "EShape"

    --------------------------
    -- 转成字符串
    --------------------------
    function EShape.toString(enumValue)
        local result    = "Default"
        if enumValue == EShape.DOT then
            result = "Dot"
        elseif enumValue == EShape.CIRCLE then
            result = "Circle"
        elseif enumValue == EShape.LINE then
            result = "Line"
        elseif enumValue == EShape.EDGE then
            result = "Edge"
        elseif enumValue == EShape.TRIANGLE then
            result = "Triangle"
        elseif enumValue == EShape.RECTANGLE then
            result = "Rectangle"
        elseif enumValue == EShape.POLYGON then
            result = "Polygon"
        elseif enumValue == EShape.CHAIN then
            result = "Chain"
        end
        return result
    end

    --------------------------
    -- 转成枚举
    --------------------------
    function EShape.toEnumByString(enumString)
        enumString        =  string.lower(enumString)
        local result      =  EShape.DEFAULT
        if enumString  == "dot" then
            result        =  EShape.DOT
        elseif enumString == "circle" then
            result        =  EShape.CIRCLE
        elseif enumString == "line" then
            result        =  EShape.LINE
        elseif enumString == "edge" then
            result        =  EShape.EDGE
        elseif enumString == "triangle" then
            result        =  EShape.TRIANGLE
        elseif enumString == "rectangle" then
            result        =  EShape.RECTANGLE
        elseif enumString == "polygon" then
            result        =  EShape.POLYGON
        elseif enumString == "chain" then
            result        =  EShape.CHAIN
        end
        return result
    end
end




--========================================================================
-- 构造型函数 
--========================================================================
--------------------------
-- 世界[World]
--------------------------
--[[--
    创建物理世界

    ### Useage:
        local world = ZBox2D.createWorld(重力矢量, 是否允许静止的物体休眠, 是否开启连续物理检测, 世界的边界点的集合)
        
    ### Aliases:

    ### Notice:
        box2D的力一般以b2Vec2类型表示。
        这里创建的物理世界会保存在一个全局变量里面，以方便访问。所以当这个世界不需要存在的时候记得一定要进行销毁。

    ### Example:
        ----------------------
        -- 示例1: 通用操作
        ----------------------
        
    ### Parameters:
    -   b2Vec2  **gravity**                   [可选] 重力矢量
    -   bool    **isCreateEdge**              [可选] 是否创建世界边缘（默认的世界边缘。即屏幕边缘，若要创建自定义边缘请使用createWorldEdge方法）
    -   boolean **isAllowSleeping**           [可选] 是否允许静止的物体休眠
    -   boolean **isContinuousPhysics**       [可选] 是否开启连续物理检测

    ### OptionParameters

    ### Returns: 
    -   b2World                             物理世界对象
--]]
function M.createWorld(gravity, isCreateEdge, isAllowSleeping, isContinuousPhysics)
    -- 参数验证
    isAllowSleeping      = ifnil(isAllowSleeping, true)
    isContinuousPhysics  = ifnil(isContinuousPhysics, true)
    -- 创建世界
    local world          = b2World(gravity or b2Vec2(0, -9.8))
    -- 允许静止的物体休眠
    world:SetAllowSleeping(isAllowSleeping)
    -- 开启连续物理检测，使模拟更加的真实
    world:SetContinuousPhysics(isContinuousPhysics)
    -- 保留引用
    M.currentPhysicsWorld = world
    -- 创建边沿
    if isCreateEdge then 
        M.createWorldEdge() 
    end
    return world
end



--[[--

    创建世界边沿

    ### Useage:
        local edge = ZBox2D.createWorldEdge(世界边缘坐标点集合)
    ### Aliases:

    ### Notice:
        世界的边缘一般是使用四条线（刚体）首尾相连而成。
        因为屏幕的缘故，边缘一般用顺时针或者逆时针顺序的四个点围成。        

    ### Parameters:
    -   table   **points**              [可选] 世界边缘坐标点集合
    -   bool    **isNeedRoof**          [可选] 是否需要上边缘
    ### OptionParameters

    ### Returns: 
    -   b2Body                          世界边沿对象
--]]
function M.createWorldEdge(points, isNeedRoof)
    -- 边沿构造器[创建一条边]
    local function edgeMacker(body, fromPoint, toPoint, id)
        local shape        = b2EdgeShape()
        local fixtureDef   = b2FixtureDef()
        shape:Set(b2Vec2(fromPoint.x / PTM_RATIO, fromPoint.y / PTM_RATIO),
        b2Vec2(toPoint.x / PTM_RATIO, toPoint.y / PTM_RATIO))
        fixtureDef.shape    = shape
        fixtureDef.id       = id
        fixtureDef.friction = 1
        body:CreateFixture(fixtureDef)
    end
    local roof = ifnil(isNeedRoof, false)
    -- 边沿定义，创建边沿
    local edgeBodyDef = b2BodyDef()
    local edgeBody    = M.currentPhysicsWorld:CreateBody(edgeBodyDef)

    -- 生成上下左右四条边沿
    if true then
        points = points or { cc.p(0, 0), cc.p(V.w, 0), cc.p(V.w, V.h), cc.p(0, V.h),}
        edgeMacker(edgeBody, points[1], points[2], 1)
        edgeMacker(edgeBody, points[1], points[4], 2)
        -- 是否需要上边界
        if roof then
            edgeMacker(edgeBody, points[3], points[4], 3)            
        end
        edgeMacker(edgeBody, points[3], points[2], 4)
    end

    -- 保留引用
    M.worldEdgeBody = edgeBody
    return edgeBody
end


--------------------------
-- 刚体[Body]
-------------------------- 
--[[--
    创建刚体
    ### Useage:
        local bodyDef = ZBox2D.createBody(刚体信息, 夹具信息)
    ### Notice:
        形状主要用于碰撞。
    ### Parameters:
    -   table   **bodyInfo**      [必选] 刚体信息 
    -   table  **fixtureInfo**    [必选] 夹具信息
        **fixtureInfo:若是用physicalEditor，则里面的内容为：{plistPath = plist路径， key=关键字}
    ### Returns: 
    -   b2Body                  刚体对象
--]]
function M.createBody(bodyInfo, fixtureInfo)
    bodyInfo      = bodyInfo or {}
    fixtureInfo   = fixtureInfo or {}
    -- 创建一个刚体的定义，里面保存要创建的所有信息（位置、角度、类型等）。
    local bodyDef = M.createBodyDef(bodyInfo)
    -- 创建一个刚体对象，根据刚体定义创建
    local body    = M.currentPhysicsWorld:CreateBody(bodyDef)
    -- 如果用户数据存在，将刚体保存位用户数据的一个属性，方便使用用户数据访问刚体，不是box2d刚体的做法。
    if body.userData then
        body.userData.body = body
    end

    -- 创建简单或复杂的纹理（形状）
    if fixtureInfo.key then
        M.addComplexFixture(body, fixtureInfo.plistPath, fixtureInfo.key)
    else
        M.addSimpleFixture(body, bodyInfo)
    end
    return body
end

--[[--
    创建矩形刚体刚体
    ### Useage:
        local bodyDef = ZBox2D.createRectangleBody(长, 宽, 和刚体绑定的节点， 其他参数)
    ### Notice:
        形状主要用于碰撞。
    ### Parameters:
    -   cc.size     **size**            [必选] 矩形的长宽
    -   cc.Sprite   **node**            [可选] 和刚体绑定的节点
    -   tabel       **params**          [可选] 其他参数（如要修改刚体和夹具的数据在此表上赋值）
    ### Returns: 
    -   b2Body                  刚体对象
--]]
function M.createRectangleBody(size, node, point, params)
    params = params or {}
    params.userData     = node
    params.pos          = point
    local bodyDef       = M.createBodyDef(params)
    local body          = M.currentPhysicsWorld:CreateBody(bodyDef)
    local shapeInfo     = {}
    shapeInfo.shapeType = EShape.RECTANGLE
    shapeInfo.length    = size.width
    shapeInfo.width     = size.height
    params.shape    = shapeInfo
    M.addSimpleFixture(body, params)
    return body
end

--[[--
    创建矩形刚体刚体
    ### Useage:
        local bodyDef = ZBox2D.createCircleBody(刚体信息, 包含形状信息的.plist文件, 物理形状图片名称)
    ### Notice:
        形状主要用于碰撞。
    ### Parameters:
    -   Number     **radius**          [必选] 圆的半径
    -   cc.Sprite  **node**            [可选] PhysicsEditor导出的.plist文件
    -   tabel      **params**          [可选] 其他参数（如要修改刚体和夹具的数据在此表上赋值）
    ### Returns: 
    -   b2Body                  刚体对象
--]]
function M.createCircleBody(radius, node, point, params)
    params = params or {}
    params.userData = node
    params.pos      = point
    local bodyDef   = M.createBodyDef(params)
    local body      = M.currentPhysicsWorld:CreateBody(bodyDef)


    local shapeInfo  = {}
    shapeInfo.shapeType = EShape.CIRCLE
    shapeInfo.radius    = radius
    params.shape    = shapeInfo
    M.addSimpleFixture(body, params)
    return body
end


--[[--
    创建刚体描述
    ### Useage:
        local bodyDef = ZBox2D.createDef(刚体信息)
    ### Notice:
        形状主要用于碰撞。        
    ### Parameters:
    -   table   **params**      [必选] 刚体信息 
    ### Returns: 
    -   b2BodyDef               刚体描述
--]]
function M.createBodyDef(bodyInfo)
    local bodyDef           = b2BodyDef()
    bodyDef.position        = M.ccpToVec(bodyInfo.pos or cc.p(V.w_2, V.h_2))
    --角度
    bodyDef.angle           = bodyInfo.angle or 0
    --线速度
    bodyDef.linearVelocity  = bodyInfo.linearVelocity or b2Vec2(0, 0)
    --角速度
    bodyDef.angularVelocity = bodyInfo.angularVelocity or 0
    --线性阻尼
    bodyDef.linearDamping   = bodyInfo.linearDamping or 0
    --角阻尼
    bodyDef.angularDamping  = bodyInfo.angularDamping or 0
    --动态刚体 b2_dynamicBody,静态刚体 b2_staticBody,平台刚体 b2_kinematicBody
    bodyDef.type            = bodyInfo.type or b2_dynamicBody
    --允许休眠
    bodyDef.allowSleep      = bodyInfo.allowSleep or true
    --是否唤醒
    bodyDef.awake           = bodyInfo.awake or true
    --是否固定旋转角度
    bodyDef.fixedRotation   = bodyInfo.fixedRotation or false
    --是否为子弹刚体
    bodyDef.bullet          = bodyInfo.bullet or false
    --是否被激活
    bodyDef.active          = bodyInfo.active or true
    --重力因子
    bodyDef.gravityScale    = bodyInfo.gravityScale or 1.0
    -- 用户数据绑定
    bodyDef.userData        = bodyInfo.userData
    return bodyDef
end

--[[--
    用physicsEditor生产plist的夹具（Fixtrue）
    ### Useage:
        ZBox2D.addComplexFixture(刚体对象, 包含形状信息的.plist文件, 物理形状图片名称)
    ### Aliases:

    ### Notice:
        用于给刚体绑定物理形状、质量、摩擦力、弹性系数等物理属性。

    ### Parameters:
    -   b2Body  **body**        [必选] 刚体对象
    -   String  **plistPath**   [必选] PhysicsEditor导出的.plist文件
    -   String  **key**         [必选] plist文件中物理形状图片名称
--]]
function M.addComplexFixture(body, plistPath, key)
    -- 加载physicsDesigner的.plist格式文件
    GB2ShapeCache:sharedGB2ShapeCache():addShapesWithFile(plistPath)
    -- 把生成的刚体和形状绑在一起，key即图片名
    GB2ShapeCache:sharedGB2ShapeCache():addFixturesToBody(body, key)
end

--[[--
    创建夹具
    ### Useage:
        ZBox2D.addSimpleFixture(刚体对象, 形状信息)
    ### Notice:
        用于给刚体绑定物理形状、质量、摩擦力、弹性系数等物理属性。
    ### Parameters:
    -   b2Body  **body**        [必选] 刚体对象
    -   table   **bodyInfo**    [必选] 刚体信息 
--]]
--
function M.addSimpleFixture(body, fixtureInfo)
    -- 创建一个刚体的纹理（夹具/材质）
    local fixtureDef               = b2FixtureDef()
    --摩擦
    fixtureDef.friction            = fixtureInfo.friction or .3
    --弹性系数
    fixtureDef.restitution         = fixtureInfo.restitution or .2
    --密度
    fixtureDef.density             = fixtureInfo.density or .3

    fixtureDef.isSensor            = fixtureInfo.isSensor or false       
    -- 碰撞筛选
    if fixtureInfo.maskBits or fixtureInfo.categoryBits or fixtureInfo.groupIndex then
        local filter = b2Filter()
        filter.categoryBits = fixtureInfo.categoryBits or 0x0001
        filter.maskBits     = fixtureInfo.maskBits or 0xFFFF
        filter.groupIndex   = fixtureInfo.groupIndex or 0
        fixtureDef.filter   = filter
    end
    --用户数据
    fixtureDef.userData            = fixtureInfo.userData
    -- 创建一个或多个形状
    if fixtureInfo.shape then
        local function shapeMaker(body, shape)
            -- 根据形状信息创建一个形状
            local shapeObj      = M.createShape(shape)
            -- 将形状和材质绑定（只是简单的保存了引用）
            fixtureDef.shape    = shapeObj 
            -- 将刚体和材质绑定（只是简单的保存了引用）
            body.fixtureDef     = fixtureDef 
            -- 创建刚体的材质（这里才是真正的绑定了）
            local fixture       = body:CreateFixture(fixtureDef)
        end

        if fixtureInfo.shape["shapeType"] then
            -- 如果bodyInfo.shape里面保存的不是表，说明bodyInfo.shape就是一个形状信息 
            shapeMaker(body, fixtureInfo.shape)
        else
            for _, v in pairs(fixtureInfo.shape) do
                -- 如果bodyInfo.shape里面保存的是表，说明bodyInfo.shape里面是多个形状的信息，应该使用bodyInfo.shapes才对。 
                shapeMaker(body, v)
            end
        end
    end
end













-------------------------------------------------------------------------
-- 创建形状 
------------------------------------------------------------------------- 
--[[--
    创建形状

    ### Useage:
        local shape = ZBox2D.createShape(形状信息)

    ### Notice:
        形状主要用于碰撞。

    ### Parameters:
    -   table   **shapeInfo**       [必选] 形状信息 
    ### Returns: 
    -   b2Shape                     物理形状对象
--]]
function M.createShape(shapeInfo)
    local shapeType    = shapeInfo.shapeType
    -- 如果是字符串传进来需要转成数值，具体枚举请看EShape
    if type(shapeInfo.shapeType) == "string" then
        shapeType    = EShape.toEnumByString(shapeInfo.shapeType)
    end
    local shape        = nil
    if shapeType == EShape.CIRCLE then              -- 圆形
        shape = M.createShapeCircle(shapeInfo)
    elseif shapeType == EShape.POLYGON then         -- 多边形
        shape = M.createShapePolygon(shapeInfo.points)     
    elseif shapeType == EShape.EDGE then            -- 边界
        shape = M.createShapeEdge(shapeInfo.startPoint, shapeInfo.endPoint)
    elseif shapeType == EShape.RECTANGLE then
        shape = M.createShapeRectangle(shapeInfo.length, shapeInfo.width)    
    elseif shapeType == EShape.CHAIN then
        -- TODO 
    end
    return shape
end

--[[--
    创建形状[圆]
    ### Useage:
        local shape = ZBox2D.createShapeCircle(形状信息)

    ### Notice:
        形状主要用于碰撞。

    ### Parameters:
    -   number   **radius**       [必选] 半径/米

    ### Returns: 
    -   b2CircleShape               多边形
--]]

-- function M.createShapeCircle(radius)
--     -- 创建一个圆形
--     local shape    = b2CircleShape()
--     -- 设置半径
--     shape.m_radius = radius or 1
--     return shape
-- end

function M.createShapeCircle(shapeInfo)
    -- 创建一个圆形
    local shape         = b2CircleShape()
    local offset        = ifnil(shapeInfo.offset, ccp(0, 0))
    -- 设置半径
    shape.m_radius      = shapeInfo.radius or 1
    shape.m_p           = b2Vec2(offset.x / PTM_RATIO, offset.y / PTM_RATIO)
    return shape
end

--[[--
    创建形状[多边形]
    ### Useage:
        local shape = ZBox2D.createShapePolygon(顶点表)
        
    ### Notice:
        形状主要用于碰撞。
        
    ### Parameters:
    -   table   **points**       [必选] 多边形顶点集合 

    ### Returns: 
    -   b2PolygonShape              多边形
--]]
function M.createShapePolygon(points)
    -- 创建多边形
    local shape       = b2PolygonShape()
    -- 顶点集合
    local vertices    = {}
    -- 初始化顶点集合
    for i, point in ipairs(points) do
        table.insert(vertices, M.ccpToVec(point))
    end
    shape:Set(PS.getVertices(vertices), #vertices)
    return shape
end


--[[--
    创建矩形
    ### Useage:
        local shape = ZBox2D.createShapeRectangle(长，宽)
        
    ### Notice:
        形状主要用于碰撞。
        
    ### Parameters:
    -   number   **length**       [必选] 长 
    -   number   **width**        [必选] 宽 

    ### Returns: 
    -   b2PolygonShape              多边形
--]]
function M.createShapeRectangle(length, width)
    local shape = b2PolygonShape()
    shape:SetAsBox(length, width)
    return shape
end
--[[--
    创建形状[线、边缘]

    ### Useage:
        local shape = ZBox2D.createShapeEdge(起始位置， 终点位置)
        
    ### Notice:
        一条可以碰撞的线段。
        
    ### Parameters:
    -   cc.point   **startPoint**       [必选] 起始位置
    -   cc.point   **endPoint**         [必选] 终点位置

    ### Returns: 
    -   b2EdgeShape                 线段
--]]
function M.createShapeEdge(startPoint, endPoint)
    -- 线段起点
    local startPoint   = startPoint
    -- 线段终点
    local endPoint     = endPoint
    -- 创建一条线段
    local shape        = b2EdgeShape()
    -- 设置线段的起点和终点
    shape:Set(M.ccpToVec(startPoint), M.ccpToVec(endPoint))
    return shape
end






-------------------------------------------------------------------------
-- 物理世界迭代
-------------------------------------------------------------------------
--[[--
    开启物理世界更新

    ### Useage:
        ZBox2D.update(handler(self, self.tick), 1.0 / 60)
        
    ### Notice:
        开启更新后才会进行物理模拟。

    ### Parameters:
    -   function    **delegateTick**        [可选] 进行物理模拟和数据更新的函数

    ### Returns: 
    -   CCScheduler                         物理侦听对象
--]]
function M.update(delegateTick)
    -- 开启延时器进行物理更新
    local timer = scheduler.scheduleUpdateGlobal(function (dt)
        if M.sliceTick then
            M.sliceTick()
        end
        local callBack = delegateTick or M.tick
        callBack(dt)
    end)
    -- 保存引用
    M.timer = timer
    return timer
end

-- 更新[物理世界]
function M.tick(dt)
    if not M.currentPhysicsWorld then return end
    -- 速度迭代device、位置迭代
    -- 迭代次数越多越真实，但是性能越低。
    local velocityIterations, positionIterations = 8, 8
    -- 物理引擎进行物理模拟，生成模拟后的数据
    M.currentPhysicsWorld:Step(dt, velocityIterations, positionIterations)
    -- 同步物理世界和渲染世界
    local body = M.currentPhysicsWorld:GetBodyList()
    while body do
        if body:GetUserData() then
            local spr = tolua.cast(body:GetUserData(), "cc.Sprite")
            local x, y = body:GetPosition().x * PTM_RATIO, body:GetPosition().y * PTM_RATIO
            -- 更新位置、角度，同步物理世界和渲染世界
            spr:setPosition(cc.p(x, y))
            spr:setRotation(-1 * PT.radians2degrees(body:GetAngle()))
        end
        -- 获得下一个body
        body = body:GetNext()
    end
end





-------------------------------------------------------------------------
--侦听器
------------------------------------------------------------------------- 
--[[--
    开启物理接触侦听器
    ### Useage:
        ZBox2D.openContactListener(handler(self, self.onContact))
        
    ### Notice:
        注册物理碰撞的回调函数，包含三个参数：
            碰撞事件的类型对象(分别是接触前、接触后、求解前和求解后)
            接触对象(里面包含接触信息，接触的刚体、接触点等等。)
            oldManifold对象
        
    ### Parameters:
    -   function    **delegateMethod**      [必选] 侦听器回调函数

    ### OptionParameters
        接触类型：
            GB2_CONTACTTYPE_BEGIN_CONTACT   ：开始接触
            GB2_CONTACTTYPE_END_CONTACT     ：结束接触
            GB2_CONTACTTYPE_PRE_SOLVE       ：求解前
            GB2_CONTACTTYPE_POST_SOLVE      ：求解后 
--]]
function M.openContactListener(delegateMethod, target)
    -- 创建接触侦听器
    local listener = GB2ContactListener:new_local()

    -- 为接触注册侦听函数
    listener:registerScriptHandler(function(contactType, contact, oldManifold)
        delegateMethod(target, contactType, contact, oldManifold)
    end)
    -- 设置物理世界的接触侦听
    M.currentPhysicsWorld:SetContactListener(listener)

    -- 保存引用指针，防止对象被回收导致闪退
    M.currentPhysicsWorld.contactListener = listener

    return listener
end


--[[--
    关闭物理接触侦听器
    ### Useage:
        ZBox2D.closeContactListener()

    ### Notice:
        box2D的力一般以b2Vec2类型表示。
        这里创建的物理世界会保存在一个全局变量里面，以方便访问。所以当这个世界不需要存在的时候记得一定要进行销毁。
--]]
function M.closeContactListener()
    M.currentPhysicsWorld:SetContactListener(nil)
end

--[[--

获取物理世界

### Useage:
    local world = ZBox2D.getWorld()
    
### Aliases:

### Notice:
    返回最新创建的物理世界。

### Example:
    
### Parameters:

### OptionParameters

### Returns: 
-   b2World                 物理世界对象

--]]--
function M.getWorld()
    return M.currentPhysicsWorld
end

--[[--

设置物理世界

### Useage:
    ZBox2D.setWorld(物理世界对象)
    
### Aliases:

### Notice:
    有点时候获取到的点错误，会是b2Vec2(0, 0)，开启矫正后会它设置到屏幕外足够远的地方去。

### Example:
    
### Parameters:
-   b2World     **world**       [必选] 物理世界对象

### OptionParameters

### Returns: 

--]]--
function M.setWorld(world)
    M.currentPhysicsWorld = world 
end

--[[--

获取时间步

### Useage:
    local timeStep = ZBox2D.getTimeStep(接触对象, 是否矫正结果)
    
### Aliases:

### Notice:
    iPhone4 物理模拟比较卡，将物理模拟速率降低。固件名iPhone3,1即iPhone4，iPod4,即touch4。

### Example:
    
### Parameters:

### OptionParameters

### Returns: 
-   float                       时间步

--]]--
function M.getTimeStep()
    local deviceInfo    = NV.getDeviceInfo()
    local version       = deviceInfo.version 
    local timeStep      = 1.0 / 60

    -- iPhone4/4S
    if isandroid() or version == "iPhone3,1" or version == "iPod4,1" or 
        -- iPod Touch
        version == "iPod1,1" or version == "iPod2,1" or version == "iPod3,1" or 
        version == "iPod4,1" or version == "iPod5,1" or 
        -- iPad mini 1
        version == "iPad2,5" or version == "iPad2,6" or version == "iPad2,7" then
        timeStep = 1.0 / 40
    end

    return timeStep
end 

--[[--
    根据接触对象获取碰撞接触点 
    ### Useage:
        local contactPoint, bodyA, bodyB = ZBox2D.getContactWorldPoint(接触对象, 是否矫正结果)

    ### Notice:
        有点时候获取到的点错误，会是b2Vec2(0, 0)，开启矫正后会它设置到屏幕外足够远的地方去。

    ### Example:
        ----------------------
        -- 示例1: 获取接触点
        ----------------------
        local contactPoint = ZBox2D.getContactWorldPoint(接触对象, 是否矫正结果)
        print("contactPoint ＝ ", contactPoint.x, contactPoint.y)
        
    ### Parameters:
    -   b2Contact   **contact**         [必选] 接触对象
    -   boolean     **isCorrection**    [可选] 是否矫正结果

    ### OptionParameters

    ### Returns: 
    -   CCPoint                         世界边沿对象
    -   b2Body                          产生接触的刚体对象A
    -   b2Body                          产生接触的刚体对象B

--]]
--
function M.getContactWorldPoint(contact, isCorrection)
    -- 获取碰撞的刚体
    local bodyA    = contact:GetFixtureA() and contact:GetFixtureA():GetBody() or nil
    local bodyB    = contact:GetFixtureB() and contact:GetFixtureB():GetBody() or nil

    if bodyA and bodyB then
        -- 定义一个b2WorldManifold对象，用来获取并存储碰撞点的全局坐标
        local manifold = GB2Util:newWorldManifold()
        -- 通过GetWorldManifolde方法，计算出碰撞点的全局坐标，并存储到manifold变量中
        contact:GetWorldManifold(manifold)
        -- 获取碰撞点
        local point    = manifold.points[0]

        -- 容错[有点时候获取到的点会是b2Vec2(0, 0)，我把它设置到屏幕外足够远的地方去。]
        if ifnil(isCorrection, true) and point.x == 0 and point.y == 0 then
            point = cc.p(-1000, -1000)
        end

        -- 转成像素坐标返回
        return M.vecToCc.p(point)
    end

    return cc.p(0, 0), bodyA, bodyB
end






--------------------------
-- 关节[Joints]
--------------------------
--[[--

    创建鼠标关节

    ### Useage:
        local joint = ZBox2D.createMouseJoint(刚体对象A, 刚体对象B, 关节信息)
        
    ### Notice:
        鼠标关节用于多拽刚体，实际作用的应该只有一个刚体，但是关节是用于连接两个刚体的结构。
        一般我们将关节连接的bodyA设置为世界的边界刚体。

    ### Example:
        ----------------------
        -- 示例1: 移动鼠标关节
        ----------------------
        -- 创建鼠标关节
        local joint = ZBox2D.createMouseJoint(self.edge,  touchBody, jointInfo)
        -- 设置关节的位置
        joint:SetTarget(b2Vec2(x / PTM_RATIO, y / PTM_RATIO))
        
    ### Parameters:
    -   b2Body  **bodyA**           [必选] 要连接的刚体对象A
    -   b2Body  **bodyB**           [必选] 要连接的刚体对象B
    -   table   **jointInfo**       [必选] 关节信息

    ### Returns: 
    -   b2MouseJoint                鼠标关节对象
--]]
function M.createMouseJoint(bodyA, bodyB, jointInfo)
    if (not M.currentPhysicsWorld) then return end
    -- 创建一个鼠标关节定义
    local mouseJointDef            = b2MouseJointDef()
    -- 关节连接的刚体A
    mouseJointDef.bodyA            = bodyA
    -- 关节连接的刚体B
    mouseJointDef.bodyB            = bodyB
    -- 关节连接在刚体A上的锚点，其他关节应该也有，默认在中央
    mouseJointDef.localAnchorA     = ifnil(jointInfo.localAnchorA or b2Vec2(0.5, 0.5))
    -- 关节连接在刚体B上的锚点，其他关节应该也有，默认在中央
    mouseJointDef.localAnchorB     = ifnil(jointInfo.localAnchorB or b2Vec2(0.5, 0.5))
    -- 频率：频率越高，关节越硬。影响关节的弹性（典型情况下，关节频率要小于一半的时间步(time step)频率。
    --  比如每秒执行60次时间步, 关节的频率就要小于30赫兹。这样做的理由可以参考Nyquist频率理论。）
    mouseJointDef.frequencyHz      = jointInfo.frequencyHz or 30
    -- 阻尼率：值越大，关节运动阻尼越大。影响关节的弹性（阻尼率无单位，典型是在0到1之间, 也可以更大。1是阻尼率的临界值, 当阻尼率为1时，没有振动。）
    mouseJointDef.dampingRatio     = jointInfo.dampingRatio or 1
    -- 是否连续碰撞
    mouseJointDef.collideConnected = jointInfo.collideConnected or false
    -- 作用点
    mouseJointDef.target           = M.ccpToVecRatio(jointInfo.target)
    -- 限制关节上可以施加的最大的力
    mouseJointDef.maxForce         = jointInfo.maxForce or 0
    -- 创建关节，并转换为b2MouseJoint类型   
    return tolua.cast(M.currentPhysicsWorld:CreateJoint(mouseJointDef), "b2MouseJoint")
end

--[[--
    创建焊接关节

    ### Useage:
    local joint = ZBox2D.createWeldJoint(刚体对象A, 刚体对象B, 关节信息)

    ### Parameters:
    -   b2Body  **bodyA**           [必选] 要连接的刚体对象A
    -   b2Body  **bodyB**           [必选] 要连接的刚体对象B
    -   table   **jointInfo**       [必选] 关节信息

    ### Returns: 
    -   b2WeldJoint                 焊接关节对象
--]]
function M.createWeldJoint(bodyA, bodyB, jointInfo)
    if (not M.currentPhysicsWorld) then return end

    -- 创建一个焊接关节定义
    local weldJointDef            = b2WeldJointDef()
    weldJointDef:Initialize(bodyA, bodyB, bodyB:GetWorldCenter())
    -- 频率：频率越高，关节越硬。影响关节的弹性（典型情况下，关节频率要小于一半的时间步(time step)频率。
    --  比如每秒执行60次时间步, 关节的频率就要小于30赫兹。这样做的理由可以参考Nyquist频率理论。）
    weldJointDef.frequencyHz        = jointInfo.frequencyHz or 30
    -- 阻尼率：值越大，关节运动阻尼越大。影响关节的弹性（阻尼率无单位，典型是在0到1之间, 也可以更大。1是阻尼率的临界值, 当阻尼率为1时，没有振动。）
    weldJointDef.dampingRatio    = jointInfo.dampingRatio or 0
    -- 是否连续碰撞
    weldJointDef.collideConnected = jointInfo.collideConnected or false

    -- 创建关节，并转换为b2WeldJoint类型
    return tolua.cast(M.currentPhysicsWorld:CreateJoint(weldJointDef), "b2WeldJoint")
end

--[[--
    创建距离关节
    ### Useage:
    local joint = ZBox2D.createDistanceJoint(刚体对象A, 刚体对象B, 关节信息)

    ### Parameters:
    -   b2Body  **bodyA**           [必选] 要连接的刚体对象A
    -   b2Body  **bodyB**           [必选] 要连接的刚体对象B
    -   table   **jointInfo**       [必选] 关节信息

    ### Returns: 
    -   b2Joint                     距离关节对象
--]]
function M.createDistanceJoint(bodyA, bodyB, jointInfo)
    if (not M.currentPhysicsWorld) then return end
    -- 创建一个距离关节定义
    local distanceJointDef        = b2DistanceJointDef()
    distanceJointDef:Initialize(bodyA, bodyB, ifnil(jointInfo.jointPointA, bodyA: GetWorldCenter()), ifnil(jointInfo.jointPointB, bodyB: GetWorldCenter()))
    -- 关节连接的刚体A
    distanceJointDef.bodyA        = bodyA
    -- 关节连接的刚体B
    distanceJointDef.bodyB        = bodyB
    -- 距离关节的长度
    distanceJointDef.length       = jointInfo.length or 1
    -- 频率：频率越高，关节越硬。影响关节的弹性（典型情况下，关节频率要小于一半的时间步(time step)频率。
    --  比如每秒执行60次时间步, 关节的频率就要小于30赫兹。这样做的理由可以参考Nyquist频率理论。）
    distanceJointDef.frequencyHz  = jointInfo.frequencyHz or 30
    -- 阻尼率：值越大，关节运动阻尼越大。影响关节的弹性（阻尼率无单位，典型是在0到1之间, 也可以更大。1是阻尼率的临界值, 当阻尼率为1时，没有振动。）
    distanceJointDef.dampingRatio = jointInfo.dampingRatio or 0
    -- 是否连续碰撞
    distanceJointDef.collideConnected = jointInfo.collideConnected or true

    -- 创建关节
    return M.currentPhysicsWorld:CreateJoint(distanceJointDef)
end

--[[--

    创建移动关节

    ### Useage:
    local joint = ZBox2D.createPrismaticJoint(刚体对象A, 刚体对象B, 关节信息)

    ### Aliases:

    ### Notice:

    ### Example:

    ### Parameters:
    -   b2Body  **bodyA**           [必选] 要连接的刚体对象A
    -   b2Body  **bodyB**           [必选] 要连接的刚体对象B
    -   table   **jointInfo**       [必选] 关节信息



    ### OptionParameters

    ### Returns: 
    -   b2Joint                     移动关节对象

--]]
--
function M.createPrismaticJoint(bodyA, bodyB, jointInfo)
    if (not M.currentPhysicsWorld) then return end

    -- 声明移动关节结构体，结构体里面存储的都是初始化关节所需的参数。dir是关节移动的方向
    -- 创建一个移动关节的定义
    local prismaticJointDef            = b2PrismaticJointDef()

    if true then
        -- 移动的方向，用矢量来表示可以移动的方向，默认为任意方向（零向量）
        local directVec    = jointInfo.dir or b2Vec2(0, 0)
        -- 初始化关节
        prismaticJointDef:Initialize(bodyA, bodyB, bodyB:GetWorldCenter(), directVec)
    end

    -- 移动的最小距离，与方向同向为正，反向为负。启用限制后才有效果。
    prismaticJointDef.lowerTranslation = jointInfo.lowerTranslation and jointInfo.lowerTranslation / PTM_RATIO or -1
    -- 移动的最大距离，与方向同向为正，反向为负。启用限制后才有效果。
    prismaticJointDef.upperTranslation = jointInfo.upperTranslation and jointInfo.upperTranslation / PTM_RATIO or 1
    -- 是否启用限制
    prismaticJointDef.enableLimit      = ifnil(jointInfo.enableLimit, true)
    -- 是否连续碰撞
    prismaticJointDef.collideConnected = jointInfo.collideConnected or false

    -- 创建关节
    return M.currentPhysicsWorld:CreateJoint(prismaticJointDef)
end

--[[--

    创建绳索关节

    ### Useage:
    local joint = ZBox2D.createRopeJoint(刚体对象A, 刚体对象B, 关节信息)

    ### Parameters:
    -   b2Body  **bodyA**           [必选] 要连接的刚体对象A
    -   b2Body  **bodyB**           [必选] 要连接的刚体对象B
    -   table   **jointInfo**       [必选] 关节信息

    ### Returns: 
    -   b2Joint                     绳索关节对象
--]]
function M.createRopeJoint(bodyA, bodyB, jointInfo)
    if (not M.currentPhysicsWorld) then return end
    -- 创建一个绳索关节的定义
    local ropeJointDef        = b2RopeJointDef()
    -- ropeJointDef:Initialize(bodyA, bodyB, bodyA:GetWorldCenter(), bodyB:GetWorldCenter())
    -- 绳索的最大长度
    ropeJointDef.maxLength    = ifnil(jointInfo.maxLength, 4)
    -- 关节连接的刚体A
    ropeJointDef.bodyA        = bodyA
    -- 关节连接的刚体B
    ropeJointDef.bodyB        = bodyB
    -- 关节连接在刚体A上的锚点，其他关节应该也有，默认在中央
    ropeJointDef.localAnchorA = ifnil(jointInfo.localAnchorA or b2Vec2(0.5, 0.5))
    -- 关节连接在刚体B上的锚点，其他关节应该也有，默认在中央
    ropeJointDef.localAnchorB = ifnil(jointInfo.localAnchorB or b2Vec2(0.5, 0.5))
    -- 是否连续碰撞 
    ropeJointDef.collideConnected = true

    -- 创建关节
    return M.currentPhysicsWorld:CreateJoint(ropeJointDef)
end

--[[--
    创建旋转关节

    ### Useage:
    local joint = ZBox2D.createRevoluteJoint(刚体对象A, 刚体对象B, 关节信息)

    ### Parameters:
    -   b2Body  **bodyA**           [必选] 要连接的刚体对象A
    -   b2Body  **bodyB**           [必选] 要连接的刚体对象B
    -   table   **jointInfo**       [必选] 关节信息

    ### Returns: 
    -   b2RevoluteJoint             旋转关节对象
--]]
function M.createRevoluteJoint(bodyA, bodyB, jointInfo)
    if (not M.currentPhysicsWorld) then return end

    -- 创建一个旋转关节定义
    local revoluteJointDef            = b2RevoluteJointDef()
    revoluteJointDef:Initialize(bodyA, bodyB, bodyB: GetWorldCenter())
    -- 关节连接的刚体A
    revoluteJointDef.bodyA            = bodyA
    -- 关节连接的刚体B
    revoluteJointDef.bodyB            = bodyB
    -- 限制可转动的最小角度，启用角度限制后才有效果 
    revoluteJointDef.lowerAngle       = jointInfo.lowerAngle and jointInfo.lowerAngle * TO_PI or 0
    -- 限制可转动的最大角度，启用角度限制后才有效果 
    revoluteJointDef.upperAngle       = jointInfo.upperAngle and jointInfo.upperAngle * TO_PI or 0
    -- 是否启用角度限制，类似手臂只能在一定角度内旋转一样。
    revoluteJointDef.enableLimit      = jointInfo.enableLimit or false
    -- 马达的速度 
    revoluteJointDef.motorSpeed       = jointInfo.motorSpeed or 0
    -- 马达的最大扭矩
    revoluteJointDef.maxMotorTorque   = jointInfo.maxMotorTorque or 11110
    -- 是否启用旋转马达，启用后关节会自动转动
    revoluteJointDef.enableMotor      = jointInfo.enableMotor or true
    -- 频率：频率越高，关节越硬。影响关节的弹性（典型情况下，关节频率要小于一半的时间步(time step)频率。
    --  比如每秒执行60次时间步, 关节的频率就要小于30赫兹。这样做的理由可以参考Nyquist频率理论。）
    revoluteJointDef.frequencyHz      = jointInfo.frequencyHz or 30
    -- 是否连续碰撞
    revoluteJointDef.collideConnected = jointInfo.collideConnected or false
    -- 关节长度 
    revoluteJointDef.length           = jointInfo.length or 0.1

    -- 创建关节，并转换为b2RevoluteJoint类型
    return tolua.cast(M.currentPhysicsWorld:CreateJoint(revoluteJointDef), "b2RevoluteJoint")
end

--[[--

创建滑轮关节

### Useage:
local joint = ZBox2D.createPulleyJoint(刚体对象A, 刚体对象B, 关节信息)

### Aliases:

### Notice:

### Example:

### Parameters:
-   b2Body  **bodyA**           [必选] 要连接的刚体对象A
-   b2Body  **bodyB**           [必选] 要连接的刚体对象B
-   table   **jointInfo**       [必选] 关节信息



### OptionParameters

### Returns: 
-   b2Joint                     滑轮关节对象

--]]
--
function M.createPulleyJoint(bodyA, bodyB, jointInfo)
    if (not M.currentPhysicsWorld) then return end

    -- 创建一个滑轮关节定义
    local pulleyJointDef    = b2PulleyJointDef()
    local function ccpToVecRatioIfnil(point, defaultVec2, offset)
        point = point and M.ccpToVecRatio(point) or b2Vec2(default.x + offset.x, default.y + offset.y)
        return point
    end

    -- 滑轮绳子拉动的点
    local bodyWorldPointA = bodyA:GetWorldCenter()
    -- 滑轮绳子拉动的点
    local bodyWorldPointB = bodyB:GetWorldCenter()
    -- 刚体A对应的那个滑轮的位置
    local groundPointA    = ccpToVecRatioIfnil(jointInfo.groundAnchorA, bodyWorldPointA, b2Vec2(0, 10))
    -- 刚体B对应的那个滑轮的位置
    local groundPointB    = ccpToVecRatioIfnil(jointInfo.groundAnchorB, bodyWorldPointB, b2Vec2(0, 10))
    -- 比例(关节传动时，滑轮上升和下降的两头的位移比例)
    local ratio           = jointInfo.ratio or 1
    -- 初始化关节
    pulleyJointDef.Initialize(bodyA, bodyB, groundPointA, groundPointB,bodyWorldPointA, bodyWorldPointB, ratio)

    -- 绳子可拉动的最大长度
    pulleyJointDef.maxLengthA = jointInfo.maxLengthA or 5
    -- 绳子可拉动的最大长度
    pulleyJointDef.maxLengthB = jointInfo.maxLengthB or 5
    return M.currentPhysicsWorld:CreateJoint(pulleyJointDef)
end

--[[--
    创建齿轮关节
    ### Useage:
    local joint = ZBox2D.createGearJoint(刚体对象A, 刚体对象B, 关节信息)

    ### Aliases:

    ### Notice:

    ### Example:

    ### Parameters:
    -   b2Body  **bodyA**           [必选] 要连接的刚体对象A
    -   b2Body  **bodyB**           [必选] 要连接的刚体对象B
    -   table   **jointInfo**       [必选] 关节信息

    ### Returns: 
    -   b2Joint                     齿轮关节对象
--]]
function M.createGearJoint(bodyA, bodyB, jointInfo)
    if (not M.currentPhysicsWorld) then return end

    -- 创建一个齿轮关节
    local gearJointDef = b2GearJointDef()
    -- 齿轮关节关联的关节1，释放这两个关节时需要先释放齿轮关节，否则会引起空指针错误。
    gearJointDef.joint1 = jointInfo.joint1
    -- 齿轮关节关联的关节2，释放这两个关节时需要先释放齿轮关节，否则会引起空指针错误。 
    gearJointDef.joint2 = jointInfo.joint2
    -- 关节连接的刚体A
    gearJointDef.bodyA = bodyA
    -- 关节连接的刚体B
    gearJointDef.bodyB = bodyB
    -- 关节比例（齿轮系数）
    gearJointDef.ratio = jointInfo.ratio or 1

    return M.currentPhysicsWorld:CreateJoint(gearJointDef)
end

--[[--
    创建轮子关节

    ### Useage:
    local joint = ZBox2D.createWheelJoint(刚体对象A, 刚体对象B, 关节信息)

    ### Aliases:

    ### Notice:

    ### Example:

    ### Parameters:
    -   b2Body  **bodyA**           [必选] 要连接的刚体对象A
    -   b2Body  **bodyB**           [必选] 要连接的刚体对象B
    -   table   **jointInfo**       [必选] 关节信息

    ### OptionParameters

    ### Returns: 
    -   b2Joint                     轮子关节对象
--]]
function M.createWheelJoint(bodyA, bodyB, jointInfo)
    if (not M.currentPhysicsWorld) then return end

    -- 创建一个轮子关节定义
    local wheelJointDef          = b2WheelJointDef()
    if true then
        -- 用坐标表示轮子轴的位置
        local axis               = jointInfo.axis or b2Vec2(1, 0)
        -- 初始化关节
        wheelJointDef:Initialize(bodyA, bodyB, bodyB:GetWorldCenter(), axis)
    end
    -- 是否启用马达
    wheelJointDef.enableMotor    = jointInfo.enableMotor or false
    -- 马达速度
    wheelJointDef.motorSpeed     = jointInfo.motorSpeed or 0
    -- 马达的最大扭矩 
    wheelJointDef.maxMotorTorque = jointInfo.maxMotorTorque or 0
    -- 频率：频率越高，关节越硬。影响关节的弹性（典型情况下，关节频率要小于一半的时间步(time step)频率。
    --  比如每秒执行60次时间步, 关节的频率就要小于30赫兹。这样做的理由可以参考Nyquist频率理论。）
    wheelJointDef.frequencyHz    = jointInfo.frequencyHz or 30
    -- 阻尼率：值越大，关节运动阻尼越大。影响关节的弹性（阻尼率无单位，典型是在0到1之间, 也可以更大。1是阻尼率的临界值, 当阻尼率为1时，没有振动。）
    wheelJointDef.dampingRatio   = jointInfo.dampingRatio or 0.2

    -- 创建关节 
    return tolua.cast(M.currentPhysicsWorld:CreateJoint(wheelJointDef), "b2WheelJoint")
end

--[[--

    创建摩擦关节

    ### Useage:
    local joint = ZBox2D.createFrictionJoint(刚体对象A, 刚体对象B, 关节信息)

    ### Aliases:

    ### Notice:
    摩擦关节用于阻碍两个刚体的相对运动。

    ### Example:

    ### Parameters:
    -   b2Body  **bodyA**           [必选] 要连接的刚体对象A
    -   b2Body  **bodyB**           [必选] 要连接的刚体对象B
    -   table   **jointInfo**       [必选] 关节信息

    ### Returns: 
    -   b2Joint                     摩擦关节对象
--]]
function M.createFrictionJoint(bodyA, bodyB, jointInfo)
    if (not M.currentPhysicsWorld) then return end
    -- 创建一个摩擦关节定义
    local frictionJointDef        = b2FrictionJointDef()

    -- -- 相对于bodyA原点的局部锚点。
    -- frictionJointDef.localAnchorA = jointInfo.localAnchorA or bodyA:GetWorldCenter()
    -- -- 相对于bodyB原点的局部锚点。
    -- frictionJointDef.localAnchorB = jointInfo.localAnchorB or bodyB:GetWorldCenter()
    -- -- 是否使用默认锚点
    -- if jointInfo.localAnchorA and jointInfo.localAnchorB then
        -- 初始化关节
        -- frictionJointDef:Initialize(bodyA, bodyB, bodyB:GetWorldCenter())
    -- end
    frictionJointDef:Initialize(bodyA, bodyB, bodyB:GetWorldCenter())
    -- 阻尼率：值越大，关节运动阻尼越大。影响关节的弹性（阻尼率无单位，典型是在0到1之间, 也可以更大。1是阻尼率的临界值, 当阻尼率为1时，没有振动。）
    frictionJointDef.dampingRatio = jointInfo.dampingRatio or 0
    -- 最大摩擦力N
    frictionJointDef.maxForce     = jointInfo.maxForce or 0
    -- 最大摩擦力矩，单位为N-m
    frictionJointDef.maxTorque    = jointInfo.maxTorque or 0
    return tolua.cast(M.currentPhysicsWorld:CreateJoint(frictionJointDef), "b2FrictionJoint")
end














-------------------------------------------------------------------------
-- 辅助型函数 
------------------------------------------------------------------------- 
--[[--
将opengl坐标转换成box2d矢量坐标。

### Useage:
    local vec = ZBox2D.ccpToVec(坐标)
    
### Aliases:

### Notice:
    二者转换的时候进行了一定的比例缩放。
    
### Example:
    ----------------------
    -- 示例1: 通用操作
    ----------------------
    local vec = ZBox2D.ccpToVec(cc.p(300, 400))
    
### Parameters:
-   CCPoint     **point**           [必选] opengl坐标

### OptionParameters

### Returns: 
-   b2Vec2                           矢量坐标

--]]
--
function M.ccpToVec(point)
    return b2Vec2(point.x / PTM_RATIO, point.y / PTM_RATIO)
end
M.ccpToVecRatio = M.ccpToVec
--[[--

将box2d矢量坐标转换成opengl坐标。

### Useage:
    local point = ZBox2D.vecToPoint(矢量)
    
### Aliases:

### Notice:
    二者转换的时候进行了一定的比例缩放。

### Example:
    ----------------------
    -- 示例1: 通用操作
    ----------------------
    local point = ZBox2D.vecToPoint(b2Vec2(30, 40))
    
### Parameters:
-   b2Vec2  **vec**                 [必选] 矢量坐标

### OptionParameters

### Returns: 
-   CCPoint                         opengl坐标 

--]]
--
function M.vecToPoint(vec)
    return cc.p(vec.x * PTM_RATIO, vec.y * PTM_RATIO)
end

--[[--
    开启调试渲染
    ### Useage:
        ZBox2D.openDebug(layer)

    ### Notice:
        根据物理模拟的信息在场景内绘制刚体形状和关节。

    ### Example:
        
    ### Parameters:
    -   CCNode  **node**             [必选] 用于显示绘制的刚体区域和关节的父节点。
    -   bool    **isOpen**           [可选] 是否打开调试      
--]]
function M.openDebug(node, isOpen)
    if isOpen then
        local debugDraw = GB2DebugDrawLayer:create(M.currentPhysicsWorld, PTM_RATIO)
        node:add(debugDraw, 9999)
    end
end
M.openDebugRender    = M.openDebug

--[[--
    设置刚体位置和旋转角度

    ### Useage:
        ZBox2D.setBodyPositionAndAngle(刚体对象, 坐标, 弧度)
        
    ### Aliases:

    ### Notice:
        box2d坐标使用b2Vec2类型，所以这边的坐标要先转换为b2Vec2类型。
        box2d坐标使用弧度制，所以这边的角度要先转换为弧度制。

    ### Parameters:
    -   b2Body  **body**        [必选] 刚体对象
    -   b2Vec2  **position**    [必选] box2d坐标
    -   float   **angle**       [必选] 刚体弧度
--]]
function M.setBodyPositionAndAngle(body, position, angle)
    if body then
        -- b2Vec2矢量类型
        position    = position or body:GetPosition()
        -- box2d的角度都是以弧度形式表示
        angle    = angle or body:GetAngle()

        body:SetTransform(position, angle)
    end
end
M.setTransform = M.setBodyPositionAndAngle



--[[--
    设置刚体位置
    ### Useage:
        ZBox2D.setBodyPosition(刚体对象, opengl坐标)
        
    ### Aliases:

    ### Notice:
        box2d坐标和opengl坐标存在比例关系，所以这边传参的坐标会被转换成b2Vec2类型的box2d坐标。
        
    ### Parameters:
    -   b2Body  **body**        [必选] 刚体对象
    -   CCPoint **position**    [必选] opengl坐标
--]]
function M.setBodyPosition(body, position)
    if body then
        -- b2Vec2矢量类型
        position    = position and M.ccpToVec(position) or body:GetPosition()

        M.setBodyPositionAndAngle(body, position)
    end
end



--[[--
    属性[获取刚体的碰撞种群索引]
    ### Parameters:
    -   b2Body     **body**                 [必选] 刚体对象

    ### Returns: 
    -   number                             碰撞种群索引
--]]
function M.getGroupIndex(body)
    if body then
        local fixture = body:GetFixtureList()

        if fixture then
            local filter = fixture:GetFilterData()

            if filter then
                return filter.groupIndex
            end
        end
    end
    return body:GetFixtureList():GetFilterData().groupIndex
end

--[[--
    属性[设置刚体的碰撞种群索引]

    ### Notice:
        box2D支持16种碰撞种群，用于做碰撞筛选。

    ### Parameters:
    -   b2Body     **body**                 [必选] 刚体对象
    -   number     **groupIndex**           [必选] 碰撞种群索引(取值区间是[0,15])
--]]
function M.setGroupIndex(body, groupIndex)
    body:GetFixtureList():GetFilterData().groupIndex = groupIndex or 0
end








--========================================================================
-- 析构型函数 
--======================================================================== 
--[[--
    摧毁世界

    ### Useage:
        ZBox2D.destroyWorld(刚体对象, 物理世界对象)
        
    ### Aliases:

    ### Notice:
        销毁对象，并返回一个空值。
        因为创建物理世界时会将其保存在一个全局变量里面，方便访问。所以当不需要时，一定要手动销毁。
        
    ### Example:
        ----------------------
        -- 示例1: 通用操作
        ----------------------
        local World = ZBox2D.createWorld( ... )
        World       = ZBox2D.destroyWorld(World)
        
    ### Parameters:
    -   b2World     **body**            [必选] 要被销毁的物理世界对象

    ### Returns: 
    -   null                             空值
--]]
function M.destroyWorld(world)
    world = world or M.currentPhysicsWorld
    if not world then return end
    do
        -- 获得刚体
        local body = M.currentPhysicsWorld:GetBodyList()
        while body do
            world:DestroyBody(body)
            -- 获得下一个body
            body = body:GetNext()
        end
    end

    do
        -- 获得关节
        local joint = world:GetJointList()
        while joint do 
            world:DestroyJoint(joint)
            -- 获得下一个joint
            joint = joint:GetNext()
        end
    end

    if  M.timer then
        scheduler.unscheduleGlobal(M.timer)
        M.timer = nil
    end
    world = nil
    M.currentPhysicsWorld = nil
    return nil
end


--[[--
    摧毁刚体
    ### Useage:
        ZBox2D.destroyBody(刚体对象, 物理世界对象)
        
    ### Notice:
        销毁对象，并返回一个空值。
        
    ### Example:
        ----------------------
        -- 示例1: 通用操作
        ----------------------
        local body  = ZBox2D.createBody( ... )
        body        = ZBox2D.destroyBody(body)
        
    ### Parameters:
    -   b2Body      **body**            [必选] 要被销毁的刚体对象
    -   b2World     **world**           [可选] 物理世界对象

    ### OptionParameters
        
    ### Returns: 
    -   null                             空值
--]]
function M.destroyBody(body, world)
    world = world or M.currentPhysicsWorld
    if body and world then
        world:DestroyBody(body)
    end

    return nil
end

--[[--
    摧毁关节

    ### Useage:
        ZBox2D.destroyJoint(关节对象, 物理世界对象)
        
    ### Notice:
        销毁对象，并返回一个空值。
        
    ### Example:
        ----------------------
        -- 示例1: 通用操作
        ----------------------
        local joint = ZBox2D.createMouseJoint( ... )
        joint       = ZBox2D.destroyJoint(joint)
        
    ### Parameters:
    -   b2Joint     **joint**           [必选] 要被销毁的关节对象
    -   b2World     **world**           [可选] 物理世界对象

    ### Returns: 
    -   null                             空值
--]]
function M.destroyJoint(joint, world)
    world = world or M.currentPhysicsWorld
    if joint and world then
        world:DestroyJoint(joint)
    end
    return nil
end







-----------------------------------------------------------------------------------------
-- 刚体切割
-----------------------------------------------------------------------------------------
--[[
    辅助方法
]]
-- 多边形最大点数
local b2_maxPolygonVertices   = 9
-- 浮点数小量
local b2_epsilon              = 1.192093 * math.pow(10, -7)
local function b2Vec2Copy(a)
    return b2Vec2(a.x, a.y)
end
local function b2Vec2Minus(a, b)
    return b2Vec2(a.x - b.x, a.y - b.y)
end
local function calculate_determinant_2x3(x1, y1, x2, y2, x3, y3) 
    return (x1 * y2 + x2 * y3 + x3 * y1 - y1 * x2 - y2 * x3 - y3 * x1)
end

local function midpoint(a, b) 
    return (a + b) / 2
end
-- 排列点集
local function sortVertices(targets)
    local end_ = table.getn(targets)
    for i = 0, end_ - 1 do
        for j = i + 1, end_ do
            local t1 = targets[i]
            local t2 = targets[j]
            local x1, x2 = t1.x, t2.x
            local fix = false
            if x1 < x2 then 
                fix = true
            end

            if not fix then -- swap 
                local temp = targets[i]
                targets[i] = targets[j]
                targets[j] = temp
            end
        end
    end
    return targets
end

local function tocstrvec2(t, from)
    local result = ""
    if from == nil then 
        from = 1
    end

    local n = #t
    for i = from, n do
        result = result .. t[i].x .. "," .. t[i].y .. "|"
    end
    return string.sub(result, 1, #result - 1)
end

-- 此方法按照逆时针的顺序重排顶点. 它使用qsort方法按x坐标升序排列,然后使用determinants来完成最终的重排.
local function arrangeVertices(vertices, count)
    local determinant
    local iCounterClockWise     = 1
    local iClockWise            = count - 1
    local i
    local referencePointA,referencePointB
    local sortedVertices        = {}

    -- 根据位置x进行排序
    sortVertices(vertices)
    sortedVertices[0]           = vertices[0]
    referencePointA             = vertices[0]         
    referencePointB             = vertices[count - 1] 
    for i = 1, count - 1 - 1 do
        determinant = calculate_determinant_2x3(
            referencePointA.x, 
            referencePointA.y, 
            referencePointB.x, 
            referencePointB.y, 
            vertices[i].x, 
            vertices[i].y)
        if determinant < 0 then
            sortedVertices[iCounterClockWise] = vertices[i]
            iCounterClockWise = iCounterClockWise + 1
        else 
            sortedVertices[iClockWise] = vertices[i]
            iClockWise = iClockWise - 1
        end
    end
    sortedVertices[iCounterClockWise] = vertices[count - 1]
    return sortedVertices
end

-- 此方法假设所有的顶点都是合理的.
local function areVerticesAcceptable(vertices, count) 
    --定点小于3不构成平面图形
    if count < 3 then
        return false
    end
    --顶点数量超过上限
    if count > b2_maxPolygonVertices then
        return false
    end
    local i
    for i = 0, count - 1 do
        local i1 = i
        local i2 = 0
        if i + 1 < count then 
            i2 = i + 1 
        end
        local edge = b2Vec2Minus(vertices[i2], vertices[i1]) 

        --相邻两个点的距离小于b2_epsilon，切割失败
        if edge:LengthSquared() <= b2_epsilon * b2_epsilon then
            return false
        end
    end
    --图形面积
    local area = 0.0
    local pRef = b2Vec2(0.0, 0.0)
    for i = 0, count - 1 do
        local p1 = pRef
        local p2 = vertices[i]
        local p3 = nil

        if i + 1 < count then
            p3 = vertices[i + 1] 
        else
            p3 = vertices[0]
        end
        local e1 = b2Vec2Minus(p2, p1)      -- p2 - p1
        local e2 = b2Vec2Minus(p3, p1)      -- p3 - p1
        local D  = b2Cross(e1, e2)
        --计算相邻两个向量组成的三角形的面积
        local triangleArea = 0.5 * D
        area = area + triangleArea
    end
    if area <= b2_epsilon then
        return false
    end
    --计算每一条边与不在边上的其他顶点组成的三角形的面积s，s<0，切割失败
    for i = 0, count - 1 do
        local i1 = i
        local i2 = 0
        if i + 1 < count then
            i2 = i + 1 
        end
        local edge = b2Vec2Minus(vertices[i2], vertices[i1]) 
        for j = 0, count - 1 do
            if not (j == i1 or j == i2) then
                local r = b2Vec2Minus(vertices[j], vertices[i1]) 
                local s = b2Cross(edge, r)
                if s < 0.0 then
                    return false
                end
            end
        end
    end
    --改变数组索引，从1开始
    local verticesCopy = {}
    for i = 0, count - 1 do
        table.insert(verticesCopy,vertices[i])
    end
    --当count大于三，表示不是三角形
    if count > 3 then 
        local flag = false
        --判断多边形的所有对角线，只要有一条对角线大于9就满足切割条件
        for i = 1, count - 1 do
            local vec1 = verticesCopy[1]
            local pos1 = cc.p(verticesCopy[1].x * PTM_RATIO, verticesCopy[1].y * PTM_RATIO)
            for j = 3, count - 1 do
                local pos2 = cc.p(verticesCopy[j].x * PTM_RATIO, verticesCopy[j].y * PTM_RATIO)
                if cc.pGetDistance(pos1, pos2) > 9 then 
                    flag = true
                end
            end
            table.remove(verticesCopy,1)
            table.insert(verticesCopy,vec1)
        end
        return flag
        --三角形
    else
        local pos1 = cc.p(verticesCopy[1].x * PTM_RATIO, verticesCopy[1].y * PTM_RATIO)
        local pos2 = cc.p(verticesCopy[2].x * PTM_RATIO, verticesCopy[2].y * PTM_RATIO)
        local pos3 = cc.p(verticesCopy[3].x * PTM_RATIO, verticesCopy[3].y * PTM_RATIO)
        local a = cc.pGetDistance(pos1, pos2)
        local b = cc.pGetDistance(pos2, pos3)
        local c = cc.pGetDistance(pos1, pos3)
        local p = (a + b + c) / 2
        local area = math.sqrt(p*(p - a)*(p -b)*(p -c))
        --三角形面积小于20，切割失败
        if area < 20 then 
            return false
        end
    end
    return true
end

--  参数解析：物理世界、位置、旋转角度、顶点列表、顶点数、密度、摩擦力、恢复力,线性阻尼，角度阻尼
local function createSplitBody(info)
    local bodydef, body, fixtureDef 
    local world             = info.world or M.currentPhysicsWorld
    local position          = info.position
    local rotation          = info.rotation
    local vertices          = info.vertices
    local count             = info.count
    local density           = info.density
    local friction          = info.friction
    local restitution       = info.restitution
    local linearDamping     = info.linearDamping
    local angularDamping    = info.angularDamping
    -- 创建刚体
    bodydef                 = b2BodyDef()
    bodydef.type            = b2_dynamicBody
    bodydef.position        = position
    bodydef.angle           = rotation
    bodydef.linearDamping   = linearDamping == 0 and  10 or linearDamping
    bodydef.angularDamping  = angularDamping == 0 and  10 or angularDamping
    body                    = world:CreateBody(bodydef)
    -- 绑定材质
    local fixtureDef        = b2FixtureDef()
    fixtureDef.density      = density
    fixtureDef.friction     = friction
    fixtureDef.restitution  = restitution
    -- 绑定材质形状
    local shape             = b2PolygonShape()
    shape:Set(BridgeUtils:arrb2Vec2(tocstrvec2(vertices, 0)), count)
    fixtureDef.shape        = shape  
    body:CreateFixture(fixtureDef)
    return body
end

-- 切割多边形精灵
local function splitPolygonSprite(sprite)
    local flag                  = false
    local flag2                 = false
    local newSprite1            = nil
    local newSprite2            = nil
    -- 原始夹具
    local originalFixture       = sprite:getBody():GetFixtureList()
    -- 原始多边形
    local originalPolygon       = tolua.cast(originalFixture:GetShape(), "b2PolygonShape")
    -- 原始顶点数
    local vertexCount           = originalPolygon:GetVertexCount()
    -- 行列式 
    local determinant
    local i
    -- 精灵1/精灵2 的点集
    local sprite1Vertices       = {} 
    local sprite2Vertices       = {} 
    local sprite1VerticesSorted 
    local sprite2VerticesSorted 
    -- 精灵1/精灵2 的点数
    local sprite1VertexCount    = 0 
    local sprite2VertexCount    = 0 
    -- 冲量系数
    local coefficient = 3
    -- #entryPoint  切割线首次和多边形接触的点
    -- #exitPoint   切割线第二次和多边形接触的点
    sprite1Vertices[sprite1VertexCount] = b2Vec2Copy(sprite:getEntryPoint())
    sprite1VertexCount = sprite1VertexCount + 1
    sprite1Vertices[sprite1VertexCount] = b2Vec2Copy(sprite:getExitPoint())
    sprite1VertexCount = sprite1VertexCount + 1

    sprite2Vertices[sprite2VertexCount] = b2Vec2Copy(sprite:getEntryPoint())
    sprite2VertexCount = sprite2VertexCount + 1
    sprite2Vertices[sprite2VertexCount] = b2Vec2Copy(sprite:getExitPoint())
    sprite2VertexCount = sprite2VertexCount + 1 
    -- 区分切割中精灵顶点的归属权
    for i = 0, vertexCount - 1 do
        local point              = originalPolygon:GetVertex(i)
        local diffFromEntryPoint = b2Vec2Minus(point, sprite:getEntryPoint())   
        local diffFromExitPoint  = b2Vec2Minus(point, sprite:getExitPoint())     
        if not ((diffFromEntryPoint.x == 0 and diffFromEntryPoint.y == 0) or 
            (diffFromExitPoint.x == 0 and diffFromExitPoint.y == 0)) then
            determinant = calculate_determinant_2x3(
                sprite:getEntryPoint().x, 
                sprite:getEntryPoint().y,
                sprite:getExitPoint().x,
                sprite:getExitPoint().y, 
                point.x, 
                point.y)
            if determinant > 0 then
                sprite1Vertices[sprite1VertexCount] = point
                sprite1VertexCount = sprite1VertexCount + 1
            else
                sprite2Vertices[sprite2VertexCount] = point
                sprite2VertexCount = sprite2VertexCount + 1
            end
        end
    end
    --按照逆时针的顺序重排顶点
    sprite1VerticesSorted = arrangeVertices(sprite1Vertices, sprite1VertexCount)
    sprite2VerticesSorted = arrangeVertices(sprite2Vertices, sprite2VertexCount)
    -- 假设所有的顶点都是合理的
    local sprite1VerticesAcceptable = areVerticesAcceptable(sprite1VerticesSorted, sprite1VertexCount)
    local sprite2VerticesAcceptable = areVerticesAcceptable(sprite2VerticesSorted, sprite2VertexCount)
    if sprite1VerticesAcceptable and sprite2VerticesAcceptable then 
        -- DA.sendEvent("lyd035","饮料切水果-切成功")
        local worldEntry    = sprite:getBody():GetWorldPoint(sprite:getEntryPoint())
        local worldExit     = sprite:getBody():GetWorldPoint(sprite:getExitPoint())
        local angle         = ccpToAngle(ccpSub(ccp(worldExit.x, worldExit.y), ccp(worldEntry.x, worldEntry.y)))
        local vector1       = ccpForAngle(angle + 1.570796)
        local vector2       = ccpForAngle(angle - 1.570796)
        local midX          = midpoint(worldEntry.x, worldExit.x)
        local midY          = midpoint(worldEntry.y, worldExit.y)
        -- 创建新的刚体精灵1
        local body1         = createSplitBody({
            world           = world, 
            position        = sprite:getBody():GetPosition(), 
            rotation        = sprite:getBody():GetAngle(), 
            vertices        = sprite1VerticesSorted, 
            count           = sprite1VertexCount, 
            density         = originalFixture:GetDensity(), 
            friction        = originalFixture:GetFriction(), 
            restitution     = originalFixture:GetRestitution(),
            linearDamping   = sprite:getBody():GetLinearDamping(),
            angularDamping  = sprite:getBody():GetAngularDamping()
        })
        newSprite1          = GB2SpritePRKit:create(sprite:getTexture(), body1, false, PTM_RATIO)
        -- # ApplyLinearImpulse() 申请线性冲量 参数含义：1.冲量值[向量], 2.作用点位置[点][默认为两切割点的中心点]
        newSprite1:getBody():ApplyLinearImpulse(
            b2Vec2(coefficient * body1:GetMass() * vector1.x, coefficient * body1:GetMass() * vector1.y), 
            b2Vec2(midX, midY)
        )
        sprite:getParent():addChild(newSprite1, sprite:getZOrder()) 

        -- 创建新的刚体精灵2 
        local body2 = createSplitBody({
            world           = world, 
            position        = sprite:getBody():GetPosition(), 
            rotation        = sprite:getBody():GetAngle(), 
            vertices        = sprite2VerticesSorted, 
            count           = sprite2VertexCount, 
            density         = originalFixture:GetDensity(), 
            friction        = originalFixture:GetFriction(),  
            restitution     = originalFixture:GetRestitution(),
            linearDamping   = sprite:getBody():GetLinearDamping(),
            angularDamping  = sprite:getBody():GetAngularDamping()})
        newSprite2          = GB2SpritePRKit:create(sprite:getTexture(), body2, false, PTM_RATIO)
        newSprite2:getBody():ApplyLinearImpulse(
            b2Vec2(coefficient * body2:GetMass() * vector2.x, coefficient * body2:GetMass() * vector2.y), 
            b2Vec2(midX, midY)
        )
        newSprite2:setVisible(true)
        sprite:getParent():addChild(newSprite2, sprite:getZOrder())

        --切割成功
        flag2 = true
        -- 获取原精灵
        if sprite:getOriginal() then 
            local convertedWorldEntry   = b2Vec2(worldEntry.x * PTM_RATIO,worldEntry.y * PTM_RATIO)
            local convertedWorldExit    = b2Vec2(worldExit.x  * PTM_RATIO,worldExit.y  * PTM_RATIO)
            local midX = midpoint(convertedWorldEntry.x, convertedWorldExit.x)
            local midY = midpoint(convertedWorldEntry.y, convertedWorldExit.y)
            -- 解除碰撞
            sprite:deactivateCollisions()
            -- 重置参数
            sprite:setPosition(ccp(-10012, -10012))
            sprite:setSliceEntered(false)
            sprite:setSliceExited(false)
            sprite:setEntryPoint(b2Vec2(0, 0))
            sprite:setExitPoint(b2Vec2(0, 0))
        else
            flag = true
        end
    else
        sprite:setSliceEntered(false)
        sprite:setSliceExited(false)
    end
    -- 参数重置
    sprite1VerticesSorted   = nil
    sprite2VerticesSorted   = nil
    sprite1Vertices         = nil
    sprite2Vertices         = nil
    
    return flag2
end

-- 检查切割物体对象
local function checkAndSliceObjects(callback)
    local world = M.currentPhysicsWorld
    -- 旧刚体[将移除]
    local _oldBodyToDel = {}
    -- 获取物理世界刚体列表中的刚体
    local b = world:GetBodyList()
    while b do
        if b:GetUserData() then
            -- 转换类型
            local sprite = tolua.cast(b:GetUserData(), "GB2SpritePRKit")
            -- 如果有切割线进入，并且完成了一次完整的切割，执行精灵切割
            if sprite:getSliceEntered() and sprite:getSliceExited() then
                local worldEntry    = sprite:getBody():GetWorldPoint(sprite:getEntryPoint())
                local worldExit     = sprite:getBody():GetWorldPoint(sprite:getExitPoint())
                -- print("11===", worldEntry.x * PTM_RATIO, worldEntry.y * PTM_RATIO)
                -- print("222====", worldExit.x * PTM_RATIO, worldExit.y * PTM_RATIO)
                if  cc.pGetDistance(M.vecToPoint(worldEntry), M.vecToPoint(worldExit)) > 10 then
                    -- 切割函数
                    local flag = splitPolygonSprite(sprite)  
                    if flag  then     
                        -- 切割回调（返回切入点与切出点的世界坐标）
                        if callback then
                            callback(worldEntry, worldExit)
                        end
                        table.insert(_oldBodyToDel, sprite)
                    end
                end

            end       
        end
        -- 获取下一个刚体
        b = b:GetNext()
    end
    -- 移除物理世界中的废弃刚体精灵
    for i = 1, #_oldBodyToDel do
        local sprite = _oldBodyToDel[i]
        world:DestroyBody(sprite:getBody())
        sprite:getParent():removeChild(sprite, true)
    end
    _oldBodyToDel = nil
end

--从plist文件里提取点
local function getVerticesByPlist(plist, fileName)
    local vertices      = {}
    local shape         = nil
    local dict          = cc.FileUtils:getInstance():getValueMapFromFile(plist)
    local bodyArr       = dict["bodies"]
    local body          = bodyArr[fileName]                    
    local fixtureList   = body["fixtures"]
    local fixtureDict   = fixtureList[1]                              
     local fixtureType  = fixtureDict["fixture_type"]
    if fixtureType == "POLYGON" then
        local polygonData = fixtureDict["polygons"]
        for i,v in ipairs(polygonData) do
           local dataArr = v  

           for j,v1 in ipairs(v) do
                local pStr = cc.PointFromString(v1)
                local point = cc.p(pStr.x / PTM_RATIO  / 2, pStr.y / PTM_RATIO / 2)
                table.insert(vertices, point)           
           end
        end
    end
    return vertices
end





-- 创建切割用的刚体
    --[[--
    设置刚体位置和旋转角度

    ### Useage:
        ZBox2D.createGB2SpritePRKit(世界, 资源路径, 刚体的顶点集， 顶点数量，刚体信息， 位置)
    ### Parameters:
    -   b2World    **world**          [必选] 世界
    -   string     **image**          [必选] 节点资源路径
    -   string     **plistPath**      [必选] plist夹具资源
    -   string     **key**            [必选] plist文件关键字
    -   table      **bodyInfo**       [必选] 刚体信息
--]]
function M.createGB2SpritePRKit(world, image, plistPath, key, bodyInfo)
    world = world       or M.currentPhysicsWorld
    bodyInfo = bodyInfo or {}
    local vert                     = getVerticesByPlist(plistPath, key)
    local count, vertices          = #vert, tocstrvec2(vert)
    -- 创建刚体
    local bodyDef                  = M.createBodyDef(bodyInfo)
    local body                     = world: CreateBody(bodyDef)
    -- 场景夹具
    local fixtureDef               = b2FixtureDef()
    fixtureDef.density             = bodyInfo.density       or 1
    fixtureDef.friction            = bodyInfo.friction      or 0
    fixtureDef.restitution         = bodyInfo.restitution   or 0
    fixtureDef.isSensor            = bodyInfo.isSensor      or false
    fixtureDef.linearDamping       = bodyInfo.linearDamping or 10

    -- 绑定材质形状
    local shape                    = b2PolygonShape()
    shape:Set(BridgeUtils:arrb2Vec2(vertices), count)
    fixtureDef.shape               = shape  
    release_print("=====createGB2SpritePRKit=====1")
    body:CreateFixture(fixtureDef)
    release_print("=====createGB2SpritePRKit=====2")
    local node = GB2SpritePRKit:create(image, body, false, PTM_RATIO)
    return node
end

-- 执行切割
function M.sliceBody(startPoint, endPoint, x, y)
    local location = cc.p(x, y)
    if ccpLengthSQ(ccpSub(startPoint, location)) > 25 then 
        M.currentPhysicsWorld:RayCast(M.currentRaycastCallback, 
            M.ccpToVec(startPoint),   M.ccpToVec(location)
        )
        M.currentPhysicsWorld:RayCast(M.currentRaycastCallback,
            M.ccpToVec(location),   M.ccpToVec(startPoint)
        )
        endPoint = startPoint
        startPoint = location
    end

    return startPoint, endPoint  
end

-- 切割初始化 callback:每次切割成功回调
function M.sliceInit(callback)
    M.sliceTick = function (dt)
        checkAndSliceObjects(callback)
    end
end
-- 切割销毁
function M.sliceDestroy(callback)
    M.sliceTick = nil
end

-- 重设切割参数
function M.clearSlices(world)
    local b = world:GetBodyList()
    local count = 0
    while b do
        count = count + 1
        if b:GetUserData() then
            local sprite = tolua.cast(b:GetUserData(), "GB2SpritePRKit")
            sprite:setSliceEntered(false)
            sprite:setSliceExited(false)
        end
        b = b:GetNext()
    end
end

-- 切割开始
function M.sliceBegan(x,y, world, raycastCallback)
    if world then
        M.currentPhysicsWorld = world
    end
    if raycastCallback then
        M.currentRaycastCallback = raycastCallback
    else
        M.currentRaycastCallback = GB2RayCastCallbackPRKit()
    end
    -- 重设切割参数
    M.clearSlices(M.currentPhysicsWorld)
    -- 记录切割起始点
    M.startP            = cc.p(x, y)    
    M.startSlicePoint   = cc.p(x, y)
    M.lastSlicePoint    = M.startSlicePoint
end

-- 切割移动
function M.sliceMoved(x,y)
    local point = cc.p(x,y)
    M.startSlicePoint, M.lastSlicePoint = M.sliceBody(M.startSlicePoint, M.lastSlicePoint, x, y)
end

-- 切割结束
function M.sliceEnded(x,y)
    if x and y then
        local endPoint = cc.p(x,y)
        local world    = M.currentPhysicsWorld
        local vector   = M.ccpToVec(endPoint)
        local aabb     = PS.newAABB(vector)
        -- 查询在物理世界中接触到的材质
        local callback = GB2QueryCallbackSimple(vector)
        world:QueryAABB(callback, aabb)
        local count = 0
        -- 停在刚体上
        if callback:getFixture() then   
            ---进入切割
            local body = callback:getFixture():GetBody()
            local sprite = tolua.cast(body:GetUserData(), "GB2SpritePRKit")
            if sprite:getSliceEntered()  then
                M.endPointInsideTheBody(sprite, x, y)
            else
                -- 点击开始结束都在刚体内部（以起始点终点做延长线切割一次）判断下不是同个点才切。不然点击会闪退
                M.allInsideTheBody(world, sprite, x, y)
            end
        else    
            -- 结束的点在刚体外部
            M.endPointOutsideTheBody(world, sprite, x, y)
        end
    end
    M.startSlicePoint   = nil
    M.lastSlicePoint    = nil
end

-- 结束的点在刚体内部
function M.endPointInsideTheBody(sprite, x, y)
    local count = 0
    local p = cc.p(x,y)
    local direction = cc.pSub(p, M.startSlicePoint)
    local d = cc.pGetLength(direction)

    while not sprite:getSliceExited() do
        count = count + 1
        if count > 500 then
            count = 0
            break
        end
        p.x = p.x + direction.x / d 
        p.y = p.y + direction.y / d 
        M.startSlicePoint, M.lastSlicePoint = M.sliceBody(M.startSlicePoint, M.lastSlicePoint, p.x, p.y)
    end
end

-- 开始和结束的点都在刚体内部
function M.allInsideTheBody(world, sprite, x, y)
    local endPoint = cc.p(x, y)
    local count = 0
    -- 点击开始结束都在刚体内部（以起始点终点做延长线切割一次）判断下不是同个点才切。不然点击会闪退
    if M.startSlicePoint and (M.startSlicePoint.x~=x or M.startSlicePoint.y~=y) then
        local p1 = M.startP
        local direction1 = cc.pSub(M.startP, endPoint)
        local d1 = cc.pGetLength(direction1)
    
        local p2 = endPoint
        local direction2 = cc.pSub(endPoint, M.startP)
        local d2 = cc.pGetLength(direction2)
        while not sprite:getSliceExited() do
            count = count + 1
            if count > 500 then
                count = 0
                break
            end

            p1.x = p1.x + direction1.x / d1 * 10 
            p1.y = p1.y + direction1.y / d1 * 10
            
            p2.x = p2.x + direction2.x / d2 * 10
            p2.y = p2.y + direction2.y / d2 * 10
   
            world:RayCast(M.currentRaycastCallback, 
                M.ccpToVec(p1),  M.ccpToVec(p2)
            )
            world:RayCast(M.currentRaycastCallback,
                M.ccpToVec(p2),  M.ccpToVec(p1)
            )
        end
    end
end

-- 结束的点在刚体外部
function M.endPointOutsideTheBody(world, sprite, x, y)
    local vector   = M.ccpToVec(M.startP)
    local aabb     = PS.newAABB(vector)
    -- 查询在物理世界中接触到的材质
    local callback = GB2QueryCallbackSimple(vector)
    world:QueryAABB(callback, aabb)
    local count = 0
    -- 从刚体内部切到外部
    if callback:getFixture() then  
        local body = callback:getFixture():GetBody()
        local sprite = tolua.cast(body:GetUserData(), "GB2SpritePRKit")
        if sprite:getSliceEntered()  then
            local p = cc.p(x,y)
            local direction = cc.pSub(p, M.startP)
            local d = cc.pGetLength(direction)
            while not sprite:getSliceExited() do
                if not count then count = 0 end
                count = count + 1
                if count > 500 then
                    count = 0
                    break
                end
                p.x = p.x - direction.x / d * 5 
                p.y = p.y - direction.y / d * 5 
                M.startSlicePoint, M.lastSlicePoint = M.sliceBody(M.startSlicePoint, M.lastSlicePoint, p.x, p.y)
            end

        end 
    end
end
return M