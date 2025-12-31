--[[ 
    BIELZINN V2:
    - Wall Check (Não gruda através de paredes)
    - Botões para mudar tamanho do FOV (+/-)
    - Team Check e ESP inclusos
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Configurações
local Settings = {
    ESP = {
        Enabled = false,
        TeamCheck = false,
        BoxColor = Color3.fromRGB(255, 0, 0),
    },
    Aimbot = {
        Enabled = false,
        TeamCheck = false,
        FOV = 150,
        ShowFOV = false,
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

-- Função de Wall Check (Verifica se há paredes no caminho)
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
    
    if Result then
        return Result.Instance:IsDescendantOf(TargetPart.Parent)
    end
    return false
end

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
                    -- AQUI ENTRA O WALL CHECK
                    if IsVisible(Part) then
                        ShortestDist = Dist
                        Target = Player
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
MainFrame.Size = UDim2.new(0, 350, 0, 320)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "BIELZINN V2 | WALL CHECK"
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16

-- Botões de Aimbot, ESP e Show FOV (Organizados)
local function CreateButton(text, pos, callback)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0, 310, 0, 35)
    btn.Position = pos
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.Gotham
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local AimBtn = CreateButton("Aimbot: OFF", UDim2.new(0, 20, 0, 50), function()
    Settings.Aimbot.Enabled = not Settings.Aimbot.Enabled
    _G.AimBtn.Text = "Aimbot: " .. (Settings.Aimbot.Enabled and "ON" or "OFF")
    _G.AimBtn.BackgroundColor3 = Settings.Aimbot.Enabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(45, 45, 45)
end)
_G.AimBtn = AimBtn

local EspBtn = CreateButton("ESP: OFF", UDim2.new(0, 20, 0, 95), function()
    Settings.ESP.Enabled = not Settings.ESP.Enabled
    _G.EspBtn.Text = "ESP: " .. (Settings.ESP.Enabled and "ON" or "OFF")
    _G.EspBtn.BackgroundColor3 = Settings.ESP.Enabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(45, 45, 45)
end)
_G.EspBtn = EspBtn

local FovBtn = CreateButton("Show FOV: OFF", UDim2.new(0, 20, 0, 140), function()
    Settings.Aimbot.ShowFOV = not Settings.Aimbot.ShowFOV
    FOVCircle.Visible = Settings.Aimbot.ShowFOV
    _G.FovBtn.Text = "Show FOV: " .. (Settings.Aimbot.ShowFOV and "ON" or "OFF")
    _G.FovBtn.BackgroundColor3 = Settings.Aimbot.ShowFOV and Color3.fromRGB(0, 150, 150) or Color3.fromRGB(45, 45, 45)
end)
_G.FovBtn = FovBtn

-- CONTROLE DE TAMANHO DO FOV
local FovLabel = Instance.new("TextLabel", MainFrame)
FovLabel.Size = UDim2.new(0, 310, 0, 30)
FovLabel.Position = UDim2.new(0, 20, 0, 190)
FovLabel.Text = "FOV Size: " .. Settings.Aimbot.FOV
FovLabel.TextColor3 = Color3.new(1,1,1)
FovLabel.BackgroundTransparency = 1
FovLabel.Font = Enum.Font.Gotham

local MinusBtn = Instance.new("TextButton", MainFrame)
MinusBtn.Size = UDim2.new(0, 150, 0, 35)
MinusBtn.Position = UDim2.new(0, 20, 0, 225)
MinusBtn.Text = "FOV -10"
MinusBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
MinusBtn.TextColor3 = Color3.new(1,1,1)

local PlusBtn = Instance.new("TextButton", MainFrame)
PlusBtn.Size = UDim2.new(0, 150, 0, 35)
PlusBtn.Position = UDim2.new(0, 180, 0, 225)
PlusBtn.Text = "FOV +10"
PlusBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
PlusBtn.TextColor3 = Color3.new(1,1,1)

MinusBtn.MouseButton1Click:Connect(function()
    Settings.Aimbot.FOV = math.max(10, Settings.Aimbot.FOV - 10)
    FovLabel.Text = "FOV Size: " .. Settings.Aimbot.FOV
end)

PlusBtn.MouseButton1Click:Connect(function()
    Settings.Aimbot.FOV = math.min(800, Settings.Aimbot.FOV + 10)
    FovLabel.Text = "FOV Size: " .. Settings.Aimbot.FOV
end)

-- Loop Principal
RunService.RenderStepped:Connect(function()
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

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)
