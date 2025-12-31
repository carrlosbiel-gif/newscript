local Plrs = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LP = Plrs.LocalPlayer
local Cam = workspace.CurrentCamera

local SecureConfig = {
    Aimbot = {
        Active = false,
        FOV = 150,
        Smooth = 0.12, 
        Part = "Head",
        Dist = 500,
        WallCheck = true,
        IgnoreTeam = true
    },
    Visuals = {
        BoxEnabled = false,
        SecureColor = Color3.fromRGB(0, 255, 120),
        EnemyColor = Color3.fromRGB(255, 50, 50)
    }
}

-- [RAIO DE VISIBILIDADE / WALL CHECK]
local function IsBehindWall(TargetPart)
    local Character = LP.Character
    if not Character then return true end
    local Origin = Cam.CFrame.Position
    local Destination = TargetPart.Position
    local Direction = (Destination - Origin).Unit * (Destination - Origin).Magnitude
    local RayParams = RaycastParams.new()
    RayParams.FilterDescendantsInstances = {Character, Cam}
    RayParams.FilterType = Enum.RaycastFilterType.Exclude
    local Result = workspace:Raycast(Origin, Direction, RayParams)
    
    if Result == nil then return false end
    if Result.Instance:IsDescendantOf(TargetPart.Parent) then return false end
    return true
end

local FOV_Ring = Drawing.new("Circle")
FOV_Ring.Visible = false
FOV_Ring.Thickness = 1
FOV_Ring.Radius = SecureConfig.Aimbot.FOV
FOV_Ring.Color = Color3.new(1, 1, 1)

local Cache_ESP = {}

local function CreateSecureBox(P)
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = SecureConfig.Visuals.SecureColor
    Box.Thickness = 1
    Box.Filled = false
    Cache_ESP[P] = Box
end

local function UpdateVisuals()
    for p, box in pairs(Cache_ESP) do
        local isAlly = (p.Team == LP.Team and p.Team ~= nil)
        if SecureConfig.Visuals.BoxEnabled and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if SecureConfig.Aimbot.IgnoreTeam and isAlly then
                box.Visible = false
            else
                local Root = p.Character.HumanoidRootPart
                local Pos, OnScreen = Cam:WorldToViewportPoint(Root.Position)
                if OnScreen then
                    local Dist = (Cam.CFrame.Position - Root.Position).Magnitude
                    if Dist < SecureConfig.Aimbot.Dist then
                        local Size = 1000 / Dist
                        box.Size = Vector2.new(Size, Size * 1.5)
                        box.Position = Vector2.new(Pos.X - Size/2, Pos.Y - Size/1.5)
                        box.Color = isAlly and SecureConfig.Visuals.SecureColor or SecureConfig.Visuals.EnemyColor
                        box.Visible = true
                    else box.Visible = false end
                else box.Visible = false end
            end
        else box.Visible = false end
    end
end

local function GetClosestTarget()
    local t = nil
    local sd = SecureConfig.Aimbot.FOV
    for _, v in pairs(Plrs:GetPlayers()) do
        if v ~= LP and v.Character and v.Character:FindFirstChild(SecureConfig.Aimbot.Part) then
            local isAlly = (v.Team == LP.Team and v.Team ~= nil)
            if not (SecureConfig.Aimbot.IgnoreTeam and isAlly) then
                local P = v.Character[SecureConfig.Aimbot.Part]
                if not IsBehindWall(P) then
                    local Pos, OnScreen = Cam:WorldToViewportPoint(P
