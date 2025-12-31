local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Settings = {
    ESP = {
        Enabled = false,
        TeamCheck = true, -- Ativado para não poluir a tela com aliados
    },
    Aimbot = {
        Enabled = false,
        TeamCheck = true, -- SÓ GRUDA EM INIMIGOS
        FOV = 150,
        ShowFOV = false,
        TargetPart = "Head",
        MaxDistance = 500,
        Smoothing = 0.15 -- SUAVIZAÇÃO: Evita movimentos instantâneos (Bans)
    }
}

-- Círculo do FOV
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 100
FOVCircle.Radius = Settings.Aimbot.FOV
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.Color = Color3.fromRGB(255, 255, 255)

local ESP_Table = {}

-- Função de Checagem de Time
local function IsEnemy(Player)
    if not Settings.Aimbot.TeamCheck then return true end
    return Player.Team ~= LocalPlayer.Team
end

-- Função Wall Check (Visibilidade)
local function IsVisible(TargetPart)
    local Character = LocalPlayer.Character
    if not Character then return false end
    local Origin = Camera.CFrame.Position
    local Destination = TargetPart.Position
    local Direction = (Destination - Origin).Unit * (Destination - Origin).Magnitude
    local RayParams = RaycastParams.new()
    RayParams.FilterDescendantsInstances = {Character, Camera}
    RayParams.FilterType = Enum.RaycastFilterType.Exclude
    local Result = workspace:Raycast(Origin, Direction, RayParams)
    return Result == nil or Result.Instance:IsDescendantOf(TargetPart.Parent)
end

-- Criar Desenhos do ESP
local function CreateESP(Player)
    if Player == LocalPlayer then return end
    local Objects = {
        Box = Drawing.new("Square"),
        Distance = Drawing.new("Text")
    }
    Objects.Box.Thickness = 2
    Objects.Box.Filled = false
    Objects.Distance.Size = 16
    Objects.Distance.Center = true
    Objects.Distance.Outline = true
    ESP_Table[Player] = Objects
end

-- Atualizar ESP
local function UpdateESP(Player, Objects)
    local Char = Player.Character
    local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
    local Root = Char and Char:FindFirstChild("HumanoidRootPart")

    -- Check de Time + Vida + Distância
    if not Settings.ESP.Enabled or not Root or not Hum or Hum.Health <= 0 or (Settings.ESP.TeamCheck and not IsEnemy(Player)) then
        for _, obj in pairs(Objects) do obj.Visible = false end
        return
    end

    local Dist = (Camera.CFrame.Position - Root.Position).Magnitude
    if Dist > 500 then -- Limite de 500m fixo para o ESP
        for _, obj in pairs(Objects) do obj.Visible = false end
        return
    end

    local Pos, OnScreen = Camera:WorldToViewportPoint(Root.Position)
    if OnScreen then
        local Scale = 1000 / Dist
        local healthPercent = Hum.Health / Hum.MaxHealth
        local dynamicColor = Color3.fromHSV(healthPercent * 0.3, 1, 1) 

        Objects.Box.Size = Vector2.new(Scale, Scale * 1.5)
        Objects.Box.Position = Vector2.new(Pos.X - Scale/2, Pos.Y - Scale/0.75)
        Objects.Box.Color = dynamicColor
        Objects.Box.Visible = true
        
        Objects.Distance.Text = math.floor(Dist) .. "m"
        Objects.Distance.Position = Vector2.new(Pos.X, Objects.Box.Position.Y + Objects.Box.Size.Y + 5)
        Objects.Distance.Visible = true
    else
        for _, obj in pairs(Objects) do obj.Visible = false end
    end
end

-- Busca de Alvo MELHORADA
local function GetClosestPlayer()
    local Target = nil
    local ShortestDist = Settings.Aimbot.FOV
    
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and IsEnemy(Player) and Player.Character then
            local Part = Player.Character:FindFirstChild(Settings.Aimbot.TargetPart)
            local Root = Player.Character:FindFirstChild("HumanoidRootPart")
            local Hum = Player.Character:FindFirstChildOfClass("Humanoid")

            if Part and Root and Hum and Hum.Health > 0 then
                local RealDist = (LocalPlayer.Character.HumanoidRootPart.Position - Root.Position).Magnitude
                if RealDist <= Settings.Aimbot.MaxDistance then
                    local Pos, OnScreen = Camera:WorldToViewportPoint(Part.Position)
                    if OnScreen then
                        local MousePos = UserInputService:GetMouseLocation()
                        local DistFOV = (Vector2.new(Pos.X, Pos.Y) - MousePos).Magnitude
                        if DistFOV < ShortestDist and IsVisible(Part) then
                            ShortestDist = DistFOV
                            Target = Player
                        end
                    end
                end
            end
        end
    end
    return Target
end

-- INTERFACE
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 350, 0, 580)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -290)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame)

local Content = Instance.new("Frame", MainFrame)
Content.Size = UDim2.new(1, 0, 1, -60)
Content.Position = UDim2.new(0, 0, 0, 60)
Content.BackgroundTransparency = 1

-- Mostrador de Status (Adicionado)
local TargetStatus = Instance.new("TextLabel", Content)
TargetStatus.Size = UDim2.new(0, 310, 0, 35)
TargetStatus.Position = UDim2.new(0, 20, 0, 0)
TargetStatus.Text = "AGUARDANDO INIMIGO..."
TargetStatus.TextColor3 = Color3.fromRGB(255, 255, 255)
TargetStatus.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TargetStatus.BackgroundTransparency = 0.6
TargetStatus.Font = Enum.Font.GothamBold
TargetStatus.TextSize = 14
Instance.new("UICorner", TargetStatus)

local function NewBtn(txt, pos, color)
    local b = Instance.new("TextButton", Content)
    b.Size = UDim2.new(0, 310, 0, 35)
    b.Position = pos
    b.Text = txt
    b.BackgroundColor3 = color
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold
    Instance.new("UICorner", b)
    return b
end

local AimBtn = NewBtn("Aimbot: OFF", UDim2.new(0, 20, 0, 45), Color3.fromRGB(30, 30, 30))
local TeamBtn = NewBtn("Team Check: ON", UDim2.new(0, 20, 0, 85), Color3.fromRGB(0, 120, 120))
local TargetBtn = NewBtn("Alvo: CABEÇA", UDim2.new(0, 20, 0, 125), Color3.fromRGB(30, 30, 30))
local EspBtn = NewBtn("ESP: OFF", UDim2.new(0, 20, 0, 165), Color3.fromRGB(30, 30, 30))

-- Controles de FOV e Alcance
local DisplayFov = NewBtn("TAMANHO FOV: " .. Settings.Aimbot.FOV, UDim2.new(0, 20, 0, 210), Color3.fromRGB(20, 20, 20))
local MenosFov = NewBtn("- FOV", UDim2.new(0, 20, 0, 250), Color3.fromRGB(100, 30, 30))
MenosFov.Size = UDim2.new(0, 150, 0, 30)
local MaisFov = NewBtn("+ FOV", UDim2.new(0, 180, 0, 250), Color3.fromRGB(30, 100, 30))
MaisFov.Size = UDim2.new(0, 150, 0, 30)

local DisplayDist = NewBtn("ALCANCE: " .. Settings.Aimbot.MaxDistance .. "m", UDim2.new(0, 20, 0, 290), Color3.fromRGB(20, 20, 20))
local MenosDist = NewBtn("- ALCANCE", UDim2.new(0, 20, 0, 330), Color3.fromRGB(100, 30, 30))
MenosDist.Size = UDim2.new(0, 150, 0, 30)
local MaisDist = NewBtn("+ ALCANCE", UDim2.new(0, 180, 0, 330), Color3.fromRGB(30, 100, 30))
MaisDist.Size = UDim2.new(0, 150, 0, 30)

-- Lógica dos Botões
AimBtn.MouseButton1Click:Connect(function()
    Settings.Aimbot.Enabled = not Settings.Aimbot.Enabled
    AimBtn.Text = "Aimbot: " .. (Settings.Aimbot.Enabled and "ON" or "OFF")
    AimBtn.BackgroundColor3 = Settings.Aimbot.Enabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(30, 30, 30)
end)

TeamBtn.MouseButton1Click:Connect(function()
    Settings.Aimbot.TeamCheck = not Settings.Aimbot.TeamCheck
    Settings.ESP.TeamCheck = Settings.Aimbot.TeamCheck
    TeamBtn.Text = "Team Check: " .. (Settings.Aimbot.TeamCheck and "ON" or "OFF")
    TeamBtn.BackgroundColor3 = Settings.Aimbot.TeamCheck and Color3.fromRGB(0, 120, 120) or Color3.fromRGB(120, 0, 0)
end)

TargetBtn.MouseButton1Click:Connect(function()
    Settings.Aimbot.TargetPart = (Settings.Aimbot.TargetPart == "Head" and "HumanoidRootPart" or "Head")
    Target
