-- 1. I-LOAD ANG UI LIBRARY
local Kavo = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Kavo.CreateLib("Blade Ball Client", "Midnight")

-- 2. GUMAWA NG TAB AT SECTION
local MainTab = Window:NewTab("Main")
local MainSection = MainTab:NewSection("Automation")

-- 3. MGA VARIABLE MULA SA TRAPA MO + GUI TOGGLE
local AutoParryEnabled = false -- Kontrolado ng Toggle sa GUI

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")

local Player = Players.LocalPlayer
local Balls = workspace:WaitForChild("Balls")

-- Function ng tropa mo para sa Target Check gamit ang Highlight
local function IsTarget()
    return (Player.Character and Player.Character:FindFirstChild("Highlight"))
end

-- Function ng tropa mo para sa pagpindot ng 'F'
local function Parry()
    VirtualInputManager:SendKeyEvent(true, "F", false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, "F", false, game)
end

-- 4. ANG EVENT LISTENER NG BOLA (Gagana lang kapag NAKA-ON ang toggle)
Balls.ChildAdded:Connect(function(Ball)
    if Ball:GetAttribute("realBall") ~= true then return end
    
    print("[+] Ball spawned, monitoring...")
    
    Ball:GetPropertyChangedSignal("Position"):Connect(function()
        -- Dagdag na kondisyon: Dapat true rin ang AutoParryEnabled mula sa GUI
        if AutoParryEnabled and IsTarget() and Ball.Parent then
            local Distance = (Ball.Position - workspace.CurrentCamera.Focus.Position).Magnitude
            
            -- Pwede mong baguhin itong 30 depende sa bilis ng bola
            if Distance < 30 then
                Parry()
                print("[-] PARRIED! Distance:", Distance)
                task.wait(0.1) -- Kaunting cooldown para maiwasan ang double-parry bug
            end
        end
    end)
end)

-- 5. TOGGLE BUTTON SA GUI
MainSection:NewToggle("Auto Parry", "Gagamit ng Virtual Input at Highlight Tracker", function(state)
    AutoParryEnabled = state
    if state then
        print("[+] Auto Parry: NAKA-ON")
    else
        print("[-] Auto Parry: NAKA-OFF")
    end
end)
