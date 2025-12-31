local _P = game:GetService("Players")
local _R = game:GetService("RunService")
local _U = game:GetService("UserInputService")
local _L = _P.LocalPlayer
local _C = workspace.CurrentCamera

local _DATA = {
    ESP = { Enabled = false, TeamCheck = false },
    Aimbot = {
        Enabled = false,
        TeamCheck = false,
        FOV = 150,
        ShowFOV = false,
        TargetPart = "Head",
        MaxDistance = 500,
        Smoothness = 0.15, -- [SUAVIZAÇÃO] 0.1 a 1 (menor é mais suave)
        Jitter = 0.3 -- [RANDOMIZAÇÃO] Variação aleatória do alvo
    }
}

local _FOV_CIRC = Drawing.new("Circle")
_FOV_CIRC.Thickness = 1
_FOV_CIRC.NumSides = 100
_FOV_CIRC.Radius = _DATA.Aimbot.FOV
_FOV_CIRC.Filled = false
_FOV_CIRC.Visible = false
_FOV_CIRC.Color = Color3.fromRGB(255, 255, 255)

local _E_TBL = {}

-- Função de Verificação de Visão camuflada
local function _RAY_CH(_T_PRT)
    local _CHAR = _L.Character
    if not _CHAR then return false end
    local _OR = _C.CFrame.Position
    local _DE = _T_PRT.Position
    local _DI = (_DE - _OR).Unit * (_DE - _OR).Magnitude
    local _RP = RaycastParams.new()
    _RP.FilterDescendantsInstances = {_CHAR, _C}
    _RP.FilterType = Enum.RaycastFilterType.Exclude
    local _RE = workspace:Raycast(_OR, _DI, _RP)
    return _RE == nil or _RE.Instance:IsDescendantOf(_T_PRT.Parent)
end

-- [RANDOMIZAÇÃO] Gera um ponto aleatório próximo ao alvo
local function _GET_RND_POS(_POS)
    local _J = _DATA.Aimbot.Jitter
    return _POS + Vector3.new(
        math.random(-_J, _J),
        math.random(-_J, _J),
        math.random(-_J, _J)
    )
end

local function CreateESP(Player)
    if Player == _L then return end
    local Objects = {
        Box = Drawing.new("Square"),
        Distance = Drawing.new("Text")
    }
    Objects.Box.Thickness = 1
    Objects.Box.Filled = false
    Objects.Distance.Size = 14
    Objects.Distance.Center = true
    Objects.Distance.Outline = true
    _E_TBL[Player] = Objects
end

local function UpdateESP(Player, Objects)
    local Char = Player.Character
    local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
    local Root = Char and Char:FindFirstChild("HumanoidRootPart")

    if not _DATA.ESP.Enabled or not Root or not Hum or Hum.Health <= 0 then
        for _, obj in pairs(Objects) do obj.Visible = false end
        return
    end

    local Dist = (_C.CFrame.Position - Root.Position).Magnitude
    if Dist > 500 then
        for _, obj in pairs(Objects) do obj.Visible = false end
        return
    end

    local Pos, OnScreen = _C:WorldToViewportPoint(Root.Position)
    
    if OnScreen then
        local Scale = 1000 / Dist
        Objects.Box.Size = Vector2.new(Scale, Scale * 1.5)
        Objects.Box.Position = Vector2.new(Pos.X - Scale/2, Pos.Y - Scale/0.75)
        Objects.Box.Color = Color3.fromHSV((Hum.Health / Hum.MaxHealth) * 0.3, 1, 1)
        Objects.Box.Visible = true
        
        Objects.Distance.Text = math.floor(Dist) .. "m"
        Objects.Distance.Position = Vector2.new(Pos.X, Objects.Box.Position.Y + Objects.Box.Size.Y + 2)
        Objects.Distance.Visible = true
    else
        for _, obj in pairs(Objects) do obj.Visible = false end
    end
end

local function _GET_TARGET()
    local _T = nil
    local _SD = _DATA.Aimbot.FOV
    for _, _P_OBJ in pairs(_P:GetPlayers()) do
        if _P_OBJ ~= _L and _P_OBJ.Character and _P_OBJ.Character:FindFirstChild(_DATA.Aimbot.TargetPart) then
            local _PRT = _P_OBJ.Character[_DATA.Aimbot.TargetPart]
            local _RT = _P_OBJ.Character.HumanoidRootPart
            local _D_REAL = (_L.Character.HumanoidRootPart.Position - _RT.Position).Magnitude
            
            if _D_REAL <= _DATA.Aimbot.MaxDistance then
                local _VPOS, _OS = _C:WorldToViewportPoint(_PRT.Position)
                if _OS then
                    local _M_POS = _U:GetMouseLocation()
                    local _D_FOV = (Vector2.new(_VPOS.X, _VPOS.Y) - _M_POS).Magnitude
                    if _D_FOV < _SD and _RAY_CH(_PRT) then
                        _SD = _D_FOV
                        _T = _PRT
                    end
                end
            end
        end
    end
    return _T
end

-- Interface Original com ajustes
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 350, 0, 560)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -280)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "BIELZINN HUB | SECURE V3"
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Title.Font = Enum.Font.GothamBold
Instance.new("UICorner", Title)

local Content = Instance.new("Frame", MainFrame)
Content.Size = UDim2.new(1, 0, 1, -40)
Content.Position = UDim2.new(0, 0, 0, 40)
Content.BackgroundTransparency = 1

local function NewBtn(txt, pos, color, callback)
    local b = Instance.new("TextButton", Content)
    b.Size = UDim2.new(0, 310, 0, 35)
    b.Position = pos
    b.Text = txt
    b.BackgroundColor3 = color
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(callback)
    return b
end

local AimBtn = NewBtn("Aimbot: OFF", UDim2.new(0, 20, 0, 10), Color3.fromRGB(30, 30, 30), function()
    _DATA.Aimbot.Enabled = not _DATA.Aimbot.Enabled
end)

local EspBtn = NewBtn("ESP: OFF", UDim2.new(0, 20, 0, 50), Color3.fromRGB(30, 30, 30), function()
    _DATA.ESP.Enabled = not _DATA.ESP.Enabled
end)

-- Loop principal atualizado com LERP e JITTER
_R.RenderStepped:Connect(function()
    _FOV_CIRC.Radius = _DATA.Aimbot.FOV
    _FOV_CIRC.Visible = _DATA.Aimbot.ShowFOV
    _FOV_CIRC.Position = _U:GetMouseLocation()

    if _DATA.Aimbot.Enabled then
        local _TARGET = _GET_TARGET()
        if _TARGET then
            -- [RANDOMIZAÇÃO]
            local _TARGET_POS = _GET_RND_POS(_TARGET.Position)
            
            -- [SUAVIZAÇÃO] Usa Lerp para mover a câmera suavemente
            local _LOOK_AT = CFrame.new(_C.CFrame.Position, _TARGET_POS)
            _C.CFrame = _C.CFrame:Lerp(_LOOK_AT, _DATA.Aimbot.Smoothness)
        end
    end
    
    for P, O in pairs(_E_TBL) do UpdateESP(P, O) end
    
    -- Atualizar textos da UI
    AimBtn.Text = "Aimbot: " .. (_DATA.Aimbot.Enabled and "ON" or "OFF")
    AimBtn.BackgroundColor3 = _DATA.Aimbot.Enabled and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(30, 30, 30)
    EspBtn.Text = "ESP: " .. (_DATA.ESP.Enabled and "ON" or "OFF")
    EspBtn.BackgroundColor3 = _DATA.ESP.Enabled and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(30, 30, 30)
end)

for _, p in pairs(_P:GetPlayers()) do CreateESP(p) end
_P.PlayerAdded:Connect(CreateESP)

_U.InputBegan:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.RightShift then MainFrame.Visible = not MainFrame.Visible end
end)
