local _P = game:GetService("Players")
local _R = game:GetService("RunService")
local _U = game:GetService("UserInputService")
local _L = _P.LocalPlayer
local _C = workspace.CurrentCamera

local _DATA = {
    Aimbot = {
        Enabled = true, -- Já deixei ligado por padrão para teste
        FOV = 150,
        TargetPart = "Head",
        MaxDistance = 500,
        Smoothness = 0.15,
        Jitter = 0.35
    }
}

-- [VERIFICAÇÃO DE GATILHO DO CONTROLE]
local function IsAimingOnController()
    local gamepads = _U:GetConnectedGamepads()
    for _, gamepad in pairs(gamepads) do
        local state = _U:getGamepadState(gamepad)
        for _, input in pairs(state) do
            -- ButtonL2 é o gatilho de mira (LT/L2)
            if input.KeyCode == Enum.KeyCode.ButtonL2 then
                -- Se o gatilho estiver apertado mais que 10%, considera que está mirando
                return input.Position.Z > 0.1
            end
        end
    end
    return false
end

-- [RAIO DE VISIBILIDADE / WALL CHECK]
local function _RAY_CH(_T_PRT)
    if not _L.Character then return false end
    local _RP = RaycastParams.new()
    _RP.FilterDescendantsInstances = {_L.Character, _C}
    _RP.FilterType = Enum.RaycastFilterType.Exclude
    local _RE = workspace:Raycast(_C.CFrame.Position, (_T_PRT.Position - _C.CFrame.Position).Unit * 1000, _RP)
    return _RE == nil or _RE.Instance:IsDescendantOf(_T_PRT.Parent)
end

-- [BUSCA DE ALVO CENTRALIZADO (PARA CONTROLE)]
local function _GET_TARGET()
    local _T = nil
    local _SD = _DATA.Aimbot.FOV
    local _SCREEN_CENTER = Vector2.new(_C.ViewportSize.X / 2, _C.ViewportSize.Y / 2)

    for _, _PL in pairs(_P:GetPlayers()) do
        if _PL ~= _L and _PL.Character and _PL.Character:FindFirstChild(_DATA.Aimbot.TargetPart) then
            local _PRT = _PL.Character[_DATA.Aimbot.TargetPart]
            local _RT = _PL.Character:FindFirstChild("HumanoidRootPart")
            
            if _RT then
                local _DIST = (_L.Character.HumanoidRootPart.Position - _RT.Position).Magnitude
                if _DIST <= _DATA.Aimbot.MaxDistance then
                    local _VPOS, _OS = _C:WorldToViewportPoint(_PRT.Position)
                    if _OS then
                        local _M_D = (Vector2.new(_VPOS.X, _VPOS.Y) - _SCREEN_CENTER).Magnitude
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

-- [LOOP DE RENDERIZAÇÃO]
_R.RenderStepped:Connect(function()
    -- Verifica se o Aimbot está ligado no menu E se o gatilho L2 está apertado
    if _DATA.Aimbot.Enabled and IsAimingOnController() then
        local _TARGET = _GET_TARGET()
        if _TARGET then
            -- Randomização leve (Jitter)
            local _J = _DATA.Aimbot.Jitter
            local _T_POS = _TARGET.Position + Vector3.new(math.random(-_J,_J), math.random(-_J,_J), math.random(-_J,_J))
            
            -- Suavização (Lerp)
            local _LOOK = CFrame.new(_C.CFrame.Position, _T_POS)
            _C.CFrame = _C.CFrame:Lerp(_LOOK, _DATA.Aimbot.Smoothness)
        end
    end
end)
