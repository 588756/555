-- 等待游戏加载，防止注入后报错
task.wait(3)

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- 如果已经存在这个UI，就删掉重新创建，防止重复
if playerGui:FindFirstChild("CustomUIScreen") then
    playerGui.CustomUIScreen:Destroy()
end

-- 1. 创建主屏幕容器
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CustomUIScreen"
screenGui.Parent = playerGui
screenGui.IgnoreGuiInset = true

-- 2. 主框架
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Parent = screenGui
mainFrame.Size = UDim2.new(1, 0, 1, 0)
mainFrame.BackgroundTransparency = 1 -- 完全透明

-- ================= 顶部状态栏 =================
local topBar = Instance.new("Frame")
topBar.Parent = mainFrame
topBar.Size = UDim2.new(0, 280, 0, 55)
topBar.Position = UDim2.new(0, 15, 0, 15)
topBar.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
topBar.BackgroundTransparency = 0.15
local topCorner = Instance.new("UICorner")
topCorner.Parent = topBar
topCorner.CornerRadius = UDim.new(1, 0) -- 全圆角

-- 顶部图标（你需要自己替换为真实的图片ID，否则显示为白色方块）
local function createIcon(parent, xOffset, imageId)
    local icon = Instance.new("ImageLabel")
    icon.Parent = parent
    icon.Size = UDim2.new(0, 32, 0, 32)
    icon.Position = UDim2.new(0, xOffset, 0.5, -16)
    icon.BackgroundTransparency = 1
    icon.Image = imageId or "rbxassetid://0" -- 默认占位符
    icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
    return icon
end
createIcon(topBar, 10)   -- 罗布乐思Logo
createIcon(topBar, 60)   -- 菜单三条杠
createIcon(topBar, 110)  -- 聊天气泡(带数字3)
createIcon(topBar, 160)  -- 耳机

-- ================= 血条 (右上角) =================
local healthBg = Instance.new("Frame")
healthBg.Parent = mainFrame
healthBg.Size = UDim2.new(0, 220, 0, 18)
healthBg.Position = UDim2.new(1, -240, 0, 20)
healthBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
local hCorner = Instance.new("UICorner")
hCorner.Parent = healthBg
hCorner.CornerRadius = UDim.new(1, 0)

local healthFill = Instance.new("Frame")
healthFill.Parent = healthBg
healthFill.Size = UDim2.new(0.75, 0, 1, 0)
healthFill.BackgroundColor3 = Color3.fromRGB(90, 255, 90)
healthFill.BorderSizePixel = 0
local hfCorner = Instance.new("UICorner")
hfCorner.Parent = healthFill
hfCorner.CornerRadius = UDim.new(1, 0)

-- ================= 中间三个菜单面板 =================
local function createDarkPanel(xCenterOffset, width, height)
    local panel = Instance.new("Frame")
    panel.Parent = mainFrame
    panel.Size = UDim2.new(0, width, 0, height)
    panel.Position = UDim2.new(0.5, xCenterOffset, 0.5, -(height/2))
    panel.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    panel.BackgroundTransparency = 0.2
    local pCorner = Instance.new("UICorner")
    pCorner.Parent = panel
    pCorner.CornerRadius = UDim.new(0, 8)
    return panel
end

-- 左侧面板
local leftPanel = createDarkPanel(-220, 140, 250)
local leftList = Instance.new("UIListLayout")
leftList.Parent = leftPanel
leftList.Padding = UDim.new(0, 6)
leftList.SortOrder = Enum.SortOrder.LayoutOrder

local leftTexts = {"  ⚙️ 系统设定", "  🛡️ 管理面板", "  👤 玩家列表", "  📦 物品背包", "  🚀 传送功能"}
for _, text in ipairs(leftTexts) do
    local lbl = Instance.new("TextLabel")
    lbl.Parent = leftPanel
    lbl.Size = UDim2.new(1, -15, 0, 25)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    lbl.TextSize = 14
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextXAlignment = Enum.TextXAlignment.Left
end

-- 中间面板 (带按钮)
local midPanel = createDarkPanel(0, 190, 280)
local midList = Instance.new("UIListLayout")
midList.Parent = midPanel
midList.Padding = UDim.new(0, 6)
midList.SortOrder = Enum.SortOrder.LayoutOrder

local function addMidButton(text, isBlue)
    local btn = Instance.new("TextButton")
    btn.Parent = midPanel
    btn.Size = UDim2.new(1, -15, 0, 28)
    btn.BackgroundColor3 = isBlue and Color3.fromRGB(40, 90, 220) or Color3.fromRGB(40, 40, 40)
    btn.BackgroundTransparency = isBlue and 0.2 or 0.5
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    btn.Font = Enum.Font.Gotham
    local bCorner = Instance.new("UICorner")
    bCorner.Parent = btn
    bCorner.CornerRadius = UDim.new(0, 6)
end
addMidButton(" 🎵 音乐播放器", false)
addMidButton(" 🔄 自动连招", false)
addMidButton(" 📦 自动拾取物品", true) -- 蓝色按钮
addMidButton(" 🏠 传送至大厅", false)
addMidButton(" 🎥 切换视角", false)

-- 右侧面板
local rightPanel = createDarkPanel(220, 140, 250)
local rightList = Instance.new("UIListLayout")
rightList.Parent = rightPanel
rightList.Padding = UDim.new(0, 6)
rightList.SortOrder = Enum.SortOrder.LayoutOrder

local rightTexts = {"  🎨 画质设置", "  🔊 音量控制", "  🖱️ 操作模式", "  🎒 背包整理", "  ❌ 退出游戏"}
for _, text in ipairs(rightTexts) do
    local lbl = Instance.new("TextLabel")
    lbl.Parent = rightPanel
    lbl.Size = UDim2.new(1, -15, 0, 25)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    lbl.TextSize = 14
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextXAlignment = Enum.TextXAlignment.Left
end

-- ================= 下方跳跃键 =================
local jumpBtn = Instance.new("TextButton")
jumpBtn.Parent = mainFrame
jumpBtn.Size = UDim2.new(0, 70, 0, 70)
jumpBtn.Position = UDim2.new(1, -90, 1, -100)
jumpBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
jumpBtn.BackgroundTransparency = 0.3
jumpBtn.Text = "↑"
jumpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
jumpBtn.TextSize = 30
local jCorner = Instance.new("UICorner")
jCorner.Parent = jumpBtn
jCorner.CornerRadius = UDim.new(1, 0)

-- ================= 底部白点圆圈 =================
-- 因为你要求纯UI，这里的圆点环实际上是静止的图片排版
local circleFrame = Instance.new("Frame")
circleFrame.Parent = mainFrame
circleFrame.Size = UDim2.new(0, 420, 0, 420)
circleFrame.Position = UDim2.new(0.5, -210, 0.5, -150)
circleFrame.BackgroundTransparency = 1

-- 模拟粒子环
for i = 1, 20 do
    local dot = Instance.new("Frame")
    dot.Parent = circleFrame
    dot.Size = UDim2.new(0, 12, 0, 12)
    dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    local dCorner = Instance.new("UICorner")
    dCorner.Parent = dot
    dCorner.CornerRadius = UDim.new(1, 0)
    
    -- 这里简单模拟圆形布局 (使用三角函数分布)
    local angle = (i / 20) * 2 * math.pi
    local radius = 200
    dot.Position = UDim2.new(0.5, (math.cos(angle) * radius) - 6, 0.5, (math.sin(angle) * radius) - 6)
end