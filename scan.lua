-- Simple Screen Notification Scanner
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

-- Function para mag-pop up ang text sa screen mo mismo
local function notify(title, text)
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = 5
    })
end

notify("Scanner Active", "Naghahanap ng bola...")
task.wait(1)

-- I-print ang pangalan ng player
notify("Player Name", Players.LocalPlayer.Name)

-- Hanapin ang bola sa workspace
local foundCount = 0
for _, v in ipairs(Workspace:GetChildren()) do
    if v:IsA("BasePart") or v.Name:lower():match("ball") then
        foundCount = foundCount + 1
        notify("FOUND BOLA!", "Name: " .. v.Name .. " (" .. v.ClassName .. ")")
    end
end

if foundCount == 0 then
    notify("Scanner Result", "Walang nahanap na bola sa Workspace. Siguraduhing nasa laban ka!")
end
