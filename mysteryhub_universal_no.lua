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
       
       
       -- Odczekanie 3 sekund
task.wait(3)
       
       -- Wyrzucenie z serwera z niestandardową wiadomością
game.Players.LocalPlayer:Kick("słuchaj sie cwelu i przetestuj ten skrypt w tsb😈")
