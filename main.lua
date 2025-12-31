local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "BIELZINN HUB | CLT V3",
   LoadingTitle = "Iniciando Sistema...",
   LoadingSubtitle = "by Gemini",
   ConfigurationSaving = { Enabled = false }
})

-- Serviços e Variáveis
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Settings = {
    ESP = { Enabled = false, MaxDistance = 500 },
    Aimbot = { Enabled = false, FOV = 150, ShowFOV = false, TargetPart = "Head", MaxDistance = 500 }
}

-- Círculo do FOV
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 100
FOVCircle.Radius = Settings.Aimbot.FOV
FOVCircle.Visible = false
FOVCircle.Color = Color3.fromRGB(255, 255, 255)

local ESP_Table = {}

-- Funções Auxiliares
local function IsVisible(TargetPart)
    local Character = LocalPlayer.Character
    if not Character then return false end
    local RayParams = RaycastParams.new()
    RayParams.FilterDescendantsInstances = {Character, Camera}
    RayParams.FilterType = Enum.RaycastFilterType.Exclude
    local Result = workspace:Raycast(Camera.CFrame.Position, (TargetPart.Position - Camera.CFrame.Position).Unit * (TargetPart.Position - Camera.CFrame.Position).Magnitude, RayParams)
    return Result == nil or Result.Instance:IsDescendantOf(TargetPart.Parent)
end

local function GetClosestPlayer()
    local Target = nil
    local ShortestDist = Settings.Aimbot.FOV
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild(Settings.Aimbot.TargetPart) then
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

-- Lógica do ESP
local function CreateESP(Player)
    if Player == LocalPlayer then return end
    local Objects = { Box = Drawing.new("Square"), Distance = Drawing.new("Text") }
    Objects.Box.Thickness = 1
    Objects.Distance.Size = 14
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

    local Dist = (Camera.CFrame.Position - Root.Position).Magnitude
    if Dist > Settings.ESP.MaxDistance then
        for _, obj in pairs(Objects) do obj.Visible = false end
        return
    end

    local Pos, OnScreen = Camera:WorldToViewportPoint(Root.Position)
    if OnScreen then
        local Scale = 1000 / Dist
        Objects.Box.Size = Vector2.new(Scale, Scale * 1.5)
        Objects.Box.Position = Vector2.new(Pos.X - Scale/2, Pos.Y - Scale/0.75)
        Objects.Box.Color = Color3.fromHSV(math.clamp(Hum.Health/100, 0, 0.3), 1, 1)
        Objects.Box.Visible = true
        
        Objects.Distance.Text = math.floor(Dist) .. "m"
        Objects.Distance.Position = Vector2.new(Pos.X, Objects.Box.Position.Y + Objects.Box.Size.Y + 2)
        Objects.Distance.Visible = true
    else
        for _, obj in pairs(Objects) do obj.Visible = false end
    end
end

-- Interface Rayfield
local CombatTab = Window:CreateTab("Combate", 4483362458)
local VisualTab = Window:CreateTab("Visuais", 4483362458)

CombatTab:CreateSection("Aimbot")

CombatTab:CreateToggle({
   Name = "Ativar Aimbot",
   CurrentValue = false,
   Callback = function(Value) Settings.Aimbot.Enabled = Value end,
})

CombatTab:CreateDropdown({
   Name = "Alvo",
   Options = {"Head", "HumanoidRootPart"},
   CurrentOption = {"Head"},
   Callback = function(Option) Settings.Aimbot.TargetPart = Option[1] end,
})

CombatTab:CreateSlider({
   Name = "Tamanho do FOV",
   Range = {0, 500},
   Increment = 10,
   CurrentValue = 150,
   Callback = function(Value) 
      Settings.Aimbot.FOV = Value 
      FOVCircle.Radius = Value
   end,
})

CombatTab:CreateToggle({
   Name = "Ver Círculo",
   CurrentValue = false,
   Callback = function(Value) 
      Settings.Aimbot.ShowFOV = Value 
      FOVCircle.Visible = Value
   end,
})

CombatTab:CreateSlider({
   Name = "Alcance do Aim (Metros)",
   Range = {0, 2000},
   Increment = 50,
   CurrentValue = 500,
   Callback = function(Value) Settings.Aimbot.MaxDistance = Value end,
})

VisualTab:CreateSection("ESP")

VisualTab:CreateToggle({
   Name = "Ativar ESP",
   CurrentValue = false,
   Callback = function(Value) Settings.ESP.Enabled = Value end,
})

VisualTab:CreateSlider({
   Name = "Distância Máxima ESP",
   Range = {0, 3000},
   Increment = 100,
   CurrentValue = 500,
   Callback = function(Value) Settings.ESP.MaxDistance = Value end,
})

-- Loops de Renderização
RunService.RenderStepped:Connect(function()
    if Settings.Aimbot.ShowFOV then
        FOVCircle.Position = UserInputService:GetMouseLocation()
    end
    
    if Settings.Aimbot.Enabled then
        local T = GetClosestPlayer()
        if T then
            -- MIRA INSTANTÂNEA + ERRO ALEATÓRIO PARA SEGURANÇA
            local TargetPos = T.Character[Settings.Aimbot.TargetPart].Position
            local RandomOffset = Vector3.new(math.random(-1,1)/10, math.random(-1,1)/10, math.random(-1,1)/10)
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, TargetPos + RandomOffset)
        end
    end

    for Player, Objects in pairs(ESP_Table) do
        UpdateESP(Player, Objects)
    end
end)

for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)

Rayfield:Notify({
   Title = "Sistema Ativo",
   Content = "Use Right Shift para abrir/fechar o menu.",
   Duration = 5,
   Image = 4483362458,
})
