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
        TargetPart = "Head" -- Alterna entre "Head" e "HumanoidRootPart" (Peito)
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

-- Atualizar ESP com Cor Dinâmica por Vida
local function UpdateESP(Player, Objects)
    local Char = Player.Character
    local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
    local Root = Char and Char:FindFirstChild("HumanoidRootPart")

    if not Settings.ESP.Enabled or not Root or not Hum or Hum.Health <= 0 then
        for _, obj in pairs(Objects) do obj.Visible = false end
        return
    end

    local Pos, OnScreen = Camera:WorldToViewportPoint(Root.Position)
    if OnScreen then
        local Dist = (Camera.CFrame.Position - Root.Position).Magnitude
        local Scale = 1000 / Dist
        
        -- Lógica de Cor por Vida (Verde -> Amarelo -> Vermelho)
        local healthPercent = Hum.Health / Hum.MaxHealth
        local dynamicColor = Color3.fromHSV(healthPercent * 0.3, 1, 1) 

        Objects.Box.Size = Vector2.new(Scale, Scale * 1.5)
        Objects.Box.Position = Vector2.new(Pos.X - Scale/2, Pos.Y - Scale/0.75)
        Objects.Box.Color = dynamicColor
        Objects.Box.Visible = true
        
        Objects.Distance.Text = math.floor(Dist) .. "m [" .. math.floor(Hum.Health) .. " HP]"
        Objects.Distance.Position = Vector2.new(Pos.X, Objects.Box.Position.Y + Objects.Box.Size.Y + 5)
        Objects.Distance.Color = dynamicColor
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
        if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild(Settings.Aimbot.TargetPart) then
            local Part = Player.Character[Settings.Aimbot.TargetPart]
            local Pos, OnScreen = Camera:WorldToViewportPoint(Part.Position)
            if OnScreen then
                local MousePos = UserInputService:GetMouseLocation()
                local Dist = (Vector2.new(Pos.X, Pos.Y) - MousePos).Magnitude
                if Dist < ShortestDist and IsVisible(Part) then
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
MainFrame.Size = UDim2.new(0, 350, 0, 480)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame)

local BackgroundImg = Instance.new("ImageLabel", MainFrame)
BackgroundImg.Size = UDim2.new(1, 0, 1, 0)
BackgroundImg.Image = "rbxassetid://13247072551"
BackgroundImg.BackgroundTransparency = 1
BackgroundImg.ScaleType = Enum.ScaleType.Stretch
BackgroundImg.ZIndex = 0
Instance.new("UICorner", BackgroundImg)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "BIELZINN HUB | CLT V3"
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundTransparency = 0.3
Title.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Title.Font = Enum.Font.GothamBold
Title.ZIndex = 2
Instance.new("UICorner", Title)

local MinBtn = Instance.new("TextButton", MainFrame)
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -40, 0, 5)
MinBtn.Text = "_"
MinBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
MinBtn.TextColor3 = Color3.new(1,1,1)
MinBtn.ZIndex = 3
Instance.new("UICorner", MinBtn)

local Content = Instance.new("Frame", MainFrame)
Content.Size = UDim2.new(1, 0, 1, -60)
Content.Position = UDim2.new(0, 0, 0, 60)
Content.BackgroundTransparency = 1
Content.ZIndex = 2

local function NewBtn(txt, pos, color)
    local b = Instance.new("TextButton", Content)
    b.Size = UDim2.new(0, 310, 0, 40)
    b.Position = pos
    b.Text = txt
    b.BackgroundColor3 = color
    b.BackgroundTransparency = 0.2
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold
    b.ZIndex = 3
    Instance.new("UICorner", b)
    return b
end

local AimBtn = NewBtn("Aimbot: OFF", UDim2.new(0, 20, 0, 5), Color3.fromRGB(30, 30, 30))
local TargetBtn = NewBtn("Alvo: CABEÇA", UDim2.new(0, 20, 0, 50), Color3.fromRGB(30, 30, 30)) -- NOVO: Botão Cabeça/Peito
local EspBtn = NewBtn("ESP: OFF", UDim2.new(0, 20, 0, 95), Color3.fromRGB(30, 30, 30))
local FovVisBtn = NewBtn("Ver Círculo: OFF", UDim2.new(0, 20, 0, 140), Color3.fromRGB(30, 30, 30))

local DisplayFov = Instance.new("TextLabel", Content)
DisplayFov.Size = UDim2.new(0, 310, 0, 30)
DisplayFov.Position = UDim2.new(0, 20, 0, 185)
DisplayFov.Text = "FOV: " .. Settings.Aimbot.FOV
DisplayFov.TextColor3 = Color3.fromRGB(255, 255, 255)
DisplayFov.BackgroundTransparency = 1
DisplayFov.Font = Enum.Font.GothamBold
DisplayFov.ZIndex = 3

local Menos = NewBtn("FOV -10", UDim2.new(0, 20, 0, 220), Color3.fromRGB(150, 50, 50))
Menos.Size = UDim2.new(0, 150, 0, 40)
local Mais = NewBtn("FOV +10", UDim2.new(0, 180, 0, 220), Color3.fromRGB(50, 100, 150))
Mais.Size = UDim2.new(0, 150, 0, 40)

-- Lógica Minimizar
local minimizado = false
MinBtn.MouseButton1Click:Connect(function()
    minimizado = not minimizado
    MainFrame:TweenSize(minimizado and UDim2.new(0, 350, 0, 40) or UDim2.new(0, 350, 0, 480), "Out", "Quad", 0.3, true)
    Content.Visible = not minimizado
    BackgroundImg.Visible = not minimizado
    MinBtn.Text = minimizado and "+" or "_"
end)

-- Eventos Botões
AimBtn.MouseButton1Click:Connect(function()
    Settings.Aimbot.Enabled = not Settings.Aimbot.Enabled
    AimBtn.Text = "Aimbot: " .. (Settings.Aimbot.Enabled and "ON" or "OFF")
    AimBtn.BackgroundColor3 = Settings.Aimbot.Enabled and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(30, 30, 30)
end)

TargetBtn.MouseButton1Click:Connect(function()
    if Settings.Aimbot.TargetPart == "Head" then
        Settings.Aimbot.TargetPart = "HumanoidRootPart"
        TargetBtn.Text = "Alvo: PEITO"
    else
        Settings.Aimbot.TargetPart = "Head"
        TargetBtn.Text = "Alvo: CABEÇA"
    end
end)

EspBtn.MouseButton1Click:Connect(function()
    Settings.ESP.Enabled = not Settings.ESP.Enabled
    EspBtn.Text = "ESP: " .. (Settings.ESP.Enabled and "ON" or "OFF")
    EspBtn.BackgroundColor3 = Settings.ESP.Enabled and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(30, 30, 30)
end)

FovVisBtn.MouseButton1Click:Connect(function()
    Settings.Aimbot.ShowFOV = not Settings.Aimbot.ShowFOV
    FOVCircle.Visible = Settings.Aimbot.ShowFOV
    FovVisBtn.Text = "Ver Círculo: " .. (Settings.Aimbot.ShowFOV and "ON" or "OFF")
end)

Mais.MouseButton1Click:Connect(function()
    Settings.Aimbot.FOV = Settings.Aimbot.FOV + 10
    DisplayFov.Text = "FOV: " .. Settings.Aimbot.FOV
end)

Menos.MouseButton1Click:Connect(function()
    if Settings.Aimbot.FOV > 10 then
        Settings.Aimbot.FOV = Settings.Aimbot.FOV - 10
        DisplayFov.Text = "FOV: " .. Settings.Aimbot.FOV
    end
end)

-- Loop Render
RunService.RenderStepped:Connect(function()
    if Settings.Aimbot.ShowFOV then
        FOVCircle.Radius = Settings.Aimbot.FOV
        FOVCircle.Position = UserInputService:GetMouseLocation()
    end
    if Settings.Aimbot.Enabled then
        local T = GetClosestPlayer()
        if T and T.Character and T.Character:FindFirstChild(Settings.Aimbot.TargetPart) then 
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, T.Character[Settings.Aimbot.TargetPart].Position) 
        end
    end
    for Player, Objects in pairs(ESP_Table) do
        UpdateESP(Player, Objects)
    end
end)

for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)

UserInputService.InputBegan:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.RightShift then MainFrame.Visible = not MainFrame.Visible end
end)
