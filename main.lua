local Players = game:GetService("Players")

local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local Mouse = LocalPlayer:GetMouse()

local Camera = workspace.CurrentCamera



local Settings = {

    SilentAim = {

        Enabled = true,

        FOV = 60, -- FOV curto para não desviar a bala de forma absurda

        Hitchance = 85, -- 85% das balas pegam (simula erros humanos)

        TargetPart = "Head"

    }

}



-- [Lógica de Redirecionamento de Projétil]

-- Esta função intercepta onde o jogo acha que você está atirando

local oldNamecall

oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)

    local args = {...}

    local method = getnamecallmethod()



    -- Verifica se o jogo está tentando calcular a trajetória do tiro

    if Settings.SilentAim.Enabled and (method == "FindPartOnRayWithIgnoreList" or method == "Raycast") then

        local Target = GetClosestPlayer() -- Usa sua função de busca por FOV

        

        if Target and math.random(1, 100) <= Settings.SilentAim.Hitchance then

            local TargetPart = Target.Character[Settings.SilentAim.TargetPart]

            

            -- Redireciona a bala para o alvo silenciosamente

            if args[1] then

                args[1] = Ray.new(Camera.CFrame.Position, (TargetPart.Position - Camera.CFrame.Position).Unit * 1000)

                return oldNamecall(self, unpack(args))

            end

        end

    end

    return oldNamecall(self, ...)

end)



-- [Visualização de FOV para Controle]

local FOVCircle = Drawing.new("Circle")

FOVCircle.Visible = true

FOVCircle.Thickness = 1

FOVCircle.Color = Color3.fromRGB(0, 255, 150) -- Verde "Safe"

FOVCircle.Transparency = 0.5



RunService.RenderStepped:Connect(function()

    FOVCircle.Radius = Settings.SilentAim.FOV

    FOVCircle.Position = game:GetService("UserInputService"):GetMouseLocation()

end)
