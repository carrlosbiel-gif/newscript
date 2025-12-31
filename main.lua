local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Configurações com nomes alternativos para segurança de string
local SystemCfg = {
    Module_Alpha = { -- ESP
        Active = false,
        MaxRange = 500,
    },
    Module_Beta = { -- AIM
        Active = false,
        Range = 150,
        RenderCircle = false,
        Point = "Head",
        DistanceLimit = 500
    }
}

local RenderPoint = Drawing.new("Circle")
RenderPoint.Thickness = 1
RenderPoint.NumSides = 60
RenderPoint.Radius = SystemCfg.Module_Beta.Range
RenderPoint.Visible = false
RenderPoint.Color = Color3.fromRGB(255, 255, 255)

local Data_Cache = {}

-- Função de Verificação de Parede (Wallcheck)
local function CheckView(Part)
    local Char = LocalPlayer.Character
    if not Char then return false end
    local RayParams = RaycastParams.new()
    RayParams.FilterDescendantsInstances = {Char, Camera}
    RayParams.FilterType = Enum.RaycastFilterType.Exclude
    local Result = workspace:Raycast(Camera.CFrame.Position, (Part.Position - Camera.CFrame.Position).Unit * (Part.Position - Camera.CFrame.Position).Magnitude, RayParams)
    return Result == nil or Result.Instance:IsDescendantOf(Part.Parent)
end

local function Initialize_Link(Player)
    if Player == LocalPlayer then return end
    local RenderObj = {
        Frame = Drawing.new("Square"),
        Label = Drawing.new("Text")
    }
    RenderObj.Frame.Thickness = 1
    RenderObj.Label.Size = 14
    RenderObj.Label.Center = true
    RenderObj.Label.Outline = true
    Data_Cache[Player] = RenderObj
end

local function Refresh_Link(Player, Obj)
    local Char = Player.Character
    local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
    local Root = Char and Char:FindFirstChild("HumanoidRootPart")

    if not SystemCfg.Module_Alpha.Active or not Root or not Hum or Hum.Health <= 0 then
        for _, v in pairs(Obj) do v.Visible = false end
        return
    end

    local Dist = (Camera.CFrame.Position - Root.Position).Magnitude
    if Dist > SystemCfg.Module_Alpha.MaxRange then
        for _, v in pairs(Obj) do v.Visible = false end
        return
    end

    local Pos, OnScreen = Camera:WorldToViewportPoint(Root.Position)
    if OnScreen then
        local BoxSize = 1000 / Dist
        Obj.Frame.Size = Vector2.new(BoxSize, BoxSize * 1.5)
        Obj.Frame.Position = Vector2.new(Pos.X - BoxSize/2, Pos.Y - BoxSize/0.75)
        Obj.Frame.Color = Color3.fromHSV(math.clamp(Hum.Health/100, 0, 0.3), 1, 1)
        Obj.Frame.Visible = true
        
        Obj.Label.Text = "[" .. math.floor(Dist) .. "m]"
        Obj.Label.Position = Vector2.new(Pos.X, Obj.Frame.Position.Y + Obj.Frame.Size.Y + 2)
        Obj.Label.Visible = true
    else
        for _, v in pairs(Obj) do v.Visible = false end
    end
end

local function SeekTarget()
    local BestTarget = nil
    local MinDist = SystemCfg.Module_Beta.Range
    for _, P in pairs(Players:GetPlayers()) do
        if P ~= LocalPlayer and P.Character and P.Character:FindFirstChild(SystemCfg.Module_Beta.Point) then
            local Part = P.Character[SystemCfg.Module_Beta.Point]
            local Root = P.Character:FindFirstChild("HumanoidRootPart")
            
            if Root then
                local Mag = (LocalPlayer.Character.HumanoidRootPart.Position - Root.Position).Magnitude
                if Mag <= SystemCfg.Module_Beta.DistanceLimit then
                    local ScreenPos, Visible = Camera:WorldToViewportPoint(Part.Position)
                    if Visible then
                        local MouseDist = (Vector2.new(ScreenPos.X, ScreenPos.Y) - UserInputService:GetMouseLocation()).Magnitude
                        if MouseDist < MinDist and CheckView(Part) then
                            MinDist = MouseDist
                            BestTarget = Part
                        end
                    end
                end
            end
        end
    end
    return BestTarget
end

-- INTERFACE VISUAL
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 350, 0, 400)
Main.Position = UDim2.new(0.5, -175, 0.5, -200)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main)

local Header = Instance.new("TextLabel", Main)
Header.Size = UDim2.new(1, 0, 0, 45)
Header.Text = "SYSTEM_OVERLAY_V3"
Header.TextColor3 = Color3.new(1, 1, 1)
Header.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Header.Font = Enum.Font.GothamBold
Instance.new("UICorner", Header)

local Container = Instance.new("Frame", Main)
Container.Size = UDim2.new(1, -20, 1, -60)
Container.Position = UDim2.new(0, 10, 0, 55)
Container.BackgroundTransparency = 1

local UIList = Instance.new("UIListLayout", Container)
UIList.Padding = UDim.new(0, 8)

local function AddToggle(name, callback)
    local btn = Instance.new("TextButton", Container)
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.Text = name .. ": OFF"
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.Gotham
    Instance.new("UICorner", btn)
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = name .. ": " .. (state and "ON" or "OFF")
        btn.BackgroundColor3 = state and Color3.fromRGB(50, 100, 50) or Color3.fromRGB(35, 35, 35)
        callback(state)
    end)
end

AddToggle("Visual Engine (ESP)", function(v) SystemCfg.Module_Alpha.Active = v end)
AddToggle("Lock-On Assist (AIM)", function(v) SystemCfg.Module_Beta.Active = v end)
AddToggle("Show Boundary (FOV)", function(v) 
    SystemCfg.Module_Beta.RenderCircle = v 
    RenderPoint.Visible = v
end)

-- Loop Principal
RunService.RenderStepped:Connect(function()
    if SystemCfg.Module_Beta.RenderCircle then
        RenderPoint.Radius = SystemCfg.Module_Beta.Range
        RenderPoint.Position = UserInputService:GetMouseLocation()
    end

    if SystemCfg.Module_Beta.Active then
        local TargetPart = SeekTarget()
        if TargetPart then
            -- Mira Instantânea (Lock-on puro) com erro aleatório mínimo
            local RandomOffset = Vector3.new(math.random(-2, 2)/10, math.random(-2, 2)/10, math.random(-2, 2)/10)
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, TargetPart.Position + RandomOffset)
        end
    end

    for p, obj in pairs(Data_Cache) do Refresh_Link(p, obj) end
end)

for _, p in pairs(Players:GetPlayers()) do Initialize_Link(p) end
Players.PlayerAdded:Connect(Initialize_Link)

-- Abrir/Fechar Menu (RightShift ou Insert)
UserInputService.InputBegan:Connect(function(io)
    if io.KeyCode == Enum.KeyCode.RightShift or io.KeyCode == Enum.KeyCode.Insert then
        Main.Visible = not Main.Visible
    end
end)
