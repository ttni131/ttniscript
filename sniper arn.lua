-- [[ ttni131 | cs2lua ]] --
-- [[ Apex Edition - JJSploit & Low-Level Fix ]] --

local Settings = {
    Aimbot = false,
    WallCheck = true,
    AimbotKey = Enum.UserInputType.MouseButton2, -- Sağ Tık
    MenuKey = Enum.KeyCode.RightShift,
    ESP = true
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- == MANUEL MENU (Hata Vermez) == --
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 220, 0, 150)
MainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 2
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "ttniscript: Apex (JJSploit Fix)"
Title.TextColor3 = Color3.fromRGB(0, 255, 127)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

local function CreateButton(text, pos, callback)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0, 200, 0, 35)
    btn.Position = UDim2.new(0, 10, 0, pos)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local AimBtn = CreateButton("AIMLOCK: KAPALI", 40, function()
    Settings.Aimbot = not Settings.Aimbot
    _G.btnText = Settings.Aimbot and "AIMLOCK: ACIK" or "AIMLOCK: KAPALI"
end)

local ESPBtn = CreateButton("ESP: AKTIF ET", 85, function()
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and not v.Character:FindFirstChild("ttni_ESP") then
            local h = Instance.new("Highlight", v.Character)
            h.Name = "ttni_ESP"
            h.FillColor = Color3.fromRGB(0, 255, 127)
        end
    end
end)

-- Menü Kapatma (Right Shift)
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Settings.MenuKey then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- == AIMLOCK (SADECE KAFA) == --
local function GetClosestHead()
    local target = nil
    local dist = math.huge
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") and v.Character.Humanoid.Health > 0 then
            local head = v.Character.Head
            local _, onScreen = Camera:WorldToViewportPoint(head.Position)
            
            if onScreen then
                local mag = (head.Position - Camera.CFrame.Position).Magnitude
                if mag < dist then
                    target = head
                    dist = mag
                end
            end
        end
    end
    return target
end

RunService.RenderStepped:Connect(function()
    AimBtn.Text = _G.btnText or "AIMLOCK: KAPALI"
    if Settings.Aimbot and UserInputService:IsMouseButtonPressed(Settings.AimbotKey) then
        local target = GetClosestHead()
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end
end)

print("ttniscript FIXED: Artik nil hatasi alamazsin!")
