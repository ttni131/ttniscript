-- [[ ttniscript | ttni131 ]] --
-- [[ File: sniper_arn.lua ]] --

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "ttniscript | ttni131", HidePremium = false, SaveConfig = true, ConfigFolder = "ttniConfig"})

local Settings = {
    Aimbot = false,
    WallCheck = true,
    Smoothness = 1, -- Full Lock
    AimbotKey = Enum.UserInputType.MouseButton2
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Duvar Kontrolü (Raycast)
local function IsVisible(TargetPart)
    if not Settings.WallCheck then return true end
    local Character = LocalPlayer.Character
    if not Character then return false end
    
    local RaycastParams = RaycastParams.new()
    RaycastParams.FilterType = Enum.RaycastFilterType.Exclude
    RaycastParams.FilterDescendantsInstances = {Character, TargetPart.Parent}
    
    local Result = workspace:Raycast(Camera.CFrame.Position, (TargetPart.Position - Camera.CFrame.Position).Unit * 1000, RaycastParams)
    return Result == nil
end

-- Hedef Bulucu
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

-- Menü Sekmeleri
local MainTab = Window:MakeTab({
	Name = "Aimbot & Visuals",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

MainTab:AddToggle({
	Name = "Hard Aimbot (Sağ Tık)",
	Default = false,
	Callback = function(Value)
		Settings.Aimbot = Value
	end    
})

MainTab:AddToggle({
	Name = "Wall Check (Görüş Kontrolü)",
	Default = true,
	Callback = function(Value)
		Settings.WallCheck = Value
	end    
})

MainTab:AddSlider({
	Name = "Smoothness (Hız)",
	Min = 1,
	Max = 100,
	Default = 100,
	Color = Color3.fromRGB(0,255,127),
	Increment = 1,
	ValueName = "%",
	Callback = function(Value)
		Settings.Smoothness = Value / 100
	end    
})

MainTab:AddButton({
	Name = "Neon ESP",
	Callback = function()
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and not v.Character:FindFirstChild("ttni_ESP") then
                local h = Instance.new("Highlight", v.Character)
                h.Name = "ttni_ESP"
                h.FillColor = Color3.fromRGB(0, 255, 127)
                h.FillTransparency = 0.5
            end
        end
	end    
})

-- Çalışma Döngüsü
RunService.RenderStepped:Connect(function()
    if Settings.Aimbot and UserInputService:IsMouseButtonPressed(Settings.AimbotKey) then
        local target = GetTarget()
        if target then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), Settings.Smoothness)
        end
    end
end)

OrionLib:Init() -- Menüyü Başlat
