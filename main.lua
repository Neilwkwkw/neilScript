local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Balls = Workspace:WaitForChild("Balls")

-- GLOBAL BYPASS CONFIGS
local AutoParryEnabled = false
local ActivationDistance = 30 
local HasManualParried = false -- DITO NAKASALALAY ANG BYPASS (Katulad ng Levi Hub)
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

if PlayerGui:FindFirstChild("AutoParryGui") then PlayerGui.AutoParryGui:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = getRandomName()
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

-- Main Menu Window
local mainFrame = Instance.new("Frame")
mainFrame.Name = getRandomName()
mainFrame.Size = UDim2.new(0, 320, 0, 360)
mainFrame.Position = UDim2.new(0.5, -160, 0.4, -180) 
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true 
mainFrame.ClipsDescendants = true 
mainFrame.Parent = screenGui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
local uiStroke = Instance.new("UIStroke", mainFrame)
uiStroke.Thickness = 1
uiStroke.Color = Color3.fromRGB(45, 45, 45)

-- Title Header
local titleBar = Instance.new("Frame")
titleBar.Name = getRandomName()
titleBar.Size = UDim2.new(1, 0, 0, 50)
titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Text = "CORE SYSTEM MODULE"
title.Size = UDim2.new(1, -50, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 13
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

-- Minimize Engine
local minButton = Instance.new("TextButton")
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

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -24, 1, -125)
scrollFrame.Position = UDim2.new(0, 12, 0, 65)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 2
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 320)
scrollFrame.Parent = mainFrame

Instance.new("UIListLayout", scrollFrame).Padding = UDim.new(0, 10)

-- Bottom Status Notification Bar
local statsLabel = Instance.new("TextLabel")
statsLabel.Size = UDim2.new(1, -24, 0, 35)
statsLabel.Position = UDim2.new(0, 12, 1, -48)
statsLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
statsLabel.Text = "SECURITY: Perform 1 manual parry (F) to unlock..."
statsLabel.TextColor3 = Color3.fromRGB(230, 160, 40) 
statsLabel.Font = Enum.Font.GothamMedium
statsLabel.TextSize = 11
statsLabel.BorderSizePixel = 0
statsLabel.Parent = mainFrame

Instance.new("UICorner", statsLabel).CornerRadius = UDim.new(0, 8)
local bottomStroke = Instance.new("UIStroke", statsLabel)
bottomStroke.Color = Color3.fromRGB(60, 50, 30)

-- Minimize Event Handler
local isMinimized = false
minButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    minButton.Text = isMinimized and "+" or "—"
    scrollFrame.Visible = not isMinimized
    statsLabel.Visible = not isMinimized
    TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = isMinimized and UDim2.new(0, 320, 0, 50) or UDim2.new(0, 320, 0, 360)}):Play()
end)

-- HUMANIZED PARRY CONTROLLER (May dynamic delays para iwas algorithm scans)
local function Parry()
    local currentTick = tick()
    if currentTick - LastParryTick < 0.23 then return end 
    LastParryTick = currentTick

    task.defer(function() 
        pcall(function()
            local VIM = game:GetService("VirtualInputManager")
            if VIM then
                VIM:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                -- Random keypress hold time para mukhang tao ang pumindot
                task.wait(math.random(30, 50) / 1000) 
                VIM:SendKeyEvent(false, Enum.KeyCode.F, false, game)
            end
        end)
    end)
end

-- =========================================================
-- ANTI-CHEAT HANDSHAKE METHOD (LEVI HUB SIMULATION)
-- =========================================================
local function triggerSecurityHandshake()
    if not HasManualParried then
        HasManualParried = true
        
        statsLabel.TextColor3 = Color3.fromRGB(40, 230, 40) 
        statsLabel.BackgroundColor3 = Color3.fromRGB(15, 25, 15)
        statsLabel.Text = "BYPASS ENGAGED: Engine Stream Secure!"
        bottomStroke.Color = Color3.fromRGB(30, 60, 30)
        title.Text = "SYSTEM ENVIRONMENT // SECURE"
    end
end

-- Nag-aabang sa unang lehitimong parry mo gamit ang keyboard o mobile screen click
UserInputService.InputBegan:Connect(function(input, processed)
    if input.KeyCode == Enum.KeyCode.F or input.UserInputType == Enum.UserInputType.Touch then
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            task.delay(0.05, triggerSecurityHandshake)
        end
    end
end)

local function IsTarget()
    return (Player.Character and Player.Character:FindFirstChild("Highlight"))
end

-- LIGHTWEIGHT BALL TRACKING (Inalis ang mapanganib na Heartbeat connection)
local function HookBallVelocityEvents(Ball)
    if not Ball:IsA("BasePart") or Ball:GetAttribute("realBall") ~= true then return end
    
    local lastPosition = Ball.Position
    local lastUpdateTime = tick()
    
    Ball:GetPropertyChangedSignal("Position"):Connect(function()
        if not Ball.Parent then return end
        
        local currentTime = tick()
        local deltaTime = currentTime - lastUpdateTime
        local ballSpeed = 0
        local isTargetingMe = IsTarget()
        
        if deltaTime > 0 then
            local realVelocity = (Ball.Position - lastPosition) / deltaTime
            ballSpeed = realVelocity.Magnitude
            
            -- HINDI TATAKBO KAPAG HINDI KA PA NAG-MANUAL PARRY SA SIMULA
            if HasManualParried and AutoParryEnabled and isTargetingMe and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                local myPos = Player.Character.HumanoidRootPart.Position
                local distance = (Ball.Position - myPos).Magnitude
                
                -- Advanced velocity adjustment formula mo
                local dynamicDistance = ActivationDistance + (ballSpeed * 0.11)
                local dotProduct = realVelocity.Unit:Dot((myPos - Ball.Position).Unit)
                
                if distance <= dynamicDistance and dotProduct > 0 then
                    Parry()
                end
            end
        end
        
        lastPosition = Ball.Position
        lastUpdateTime = tick()
    end)
end

-- UI Engine Builder Sliders/Toggles
local function createSlider(label, minVal, maxVal, defaultVal, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 65)
    container.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    container.BorderSizePixel = 0
    container.Parent = scrollFrame
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)
    
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
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 11
    valueLabel.Parent = container
    
    local sliderButton = Instance.new("TextButton")
    sliderButton.Size = UDim2.new(1, -20, 0, 4)
    sliderButton.Position = UDim2.new(0, 10, 0, 42)
    sliderButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    sliderButton.Text = ""
    sliderButton.Parent = container
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    fill.BorderSizePixel = 0
    fill.Parent = sliderButton
    
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

local function createToggle(label, defaultState, callback)
    local container = Instance.new("TextButton")
    container.Size = UDim2.new(1, 0, 0, 45)
    container.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    container.Text = ""
    container.Parent = scrollFrame
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)
    
    local labelText = Instance.new("TextLabel")
    labelText.Text = label
    labelText.Size = UDim2.new(1, -60, 1, 0)
    labelText.Position = UDim2.new(0, 10, 0, 0)
    labelText.BackgroundTransparency = 1
    labelText.TextColor3 = Color3.fromRGB(220, 220, 220)
    labelText.Font = Enum.Font.GothamMedium
    labelText.TextSize = 12
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = container
    
    local toggleButton = Instance.new("Frame")
    toggleButton.Size = UDim2.new(0, 34, 0, 18)
    toggleButton.Position = UDim2.new(1, -44, 0.5, -9)
    toggleButton.BackgroundColor3 = defaultState and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(45, 45, 45)
    toggleButton.Parent = container
    Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(0, 9)
    
    local isEnabled = defaultState
    container.MouseButton1Click:Connect(function()
        isEnabled = not isEnabled
        toggleButton.BackgroundColor3 = isEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(45, 45, 45)
        callback(isEnabled)
    end)
end

-- Deploy Settings Components
createSlider("Trigger Target Radius", 15, 60, 30, function(value) ActivationDistance = value end)
createToggle("Automatic Core Override", false, function(state) AutoParryEnabled = state end)

-- Initial System Hooks
for _, ball in pairs(Balls:GetChildren()) do HookBallVelocityEvents(ball) end
Balls.ChildAdded:Connect(HookBallVelocityEvents)