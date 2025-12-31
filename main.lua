local _P = game:GetService("Players")
local _R = game:GetService("RunService")
local _U = game:GetService("UserInputService")
local _L = _P.LocalPlayer
local _C = workspace.CurrentCamera

local _DATA = {
    ESP = { Enabled = false, MaxDist = 500 }, -- ESP Adicionado aqui
    Aimbot = {
        Enabled = false,
        FOV = 150,
        ShowFOV = false,
        TargetPart = "Head",
        MaxDistance = 500,
        Smoothness = 0.15,
        Jitter = 0.35
    }
}

-- [DESENHO DO FOV]
local _FOV_CIRC = Drawing.new("Circle")
_FOV_CIRC.Thickness = 1
_FOV_CIRC.NumSides = 100
_FOV_CIRC.Radius = _DATA.Aimbot.FOV
_FOV_CIRC.Visible = false
_FOV_CIRC.Color = Color3.fromRGB(255, 255, 255)

local _E_TBL = {}

-- [FUNÇÃO PARA CRIAR BOX ESP]
local function CreateESP(Player)
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = Color3.fromRGB(255, 255, 255)
    Box.Thickness = 1 -- Fino para ser discreto
    Box.Filled = false
    
    _E_TBL[Player] = Box
end

-- [FUNÇÃO WALL CHECK]
local function _RAY_CH(_T_PRT)
    local _CHAR = _L.Character
    if not _CHAR then return false end
    local _RP = RaycastParams.new()
    _RP.FilterDescendantsInstances = {_CHAR, _C}
    _RP.FilterType = Enum.RaycastFilterType.Exclude
    local _RE = workspace:Raycast(_C.CFrame.Position, (_T_PRT.Position - _C.CFrame.Position).Unit * 1000, _RP)
    return _RE == nil or _RE.Instance:IsDescendantOf(_T_PRT.Parent)
end

-- [RANDOMIZAÇÃO DE ALVO]
local function _GET_RND_POS(_POS)
    local _J = _DATA.Aimbot.Jitter
    return _POS + Vector3.new(math.random(-_J, _J), math.random(-_J, _J), math.random(-_J, _J))
end

-- [BUSCA DE ALVO OTIMIZADA]
local function _GET_TARGET()
    local _T = nil
    local _SD = _DATA.Aimbot.FOV
    for _, _PL in pairs(_P:GetPlayers()) do
        if _PL ~= _L and _PL.Character and _PL.Character:FindFirstChild(_DATA.Aimbot.TargetPart) then
            local _PRT = _PL.Character[_DATA.Aimbot.TargetPart]
            local _RT = _PL.Character:FindFirstChild("HumanoidRootPart")
            if _RT then
                local _DIST = (_L.Character.HumanoidRootPart.Position - _RT.Position).Magnitude
                if _DIST <= _DATA.Aimbot.MaxDistance then
                    local _VPOS, _OS = _C:WorldToViewportPoint(_PRT.Position)
                    if _OS then
                        local _M_D = (Vector2.new(_VPOS.X, _VPOS.Y) - _U:GetMouseLocation()).Magnitude
                        if _M_D < _SD and _RAY_CH(_PRT) then
                            _SD = _M_D
                            _T = _PRT
                        end
                    end
                end
            end
        end
    end
    return _T
end

-- [INTERFACE GRÁFICA]
local UI = Instance.new("ScreenGui", game:GetService("CoreGui"))
local Main = Instance.new("Frame", UI)
Main.Size = UDim2.new(0, 320, 0, 480) -- Aumentado para o novo botão
Main.Position = UDim2.new(0.5, -160, 0.5, -240)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "BIELZINN HUB | PRO SECURE"
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
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

-- Botões de Ativação
local AimBtn = NewBtn("AIMBOT: OFF", UDim2.new(0, 20, 0, 50), Color3.fromRGB(40, 40, 40), function()
    _DATA.Aimbot.Enabled = not _DATA.Aimbot.Enabled
end)

local PartBtn = NewBtn("ALVO: CABEÇA", UDim2.new(0, 20, 0, 95), Color3.fromRGB(40, 40, 40), function()
    _DATA.Aimbot.TargetPart = (_DATA.Aimbot.TargetPart == "Head" and "HumanoidRootPart" or "Head")
end)

local EspBtn = NewBtn("ESP BOX: OFF", UDim2.new(0, 20, 0, 140), Color3.fromRGB(40, 40, 40), function()
    _DATA.ESP.Enabled = not _DATA.ESP.Enabled
end)

local FovShowBtn = NewBtn("VER CÍRCULO: OFF", UDim2.new(0, 20, 0, 185), Color3.fromRGB(40, 40, 40), function()
    _DATA.Aimbot.ShowFOV = not _DATA.Aimbot.ShowFOV
end)

-- Controles de Tamanho do FOV
local FovLabel = Instance.new("TextLabel", Main)
FovLabel.Size = UDim2.new(1, 0, 0, 30)
FovLabel.Position = UDim2.new(0, 0, 0, 225)
FovLabel.Text = "AJUSTE DE FOV: " .. _DATA.Aimbot.FOV
FovLabel.TextColor3 = Color3.new(1,1,1)
FovLabel.BackgroundTransparency = 1
FovLabel.Font = Enum.Font.Gotham

local FovMenos = NewBtn("-", UDim2.new(0, 60, 0, 255), Color3.fromRGB(150, 50, 50), function()
    _DATA.Aimbot.FOV = math.max(10, _DATA.Aimbot.FOV - 10)
end)
FovMenos.Size = UDim2.new(0, 80, 0, 35)

local FovMais = NewBtn("+", UDim2.new(0, 180, 0, 255), Color3.fromRGB(50, 100, 150), function()
    _DATA.Aimbot.FOV = math.min(800, _DATA.Aimbot.FOV + 10)
end)
FovMais.Size = UDim2.new(0, 80, 0, 35)

--
