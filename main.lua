local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Xeno Silent Aim",
   LoadingTitle = "Carregando Script...",
   LoadingSubtitle = "por Gemini",
})

local Tab = Window:CreateTab("Aimbot", 4483362458) -- Ícone de alvo

local Section = Tab:CreateSection("Configurações Principais")

Tab:CreateToggle({
   Name = "Ativar Silent Aim",
   CurrentValue = true,
   Flag = "SilentAimEnabled",
   Callback = function(Value)
      Settings.SilentAim.Enabled = Value
   end,
})

Tab:CreateSlider({
   Name = "Tamanho do FOV",
   Range = {0, 500},
   Increment = 10,
   Suffix = "Pixels",
   CurrentValue = 60,
   Flag = "FOVSize",
   Callback = function(Value)
      Settings.SilentAim.FOV = Value
   end,
})
