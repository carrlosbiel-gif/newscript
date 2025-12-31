-- [BIELZINN HUB V4 - FAST AIM & HEADSHOT]
local _P = game:GetService("Players")
local _R = game:GetService("RunService")
local _U = game:GetService("UserInputService")
local _L = _P.LocalPlayer
local _C = workspace.CurrentCamera

-- Limpeza de UI antiga
local old = game:GetService("CoreGui"):FindFirstChild("BielzinnHubV4")
if old then old:Destroy() end

local _DATA = {
    ESP = { Enabled = false, MaxDist = 500 },
    Aimbot = {
        Enabled = false,
        FOV = 150,
        ShowFOV = false,
        TargetPart = "Head",
        MaxDistance = 600,
        -- VELOCIDADE DE PUXADA: 0.4 é muito rápido, 0.1 é lento.
        Smoothness = 0.35, 
        IsAiming = false
    }
}

-- [CACHING DE DESENHOS]
local _E_TBL = {}
local _FOV_CIRC = Drawing.new("Circle")
_FOV_CIRC.Thickness = 1
_FOV_CIRC.NumSides = 40
_FOV_CIRC.Radius = _DATA.Aimbot.FOV
_FOV_CIRC.Visible = false
_FOV_CIRC.Color = Color3.new(1,0,0) -- Vermelho para FOV de combate

-- [DETECTOR DE INPUT]
_U.InputBegan:Connect(function(i, p)
    if p then return end
    if i.KeyCode == Enum.KeyCode.ButtonL2 or i.UserInputType == Enum.UserInputType.MouseButton2 then 
        _DATA.Aimbot.IsAiming = true 
    end
end)
_U.InputEnded:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.ButtonL2 or i.UserInputType == Enum.UserInputType.MouseButton2 then 
        _DATA.Aimbot.IsAiming = false 
    end
end)

-- [BOX ESP]
local function CreateESP(Player)
    if _E_TBL[Player] then return end
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Thickness = 1
    _E_TBL[Player] = Box
end

-- [INTERFACE]
local UI = Instance.new("ScreenGui", game:GetService("CoreGui"))
UI.Name = "BielzinnHubV4"

local Main = Instance.new("Frame", UI)
Main.Size = UDim2.new(0, 220, 0, 280)
Main.Position = UDim2.new(0.5, -110, 0.5, -140)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "BIELZINN V4 | AGGRESSIVE"
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundColor3 = Color3.fromRGB(40, 0, 0) -- Cor de alerta (Modo Rápido)
Instance.new("UICorner", Title)

-- Botão Minimizar
local Minimized = false
local MinBtn = Instance.new("TextButton", Main)
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -35, 0, 2)
MinBtn.Text = "-"
MinBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MinBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", MinBtn)

local Container = Instance.new("Frame", Main)
Container.Size = UDim2.new(1, 0, 1, -40)
Container.Position = UDim2.new(0, 0, 0, 40)
Container.BackgroundTransparency = 1

MinBtn.MouseButton1Click:Connect(function()
    Minimized = not Minimized
    Container.Visible = not Minimized
    Main:TweenSize(Minimized and UDim2.new(0, 220, 0, 35) or UDim2.new(0, 220, 0, 280), "Out", "Quad", 0.3, true)
    MinBtn.Text = Minimized and "+" or "-"
end)

local function AddBtn(txt, y, cb)
    local b = Instance.new("TextButton", Container)
    b.Size = UDim2.new(1, -20, 0, 35)
    b.Position = UDim2.new(0, 10, 0, y)
    b.Text = txt
    b.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    b.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() cb(b) end)
end

AddBtn("AIMBOT: OFF", 10, function(b)
    _DATA.Aimbot.Enabled = not _DATA.Aimbot.Enabled
    b.Text = "AIMBOT: " .. (_DATA.Aimbot.Enabled and "ON" or "OFF")
end)

AddBtn("AUMENTAR VELOCIDADE", 50, function(b)
    _DATA.Aimbot.Smoothness = math.min(_DATA.Aimbot.Smoothness + 0.05, 1)
    b.Text = "VELOCIDADE: " .. tostring(math.floor(_DATA.Aimbot.Smoothness * 100)) .. "%"
end)

AddBtn("ESP: OFF", 90, function(b)
    _DATA.ESP.Enabled = not _DATA.ESP.Enabled
    b.Text = "ESP: " .. (_DATA.ESP.Enabled and "ON" or "OFF")
end)

AddBtn("OTIMIZAR FPS", 130, function(b)
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("Part") or v:IsA("MeshPart") then
            v.Material = Enum.Material.SmoothPlastic
        elseif v:IsA("Decal") or v:IsA("Texture") or v:IsA("ParticleEmitter") then
            v:Destroy()
        end
    end
    b.Text = "FPS OTIMIZADO!"
    b.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
end)

-- [LOOP DE ATUALIZAÇÃO]
_R.Heartbeat:Connect(function()
    _FOV_CIRC.Visible = _DATA.Aimbot.ShowFOV
    _FOV_CIRC.Position = _U:GetMouseLocation()

    if _DATA.Aimbot.Enabled and _DATA.Aimbot.IsAiming then
        local target = nil
        local dist = _DATA.Aimbot.FOV
        local screenCenter = Vector2.new(_C.ViewportSize.X/2, _C.ViewportSize.Y/2)

        for _, v in pairs(_P:GetPlayers()) do
            if v ~= _L and v.Character and v.Character:FindFirstChild(_DATA.Aimbot.TargetPart) then
                -- Checa se o inimigo está vivo
                if v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
                    local part = v.Character[_DATA.Aimbot.TargetPart]
                    local p, ons = _C:WorldToViewportPoint(part.Position)
                    local mag = (Vector2.new(p.X, p.Y) - screenCenter).Magnitude
                    
                    if ons and mag < dist then
                        dist = mag
                        target = part
                    end
                end
            end
        end

        if target then
            -- PUXADA AGGRESSIVA: Usa Lerp com Smoothness maior para travar na cabeça
            local goal = CFrame.new(_C.CFrame.Position, target.Position)
            _C.CFrame = _C.CFrame:Lerp(goal, _DATA.Aimbot.Smoothness)
        end
    end

    -- ESP UPDATE
    if _DATA.ESP.Enabled then
        for p, box in pairs(_E_TBL) do
            if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local pos, ons = _C:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                if ons then
                    local d = (_C.CFrame.Position - p.Character.HumanoidRootPart.Position).Magnitude
                    if d < _DATA.ESP.MaxDist then
                        local s = 1000/d
                        box.Size = Vector2.new(s, s*1.5)
                        box.Position = Vector2.new(pos.X-s/2, pos.Y-s/1.5)
                        box.Visible = true
                        box.Color = (p.Team == _L.Team and p.Team ~= nil) and Color3.new(0,1,0) or Color3.new(1,0,0)
                        continue
                    end
                end
            end
            box.Visible = false
        end
    end
end)

_U.InputBegan:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.DPadUp then Main.Visible = not Main.Visible end
end)

for _, p in pairs(_P:GetPlayers()) do CreateESP(p) end
_P.PlayerAdded:Connect(CreateESP)
