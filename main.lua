local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Blatant",
    SubTitle = "Blade Ball Manager",
    TabWidth = 160,
    Size = UDim2.fromOffset(600, 450),
    Acrylic = true,
    Theme = "Dark"
})

-- Tabs
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "swords" })
}

-- BLATANT SECTION
local BlatantSection = Tabs.Main:AddSection("Blatant")

BlatantSection:AddToggle("AutoParry", {Title = "Auto Parry", Default = false })
BlatantSection:AddSlider("ParryAccuracy", {Title = "Parry Accuracy", Default = 32, Min = 0, Max = 100})
BlatantSection:AddDropdown("AutoCurve", {Title = "Auto Curve Direction", Values = {"Random", "Left", "Right"}, Multi = false, Default = 1})
BlatantSection:AddToggle("CooldownProtection", {Title = "Cooldown Protection", Default = true })

-- LOBBY AUTO PARRY SECTION
local LobbySection = Tabs.Main:AddSection("Lobby Auto Parry")
LobbySection:AddToggle("LobbyAutoParry", {Title = "Lobby Auto Parry", Default = false })
LobbySection:AddSlider("LobbyParryAccuracy", {Title = "Lobby Parry Accuracy", Default = 40, Min = 0, Max = 100})
LobbySection:AddToggle("LobbyRandom", {Title = "Lobby Random Accuracy", Default = false })

-- MANUEL SPAM SECTION
local ManualSection = Tabs.Main:AddSection("Manuel Spam")
ManualSection:AddToggle("ManualSpam", {Title = "Manuel Spam", Default = false })
ManualSection:AddDropdown("SpamMode", {Title = "Mode", Values = {"Remote", "Click"}, Default = 1})
ManualSection:AddKeybind("SpamKey", {Title = "Spam Key", Mode = "Toggle", Default = "E"})
ManualSection:AddToggle("SpamNotify", {Title = "Spam Notify", Default = false })
ManualSection:AddToggle("AnimFix", {Title = "Animation Fix", Default = true })

-- AUTO SPAM PARRY SECTION
local AutoSpamSection = Tabs.Main:AddSection("Auto Spam Parry")
AutoSpamSection:AddToggle("AutoSpamParry", {Title = "Auto Spam Parry", Default = false })
AutoSpamSection:AddDropdown("AutoSpamMode", {Title = "Mode", Values = {"Remote"}, Default = 1})

Fluent:Notify({Title = "Blatant", Content = "GUI Loaded Successfully!", Duration = 5})
