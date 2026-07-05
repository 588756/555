getgenv().XiaoPi_Detect_Config = {
    CustomName = "自定义头顶名字",
    DetectEnabled = true
}

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ====================== 自定义头顶称号（全房间可见） ======================
local function RemoveOldTag(character)
    local head = character:FindFirstChild("Head")
    if not head then return end
    for _, child in head:GetChildren() do
        if child.Name == "PiOverheadBillboard" then
            child:Destroy()
        end
    end
end

local function SpawnHeadTag(character, text)
    RemoveOldTag(character)
    local headPart = character:WaitForChild("Head", 3)
    if not headPart then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PiOverheadBillboard"
    billboard.Size = UDim2.new(4, 0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0, 2.3, 0)
    billboard.Parent = headPart

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 30
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.new(0,0,0)
    label.TextColor3 = Color3.new(1, 0.2, 0)
    label.Text = text
    label.Parent = billboard
end

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.7)
    SpawnHeadTag(char, getgenv().XiaoPi_Detect_Config.CustomName)
end)

-- ====================== 右上角玩家监测面板 ======================
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = PlayerGui
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 240, 0, 400)
mainFrame.Position = UDim2.new(1, -250, 0, 40)
mainFrame.BackgroundColor3 = Color3.new(0,0,0)
mainFrame.BackgroundTransparency = 0.4
mainFrame.BorderSizePixel = 1
mainFrame.BorderColor3 = Color3.new(1,0.2,0)
mainFrame.Parent = screenGui

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1,0,0,45)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "皮脚本玩家监测列表"
titleLabel.TextColor3 = Color3.new(1,0.2,0)
titleLabel.TextSize = 24
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Parent = mainFrame

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -10, 1, -50)
scrollFrame.Position = UDim2.new(0,5,0,45)
scrollFrame.BackgroundTransparency = 1
scrollFrame.CanvasSize = UDim2.new(0,0,0,0)
scrollFrame.Parent = mainFrame

local playerItem = Instance.new("TextLabel")
playerItem.Size = UDim2.new(1,0,0,36)
playerItem.BackgroundTransparency = 1
playerItem.TextSize = 19
playerItem.Visible = false
playerItem.Parent = scrollFrame

local highlightCache = {}

-- ====================== 核心检测：抓取角色身上的白边高亮 ======================
local function RefreshPlayerPanel()
    scrollFrame:ClearAllChildren()
    local offsetY = 0
    for _, plr in Players:GetPlayers() do
        local newLabel = playerItem:Clone()
        newLabel.Visible = true
        newLabel.Position = UDim2.new(0,0,0,offsetY)
        newLabel.Text = plr.Name
        newLabel.TextColor3 = Color3.new(1,1,1)

        local char = plr.Character
        if not char then continue end

        local hasXiaoPiHighlight = false
        --遍历角色所有子物体，查找高亮对象
        for _, child in char:GetChildren() do
            if child:IsA("Highlight") then
                --皮脚本高亮特征：绑定玩家本体、墙体透视、白色描边
                if child.Adornee == char and child.DepthMode == Enum.HighlightDepthMode.AlwaysOnTop then
                    highlightCache[plr] = (highlightCache[plr] or 0) + 1
                    if highlightCache[plr] > 3 then
                        hasXiaoPiHighlight = true
                    end
                end
            end
        end

        if not hasXiaoPiHighlight then
            highlightCache[plr] = math.max(0, (highlightCache[plr] or 0) - 1)
        end

        if hasXiaoPiHighlight then
            newLabel.Text = "[皮脚本] "..plr.Name
            newLabel.TextColor3 = Color3.new(1, 0, 0)
        end

        newLabel.Parent = scrollFrame
        offsetY += 36
    end
    scrollFrame.CanvasSize = UDim2.new(0,0,0,offsetY)
end

RunService.RenderStepped:Connect(RefreshPlayerPanel)

-- ====================== 称号修改弹窗 ======================
local settingWindow = Instance.new("Frame")
settingWindow.Size = UDim2.new(0, 320, 0, 180)
settingWindow.Position = UDim2.new(0.5, -160, 0.5, -90)
settingWindow.BackgroundColor3 = Color3.new(0,0,0)
settingWindow.BackgroundTransparency = 0.5
settingWindow.BorderColor3 = Color3.new(1,0.2,0)
settingWindow.Parent = screenGui

local winTitle = Instance.new("TextLabel")
winTitle.Size = UDim2.new(1,0,0,42)
winTitle.BackgroundTransparency = 1
winTitle.Text = "设置头顶显示名称"
winTitle.TextColor3 = Color3.new(1,0.2,0)
winTitle.TextSize = 22
winTitle.Parent = settingWindow

local inputBox = Instance.new("TextBox")
inputBox.Size = UDim2.new(0.8,0,0,50)
inputBox.Position = UDim2.new(0.1,0,0,48)
inputBox.BackgroundColor3 = Color3.new(0.12,0.12,0.12)
inputBox.Text = getgenv().XiaoPi_Detect_Config.CustomName
inputBox.TextColor3 = Color3.new(1,1,1)
inputBox.Parent = settingWindow

local confirmBtn = Instance.new("TextButton")
confirmBtn.Size = UDim2.new(0.8,0,0,42)
confirmBtn.Position = UDim2.new(0.1,0,0,110)
confirmBtn.BackgroundColor3 = Color3.new(1,0.2,0)
confirmBtn.Text = "确认保存"
confirmBtn.TextColor3 = Color3.new(0,0,0)
confirmBtn.Parent = settingWindow

confirmBtn.MouseButton1Click:Connect(function()
    getgenv().XiaoPi_Detect_Config.CustomName = inputBox.Text
    settingWindow.Visible = false
    if LocalPlayer.Character then
        SpawnHeadTag(LocalPlayer.Character, getgenv().XiaoPi_Detect_Config.CustomName)
    end
end)
