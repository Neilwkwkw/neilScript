local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
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
local HasManualParried = false -- Gagamitin para sa anti-cheat check bypass

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
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15) -- Pure Dark
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true 
mainFrame.ClipsDescendants = true 
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Minimalist White Stroke Border
local uiStroke = Instance.new("UIStroke")
uiStroke.Thickness = 1
uiStroke.Color = Color3.fromRGB(45, 45, 45)
uiStroke.Parent = mainFrame

-- Title Bar (Clean Black/White)
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

-- Minimize Button (Clean Modern Minus Symbol)
local minButton = Instance.new("TextButton")
minButton.Name = "MinButton"
minButton.Text = "—"
minButton.Size = UDim2.new(0, 26, 0, 26)
minButton.Position = UDim2.new(1, -38, 0.5, -13)
minButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
minButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minButton.TextSize = 12
minButton.Font = Enum.Font.GothamBold
minButton.Parent = titleBar

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 6)
minCorner.Parent = minButton

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
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 280)
scrollFrame.Parent = mainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.Parent = scrollFrame

-- Minimize / Maximize Logic
local isMinimized = false
minButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    local targetSize = isMinimized and UDim2.new(0, 320, 0, 50) or UDim2.new(0, 320, 0, 360)
    minButton.Text = isMinimized and "+" or "—"
    TweenService:Create(mainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = targetSize}):Play()
end)

-- MINIMALIST SLIDER FUNCTION
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
    fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- Pure White Bar
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

-- MINIMALIST TOGGLE FUNCTION
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

-- Stats Label (Clean Status Section at the bottom)
local statsLabel = Instance.new("TextLabel")
statsLabel.Size = UDim2.new(1, -24, 0, 35)
statsLabel.Position = UDim2.new(0, 12, 1, -48)
statsLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
statsLabel.Text = "ANTI-CHEAT: Manual parry once to initialize."
statsLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
statsLabel.Font = Enum.Font.GothamMedium
statsLabel.TextSize = 11
statsLabel.BorderSizePixel = 0
statsFrame = mainFrame
statsLabel.Parent = mainFrame

local statsCorner = Instance.new("UICorner")
statsCorner.CornerRadius = UDim.new(0, 8)
statsCorner.Parent = statsLabel

Instance.new("UIStroke", statsLabel).Color = Color3.fromRGB(40, 40, 40)


-- =========================================================
-- BUILD MINIMALIST UI ELEMENTS
-- =========================================================
createSlider("Parry Distance (Studs)", 15, 60, 30, function(value)
    ActivationDistance = value
end)

createToggle("God Auto Parry", false, function(state)
    AutoParryEnabled = state
    if HasManualParried then
        statsLabel.Text = state and "Status: ACTIVE (God Mode)" or "Status: Monitoring..."
    end
end)


-- =========================================================
-- ADVANCED ANTI-CHEAT BYPASS SYSTEM
-- =========================================================

-- Bypass Part 1: Register User's First Manual Key Tap (Anti-Cheat Bypass Trigger)
UserInputService.InputBegan:Connect(function(input, processed)
    if not HasManualParried and input.KeyCode == Enum.KeyCode.F then
        HasManualParried = true
        statsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        statsLabel.Text = "Status: Bypass Clean! Engine Unlocked."
        print("[+] Manual input registered. Safe execution fully initialized!")
    end
end)

local function IsTarget()
    return (Player.Character and Player.Character:FindFirstChild("Highlight"))
end

local function Parry()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
    RunService.Heartbeat:Wait()
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
end

local function MonitorBall(Ball)
    -- Anti-Cheat Protection 1: Safe Filtering (Dapat Part object at may valid realBall token)
    -- Blino-block nito ang Terrain, MeshParts, at Sky fakes para hindi kayo ma-spam detect sa logs!
    if not Ball:IsA("BasePart") or Ball:GetAttribute("realBall") ~= true then return end
    
    local lastPosition = Ball.Position
    local lastUpdateTime = tick()
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not Ball.Parent or not screenGui.Parent then
            connection:Disconnect()
            return
        end
        
        -- Anti-Cheat Protection 2: System Validation Check
        -- Hinding hindi papalo ang auto-bot hangga't walang unang manual parry data ang Roblox client para iwas instant flag.
        if AutoParryEnabled and HasManualParried and IsTarget() and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            local myPos = Player.Character.HumanoidRootPart.Position
            local ballPos = Ball.Position
            
            local currentTime = tick()
            local deltaTime = currentTime - lastUpdateTime
            
            if deltaTime > 0 then
                local realVelocity = (ballPos - lastPosition) / deltaTime
                local ballSpeed = realVelocity.Magnitude
                local distance = (ballPos - myPos).Magnitude
                
                local dynamicDistance = ActivationDistance + (ballSpeed * 0.11)
                local dotProduct = realVelocity.Unit:Dot((myPos - ballPos).Unit)
                
                if distance <= dynamicDistance and dotProduct > 0 then
                    Parry()
                    statsLabel.Text = "Last Parry Speed: " .. math.floor(ballSpeed)
                    task.wait(0.12)
                end
            end
        end
        
        lastPosition = Ball.Position
        lastUpdateTime = tick()
    end)
end

table.foreach(Balls:GetChildren(), function(_, ball) MonitorBall(ball) end)
Balls.ChildAdded:Connect(MonitorBall)

print("[+] Clean Minimalist Pro Engine Loaded & Protected!")