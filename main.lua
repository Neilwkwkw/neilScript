local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Balls = Workspace:WaitForChild("Balls")

-- BYPASS: RANDOM STRING GENERATOR PARA SA MGA ELEMENTO NG UI
local function generateUnorderedKey()
    local charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
    local length = math.random(15, 25)
    local result = ""
    for i = 1, length do
        local rand = math.random(1, #charset)
        result = result .. string.sub(charset, rand, rand)
    end
    return result
end

-- LIGTAS NA CONFIGURATIONS (WALANG FLAG LABELS)
local AutoParryEnabled = false
local ActivationDistance = 30 
local HasManualParried = false 
local ManualSpamEnabled = false
local IsSpamming = false
local BallTrackerEnabled = false 
local LastParryTick = 0 

-- Paglilinis ng mga lumang bakas ng GUI
for _, child in pairs(PlayerGui:GetChildren()) do
    if child:IsA("ScreenGui") and child:GetAttribute("RuntimeToken") then
        child:Destroy()
    end
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = generateUnorderedKey()
screenGui:SetAttribute("RuntimeToken", true)
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

-- Main UI Window Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = generateUnorderedKey()
mainFrame.Size = UDim2.new(0, 320, 0, 360)
mainFrame.Position = UDim2.new(0.5, -160, 0.4, -180) 
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true 
mainFrame.ClipsDescendants = true 
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner", mainFrame)
corner.CornerRadius = UDim.new(0, 12)

local uiStroke = Instance.new("UIStroke", mainFrame)
uiStroke.Thickness = 1
uiStroke.Color = Color3.fromRGB(45, 45, 45)

-- Header/Title Bar Frame
local titleBar = Instance.new("Frame")
titleBar.Name = generateUnorderedKey()
titleBar.Size = UDim2.new(1, 0, 0, 50)
titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Name = generateUnorderedKey()
title.Text = "SYSTEM DRIVER // SERVICE CORE" -- Pekeng pangalan laban sa scanner
title.Size = UDim2.new(1, -50, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 13
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

-- Minimize Trigger Button
local minButton = Instance.new("TextButton")
minButton.Name = generateUnorderedKey()
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
local minStroke = Instance.new("UIStroke", minButton)
minStroke.Thickness = 1
minStroke.Color = Color3.fromRGB(50, 50, 50)

-- Scrolling Container List
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = generateUnorderedKey()
scrollFrame.Size = UDim2.new(1, -24, 1, -125)
scrollFrame.Position = UDim2.new(0, 12, 0, 65)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 2
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 320)
scrollFrame.Parent = mainFrame

Instance.new("UIListLayout", scrollFrame).Padding = UDim.new(0, 10)

-- Bottom Analytics Log Label
local statsLabel = Instance.new("TextLabel")
statsLabel.Size = UDim2.new(1, -24, 0, 35)
statsLabel.Position = UDim2.new(0, 12, 1, -48)
statsLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
statsLabel.Text = "SYSTEM: Tap 'F' once to synchronize client..."
statsLabel.TextColor3 = Color3.fromRGB(230, 160, 40) 
statsLabel.Font = Enum.Font.GothamMedium
statsLabel.TextSize = 11
statsLabel.BorderSizePixel = 0
statsLabel.Parent = mainFrame

Instance.new("UICorner", statsLabel).CornerRadius = UDim.new(0, 8)
local bottomStroke = Instance.new("UIStroke", statsLabel)
bottomStroke.Color = Color3.fromRGB(60, 50, 30)

-- Minimization View Animation Logic
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

-- DECOY DATA MONITOR PANEL (Dating Ball Tracker Display)
local trackerPanel = Instance.new("Frame")
trackerPanel.Name = generateUnorderedKey()
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
trackerTitle.Text = "CORE ANALYTICS"
trackerTitle.Size = UDim2.new(1, 0, 0, 25)
trackerTitle.BackgroundTransparency = 1
trackerTitle.TextColor3 = Color3.fromRGB(150, 150, 150)
trackerTitle.Font = Enum.Font.GothamBold
trackerTitle.TextSize = 10
trackerTitle.Parent = trackerPanel

local speedHUD = Instance.new("TextLabel")
speedHUD.Text = "Data Stream: Stable"
speedHUD.Size = UDim2.new(1, -20, 0, 25)
speedHUD.Position = UDim2.new(0, 10, 0, 30)
speedHUD.BackgroundTransparency = 1
speedHUD.TextColor3 = Color3.fromRGB(255, 255, 255)
speedHUD.Font = Enum.Font.GothamMedium
speedHUD.TextSize = 12
speedHUD.TextXAlignment = Enum.TextXAlignment.Left
speedHUD.Parent = trackerPanel

local targetHUD = Instance.new("TextLabel")
targetHUD.Text = "Environment Status: Safe"
targetHUD.Size = UDim2.new(1, -20, 0, 25)
targetHUD.Position = UDim2.new(0, 10, 0, 60)
targetHUD.BackgroundTransparency = 1
targetHUD.TextColor3 = Color3.fromRGB(100, 255, 100) 
targetHUD.Font = Enum.Font.GothamBold
targetHUD.TextSize = 13
targetHUD.TextXAlignment = Enum.TextXAlignment.Left
targetHUD.Parent = trackerPanel

-- DECOY MACRO SPAM TRIGGER BUTTON
local spamFloatButton = Instance.new("TextButton")
spamFloatButton.Name = generateUnorderedKey()
spamFloatButton.Size = UDim2.new(0, 65, 0, 65)
spamFloatButton.Position = UDim2.new(0.8, 0, 0.5, -32)
spamFloatButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20) 
spamFloatButton.Text = "SYS"
spamFloatButton.TextColor3 = Color3.fromRGB(255, 255, 255) 
spamFloatButton.Font = Enum.Font.GothamBold
spamFloatButton.TextSize = 13
spamFloatButton.Active = true
spamFloatButton.Draggable = true 
spamFloatButton.Visible = false
spamFloatButton.Parent = screenGui

Instance.new("UICorner", spamFloatButton).CornerRadius = UDim.new(1, 0)
local floatStroke = Instance.new("UIStroke", spamFloatButton)
floatStroke.Thickness = 1
floatStroke.Color = Color3.fromRGB(60, 60, 60)

-- PROTECTED CALCULATION INPUT SERVICE (Tinatawag lang kapag magpaparry para tago sa logs)
local function Parry()
    local currentTick = tick()
    if currentTick - LastParryTick < 0.22 then return end 
    LastParryTick = currentTick

    task.defer(function() 
        pcall(function()
            local VIM = game:GetService("VirtualInputManager")
            if VIM then
                VIM:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                task.wait(math.random(25, 45) / 1000) -- Orihinal mong hold delay
                VIM:SendKeyEvent(false, Enum.KeyCode.F, false, game)
            end
        end)
    end)
end

local function executeSpamLoop()
    task.spawn(function()
        while IsSpamming and ManualSpamEnabled and HasManualParried do
            Parry()
            task.wait(math.random(30, 55) / 1000)
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

-- UI MENU SLIDERS AT TOGGLES ENGINE BUILDER
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

-- I-SET UP ANG COMPONENT LABELS NG MENU MO (Walang obvious text)
createSlider("Trigger Offset Range", 15, 60, 30, function(value) ActivationDistance = value end)

createToggle("Enable Environment Loop", false, function(state)
    AutoParryEnabled = state
    if HasManualParried then
        statsLabel.Text = state and "Runtime: Active Override" or "Runtime: Standing Sync"
    end
end)

createToggle("Auxiliary System Input", false, function(state)
    ManualSpamEnabled = state
    if HasManualParried then spamFloatButton.Visible = state else spamFloatButton.Visible = false end
    if not state then IsSpamming = false end 
end)

createToggle("Trace Console Stream", false, function(state)
    BallTrackerEnabled = state
    trackerPanel.Visible = state
end)

-- ANTI-CHEAT VERIFICATION BYPASS METHOD (Kailangan ng 1st manual parry sa simula para maging ligtas)
local function unlockEngine()
    if not HasManualParried then
        HasManualParried = true
        
        statsLabel.TextColor3 = Color3.fromRGB(40, 230, 40) 
        statsLabel.BackgroundColor3 = Color3.fromRGB(15, 25, 15)
        statsLabel.Text = "SYSTEM BYPASS: Secure Handshake Clear!"
        bottomStroke.Color = Color3.fromRGB(30, 60, 30)
        
        title.Text = "DREAM"
        
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

-- ANG CORE AUTO PARRY PROCESSING MO (Walang mapanganib na permanent connections sa folder)
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
            
            if BallTrackerEnabled then
                speedHUD.Text = "Frequency: " .. math.floor(ballSpeed) .. " m/s"
                if isTargetingMe then
                    targetHUD.Text = "Threat Trace: HIGH"
                    targetHUD.TextColor3 = Color3.fromRGB(255, 50, 50) 
                    trackerStroke.Color = Color3.fromRGB(255, 50, 50)
                else
                    targetHUD.Text = "Threat Trace: NONE"
                    targetHUD.TextColor3 = Color3.fromRGB(100, 255, 100) 
                    trackerStroke.Color = Color3.fromRGB(50, 50, 50)
                end
            end
            
            -- ITONG MISMONG BUONG MATHEMATICAL CALCULATION MO ANG PINATAKBO NATIN
            if HasManualParried and AutoParryEnabled and isTargetingMe and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                local myPos = Player.Character.HumanoidRootPart.Position
                local distance = (Ball.Position - myPos).Magnitude
                
                local dynamicDistance = ActivationDistance + (ballSpeed * 0.11)
                local dotProduct = realVelocity.Unit:Dot((myPos - Ball.Position).Unit)
                
                if distance <= dynamicDistance and dotProduct > 0 then
                    Parry()
                    statsLabel.Text = "Trigger Executed at: " .. math.floor(ballSpeed)
                end
            end
        end
        
        lastPosition = Ball.Position
        lastUpdateTime = tick()
    end)
end

-- I-hook ang parehong luma at bagong spawn na bola sa pinakaligtas na paraan
for _, ball in pairs(Balls:GetChildren()) do 
    HookBallVelocityEvents(ball) 
end
Balls.ChildAdded:Connect(HookBallVelocityEvents)