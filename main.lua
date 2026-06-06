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

-- MGA GLOBAL SETTINGS (Konektado sa UI)
local AutoParryEnabled = false
local ActivationDistance = 30 -- Ito ang babaguhin ng Slider

-- I-DELETE ANG LUMANG GUI KUNG MERON MAN PARA WALANG PATONG-PATONG
if PlayerGui:FindFirstChild("AutoParryGui") then
    PlayerGui.AutoParryGui:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoParryGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 330, 0, 380)
mainFrame.Position = UDim2.new(0.5, -165, 0.4, -190) -- Gitna ng screen para sa Mobile
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true -- Pwede mong itulak-tulak sa screen ng CP
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 50)
titleBar.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = titleBar

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Text = "⚡ BLADE BALL: GOD PARRY PRO"
title.Size = UDim2.new(1, 0, 1, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.Parent = titleBar

-- Scroll frame
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "ScrollFrame"
scrollFrame.Size = UDim2.new(1, -20, 1, -120)
scrollFrame.Position = UDim2.new(0, 10, 0, 60)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 4
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 300)
scrollFrame.Parent = mainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.Parent = scrollFrame

-- FIX #1: MOBILE-FRIENDLY SLIDER FUNCTION
local function createSlider(label, minVal, maxVal, defaultVal, callback)
    local container = Instance.new("Frame")
    container.Name = label
    container.Size = UDim2.new(1, 0, 0, 70)
    container.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    container.BorderSizePixel = 0
    container.Parent = scrollFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = container
    
    local labelText = Instance.new("TextLabel")
    labelText.Text = label
    labelText.Size = UDim2.new(1, -10, 0, 20)
    labelText.Position = UDim2.new(0, 5, 0, 5)
    labelText.BackgroundTransparency = 1
    labelText.TextColor3 = Color3.new(1, 1, 1)
    labelText.TextSize = 12
    labelText.Font = Enum.Font.GothamBold
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = container
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Text = tostring(defaultVal)
    valueLabel.Size = UDim2.new(0, 40, 0, 20)
    valueLabel.Position = UDim2.new(1, -45, 0, 5)
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
    valueLabel.TextSize = 12
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.Parent = container
    
    local sliderButton = Instance.new("TextButton")
    sliderButton.Name = "SliderButton"
    sliderButton.Size = UDim2.new(1, -10, 0, 10)
    sliderButton.Position = UDim2.new(0, 5, 0, 35)
    sliderButton.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    sliderButton.Text = ""
    sliderButton.BorderSizePixel = 0
    sliderButton.Parent = container
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 4)
    sliderCorner.Parent = sliderButton
    
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    fill.BorderSizePixel = 0
    fill.Parent = sliderButton
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 4)
    fillCorner.Parent = fill
    
    local dragging = false
    
    local function updateSlider(input)
        local percentage = math.clamp((input.Position.X - sliderButton.AbsolutePosition.X) / sliderButton.AbsoluteSize.X, 0, 1)
        local value = math.floor(minVal + (maxVal - minVal) * percentage)
        fill.Size = UDim2.new(percentage, 0, 1, 0)
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
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- FIX #2: TEXTBUTTON PARA GUMANA ANG CLICK SA TOGGLE
local function createToggle(label, defaultState, callback)
    local container = Instance.new("TextButton")
    container.Name = label
    container.Size = UDim2.new(1, 0, 0, 45)
    container.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    container.BorderSizePixel = 0
    container.Text = ""
    container.Parent = scrollFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = container
    
    local labelText = Instance.new("TextLabel")
    labelText.Text = label
    labelText.Size = UDim2.new(1, -60, 1, 0)
    labelText.Position = UDim2.new(0, 10, 0, 0)
    labelText.BackgroundTransparency = 1
    labelText.TextColor3 = Color3.new(1, 1, 1)
    labelText.TextSize = 13
    labelText.Font = Enum.Font.Gotham
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = container
    
    local toggleButton = Instance.new("Frame")
    toggleButton.Name = "ToggleButton"
    toggleButton.Size = UDim2.new(0, 40, 0, 22)
    toggleButton.Position = UDim2.new(1, -50, 0.5, -11)
    toggleButton.BackgroundColor3 = defaultState and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(100, 100, 120)
    toggleButton.BorderSizePixel = 0
    toggleButton.Parent = container
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 11)
    toggleCorner.Parent = toggleButton
    
    local toggleCircle = Instance.new("Frame")
    toggleCircle.Name = "Circle"
    toggleCircle.Size = UDim2.new(0, 16, 0, 16)
    toggleCircle.Position = defaultState and UDim2.new(0, 22, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    toggleCircle.BackgroundColor3 = Color3.new(1, 1, 1)
    toggleCircle.BorderSizePixel = 0
    toggleCircle.Parent = toggleButton
    
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(0, 8)
    circleCorner.Parent = toggleCircle
    
    local isEnabled = defaultState
    
    container.MouseButton1Click:Connect(function()
        isEnabled = not isEnabled
        toggleButton.BackgroundColor3 = isEnabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(100, 100, 120)
        
        local tween = TweenService:Create(
            toggleCircle,
            TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Position = isEnabled and UDim2.new(0, 22, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}
        )
        tween:Play()
        
        callback(isEnabled)
    end)
end

-- Stats Label sa ilalim
local statsLabel = Instance.new("TextLabel")
statsLabel.Name = "Stats"
statsLabel.Text = "Status: Monitoring Match..."
statsLabel.Size = UDim2.new(1, -20, 0, 35)
statsLabel.Position = UDim2.new(0, 10, 1, -45)
statsLabel.BackgroundColor3 = Color3.fromRGB(0, 120, 220)
statsLabel.TextColor3 = Color3.new(1, 1, 1)
statsLabel.TextSize = 12
statsLabel.Font = Enum.Font.GothamBold
statsLabel.BorderSizePixel = 0
statsLabel.Parent = mainFrame

local statsCorner = Instance.new("UICorner")
statsCorner.CornerRadius = UDim.new(0, 6)
statsCorner.Parent = statsLabel


-- =========================================================
-- BUILD THE UI ELEMENTS
-- =========================================================

-- 1. Slider para sa Custom Activation Distance
createSlider("Parry Distance (Studs)", 15, 60, 30, function(value)
    ActivationDistance = value
end)

-- 2. Main Auto Parry Toggle
createToggle("God Auto Parry", false, function(state)
    AutoParryEnabled = state
    statsLabel.Text = state and "Status: ACTIVE (God Mode)" or "Status: Deactivated"
end)


-- =========================================================
-- THE ULTIMATE PARRY ENGINE LOGIC
-- =========================================================

local function IsTarget()
    return (Player.Character and Player.Character:FindFirstChild("Highlight"))
end

local function Parry()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
    RunService.Heartbeat:Wait()
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
end

local function MonitorBall(Ball)
    if Ball:GetAttribute("realBall") ~= true then return end
    
    local lastPosition = Ball.Position
    local lastUpdateTime = tick()
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not Ball.Parent or not screenGui.Parent then
            connection:Disconnect()
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
                
                -- DYNAMIC FORMULA: Slider distance base + speed modifier + automatic latency offset
                local dynamicDistance = ActivationDistance + (ballSpeed * 0.11)
                
                -- Siguraduhing pasugod ang bola sa player, hindi papalayo
                local dotProduct = realVelocity.Unit:Dot((myPos - ballPos).Unit)
                
                if distance <= dynamicDistance and dotProduct > 0 then
                    Parry()
                    statsLabel.Text = "Last Parry Speed: " .. math.floor(ballSpeed)
                    task.wait(0.12) -- Prevent click registration overload
                end
            end
        end
        
        lastPosition = Ball.Position
        lastUpdateTime = tick()
    end)
end

-- Hook sa folder tracking ng tropa mo
table.foreach(Balls:GetChildren(), function(_, ball) MonitorBall(ball) end)
Balls.ChildAdded:Connect(MonitorBall)

print("[+] Custom Pro GUI Loaded and Synced!")