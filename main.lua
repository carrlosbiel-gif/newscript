local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Settings = {
    ESP = {
        Enabled = false,
        TeamCheck = false,
    },
    Aimbot = {
        Enabled = false,
        TeamCheck = false,
        FOV = 150,
        ShowFOV = false,
        TargetPart = "Head",
        MaxDistance = 500 
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

-- Função de Atualizar ESP
local function UpdateESP(Player, Objects)
    local Char = Player.Character
    local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
    local Root = Char and Char:FindFirstChild("HumanoidRootPart")

    if not Settings.ESP.Enabled or not Root or not Hum or Hum.Health <= 0 then
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

-- Busca de Alvo
local function GetClosestPlayer()
    local Target = nil
    local ShortestDist = Settings.Aimbot.FOV
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild(Settings.Aimbot.TargetPart) and Player.Character:FindFirstChild("HumanoidRootPart") then
            local Part = Player.Character[Settings.Aimbot.TargetPart]
            local Root = Player.Character.HumanoidRootPart
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
    return Target
end

-- INTERFACE TOTALMENTE TRANSPARENTE
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 350, 0, 560)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -280)
MainFrame.BackgroundTransparency = 1 -- FUNDO 100% TRANSPARENTE (TOTALMENTE INVISÍVEL)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "BIELZINN HUB | CLT V3"
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundTransparency = 0.5 -- Título levemente visível para você achar o menu
Title.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Title.Font = Enum.Font.GothamBold
Title.ZIndex = 2
Instance.new("UICorner", Title)

local Content = Instance.new("Frame", MainFrame)
Content.Size = UDim2.new(1, 0, 1, -60)
Content.Position = UDim2.new(0, 0, 0, 60)
Content.BackgroundTransparency = 1
Content.ZIndex = 2

-- FUNÇÃO PARA BOTÕES TRANSPARENTES
local function NewBtn(txt, pos, color)
    local b = Instance.new("TextButton", Content)
    b.Size = UDim2.new(0, 310, 0, 35)
    b.Position = pos
    b.Text = txt
    b.BackgroundColor3 = color
    b.BackgroundTransparency = 0.5 -- BOTÕES TAMBÉM MEIO TRANSPARENTES
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold
    b.ZIndex = 3
    Instance.new("UICorner", b)
    return b
end

local AimBtn = NewBtn("Aimbot: OFF", UDim2.new(0, 20, 0, 0), Color3.fromRGB(0, 0, 0))
local TargetBtn = NewBtn("Alvo: CABEÇA", UDim2.new(0, 20, 0, 40), Color3.fromRGB(0, 0, 0))
local EspBtn = NewBtn("ESP: OFF", UDim2.new(0, 20, 0, 80), Color3.fromRGB(0, 0, 0))
local FovVisBtn = NewBtn("Ver Círculo: OFF", UDim2.new(0, 20, 0, 120), Color3.fromRGB(0, 0, 0))

local DisplayFov = Instance.new("TextLabel", Content)
DisplayFov.Size = UDim2.new(0, 310, 0, 25)
DisplayFov.Position = UDim2.new(0, 20, 0, 160)
DisplayFov.Text = "TAMANHO FOV: " .. Settings.Aimbot.FOV
DisplayFov.TextColor3 = Color3.fromRGB(255, 255, 255)
DisplayFov.BackgroundTransparency = 1
DisplayFov.Font = Enum.Font.GothamBold
DisplayFov.ZIndex = 3

local MenosFov = NewBtn("FOV -10", UDim2.new(0, 20, 0, 190), Color3.fromRGB(150, 0, 0))
MenosFov.Size = UDim2.new(0, 150, 0, 30)
local MaisFov = NewBtn("FOV +10", UDim2.new(0, 180, 0, 190), Color3.fromRGB(0, 100, 200))
MaisFov.Size = UDim2.new(0, 150, 0, 30)

local DisplayDist = Instance.new("TextLabel", Content)
DisplayDist.Size = UDim2.new(0, 310, 0, 25)
DisplayDist.Position = UDim2.new(0, 20, 0, 230)
DisplayDist.Text = "ALCANCE AIM: " .. Settings.Aimbot.MaxDistance .. "m"
DisplayDist.TextColor3 = Color3.fromRGB(255, 255, 0)
DisplayDist.BackgroundTransparency = 1
DisplayDist.Font = Enum.Font.GothamBold
DisplayDist.ZIndex = 3

local MenosDist = NewBtn("ALCANCE -50m", UDim2.new(0, 20, 0, 260), Color3.fromRGB(150, 0, 0))
MenosDist.Size = UDim2.new(0, 150, 0, 30)
local MaisDist = NewBtn("ALCANCE +50m", UDim2.new(0, 180, 0, 260), Color3.fromRGB(0, 100, 200))
MaisDist.Size = UDim2.new(0, 150, 0, 30)

-- Lógica Minimizar
local minimizado = false
Title.MouseButton1Click:Connect(function() -- Clique no título para minimizar
    minimizado = not minimizado
    MainFrame:TweenSize(minimizado and UDim2.new(0, 350, 0, 40) or UDim2.new(0, 350, 0, 560), "Out", "Quad", 0.3, true)
    Content.Visible = not minimizado
end)

-- Eventos
AimBtn.MouseButton1Click:Connect(function()
    Settings.Aimbot.Enabled = not Settings.Aimbot.Enabled
    AimBtn.Text = "Aimbot: " .. (Settings.Aimbot.Enabled and "ON" or "OFF")
    AimBtn.BackgroundColor3 = Settings.Aimbot.Enabled and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(0, 0, 0)
end)

TargetBtn.MouseButton1Click:Connect(function()
    Settings.Aimbot.TargetPart = (Settings.Aimbot.TargetPart ==
