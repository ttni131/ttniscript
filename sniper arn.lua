print("ttniscript baslatiliyor...") -- F9 konsolunda bunu görmen lazım

local success, err = pcall(function()
    local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
    local Window = Library.Colors:CreateWindow("ttniscript | ttni131", "RightShift")
    
    -- ... (Geri kalan kodlar buraya) ...
    
    print("ttniscript basariyla yuklendi!")
end)

if not success then
    warn("Script yuklenirken hata olustu: " .. err)
end-- [[ ttniscript | ttni131 ]] --
-- [[ File: sniper arn.lua ]] --

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.Colors:CreateWindow("ttniscript | ttni131", "RightShift")

local Settings = {
    Aimbot = false,
    WallCheck = true,
    Smoothness = 1, -- Full Lock (1 Smoot)
    AimbotKey = Enum.UserInputType.MouseButton2 -- Sağ Tık
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Duvar Kontrolü
local function IsVisible(TargetPart)
    if not Settings.WallCheck then return true end
    local Character = LocalPlayer.Character
    if not Character then return false end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {Character, TargetPart.Parent}
    local result = workspace:Raycast(Camera.CFrame.Position, (TargetPart.Position - Camera.CFrame.Position).Unit * 1000, params)
    return result == nil
end

-- Hedef Seçici
local function GetTarget()
    local Closest = nil
    local ShortestDistance = math.huge
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") and v.Character:FindFirstChild("Humanoid").Health > 0 then
            local ScreenPos, OnScreen = Camera:WorldToViewportPoint(v.Character.Head.Position)
            if OnScreen and IsVisible(v.Character.Head) then
                local dist = (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(ScreenPos.X, ScreenPos.Y)).Magnitude
                if dist < ShortestDistance then
                    Closest = v.Character.Head
                    ShortestDistance = dist
                end
            end
        end
    end
    return Closest
end

-- Menü Tasarımı
local Main = Window:NewTab("ttniscript")
local Section = Main:NewSection("Sniper Arena - ttni131")

Section:NewToggle("Aimbot (Hard Lock)", "Sağ tıkla hedefe anında yapışır.", function(state) Settings.Aimbot = state end)
Section:NewToggle("Wall Check", "Duvar arkası kitlemeyi engeller.", function(state) Settings.WallCheck = state end)
Section:NewSlider("Smoothness", "1 = Full Lock", 100, 10, function(s) Settings.Smoothness = s / 100 end)
Section:NewButton("ESP (Neon Green)", "Rakipleri gösterir.", function()
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and not v.Character:FindFirstChild("ttni_ESP") then
            local h = Instance.new("Highlight", v.Character)
            h.Name = "ttni_ESP"
            h.FillColor = Color3.fromRGB(0, 255, 127)
            h.FillTransparency = 0.5
        end
    end
end)

-- Döngü
RunService.RenderStepped:Connect(function()
    if Settings.Aimbot and UserInputService:IsMouseButtonPressed(Settings.AimbotKey) then
        local target = GetTarget()
        if target then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), Settings.Smoothness)
        end
    end
end)

print("ttniscript Loaded! Creator: ttni131")
