-- 基础服务
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- 全局状态变量
local espToggle = false
local nightToggle = false
local timeToggle = false
local flyToggle = false
local originalBright = Lighting.Brightness
local originalAmbient = Lighting.Ambient
local originalTime = Lighting.TimeOfDay
local highlightCache = {}
local targetPlayer = nil
local flySpeed = 50 -- 默认飞行速度
local vehicleSpeedMult = 2 -- 车辆加速倍数

-- 总UI容器
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MemToolUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

-- 主拖动面板
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0,240,0,310)
mainFrame.Position = UDim2.new(0.01,0,0.25,0)
mainFrame.BackgroundColor3 = Color3.new(0.08,0.08,0.12)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.new(0,0.6,1)
mainFrame.BackgroundTransparency = 0.1
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- 标题
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "纪念工具面板"
title.TextColor3 = Color3.new(0,0.9,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 17
title.Parent = mainFrame

-- 夜视按钮
local nightBtn = Instance.new("TextButton")
nightBtn.Size = UDim2.new(0.85,0,0,26)
nightBtn.Position = UDim2.new(0.075,0,0,32)
nightBtn.BackgroundColor3 = Color3.new(0,0.45,0.7)
nightBtn.Text = "开启夜视"
nightBtn.TextColor3 = Color3.new(1,1,1)
nightBtn.TextSize = 13
nightBtn.Parent = mainFrame

-- 角色高亮按钮
local espBtn = Instance.new("TextButton")
espBtn.Size = UDim2.new(0.85,0,0,26)
espBtn.Position = UDim2.new(0.075,0,0,60)
espBtn.BackgroundColor3 = Color3.new(0.3,0.6,0.2)
espBtn.Text = "开启角色标记"
espBtn.TextColor3 = Color3.new(1,1,1)
espBtn.TextSize = 13
espBtn.Parent = mainFrame

-- 时间锁定按钮
local timeBtn = Instance.new("TextButton")
timeBtn.Size = UDim2.new(0.85,0,0,26)
timeBtn.Position = UDim2.new(0.075,0,0,88)
timeBtn.BackgroundColor3 = Color3.new(0.6,0.4,0.1)
timeBtn.Text = "固定正午时间"
timeBtn.TextColor3 = Color3.new(1,1,1)
timeBtn.TextSize = 13
timeBtn.Parent = mainFrame

-- 飞行开关
local flyBtn = Instance.new("TextButton")
flyBtn.Size = UDim2.new(0.85,0,0,26)
flyBtn.Position = UDim2.new(0.075,0,0,116)
flyBtn.BackgroundColor3 = Color3.new(0.1,0.7,0.7)
flyBtn.Text = "开启飞行"
flyBtn.TextColor3 = Color3.new(1,1,1)
flyBtn.TextSize = 13
flyBtn.Parent = mainFrame

-- 飞行速度增减
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.4,0,0,22)
speedLabel.Position = UDim2.new(0.075,0,0,144)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "飞行速度:"..flySpeed
speedLabel.TextColor3 = Color3.new(1,1,1)
speedLabel.TextSize = 12
speedLabel.Parent = mainFrame

local speedAdd = Instance.new("TextButton")
speedAdd.Size = UDim2.new(0.18,0,0,22)
speedAdd.Position = UDim2.new(0.48,0,0,144)
speedAdd.BackgroundColor3 = Color3.new(0,0.5,0)
speedAdd.Text = "+"
speedAdd.TextColor3 = Color3.new(1,1,1)
speedAdd.Parent = mainFrame

local speedMinus = Instance.new("TextButton")
speedMinus.Size = UDim2.new(0.18,0,0,22)
speedMinus.Position = UDim2.new(0.68,0,0,144)
speedMinus.BackgroundColor3 = Color3.new(0.6,0,0)
speedMinus.Text = "-"
speedMinus.TextColor3 = Color3.new(1,1,1)
speedMinus.Parent = mainFrame

-- 车辆加速按钮
local carSpeedBtn = Instance.new("TextButton")
carSpeedBtn.Size = UDim2.new(0.85,0,0,26)
carSpeedBtn.Position = UDim2.new(0.075,0,0,168)
carSpeedBtn.BackgroundColor3 = Color3.new(0.8,0.2,0.5)
carSpeedBtn.Text = "车辆加速开启"
carSpeedBtn.TextColor3 = Color3.new(1,1,1)
carSpeedBtn.TextSize = 13
carSpeedBtn.Parent = mainFrame

-- 玩家列表分区标签
local listLabel = Instance.new("TextLabel")
listLabel.Size = UDim2.new(0.85,0,0,22)
listLabel.Position = UDim2.new(0.075,0,0,198)
listLabel.BackgroundTransparency = 1
listLabel.Text = "玩家传送列表"
listLabel.TextColor3 = Color3.new(1,1,1)
listLabel.TextSize = 13
listLabel.Parent = mainFrame

-- 玩家列表滚动框
local listScroll = Instance.new("ScrollingFrame")
listScroll.Size = UDim2.new(0.85,0,0,40)
listScroll.Position = UDim2.new(0.075,0,0,220)
listScroll.BackgroundColor3 = Color3.new(0.15,0.15,0.2)
listScroll.BorderSizePixel = 1
listScroll.BorderColor3 = Color3.new(0.3,0.3,0.4)
listScroll.CanvasSize = UDim2.new(0,0,0,0)
listScroll.ScrollBarThickness = 4
listScroll.Parent = mainFrame

-- 刷新列表按钮
local refreshListBtn = Instance.new("TextButton")
refreshListBtn.Size = UDim2.new(0.4,0,0,26)
refreshListBtn.Position = UDim2.new(0.075,0,0,264)
refreshListBtn.BackgroundColor3 = Color3.new(0.2,0.3,0.7)
refreshListBtn.Text = "刷新列表"
refreshListBtn.TextColor3 = Color3.new(1,1,1)
refreshListBtn.TextSize = 12
refreshListBtn.Parent = mainFrame

-- 传送到目标按钮
local tpToTargetBtn = Instance.new("TextButton")
tpToTargetBtn.Size = UDim2.new(0.38,0,0,26)
tpToTargetBtn.Position = UDim2.new(0.52,0,0,264)
tpToTargetBtn.BackgroundColor3 = Color3.new(0.1,0.6,0.4)
tpToTargetBtn.Text = "我传过去"
tpToTargetBtn.TextColor3 = Color3.new(1,1,1)
tpToTargetBtn.TextSize = 12
tpToTargetBtn.Parent = mainFrame

-- 呼叫玩家到我按钮
local tpToMeBtn = Instance.new("TextButton")
tpToMeBtn.Size = UDim2.new(0.85,0,0,26)
tpToMeBtn.Position = UDim2.new(0.075,0,0,292)
tpToMeBtn.BackgroundColor3 = Color3.new(0.7,0.4,0.1)
tpToMeBtn.Text = "让目标传送到我"
tpToMeBtn.TextColor3 = Color3.new(1,1,1)
tpToMeBtn.TextSize = 12
tpToMeBtn.Parent = mainFrame

-- 重置全部按钮
local resetBtn = Instance.new("TextButton")
resetBtn.Size = UDim2.new(0.85,0,0,28)
resetBtn.Position = UDim2.new(0.075,0,0,320)
resetBtn.BackgroundColor3 = Color3.new(0.7,0.2,0.2)
resetBtn.Text = "重置全部设置"
resetBtn.TextColor3 = Color3.new(1,1,1)
resetBtn.TextSize = 13
resetBtn.Parent = mainFrame

--==================== 飞行逻辑 ====================
local camera = workspace.CurrentCamera
local moveDir = Vector3.new(0,0,0)
local function updateFly()
    if not flyToggle then return end
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end
    hum.GravityScale = 0
    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Jumping,false)
    local camCFrame = camera.CFrame
    local moveVec = (camCFrame.LookVector * moveDir.Z + camCFrame.RightVector * moveDir.X) * flySpeed
    root.Velocity = Vector3.new(moveVec.X, moveDir.Y * flySpeed, moveVec.Z)
end

UserInputService.InputBegan:Connect(function(input,gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.W then moveDir = Vector3.new(moveDir.X,moveDir.Y,-1) end
    if input.KeyCode == Enum.KeyCode.S then moveDir = Vector3.new(moveDir.X,moveDir.Y,1) end
    if input.KeyCode == Enum.KeyCode.A then moveDir = Vector3.new(-1,moveDir.Y,moveDir.Z) end
    if input.KeyCode == Enum.KeyCode.D then moveDir = Vector3.new(1,moveDir.Y,moveDir.Z) end
    if input.KeyCode == Enum.KeyCode.Space then moveDir = Vector3.new(moveDir.X,1,moveDir.Z) end
    if input.KeyCode == Enum.KeyCode.LeftControl then moveDir = Vector3.new(moveDir.X,-1,moveDir.Z) end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.S then moveDir = Vector3.new(moveDir.X,moveDir.Y,0) end
    if input.KeyCode == Enum.KeyCode.A or input.KeyCode == Enum.KeyCode.D then moveDir = Vector3.new(0,moveDir.Y,moveDir.Z) end
    if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.LeftControl then moveDir = Vector3.new(moveDir.X,0,moveDir.Z) end
end)

flyBtn.MouseButton1Click:Connect(function()
    flyToggle = not flyToggle
    flyBtn.Text = flyToggle and "关闭飞行" or "开启飞行"
    if not flyToggle then
        local char = LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char.Humanoid.GravityScale = 1
        end
        moveDir = Vector3.new(0,0,0)
    end
end)

speedAdd.MouseButton1Click:Connect(function()
    flySpeed += 10
    speedLabel.Text = "飞行速度:"..flySpeed
end)
speedMinus.MouseButton1Click:Connect(function()
    if flySpeed > 10 then
        flySpeed -= 10
        speedLabel.Text = "飞行速度:"..flySpeed
    end
end)

--==================== 车辆加速逻辑 ====================
local carBoostOn = false
carSpeedBtn.MouseButton1Click:Connect(function()
    carBoostOn = not carBoostOn
    carSpeedBtn.Text = carBoostOn and "车辆加速关闭" or "车辆加速开启"
end)
RunService.Heartbeat:Connect(function()
    if not carBoostOn then return end
    local char = LocalPlayer.Character
    if not char then return end
    local seat = char:FindFirstChildOfClass("VehicleSeat")
    if seat then
        seat.MaxSpeed = 120 * vehicleSpeedMult
        seat.Torque = seat.Torque * vehicleSpeedMult
    end
end)

--==================== 夜视切换 ====================
nightBtn.MouseButton1Click:Connect(function()
    nightToggle = not nightToggle
    if nightToggle then
        nightBtn.Text = "关闭夜视"
        Lighting.Brightness = 3.2
        Lighting.Ambient = Color3.new(0.9,0.9,0.9)
    else
        nightBtn.Text = "开启夜视"
        Lighting.Brightness = originalBright
        Lighting.Ambient = originalAmbient
    end
end)

--==================== 时间锁定切换 ====================
timeBtn.MouseButton1Click:Connect(function()
    timeToggle = not timeToggle
    if timeToggle then
        timeBtn.Text = "恢复自然时间"
        Lighting.TimeOfDay = 12
    else
        timeBtn.Text = "固定正午时间"
        Lighting.TimeOfDay = originalTime
    end
end)

--==================== 清除所有高亮缓存 ====================
local function clearAllHighlights()
    for _,hl in pairs(highlightCache) do
        pcall(function() hl:Destroy() end)
    end
    table.clear(highlightCache)
end

--==================== 角色高亮渲染（玩家白色/NPC绿色） ====================
local function refreshESP()
    if not espToggle then
        clearAllHighlights()
        return
    end
    for _,model in workspace:GetChildren() do
        if not model:IsA("Model") then continue end
        local human = model:FindFirstChildOfClass("Humanoid")
        if not human or model == LocalPlayer.Character then continue end
        local hl = highlightCache[model] or Instance.new("Highlight")
        hl.Adornee = model
        hl.FillTransparency = 0.5
        hl.OutlineTransparency = 0
        hl.Parent = model
        highlightCache[model] = hl
        local targetPlr = Players:GetPlayerFromCharacter(model)
        if targetPlr then
            hl.FillColor = Color3.new(1,1,1)
            hl.OutlineColor = Color3.new(1,1,1)
        else
            hl.FillColor = Color3.new(0,1,0)
            hl.OutlineColor = Color3.new(0,1,0)
        end
    end
end

espBtn.MouseButton1Click:Connect(function()
    espToggle = not espToggle
    espBtn.Text = espToggle and "关闭角色标记" or "开启角色标记"
    if not espToggle then clearAllHighlights() end
end)

RunService.RenderStepped:Connect(refreshESP)
RunService.RenderStepped:Connect(updateFly)

--==================== 刷新玩家列表函数 ====================
local function refreshPlayerList()
    for _,child in listScroll:GetChildren() do
        if child:IsA("TextButton") then child:Destroy() end
    end
    local offsetY = 0
    for _,plr in Players:GetPlayers() do
        if plr == LocalPlayer then continue end
        local playerBtn = Instance.new("TextButton")
        playerBtn.Size = UDim2.new(1,0,0,22)
        playerBtn.Position = UDim2.new(0,0,0,offsetY)
        playerBtn.BackgroundColor3 = Color3.new(0.2,0.2,0.3)
        playerBtn.Text = plr.Name
        playerBtn.TextColor3 = Color3.new(1,1,1)
        playerBtn.TextSize = 12
        playerBtn.Parent = listScroll
        playerBtn.MouseButton1Click:Connect(function()
            targetPlayer = plr
            for _,btn in listScroll:GetChildren() do
                if btn:IsA("TextButton") then
                    btn.BackgroundColor3 = Color3.new(0.2,0.2,0.3)
                end
            end
            playerBtn.BackgroundColor3 = Color3.new(0,0.5,0.8)
        end)
        offsetY += 24
    end
    listScroll.CanvasSize = UDim2.new(0,0,0,offsetY)
end

refreshListBtn.MouseButton1Click:Connect(refreshPlayerList)
task.wait(0.5)
refreshPlayerList()

--==================== 传送功能 ====================
tpToTargetBtn.MouseButton1Click:Connect(function()
    if not targetPlayer then return end
    local targetChar = targetPlayer.Character
    local localChar = LocalPlayer.Character
    if not targetChar or not localChar then return end
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    local myRoot = localChar:FindFirstChild("HumanoidRootPart")
    if targetRoot and myRoot then
        myRoot.CFrame = CFrame.new(targetRoot.Position + Vector3.new(0,3,0))
    end
end)

tpToMeBtn.MouseButton1Click:Connect(function()
    if not targetPlayer then return end
    local targetChar = targetPlayer.Character
    local localChar = LocalPlayer.Character
    if not targetChar or not localChar then return end
    local myRoot = localChar:FindFirstChild("HumanoidRootPart")
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if myRoot and targetRoot then
        targetRoot.CFrame = CFrame.new(myRoot.Position + Vector3.new(0,3,0))
    end
end)

--==================== 一键重置全部设置 ====================
resetBtn.MouseButton1Click:Connect(function()
    nightToggle = false
    espToggle = false
    timeToggle = false
    flyToggle = false
    carBoostOn = false
    targetPlayer = nil
    flySpeed = 50
    moveDir = Vector3.new(0,0,0)
    nightBtn.Text = "开启夜视"
    espBtn.Text = "开启角色标记"
    timeBtn.Text = "固定正午时间"
    flyBtn.Text = "开启飞行"
    carSpeedBtn.Text = "车辆加速开启"
    speedLabel.Text = "飞行速度:"..flySpeed
    Lighting.Brightness = originalBright
    Lighting.Ambient = originalAmbient
    Lighting.TimeOfDay = originalTime
    clearAllHighlights()
    refreshPlayerList()
    local char = LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        char.Humanoid.GravityScale = 1
    end
end)

--==================== 退出游戏自动还原光影 ====================
LocalPlayer.Removing:Connect(function()
    Lighting.Brightness = originalBright
    Lighting.Ambient = originalAmbient
    Lighting.TimeOfDay = originalTime
    clearAllHighlights()
    local char = LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        char.Humanoid.GravityScale = 1
    end
end)
