local Plrs = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LP = Plrs.LocalPlayer
local Cam = workspace.CurrentCamera

local SecureConfig = {
    Aimbot = {
        Active = false,
        FOV = 150,
        Smooth = 0.12, 
        Part = "Head",
        Dist = 500,
        WallCheck = true,
        IgnoreTeam = true -- [NOVO] Ignorar aliados ativado
    },
    Visuals = {
        BoxEnabled = false,
        SecureColor = Color3.fromRGB(0, 255, 120),
        EnemyColor = Color3.fromRGB(255, 50, 50) -- Cor para inimigos
    }
}

-- [RAIO DE VISIBILIDADE]
local function IsBehindWall(TargetPart)
    local Character = LP.Character
    if not Character then return true end
    local Origin = Cam.CFrame.Position
    local Destination = TargetPart.Position
    local Direction = (Destination - Origin).Unit * (Destination - Origin).Magnitude
    local RayParams = RaycastParams.new()
    RayParams.FilterDescendantsInstances = {Character, Cam}
    RayParams.FilterType = Enum.RaycastFilterType.Exclude
    local Result = workspace:Raycast(Origin, Direction, RayParams)
    
    if Result == nil then return false end
    if Result.Instance:IsDescendantOf(TargetPart.Parent) then return false end
    return true
end

local FOV_Ring = Drawing.new("Circle")
FOV_Ring.Visible = false
FOV_Ring.Thickness = 1
FOV_Ring.Radius = SecureConfig.Aimbot.FOV
FOV_Ring.Color = Color3.new(1, 1, 1)

local Cache_ESP = {}

local function CreateSecureBox(P)
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = SecureConfig.Visuals.SecureColor
    Box.Thickness = 1
    Box.Filled = false
    Cache_ESP[P] = Box
end

-- [ATUALIZAÇÃO VISUAL COM TEAM CHECK]
local function UpdateVisuals()
    for p, box in pairs(Cache_ESP) do
        -- Verifica se o jogador deve ser mostrado (Ignora se for aliado e o check estiver ligado)
        local isAlly = (p.Team == LP.Team and p.Team ~= nil)
        
        if SecureConfig.Visuals.BoxEnabled and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if SecureConfig.Aimbot.IgnoreTeam and isAlly then
                box.Visible = false
            else
                local Root = p.Character.HumanoidRootPart
                local Pos, OnScreen = Cam:WorldToViewportPoint(Root.Position)
                
                if OnScreen then
                    local Dist = (Cam.CFrame.Position - Root.Position).Magnitude
                    if Dist < SecureConfig.Aimbot.Dist then
                        local Size = 1000 / Dist
                        box.Size = Vector2.new(Size, Size * 1.5)
                        box.Position = Vector2.new(Pos.X - Size/2, Pos.Y - Size/1.5)
                        box.Color = isAlly and SecureConfig.Visuals.SecureColor or SecureConfig.Visuals.EnemyColor
                        box.Visible = true
                    else box.Visible = false end
                else box.Visible = false end
            end
        else box.Visible = false end
    end
end

-- [BUSCA DE ALVO COM TEAM CHECK]
local function GetClosestTarget()
    local t = nil
    local sd = SecureConfig.Aimbot.FOV
    for _, v in pairs(Plrs:GetPlayers()) do
        if v ~= LP and v.Character and v.Character:FindFirstChild(SecureConfig.Aimbot.Part) then
            
            -- VERIFICA SE É ALIADO
            local isAlly = (v.Team == LP.Team and v.Team ~= nil)
            
            -- Só mira se NÃO for aliado (ou se o TeamCheck estiver desligado)
            if not (SecureConfig.Aimbot.IgnoreTeam and isAlly) then
                local P = v.Character[SecureConfig.Aimbot.Part]
                if not IsBehindWall(P) then
                    local Pos, OnScreen = Cam:WorldToViewportPoint(P.Position)
                    if OnScreen then
                        local m = (Vector2.new(Pos.X, Pos.Y) - UIS:GetMouseLocation()).Magnitude
                        if m < sd then
                            sd = m
                            t = P
                        end
                    end
                end
            end
        end
    end
    return t
end

RS.RenderStepped:Connect(function()
    UpdateVisuals()
    FOV_Ring.Position = UIS:GetMouseLocation()
    if SecureConfig.Aimbot.Active then
        local Alvo = GetClosestTarget()
        if Alvo then
            local Look = CFrame.new(Cam.CFrame.Position, Alvo.Position)
            Cam.CFrame = Cam.CFrame:Lerp(Look, SecureConfig.Aimbot.Smooth)
        end
    end
end)

for _, p in pairs(Plrs:GetPlayers()) do if p ~= LP then CreateSecureBox(p) end end
Plrs.PlayerAdded:Connect(CreateSecureBox)

--- [ INTERFACE ] ---
local UI = Instance.new("ScreenGui", game:GetService("CoreGui"))
local F = Instance.new("Frame", UI)
F.Size = UDim2.new(0, 180, 0, 140)
F.Position = UDim2.new(0.05, 0, 0.4, 0)
F.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
F.Active = true
F.Draggable = true
Instance.new("UICorner", F)

local function AddBtn(txt, pos, callback)
    local b = Instance.new("TextButton", F)
    b.Size = UDim2.new(1, -20, 0, 35)
    b.Position = pos
    b.Text = txt
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    b.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() callback(b) end)
end

AddBtn("AIMBOT: OFF", UDim2.new(0, 10, 0, 10), function(b)
    SecureConfig.Aimbot.Active = not SecureConfig.Aimbot.Active
    b.Text = "AIMBOT: " .. (SecureConfig.Aimbot.Active and "ON" or "OFF")
    b.BackgroundColor3 = SecureConfig.Aimbot.Active and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(40, 40, 40)
end)

AddBtn("ESP BOX: OFF", UDim2.new(0, 10, 0, 50), function(b)
    SecureConfig.Visuals.BoxEnabled = not SecureConfig.Visuals.BoxEnabled
    b.Text = "ESP BOX: " .. (SecureConfig.Visuals.BoxEnabled and "ON" or "OFF")
    b.BackgroundColor3 = SecureConfig.Visuals.BoxEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(40, 40, 40)
end)

AddBtn("TEAM CHECK: ON", UDim2.new(0, 10, 0, 90), function(b)
    SecureConfig.Aimbot.IgnoreTeam = not SecureConfig.Aimbot.IgnoreTeam
    b.Text = "TEAM CHECK: " .. (SecureConfig.Aimbot.IgnoreTeam and "ON" or "OFF")
    b.BackgroundColor3 = SecureConfig.Aimbot.IgnoreTeam and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(40, 40, 40)
end)
