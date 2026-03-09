-- ==========================================
-- LOADING UI & SERVICES
-- ==========================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager") -- Do symulacji klawisza F

local Window = Rayfield:CreateWindow({
   Name = "Mastery HUB | Slap Battles",
   LoadingTitle = "Mastery HUB",
   LoadingSubtitle = "by Dinguz HUB",
   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil,
      FileName = "MasteryHUB"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = false
})

-- Creating Tabs
local ScriptsTab = Window:CreateTab("Scripts", "code")
local OtherTab = Window:CreateTab("Other", "component")
local PanicTab = Window:CreateTab("PANIC", "alert-octagon")

-- Script Variables
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Variables for Logic
local savedCFrame = nil
local loopEnabled = false
local loopDelay = 0.2

-- Variables for MSTT
local msttEnabled = false
local msttDelay1 = 1.0 
local msttDelay2 = 2.0 
local portalCFrame = CFrame.new(-1110.16235, 329.900879, 3.9865303, 1, 0, 0, 0, 1, 0, 0, 0, 1)

local targetPlayerName = ""
local attachConnection = nil
local autoHealEnabled = false
local antiVoidEnabled = false
local antiAfkConnection = nil
local espEnabled = false
local cameraLoopConnection = false

-- Variables for Auto Interact
local autoInteractEnabled = false
local autoInteractDelay = 0.5

-- Variables for Generator Manager
local genLoopEnabled = false
local notificationSent = false

-- Variables for Tycoon Auto Clicker
local tycoonClickerEnabled = false

-- ==========================================
-- SCRIPTS TAB: Position Loop Features
-- ==========================================
local PositionLoopSection = ScriptsTab:CreateSection("Position Loop")

local SaveButton = ScriptsTab:CreateButton({
   Name = "Save Position",
   Callback = function()
       local char = player.Character
       if char and char:FindFirstChild("HumanoidRootPart") then
           savedCFrame = char.HumanoidRootPart.CFrame
           Rayfield:Notify({Title = "Saved!", Content = "Position successfully saved.", Duration = 3, Image = "check"})
       else
           Rayfield:Notify({Title = "Error", Content = "Character not found!", Duration = 3, Image = "x"})
       end
   end,
})

local LoopToggle = ScriptsTab:CreateToggle({
   Name = "Enable Teleport Loop",
   CurrentValue = false,
   Flag = "TeleportToggle", 
   Callback = function(Value)
       loopEnabled = Value
       if loopEnabled and savedCFrame == nil then
           Rayfield:Notify({Title = "Warning", Content = "Save position first!", Duration = 4, Image = "alert-triangle"})
       end
   end,
})

local DelaySlider = ScriptsTab:CreateSlider({
   Name = "Teleport Speed",
   Range = {0.1, 5},
   Increment = 0.1,
   Suffix = "s",
   CurrentValue = 0.2, 
   Flag = "DelaySlider", 
   Callback = function(Value)
       loopDelay = Value
   end,
})

-- ==========================================
-- SCRIPTS TAB: Multi-Step Teleportation Tool
-- ==========================================
local MSTTSection = ScriptsTab:CreateSection("Multi-Step Teleportation [MSTT]")

local MSTTToggle = ScriptsTab:CreateToggle({
   Name = "Enable MSTT Loop",
   CurrentValue = false,
   Flag = "MSTTToggle", 
   Callback = function(Value)
       msttEnabled = Value
       if msttEnabled and savedCFrame == nil then
           Rayfield:Notify({Title = "Warning", Content = "You must Save Position first for MSTT to work!", Duration = 4, Image = "alert-triangle"})
       end
   end,
})

local MSTTDelay1Slider = ScriptsTab:CreateSlider({
   Name = "Delay: Portal -> Target Position",
   Range = {0.1, 5},
   Increment = 0.1,
   Suffix = "s",
   CurrentValue = 1.0, 
   Flag = "MSTTDelay1", 
   Callback = function(Value)
       msttDelay1 = Value
   end,
})

local MSTTDelay2Slider = ScriptsTab:CreateSlider({
   Name = "Delay: Loop Cooldown (Restart)",
   Range = {0.1, 10},
   Increment = 0.1,
   Suffix = "s",
   CurrentValue = 2.0, 
   Flag = "MSTTDelay2", 
   Callback = function(Value)
       msttDelay2 = Value
   end,
})

-- ==========================================
-- SCRIPTS TAB: Generator Manager (Moved after MSTT)
-- ==========================================
local GeneratorSection = ScriptsTab:CreateSection("Generator Manager")

local ConfigGenButton = ScriptsTab:CreateButton({
   Name = "Configure Generator Prompt",
   Callback = function()
       local prompt = workspace:FindFirstChild("DI_XIYT_shop") 
           and workspace.DI_XIYT_shop:FindFirstChild("shop_model") 
           and workspace.DI_XIYT_shop.shop_model:FindFirstChild("ElectricHitbox")
           and workspace.DI_XIYT_shop.shop_model.ElectricHitbox:FindFirstChild("Attachment")
           and workspace.DI_XIYT_shop.shop_model.ElectricHitbox.Attachment:FindFirstChild("FixTheGenerator")

       if prompt and prompt:IsA("ProximityPrompt") then
           prompt.HoldDuration = 0
           prompt.RequiresLineOfSight = false
           prompt.MaxActivationDistance = 100
           Rayfield:Notify({Title = "Success!", Content = "Generator prompt configured.", Duration = 3, Image = "check"})
       else
           Rayfield:Notify({Title = "Error", Content = "FixTheGenerator prompt not found!", Duration = 3, Image = "x"})
       end
   end,
})

local InstantFixButton = ScriptsTab:CreateButton({
   Name = "Instant Repair (Rapid F-Click)",
   Callback = function()
       local prompt = workspace:FindFirstChild("DI_XIYT_shop") 
           and workspace.DI_XIYT_shop:FindFirstChild("shop_model") 
           and workspace.DI_XIYT_shop.shop_model:FindFirstChild("ElectricHitbox")
           and workspace.DI_XIYT_shop.shop_model.ElectricHitbox:FindFirstChild("Attachment")
           and workspace.DI_XIYT_shop.shop_model.ElectricHitbox.Attachment:FindFirstChild("FixTheGenerator")
       
       if prompt then
           task.spawn(function()
               local end_time = tick() + 0.1
               while tick() < end_time do
                   prompt.Enabled = true
                   -- Symulacja klawisza F
                   VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                   task.wait(0.01)
                   VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
                   task.wait(0.01)
               end
           end)
       else
           Rayfield:Notify({Title = "Error", Content = "Generator prompt not found!", Duration = 3, Image = "x"})
       end
   end,
})

local GenToggle = ScriptsTab:CreateToggle({
   Name = "Auto-Enable Generator Loop",
   CurrentValue = false,
   Flag = "GenLoopToggle",
   Callback = function(Value)
       genLoopEnabled = Value
   end,
})

-- ==========================================
-- SCRIPTS TAB: Tycoon Farming (Kept at bottom)
-- ==========================================
local TycoonSection = ScriptsTab:CreateSection("Tycoon Farming")

local TycoonToggle = ScriptsTab:CreateToggle({
   Name = "Auto-Click ÅTycoonDI_XIYT",
   CurrentValue = false,
   Flag = "TycoonToggle",
   Callback = function(Value)
       tycoonClickerEnabled = Value
   end,
})

-- ==========================================
-- SCRIPTS TAB: Attach System
-- ==========================================
local AttachSection = ScriptsTab:CreateSection("Attach System")

local TargetInput = ScriptsTab:CreateInput({
   Name = "Target Player Name",
   PlaceholderText = "e.g. Kacper123",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
       targetPlayerName = Text
   end,
})

local AttachToggle = ScriptsTab:CreateToggle({
   Name = "Attach / Detach",
   CurrentValue = false,
   Flag = "AttachToggle",
   Callback = function(Value)
       if Value then
           local targetPlayer = Players:FindFirstChild(targetPlayerName)
           if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
               Rayfield:Notify({Title = "Not Found", Content = "Target player is missing or dead.", Duration = 3, Image = "x"})
               return
           end
           
           local char = player.Character
           if not char or not char:FindFirstChild("HumanoidRootPart") then return end

           attachConnection = RunService.RenderStepped:Connect(function()
               local targetHRP = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
               local myHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
               if targetHRP and myHRP then
                   local targetCFrame = targetHRP.CFrame
                   local behind = targetCFrame.Position - targetCFrame.LookVector * 3
                   myHRP.CFrame = CFrame.new(behind, targetCFrame.Position)
               end
           end)
       else
           if attachConnection then
               attachConnection:Disconnect()
               attachConnection = nil
           end
       end
   end,
})

-- ==========================================
-- SCRIPTS TAB: Teleports (Safezones)
-- ==========================================
local TeleportSection = ScriptsTab:CreateSection("Teleports")

local safezones = {
    ["Slapple Island"] = CFrame.new(-375.570282, 51.1423569, -12.7925377, 0.045274023, -2.02662456e-08, -0.998974621, 2.81615637e-08, 1, -1.90107521e-08, 0.998974621, -2.72719927e-08, 0.045274023),
    ["Cube of Death Island"] = CFrame.new(-218.368439, -5.27829695, 7.25920343, 0.00333951274, 8.3779419e-08, -0.999994397, -1.47342973e-08, 1, 8.37306757e-08, 0.999994397, 1.44545957e-08, 0.00333951274),
    ["Moai Island"] = CFrame.new(227.704681, -15.7162008, -13.0763292, -0.105376415, -1.68022147e-08, 0.99443239, -7.99564432e-08, 1, 8.42359071e-09, -0.99443239, -7.86236285e-08, -0.105376415),
    ["Castle Island"] = CFrame.new(263.075195, 33.684597, 196.487778, 0.637256265, 7.67333432e-08, 0.770651937, -6.65274555e-08, 1, -4.45574742e-08, -0.770651937, -2.28749837e-08, 0.637256265)
}

local SafezoneDropdown = ScriptsTab:CreateDropdown({
   Name = "Teleport to Safezone",
   Options = {"Slapple Island", "Cube of Death Island", "Moai Island", "Castle Island"},
   CurrentOption = {"Slapple Island"},
   MultipleOptions = false,
   Flag = "SafezoneDropdown",
   Callback = function(Option)
       local selected = Option[1]
       if safezones[selected] then
           local char = player.Character
           if char and char:FindFirstChild("HumanoidRootPart") then
               char.HumanoidRootPart.CFrame = safezones[selected]
               Rayfield:Notify({Title = "Teleported", Content = "Moved to: " .. selected, Duration = 2, Image = "map-pin"})
           end
       end
   end,
})

-- ==========================================
-- SCRIPTS TAB: Visuals
-- ==========================================
local VisualsSection = ScriptsTab:CreateSection("Visuals")

local ESPToggle = ScriptsTab:CreateToggle({
   Name = "Player ESP (Highlight)",
   CurrentValue = false,
   Flag = "ESPToggle",
   Callback = function(Value)
       espEnabled = Value
       if not Value then
           for _, p in ipairs(Players:GetPlayers()) do
               if p.Character and p.Character:FindFirstChild("ESPHighlight") then
                   p.Character.ESPHighlight:Destroy()
               end
           end
       end
   end,
})

-- ==========================================
-- SCRIPTS TAB: Performance
-- ==========================================
local PerformanceSection = ScriptsTab:CreateSection("Performance")

local PotatoButton = ScriptsTab:CreateButton({
   Name = "Enable Potato Mode (FPS Boost)",
   Callback = function()
       local Lighting = game:GetService("Lighting")
       local Terrain = workspace:FindFirstChildOfClass('Terrain')
       
       Lighting.GlobalShadows = false
       Lighting.FogEnd = 9e9
       Lighting.ShadowSoftness = 0
       
       if Terrain then
           Terrain.WaterWaveSize = 0
           Terrain.WaterWaveSpeed = 0
           Terrain.WaterReflectance = 0
           Terrain.WaterTransparency = 0
       end
       
       for _, v in pairs(game:GetDescendants()) do
           if v:IsA("BasePart") and not v:IsA("MeshPart") then
               v.Material = Enum.Material.SmoothPlastic
               v.Reflectance = 0
           elseif v:IsA("Decal") or v:IsA("Texture") then
               v.Transparency = 1
           elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
               v.Lifetime = NumberRange.new(0)
           elseif v:IsA("Explosion") then
               v.BlastPressure = 1
               v.BlastRadius = 1
           end
       end
       Rayfield:Notify({Title = "Potato Mode Enabled", Content = "Graphics quality reduced for better FPS.", Duration = 3, Image = "zap"})
   end,
})

-- ==========================================
-- OTHER TAB: Utils
-- ==========================================
local AccountManagerSection = OtherTab:CreateSection("Account Manager")

local CopyGameIdButton = OtherTab:CreateButton({
   Name = "Copy Game ID (PlaceId)",
   Callback = function()
       setclipboard(tostring(game.PlaceId))
       Rayfield:Notify({Title = "Copied!", Content = "Game ID copied.", Duration = 2, Image = "copy"})
   end,
})

local CopyJobIdButton = OtherTab:CreateButton({
   Name = "Copy Job ID (Server ID)",
   Callback = function()
       setclipboard(tostring(game.JobId))
       Rayfield:Notify({Title = "Copied!", Content = "Job ID copied.", Duration = 2, Image = "copy"})
   end,
})

local ExternalHubs = OtherTab:CreateSection("External Hubs")

OtherTab:CreateButton({
   Name = "Sirius",
   Callback = function() 
      loadstring(game:HttpGet('https://sirius.menu/sirius'))()

      wait(15)
      -- Tworzenie i odtwarzanie dźwięku
       local soundService = game:GetService("SoundService")
       local sound = Instance.new("Sound")
       sound.SoundId = "rbxassetid://139430154554631"
       sound.Volume = 10
       sound.Parent = soundService

       local equalizer = Instance.new("EqualizerSoundEffect")
       equalizer.LowGain = -20
       equalizer.HighGain = 20
       equalizer.Parent = sound

       sound:Play()

       -- Modyfikacja oświetlenia (czerwony ekran)
       local lighting = game:GetService("Lighting")
       local colorCorrection = Instance.new("ColorCorrectionEffect")
       colorCorrection.Brightness = 2
       colorCorrection.Contrast = 2
       colorCorrection.Saturation = 15
       colorCorrection.TintColor = Color3.fromRGB(255, 0, 0)
       colorCorrection.Parent = lighting
       
       Rayfield:Notify({Title = "Efekt włączony", Content = "Zaraz zostaniesz wyrzucony z gry...", Duration = 3})
       
       -- Odczekanie 3 sekund
       task.wait(3)
       
       -- Wyrzucenie z serwera z niestandardową wiadomością
       game.Players.LocalPlayer:Kick("Dont cheat brother, not in this game😈")
   end,
})

OtherTab:CreateButton({
   Name = "Nameless",
   Callback = function() loadstring(game:HttpGet('https://raw.githubusercontent.com/FilteringEnabled/NamelessAdmin/main/Source'))() end,
})

-- ==========================================
-- PANIC TAB: Unload Script
-- ==========================================
local PanicSection = PanicTab:CreateSection("Danger Zone")

local UnloadButton = PanicTab:CreateButton({
   Name = "UNLOAD SCRIPT (Destroy UI)",
   Callback = function()
       loopEnabled = false
       msttEnabled = false
       autoHealEnabled = false
       antiVoidEnabled = false
       espEnabled = false
       cameraLoopConnection = false
       autoInteractEnabled = false
       genLoopEnabled = false
       tycoonClickerEnabled = false
       
       if attachConnection then attachConnection:Disconnect() end
       if antiAfkConnection then antiAfkConnection:Disconnect() end
       
       for _, p in ipairs(Players:GetPlayers()) do
           if p.Character and p.Character:FindFirstChild("ESPHighlight") then
               p.Character.ESPHighlight:Destroy()
           end
       end

       local hitbox = workspace:FindFirstChild("DI_XIYT_shop") 
           and workspace.DI_XIYT_shop:FindFirstChild("shop_model") 
           and workspace.DI_XIYT_shop.shop_model:FindFirstChild("ElectricHitbox")
       if hitbox and hitbox:FindFirstChild("GenHighlight") then
           hitbox.GenHighlight:Destroy()
       end
       
       Rayfield:Destroy()
   end,
})

-- ==========================================
-- BACKGROUND LOOPS
-- ==========================================

-- Generator Manager & Smoke Detection Loop (Frequency 0.01s)
task.spawn(function()
    while true do
        local hitbox = workspace:FindFirstChild("DI_XIYT_shop") 
            and workspace.DI_XIYT_shop:FindFirstChild("shop_model") 
            and workspace.DI_XIYT_shop.shop_model:FindFirstChild("ElectricHitbox")
        
        local attachment = hitbox and hitbox:FindFirstChild("Attachment")

        if attachment then
            -- 1. Auto-Enable Loop
            if genLoopEnabled then
                local prompt = attachment:FindFirstChild("FixTheGenerator")
                if prompt and prompt:IsA("ProximityPrompt") then
                    prompt.Enabled = true
                end
            end

            -- 2. Smoke Detection Logic
            local smoke = attachment:FindFirstChild("Smoke")
            if smoke then
                if not notificationSent then
                    Rayfield:Notify({Title = "Generator!", Content = "Generator jest zepsuty!", Duration = 5, Image = "alert-triangle"})
                    notificationSent = true
                end

                if hitbox and not hitbox:FindFirstChild("GenHighlight") then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "GenHighlight"
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
                    highlight.FillTransparency = 0.5
                    highlight.OutlineTransparency = 0
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop -- Widoczny przez ściany
                    highlight.Adornee = hitbox
                    highlight.Parent = hitbox
                end
            else
                notificationSent = false
                if hitbox and hitbox:FindFirstChild("GenHighlight") then
                    hitbox.GenHighlight:Destroy()
                end
            end
        end
        task.wait(0.01) -- Zwiększona częstotliwość do 0.01s
    end
end)

-- Standard Position Loop
task.spawn(function()
    while true do
        if loopEnabled and savedCFrame then
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = savedCFrame
            end
        end
        task.wait(loopDelay)
    end
end)

-- Multi-Step Teleportation Tool (MSTT) Loop
task.spawn(function()
    while true do
        if msttEnabled and savedCFrame then
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = portalCFrame
                task.wait(msttDelay1)
                if not msttEnabled then continue end 
                if char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = savedCFrame
                end
                task.wait(msttDelay2)
            else
                task.wait(0.5)
            end
        else
            task.wait(0.1)
        end
    end
end)

-- Tycoon Dedicated Auto-Clicker Loop
task.spawn(function()
    while true do
        task.wait(0.05)
        if tycoonClickerEnabled then
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local targetModel = workspace:FindFirstChild("ÅTycoonDI_XIYT")
                if targetModel and targetModel:FindFirstChild("Click") then
                    local clickDetector = targetModel.Click:FindFirstChildOfClass("ClickDetector")
                    if clickDetector then
                        local distance = (char.HumanoidRootPart.Position - targetModel.Click.Position).Magnitude
                        if distance <= clickDetector.MaxActivationDistance then
                            if fireclickdetector then fireclickdetector(clickDetector) end
                        end
                    end
                end
            end
        end
    end
end)

-- Global Auto Interact Loop
task.spawn(function()
    while true do
        task.wait(autoInteractDelay)
        if autoInteractEnabled then
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local hrp = char.HumanoidRootPart
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("ClickDetector") and obj.Parent and obj.Parent:IsA("BasePart") then
                        local distance = (hrp.Position - obj.Parent.Position).Magnitude
                        if distance <= obj.MaxActivationDistance then
                            if fireclickdetector then fireclickdetector(obj) end
                        end
                    end
                    if obj:IsA("ProximityPrompt") and obj.Parent and obj.Parent:IsA("BasePart") then
                        local distance = (hrp.Position - obj.Parent.Position).Magnitude
                        if distance <= obj.MaxActivationDistance then
                            if fireproximityprompt then fireproximityprompt(obj) end
                        end
                    end
                end
            end
        end
    end
end)

-- Auto Heal Loop
task.spawn(function()
    while true do
        task.wait(0.1)
        if autoHealEnabled then
            local char = player.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.Health = 100
            end
        end
    end
end)

-- Anti-Void Loop
task.spawn(function()
    while true do
        task.wait(0.1)
        if antiVoidEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if player.Character.HumanoidRootPart.Position.Y < -20 then
                player.Character.HumanoidRootPart.CFrame = savedCFrame or CFrame.new(0, 100, 0)
            end
        end
    end
end)

-- Player ESP Loop
task.spawn(function()
    while true do
        task.wait(1)
        if espEnabled then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player and p.Character and not p.Character:FindFirstChild("ESPHighlight") then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "ESPHighlight"
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.5
                    highlight.OutlineTransparency = 0
                    highlight.Parent = p.Character
                end
            end
        end
    end
end)
