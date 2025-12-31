local _P = game:GetService("Players")
local _R = game:GetService("RunService")
local _U = game:GetService("UserInputService")
local _L = _P.LocalPlayer
local _C = workspace.CurrentCamera

local _DATA = {
    Aimbot = {
        Enabled = false,
        Active = false,
        FOV = 150,
        TargetPart = "Head",
        MaxDistance = 500,
        Smoothness = 0.15,
        Jitter = 0.3
    },
    Visuals = {
        Box = false
    }
}

-- [FUNÇÃO PARA DETECTAR GATILHO L2/LT]
local function IsAiming()
    -- Checa se o gatilho L2 está sendo pressionado (Controle)
    local controllerActive = false
    local inputs = _U:GetKeysPressed()
    for _, input in pairs(inputs) do
        if input.KeyCode == Enum.KeyCode.ButtonL2 then
            controllerActive = true
        end
    end
    -- Também aceita o Botão Direito do Mouse para PC
    return controllerActive or _U:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
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

-- [INTERFACE GRÁFICA CORRIGIDA]
local UI = Instance.new("ScreenGui")
UI.Name = "BielzinnHub"
UI.Parent = game:GetService("CoreGui")

local Main = Instance.new("Frame", UI)
Main.Size = UDim2.new(0, 300, 0, 350)
Main.Position = UDim2.new(0.5, -150, 0.5, -175)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "BIELZINN HUB V4"
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Title.Font = Enum.Font.GothamBold
Instance.new("UICorner", Title)

local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(1, 0, 1, -40)
Content.Position = UDim2.new(0, 0, 0, 40)
Content.BackgroundTransparency = 1

local function NewBtn(txt, pos, callback)
    local b = Instance.new("TextButton", Content)
    b.Size = UDim2.new(1, -40, 0, 40)
    b.Position = pos
    b.Text = txt
    b.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(callback)
    return b
end

-- Botões
local AimBtn = NewBtn("AIMBOT: OFF", UDim2.new(0, 20, 0, 20), function()
    _DATA.Aimbot.Enabled = not _DATA.Aimbot.Enabled
end)

local PartBtn = NewBtn("ALVO: CABEÇA", UDim2.new(0, 20, 0, 70), function()
    _DATA.Aimbot.TargetPart = (_DATA.Aimbot.TargetPart == "Head" and "HumanoidRootPart" or "Head")
end)

local FovLabel = Instance.new("TextLabel", Content)
FovLabel.Size = UDim2.new(1, 0, 0, 30)
FovLabel.Position = UDim2.new(0, 0, 0, 120)
FovLabel.Text = "FOV: " .. _DATA.Aimbot.FOV
FovLabel.TextColor3 = Color3.new(1,1,1)
FovLabel.BackgroundTransparency = 1

NewBtn("FOV +25", UDim2.new(0, 20, 0, 150), function() _DATA.Aimbot.FOV = _DATA.Aimbot.FOV + 25 end)
NewBtn("FOV -25", UDim2.new(0, 20, 0, 200), function() _DATA.Aimbot.FOV = math.max(25, _DATA.Aimbot.FOV - 25) end)

-- [LOOP PRINCIPAL]
_R.RenderStepped:Connect(function()
    AimBtn.Text = "AIMBOT: " .. (_DATA.Aimbot.Enabled and "ON" or "OFF")
    AimBtn.BackgroundColor3 = _DATA.Aimbot.Enabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(45, 45, 45)
    PartBtn.Text = "ALVO: " .. (_DATA.Aimbot.TargetPart == "Head" and "CABEÇA" or "PEITO")
    FovLabel.Text = "FOV: " .. _DATA.Aimbot.FOV

    if _DATA.Aimbot.Enabled and IsAiming() then
        local target = _GET_TARGET()
        if target then
            local jitter = _DATA.Aimbot.Jitter
            local targetPos = target.Position + Vector3.new(math.random(-jitter, jitter), math.random(-jitter, jitter), math.random(-jitter, jitter))
            local lookAt = CFrame.new(_C.CFrame.Position, targetPos)
            _C.CFrame = _C.CFrame:Lerp(lookAt, _DATA.Aimbot.Smoothness)
        end
    end
end)

-- Minimizar com Seta para Cima (Controle) ou RightShift (PC)
_U.InputBegan:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.DPadUp or i.KeyCode == Enum.KeyCode.RightShift then
        Main.Visible = not Main.Visible
    end
end)
