local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- IDENTIFICA O MELHOR LOCAL PARA A UI
local ParentUI = (gethui and gethui()) or (game:GetService("CoreGui"):FindFirstChild("RobloxGui") and game:GetService("CoreGui")) or LocalPlayer:WaitForChild("PlayerGui")

-- LIMPA VERSÕES ANTIGAS PARA NÃO ACUMULAR
if ParentUI:FindFirstChild("BielzinnHub_CLTV3") then
    ParentUI:FindFirstChild("BielzinnHub_CLTV3"):Destroy()
end

local Settings = {
    ESP = { Enabled = false, TeamCheck = true },
    Aimbot = {
        Enabled = false,
        TeamCheck = true,
        FOV = 150,
        ShowFOV = false,
        TargetPart = "Head",
        MaxDistance = 500,
        Smoothing = 0.15 -- Mira suave
    }
}

-- BIBLIOTECA DE DESENHO (FOV)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 100
FOVCircle.Radius = Settings.Aimbot.FOV
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.Color = Color3.fromRGB(255, 255, 255)

local ESP_Table = {}

-- FUNÇÕES TÉCNICAS
local function IsEnemy(Player)
    if not Settings.Aimbot.TeamCheck then return true end
    return Player.Team ~= LocalPlayer.Team
end

local function IsVisible(TargetPart)
    local Character = LocalPlayer.Character
    if not Character then return false end
    local RayParams = RaycastParams.new()
    RayParams.FilterDescendantsInstances = {Character, Camera}
    RayParams.FilterType = Enum.RaycastFilterType.Exclude
    local Result = workspace:Raycast(Camera.CFrame.Position, (TargetPart.Position - Camera.CFrame.Position), RayParams)
    return Result == nil or Result.Instance:IsDescendantOf(TargetPart.Parent)
end

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

-- INTERFACE PRINCIPAL
local ScreenGui = Instance.new("ScreenGui", ParentUI)
ScreenGui.Name = "BielzinnHub_CLTV3"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 350, 0, 520)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -260)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "BIELZINN HUB | CLT V3"
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Title.Font = Enum.Font.GothamBold
Instance.new("UICorner", Title)

local Content = Instance.new("Frame", MainFrame)
Content.Size = UDim2.new(1, 0, 1, -50)
Content.Position = UDim2.new(0, 0, 0, 50)
Content.BackgroundTransparency = 1

local TargetStatus = Instance.new("TextLabel", Content)
TargetStatus.Size = UDim2.new(0, 310, 0, 35)
TargetStatus.Position = UDim2.new(0, 20, 0, 10)
TargetStatus.Text = "BUSCANDO INIMIGOS..."
TargetStatus.TextColor3 = Color3.fromRGB(255, 255, 255)
TargetStatus.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TargetStatus.BackgroundTransparency = 0.5
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

-- BOTOES
local AimBtn = NewBtn("Aimbot: OFF", UDim2.new(0, 20, 0, 55), Color3.fromRGB(35, 35, 35))
local TeamBtn = NewBtn("Team Check: ON", UDim2.new(0, 20, 0, 100), Color3.fromRGB(0, 100, 100))
local TargetBtn = NewBtn("Alvo: CABEÇA", UDim2.new(0, 20, 0, 145), Color3.fromRGB(35, 35, 35))
local EspBtn = NewBtn("ESP: OFF", UDim2.new(0, 20, 0, 190), Color3.fromRGB(35, 35, 35))
local FovBtn = NewBtn("Ver FOV: OFF", UDim2.new(0, 20, 0, 235), Color3.fromRGB(35, 35, 35))

-- CONTROLES DE ALCANCE
local DistLabel = NewBtn("ALCANCE: " .. Settings.Aimbot.MaxDistance .. "m", UDim2.new(0, 20, 0, 285), Color3.fromRGB(20, 20, 20))
local MenosDist = NewBtn("-50m", UDim2.new(0, 20, 0, 325), Color3.fromRGB(120, 40, 40))
MenosDist.Size = UDim2.new(0, 150, 0, 30)
local MaisDist = NewBtn("+50m", UDim2.new(0, 180, 0, 325), Color3.fromRGB(40, 120, 40))
MaisDist.Size = UDim2.new(0, 150, 0, 30)

-- LOGICA DOS BOTOES
AimBtn.MouseButton1Click:Connect(function()
    Settings.Aimbot.Enabled = not Settings.Aimbot.Enabled
    AimBtn.Text = "Aimbot: " .. (Settings.Aimbot.Enabled and "ON" or "OFF")
    AimBtn.BackgroundColor3 = Settings.Aimbot.Enabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(35, 35, 35)
end)

TeamBtn.MouseButton1Click:Connect(function()
    Settings.Aimbot.TeamCheck = not Settings.Aimbot.TeamCheck
    Settings.ESP.TeamCheck = Settings.Aimbot.TeamCheck
    TeamBtn.Text = "Team Check: " .. (Settings.Aimbot.TeamCheck and "ON" or "OFF")
    TeamBtn.BackgroundColor3 = Settings.Aimbot.TeamCheck and Color3.fromRGB(0, 100, 100) or Color3.fromRGB(150, 0, 0)
end)

TargetBtn.MouseButton1Click:Connect(function()
    Settings.Aimbot.TargetPart = (Settings.Aimbot.TargetPart == "Head" and "HumanoidRootPart" or "Head")
    TargetBtn.Text = "Alvo: " .. (Settings.Aimbot.TargetPart == "Head" and "CABEÇA" or "PEITO")
end)

EspBtn.MouseButton1Click:Connect(function()
    Settings.ESP.Enabled = not Settings.ESP.Enabled
    EspBtn.Text = "ESP: " .. (Settings.ESP.Enabled and "ON" or "OFF")
    EspBtn.BackgroundColor3 = Settings.ESP.Enabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(35, 35, 35)
end)

FovBtn.MouseButton1Click:Connect(function()
    Settings.Aimbot.ShowFOV = not Settings.Aimbot.ShowFOV
    FovBtn.Text = "Ver FOV: " .. (Settings.Aimbot.ShowFOV and "ON" or "OFF")
end)

MaisDist.MouseButton1Click:Connect(function() Settings.Aimbot.MaxDistance += 50 DistLabel.Text = "ALCANCE: " .. Settings.Aimbot.MaxDistance .. "m" end)
MenosDist.MouseButton1Click:Connect(function() if Settings.Aimbot.MaxDistance > 50 then Settings.Aimbot.MaxDistance -= 50 DistLabel.Text = "ALCANCE: " .. Settings.Aimbot.MaxDistance .. "m" end end)

-- LOOP DE RENDERIZAÇÃO
RunService.RenderStepped:Connect(function()
    if Settings.Aimbot.ShowFOV then
        FOVCircle.Visible = true
        FOVCircle.Radius = Settings.Aimbot.FOV
        FOVCircle.Position = UserInputService:GetMouseLocation()
    else
        FOVCircle.Visible = false
    end
    
    local T = GetClosestPlayer()
    if T then
        local d = (LocalPlayer.Character.HumanoidRootPart.Position - T.Character.HumanoidRootPart.Position).Magnitude
        TargetStatus.Text = "ALVO: " .. T.Name:upper() .. " [" .. math.floor(d) .. "m]"
        if Settings.Aimbot.Enabled then
            local NewLook = CFrame.new(Camera.CFrame.Position, T.Character[Settings.Aimbot.TargetPart].Position)
            Camera.CFrame = Camera.CFrame:Lerp(NewLook, Settings.Aimbot.Smoothing)
        end
    else
        TargetStatus.Text = "BUSCANDO INIMIGOS..."
    end
end)

-- Abre/Fecha com RightShift
UserInputService.InputBegan:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.RightShift then MainFrame.Visible = not MainFrame.Visible end
end)
