local Plrs = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LP = Plrs.LocalPlayer
local Cam = workspace.CurrentCamera

-- Configurações com proteção de suavização
local Config = {
    Aimbot = {
        Enabled = false,
        FOV = 150,
        Smoothness = 0.15, -- [NOVO] Quanto menor, mais suave/seguro
        TargetPart = "Head",
        MaxDistance = 500,
        VisibleCheck = true
    },
    ESP = {
        Enabled = false
    }
}

local CircleFOV = Drawing.new("Circle")
CircleFOV.Thickness = 1
CircleFOV.NumSides = 100
CircleFOV.Radius = Config.Aimbot.FOV
CircleFOV.Visible = false
CircleFOV.Color = Color3.fromRGB(255, 255, 255)

-- Função Wall Check (Otimizada)
local function CheckVisibility(Part)
    local Char = LP.Character
    if not Char then return false end
    local RayParams = RaycastParams.new()
    RayParams.FilterDescendantsInstances = {Char, Cam}
    RayParams.FilterType = Enum.RaycastFilterType.Exclude
    local Result = workspace:Raycast(Cam.CFrame.Position, (Part.Position - Cam.CFrame.Position).Unit * 1000, RayParams)
    return Result == nil or Result.Instance:IsDescendantOf(Part.Parent)
end

-- Lógica de busca de alvo com suavização (Lerp)
local function GetTarget()
    local Target = nil
    local Closest = Config.Aimbot.FOV
    local MousePos = UIS:GetMouseLocation()

    for _, v in pairs(Plrs:GetPlayers()) do
        if v ~= LP and v.Character and v.Character:FindFirstChild(Config.Aimbot.TargetPart) then
            local Part = v.Character[Config.Aimbot.TargetPart]
            local ScreenPos, OnScreen = Cam:WorldToViewportPoint(Part.Position)
            
            if OnScreen then
                local Dist = (Vector2.new(ScreenPos.X, ScreenPos.Y) - MousePos).Magnitude
                if Dist < Closest and CheckVisibility(Part) then
                    Closest = Dist
                    Target = Part
                end
            end
        end
    end
    return Target
end

-- Loop de Renderização (Aqui acontece a mágica indetectável)
RS.RenderStepped:Connect(function()
    CircleFOV.Position = UIS:GetMouseLocation()
    CircleFOV.Radius = Config.Aimbot.FOV
    
    if Config.Aimbot.Enabled then
        local Alvo = GetTarget()
        if Alvo then
            -- [SUAVIZAÇÃO] Em vez de travar instantâneo, a mira "desliza" até o alvo
            local LookAt = CFrame.new(Cam.CFrame.Position, Alvo.Position)
            Cam.CFrame = Cam.CFrame:Lerp(LookAt, Config.Aimbot.Smoothness)
        end
    end
end)

--- [INTERFACE SIMPLIFICADA] ---
-- (Mantive a estrutura básica para não dar erro, mas adicionei a trava de segurança)

local Main = Instance.new("ScreenGui", game:GetService("CoreGui"))
local Frame = Instance.new("Frame", Main)
Frame.Size = UDim2.new(0, 200, 0, 150)
Frame.Position = UDim2.new(0.5, -100, 0.5, -75)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Active = true
Frame.Draggable = true

local BtnAim = Instance.new("TextButton", Frame)
BtnAim.Size = UDim2.new(1, -20, 0, 40)
BtnAim.Position = UDim2.new(0, 10, 0, 10)
BtnAim.Text = "AIMBOT: OFF"
BtnAim.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
BtnAim.TextColor3 = Color3.new(1,1,1)

BtnAim.MouseButton1Click:Connect(function()
    Config.Aimbot.Enabled = not Config.Aimbot.Enabled
    BtnAim.Text = "AIMBOT: " .. (Config.Aimbot.Enabled and "ON" or "OFF")
    BtnAim.BackgroundColor3 = Config.Aimbot.Enabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
end)

local LabelWarning = Instance.new("TextLabel", Frame)
LabelWarning.Size = UDim2.new(1, 0, 0, 30)
LabelWarning.Position = UDim2.new(0, 0, 1, -30)
LabelWarning.Text = "MODO SUAVE ATIVADO"
LabelWarning.TextColor3 = Color3.new(1, 0.8, 0)
LabelWarning.BackgroundTransparency = 1
