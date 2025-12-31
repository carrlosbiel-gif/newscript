-- Carregando a Library Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "SYSTEM_OVERLAY_V3 | BIELZINN",
   LoadingTitle = "Carregando Engine...",
   LoadingSubtitle = "Segurança Ativa",
   ConfigurationSaving = {
      Enabled = false
   },
   KeySystem = false
})

-- Variáveis de Configuração (Nomes alterados para segurança)
local Settings = {
    Visuals = { Enabled = false, Range = 500 },
    Assistance = { Enabled = false, FOV = 150, Target = "Head", MaxDist = 500, ShowFOV = false }
}

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Círculo de FOV (Desenho nativo)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 100
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Filled = false
FOVCircle.Visible = false

-- Lógica de Busca de Alvo (Instantânea)
local function GetTarget()
    local BestTarget = nil
    local MaxDistFOV = Settings.Assistance.FOV
    
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild(Settings.Assistance.Target) then
            local Part = Player.Character[Settings.Assistance.Target]
            local Root = Player.Character:FindFirstChild("HumanoidRootPart")
            
            if Root then
                local RealDistance = (LocalPlayer.Character.HumanoidRootPart.Position - Root.Position).Magnitude
                if RealDistance <= Settings.Assistance.MaxDist then
                    local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Part.Position)
                    if OnScreen then
                        local MouseDist = (Vector2.new(ScreenPos.X, ScreenPos.Y) - UserInputService:GetMouseLocation()).Magnitude
                        if MouseDist < MaxDistFOV then
                            MaxDistFOV = MouseDist
                            BestTarget = Part
                        end
                    end
                end
            end
        end
    end
    return BestTarget
end

-- [ TABS DA INTERFACE ]
local MainTab = Window:CreateTab("Combate", 4483362458)
local VisualTab = Window:CreateTab("Visuais", 4483362458)

-- [ SEÇÃO DE COMBATE ]
MainTab:CreateSection("Configurações de Mira")

MainTab:CreateToggle({
   Name = "Ativar Precision Assist (AIM)",
   CurrentValue = false,
   Callback = function(Value)
      Settings.Assistance.Enabled = Value
   end,
})

MainTab:CreateDropdown({
   Name = "Alvo Prioritário",
   Options = {"Head", "HumanoidRootPart"},
   CurrentOption = {"Head"},
   MultipleOptions = false,
   Callback = function(Option)
      Settings.Assistance.Target = Option[1]
   end,
})

MainTab:CreateSlider({
   Name = "Tamanho do FOV",
   Range = {0, 600},
   Increment = 10,
   Suffix = "px",
   CurrentValue = 150,
   Callback = function(Value)
      Settings.Assistance.FOV = Value
      FOVCircle.Radius = Value
   end,
})

MainTab:CreateToggle({
   Name = "Exibir Círculo de FOV",
   CurrentValue = false,
   Callback = function(Value)
      Settings.Assistance.ShowFOV = Value
      FOVCircle.Visible = Value
   end,
})

-- [ SEÇÃO DE VISUAIS ]
VisualTab:CreateSection("Engine de Visualização")

VisualTab:CreateToggle({
   Name = "Ativar Visual Engine (ESP)",
   CurrentValue = false,
   Callback = function(Value)
      Settings.Visuals.Enabled = Value
   end,
})

-- [ LOOP DE EXECUÇÃO ]
RunService.RenderStepped:Connect(function()
    -- Atualiza posição do FOV
    if Settings.Assistance.ShowFOV then
        FOVCircle.Position = UserInputService:GetMouseLocation()
    end

    -- Lógica de Mira (Instantânea + Erro Humano de 0.2 studs)
    if Settings.Assistance.Enabled then
        local Target = GetTarget()
        if Target then
            local RandomError = Vector3.new(math.random(-2,2)/10, math.random(-2,2)/10, math.random(-2,2)/10)
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, Target.Position + RandomError)
        end
    end
end)

Rayfield:Notify({
   Title = "Script Carregado",
   Content = "Use Right Shift para abrir/fechar o menu.",
   Duration = 5,
   Image = 4483362458,
})
