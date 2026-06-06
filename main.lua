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
local HasManualParried = false -- Hard Anti-Cheat Lock
local ManualSpamEnabled = false
local IsSpamming = false

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
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 280)
scrollFrame.Parent = mainFrame

Instance.new("UIListLayout", scrollFrame).Padding = UDim.new(0, 10)

-- Minimize / Maximize Logic
local isMinimized = false
minButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    local targetSize = isMinimized and UDim2.new(0, 320, 0, 50) or UDim2.new(0, 320, 0, 360)
    minButton.Text = isMinimized and "+" or "—"
    TweenService:Create(mainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = targetSize}):Play()
end)

-- Stats / Security Alert Label
local statsLabel = Instance.new("TextLabel")
statsLabel.Size = UDim2.new(1, -24, 0, 35)
statsLabel.Position = UDim2.new(0, 12, 1, -48)
statsLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
statsLabel.Text = "SECURITY: Hard-locked. Awaiting manual input."
statsLabel.TextColor3 = Color3.fromRGB(160, 40, 40)
statsLabel.Font = Enum.Font.GothamMedium
statsLabel.TextSize = 11
statsLabel.BorderSizePixel = 0
statsLabel.Parent = mainFrame

Instance.new("UICorner", statsLabel).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", statsLabel).Color = Color3.fromRGB(50, 30, 30)

-- NOTIFICATION UI
local function showNotification(message)
    local notifFrame = Instance.new("Frame")
    notifFrame.Size = UDim2.new(0, 260, 0, 45)
    notifFrame.Position = UDim2.new(0.5, -130, 0, -60)
    notifFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    notifFrame.Parent = screenGui
    
    Instance.new("UICorner", notifFrame).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", notifFrame)
    stroke.Thickness = 1
    stroke.Color = Color3.fromRGB(180, 50, 50)
    
    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(1, -20, 1, 0)
    txt.Position = UDim2.new(0, 10, 0, 0)
    txt.BackgroundTransparency = 1
    txt.Text = message
    txt.TextColor3 = Color3.fromRGB(255, 255, 255)
    txt.Font = Enum.Font.GothamBold
    txt.TextSize = 11
    txt.Parent = notifFrame
    
    notifFrame:TweenPosition(UDim2.new(0.5, -130, 0, 15), "Out", "Quad", 0.3, true)
    task.delay(3, function()
        if notifFrame and notifFrame.Parent then
            notifFrame:TweenPosition(UDim2.new(0.5, -130, 0, -60), "In", "Quad", 0.3, true, function()
                notifFrame:Destroy()
            end)
        end
    end)
end

-- CREATING FLOATING MANUAL SPAM BUTTON
local spamFloatButton = Instance.new("TextButton")
spamFloatButton.Name = "SpamFloatButton"
spamFloatButton.Size = UDim2.new(0, 70, 0, 70)
spamFloatButton.Position = UDim2.new(0.8, 0, 0.5, -35)
spamFloatButton.BackgroundColor3 = Color3.fromRGB(230, 30, 30) -- Striking Crimson Red
spamFloatButton.Text = "SPAM"
spamFloatButton.TextColor3 = Color3.fromRGB(255, 255, 255)
spamFloatButton.Font = Enum.Font.GothamBold
spamFloatButton.TextSize = 14
spamFloatButton.Active = true
spamFloatButton.Draggable = true -- Pwedeng galawin kahit saan sa screen
spamFloatButton.Visible = false
spamFloatButton.Parent = screenGui

local floatCorner = Instance.new("UICorner")
floatCorner.CornerRadius = UDim.new(1, 0) -- Perfect Circle Shape
floatCorner.Parent = spamFloatButton

local floatStroke = Instance.new("UIStroke")
floatStroke.Thickness = 3
floatStroke.Color = Color3.fromRGB(255, 255, 255)
floatStroke.Parent = spamFloatButton

-- SPAM MECHANISM DETECTOR
local function executeSpamLoop()
    task.spawn(function()
        while IsSpamming and ManualSpamEnabled and HasManualParried do
            pcall(function()
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                -- Super bilis na tick rate ngunit ligtas pa rin mula sa frame logs analysis (0.010 - 0.022s)
                task.wait(math.random(10, 22) / 1000) 
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
            end)
            task.wait(0.01)
        end
    end)
end

-- Mouse/Touch Press Down (Pagsisimula ng spam)
spamFloatButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        IsSpamming = true
        spamFloatButton.BackgroundColor3 = Color3.fromRGB(150, 10, 10) -- Magdidilim kapag pinipindot
        executeSpamLoop()
    end
end)

-- Mouse/Touch Release (Paghinto ng spam)
spamFloatButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        IsSpamming = false
        spamFloatButton.BackgroundColor3 = Color3.fromRGB(230, 30, 30)
    end
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

-- MINIMALIST TOGGLE FUNCTION
local function createToggle(label, defaultState, isSpamToggle, callback)
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
        -- KUNG HINDI PA NAG-P-PARRY ANG USER, LOCKOUT SYSTEM!
        if not HasManualParried then
            showNotification("Parry Manually First To Activate")
            return
        end
        
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

-- BUILD UI ELEMENTS
createSlider("Parry Distance (Studs)", 15, 60, 30, function(value) ActivationDistance = value end)

createToggle("God Auto Parry", false, false, function(state)
    AutoParryEnabled = state
    statsLabel.Text = state and "Status: ACTIVE (God Mode)" or "Status: Monitoring..."
end)

createToggle("Manual Spam Button", false, true, function(state)
    ManualSpamEnabled = state
    spamFloatButton.Visible = state
    if not state then IsSpamming = false end -- Force reset if disabled
end)

-- =========================================================
-- SECURED LOCK MECHANISM (ANTI-CHEAT TRIGGER GATE)
-- =========================================================

local function unlockEngine()
    if not HasManualParried then
        HasManualParried = true
        statsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        statsLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        statsLabel.Text = "Status: Bypass Clean! Engine Unlocked."
        statsLabel.Parent.UIStroke.Color = Color3.fromRGB(45, 45, 45)
        
        -- Kung naka-on na agad ang switch settings bago ang unlock, i-update ang float button visibility dito
        if ManualSpamEnabled then
            spamFloatButton.Visible = true
        end
    end
end

UserInputService.InputBegan:Connect(function(input, processed)
    if input.KeyCode == Enum.KeyCode.F or input.UserInputType == Enum.UserInputType.Touch then
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            unlockEngine()
        end
    end
end)

local function IsTarget()
    return (Player.Character and Player.Character:FindFirstChild("Highlight"))
end

local function Parry()
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
        task.wait(math.random(15, 35) / 1000) 
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
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
            return
        end
        
        -- HARD SECURITY LOCKOUT
        if not HasManualParried then 
            return 
        end
        
        if AutoParryEnabled and IsTarget() and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
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
                    task.wait(0.15)
                end
            end
        end
        
        lastPosition = Ball.Position
        lastUpdateTime = tick()
    end)
end

table.foreach(Balls:GetChildren(), function(_, ball) MonitorBall(ball) end)
Balls.ChildAdded:Connect(MonitorBall)