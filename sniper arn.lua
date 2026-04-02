local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.Colors:CreateWindow("Ultra Sniper Arena", "RightShift")

local Settings = {
    Aimbot = false,
    WallCheck = true,
    Smoothness = 1, -- İstediğin gibi tam kitleme (Full Snap)
    AimbotKey = Enum.UserInputType.MouseButton2
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Duvar Kontrolü (Görmediğin adama kitlemez)
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

-- En Yakın Hedefi Bul
local function GetClosestTarget()
    local Closest = nil
    local ShortestDistance = math.huge

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") and v.Character:FindFirstChild("Humanoid").Health > 0 then
            local ScreenPos, OnScreen = Camera:WorldToViewportPoint(v.Character.Head.Position)
            if OnScreen and IsVisible(v.Character.Head) then
                local Distance = (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(ScreenPos.X, ScreenPos.Y)).Magnitude
                if Distance < ShortestDistance then
                    Closest = v.Character.Head
                    ShortestDistance = Distance
                end
            end
        end
    end
    return Closest
end

-- UI
local Main = Window:NewTab("Main")
local Section = Main:NewSection("Hard Lock Settings")

Section:NewToggle("Hard Aimbot", "Sağ tıkla hedefe direkt yapışır.", function(state)
    Settings.Aimbot = state
end)

Section:NewToggle("Wall Check (Görüş Kontrolü)", "Açık kalması ban riskini azaltır.", function(state)
    Settings.WallCheck = state
end)

Section:NewSlider("Snap Smoothness", "1 = Anında kitleme", 100, 1, function(s)
    Settings.Smoothness = s / 100
end)

-- Ana Döngü
RunService.RenderStepped:Connect(function()
    if Settings.Aimbot and UserInputService:IsMouseButtonPressed(Settings.AimbotKey) then
        local Target = GetClosestTarget()
        if Target then
            -- Lerp(LookAt, 1) kullanarak anında hedefe döner
            local LookAt = CFrame.new(Camera.CFrame.Position, Target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(LookAt, Settings.Smoothness)
        end
    end
end)
