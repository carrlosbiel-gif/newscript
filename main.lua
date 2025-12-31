local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Settings = {
    ESP = {
        Enabled = false,
        TeamCheck = true,
    },
    Aimbot = {
        Enabled = false,
        TeamCheck = true,
        FOV = 150,
        ShowFOV = false,
        TargetPart = "Head",
        MaxDistance = 500,
        Smoothing = 0.15 -- VALOR DE SUAVIZAÇÃO (0.01 a 1.0)
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

-- Função para verificar se é inimigo
local function IsEnemy(Player)
    if not Settings.Aimbot.TeamCheck then return true end
    return Player.Team ~= LocalPlayer.Team
end

-- Função Wall Check
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

    if not Settings.ESP.Enabled or not Root or not Hum or Hum.Health <= 0 or (Settings.ESP.TeamCheck and not IsEnemy(Player)) then
        for _, obj in pairs(Objects) do obj.Visible = false end
        return
    end

    local Dist = (Camera.CFrame.Position - Root.Position).Magnitude
    if Dist > 500 then
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

-- Busca de Alvo Otimizada
local function GetClosestPlayer()
    local Target = nil
    local ShortestDist = Settings.Aimbot.FOV
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and IsEnemy(Player) and Player.Character and Player.Character:FindFirstChild(Settings.Aimbot.TargetPart) then
            local Part = Player.Character[Settings.Aimbot.TargetPart]
            local Root = Player.Character:FindFirstChild("HumanoidRootPart")
            if Root then
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
MainFrame.Size = UDim2.new(0, 350, 0, 620) -- Ajustado para nova função
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -310)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame)

local Content = Instance.new("Frame", MainFrame)
Content.Size = UDim2.new(1, 0, 1, -60)
Content.Position = UDim2.new(0, 0, 0, 60)
Content.BackgroundTransparency = 1

local function NewBtn(txt, pos, color)
    local b = Instance.new("TextButton", Content)
    b.Size = UDim2.new(0, 310, 0, 35)
    b.Position = pos
    b.Text = txt
    b.BackgroundColor3 = color
    b.BackgroundTransparency = 0.2
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold
    Instance.new("UICorner", b)
    return b
end

local AimBtn = NewBtn("Aimbot: OFF", UDim2.new(0, 20, 0, 0), Color3.fromRGB(30, 30, 30))
local TeamBtn = NewBtn("Team Check: ON", UDim2.new(0, 20, 0, 40), Color3.fromRGB(0, 100, 100))
local TargetBtn = NewBtn("Alvo: CABEÇA", UDim2.new(0, 20, 0, 80), Color3.fromRGB(30, 30, 30))
local EspBtn = NewBtn("ESP: OFF", UDim2.new(0, 20, 0, 120), Color3.fromRGB(30, 30, 30))
local FovVisBtn = NewBtn("Ver Círculo: OFF", UDim2.new(0, 20, 0, 160), Color3.fromRGB(30, 30, 30))

-- CONTROLE DE SMOOTHING (SUAVIZAÇÃO)
local DisplaySmooth = Instance.new("TextLabel", Content)
DisplaySmooth.Size = UDim2.new(0, 310, 0, 25)
DisplaySmooth.Position = UDim2.new(0, 20, 0, 205)
DisplaySmooth.Text = "SUAVIZAÇÃO: " .. math.floor(Settings.Aimbot.Smoothing * 100) .. "%"
DisplaySmooth.TextColor3 = Color3.fromRGB(200, 200, 255)
DisplaySmooth.BackgroundTransparency = 1
DisplaySmooth.Font = Enum.Font.GothamBold

local MenosSmooth = NewBtn("MIRA RÁPIDA", UDim2.new(0, 20, 0, 235), Color3.fromRGB(100, 50, 150))
MenosSmooth.Size = UDim2.new(0, 150, 0, 30)
local MaisSmooth = NewBtn("MIRA SUAVE", UDim2.new(0, 180, 0, 235), Color3.fromRGB(50, 150, 150))
MaisSmooth.Size = UDim2.new(0, 150, 0, 30)

-- [BOTÕES DE FOV E DISTÂNCIA SEGUEM ABAIXO...]
local DisplayFov = Instance.new("TextLabel", Content)
DisplayFov.Size = UDim2.new(0, 310, 0, 25)
DisplayFov.Position = UDim2.new(0, 20, 0, 280)
DisplayFov.Text = "TAMANHO FOV: " .. Settings.Aimbot.FOV
DisplayFov.
