-- [[ ttni131 | cs2lua ]] --
-- [[ Project: ttniscript: Apex Edition ]] --
-- [[ File: sniper_arn.lua ]] --

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.Colors:CreateWindow("ttniscript: Apex Edition", "RightShift")

local Settings = {
    Aimbot = false,
    AimbotSmoothness = 1, -- 1 = Anında Lock
    WallCheck = true,
    HeadshotOnly = true, -- Sadece Kafa
    AimbotKey = Enum.UserInputType.MouseButton2,
    ESP = {
        Boxes = false,
        Names = false,
        Tracer = false,
        Skeletons = false,
        Health = false
    }
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- == AIMBOT MANTIGI == --

-- Duvar Kontrolü
local function IsVisible(TargetPart)
    if not Settings.WallCheck then return true end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LocalPlayer.Character, TargetPart.Parent}
    local result = workspace:Raycast(Camera.CFrame.Position, (TargetPart.Position - Camera.CFrame.Position).Unit * 1000, params)
    return result == nil
end

-- Hedef Bulucu
local function GetTarget()
    local target = nil
    local dist = math.huge
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") and v.Character.Humanoid.Health > 0 then
            local head = v.Character.Head
            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen and IsVisible(head) then
                local magnitude = (head.Position - Camera.CFrame.Position).Magnitude
                if magnitude < dist then
                    target = head -- Sadece Kafa
                    dist = magnitude
                end
            end
        end
    end
    return target
end

-- == ESP MANTIGI == --
local Drawing = Drawing or error("Executor'in Drawing Library desteklemiyor!")

local function CreateDraw(type, properties)
    local obj = Drawing.new(type)
    for i, v in pairs(properties) do
        obj[i] = v
    end
    return obj
end

local function HandleESP(p)
    if p == LocalPlayer then return end
    
    local Box = CreateDraw("Square", {Thickness = 1, Filled = false, Color = Color3.fromRGB(0, 255, 127), Visible = false})
    local Outline = CreateDraw("Square", {Thickness = 3, Filled = false, Color = Color3.fromRGB(0, 0, 0), Visible = false})
    local Name = CreateDraw("Text", {Size = 13, Center = true, Outline = true, Color = Color3.fromRGB(255, 255, 255), Visible = false})
    local HealthBar = CreateDraw("Square", {Thickness = 1, Filled = true, Visible = false})
    local Tracer = CreateDraw("Line", {Thickness = 1, Color = Color3.fromRGB(0, 255, 127), Visible = false})
    
    local Skeletons = {
        HeadToTorso = CreateDraw("Line", {Thickness = 1, Color = Color3.fromRGB(255, 255, 255), Visible = false}),
        TorsoToLarm = CreateDraw("Line", {Thickness = 1, Color = Color3.fromRGB(255, 255, 255), Visible = false}),
        TorsoToRarm = CreateDraw("Line", {Thickness = 1, Color = Color3.fromRGB(255, 255, 255), Visible = false}),
        TorsoToLleg = CreateDraw("Line", {Thickness = 1, Color = Color3.fromRGB(255, 255, 255), Visible = false}),
        TorsoToRleg = CreateDraw("Line", {Thickness = 1, Color = Color3.fromRGB(255, 255, 255), Visible = false})
    }

    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not p or not p.Parent or not p.Character or not p.Character:FindFirstChild("HumanoidRootPart") then
            Box:Remove()
            Outline:Remove()
            Name:Remove()
            HealthBar:Remove()
            Tracer:Remove()
            for _, line in pairs(Skeletons) do line:Remove() end
            connection:Disconnect()
            return
        end
        
        local hrp = p.Character.HumanoidRootPart
        local humanoid = p.Character.Humanoid
        local head = p.Character.Head
        local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        
        -- Default: Gizle
        Box.Visible = false
        Outline.Visible = false
        Name.Visible = false
        HealthBar.Visible = false
        Tracer.Visible = false
        for _, line in pairs(Skeletons) do line:Visible = false end

        if onScreen then
            local headPos = Camera:WorldToViewportPoint(head.Position)
            local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
            
            local height = (headPos.Y - legPos.Y)
            local width = height * 0.6 -- En Boy Oranı
            
            -- Box ESP
            if Settings.ESP.Boxes then
                Box.Size = Vector2.new(width, height)
                Box.Position = Vector2.new(pos.X - width/2, pos.Y - height/2)
                Box.Visible = true
                
                Outline.Size = Box.Size
                Outline.Position = Box.Position
                Outline.Visible = true
            end
            
            -- Name ESP
            if Settings.ESP.Names then
                Name.Text = p.Name
                Name.Position = Vector2.new(pos.X, (pos.Y - height/2) - 15)
                Name.Visible = true
            end
            
            -- Health ESP
            if Settings.ESP.Health then
                local healthPercent = humanoid.Health / humanoid.MaxHealth
                local healthBarHeight = height * healthPercent
                local healthBarPos = (pos.Y - height/2) + (height - healthBarHeight)
                
                HealthBar.Size = Vector2.new(2, healthBarHeight)
                HealthBar.Position = Vector2.new(pos.X - (width/2) - 5, healthBarPos)
                HealthBar.Color = Color3.fromHSV(healthPercent * 0.33, 1, 1) -- Yeşilden Kırmızıya
                HealthBar.Visible = true
            end
            
            -- Tracer ESP
            if Settings.ESP.Tracer then
                Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y) -- Ekranın altı
                Tracer.To = Vector2.new(pos.X, pos.Y)
                Tracer.Visible = true
            end
            
            -- Skeleton ESP (Sadece R15 için optimize edildi)
            if Settings.ESP.Skeletons and p.Character:FindFirstChild("UpperTorso") then
                local limbs = {
                    H = head.Position,
                    T = p.Character.UpperTorso.Position,
                    LA = p.Character.LeftUpperArm.Position,
                    RA = p.Character.RightUpperArm.Position,
                    LL = p.Character.LeftUpperLeg.Position,
                    RL = p.Character.RightUpperLeg.Position
                }
                
                local function WorldToViewport(pos)
                    local w, o = Camera:WorldToViewportPoint(pos)
                    return Vector2.new(w.X, w.Y), o
                end
                
                local h, _ = WorldToViewport(limbs.H)
                local t, _ = WorldToViewport(limbs.T)
                local la, _ = WorldToViewport(limbs.LA)
                local ra, _ = WorldToViewport(limbs.RA)
                local ll, _ = WorldToViewport(limbs.LL)
                local rl, _ = WorldToViewport(limbs.RL)
                
                Skeletons.HeadToTorso.From, Skeletons.HeadToTorso.To = h, t
                Skeletons.TorsoToLarm.From, Skeletons.TorsoToLarm.To = t, la
                Skeletons.TorsoToRarm.From, Skeletons.TorsoToRarm.To = t, ra
                Skeletons.TorsoToLleg.From, Skeletons.TorsoToLleg.To = t, ll
                Skeletons.TorsoToRleg.From, Skeletons.TorsoToRleg.To = t, rl
                
                for _, line in pairs(Skeletons) do line.Visible = true end
            end
        end
    end)
end

-- Players.PlayerAdded:Connect(HandleESP)
for _, player in pairs(Players:GetPlayers()) do
    HandleESP(player)
end

-- Players.PlayerAdded:Connect(HandleESP)

-- Players.PlayerAdded:Connect(HandleESP) -- Players.PlayerAdded:Connect(HandleESP)

-- players.PlayerAdded:Connect(HandleESP) -- players.PlayerAdded:Connect(HandleESP)

-- players.PlayerAdded:Connect(HandleESP) -- players.PlayerAdded:Connect(HandleESP)

-- == MENU TASARIMI == --
local Main = Window:NewTab("Main")
local Section = Main:NewSection("ttniscript | Apex Edition")

Section:NewToggle("Hard Aimlock (Sağ Tık)", "Sadece kafaya kilitlenir. Görüyorsanız affetmez.", function(state)
    Settings.Aimbot = state
end)

Section:NewToggle("Duvar Kontrolü (Görüş)", "Duvar arkasındaki adamlara kilitlenmez. Tavsiye edilir.", function(state)
    Settings.WallCheck = state
end)

Section:NewSlider("Smoothness (Yumuşaklık)", "1 = Anında Kilitlenir, 0.1 = Yavaş Kayar.", 100, 10, function(s)
    Settings.AimbotSmoothness = s / 100
end)

local Visuals = Window:NewTab("Visuals")
local SectionESP = Visuals:NewSection("ESP Settings")

SectionESP:NewToggle("Box ESP", "Rakipleri kutu içine alır.", function(state)
    Settings.ESP.Boxes = state
end)

SectionESP:NewToggle("İsim ESP", "Oyuncu isimlerini gösterir.", function(state)
    Settings.ESP.Names = state
end)

SectionESP:NewToggle("Can Barı ESP", "Rakiplerin can durumunu gösterir.", function(state)
    Settings.ESP.Health = state
end)

SectionESP:NewToggle("İskelet ESP", "Rakiplerin iskelet yapısını gösterir (R15).", function(state)
    Settings.ESP.Skeletons = state
end)

SectionESP:NewToggle("Tracer (Çizgi) ESP", "Ekranın altından rakiplere çizgi çeker.", function(state)
    Settings.ESP.Tracer = state
end)

-- == ANA DÖNGÜ == --
RunService.RenderStepped:Connect(function()
    if Settings.Aimbot and UserInputService:IsMouseButtonPressed(Settings.AimbotKey) then
        local target = GetTarget()
        if target then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), Settings.AimbotSmoothness)
        end
    end
end)

print("ttniscript: Apex Edition Yüklendi! Yapımcı: ttni131")
