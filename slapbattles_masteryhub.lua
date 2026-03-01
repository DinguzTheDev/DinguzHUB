-- ==========================================
-- GAME CHECK (Slap Battles Only)
-- ==========================================
local validPlaceIds = {
    [6403373529] = true,  -- Main Arena
    [11520107397] = true, -- No One Shot Servers
    [11828327595] = true, -- Killstreak Only
    [9015014224] = true   -- Slap Royale
}

if not validPlaceIds[game.PlaceId] then
    return -- Zatrzymuje dalsze ładowanie skryptu
end

-- ==========================================
-- LOADING UI
-- ==========================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")

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
local PanicTab = Window:CreateTab("PANIC", "alert-octagon") -- Nowa zakładka

-- Script Variables
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Variables for Logic
local savedCFrame = nil
local loopEnabled = false
local loopDelay = 0.2
local targetPlayerName = ""
local attachConnection = nil
local autoHealEnabled = false
local antiVoidEnabled = false
local antiAfkConnection = nil
local espEnabled = false
local cameraLoopConnection = false

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
-- SCRIPTS TAB: Player & World
-- ==========================================
local WorldSection = ScriptsTab:CreateSection("Player & World")

local HealToggle = ScriptsTab:CreateToggle({
   Name = "Auto Heal (100 HP)",
   CurrentValue = false,
   Flag = "HealToggle",
   Callback = function(Value)
       autoHealEnabled = Value
   end,
})

local AntiVoidToggle = ScriptsTab:CreateToggle({
   Name = "Anti-Void",
   CurrentValue = false,
   Flag = "AntiVoidToggle",
   Callback = function(Value)
       antiVoidEnabled = Value
   end,
})

local AntiAFKToggle = ScriptsTab:CreateToggle({
   Name = "Anti-AFK",
   CurrentValue = false,
   Flag = "AntiAFKToggle",
   Callback = function(Value)
       if Value then
           antiAfkConnection = player.Idled:Connect(function()
               VirtualUser:CaptureController()
               VirtualUser:ClickButton2(Vector2.new())
           end)
       else
           if antiAfkConnection then
               antiAfkConnection:Disconnect()
               antiAfkConnection = nil
           end
       end
   end,
})

local AtmosphereButton = ScriptsTab:CreateButton({
   Name = "Remove Atmosphere & Unlock Zoom",
   Callback = function()
       local lighting = game:GetService("Lighting")
       for _, v in ipairs(lighting:GetChildren()) do
           if v:IsA("Atmosphere") then
               v:Destroy()
           end
       end
       player.CameraMaxZoomDistance = math.huge
       player.CameraMinZoomDistance = 0.5
       Rayfield:Notify({Title = "Success", Content = "Atmosphere removed & Zoom unlocked.", Duration = 3, Image = "check"})
   end,
})

local CameraButton = ScriptsTab:CreateButton({
   Name = "Force Third Person & Max Zoom",
   Callback = function()
       player.CameraMaxZoomDistance = math.huge
       player.CameraMinZoomDistance = 0.5
       player.CameraMode = Enum.CameraMode.Classic
       camera.CameraType = Enum.CameraType.Custom
       cameraLoopConnection = true
       
       task.wait(0.1)
       camera.CFrame = CFrame.new(camera.CFrame.Position + camera.CFrame.LookVector * -5)

       task.spawn(function()
           while cameraLoopConnection do
               task.wait(1)
               if player.CameraMode ~= Enum.CameraMode.Classic then
                   player.CameraMode = Enum.CameraMode.Classic
               end
               if camera.CameraType ~= Enum.CameraType.Custom then
                   camera.CameraType = Enum.CameraType.Custom
               end
               player.CameraMaxZoomDistance = math.huge
           end
       end)
       
       Rayfield:Notify({Title = "Camera Unlocked", Content = "Third person and max zoom applied.", Duration = 3, Image = "camera"})
   end,
})

-- ==========================================
-- OTHER TAB: Account Manager & Scripts
-- ==========================================
local AccountManagerSection = OtherTab:CreateSection("Account Manager")

local CopyGameIdButton = OtherTab:CreateButton({
   Name = "Copy Game ID (PlaceId)",
   Callback = function()
       setclipboard(tostring(game.PlaceId))
       Rayfield:Notify({Title = "Copied!", Content = "Game ID copied to clipboard.", Duration = 2, Image = "copy"})
   end,
})

local CopyJobIdButton = OtherTab:CreateButton({
   Name = "Copy Job ID (Server ID)",
   Callback = function()
       setclipboard(tostring(game.JobId))
       Rayfield:Notify({Title = "Copied!", Content = "Job ID copied to clipboard.", Duration = 2, Image = "copy"})
   end,
})

local ExternalScriptsSection = OtherTab:CreateSection("External Scripts")

local SiriusButton = OtherTab:CreateButton({
   Name = "Sirius",
   Callback = function()
       loadstring(game:HttpGet('https://sirius.menu/sirius'))()
   end,
})

local NamelessButton = OtherTab:CreateButton({
   Name = "Nameless",
   Callback = function()
       loadstring(game:HttpGet('https://raw.githubusercontent.com/FilteringEnabled/NamelessAdmin/main/Source'))()
   end,
})

-- ==========================================
-- PANIC TAB: Unload Script
-- ==========================================
local PanicSection = PanicTab:CreateSection("Danger Zone")

local UnloadButton = PanicTab:CreateButton({
   Name = "UNLOAD SCRIPT (Destroy UI)",
   Callback = function()
       -- 1. Wyłączanie wszystkich pętli w tle
       loopEnabled = false
       autoHealEnabled = false
       antiVoidEnabled = false
       espEnabled = false
       cameraLoopConnection = false
       
       -- 2. Rozłączanie eventów
       if attachConnection then attachConnection:Disconnect() end
       if antiAfkConnection then antiAfkConnection:Disconnect() end
       
       -- 3. Czyszczenie ESP z graczy
       for _, p in ipairs(Players:GetPlayers()) do
           if p.Character and p.Character:FindFirstChild("ESPHighlight") then
               p.Character.ESPHighlight:Destroy()
           end
       end
       
       -- 4. Niszczenie całego GUI Rayfield
       Rayfield:Destroy()
   end,
})

-- ==========================================
-- BACKGROUND LOOPS
-- ==========================================

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

task.spawn(function()
    while true do
        task.wait(0.1)
        if antiVoidEnabled then
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                if char.HumanoidRootPart.Position.Y < -20 then
                    if savedCFrame then
                        char.HumanoidRootPart.CFrame = savedCFrame
                    else
                        char.HumanoidRootPart.CFrame = CFrame.new(0, 100, 0)
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(1)
        if espEnabled then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player and p.Character then
                    if not p.Character:FindFirstChild("ESPHighlight") then
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
    end
end)
