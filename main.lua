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

-- Main Frame (Minimalist Black Theme)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 320, 0, 360)
mainFrame.Position = UDim2.new(0.5, -160, 0.4, -180)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

local uiStroke = Instance.new("UIStroke")
uiStroke.Thickness = 1
uiStroke.Color = Color3.fromRGB(45, 45, 45)
uiStroke.Parent = mainFrame

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 50)
titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Text = "DREAM PARRY // PRO"
title.Size = UDim2.new(1, -50, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 13
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

-- Minimize Button
local minButton = Instance.new("TextButton")
minButton.Name = "MinButton"
minButton.Text = "—"
minButton.Size = UDim2.new(0, 26, 0, 26)
minButton.Position = UDim2.new(1, -38, 0.5, -13)
minButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
minButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minButton.TextSize = 12
minButton.Font = Enum.Font.GothamBold
minButton.ZIndex = 5
minButton.Parent = titleBar

Instance.new("UICorner", minButton).CornerRadius = UDim.new(0, 6)
local minStroke = Instance.new("UIStroke")
minStroke.Thickness = 1
minStroke.Color = Color3.fromRGB(50, 50, 50)
minStroke.Parent = minButton

-- Scroll Frame
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "ScrollFrame"
scrollFrame.Size = UDim2.new(1, -24, 1, -125)
scrollFrame.Position = UDim2.new(0, 12, 0, 65)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 2
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 320)
scrollFrame.Parent = mainFrame

Instance.new("UIListLayout", scrollFrame).Padding = UDim.new(0, 10)

-- Stats / Security Alert Label
local statsLabel = Instance.new("TextLabel")
statsLabel.Size = UDim2.new(1, -24, 0, 35)
statsLabel.Position = UDim2.new(0, 12, 1, -48)
statsLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
statsLabel.Text = "ANTI-CHEAT: Waiting for your 1st manual parry..."
statsLabel.TextColor3 = Color3.fromRGB(230, 160, 40)
statsLabel.Font = Enum.Font.GothamMedium
statsLabel.TextSize = 11
statsLabel.BorderSizePixel = 0
statsLabel.Parent = mainFrame

Instance.new("UICorner", statsLabel).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", statsLabel).Color = Color3.fromRGB(60, 50, 30)

-- Minimize / Unminimize Logic
local isMinimized = false
minButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        minButton.Text = "+"
        scrollFrame.Visible = false
        statsLabel.Visible = false
        TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 320, 0, 50)}):Play()
    else
        minButton.Text = "—"
        local tween = TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 320, 0, 360)})
        tween:Play()
        tween.Completed:Connect(function()
            if not isMinimized then
                scrollFrame.Visible = true
                statsLabel.Visible = true
            end
        end)
    end
end)

-- CENTER NOTIFICATION SYSTEM
local function showNotification(message, isSuccess)
    local notifFrame = Instance.new("Frame")
    notifFrame.Size = UDim2.new(0, 280, 0, 50)
    notifFrame.Position = UDim2.new(0.5, -140, 0, -70)
    notifFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    notifFrame.ZIndex = 10
    notifFrame.Parent = screenGui
    
    Instance.new("UICorner", notifFrame).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", notifFrame)
    stroke.Thickness = 1.5
    stroke.Color = isSuccess and Color3.fromRGB(40, 230, 40) or Color3.fromRGB(230, 40, 40)
    
    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(1, -20, 1, 0)
    txt.Position = UDim2.new(0, 10, 0, 0)
    txt.BackgroundTransparency = 1
    txt.Text = message
    txt.TextColor3 = Color3.fromRGB(255, 255, 255)
    txt.Font = Enum.Font.GothamBold
    txt.TextSize = 12
    txt.Parent = notifFrame
    
    notifFrame:TweenPosition(UDim2.new(0.5, -140, 0, 30), "Out", "Back", 0.4, true)
    
    task.delay(3, function()
        if notifFrame and notifFrame.Parent then
            notifFrame:TweenPosition(UDim2.new(0.5, -140, 0, -70), "In", "Quad", 0.3, true, function()
                notifFrame:Destroy()
            end)
        end
    end)
end

-- HUD BALL TRACKER DISPLAY PANEL
local trackerPanel = Instance.new("Frame")
trackerPanel.Name = "BallTrackerPanel"
trackerPanel.Size = UDim2.new(0, 200, 0, 100)
trackerPanel.Position = UDim2.new(0.05, 0, 0.4, 0)
trackerPanel.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
trackerPanel.BorderSizePixel = 0
trackerPanel.Active = true
trackerPanel.Draggable = true
trackerPanel.Visible = false
trackerPanel.Parent = screenGui

Instance.new("UICorner", trackerPanel).CornerRadius = UDim.new(0, 10)
local trackerStroke = Instance.new("UIStroke", trackerPanel)
trackerStroke.Thickness = 1
trackerStroke.Color = Color3.fromRGB(50, 50, 50)

local trackerTitle = Instance.new("TextLabel")
trackerTitle.Text = "LIVE BALL TRACKER"
trackerTitle.Size = UDim2.new(1, 0, 0, 25)
trackerTitle.BackgroundTransparency = 1
trackerTitle.TextColor3 = Color3.fromRGB(150, 150, 150)
trackerTitle.Font = Enum.Font.GothamBold
trackerTitle.TextSize = 10
trackerTitle.Parent = trackerPanel

local speedHUD = Instance.new("TextLabel")
speedHUD.Text = "Velocity: 0 studs/s"
speedHUD.Size = UDim2.new(1, -20, 0, 25)
speedHUD.Position = UDim2.new(0, 10, 0, 30)
speedHUD.BackgroundTransparency = 1
speedHUD.TextColor3 = Color3.fromRGB(255, 255, 255)
speedHUD.Font = Enum.Font.GothamMedium
speedHUD.TextSize = 12
speedHUD.TextXAlignment = Enum.TextXAlignment.Left
speedHUD.Parent = trackerPanel

local targetHUD = Instance.new("TextLabel")
targetHUD.Text = "Target: SAFE"
targetHUD.Size = UDim2.new(1, -20, 0, 25)
targetHUD.Position = UDim2.new(0, 10, 0, 60)
targetHUD.BackgroundTransparency = 1
targetHUD.TextColor3 = Color3.fromRGB(100, 255, 100)
targetHUD.Font = Enum.Font.GothamBold
targetHUD.TextSize = 13
targetHUD.TextXAlignment = Enum.TextXAlignment.Left
targetHUD.Parent = trackerPanel

-- FLOATING MANUAL SPAM BUTTON
local spamFloatButton = Instance.new("TextButton")
spamFloatButton.Name = "SpamFloatButton"
spamFloatButton.Size = UDim2.new(0, 65, 0, 65)
spamFloatButton.Position = UDim2.new(0.8, 0, 0.5, -32)
spamFloatButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
spamFloatButton.Text = "SPAM"
spamFloatButton.TextColor3 = Color3.fromRGB(255, 255, 255)
spamFloatButton.Font = Enum.Font.GothamBold
spamFloatButton.TextSize = 13
spamFloatButton.Active = true
spamFloatButton.Draggable = true
spamFloatButton.Visible = false
spamFloatButton.Parent = screenGui

local floatCorner = Instance.new("UICorner")
floatCorner.CornerRadius = UDim.new(1, 0)
floatCorner.Parent = spamFloatButton

local floatStroke = Instance.new("UIStroke")
floatStroke.Thickness = 1
floatStroke.Color = Color3.fromRGB(60, 60, 60)
floatStroke.Parent = spamFloatButton

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
        spamFloatButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        spamFloatButton.TextColor3 = Color3.fromRGB(0, 0, 0)
        executeSpamLoop()
    end
end)

spamFloatButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        IsSpamming = false
        spamFloatButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        spamFloatButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end)

-- SLIDER COMPONENT
local function createSlider(label, minVal, maxVal, defaultVal, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 65)
    container.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    container.BorderSizePixel = 0
    container.Parent = scrollFrame
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", container).Color = Color3.fromRGB(35, 35, 35)
    
    local labelText = Instance.new("TextLabel")
    labelText.Text = label
    labelText.Size = UDim2.new(1, -10, 0, 20)
    labelText.Position = UDim2.new(0, 10, 0, 8)
    labelText.BackgroundTransparency = 1
    labelText.TextColor3 = Color3.fromRGB(180, 180, 180)
    labelText.TextSize = 11
    labelText.Font = Enum.Font.GothamMedium
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = container
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Text = tostring(defaultVal)
    valueLabel.Size = UDim2.new(0, 40, 0, 20)
    valueLabel.Position = UDim2.new(1, -50, 0, 8)
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    valueLabel.TextSize = 11
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = container
    
    local sliderButton = Instance.new("TextButton")
    sliderButton.Size = UDim2.new(1, -20, 0, 4)
    sliderButton.Position = UDim2.new(0, 10, 0, 42)
    sliderButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    sliderButton.Text = ""
    sliderButton.BorderSizePixel = 0
    sliderButton.Parent = container
    Instance.new("UICorner", sliderButton).CornerRadius = UDim.new(0, 2)
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    fill.BorderSizePixel = 0
    fill.Parent = sliderButton
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 2)
    
    local dragging = false
    local function updateSlider(input)
        local percentage = math.clamp((input.Position.X - sliderButton.AbsolutePosition.X) / sliderButton.AbsoluteSize.X, 0, 1)
        local value = math.floor(minVal + (maxVal - minVal) * percentage)
        fill.Size = UDim2.new(percentage, 0, 1, 0)
        valueLabel.Text = tostring(value)
        callback(value)
    end
    
    sliderButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; updateSlider(input) end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then updateSlider(input) end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
end

-- TOGGLE COMPONENT
local function createToggle(label, defaultState, callback)
    local container = Instance.new("TextButton")
    container.Size = UDim2.new(1, 0, 0, 45)
    container.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    container.BorderSizePixel = 0
    container.Text = ""
    container.Parent = scrollFrame
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", container).Color = Color3.fromRGB(35, 35, 35)
    
    local labelText = Instance.new("TextLabel")
    labelText.Text = label
    labelText.Size = UDim2.new(1, -60, 1, 0)
    labelText.Position = UDim2.new(0, 10, 0, 0)
    labelText.BackgroundTransparency = 1
    labelText.TextColor3 = Color3.fromRGB(220, 220, 220)
    labelText.TextSize = 12
    labelText.Font = Enum.Font.GothamMedium
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = container
    
    local toggleButton = Instance.new("Frame")
    toggleButton.Size = UDim2.new(0, 34, 0, 18)
    toggleButton.Position = UDim2.new(1, -44, 0.5, -9)
    toggleButton.BackgroundColor3 = defaultState and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(45, 45, 45)
    toggleButton.BorderSizePixel = 0
    toggleButton.Parent = container
    Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(0, 9)
    
    local toggleCircle = Instance.new("Frame")
    toggleCircle.Size = UDim2.new(0, 12, 0, 12)
    toggleCircle.Position = defaultState and UDim2.new(0, 19, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
    toggleCircle.BackgroundColor3 = defaultState and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(200, 200, 200)
    toggleCircle.BorderSizePixel = 0
    toggleCircle.Parent = toggleButton
    Instance.new("UICorner", toggleCircle).CornerRadius = UDim.new(0, 6)
    
    local isEnabled = defaultState
    container.MouseButton1Click:Connect(function()
        isEnabled = not isEnabled
        local targetColor = isEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(45, 45, 45)
        local circleColor = isEnabled and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(200, 200, 200)
        local targetPos = isEnabled and UDim2.new(0, 19, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
        
        toggleButton.BackgroundColor3 = targetColor
        toggleCircle.BackgroundColor3 = circleColor
        
        TweenService:Create(toggleCircle, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = targetPos}):Play()
        callback(isEnabled)
    end)
end

-- BUILD THE CORE UI
createSlider("Parry Distance (Studs)", 15, 60, 30, function(value) ActivationDistance = value end)

createToggle("God Auto Parry", false, function(state)
    AutoParryEnabled = state
    if HasManualParried then
        statsLabel.Text = state and "Status: ACTIVE (God Mode)" or "Status: Monitoring..."
    end
end)

createToggle("Manual Spam Button", false, function(state)
    ManualSpamEnabled = state
    if HasManualParried then
        spamFloatButton.Visible = state
    else
        spamFloatButton.Visible = false
    end
    if not state then IsSpamming = false end
end)

createToggle("Ball Tracker Display", false, function(state)
    BallTrackerEnabled = state
    trackerPanel.Visible = state
end)

-- SECURED UNLOCK ENGINE
local function unlockEngine()
    if not HasManualParried then
        HasManualParried = true
        
        statsLabel.TextColor3 = Color3.fromRGB(40, 230, 40)
        statsLabel.BackgroundColor3 = Color3.fromRGB(15, 25, 15)
        statsLabel.Text = "SYSTEM BYPASS: Clean Engine Engaged!"
        statsLabel.Parent.UIStroke.Color = Color3.fromRGB(30, 60, 30)
        
        showNotification("SYSTEM BYPASS: ACTIVATED!", true)
        
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
            speedHUD.Text = "Velocity: 0 studs/s"
            targetHUD.Text = "Target: SAFE"
            targetHUD.TextColor3 = Color3.fromRGB(100, 255, 100)
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
                speedHUD.Text = "Velocity: " .. math.floor(ballSpeed) .. " studs/s"
                if isTargetingMe then
                    targetHUD.Text = "Target: DANGER (YOU)"
                    targetHUD.TextColor3 = Color3.fromRGB(255, 50, 50)
                    trackerStroke.Color = Color3.fromRGB(255, 50, 50)
                else
                    targetHUD.Text = "Target: SAFE"
                    targetHUD.TextColor3 = Color3.fromRGB(100, 255, 100)
                    trackerStroke.Color = Color3.fromRGB(50, 50, 50)
                end
            end
            
            if HasManualParried and AutoParryEnabled and isTargetingMe and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                local myPos = Player.Character.HumanoidRootPart.Position
                local distance = (Ball.Position - myPos).Magnitude
                
                local dynamicDistance = ActivationDistance + (ballSpeed * 0.11)
                local dotProduct = realVelocity.Unit:Dot((myPos - Ball.Position).Unit)
                
                if distance <= dynamicDistance and dotProduct > 0 then
                    Parry()
                    statsLabel.Text = "Last Auto Parry Speed: " .. math.floor(ballSpeed)
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