-- 1. I-LOAD ANG UI LIBRARY
local Kavo = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Kavo.CreateLib("Blade Ball Client", "Midnight")

-- 2. GUMAWA NG TAB AT SECTION
local MainTab = Window:NewTab("Main")
local MainSection = MainTab:NewSection("Automation")

-- 3. MGA VARIABLE
local AutoParryEnabled = false

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local ParryRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("kebaind")

-- FUNCTION PARA HANAPIN ANG BOLA (May filter para sa MeshPart na nakita sa scanner)
local function getBall()
    for _, object in ipairs(Workspace:GetChildren()) do
        -- Nilaktawan natin ang Terrain at FakeSky na nakita sa scan natin kanina
        if object:IsA("BasePart") and object.Name ~= "Terrain" and object.Name ~= "FakeSky" then
            -- Kung ang pangalan ay Ball, MeshPart, o simpleng Part, ituturing nating bola
            if object.Name == "Ball" or object.Name == "MeshPart" or object.Name == "Part" then
                return object
            end
        end
    end
    return nil
end

-- FUNCTION PARA I-CHECK KUNG IKAW ANG TARGET NG BOLA
local function isBallTargetingMe(ball)
    if ball:GetAttribute("target") == LocalPlayer.Name or ball:GetAttribute("Target") == LocalPlayer.Name then
        return true
    end
    
    local targetVal = ball:FindFirstChild("target") or ball:FindFirstChild("Target")
    if targetVal and targetVal.Value == LocalPlayer.Character then
        return true
    end
    
    return false
end

-- 4. THE MAIN LOOP
task.spawn(function()
    while task.wait() do
        if AutoParryEnabled then
            local ball = getBall()
            local character = LocalPlayer.Character
            
            if ball and character and character:FindFirstChild("HumanoidRootPart") then
                if isBallTargetingMe(ball) then
                    local playerPos = character.HumanoidRootPart.Position
                    local ballPos = ball.Position
                    local distance = (playerPos - ballPos).Magnitude
                    
                    local ActivationDistance = 20 -- Distansya ng palo (Pwede mong taasan kung late pumalo)
                    
                    if distance <= ActivationDistance then
                        ParryRemote:FireServer()
                        task.wait(0.1) -- Anti-spam cooldown
                    end
                end
            end
        end
    end
end)

-- 5. TOGGLE BUTTON
MainSection:NewToggle("Auto Parry", "Papalo lang kapag ikaw ang target at malapit ang bola", function(state)
    AutoParryEnabled = state
end)
