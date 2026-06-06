local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Balls = Workspace:WaitForChild("Balls")

-- MGA GLOBAL SETTINGS
local AutoParryEnabled = false
local ActivationDistance = 30
local HasManualParried = false
local ManualSpamEnabled = false
local IsSpamming = false
local BallTrackerEnabled = false
local LastParryTick = 0

-- Anti-Detection: Random Name Generator para sa UI
local function getRandomName()
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
    local length = math.random(10, 20)
    local str = ""
    for i = 1, length do
        local r = math.random(1, #chars)
        str = str .. string.sub(chars, r, r)
    end
    return str
end

if PlayerGui:FindFirstChild("AutoParryGui") then
    PlayerGui.AutoParryGui:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoParryGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

-- Main Frame (Enhanced Dark Theme with Gradient-like Effect)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 340, 0, 400)
mainFrame.Position = UDim2.new(0.5, -170, 0.4, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 20, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = mainFrame

local uiStroke = Instance.new("UIStroke")
uiStroke.Thickness = 3
uiStroke.Color = Color3.fromRGB(0, 200, 255)
uiStroke.Parent = mainFrame
uiStroke.Transparency = 0

-- Title Bar with Enhanced Styling
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 60)
titleBar.BackgroundColor3 = Color3.fromRGB(5, 30, 50)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 14)
titleCorner.Parent = titleBar

local titleGradientBar = Instance.new("Frame")
titleGradientBar.Size = UDim2.new(1, 0, 0, 4)
titleGradientBar.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
titleGradientBar.BorderSizePixel = 0
titleGradientBar.Parent = titleBar

local titleIcon = Instance.new("TextLabel")
titleIcon.Name = "Icon"
titleIcon.Text = "⚡"
titleIcon.Size = UDim2.new(0, 30, 0, 30)
titleIcon.Position = UDim2.new(0, 12, 0.5, -15)
titleIcon.BackgroundTransparency = 1
titleIcon.TextColor3 = Color3.fromRGB(0, 255, 200)
titleIcon.TextSize = 18
titleIcon.Font = Enum.Font.GothamBold
titleIcon.Parent = titleBar

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Text = "DREAM PARRY"
title.Size = UDim2.new(1, -90, 0, 25)
title.Position = UDim2.new(0, 45, 0, 8)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(0, 255, 200)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

local subtitle = Instance.new("TextLabel")
subtitle.Name = "Subtitle"
subtitle.Text = "Advanced Parry System"
subtitle.Size = UDim2.new(1, -90, 0, 16)
subtitle.Position = UDim2.new(0, 45, 0, 32)
subtitle.BackgroundTransparency = 1
subtitle.TextColor3 = Color3.fromRGB(100, 220, 255)
subtitle.TextSize = 11
subtitle.Font = Enum.Font.GothamMedium
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = titleBar

-- Close/Minimize Button (Enhanced)
local minButton = Instance.new("TextButton")
minButton.Name = "MinButton"
minButton.Text = "━"
minButton.Size = UDim2.new(0, 30, 0, 30)
minButton.Position = UDim2.new(1, -42, 0.5, -15)
minButton.BackgroundColor3 = Color3.fromRGB(0, 80, 150)
minButton.TextColor3 = Color3.fromRGB(0, 255, 200)
minButton.TextSize = 16
minButton.Font = Enum.Font.GothamBold
minButton.ZIndex = 5
minButton.Parent = titleBar

Instance.new("UICorner", minButton).CornerRadius = UDim.new(0, 8)
local minStroke = Instance.new("UIStroke")
minStroke.Thickness = 2
minStroke.Color = Color3.fromRGB(0, 200, 255)
minStroke.Parent = minButton
minStroke.Transparency = 0

-- Button hover effects
minButton.MouseEnter:Connect(function()
    TweenService:Create(minButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 150, 255)}):Play()
end)

minButton.MouseLeave:Connect(function()
    TweenService:Create(minButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 80, 150)}):Play()
end)

-- Scroll Frame (Enhanced)
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "ScrollFrame"
scrollFrame.Size = UDim2.new(1, -24, 1, -150)
scrollFrame.Position = UDim2.new(0, 12, 0, 75)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 4
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 200, 255)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 350)
scrollFrame.Parent = mainFrame

local listLayout = Instance.new("UIListLayout", scrollFrame)
listLayout.Padding = UDim.new(0, 12)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Stats / Security Alert Label (Enhanced)
local statsLabel = Instance.new("TextLabel")
statsLabel.Size = UDim2.new(1, -24, 0, 50)
statsLabel.Position = UDim2.new(0, 12, 1, -62)
statsLabel.BackgroundColor3 = Color3.fromRGB(5, 30, 40)
statsLabel.Text = "🔒 Waiting for activation..."
statsLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
statsLabel.Font = Enum.Font.GothamMedium
statsLabel.TextSize = 11
statsLabel.BorderSizePixel = 0
statsLabel.TextWrapped = true
statsLabel.Parent = mainFrame

Instance.new("UICorner", statsLabel).CornerRadius = UDim.new(0, 10)
local statsStroke = Instance.new("UIStroke", statsLabel)
statsStroke.Color = Color3.fromRGB(0, 200, 255)
statsStroke.Thickness = 2
statsStroke.Transparency = 0

-- Minimize / Unminimize Logic (Enhanced)
local isMinimized = false
minButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        minButton.Text = "+"
        scrollFrame.Visible = false
        statsLabel.Visible = false
        TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 340, 0, 60)}):Play()
    else
        minButton.Text = "━"
        local tween = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 340, 0, 400)})
        tween:Play()
        tween.Completed:Connect(function()
            if not isMinimized then
                scrollFrame.Visible = true
                statsLabel.Visible = true
            end
        end)
    end
end)

-- CENTER NOTIFICATION SYSTEM (Enhanced)
local function showNotification(message, isSuccess)
    local notifFrame = Instance.new("Frame")
    notifFrame.Size = UDim2.new(0, 300, 0, 60)
    notifFrame.Position = UDim2.new(0.5, -150, 0, -80)
    notifFrame.BackgroundColor3 = isSuccess and Color3.fromRGB(0, 40, 30) or Color3.fromRGB(40, 10, 10)
    notifFrame.ZIndex = 10
    notifFrame.Parent = screenGui
    
    Instance.new("UICorner", notifFrame).CornerRadius = UDim.new(0, 12)
    local stroke = Instance.new("UIStroke", notifFrame)
    stroke.Thickness = 2
    stroke.Color = isSuccess and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 100, 100)
    
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 30, 0, 30)
    icon.Position = UDim2.new(0, 12, 0.5, -15)
    icon.BackgroundTransparency = 1
    icon.Text = isSuccess and "✓" or "✕"
    icon.TextColor3 = isSuccess and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 100, 100)
    icon.Font = Enum.Font.GothamBold
    icon.TextSize = 20
    icon.Parent = notifFrame
    
    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(1, -60, 1, 0)
    txt.Position = UDim2.new(0, 45, 0, 0)
    txt.BackgroundTransparency = 1
    txt.Text = message
    txt.TextColor3 = Color3.fromRGB(255, 255, 255)
    txt.Font = Enum.Font.GothamBold
    txt.TextSize = 12
    txt.TextWrapped = true
    txt.TextXAlignment = Enum.TextXAlignment.Left
    txt.Parent = notifFrame
    
    notifFrame:TweenPosition(UDim2.new(0.5, -150, 0, 40), "Out", "Back", 0.5, true)
    
    task.delay(3.5, function()
        if notifFrame and notifFrame.Parent then
            notifFrame:TweenPosition(UDim2.new(0.5, -150, 0, -80), "In", "Quad", 0.4, true, function()
                notifFrame:Destroy()
            end)
        end
    end)
end

-- HUD BALL TRACKER DISPLAY PANEL (Enhanced)
local trackerPanel = Instance.new("Frame")
trackerPanel.Name = "BallTrackerPanel"
trackerPanel.Size = UDim2.new(0, 220, 0, 130)
trackerPanel.Position = UDim2.new(0.05, 0, 0.4, 0)
trackerPanel.BackgroundColor3 = Color3.fromRGB(5, 20, 40)
trackerPanel.BorderSizePixel = 0
trackerPanel.Active = true
trackerPanel.Draggable = true
trackerPanel.Visible = false
trackerPanel.Parent = screenGui

Instance.new("UICorner", trackerPanel).CornerRadius = UDim.new(0, 12)
local trackerStroke = Instance.new("UIStroke", trackerPanel)
trackerStroke.Thickness = 3
trackerStroke.Color = Color3.fromRGB(0, 200, 255)
trackerStroke.Transparency = 0

local trackerTitle = Instance.new("TextLabel")
trackerTitle.Text = "📊 BALL TRACKER"
trackerTitle.Size = UDim2.new(1, 0, 0, 28)
trackerTitle.BackgroundColor3 = Color3.fromRGB(0, 60, 100)
trackerTitle.BorderSizePixel = 0
trackerTitle.TextColor3 = Color3.fromRGB(0, 255, 200)
trackerTitle.Font = Enum.Font.GothamBold
trackerTitle.TextSize = 11
trackerTitle.Parent = trackerPanel
Instance.new("UICorner", trackerTitle).CornerRadius = UDim.new(0, 12)

local speedHUD = Instance.new("TextLabel")
speedHUD.Text = "⚡ Velocity: 0 studs/s"
speedHUD.Size = UDim2.new(1, -20, 0, 28)
speedHUD.Position = UDim2.new(0, 10, 0, 35)
speedHUD.BackgroundTransparency = 1
speedHUD.TextColor3 = Color3.fromRGB(0, 255, 200)
speedHUD.Font = Enum.Font.GothamMedium
speedHUD.TextSize = 12
speedHUD.TextXAlignment = Enum.TextXAlignment.Left
speedHUD.Parent = trackerPanel

local targetHUD = Instance.new("TextLabel")
targetHUD.Text = "🎯 Target: SAFE"
targetHUD.Size = UDim2.new(1, -20, 0, 28)
targetHUD.Position = UDim2.new(0, 10, 0, 72)
targetHUD.BackgroundTransparency = 1
targetHUD.TextColor3 = Color3.fromRGB(0, 255, 150)
targetHUD.Font = Enum.Font.GothamBold
targetHUD.TextSize = 12
targetHUD.TextXAlignment = Enum.TextXAlignment.Left
targetHUD.Parent = trackerPanel

-- FLOATING MANUAL SPAM BUTTON (Enhanced)
local spamFloatButton = Instance.new("TextButton")
spamFloatButton.Name = "SpamFloatButton"
spamFloatButton.Size = UDim2.new(0, 70, 0, 70)
spamFloatButton.Position = UDim2.new(0.8, 0, 0.5, -35)
spamFloatButton.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
spamFloatButton.Text = "🔥"
spamFloatButton.TextColor3 = Color3.fromRGB(255, 200, 0)
spamFloatButton.Font = Enum.Font.GothamBold
spamFloatButton.TextSize = 24
spamFloatButton.Active = true
spamFloatButton.Draggable = true
spamFloatButton.Visible = false
spamFloatButton.Parent = screenGui

local floatCorner = Instance.new("UICorner")
floatCorner.CornerRadius = UDim.new(1, 0)
floatCorner.Parent = spamFloatButton

local floatStroke = Instance.new("UIStroke")
floatStroke.Thickness = 3
floatStroke.Color = Color3.fromRGB(0, 255, 200)
floatStroke.Parent = spamFloatButton
floatStroke.Transparency = 0

-- Hover effects for spam button
spamFloatButton.MouseEnter:Connect(function()
    TweenService:Create(spamFloatButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 150, 255)}):Play()
    floatStroke.Transparency = 0
end)

spamFloatButton.MouseLeave:Connect(function()
    if not IsSpamming then
        TweenService:Create(spamFloatButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 100, 200)}):Play()
        floatStroke.Transparency = 0
    end
end)

local function executeSpamLoop()
    task.spawn(function()
        while IsSpamming and ManualSpamEnabled and HasManualParried do
            pcall(function()
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                task.wait(math.random(15, 30) / 1000)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
            end)
            task.wait(math.random(20, 40) / 1000)
        end
    end)
end

spamFloatButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        IsSpamming = true
        TweenService:Create(spamFloatButton, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 100, 0)}):Play()
        spamFloatButton.Text = "⚡"
        floatStroke.Transparency = 0
        floatStroke.Color = Color3.fromRGB(255, 150, 0)
        executeSpamLoop()
    end
end)

spamFloatButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        IsSpamming = false
        TweenService:Create(spamFloatButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 100, 200)}):Play()
        spamFloatButton.Text = "🔥"
        floatStroke.Color = Color3.fromRGB(0, 255, 200)
        floatStroke.Transparency = 0
    end
end)

-- SLIDER COMPONENT (Enhanced)
local function createSlider(label, minVal, maxVal, defaultVal, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 70)
    container.BackgroundColor3 = Color3.fromRGB(15, 35, 60)
    container.BorderSizePixel = 0
    container.Parent = scrollFrame
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 10)
    local containerStroke = Instance.new("UIStroke", container)
    containerStroke.Color = Color3.fromRGB(0, 150, 255)
    containerStroke.Thickness = 2
    containerStroke.Transparency = 0
    
    local labelText = Instance.new("TextLabel")
    labelText.Text = label
    labelText.Size = UDim2.new(1, -60, 0, 20)
    labelText.Position = UDim2.new(0, 10, 0, 8)
    labelText.BackgroundTransparency = 1
    labelText.TextColor3 = Color3.fromRGB(0, 255, 200)
    labelText.TextSize = 12
    labelText.Font = Enum.Font.GothamBold
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = container
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Text = tostring(defaultVal)
    valueLabel.Size = UDim2.new(0, 45, 0, 20)
    valueLabel.Position = UDim2.new(1, -55, 0, 8)
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    valueLabel.TextSize = 12
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = container
    
    local sliderButton = Instance.new("TextButton")
    sliderButton.Size = UDim2.new(1, -20, 0, 6)
    sliderButton.Position = UDim2.new(0, 10, 0, 40)
    sliderButton.BackgroundColor3 = Color3.fromRGB(20, 50, 100)
    sliderButton.Text = ""
    sliderButton.BorderSizePixel = 0
    sliderButton.Parent = container
    Instance.new("UICorner", sliderButton).CornerRadius = UDim.new(0, 3)
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
    fill.BorderSizePixel = 0
    fill.Parent = sliderButton
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 3)
    
    local dragging = false
    local function updateSlider(input)
        local percentage = math.clamp((input.Position.X - sliderButton.AbsolutePosition.X) / sliderButton.AbsoluteSize.X, 0, 1)
        local value = math.floor(minVal + (maxVal - minVal) * percentage)
        TweenService:Create(fill, TweenInfo.new(0.1), {Size = UDim2.new(percentage, 0, 1, 0)}):Play()
        valueLabel.Text = tostring(value)
        callback(value)
    end
    
    sliderButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
            dragging = true
            updateSlider(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then updateSlider(input) end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
end

-- TOGGLE COMPONENT (Enhanced)
local function createToggle(label, defaultState, callback)
    local container = Instance.new("TextButton")
    container.Size = UDim2.new(1, 0, 0, 50)
    container.BackgroundColor3 = Color3.fromRGB(15, 35, 60)
    container.BorderSizePixel = 0
    container.Text = ""
    container.Parent = scrollFrame
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 10)
    local containerStroke = Instance.new("UIStroke", container)
    containerStroke.Color = Color3.fromRGB(0, 150, 255)
    containerStroke.Thickness = 2
    containerStroke.Transparency = 0
    
    local labelText = Instance.new("TextLabel")
    labelText.Text = label
    labelText.Size = UDim2.new(1, -70, 1, 0)
    labelText.Position = UDim2.new(0, 12, 0, 0)
    labelText.BackgroundTransparency = 1
    labelText.TextColor3 = Color3.fromRGB(0, 255, 200)
    labelText.TextSize = 13
    labelText.Font = Enum.Font.GothamBold
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = container
    
    local toggleButton = Instance.new("Frame")
    toggleButton.Size = UDim2.new(0, 40, 0, 20)
    toggleButton.Position = UDim2.new(1, -50, 0.5, -10)
    toggleButton.BackgroundColor3 = defaultState and Color3.fromRGB(0, 200, 255) or Color3.fromRGB(30, 60, 100)
    toggleButton.BorderSizePixel = 0
    toggleButton.Parent = container
    Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(0, 10)
    
    local toggleStroke = Instance.new("UIStroke", toggleButton)
    toggleStroke.Color = Color3.fromRGB(0, 200, 255)
    toggleStroke.Thickness = 1.5
    toggleStroke.Transparency = 0
    
    local toggleCircle = Instance.new("Frame")
    toggleCircle.Size = UDim2.new(0, 16, 0, 16)
    toggleCircle.Position = defaultState and UDim2.new(0, 21, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleCircle.BorderSizePixel = 0
    toggleCircle.Parent = toggleButton
    Instance.new("UICorner", toggleCircle).CornerRadius = UDim.new(0, 8)
    
    local isEnabled = defaultState
    container.MouseButton1Click:Connect(function()
        isEnabled = not isEnabled
        local targetColor = isEnabled and Color3.fromRGB(0, 200, 255) or Color3.fromRGB(30, 60, 100)
        local targetPos = isEnabled and UDim2.new(0, 21, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        
        TweenService:Create(toggleButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = targetColor}):Play()
        TweenService:Create(toggleCircle, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = targetPos}):Play()
        callback(isEnabled)
    end)
    
    -- Hover effect
    container.MouseEnter:Connect(function()
        TweenService:Create(containerStroke, TweenInfo.new(0.2), {Transparency = 0}):Play()
    end)
    
    container.MouseLeave:Connect(function()
        TweenService:Create(containerStroke, TweenInfo.new(0.2), {Transparency = 0}):Play()
    end)
end

-- BUILD THE CORE UI
createSlider("🎯 Parry Distance (Studs)", 15, 60, 30, function(value) ActivationDistance = value end)

createToggle("⚔️ God Auto Parry", false, function(state)
    AutoParryEnabled = state
    if HasManualParried then
        statsLabel.Text = state and "⚡ STATUS: AUTO PARRY ENABLED" or "✓ STATUS: MONITORING..."
    end
end)

createToggle("🔥 Manual Spam Button", false, function(state)
    ManualSpamEnabled = state
    if HasManualParried then
        spamFloatButton.Visible = state
    else
        spamFloatButton.Visible = false
    end
    if not state then IsSpamming = false end
end)

createToggle("📊 Ball Tracker Display", false, function(state)
    BallTrackerEnabled = state
    trackerPanel.Visible = state
end)

-- SECURED UNLOCK ENGINE
local function unlockEngine()
    if not HasManualParried then
        HasManualParried = true
        
        statsLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
        statsLabel.BackgroundColor3 = Color3.fromRGB(5, 40, 20)
        statsLabel.Text = "✓ SYSTEM ACTIVE - Ready for parrying"
        statsStroke.Color = Color3.fromRGB(0, 255, 150)
        
        showNotification("🔓 System Activated!", true)
        
        if ManualSpamEnabled then
            spamFloatButton.Visible = true
        end
    end
end

UserInputService.InputBegan:Connect(function(input, processed)
    if input.KeyCode == Enum.KeyCode.F or input.UserInputType == Enum.UserInputType.Touch then
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            task.delay(0.05, unlockEngine)
        end
    end
end)

local function IsTarget()
    return (Player.Character and Player.Character:FindFirstChild("Highlight"))
end

-- HUMANIZED PARRY EXECUTOR
local function Parry()
    local currentTick = tick()
    if currentTick - LastParryTick < 0.25 then return end
    LastParryTick = currentTick

    task.defer(function()
        pcall(function()
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
            task.wait(math.random(25, 45) / 1000)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
        end)
    end)
end

local function MonitorBall(Ball)
    if not Ball:IsA("BasePart") or Ball:GetAttribute("realBall") ~= true then return end
    
    local lastPosition = Ball.Position
    local lastUpdateTime = tick()
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not Ball.Parent or not screenGui.Parent then
            connection:Disconnect()
            speedHUD.Text = "⚡ Velocity: 0 studs/s"
            targetHUD.Text = "🎯 Target: SAFE"
            targetHUD.TextColor3 = Color3.fromRGB(0, 255, 150)
            return
        end
        
        local currentTime = tick()
        local deltaTime = currentTime - lastUpdateTime
        local ballSpeed = 0
        local isTargetingMe = IsTarget()
        
        if deltaTime > 0 then
            local realVelocity = (Ball.Position - lastPosition) / deltaTime
            ballSpeed = realVelocity.Magnitude
            
        if BallTrackerEnabled then
                speedHUD.Text = "⚡ Velocity: " .. math.floor(ballSpeed) .. " studs/s"
                if isTargetingMe then
                    targetHUD.Text = "🚨 Target: DANGER!"
                    targetHUD.TextColor3 = Color3.fromRGB(255, 100, 100)
                    trackerStroke.Color = Color3.fromRGB(255, 100, 100)
                    trackerStroke.Transparency = 0
                else
                    targetHUD.Text = "🎯 Target: SAFE"
                    targetHUD.TextColor3 = Color3.fromRGB(0, 255, 150)
                    trackerStroke.Color = Color3.fromRGB(0, 200, 255)
                    trackerStroke.Transparency = 0
                end
            end
            
            if HasManualParried and AutoParryEnabled and isTargetingMe and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                local myPos = Player.Character.HumanoidRootPart.Position
                local distance = (Ball.Position - myPos).Magnitude
                
                local dynamicDistance = ActivationDistance + (ballSpeed * 0.11)
                local dotProduct = realVelocity.Unit:Dot((myPos - Ball.Position).Unit)
                
                if distance <= dynamicDistance and dotProduct > 0 then
                    Parry()
                    statsLabel.Text = "⚡ Last Parry Speed: " .. math.floor(ballSpeed) .. " studs/s"
                end
            end
        end
        
        lastPosition = Ball.Position
        lastUpdateTime = tick()
    end)
end

-- Gumamit ng standard loop sa halip na table.foreach para iwas linter warnings
for _, ball in ipairs(Balls:GetChildren()) do
    MonitorBall(ball)
end
Balls.ChildAdded:Connect(MonitorBall)