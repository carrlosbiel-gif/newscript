--[[ 
    SCRIPT ATUALIZADO:
    - Adicionado Círculo de FOV (Show FOV)
    - Botão na Interface para controlar o FOV
    - Team Check Otimizado
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Configurações
local Settings = {
    ESP = {
        Enabled = false,
        TeamCheck = false,
        BoxColor = Color3.fromRGB(255, 0, 0),
        SnaplineEnabled = false,
    },
    Aimbot = {
        Enabled = false,
        TeamCheck = false,
        FOV = 150, -- Tamanho do círculo
        MaxDistance = 500,
        ShowFOV = false, -- Controlado pelo botão
        TargetPart = "Head"
    }
}

-- Criando o Círculo do FOV
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 100
FOVCircle.Radius = Settings.Aimbot.FOV
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.Color = Color3.fromRGB(255, 255, 255)

local ESP_Table = {}

local function CreateESP(Player)
    if Player == LocalPlayer then return end
    local Objects = {
        Box = Drawing.new("Square"),
        Distance = Drawing.new("Text"),
        Snapline = Drawing.new("Line")
    }
    Objects.Box.Thickness = 2
    Objects.Box.Filled = false
    Objects.Distance.Size = 16
    Objects.Distance.Center = true
    Objects.Distance.Outline = true
    ESP_Table[Player] = Objects
end

local function UpdateESP(Player, Objects)
    local Char = Player.Character
    local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
    local Root = Char and Char:FindFirstChild("HumanoidRootPart")

    if not Settings.ESP.Enabled or not Root or not Hum or Hum.Health <= 0 then
        for _, obj in pairs(Objects) do obj.Visible = false end
        return
    end

    if Settings.ESP.TeamCheck and Player.Team == LocalPlayer.Team then
        for _, obj in pairs(Objects) do obj.Visible = false end
        return
    end

    local Pos, OnScreen = Camera:WorldToViewportPoint(Root.Position)
    if OnScreen then
        local Dist = (Camera.CFrame.Position - Root.Position).Magnitude
        local Scale = 1000 / Dist
        Objects.Box.Size = Vector2.new(Scale, Scale * 1.5)
        Objects.Box.Position = Vector2.new(Pos.X - Scale/2, Pos.Y - Scale/0.75)
        Objects.Box.Color = Settings.ESP.BoxColor
        Objects.Box.Visible = true
        Objects.Distance.Text = math.floor(Dist) .. "m"
        Objects.Distance.Position = Vector2.new(Pos.X, Objects.Box.Position.Y + Objects.Box.Size.Y + 5)
        Objects.Distance.Visible = true
    else
        for _, obj in pairs(Objects) do obj.Visible = false end
    end
end

local function GetClosestPlayer()
    local Target = nil
    local ShortestDist = Settings.Aimbot.FOV

    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild(Settings.Aimbot.TargetPart) then
            if Settings.Aimbot.TeamCheck and Player.Team == LocalPlayer.Team then continue end

            local Part = Player.Character[Settings.Aimbot.TargetPart]
            local Pos, OnScreen = Camera:WorldToViewportPoint(Part.Position)
            
            if OnScreen then
                local MousePos = UserInputService:GetMouseLocation()
                local Dist = (Vector2.new(Pos.X, Pos.Y) - MousePos).Magnitude
                
                if Dist < ShortestDist then
                    ShortestDist = Dist
                    Target = Player
                end
            end
        end
    end
    return Target
end

-- INTERFACE
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 350, 0, 300) -- Aumentei um pouco a altura
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "BIELZINN V1 | FOV SYSTEM"
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16

-- Botão Aimbot
local AimBtn = Instance.new("TextButton", MainFrame)
AimBtn.Size = UDim2.new(0, 310, 0, 40)
AimBtn.Position = UDim2.new(0, 20, 0, 60)
AimBtn.Text = "Aimbot: OFF"
AimBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
AimBtn.TextColor3 = Color3.new(1,1,1)
AimBtn.Font = Enum.Font.Gotham
AimBtn.MouseButton1Click:Connect(function()
    Settings.Aimbot.Enabled = not Settings.Aimbot.Enabled
    AimBtn.Text = "Aimbot: " .. (Settings.Aimbot.Enabled and "ON" or "OFF")
    AimBtn.BackgroundColor3 = Settings.Aimbot.Enabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(45, 45, 45)
end)

-- Botão ESP
local EspBtn = Instance.new("TextButton", MainFrame)
EspBtn.Size = UDim2.new(0, 310, 0, 40)
EspBtn.Position = UDim2.new(0, 20, 0, 110)
EspBtn.Text = "ESP: OFF"
EspBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
EspBtn.TextColor3 = Color3.new(1,1,1)
EspBtn.Font = Enum.Font.Gotham
EspBtn.MouseButton1Click:Connect(function()
    Settings.ESP.Enabled = not Settings.ESP.Enabled
    EspBtn.Text = "ESP: " .. (Settings.ESP.Enabled and "ON" or "OFF")
    EspBtn.BackgroundColor3 = Settings.ESP.Enabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(45, 45, 45)
end)

-- Botão Show FOV (NOVO)
local FovBtn = Instance.new("TextButton", MainFrame)
FovBtn.Size = UDim2.new(0, 310, 0, 40)
FovBtn.Position = UDim2.new(0, 20, 0, 160)
FovBtn.Text = "Show FOV: OFF"
FovBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
FovBtn.TextColor3 = Color3.new(1,1,1)
FovBtn.Font = Enum.Font.Gotham
FovBtn.MouseButton1Click:Connect(function()
    Settings.Aimbot.ShowFOV = not Settings.Aimbot.ShowFOV
    FOVCircle.Visible = Settings.Aimbot.ShowFOV
    FovBtn.Text = "Show FOV: " .. (Settings.Aimbot.ShowFOV and "ON" or "OFF")
    FovBtn.BackgroundColor3 = Settings.Aimbot.ShowFOV and Color3.fromRGB(0, 150, 150) or Color3.fromRGB(45, 45, 45)
end)

-- Loop Principal
RunService.RenderStepped:Connect(function()
    -- Atualiza posição e raio do círculo
    if Settings.Aimbot.ShowFOV then
        FOVCircle.Radius = Settings.Aimbot.FOV
        FOVCircle.Position = UserInputService:GetMouseLocation()
    end

    if Settings.Aimbot.Enabled then
        local Target = GetClosestPlayer()
        if Target and Target.Character and Target.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, Target.Character.Head.Position)
        end
    end
    
    for Player, Objects in pairs(ESP_Table) do
        UpdateESP(Player, Objects)
    end
end)

for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(function(p)
    if ESP_Table[p] then
        for _, obj in pairs(ESP_Table[p]) do obj:Remove() end
        ESP_Table[p] = nil
    end
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)
