-- [[ ttniscript | ttni131 ]] --
-- [[ Toggle Menu & Anti-Wall-Lock Edition ]] --

local Settings = {
    Aimbot = false,
    WallCheck = true,
    Smoothness = 1, 
    AimbotKey = Enum.UserInputType.MouseButton2, -- Sağ Tık
    ToggleKey = Enum.KeyCode.RightShift -- Menü Kapatma Tuşu
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- MENU OLUSTURMA
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 200, 0, 160)
Frame.Position = UDim2.new(0, 50, 0, 50)
Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Frame.BorderSizePixel = 1
Frame.Draggable = true
Frame.Active = true
Frame.Visible = true -- Başlangıçta açık

local Title = Instance.new("TextLabel", Frame)
Title.Text = "ttniscript | ttni131"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)

-- Aimbot Button
local AimBtn = Instance.new("TextButton", Frame)
AimBtn.Text = "Aimbot: KAPALI"
AimBtn.Size = UDim2.new(0, 180, 0, 40)
AimBtn.Position = UDim2.new(0, 10, 0, 45)
AimBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
AimBtn.TextColor3 = Color3.new(1, 1, 1)

AimBtn.MouseButton1Click:Connect(function()
    Settings.Aimbot = not Settings.Aimbot
    AimBtn.Text = Settings.Aimbot and "Aimbot: AÇIK" or "Aimbot: KAPALI"
    AimBtn.BackgroundColor3 = Settings.Aimbot and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(45, 45, 45)
end)

-- ESP Button
local ESPBtn = Instance.new("TextButton", Frame)
ESPBtn.Text = "Neon ESP Aç"
ESPBtn.Size = UDim2.new(0, 180, 0, 40)
ESPBtn.Position = UDim2.new(0, 10, 0, 95)
ESPBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
ESPBtn.TextColor3 = Color3.new(1, 1, 1)

ESPBtn.MouseButton1Click:Connect(function()
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character then
            if not v.Character:FindFirstChild("ttni_ESP") then
                local h = Instance.new("Highlight", v.Character)
                h.Name = "ttni_ESP"
                h.FillColor = Color3.fromRGB(0, 255, 127)
                h.FillTransparency = 0.5
            end
        end
    end
end)

-- MENU GIZLEME (Right Shift)
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Settings.ToggleKey then
        Frame.Visible = not Frame.Visible
    end
end)

-- WALL CHECK (Görünürlük Kontrolü)
local function IsVisible(TargetPart)
    local Character = LocalPlayer.Character
    if not Character then return false end
    
    local Params = RaycastParams.new()
    Params.FilterType = Enum.RaycastFilterType.Exclude
    Params.FilterDescendantsInstances = {Character, TargetPart.Parent} -- Kendini ve hedefi sayma
    
    local Result = workspace:Raycast(Camera.CFrame.Position, (TargetPart.Position - Camera.CFrame.Position).Unit * 1000, Params)
    return Result == nil -- Eğer arada başka bir şey yoksa (duvar gibi) true döner
end

-- AIMBOT DÖNGÜSÜ
RunService.RenderStepped:Connect(function()
    if Settings.Aimbot and UserInputService:IsMouseButtonPressed(Settings.AimbotKey) then
        local Target = nil
        local ShortestDist = math.huge
        
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then
                local head = v.Character.Head
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                
                if onScreen and IsVisible(head) then
                    local magnitude = (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                    if magnitude < ShortestDist then
                        Target = head
                        ShortestDist = magnitude
                    end
                end
            end
        end
        
        if Target then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, Target.Position), Settings.Smoothness)
        end
    end
end)

print("ttniscript V4: Right Shift ile menü kapanabilir!")
