-- [[ ttniscript | ttni131 ]] --
-- [[ No-Library Edition (Fix for Nil Error) ]] --

local Settings = {
    Aimbot = false,
    WallCheck = true,
    Smoothness = 1, -- 1 = Full Lock
    AimbotKey = Enum.UserInputType.MouseButton2
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- BASIT MENU OLUSTURMA (Kütüphane Gerektirmez)
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 200, 0, 150)
Frame.Position = UDim2.new(0, 50, 0, 50)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.BorderSizePixel = 2

local Title = Instance.new("TextLabel", Frame)
Title.Text = "ttniscript | ttni131"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.TextColor3 = Color3.fromRGB(0, 255, 127)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

-- Aimbot Button
local AimBtn = Instance.new("TextButton", Frame)
AimBtn.Text = "Aimbot: OFF"
AimBtn.Size = UDim2.new(0, 180, 0, 35)
AimBtn.Position = UDim2.new(0, 10, 0, 40)
AimBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
AimBtn.TextColor3 = Color3.new(1, 1, 1)

AimBtn.MouseButton1Click:Connect(function()
    Settings.Aimbot = not Settings.Aimbot
    AimBtn.Text = Settings.Aimbot and "Aimbot: ON" or "Aimbot: OFF"
    AimBtn.BackgroundColor3 = Settings.Aimbot and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(40, 40, 40)
end)

-- ESP Button
local ESPBtn = Instance.new("TextButton", Frame)
ESPBtn.Text = "Neon ESP"
ESPBtn.Size = UDim2.new(0, 180, 0, 35)
ESPBtn.Position = UDim2.new(0, 10, 0, 85)
ESPBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ESPBtn.TextColor3 = Color3.new(1, 1, 1)

ESPBtn.MouseButton1Click:Connect(function()
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character then
            if not v.Character:FindFirstChild("ttni_ESP") then
                local h = Instance.new("Highlight", v.Character)
                h.Name = "ttni_ESP"
                h.FillColor = Color3.fromRGB(0, 255, 127)
            end
        end
    end
end)

-- AIMBOT MANTIGI
local function IsVisible(TargetPart)
    if not Settings.WallCheck then return true end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LocalPlayer.Character, TargetPart.Parent}
    local result = workspace:Raycast(Camera.CFrame.Position, (TargetPart.Position - Camera.CFrame.Position).Unit * 1000, params)
    return result == nil
end

local function GetTarget()
    local closest = nil
    local dist = math.huge
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then
            local pos, onScreen = Camera:WorldToViewportPoint(v.Character.Head.Position)
            if onScreen and IsVisible(v.Character.Head) then
                local magnitude = (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                if magnitude < dist then
                    closest = v.Character.Head
                    dist = magnitude
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    if Settings.Aimbot and UserInputService:IsMouseButtonPressed(Settings.AimbotKey) then
        local target = GetTarget()
        if target then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), Settings.Smoothness)
        end
    end
end)

print("ttniscript FIXED Edition Loaded!")
