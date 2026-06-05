-- 1. I-LOAD ANG UI LIBRARY (Kavo Library)
local Kavo = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Kavo.CreateLib("Blade Ball Client", "Midnight") -- Pangalan ng GUI at Tema (Midnight)

-- 2. GUMAWA NG TAB AT SECTION
local MainTab = Window:NewTab("Main")
local MainSection = MainTab:NewSection("Automation")

-- 3. MGA VARIABLE PARA SA PARRY LOGIC
local AutoParryEnabled = false -- Dito itatago kung NAKA-ON o NAKA-OFF ang parry

-- Mga Roblox Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local ParryRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("kebaind")

-- Function para hanapin ang bola
local function getBall()
    for _, object in ipairs(Workspace:GetChildren()) do
        if object.Name == "Ball" or object:FindFirstChild("Ball") then
            return object
        end
    end
    return nil
end

-- 4. ANG MAIN LOOP (Tatakbo sa background pero gagana lang kung true ang AutoParryEnabled)
task.spawn(function()
    while task.wait() do
        -- Papasok lang sa logic kung NAKA-ON ang toggle sa GUI
        if AutoParryEnabled then
            local ball = getBall()
            local character = LocalPlayer.Character
            
            if ball and character and character:FindFirstChild("HumanoidRootPart") then
                local playerPos = character.HumanoidRootPart.Position
                local ballPos = ball.Position
                local distance = (playerPos - ballPos).Magnitude
                
                local ActivationDistance = 20 -- Distansya ng palo
                
                if distance <= ActivationDistance then
                    ParryRemote:FireServer()
                    task.wait(0.1) -- Anti-spam cooldown
                end
            end
        end
    end
end)

-- 5. GUMAWA NG TOGGLE SA GUI
MainSection:NewToggle("Auto Parry", "Awtomatikong papalo kapag malapit ang bola", function(state)
    AutoParryEnabled = state -- Kapag pinindot, nagiging true o false ito
    if state then
        print("[+] Auto Parry: NAKA-ON")
    else
        print("[-] Auto Parry: NAKA-OFF")
    end
end)
