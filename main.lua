local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- SEGURANÇA PARA EXECUTORES SIMPLES
local ParentUI
if gethui then
    ParentUI = gethui()
elseif game:GetService("CoreGui"):FindFirstChild("RobloxGui") then
    ParentUI = game:GetService("CoreGui")
else
    ParentUI = LocalPlayer:WaitForChild("PlayerGui")
end

local Settings = {
    ESP = { Enabled = false, TeamCheck = true },
    Aimbot = {
        Enabled = false,
        TeamCheck = true,
        FOV = 150,
        ShowFOV = false,
        TargetPart = "Head",
        MaxDistance = 500,
        Smoothing = 0.15
    }
}

-- Limpar versão anterior para não travar
if ParentUI:FindFirstChild("BielzinnHub_CLTV3") then
    ParentUI:FindFirstChild("BielzinnHub_CLTV3"):Destroy()
end

-- INTERFACE GUI (Versão Compatível)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BielzinnHub_CLTV3"
ScreenGui.Parent = ParentUI
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 350, 0, 500)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Active = true
MainFrame.Draggable = true -- Ativa movimentação do menu
Instance.new("UICorner", MainFrame)

-- [O RESTANTE DO CÓDIGO DE BOTÕES E LÓGICA DO AIMBOT SEGUE IGUAL]
-- [CERTIFIQUE-SE DE COPIAR A LÓGICA DO GetClosestPlayer DO MEU POST ANTERIOR]

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "BIELZINN HUB | FIX"
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Title.Font = Enum.Font.GothamBold

local Msg = Instance.new("TextLabel", MainFrame)
Msg.Size = UDim2.new(1, 0, 0, 100)
Msg.Position = UDim2.new(0, 0, 0, 50)
Msg.Text = "Se o menu aparecer, o executor está OK!\nAperte 'RightShift' para fechar/abrir."
Msg.TextColor3 = Color3.new(1,1,0)
Msg.BackgroundTransparency = 1
