local Plrs = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LP = Plrs.LocalPlayer
local Cam = workspace.CurrentCamera

-- Configurações Camufladas
local SecureConfig = {
    Aimbot = {
        Active = false,
        FOV = 150,
        Smooth = 0.12, -- Suavização para parecer humano
        Part = "Head",
        Dist = 500
    },
    Visuals = {
        BoxEnabled = false,
        TeamCheck = true,
        SecureColor = Color3.fromRGB(0, 255, 120)
    }
}

local FOV_Ring = Drawing.new("Circle")
FOV_Ring.Visible = false
FOV_Ring.Thickness = 1
FOV_Ring.Radius = SecureConfig.Aimbot.FOV
FOV_Ring.Color = Color3.new(1, 1, 1)

local Cache_ESP = {}

-- Criar Box Seguro
local function CreateSecureBox(P)
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = SecureConfig.Visuals.SecureColor
    Box.Thickness = 1
    Box.Filled = false
    Cache_ESP[P] = Box
end

-- Lógica do ESP (Box)
local function UpdateVisuals()
    for p, box in pairs(Cache_ESP) do
        if SecureConfig.Visuals.BoxEnabled and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") then
            local Hum = p.Character.Humanoid
            local Root = p.Character.HumanoidRootPart
            local Pos, OnScreen = Cam:WorldToViewportPoint(Root.Position)
            
            if OnScreen and Hum.Health > 0 then
                local Dist = (Cam.CFrame.Position - Root.Position).Magnitude
                if Dist < SecureConfig.Aimbot.Dist then
                    local Size = 1000 / Dist
                    box.Size = Vector2.new(Size, Size * 1.5)
                    box.Position = Vector2.new(Pos.X - Size/2, Pos.Y - Size/1.5)
                    box.Visible = true
                else
                    box.Visible = false
                end
            else
                box.Visible = false
            end
        else
            box.Visible = false
        end
    end
end

-- Função de Alvo (Otimizada)
local function GetClosestTarget()
    local t = nil
    local sd = SecureConfig.Aimbot.FOV
    for _, v in pairs(Plrs:GetPlayers()) do
        if v ~= LP and v.Character and v.Character:FindFirstChild(SecureConfig.Aimbot.Part) then
            local P = v.Character[SecureConfig.Aimbot.Part]
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
    return t
end

-- Loop Principal Unificado
RS.RenderStepped:Connect(function()
    UpdateVisuals()
    FOV_Ring.Position = UIS:GetMouseLocation()
    
    if SecureConfig.Aimbot.Active then
        local Alvo = GetClosestTarget()
        if Alvo then
            -- Movimento suave (Lerp) para não dar "snap"
            local Look = CFrame.new(Cam.CFrame.Position, Alvo.Position)
            Cam.CFrame = Cam.CFrame:Lerp(Look, SecureConfig.Aimbot.Smooth)
        end
    end
end)

-- Gerenciamento de Jogadores
for _, p in pairs(Plrs:GetPlayers()) do if p ~= LP then CreateSecureBox(p) end end
Plrs.PlayerAdded:Connect(CreateSecureBox)

--- [ INTERFACE COMPACTA ] ---
local UI = Instance.new("ScreenGui", game:GetService("CoreGui"))
local F = Instance.new("Frame", UI)
F.Size = UDim2.new(0, 180, 0, 100)
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

AddBtn("ESP BOX: OFF", UDim2.new(0, 10, 0, 55), function(b)
    SecureConfig.Visuals.BoxEnabled = not SecureConfig.Visuals.BoxEnabled
    b.Text = "ESP BOX: " .. (SecureConfig.Visuals.BoxEnabled and "ON" or "OFF")
    b.BackgroundColor3 = SecureConfig.Visuals.BoxEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(40, 40, 40)
end)
