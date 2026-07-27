-- 屏幕尺寸缓存
local screenW, screenH = ui.getScreenSize()
local snapDistance = 30 -- 磁吸触发距离，离边缘30像素内自动吸附
local floatWindows = {}

-- 创建可拖拽、缩放悬浮窗工具函数
function createFloatWindow(winTag, xmlLayout, startX, startY, startW, startH)
    local win = ui.createFloatWindow(startX, startY, startW, startH)
    win:setTag(winTag)
    win:setContentView(xmlLayout)
    win:setDraggable(true)   -- 开启拖动
    win:setResizable(true)   -- 自由拉伸调整大小
    
    -- 拖拽监听，实现自动磁吸贴墙
    win:setOnDragListener(function(v, event)
        local x, y = win:getPosition()
        local w, h = win:getSize()
        local newX, newY = x, y

        -- 吸附顶部（天花板）
        if y < snapDistance then
            newY = 0
        end
        -- 吸附底部（地面）
        if (screenH - (y + h)) < snapDistance then
            newY = screenH - h
        end
        -- 吸附左侧墙面
        if x < snapDistance then
            newX = 0
        end
        -- 吸附右侧墙面
        if (screenW - (x + w)) < snapDistance then
            newX = screenW - w
        end

        -- 位置发生变化则更新窗口坐标，完成磁吸
        if newX ~= x or newY ~= y then
            win:setPosition(newX, newY)
        end
    end)

    floatWindows[winTag] = win
    return win
end

-- ===================== 窗口1：主控控制面板UI =====================
local layoutMain = [[
<VerticalLayout layout_width="match_parent" layout_height="match_parent" bg="#161616" padding="10">
    <!-- 拖拽标题栏 -->
    <HorizontalLayout layout_width="match_parent" layout_height="32" bg="#ff4444" radius="6">
        <TextView text="音乐主控面板" textColor="#ffffff" layout_weight="1" gravity="center_vertical" textSize="14"/>
    </HorizontalLayout>

    <!-- 音量调节滑块 -->
    <TextView text="音量控制" textColor="#eeeeee" marginTop="10" textSize="13"/>
    <SeekBar layout_width="match_parent" max="100" progress="70"/>

    <!-- 播放控制按钮组 -->
    <HorizontalLayout marginTop="12" gravity="center">
        <Button text="上一曲" bg="#2a2a2a" textColor="#fff" w="65" h="36"/>
        <Button text="暂停" bg="#ff4444" textColor="#fff" w="65" h="36" marginLeft="6"/>
        <Button text="下一曲" bg="#2a2a2a" textColor="#fff" w="65" h="36" marginLeft="6"/>
    </HorizontalLayout>

    <!-- 打开搜索窗口按钮 -->
    <Button text="打开搜索面板" layout_width="match_parent" bg="#222222" textColor="#fff" marginTop="12"/>

    <TextView text="拖动窗口靠近屏幕边缘会自动吸附墙面" textColor="#aaaaaa" marginTop="8" textSize="10"/>
</VerticalLayout>
]]
-- 创建主控悬浮窗 初始坐标、宽高
createFloatWindow("mainPanel", layoutMain, 40, 100, 260, 300)

-- ===================== 窗口2：独立搜索界面UI =====================
local layoutSearch = [[
<VerticalLayout layout_width="match_parent" layout_height="match_parent" bg="#161616" padding="10">
    <HorizontalLayout layout_width="match_parent" layout_height="32" bg="#ff4444" radius="6">
        <TextView text="歌曲搜索界面" textColor="#ffffff" layout_weight="1" gravity="center_vertical" textSize="14"/>
    </HorizontalLayout>

    <EditText hint="输入歌曲/歌手名称" layout_width="match_parent" bg="#2c2c2c" textColor="#fff" marginTop="10"/>
    <Button text="搜索" layout_width="match_parent" bg="#ff4444" textColor="#fff" marginTop="8"/>

    <TextView text="拖拽四边自动吸附天花板/地面/左右墙" textColor="#aaaaaa" marginTop="12" textSize="10"/>
</VerticalLayout>
]]
-- 创建搜索悬浮窗
createFloatWindow("searchPanel", layoutSearch, 320, 100, 240, 220)

ui.toast("双悬浮窗口已加载，拖动靠近屏幕边缘自动吸附，右下角拉伸调整大小")
