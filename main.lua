local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Configurações
local Settings = {
    ESP = {
        Enabled = false,
        TeamCheck = true, -- NOVO: Ignora aliados no ESP
        BoxColor = Color3.fromRGB(255, 0, 0),
        SnaplineEnabled = false,
        Rainbow = false
    },
    Aimbot = {
        Enabled = false,
        TeamCheck = false, -- NOVO: Ignora aliados na Mira
        FOV = 100,
        MaxDistance = 500,
        ShowFOV = false,
        TargetPart = "Head"
    }
}

local ESP_Table = {}

-- Função para criar os desenhos do ESP
local function CreateESP(Player)
    if Player == LocalPlayer then return end
    
    local Objects = {
        Box = Drawing.new("Square"),
        Distance = Drawing.new("Text"),
        Snapline = Drawing.new("Line")
    }
    
    -- Configuração inicial
    Objects.Box.Thickness = 2
    Objects.Box.Filled = false
    Objects.Distance.Size = 16
    Objects.Distance.Center = true
    Objects.Distance.Outline = true
    
    ESP_Table[Player] = Objects
end

-- Função que desenha o ESP na tela
local function UpdateESP(Player, Objects)
    local Char = Player.Character
    local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
    local Root = Char and Char:FindFirstChild("HumanoidRootPart")

    -- Verifica se deve mostrar (Team Check aqui)
    if not Settings.ESP.Enabled or not Root or not Hum or Hum.Health <= 0 then
        for _, obj in pairs(Objects) do obj.Visible = false end
        return
    end

    if Settings.ESP.TeamCheck and Player.Team == LocalPlayer.Team then
        for _, obj in pairs(Objects) do obj.Visible = false end
        return
    end

    local Pos, OnScreen = Camera:WorldToViewportPoint(Root.Position)
    
    if OnScreen then
        local Dist = (Camera.CFrame.Position - Root.Position).Magnitude
        local Scale = 1000 / Dist
        
        -- Desenhar Quadrado
        Objects.Box.Size = Vector2.new(Scale, Scale * 1.5)
        Objects.Box.Position = Vector2.new(Pos.X - Scale/2, Pos.Y - Scale/0.75)
        Objects.Box.Color = Settings.ESP.BoxColor
        Objects.Box.Visible = true

        -- Distância
        Objects.Distance.Text = math.floor(Dist) .. "m"
        Objects.Distance.Position = Vector2.new(Pos.X, Objects.Box.Position.Y + Objects.Box.Size.Y + 5)
        Objects.Distance.Color = Color3.new(1,1,1)
        Objects.Distance.Visible = true

        -- Snapline
        if Settings.ESP.SnaplineEnabled then
            Objects.Snapline.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
            Objects.Snapline.To = Vector2.new(Pos.X, Pos.Y)
            Objects.Snapline.Color = Settings.ESP.BoxColor
            Objects.Snapline.Visible = true
        else
            Objects.Snapline.Visible = false
        end
    else
        for _, obj in pairs(Objects) do obj.Visible = false end
    end
end

-- Lógica do Aimbot com Team Check
local function GetClosestPlayer()
    local Target = nil
    local ShortestDist = Settings.Aimbot.FOV

    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild(Settings.Aimbot.TargetPart) then
            
            -- TEAM CHECK AQUI
            if Settings.Aimbot.TeamCheck and Player.Team == LocalPlayer.Team then 
                continue 
            end

            local Part = Player.Character[Settings.Aimbot.TargetPart]
            local Pos, OnScreen = Camera:WorldToViewportPoint(Part.Position)
            
            if OnScreen then
                local MousePos = UserInputService:GetMouseLocation()
                local Dist = (Vector2.new(Pos.X, Pos.Y) - MousePos).Magnitude
                
                if Dist < ShortestDist then
                    local Raycast = Ray.new(Camera.CFrame.Position, (Part.Position - Camera.CFrame.Position).Unit * 500)
                    local Hit = workspace:FindPartOnRay(Raycast, LocalPlayer.Character)
                    
                    if Hit and Hit:IsDescendantOf(Player.Character) then
                        ShortestDist = Dist
                        Target = Player
                    end
                end
            end
        end
    end
    return Target
end

-- Interface Visual (Melhorada)
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 350, 0, 250)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local Corner = Instance.new("UICorner", MainFrame)
Corner.CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "BIELZIN V1 | TEAM CHECK ON"
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16

-- Botão Aimbot
local AimBtn = Instance.new("TextButton", MainFrame)
AimBtn.Size = UDim2.new(0, 140, 0, 40)
AimBtn.Position = UDim2.new(0, 20, 0, 60)
AimBtn.Text = "Aimbot: OFF"
AimBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
AimBtn.TextColor3 = Color3.new(1,1,1)
AimBtn.Font = Enum.Font.Gotham

AimBtn.MouseButton1Click:Connect(function()
    Settings.Aimbot.Enabled = not Settings.Aimbot.Enabled
    AimBtn.Text = "Aimbot: " .. (Settings.Aimbot.Enabled and "ON" or "OFF")
    AimBtn.BackgroundColor3 = Settings.Aimbot.Enabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(45, 45, 45)
end)

-- Botão ESP
local EspBtn = Instance.new("TextButton", MainFrame)
EspBtn.Size = UDim2.new(0, 140, 0, 40)
EspBtn.Position = UDim2.new(0, 190, 0, 60)
EspBtn.Text = "ESP: OFF"
EspBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
EspBtn.TextColor3 = Color3.new(1,1,1)
EspBtn.Font = Enum.Font.Gotham

EspBtn.MouseButton1Click:Connect(function()
    Settings.ESP.Enabled = not Settings.ESP.Enabled
    EspBtn.Text = "ESP: " .. (Settings.ESP.Enabled and "ON" or "OFF")
    EspBtn.BackgroundColor3 = Settings.ESP.Enabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(45, 45, 45)
end)

-- Loop Principal
RunService.RenderStepped:Connect(function()
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

-- Gerenciar entrada e saída de players
for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(function(p)
    if ESP_Table[p] then
        for _, obj in pairs(ESP_Table[p]) do obj:Remove() end
        ESP_Table[p] = nil
    end
end)

print("Script carregado com sucesso! Shift Direito para fechar o menu.")
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)
