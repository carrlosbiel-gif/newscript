-- Adicione o Smoothing nas configurações
Settings.Aimbot.Smoothing = 0.2 -- Quanto menor, mais suave/lento

-- Busca de Alvo MELHORADA
local function GetClosestPlayer()
    local Target = nil
    local ShortestDist = Settings.Aimbot.FOV
    
    local MyChar = LocalPlayer.Character
    local MyRoot = MyChar and MyChar:FindFirstChild("HumanoidRootPart")
    
    if not MyRoot then return nil end -- Segurança

    for _, Player in pairs(Players:GetPlayers()) do
        -- Verifica se não é você, se está no outro time e se tem personagem
        if Player ~= LocalPlayer and (not Settings.Aimbot.TeamCheck or Player.Team ~= LocalPlayer.Team) then
            local Char = Player.Character
            local Root = Char and Char:FindFirstChild("HumanoidRootPart")
            local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
            local Part = Char and Char:FindFirstChild(Settings.Aimbot.TargetPart)
            
            if Root and Part and Hum and Hum.Health > 0 then
                local RealDist = (MyRoot.Position - Root.Position).Magnitude
                
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

-- Loop de Renderização Suave
RunService.RenderStepped:Connect(function()
    -- Círculo segue o mouse
    if Settings.Aimbot.ShowFOV then
        FOVCircle.Visible = true
        FOVCircle.Radius = Settings.Aimbot.FOV
        FOVCircle.Position = UserInputService:GetMouseLocation()
    else
        FOVCircle.Visible = false
    end

    -- Aimbot com Suavização (Lerp)
    if Settings.Aimbot.Enabled then
        local T = GetClosestPlayer()
        if T then 
            local TargetPos = T.Character[Settings.Aimbot.TargetPart].Position
            local AimData = CFrame.new(Camera.CFrame.Position, TargetPos)
            -- O segredo do Smoothing está aqui:
            Camera.CFrame = Camera.CFrame:Lerp(AimData, Settings.Aimbot.Smoothing)
        end
    end

    -- ESP (Otimizado)
    for Player, Objects in pairs(ESP_Table) do
        UpdateESP(Player, Objects)
    end
end)
