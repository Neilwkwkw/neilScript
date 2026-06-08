local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

local Window = OrionLib:MakeWindow({Name = "Blatant", HidePremium = false, SaveConfig = true, ConfigFolder = "BlatantConfig"})

-- Tabs
local Tab = Window:MakeTab({
	Name = "Main",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

-- BLATANT SECTION
Tab:AddSection({ Name = "Blatant" })

Tab:AddToggle({
	Name = "Auto Parry",
	Default = false,
	Callback = function(Value)
		print("Auto Parry: " .. tostring(Value))
	end    
})

Tab:AddSlider({
	Name = "Parry Accuracy",
	Min = 0,
	Max = 100,
	Default = 32,
	Increment = 1,
	Callback = function(Value)
		print("Accuracy: " .. Value)
	end    
})

Tab:AddDropdown({
	Name = "Auto Curve Direction",
	Default = "Random",
	Options = {"Random", "Left", "Right"},
	Callback = function(Value)
		print("Curve Direction: " .. Value)
	end    
})

Tab:AddToggle({
	Name = "Cooldown Protection",
	Default = true,
	Callback = function(Value)
		print("Cooldown Protection: " .. tostring(Value))
	end    
})

-- LOBBY AUTO PARRY SECTION
Tab:AddSection({ Name = "Lobby Auto Parry" })

Tab:AddToggle({
	Name = "Lobby Auto Parry",
	Default = false,
	Callback = function(Value)
		print("Lobby Auto Parry: " .. tostring(Value))
	end    
})

Tab:AddSlider({
	Name = "Lobby Parry Accuracy",
	Min = 0,
	Max = 100,
	Default = 40,
	Increment = 1,
	Callback = function(Value)
		print("Lobby Accuracy: " .. Value)
	end    
})

Tab:AddToggle({
	Name = "Lobby Random Accuracy",
	Default = false,
	Callback = function(Value)
		print("Lobby Random: " .. tostring(Value))
	end    
})

-- MANUEL SPAM SECTION
Tab:AddSection({ Name = "Manuel Spam" })

Tab:AddToggle({
	Name = "Manuel Spam",
	Default = false,
	Callback = function(Value)
		print("Manuel Spam: " .. tostring(Value))
	end    
})

Tab:AddDropdown({
	Name = "Mode",
	Default = "Remote",
	Options = {"Remote", "Click"},
	Callback = function(Value)
		print("Mode: " .. Value)
	end    
})

Tab:AddBind({
	Name = "Spam Key",
	Default = Enum.KeyCode.E,
	Hold = false,
	Callback = function()
		print("Spam Key pressed!")
	end    
})

Tab:AddToggle({
	Name = "Spam Notify",
	Default = false,
	Callback = function(Value)
		print("Notify: " .. tostring(Value))
	end    
})

Tab:AddToggle({
	Name = "Animation Fix",
	Default = true,
	Callback = function(Value)
		print("Anim Fix: " .. tostring(Value))
	end    
})

-- AUTO SPAM PARRY SECTION
Tab:AddSection({ Name = "Auto Spam Parry" })

Tab:AddToggle({
	Name = "Auto Spam Parry",
	Default = false,
	Callback = function(Value)
		print("Auto Spam Parry: " .. tostring(Value))
	end    
})

Tab:AddDropdown({
	Name = "Mode",
	Default = "Remote",
	Options = {"Remote"},
	Callback = function(Value)
		print("Auto Spam Mode: " .. Value)
	end    
})

OrionLib:Init()
