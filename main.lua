local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Settings = {
    Aimbot = { Enabled = false, FOV = 150, ShowFOV = false, TargetPart = "Head" }
}

-- Interface Principal
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 350, 0, 420)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Active = true
MainFrame.Draggable = true
local MainCorner = Instance.new("UICorner", MainFrame)

-- TÍTULO
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "BIELZINN HUB | CLT EDITION"
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Instance.new("UICorner", Title)

-- BOTÃO MINIMIZAR (_)
local MinBtn = Instance.new("TextButton", MainFrame)
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -65, 0, 5)
MinBtn.Text = "_"
MinBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
MinBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", MinBtn)

-- FOTO CLT
local cltImage = Instance.new("ImageLabel", MainFrame)
cltImage.Size = UDim2.new(0, 100, 0, 100)
cltImage.Position = UDim2.new(0.5, -50, 0, 50)
cltImage.Image = "rbxassetid://13247072551" -- ID CLT (Carteira de Trabalho)
cltImage.BackgroundTransparency = 1

-- CONTAINER DOS BOTÕES (Para esconder ao minimizar)
local Content = Instance.new("Frame", MainFrame)
Content.Size = UDim2.new(1, 0, 1, -150)
Content.Position = UDim2.new(0, 0, 0, 150)
Content.BackgroundTransparency = 1

local function NewBtn(txt, pos, color, parent)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0, 310, 0, 40)
    b.Position = pos
    b.Text = txt
    b.BackgroundColor3 = color
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.Gotham
    Instance.new("UICorner", b)
    return b
end

local AimBtn = NewBtn("Aimbot: OFF", UDim2.new(0, 20, 0, 10), Color3.fromRGB(40, 40, 40), Content)
local DisplayFov = Instance.new("TextLabel", Content)
DisplayFov.Size = UDim2.new(0, 310, 0, 30)
DisplayFov.Position = UDim2.new(0, 20, 0, 60)
DisplayFov.Text = "TAMANHO DO FOV: " .. Settings.Aimbot.FOV
DisplayFov.TextColor3 = Color3.fromRGB(0, 255, 255)
DisplayFov.BackgroundTransparency = 1
DisplayFov.Font = Enum.Font.GothamBold

local Menos = NewBtn("FOV -10", UDim2.new(0, 20, 0, 100), Color3.fromRGB(150, 50, 50), Content)
Menos.Size = UDim2.new(0, 150, 0, 40)

local Mais = NewBtn("FOV +10", UDim2.new(0, 180, 0, 100), Color3.fromRGB(50, 100, 150), Content)
Mais.Size = UDim2.new(0, 150, 0, 40)

-- LÓGICA MINIMIZAR
local minimizado = false
MinBtn.MouseButton1Click:Connect(function()
    minimizado = not minimizado
    if minimizado then
        MainFrame:TweenSize(UDim2.new(0, 350, 0, 40), "Out", "Quad", 0.3, true)
        Content.Visible = false
        cltImage.Visible = false
        MinBtn.Text = "+"
    else
        MainFrame:TweenSize(UDim2.new(0, 350, 0, 420), "Out", "Quad", 0.3, true)
        Content.Visible = true
        cltImage.Visible = true
        MinBtn.Text = "_"
    end
end)

-- EVENTOS AIMBOT
AimBtn.MouseButton1Click:Connect(function()
    Settings.Aimbot.Enabled = not Settings.Aimbot.Enabled
    AimBtn.Text = "Aimbot: " .. (Settings.Aimbot.Enabled and "ON" or "OFF")
    AimBtn.BackgroundColor3 = Settings.Aimbot.Enabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(40, 40, 40)
end)

Mais.MouseButton1Click:Connect(function()
    Settings.Aimbot.FOV = Settings.Aimbot.FOV + 10
    DisplayFov.Text = "TAMANHO DO FOV: " .. Settings.Aimbot.FOV
end)

Menos.MouseButton1Click:Connect(function()
    if Settings.Aimbot.FOV > 10 then
        Settings.Aimbot.FOV = Settings.Aimbot.FOV - 10
        DisplayFov.Text = "TAMANHO DO FOV: " .. Settings.Aimbot.FOV
    end
end)

-- O resto da lógica de Aimbot (GetClosestPlayer, RenderStepped) deve ser mantida abaixo...
-- [Coloque aqui as funções de busca de player e wallcheck que usamos antes]
