--GK到此一游
--GK到此一游
--GK到此一游
-- ============================================
-- 秋雨脚本 v3.0 - 完整版 + 彩蛋
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local char, root, hum

-- ==================== 预加载画面 ====================
local SplashScreen = Instance.new("ScreenGui")
SplashScreen.Name = "SplashScreen"
SplashScreen.Parent = LocalPlayer:WaitForChild("PlayerGui")
SplashScreen.ResetOnSpawn = false
SplashScreen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SplashScreen.DisplayOrder = 999

local SplashBg = Instance.new("Frame")
SplashBg.Size = UDim2.new(1, 0, 1, 0)
SplashBg.BackgroundColor3 = Color3.fromRGB(5, 5, 20)
SplashBg.BorderSizePixel = 0
SplashBg.Parent = SplashScreen

local splashImage = Instance.new("ImageLabel")
splashImage.Size = UDim2.new(0, 150, 0, 150)
splashImage.Position = UDim2.new(0.5, -75, 0.33, -75)
splashImage.BackgroundTransparency = 1
splashImage.Image = "rbxassetid://73337518954608"
splashImage.ScaleType = Enum.ScaleType.Fit
splashImage.ImageTransparency = 0.35
splashImage.Parent = SplashScreen
Instance.new("UICorner", splashImage).CornerRadius = UDim.new(0, 14)

local particles = {}
for i = 1, 25 do
    local p = Instance.new("Frame"); local s = 3 + math.random() * 4
    p.Size = UDim2.new(0, s, 0, s); p.Position = UDim2.new(math.random(), 0, math.random(), 0)
    p.BackgroundColor3 = Color3.fromRGB(80 + math.random() * 100, 120 + math.random() * 100, 255)
    p.BackgroundTransparency = 0.3; p.BorderSizePixel = 0; p.ZIndex = 2; p.Parent = SplashScreen
    Instance.new("UICorner", p).CornerRadius = UDim.new(1, 0)
    table.insert(particles, {frame = p, x = math.random(), y = math.random(), sx = (math.random() - 0.5) * 0.002, sy = -0.001 - math.random() * 0.004, alpha = 0.3 + math.random() * 0.4})
end

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 28); titleLabel.Position = UDim2.new(0, 0, 0.6, 0); titleLabel.BackgroundTransparency = 1
titleLabel.Text = "秋雨脚本"; titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255); titleLabel.TextSize = 26
titleLabel.Font = Enum.Font.GothamBlack; titleLabel.TextStrokeTransparency = 0; titleLabel.TextStrokeColor3 = Color3.fromRGB(50, 100, 255)
titleLabel.ZIndex = 3; titleLabel.Parent = SplashScreen

local loadBarBg = Instance.new("Frame")
loadBarBg.Size = UDim2.new(0, 140, 0, 3); loadBarBg.Position = UDim2.new(0.5, -70, 0.68, 0)
loadBarBg.BackgroundColor3 = Color3.fromRGB(30, 30, 50); loadBarBg.BorderSizePixel = 0; loadBarBg.Parent = SplashScreen
Instance.new("UICorner", loadBarBg).CornerRadius = UDim.new(1, 0)
local loadBar = Instance.new("Frame")
loadBar.Size = UDim2.new(0, 0, 1, 0); loadBar.BackgroundColor3 = Color3.fromRGB(80, 150, 255); loadBar.BorderSizePixel = 0; loadBar.Parent = loadBarBg
Instance.new("UICorner", loadBar).CornerRadius = UDim.new(1, 0)

local totalTime = 0; local lp = 0
local pc = RunService.RenderStepped:Connect(function(dt)
    totalTime += dt; lp = math.min(lp + dt * 0.4, 1); loadBar.Size = UDim2.new(lp, 0, 1, 0)
    local pulse = 1 + math.sin(totalTime * 2.5) * 0.05
    splashImage.Size = UDim2.new(0, 150 * pulse, 0, 150 * pulse); splashImage.Position = UDim2.new(0.5, -75 * pulse, 0.33, -75 * pulse)
    for _, p in pairs(particles) do p.x += p.sx; p.y += p.sy; if p.y < -0.1 then p.x = math.random(); p.y = 1.1 end; p.frame.Position = UDim2.new(p.x, 0, p.y, 0); p.frame.BackgroundTransparency = 1 - p.alpha + math.sin(totalTime * 3 + p.x * 10) * 0.2 end
    titleLabel.TextTransparency = 0.1 + math.sin(totalTime * 1.5) * 0.1
end)

task.wait(1.8)
local ts = TweenService; local fi = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
for _, p in pairs(particles) do ts:Create(p.frame, fi, {BackgroundTransparency = 1}):Play() end
ts:Create(SplashBg, fi, {BackgroundTransparency = 1}):Play(); ts:Create(splashImage, fi, {ImageTransparency = 1}):Play()
ts:Create(titleLabel, fi, {TextTransparency = 1}):Play(); ts:Create(loadBarBg, fi, {BackgroundTransparency = 1}):Play()
ts:Create(loadBar, fi, {BackgroundTransparency = 1}):Play()
task.wait(0.4); pc:Disconnect(); SplashScreen:Destroy()

-- ==================== 状态管理 ====================
local State = {
    Flying = false, Spinning = false, Circling = false,
    NoClip = false, InfJump = false, Speed = 1,
    ESP = false, ESPBox = false, ESPName = false, ESPHealth = false, ESPDistance = false, ESPTracers = false,
    Aimbot = false, AimbotVisible = false, Hitbox = false, HitboxSize = 5, Minimized = false,
}

local Components = {
    FlyBodyVelocity = nil, FlyConnection = nil, FlyKeyBegan = nil, FlyKeyEnded = nil,
    SpinAngularVelocity = nil, CircleConnection = nil, CircleTarget = nil,
    CircleAngle = 0, CircleSpeed = 2, JumpHeartbeat = nil, NoClipConnection = nil,
    SelectedCircleTarget = nil, ESPConnections = {}, AimbotConnection = nil,
    HitboxConnection = nil, HitboxParts = {}, TrollConnections = {},
}

-- ==================== 角色初始化 ====================
local function SetupCharacter()
    char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    root = char:WaitForChild("HumanoidRootPart"); hum = char:WaitForChild("Humanoid")
end
SetupCharacter()
LocalPlayer.CharacterAdded:Connect(function()
    SetupCharacter()
    if State.NoClip then for _, p in pairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end
end)

-- ==================== UI创建 - 居中固定 ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "QiuYuScript"; ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui"); ScreenGui.ResetOnSpawn = false

local MainWindow = Instance.new("Frame")
MainWindow.Size = UDim2.new(0, 700, 0, 340)
MainWindow.Position = UDim2.new(0.5, -350, 0.5, -170)
MainWindow.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
MainWindow.BackgroundTransparency = 0.3
MainWindow.BorderSizePixel = 0
MainWindow.Parent = ScreenGui
Instance.new("UICorner", MainWindow).CornerRadius = UDim.new(0, 12)

local uiBgImage = Instance.new("ImageLabel")
uiBgImage.Size = UDim2.new(1, 0, 1, 0); uiBgImage.Position = UDim2.new(0, 0, 0, 0); uiBgImage.BackgroundTransparency = 1
uiBgImage.Image = "rbxassetid://73337518954608"; uiBgImage.ScaleType = Enum.ScaleType.Stretch; uiBgImage.ImageTransparency = 0.15
uiBgImage.ZIndex = -1; uiBgImage.Parent = MainWindow
Instance.new("UICorner", uiBgImage).CornerRadius = UDim.new(0, 12)

local ms = Instance.new("UIStroke"); ms.Color = Color3.fromRGB(50, 100, 255); ms.Thickness = 1.5; ms.Transparency = 0.3; ms.Parent = MainWindow

-- 入场动画
MainWindow.BackgroundTransparency = 1; MainWindow.Size = UDim2.new(0, 0, 0, 0); MainWindow.Position = UDim2.new(0.5, 0, 0.5, 0); uiBgImage.ImageTransparency = 1
TweenService:Create(MainWindow, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 700, 0, 340), Position = UDim2.new(0.5, -350, 0.5, -170), BackgroundTransparency = 0.3}):Play()
TweenService:Create(uiBgImage, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {ImageTransparency = 0.15}):Play()

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 28); TitleBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255); TitleBar.BackgroundTransparency = 0.9; TitleBar.BorderSizePixel = 0; TitleBar.Parent = MainWindow
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -70, 1, 0); TitleLabel.Position = UDim2.new(0, 8, 0, 0); TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "秋雨脚本"; TitleLabel.TextColor3 = Color3.fromRGB(80, 150, 255); TitleLabel.TextSize = 13; TitleLabel.Font = Enum.Font.GothamBold; TitleLabel.TextXAlignment = Enum.TextXAlignment.Left; TitleLabel.Parent = TitleBar

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 22, 0, 22); MinBtn.Position = UDim2.new(1, -50, 0, 3); MinBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.BackgroundTransparency = 0.7; MinBtn.Text = "━"; MinBtn.TextColor3 = Color3.fromRGB(80, 150, 255); MinBtn.TextSize = 14; MinBtn.Font = Enum.Font.GothamBold; MinBtn.BorderSizePixel = 0; MinBtn.Parent = TitleBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 22, 0, 22); CloseBtn.Position = UDim2.new(1, -26, 0, 3); CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseBtn.BackgroundTransparency = 0.5; CloseBtn.Text = "✕"; CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255); CloseBtn.TextSize = 11; CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.BorderSizePixel = 0; CloseBtn.Parent = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, 0, 0, 24); TabContainer.Position = UDim2.new(0, 0, 0, 28); TabContainer.BackgroundTransparency = 1; TabContainer.Parent = MainWindow

local function CreateTab(name, pos)
    local tab = Instance.new("TextButton"); tab.Size = UDim2.new(0, 50, 0, 22); tab.Position = UDim2.new(0, pos, 0, 1)
    tab.BackgroundColor3 = Color3.fromRGB(40, 40, 60); tab.BackgroundTransparency = 0.4; tab.Text = name; tab.TextColor3 = Color3.fromRGB(200, 200, 220)
    tab.TextSize = 10; tab.Font = Enum.Font.GothamBold; tab.BorderSizePixel = 0; tab.Parent = TabContainer
    Instance.new("UICorner", tab).CornerRadius = UDim.new(0, 6); return tab
end
local ESPTab    = CreateTab("ESP", 2)
local FuncTab   = CreateTab("功能", 54)
local FunTab    = CreateTab("娱乐", 106)
local CombatTab = CreateTab("战斗", 158)
local PlayerTab = CreateTab("玩家", 210)
ESPTab.BackgroundColor3 = Color3.fromRGB(50, 100, 255); ESPTab.TextColor3 = Color3.fromRGB(255, 255, 255)

local function CreateContent()
    local c = Instance.new("Frame"); c.Size = UDim2.new(1, -16, 1, -58); c.Position = UDim2.new(0, 8, 0, 54)
    c.BackgroundTransparency = 1; c.Visible = false; c.Parent = MainWindow; return c
end
local ESPContent = CreateContent(); ESPContent.Visible = true; local FuncContent = CreateContent()
local FunContent = CreateContent(); local CombatContent = CreateContent(); local PlayerContent = CreateContent()

local function CreateButton(parent, x, y, w, h, text, active)
    local btn = Instance.new("TextButton"); btn.Size = UDim2.new(0, w, 0, h); btn.Position = UDim2.new(0, x, 0, y)
    btn.BackgroundColor3 = active and Color3.fromRGB(30, 80, 40) or Color3.fromRGB(30, 40, 60); btn.BackgroundTransparency = 0.4
    btn.Text = text; btn.TextColor3 = Color3.fromRGB(200, 220, 255); btn.TextSize = 10; btn.Font = Enum.Font.GothamMedium; btn.BorderSizePixel = 0; btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local st = Instance.new("UIStroke"); st.Color = Color3.fromRGB(50, 100, 255); st.Thickness = 1; st.Transparency = 0.5; st.Parent = btn; return btn
end

-- ==================== ESP标签页 ====================
local ESPToggle   = CreateButton(ESPContent, 0,   2,  220, 26, "ESP: 关闭", false)
local ESPBoxBtn   = CreateButton(ESPContent, 228, 2,  110, 26, "方框: 关", false)
local ESPNameBtn  = CreateButton(ESPContent, 344, 2,  110, 26, "名字: 关", false)
local ESPHealthBtn= CreateButton(ESPContent, 460, 2,  110, 26, "血量: 关", false)
local ESPDistBtn  = CreateButton(ESPContent, 576, 2,  110, 26, "距离: 关", false)
local ESPTraceBtn = CreateButton(ESPContent, 0,   32, 220, 26, "射线: 关", false)
local QQBtn = CreateButton(ESPContent, 0, 62, 220, 26, "QQ群: 1051933529", false)

-- ==================== 功能标签页 ====================
local FlyBtn    = CreateButton(FuncContent, 0,   2,  110, 26, "飞行", false)
local SpinBtn   = CreateButton(FuncContent, 116, 2,  110, 26, "自转", false)
local JumpBtn   = CreateButton(FuncContent, 232, 2,  110, 26, "无限跳", false)
local NoClipBtn = CreateButton(FuncContent, 348, 2,  110, 26, "穿墙", false)
local SpeedBtn  = CreateButton(FuncContent, 464, 2,  110, 26, "加速1x", false)
local StopBtn   = CreateButton(FuncContent, 580, 2,  104, 26, "停止全部", false)
StopBtn.BackgroundColor3 = Color3.fromRGB(60, 20, 20)

-- ==================== 娱乐标签页 ====================
local CircleBtn    = CreateButton(FunContent, 0,   2,  110, 26, "绕圈", false)
local HandsUpBtn   = CreateButton(FunContent, 116, 2,  110, 26, "举手", false)
local SitBtn       = CreateButton(FunContent, 232, 2,  110, 26, "摔倒", false)
local FreezeBtn    = CreateButton(FunContent, 348, 2,  110, 26, "冻结", false)
local FlingBtn     = CreateButton(FunContent, 464, 2,  110, 26, "弹飞", false)
local SpinTargetBtn= CreateButton(FunContent, 580, 2,  104, 26, "转圈", false)
local FlipBtn      = CreateButton(FunContent, 0,   32, 110, 26, "倒立", false)
local UnTrollBtn   = CreateButton(FunContent, 116, 32, 110, 26, "恢复", false)
-- 彩蛋按钮
local EasterBtn    = CreateButton(FunContent, 232, 32, 110, 26, "🎉彩蛋", false)
local CircleTargetLabel = Instance.new("TextLabel")
CircleTargetLabel.Size = UDim2.new(0, 400, 0, 16); CircleTargetLabel.Position = UDim2.new(0, 350, 0, 36)
CircleTargetLabel.BackgroundTransparency = 1; CircleTargetLabel.Text = "目标: 无 (在玩家列表选择)"
CircleTargetLabel.TextColor3 = Color3.fromRGB(150, 180, 220); CircleTargetLabel.TextSize = 10
CircleTargetLabel.Font = Enum.Font.GothamMedium; CircleTargetLabel.Parent = FunContent

-- ==================== 战斗标签页 ====================
local AimbotToggle = CreateButton(CombatContent, 0,   2,  170, 26, "自瞄", false)
local AimbotVisBtn = CreateButton(CombatContent, 176, 2,  170, 26, "可视检查", false)
local HitboxToggle = CreateButton(CombatContent, 352, 2,  170, 26, "范围伤害", false)
local HitboxDownBtn= CreateButton(CombatContent, 528, 2,  70,  26, "-", false)
local HitboxUpBtn  = CreateButton(CombatContent, 602, 2,  82,  26, "+", false)
local HitboxSizeLabel = Instance.new("TextLabel")
HitboxSizeLabel.Size = UDim2.new(0, 200, 0, 16); HitboxSizeLabel.Position = UDim2.new(0, 0, 0, 34); HitboxSizeLabel.BackgroundTransparency = 1
HitboxSizeLabel.Text = "范围大小: 5"; HitboxSizeLabel.TextColor3 = Color3.fromRGB(150, 180, 220); HitboxSizeLabel.TextSize = 10
HitboxSizeLabel.Font = Enum.Font.GothamBold; HitboxSizeLabel.Parent = CombatContent

-- ==================== 玩家标签页 ====================
local PlayerModeLabel = Instance.new("TextLabel")
PlayerModeLabel.Size = UDim2.new(0, 200, 0, 16); PlayerModeLabel.Position = UDim2.new(0, 0, 0, 4); PlayerModeLabel.BackgroundTransparency = 1
PlayerModeLabel.Text = "模式: 传送"; PlayerModeLabel.TextColor3 = Color3.fromRGB(150, 180, 220); PlayerModeLabel.TextSize = 10
PlayerModeLabel.Font = Enum.Font.GothamBold; PlayerModeLabel.Parent = PlayerContent
local ModeSwitchBtn = CreateButton(PlayerContent, 0, 22, 180, 22, "切换为绕圈模式", false)
local PlayerList = Instance.new("ScrollingFrame")
PlayerList.Size = UDim2.new(1, 0, 0, 188); PlayerList.Position = UDim2.new(0, 0, 0, 50); PlayerList.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
PlayerList.BackgroundTransparency = 0.85; PlayerList.BorderSizePixel = 0; PlayerList.ScrollBarThickness = 3; PlayerList.ScrollBarImageColor3 = Color3.fromRGB(50, 100, 255)
PlayerList.CanvasSize = UDim2.new(0, 0, 0, 200); PlayerList.Parent = PlayerContent; Instance.new("UICorner", PlayerList).CornerRadius = UDim.new(0, 8)

local RestoreBtn = Instance.new("ImageButton")
RestoreBtn.Size = UDim2.new(0, 50, 0, 50); RestoreBtn.Position = UDim2.new(0.5, -25, 0.5, -25); RestoreBtn.AnchorPoint = Vector2.new(0.5, 0.5)
RestoreBtn.BackgroundTransparency = 1; RestoreBtn.Image = "rbxassetid://73337518954608"; RestoreBtn.ScaleType = Enum.ScaleType.Stretch
RestoreBtn.ImageTransparency = 0.1; RestoreBtn.Visible = false; RestoreBtn.Parent = ScreenGui
Instance.new("UICorner", RestoreBtn).CornerRadius = UDim.new(1, 0)
local RestoreStroke = Instance.new("UIStroke"); RestoreStroke.Color = Color3.fromRGB(100, 150, 255); RestoreStroke.Thickness = 2; RestoreStroke.Transparency = 0.3; RestoreStroke.Parent = RestoreBtn

-- ==================== 标签切换 ====================
local currentTab = "ESP"
local function SwitchTab(tab)
    if tab == currentTab then return end; currentTab = tab
    ESPContent.Visible = (tab == "ESP"); FuncContent.Visible = (tab == "Func"); FunContent.Visible = (tab == "Fun")
    CombatContent.Visible = (tab == "Combat"); PlayerContent.Visible = (tab == "Player")
    ESPTab.BackgroundColor3 = (tab == "ESP") and Color3.fromRGB(50, 100, 255) or Color3.fromRGB(40, 40, 60)
    FuncTab.BackgroundColor3 = (tab == "Func") and Color3.fromRGB(50, 100, 255) or Color3.fromRGB(40, 40, 60)
    FunTab.BackgroundColor3 = (tab == "Fun") and Color3.fromRGB(50, 100, 255) or Color3.fromRGB(40, 40, 60)
    CombatTab.BackgroundColor3 = (tab == "Combat") and Color3.fromRGB(50, 100, 255) or Color3.fromRGB(40, 40, 60)
    PlayerTab.BackgroundColor3 = (tab == "Player") and Color3.fromRGB(50, 100, 255) or Color3.fromRGB(40, 40, 60)
    if tab == "Player" then RefreshPlayerList() end
end
ESPTab.MouseButton1Click:Connect(function() SwitchTab("ESP") end)
FuncTab.MouseButton1Click:Connect(function() SwitchTab("Func") end)
FunTab.MouseButton1Click:Connect(function() SwitchTab("Fun") end)
CombatTab.MouseButton1Click:Connect(function() SwitchTab("Combat") end)
PlayerTab.MouseButton1Click:Connect(function() SwitchTab("Player") end)

-- ==================== 最小化/恢复 ====================
MinBtn.MouseButton1Click:Connect(function()
    State.Minimized = true
    TweenService:Create(MainWindow, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
    TweenService:Create(uiBgImage, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {ImageTransparency = 1}):Play()
    task.wait(0.3); MainWindow.Visible = false; RestoreBtn.Visible = true; RestoreBtn.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(RestoreBtn, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 50, 0, 50)}):Play()
end)
RestoreBtn.MouseButton1Click:Connect(function()
    State.Minimized = false; RestoreBtn.Visible = false; MainWindow.Visible = true
    MainWindow.Size = UDim2.new(0, 0, 0, 0); MainWindow.Position = UDim2.new(0.5, 0, 0.5, 0)
    TweenService:Create(MainWindow, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 700, 0, 340), Position = UDim2.new(0.5, -350, 0.5, -170)}):Play()
    TweenService:Create(uiBgImage, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {ImageTransparency = 0.15}):Play()
end)

-- ==================== 关闭 ====================
local function CloseWithAnim()
    StopAll(); State.ESP = false
    for _, d in pairs(ESPDrawings) do for _, v in pairs(d) do v:Remove() end end; ESPDrawings = {}
    TweenService:Create(MainWindow, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0), BackgroundTransparency = 1}):Play()
    TweenService:Create(uiBgImage, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {ImageTransparency = 1}):Play()
    task.wait(0.25); ScreenGui:Destroy()
end
CloseBtn.MouseButton1Click:Connect(CloseWithAnim)

-- ==================== 功能函数 ====================
local function StartFlying()
    if State.Flying then return end; State.Flying = true; FlyBtn.BackgroundColor3 = Color3.fromRGB(30, 80, 40)
    local bv = Instance.new("BodyVelocity"); bv.MaxForce = Vector3.new(1,1,1)*50000; bv.Velocity = Vector3.zero; bv.Parent = root; Components.FlyBodyVelocity = bv
    local md, ud, sp = Vector3.zero, 0, 50
    Components.FlyConnection = RunService.Heartbeat:Connect(function()
        if not State.Flying or not Components.FlyBodyVelocity then return end; local cam = Camera; if not cam then return end
        local fw = cam.CFrame.LookVector * Vector3.new(1,0,1); local rt = cam.CFrame.RightVector * Vector3.new(1,0,1)
        local mv = (fw * -md.Z) + (rt * md.X) + Vector3.new(0, ud, 0)
        Components.FlyBodyVelocity.Velocity = mv.Magnitude > 0.1 and mv.Unit * sp or Vector3.zero
    end)
    Components.FlyKeyBegan = UserInputService.InputBegan:Connect(function(i,g) if g then return end
        if i.KeyCode == Enum.KeyCode.W then md += Vector3.new(0,0,-1) elseif i.KeyCode == Enum.KeyCode.S then md += Vector3.new(0,0,1)
        elseif i.KeyCode == Enum.KeyCode.A then md += Vector3.new(-1,0,0) elseif i.KeyCode == Enum.KeyCode.D then md += Vector3.new(1,0,0)
        elseif i.KeyCode == Enum.KeyCode.Space then ud = 1 elseif i.KeyCode == Enum.KeyCode.LeftControl then ud = -1 end end)
    Components.FlyKeyEnded = UserInputService.InputEnded:Connect(function(i)
        if i.KeyCode == Enum.KeyCode.W then md -= Vector3.new(0,0,-1) elseif i.KeyCode == Enum.KeyCode.S then md -= Vector3.new(0,0,1)
        elseif i.KeyCode == Enum.KeyCode.A then md -= Vector3.new(-1,0,0) elseif i.KeyCode == Enum.KeyCode.D then md -= Vector3.new(1,0,0)
        elseif i.KeyCode == Enum.KeyCode.Space then ud = 0 elseif i.KeyCode == Enum.KeyCode.LeftControl then ud = 0 end end)
end
local function StopFlying() State.Flying = false; FlyBtn.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
    if Components.FlyBodyVelocity then Components.FlyBodyVelocity:Destroy(); Components.FlyBodyVelocity = nil end
    if Components.FlyConnection then Components.FlyConnection:Disconnect(); Components.FlyConnection = nil end
    if Components.FlyKeyBegan then Components.FlyKeyBegan:Disconnect(); Components.FlyKeyBegan = nil end
    if Components.FlyKeyEnded then Components.FlyKeyEnded:Disconnect(); Components.FlyKeyEnded = nil end end

local function StartSpinning() if State.Spinning then return end; State.Spinning = true; SpinBtn.BackgroundColor3 = Color3.fromRGB(30, 80, 40); hum.AutoRotate = false
    if root:FindFirstChild("SpinRotator") then root.SpinRotator:Destroy() end
    local av = Instance.new("BodyAngularVelocity"); av.Name = "SpinRotator"; av.MaxTorque = Vector3.new(0,math.huge,0); av.AngularVelocity = Vector3.new(0,70,0); av.Parent = root; Components.SpinAngularVelocity = av end
local function StopSpinning() State.Spinning = false; SpinBtn.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
    if Components.SpinAngularVelocity then Components.SpinAngularVelocity:Destroy(); Components.SpinAngularVelocity = nil end; hum.AutoRotate = true end

local function StartCircling(target)
    if State.Circling then StopCircling() end
    if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") or not root then return end
    State.Circling = true; Components.CircleTarget = target; Components.CircleAngle = math.random()*math.pi*2; CircleBtn.BackgroundColor3 = Color3.fromRGB(30, 80, 40)
    local r, ho, sm = 8, 3, 0.5
    Components.CircleConnection = RunService.Heartbeat:Connect(function()
        if not State.Circling or not Components.CircleTarget then StopCircling(); return end
        local tc = Components.CircleTarget.Character; if not tc then StopCircling(); return end
        local tr = tc:FindFirstChild("HumanoidRootPart"); if not tr or not root or not root.Parent then StopCircling(); return end
        Components.CircleAngle += Components.CircleSpeed * 0.05; local tp = tr.Position
        root.CFrame = CFrame.new(root.Position:Lerp(Vector3.new(tp.X+r*math.cos(Components.CircleAngle), tp.Y+ho, tp.Z+r*math.sin(Components.CircleAngle)), sm)) end) end
local function StopCircling() State.Circling = false; Components.CircleTarget = nil; CircleBtn.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
    CircleTargetLabel.Text = "目标: 无 (在玩家列表选择)"; if Components.CircleConnection then Components.CircleConnection:Disconnect(); Components.CircleConnection = nil end end

local function ToggleInfJump() State.InfJump = not State.InfJump; JumpBtn.BackgroundColor3 = State.InfJump and Color3.fromRGB(30, 80, 40) or Color3.fromRGB(30, 40, 60)
    if State.InfJump then Components.JumpHeartbeat = RunService.Heartbeat:Connect(function() if not State.InfJump or not hum or not hum.Parent then return end; local s = hum:GetState(); if s == Enum.HumanoidStateType.Freefall or s == Enum.HumanoidStateType.Jumping then hum.Jump = true end end)
    else if Components.JumpHeartbeat then Components.JumpHeartbeat:Disconnect(); Components.JumpHeartbeat = nil end end end

local function ToggleNoClip() State.NoClip = not State.NoClip; NoClipBtn.BackgroundColor3 = State.NoClip and Color3.fromRGB(30, 80, 40) or Color3.fromRGB(30, 40, 60)
    if State.NoClip then for _, p in pairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end; Components.NoClipConnection = char.DescendantAdded:Connect(function(p) if p:IsA("BasePart") and State.NoClip then p.CanCollide = false end end)
    else for _, p in pairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end; if Components.NoClipConnection then Components.NoClipConnection:Disconnect(); Components.NoClipConnection = nil end end end

local function CycleSpeed() local speeds = {1,2,4,8,16}; local idx = 1; for i,v in ipairs(speeds) do if v == State.Speed then idx = i; break end end; idx = idx % #speeds + 1; State.Speed = speeds[idx]; hum.WalkSpeed = 16 * State.Speed; SpeedBtn.Text = "加速"..State.Speed.."x"; SpeedBtn.BackgroundColor3 = State.Speed > 1 and Color3.fromRGB(30, 80, 40) or Color3.fromRGB(30, 40, 60) end

local function StopAll() if State.Flying then StopFlying() end; if State.Spinning then StopSpinning() end; if State.Circling then StopCircling() end; if State.InfJump then ToggleInfJump() end; if State.NoClip then ToggleNoClip() end; if State.Aimbot then ToggleAimbot() end; if State.Hitbox then ToggleHitbox() end; ClearTroll(); if State.Speed ~= 1 then State.Speed = 1; hum.WalkSpeed = 16; SpeedBtn.Text = "加速1x"; SpeedBtn.BackgroundColor3 = Color3.fromRGB(30, 40, 60) end end

local function TeleportToPlayer(tp) if not tp or not root then return false end; local tc = tp.Character; if tc and tc:FindFirstChild("HumanoidRootPart") then root.CFrame = tc.HumanoidRootPart.CFrame + Vector3.new(0,3,0); return true end; return false end

-- 娱乐
local function GetTarget() return Components.SelectedCircleTarget end
local function TrollHandsUp(target) if not target then return end; local ch = target.Character; if not ch then return end; local hum = ch:FindFirstChild("Humanoid"); if not hum then return end; hum.PlatformStand = true; task.wait(0.1); local torso = ch:FindFirstChild("Torso") or ch:FindFirstChild("UpperTorso"); if torso then local rs = torso:FindFirstChild("Right Shoulder") or torso:FindFirstChild("RightUpperArm"); local ls = torso:FindFirstChild("Left Shoulder") or torso:FindFirstChild("LeftUpperArm"); if rs then rs.CurrentAngle = math.rad(180) end; if ls then ls.CurrentAngle = math.rad(180) end end end
local function TrollSit(target) if not target then return end; local ch = target.Character; if not ch then return end; local hum = ch:FindFirstChild("Humanoid"); if not hum then return end; hum.Sit = true end
local function TrollFreeze(target) if not target then return end; local ch = target.Character; if not ch then return end; local hrp = ch:FindFirstChild("HumanoidRootPart"); if not hrp then return end; for _, o in pairs(Components.TrollConnections) do if o and o.Parent then o:Destroy() end end; Components.TrollConnections = {}; local bv = Instance.new("BodyVelocity"); bv.MaxForce = Vector3.new(1,1,1)*999999; bv.Velocity = Vector3.zero; bv.Parent = hrp; local bg = Instance.new("BodyGyro"); bg.MaxTorque = Vector3.new(1,1,1)*999999; bg.CFrame = hrp.CFrame; bg.Parent = hrp; table.insert(Components.TrollConnections, bv); table.insert(Components.TrollConnections, bg) end
local function TrollFling(target) if not target then return end; local ch = target.Character; if not ch then return end; local hrp = ch:FindFirstChild("HumanoidRootPart"); if not hrp then return end; local bv = Instance.new("BodyVelocity"); bv.MaxForce = Vector3.new(1,1,1)*999999; bv.Velocity = Vector3.new(math.random(-300,300), 800, math.random(-300,300)); bv.Parent = hrp; table.insert(Components.TrollConnections, bv); task.wait(1); if bv and bv.Parent then bv:Destroy() end end
local function TrollSpin(target) if not target then return end; local ch = target.Character; if not ch then return end; local hrp = ch:FindFirstChild("HumanoidRootPart"); if not hrp then return end; local bg = Instance.new("BodyGyro"); bg.MaxTorque = Vector3.new(1,1,1)*999999; bg.CFrame = hrp.CFrame; bg.Parent = hrp; table.insert(Components.TrollConnections, bg); task.spawn(function() while bg and bg.Parent do bg.CFrame = bg.CFrame * CFrame.Angles(0, math.rad(20), 0); task.wait() end end) end
local function TrollFlip(target) if not target then return end; local ch = target.Character; if not ch then return end; local hrp = ch:FindFirstChild("HumanoidRootPart"); if not hrp then return end; local bg = Instance.new("BodyGyro"); bg.MaxTorque = Vector3.new(1,1,1)*999999; bg.CFrame = hrp.CFrame * CFrame.Angles(math.rad(180), 0, 0); bg.Parent = hrp; table.insert(Components.TrollConnections, bg) end
local function ClearTroll() for _, o in pairs(Components.TrollConnections) do if o and o.Parent then o:Destroy() end end; Components.TrollConnections = {}; local target = GetTarget(); if not target then return end; local ch = target.Character; if not ch then return end; local hum = ch:FindFirstChild("Humanoid"); if hum then hum.PlatformStand = false; hum.Sit = false end end

-- 自瞄/范围
local function GetClosestPlayer() local cl, sd = nil, math.huge
    for _, pl in pairs(Players:GetPlayers()) do if pl == LocalPlayer then continue end; local tc = pl.Character; if not tc then continue end; local hd = tc:FindFirstChild("Head"); if not hd then continue end
        if State.AimbotVisible then local _, os = Camera:WorldToViewportPoint(hd.Position); if not os then continue end; local rp = RaycastParams.new(); rp.FilterDescendantsInstances = {char}; rp.FilterType = Enum.RaycastFilterType.Blacklist; local ry = workspace:Raycast(Camera.CFrame.Position, (hd.Position - Camera.CFrame.Position).Unit * 500, rp); if ry then local hc = ry.Instance:FindFirstAncestorOfClass("Model"); if hc ~= pl.Character then continue end end end
        local sp, os = Camera:WorldToViewportPoint(hd.Position); if os then local sc = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2); local d = (Vector2.new(sp.X, sp.Y) - sc).Magnitude; if d < sd then sd = d; cl = pl end end end; return cl end
local function ToggleAimbot() State.Aimbot = not State.Aimbot; AimbotToggle.BackgroundColor3 = State.Aimbot and Color3.fromRGB(30, 80, 40) or Color3.fromRGB(30, 40, 60)
    if State.Aimbot then Components.AimbotConnection = RunService.Heartbeat:Connect(function() if not State.Aimbot then return end; local t = GetClosestPlayer(); if t and t.Character and t.Character:FindFirstChild("Head") then Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Character.Head.Position) end end)
    else if Components.AimbotConnection then Components.AimbotConnection:Disconnect(); Components.AimbotConnection = nil end end end
local function ExpandHitbox(ch) local pts = {}; for _, p in pairs(ch:GetDescendants()) do if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then local os = p.Size; p.Size = os * State.HitboxSize; p.Transparency = 0.7; p.CanCollide = true; table.insert(pts, {part = p, oldSize = os}) end end; return pts end
local function RestoreHitbox(pts) for _, d in pairs(pts) do if d.part and d.part.Parent then d.part.Size = d.oldSize end end end
local function ToggleHitbox() State.Hitbox = not State.Hitbox; HitboxToggle.BackgroundColor3 = State.Hitbox and Color3.fromRGB(30, 80, 40) or Color3.fromRGB(30, 40, 60)
    if State.Hitbox then for _, pl in pairs(Players:GetPlayers()) do if pl ~= LocalPlayer and pl.Character then Components.HitboxParts[pl] = ExpandHitbox(pl.Character) end end; Components.HitboxConnection = Players.PlayerAdded:Connect(function(pl) pl.CharacterAdded:Connect(function(ch) task.wait(0.5); if State.Hitbox then Components.HitboxParts[pl] = ExpandHitbox(ch) end end) end)
    else for _, pts in pairs(Components.HitboxParts) do RestoreHitbox(pts) end; Components.HitboxParts = {}; if Components.HitboxConnection then Components.HitboxConnection:Disconnect(); Components.HitboxConnection = nil end end end

-- ESP
local ESPDrawings = {}
local function CreateESP(player) local d = {}
    d.Box = Drawing.new("Square"); d.Box.Visible = false; d.Box.Color = Color3.fromRGB(255,255,255); d.Box.Thickness = 1.5; d.Box.Filled = false; d.Box.Transparency = 0.7
    d.Name = Drawing.new("Text"); d.Name.Visible = false; d.Name.Color = Color3.fromRGB(255,255,255); d.Name.Size = 13; d.Name.Center = true; d.Name.Outline = true; d.Name.Font = 3
    d.HealthBg = Drawing.new("Square"); d.HealthBg.Visible = false; d.HealthBg.Color = Color3.fromRGB(30,30,30); d.HealthBg.Thickness = 1; d.HealthBg.Filled = true
    d.HealthBar = Drawing.new("Square"); d.HealthBar.Visible = false; d.HealthBar.Color = Color3.fromRGB(0,255,0); d.HealthBar.Thickness = 1; d.HealthBar.Filled = true
    d.Distance = Drawing.new("Text"); d.Distance.Visible = false; d.Distance.Color = Color3.fromRGB(255,255,255); d.Distance.Size = 12; d.Distance.Center = true; d.Distance.Outline = true; d.Distance.Font = 3
    d.Tracer = Drawing.new("Line"); d.Tracer.Visible = false; d.Tracer.Color = Color3.fromRGB(255,255,255); d.Tracer.Thickness = 1; d.Tracer.Transparency = 0.5
    ESPDrawings[player] = d end
local function UpdateESP()
    for player, d in pairs(ESPDrawings) do
        if not player or not player.Parent then for _, v in pairs(d) do v:Remove() end; ESPDrawings[player] = nil; continue end
        local ch = player.Character; if not ch or not ch:FindFirstChild("HumanoidRootPart") or not ch:FindFirstChild("Humanoid") then for _, v in pairs(d) do v.Visible = false end; continue end
        if not root then continue end; local tr = ch.HumanoidRootPart; local th = ch.Humanoid; local pos, os = Camera:WorldToViewportPoint(tr.Position)
        if not os then for _, v in pairs(d) do v.Visible = false end; continue end
        local dist = (root.Position - tr.Position).Magnitude; local scale = math.clamp(1/(dist*0.05),0.5,2); local bs = Vector2.new(40*scale, 60*scale); local bp = Vector2.new(pos.X-bs.X/2, pos.Y-bs.Y/2)
        if State.ESP and State.ESPBox then d.Box.Visible = true; d.Box.Size = bs; d.Box.Position = bp; d.Box.Color = (player.TeamColor and player.TeamColor.Color) or Color3.fromRGB(255,255,255) else d.Box.Visible = false end
        if State.ESP and State.ESPName then d.Name.Visible = true; d.Name.Position = Vector2.new(pos.X, bp.Y-18); d.Name.Text = player.Name else d.Name.Visible = false end
        if State.ESP and State.ESPHealth then local h = th.Health; local mh = th.MaxHealth; local hp = math.clamp(h/mh,0,1); d.HealthBg.Visible = true; d.HealthBg.Size = Vector2.new(3, bs.Y); d.HealthBg.Position = Vector2.new(bp.X-6, bp.Y); d.HealthBar.Visible = true; d.HealthBar.Size = Vector2.new(3, bs.Y*hp); d.HealthBar.Position = Vector2.new(bp.X-6, bp.Y+bs.Y*(1-hp)); d.HealthBar.Color = hp>0.6 and Color3.fromRGB(0,255,0) or (hp>0.3 and Color3.fromRGB(255,255,0) or Color3.fromRGB(255,0,0)) else d.HealthBg.Visible = false; d.HealthBar.Visible = false end
        if State.ESP and State.ESPDistance then d.Distance.Visible = true; d.Distance.Position = Vector2.new(pos.X, bp.Y+bs.Y+4); d.Distance.Text = math.floor(dist).."m" else d.Distance.Visible = false end
        if State.ESP and State.ESPTracers then d.Tracer.Visible = true; d.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y); d.Tracer.To = Vector2.new(pos.X, bp.Y+bs.Y); d.Tracer.Color = Color3.fromRGB(255,255,255) else d.Tracer.Visible = false end
    end end
local function ToggleESP() State.ESP = not State.ESP; ESPToggle.BackgroundColor3 = State.ESP and Color3.fromRGB(30,80,40) or Color3.fromRGB(30,40,60); ESPToggle.Text = State.ESP and "ESP: 开启" or "ESP: 关闭"
    if State.ESP then for _, pl in pairs(Players:GetPlayers()) do if pl ~= LocalPlayer then CreateESP(pl) end end; local pa = Players.PlayerAdded:Connect(function(pl) if pl ~= LocalPlayer then task.wait(1); CreateESP(pl) end end); table.insert(Components.ESPConnections, pa); local pr = Players.PlayerRemoving:Connect(function(pl) if ESPDrawings[pl] then for _, v in pairs(ESPDrawings[pl]) do v:Remove() end; ESPDrawings[pl] = nil end end); table.insert(Components.ESPConnections, pr)
    else for _, d in pairs(ESPDrawings) do for _, v in pairs(d) do v:Remove() end end; ESPDrawings = {}; for _, c in pairs(Components.ESPConnections) do c:Disconnect() end; Components.ESPConnections = {} end end
local function ToggleESPBox() if not State.ESP then return end; State.ESPBox = not State.ESPBox; ESPBoxBtn.BackgroundColor3 = State.ESPBox and Color3.fromRGB(30,80,40) or Color3.fromRGB(30,40,60); ESPBoxBtn.Text = State.ESPBox and "方框: 开" or "方框: 关" end
local function ToggleESPName() if not State.ESP then return end; State.ESPName = not State.ESPName; ESPNameBtn.BackgroundColor3 = State.ESPName and Color3.fromRGB(30,80,40) or Color3.fromRGB(30,40,60); ESPNameBtn.Text = State.ESPName and "名字: 开" or "名字: 关" end
local function ToggleESPHealth() if not State.ESP then return end; State.ESPHealth = not State.ESPHealth; ESPHealthBtn.BackgroundColor3 = State.ESPHealth and Color3.fromRGB(30,80,40) or Color3.fromRGB(30,40,60); ESPHealthBtn.Text = State.ESPHealth and "血量: 开" or "血量: 关" end
local function ToggleESPDist() if not State.ESP then return end; State.ESPDistance = not State.ESPDistance; ESPDistBtn.BackgroundColor3 = State.ESPDistance and Color3.fromRGB(30,80,40) or Color3.fromRGB(30,40,60); ESPDistBtn.Text = State.ESPDistance and "距离: 开" or "距离: 关" end
local function ToggleESPTrace() if not State.ESP then return end; State.ESPTracers = not State.ESPTracers; ESPTraceBtn.BackgroundColor3 = State.ESPTracers and Color3.fromRGB(30,80,40) or Color3.fromRGB(30,40,60); ESPTraceBtn.Text = State.ESPTracers and "射线: 开" or "射线: 关" end
RunService.RenderStepped:Connect(function() if State.ESP then UpdateESP() end end)

-- QQ群
QQBtn.MouseButton1Click:Connect(function()
    if setclipboard then setclipboard("1051933529") end
    QQBtn.Text = "✅ 已复制!"; QQBtn.BackgroundColor3 = Color3.fromRGB(30, 80, 40)
    task.wait(1.5); QQBtn.Text = "QQ群: 1051933529"; QQBtn.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
end)

-- 彩蛋按钮
EasterBtn.MouseButton1Click:Connect(function()
    EasterBtn.Text = "🎉 彩蛋开启!"; EasterBtn.BackgroundColor3 = Color3.fromRGB(80, 30, 80)
    -- 创建一个彩蛋弹窗
    local easterFrame = Instance.new("Frame")
    easterFrame.Size = UDim2.new(0, 350, 0, 180)
    easterFrame.Position = UDim2.new(0.5, -175, 0.5, -90)
    easterFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
    easterFrame.BackgroundTransparency = 0.1
    easterFrame.BorderSizePixel = 0
    easterFrame.Parent = ScreenGui
    Instance.new("UICorner", easterFrame).CornerRadius = UDim.new(0, 16)
    local es = Instance.new("UIStroke"); es.Color = Color3.fromRGB(200, 150, 255); es.Thickness = 2; es.Parent = easterFrame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30); title.Position = UDim2.new(0, 0, 0, 15)
    title.BackgroundTransparency = 1; title.Text = "🌟 彩蛋 - 秋雨脚本 🌟"
    title.TextColor3 = Color3.fromRGB(255, 200, 100); title.TextSize = 16; title.Font = Enum.Font.GothamBold
    title.Parent = easterFrame
    
    local line1 = Instance.new("TextLabel")
    line1.Size = UDim2.new(1, 0, 0, 22); line1.Position = UDim2.new(0, 0, 0, 55)
    line1.BackgroundTransparency = 1; line1.Text = "第一个使用者：爱吃奥利奥"
    line1.TextColor3 = Color3.fromRGB(200, 200, 255); line1.TextSize = 14; line1.Font = Enum.Font.GothamMedium
    line1.Parent = easterFrame
    
    local line2 = Instance.new("TextLabel")
    line2.Size = UDim2.new(1, 0, 0, 22); line2.Position = UDim2.new(0, 0, 0, 80)
    line2.BackgroundTransparency = 1; line2.Text = "第一个传播者：兔大侠"
    line2.TextColor3 = Color3.fromRGB(255, 180, 180); line2.TextSize = 14; line2.Font = Enum.Font.GothamMedium
    line2.Parent = easterFrame
    
    local line3 = Instance.new("TextLabel")
    line3.Size = UDim2.new(1, 0, 0, 22); line3.Position = UDim2.new(0, 0, 0, 110)
    line3.BackgroundTransparency = 1; line3.Text = "❤️ 感谢你们的支持！❤️"
    line3.TextColor3 = Color3.fromRGB(255, 255, 255); line3.TextSize = 14; line3.Font = Enum.Font.GothamBold
    line3.Parent = easterFrame
    
    local closeEgg = Instance.new("TextButton")
    closeEgg.Size = UDim2.new(0, 80, 0, 28); closeEgg.Position = UDim2.new(0.5, -40, 0, 140)
    closeEgg.BackgroundColor3 = Color3.fromRGB(150, 80, 200); closeEgg.Text = "关闭"; closeEgg.TextColor3 = Color3.fromRGB(255,255,255)
    closeEgg.TextSize = 12; closeEgg.Font = Enum.Font.GothamBold; closeEgg.BorderSizePixel = 0
    closeEgg.Parent = easterFrame
    Instance.new("UICorner", closeEgg).CornerRadius = UDim.new(0, 8)
    
    closeEgg.MouseButton1Click:Connect(function() easterFrame:Destroy() end)
    
    task.wait(3)
    EasterBtn.Text = "🎉彩蛋"; EasterBtn.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
end)

-- 玩家列表
local playerListMode = "teleport"; local playerButtons = {}
local function RefreshPlayerList()
    for _, b in pairs(playerButtons) do b:Destroy() end; playerButtons = {}
    for _, pl in pairs(Players:GetPlayers()) do if pl ~= LocalPlayer then local n = #playerButtons + 1; local rw = math.floor((n-1)/6); local cl = (n-1)%6
        local btn = Instance.new("TextButton"); btn.Size = UDim2.new(0, 108, 0, 24); btn.Position = UDim2.new(0, cl*113, 0, rw*28)
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60); btn.BackgroundTransparency = 0.4; btn.Text = pl.Name; btn.TextColor3 = Color3.fromRGB(200, 220, 255)
        btn.TextSize = 9; btn.Font = Enum.Font.GothamMedium; btn.BorderSizePixel = 0; btn.Parent = PlayerList
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        local st = Instance.new("UIStroke"); st.Color = Color3.fromRGB(50, 100, 255); st.Thickness = 1; st.Transparency = 0.5; st.Parent = btn
        btn.MouseButton1Click:Connect(function()
            if playerListMode == "teleport" then if TeleportToPlayer(pl) then btn.BackgroundColor3 = Color3.fromRGB(30,80,40); task.wait(0.3); btn.BackgroundColor3 = Color3.fromRGB(40,40,60) end
            else Components.SelectedCircleTarget = pl; CircleTargetLabel.Text = "目标: "..pl.Name; btn.BackgroundColor3 = Color3.fromRGB(80,80,30); task.wait(0.3); btn.BackgroundColor3 = Color3.fromRGB(40,40,60) end end)
        table.insert(playerButtons, btn) end end
    PlayerList.CanvasSize = UDim2.new(0, 0, 0, math.max(math.ceil(#playerButtons/6)*28, 40))
end
ModeSwitchBtn.MouseButton1Click:Connect(function() playerListMode = (playerListMode == "teleport") and "circle" or "teleport"; PlayerModeLabel.Text = "模式: "..(playerListMode == "teleport" and "传送" or "绕圈"); ModeSwitchBtn.Text = (playerListMode == "teleport") and "切换为绕圈模式" or "切换为传送模式" end)

-- ==================== 按钮绑定 ====================
FlyBtn.MouseButton1Click:Connect(function() if State.Flying then StopFlying() else StartFlying() end end)
SpinBtn.MouseButton1Click:Connect(function() if State.Spinning then StopSpinning() else StartSpinning() end end)
JumpBtn.MouseButton1Click:Connect(ToggleInfJump); NoClipBtn.MouseButton1Click:Connect(ToggleNoClip)
SpeedBtn.MouseButton1Click:Connect(CycleSpeed); StopBtn.MouseButton1Click:Connect(StopAll)

ESPToggle.MouseButton1Click:Connect(ToggleESP); ESPBoxBtn.MouseButton1Click:Connect(ToggleESPBox); ESPNameBtn.MouseButton1Click:Connect(ToggleESPName)
ESPHealthBtn.MouseButton1Click:Connect(ToggleESPHealth); ESPDistBtn.MouseButton1Click:Connect(ToggleESPDist); ESPTraceBtn.MouseButton1Click:Connect(ToggleESPTrace)

CircleBtn.MouseButton1Click:Connect(function() if State.Circling then StopCircling() elseif Components.SelectedCircleTarget then StartCircling(Components.SelectedCircleTarget); CircleTargetLabel.Text = "目标: "..Components.SelectedCircleTarget.Name end end)
HandsUpBtn.MouseButton1Click:Connect(function() TrollHandsUp(GetTarget()) end); SitBtn.MouseButton1Click:Connect(function() TrollSit(GetTarget()) end)
FreezeBtn.MouseButton1Click:Connect(function() TrollFreeze(GetTarget()) end); FlingBtn.MouseButton1Click:Connect(function() TrollFling(GetTarget()) end)
SpinTargetBtn.MouseButton1Click:Connect(function() TrollSpin(GetTarget()) end); FlipBtn.MouseButton1Click:Connect(function() TrollFlip(GetTarget()) end)
UnTrollBtn.MouseButton1Click:Connect(ClearTroll)

AimbotToggle.MouseButton1Click:Connect(ToggleAimbot); AimbotVisBtn.MouseButton1Click:Connect(function() State.AimbotVisible = not State.AimbotVisible; AimbotVisBtn.BackgroundColor3 = State.AimbotVisible and Color3.fromRGB(30,80,40) or Color3.fromRGB(30,40,60) end)
HitboxToggle.MouseButton1Click:Connect(ToggleHitbox); HitboxUpBtn.MouseButton1Click:Connect(function() State.HitboxSize = math.min(State.HitboxSize+1, 20); HitboxSizeLabel.Text = "范围大小: "..State.HitboxSize; if State.Hitbox then ToggleHitbox(); ToggleHitbox() end end)
HitboxDownBtn.MouseButton1Click:Connect(function() State.HitboxSize = math.max(State.HitboxSize-1, 2); HitboxSizeLabel.Text = "范围大小: "..State.HitboxSize; if State.Hitbox then ToggleHitbox(); ToggleHitbox() end end)

-- ==================== 窗口拖动 ====================
local function MakeDraggable(frame, handle) local dragging, ds, sp = false
    handle.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true; ds = i.Position; sp = frame.Position end end)
    UserInputService.InputChanged:Connect(function(i) if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local d = i.Position - ds; frame.Position = UDim2.new(sp.X.Scale, sp.X.Offset+d.X, sp.Y.Scale, sp.Y.Offset+d.Y) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end) end
MakeDraggable(MainWindow, TitleBar); MakeDraggable(RestoreBtn, RestoreBtn)

CloseBtn.MouseButton1Click:Connect(CloseWithAnim)
RefreshPlayerList(); Players.PlayerAdded:Connect(RefreshPlayerList); Players.PlayerRemoving:Connect(RefreshPlayerList)
print("秋雨脚本 彩蛋版 加载完成!")