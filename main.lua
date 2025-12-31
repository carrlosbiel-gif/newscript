--[[ 
    BIELZINN V2.1:
    - INDICADOR DE TAMANHO DE FOV ATUALIZADO
    - WALL CHECK INTEGRADO
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Settings = {
    ESP = { Enabled = false, TeamCheck = false, BoxColor = Color3.fromRGB(255, 0, 0) },
    Aimbot = { Enabled = false, TeamCheck = false, FOV = 150, ShowFOV = false, TargetPart = "Head" }
}

-- Círculo do FOV
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 100
FOVCircle.Radius = Settings.Aimbot.FOV
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.Color = Color3.fromRGB(255, 255, 255)

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
MainFrame.Size = UDim2.new(0, 350, 0, 350)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 45)
Title.Text = "BIELZINN HUB | STATUS"
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Instance.new("UICorner", Title)

-- Botões Principais
local function NewBtn(txt, pos, color)
    local b = Instance.new("TextButton", MainFrame)
    b.Size = UDim2.new(0, 310, 0, 40)
    b.Position = pos
    b.Text = txt
    b.BackgroundColor3 = color
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.Gotham
    Instance.new("UICorner", b)
    return b
end

local AimBtn = NewBtn("Aimbot: OFF", UDim2.new(0, 20, 0, 60), Color3.fromRGB(40, 40, 40))
local FovVisBtn = NewBtn("Ver Círculo: OFF", UDim2.new(0, 20, 0, 110), Color3.fromRGB(40, 40, 40))

-- SEÇÃO DE TAMANHO DO FOV (O QUE VOCÊ PEDIU)
local DisplayFov = Instance.new("TextLabel", MainFrame)
DisplayFov.Size = UDim2.new(0, 310, 0, 30)
DisplayFov.Position = UDim2.new(0, 20, 0, 170)
DisplayFov.Text = "TAMANHO DO FOV: " .. Settings.Aimbot.FOV
DisplayFov.TextColor3 = Color3.fromRGB(0, 255, 255) -- Cor Ciano para destacar
DisplayFov.BackgroundTransparency = 1
DisplayFov.Font = Enum.Font.GothamBold
DisplayFov.TextSize = 16

local Menos = NewBtn("DIMINUIR FOV (-10)", UDim2.new(0, 20, 0, 210), Color3.fromRGB(150, 50, 50))
Menos.Size = UDim2.new(0, 150, 0, 40)

local Mais = NewBtn("AUMENTAR FOV (+10)", UDim2.new(0, 180, 0, 210), Color3.fromRGB(50, 100, 150))
Mais.Size = UDim2.new(0, 150, 0, 40)

-- Eventos
AimBtn.MouseButton1Click:Connect(function()
    Settings.Aimbot.Enabled = not Settings.Aimbot.Enabled
    AimBtn.Text = "Aimbot: " .. (Settings.Aimbot.Enabled and "ON" or "OFF")
    AimBtn.BackgroundColor3 = Settings.Aimbot.Enabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(40, 40, 40)
end)

FovVisBtn.MouseButton1Click:Connect(function()
    Settings.Aimbot.ShowFOV = not Settings.Aimbot.ShowFOV
    FOVCircle.Visible = Settings.Aimbot.ShowFOV
    FovVisBtn.Text = "Ver Círculo: " .. (Settings.Aimbot.ShowFOV and "ON" or "OFF")
end)

Mais.MouseButton1Click:Connect(function()
    Settings.Aimbot.FOV = Settings.Aimbot.FOV + 10
    DisplayFov.Text = "TAMANHO DO FOV: " .. Settings.Aimbot.FOV
end)

Menos.MouseButton1Click:Connect(function()
    if Settings.Aimbot.FOV > 10 then
        Settings.Aimbot.FOV = Settings.Aimbot.FOV - 10
        DisplayFov.Text = "TAMANHO DO FOV: " .. Settings.Aimbot.FOV
    end
end)

-- Loop
RunService.RenderStepped:Connect(function()
    if Settings.Aimbot.ShowFOV then
        FOVCircle.Radius = Settings.Aimbot.FOV
        FOVCircle.Position = UserInputService:GetMouseLocation()
    end
    if Settings.Aimbot.Enabled then
        local T = GetClosestPlayer()
        if T then Camera.CFrame = CFrame.new(Camera.CFrame.Position, T.Character.Head.Position) end
    end
end)

UserInputService.InputBegan:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.RightShift then MainFrame.Visible = not MainFrame.Visible end
end)
