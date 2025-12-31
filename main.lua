local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Settings = {
    Aimbot = {
        Enabled = false,
        TeamCheck = true, -- Mantenha True para testar o novo sistema
        FOV = 200,
        TargetPart = "Head"
    }
}

-- FUNÇÃO AVANÇADA DE TIME (IDENTIFICA ALIADOS DE QUALQUER JEITO)
local function isEnemy(Player)
    if not Settings.Aimbot.TeamCheck then return true end
    
    -- 1. Verifica sistema padrão de times do Roblox
    if Player.Team ~= LocalPlayer.Team then
        return true
    end

    -- 2. Verifica se a cor do Time é diferente (muito usado em jogos de guerra)
    if Player.TeamColor ~= LocalPlayer.TeamColor then
        return true
    end

    -- 3. Caso o jogo não use 'Teams', mas use cores de exibição
    if Player.Neutral == false and Player.Team == nil then
        if Player.TeamColor == LocalPlayer.TeamColor then
            return false
        end
    end

    return false
end

local function GetClosestPlayer()
    local Target = nil
    local ShortestDist = Settings.Aimbot.FOV

    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild(Settings.Aimbot.TargetPart) then
            
            -- USA A NOVA FUNÇÃO DE TIME AQUI
            if not isEnemy(Player) then 
                continue 
            end

            local Hum = Player.Character:FindFirstChildOfClass("Humanoid")
            if not Hum or Hum.Health <= 0 then continue end

            local Part = Player.Character[Settings.Aimbot.TargetPart]
            local Pos, OnScreen = Camera:WorldToViewportPoint(Part.Position)
            
            if OnScreen then
                local MousePos = UserInputService:GetMouseLocation()
                local Dist = (Vector2.new(Pos.X, Pos.Y) - MousePos).Magnitude
                
                if Dist < ShortestDist then
                    ShortestDist = Dist
                    Target = Player
                end
            end
        end
    end
    return Target
end

-- INTERFACE ULTRA SIMPLES PARA TESTE
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local Btn = Instance.new("TextButton", ScreenGui)
Btn.Size = UDim2.new(0, 200, 0, 50)
Btn.Position = UDim2.new(0, 10, 0, 10)
Btn.Text = "AIMBOT: OFF (TEAM CHECK ON)"
Btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Btn.TextColor3 = Color3.new(1,1,1)

Btn.MouseButton1Click:Connect(function()
    Settings.Aimbot.Enabled = not Settings.Aimbot.Enabled
    Btn.Text = "AIMBOT: " .. (Settings.Aimbot.Enabled and "ON" or "OFF")
    Btn.BackgroundColor3 = Settings.Aimbot.Enabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
end)

RunService.RenderStepped:Connect(function()
    if Settings.Aimbot.Enabled then
        local Target = GetClosestPlayer()
        if Target and Target.Character and Target.Character:FindFirstChild(Settings.Aimbot.TargetPart) then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, Target.Character[Settings.Aimbot.TargetPart].Position)
        end
    end
end)
