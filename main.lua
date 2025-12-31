local _P = game:GetService("Players")
local _R = game:GetService("RunService")
local _U = game:GetService("UserInputService")
local _L = _P.LocalPlayer
local _C = workspace.CurrentCamera

local _DATA = {
    ESP = { Enabled = false },
    Aimbot = {
        Enabled = false,
        -- Detecta o gatilho de mira do controle (L2/LT)
        ActiveKey = Enum.KeyCode.ButtonL2, 
        IsPressed = false,
        FOV = 150,
        ShowFOV = false,
        TargetPart = "Head",
        MaxDistance = 500,
        Smoothness = 0.12, 
        Jitter = 0.35      
    }
}

-- [RAIO DE VISIBILIDADE]
local function _RAY_CH(_T_PRT)
    local _CHAR = _L.Character
    if not _CHAR then return false end
    local _RP = RaycastParams.new()
    _RP.FilterDescendantsInstances = {_CHAR, _C}
    _RP.FilterType = Enum.RaycastFilterType.Exclude
    local _RE = workspace:Raycast(_C.CFrame.Position, (_T_PRT.Position - _C.CFrame.Position).Unit * 1000, _RP)
    return _RE == nil or _RE.Instance:IsDescendantOf(_T_PRT.Parent)
end

-- [RANDOMIZAÇÃO]
local function _GET_RND_POS(_POS)
    local _J = _DATA.Aimbot.Jitter
    return _POS + Vector3.new(math.random(-_J, _J), math.random(-_J, _J), math.random(-_J, _J))
end

-- [DETECTAR ENTRADA DO CONTROLE]
_U.InputBegan:Connect(function(input)
    -- ButtonL2 é o gatilho de mirar no controle
    if input.KeyCode == _DATA.Aimbot.ActiveKey then
        _DATA.Aimbot.IsPressed = true
    end
end)

_U.InputEnded:Connect(function(input)
    if input.KeyCode == _DATA.Aimbot.ActiveKey then
        _DATA.Aimbot.IsPressed = false
    end
end)

-- [BUSCA DE ALVO]
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
                        -- No controle, usamos o centro da tela como referência para o FOV
                        local _SCREEN_CENTER = Vector2.new(_C.ViewportSize.X / 2, _C.ViewportSize.Y / 2)
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

-- [LOOP PRINCIPAL]
_R.RenderStepped:Connect(function()
    -- No controle, o Aimbot só ativado se estiver mirando com L2/LT
    if _DATA.Aimbot.Enabled and _DATA.Aimbot.IsPressed then
        local _TARGET = _GET_TARGET()
        if _TARGET then
            local _T_POS = _GET_RND_POS(_TARGET.Position)
            local _LOOK = CFrame.new(_C.CFrame.Position, _T_POS)
            _C.CFrame = _C.CFrame:Lerp(_LOOK, _DATA.Aimbot.Smoothness)
        end
    end
end)

-- Interface adaptada para controle (Atalho: D-Pad Up / Seta para Cima)
_U.InputBegan:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.DPadUp then
        local UI_Main = game:GetService("CoreGui"):FindFirstChild("ScreenGui")
        if UI_Main then
            UI_Main.Enabled = not UI_Main.Enabled
        end
    end
end)
