-- Limpar UIs antigas para evitar sobreposição
local oldUI = game:GetService("CoreGui"):FindFirstChild("BielzinnHubV4") or game:GetService("Players").LocalPlayer:FindFirstChild("BielzinnHubV4", true)
if oldUI then oldUI:Destroy() end

local _P = game:GetService("Players")
local _R = game:GetService("RunService")
local _U = game:GetService("UserInputService")
local _L = _P.LocalPlayer
local _C = workspace.CurrentCamera

local _DATA = {
    ESP = { Enabled = false, MaxDist = 500 },
    Aimbot = {
        Enabled = false,
        FOV = 150,
        ShowFOV = false,
        TargetPart = "Head",
        MaxDistance = 500,
        Smoothness = 0.15,
        Jitter = 0.35,
        IsAiming = false
    }
}

-- [DESENHO DO FOV]
local _FOV_CIRC = Drawing.new("Circle")
_FOV_CIRC.Thickness = 1
_FOV_CIRC.NumSides = 60
_FOV_CIRC.Radius = _DATA.Aimbot.FOV
_FOV_CIRC.Visible = false
_FOV_CIRC.Color = Color3.fromRGB(255, 255, 255)

local _E_TBL = {}

-- [DETECÇÃO DE CONTROLE ROBUSTA]
_U.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.ButtonL2 then _DATA.Aimbot.IsAiming = true end
end)
_U.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.ButtonL2 then _DATA.Aimbot.IsAiming = false end
end)

-- [BOX ESP]
local function CreateESP(Player)
    if _E_TBL[Player] then return end
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = Color3.fromRGB(255, 0, 0)
    Box.Thickness = 1
    Box.Filled = false
    _E_TBL[Player] = Box
end

-- [WALL CHECK]
local function _RAY_CH(_T_PRT)
    if not _L.Character then return false end
    local _RP = RaycastParams.new()
    _RP.FilterDescendantsInstances = {_L.Character, _C}
    _RP.FilterType = Enum.RaycastFilterType.Exclude
    local _RE = workspace:Raycast(_C.CFrame.Position, (_T_PRT.Position - _C.CFrame.Position).Unit * 1000, _RP)
    return _RE == nil or _RE.Instance:IsDescendantOf(_T_PRT.Parent)
end

-- [BUSCA DE ALVO]
local function _GET_TARGET()
    local _T = nil
    local _SD = _DATA.Aimbot.FOV
    local _CENTER = Vector2.new(_C.ViewportSize.X / 2, _C.ViewportSize.Y / 2)

    for _, v in pairs(_P:GetPlayers()) do
        if v ~= _L and v.Character and v.Character:FindFirstChild(_DATA.Aimbot.TargetPart) then
            local p = v.Character[_DATA.Aimbot.TargetPart]
            local root = v.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local dist = (_L.Character.HumanoidRootPart.Position - root.Position).Magnitude
                if dist <= _DATA.Aimbot.MaxDistance then
                    local vpos, ons = _C:WorldToViewportPoint(p.Position)
                    if ons then
                        local mag = (Vector2.new(vpos.X, vpos.Y) - _CENTER).Magnitude
                        if mag < _SD and _RAY_CH(p) then
                            _SD = mag
                            _T = p
                        end
                    end
                end
            end
        end
    end
    return _T
end

-- [INTERFACE ADAPTADA PARA EXECUTORES]
local UI = Instance.new("ScreenGui")
UI.Name = "BielzinnHubV4"
-- Tenta CoreGui, se falhar vai para PlayerGui
local success, err = pcall(function() UI.Parent = game:GetService("CoreGui") end)
if not success then UI.Parent = _L:WaitForChild("PlayerGui") end

local Main = Instance.new("Frame", UI)
Main.Size = UDim2.new(0, 300, 0, 400)
Main.Position = UDim2.new(0.5, -150, 0.5, -200)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "BIELZINN HUB | XENO FIX"
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Title.Font = Enum.Font.GothamBold
Instance.new("UICorner", Title)

local function NewBtn(txt, pos, color, callback)
    local b = Instance.new("TextButton", Main)
    b.Size = UDim2.new(1, -40, 0, 35)
    b.Position = pos
    b.Text = txt
    b.BackgroundColor3 = color
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(callback)
    return b
end

local AimBtn = NewBtn("AIMBOT: OFF", UDim2.new(0, 20, 0, 60), Color3.fromRGB(40, 40, 40), function()
    _DATA.Aimbot.Enabled = not _DATA.Aimbot.Enabled
end)

local EspBtn = NewBtn("ESP BOX: OFF", UDim2.new(0, 20, 0, 105), Color3.fromRGB(40, 40, 40), function()
    _DATA.ESP.Enabled = not _DATA.ESP.Enabled
end)

local PartBtn = NewBtn("ALVO: CABEÇA", UDim2.new(0, 20, 0, 150), Color3.fromRGB(40, 40, 40), function()
    _DATA.Aimbot.TargetPart = (_DATA.Aimbot.TargetPart == "Head" and "HumanoidRootPart" or "Head")
end)

-- [LOOP PRINCIPAL]
_R.RenderStepped:Connect(function()
    AimBtn.Text = "AIMBOT: " .. (_DATA.Aimbot.Enabled and "ON" or "OFF")
    AimBtn.BackgroundColor3 = _DATA.Aimbot.Enabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(40, 40, 40)
    EspBtn.Text = "ESP BOX: " .. (_DATA.ESP.Enabled and "ON" or "OFF")
    EspBtn.BackgroundColor3 = _DATA.ESP.Enabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(40, 40, 40)
    PartBtn.Text = "ALVO: " .. (_DATA.Aimbot.TargetPart == "Head" and "CABEÇA" or "PEITO")

    -- Lógica ESP
    for _, p in pairs(_P:GetPlayers()) do
        local box = _E_TBL[p]
        if not box then CreateESP(p) continue end
        if _DATA.ESP.Enabled and p ~= _L and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local root = p.Character.HumanoidRootPart
            local pos, ons = _C:WorldToViewportPoint(root.Position)
            if ons then
                local dist = (_C.CFrame.Position - root.Position).Magnitude
                local size = 1000 / dist
                box.Size = Vector2.new(size, size * 1.5)
                box.Position = Vector2.new(pos.X - size/2, pos.Y - size/1.5)
                box.Visible = true
                box.Color = (p.Team == _L.Team and p.Team ~= nil) and Color3.new(0,1,0) or Color3.new(1,0,0)
            else box.Visible = false end
        else box.Visible = false end
    end

    -- Lógica Aimbot (Só ativa se estiver segurando L2/LT no controle)
    if _DATA.Aimbot.Enabled and _DATA.Aimbot.IsAiming then
        local target = _GET_TARGET()
        if target then
            local jitter = _DATA.Aimbot.Jitter
            local tPos = target.Position + Vector3.new(math.random(-jitter, jitter), math.random(-jitter, jitter), math.random(-jitter, jitter))
            _C.CFrame = _C.CFrame:Lerp(CFrame.new(_C.CFrame.Position, tPos), _DATA.Aimbot.Smoothness)
        end
    end
end)

-- Abrir/Fechar com DPadUp (Seta Cima) ou RightShift
_U.InputBegan:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.DPadUp or i.KeyCode == Enum.KeyCode.RightShift then
        Main.Visible = not Main.Visible
    end
end)
