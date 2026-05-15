local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local bgm = SoundService:WaitForChild("BackgroundMusic")

-- 1. INITIAL STATE
bgm.Volume = 0 -- Start silent
bgm:Play()

-- 2. THE FADE-IN (High-End Polish)
-- We use a 4-second fade so the transition feels natural
local fadeInfo = TweenInfo.new(4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
local fadeIn = TweenService:Create(bgm, fadeInfo, {Volume = 0.8})

fadeIn:Play()

-- 3. OPTIONAL: The "Low-Pass" Cave Effect
-- If you want it to sound like the music is "inside" the cave
local equalizer = bgm:FindFirstChildOfClass("EqualizerSoundEffect") or Instance.new("EqualizerSoundEffect")
equalizer.HighGain = -10 -- Muffles the sharp highs for a "deep cave" vibe
equalizer.Parent = bgm