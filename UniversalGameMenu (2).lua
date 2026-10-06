--[[
    UNIVERSAL CHEAT MENU (RAYFIELD EDITION)
    Works on any game via an Executor. 
    Removes the server-side dependency and replaces custom GUI with Rayfield API.
--]]

-- Cache services
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local controls = require(player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")):GetControls()
local isTouch = UIS.TouchEnabled

-- Settings Configurations
local S = {
    -- Aim
    aimbot = false,
    aimMode = "Always", -- "Always" or "Hold"
    fov = 150,
    smooth = 0.25,
    maxDist = 500,
    targetPart = "Head",
    wallCheck = false,
    -- Visuals
    espBox = false,
    tracers = false,
    nametags = false,
    espDist = 1000,
    -- Movement
    speedOn = false,
    speed = 32,
    flyOn = false,
    flySpeed = 60,
}

------------------------------------------------
-- RAYFIELD INITIALIZATION
------------------------------------------------
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Protocol-X: Universal",
    LoadingTitle = "Protocol-X Suite",
    LoadingSubtitle = "by Chicago-oldaccount",
    ConfigurationSaving = {
        Enabled = false
    },
    KeySystem = false
})

-- Visual FOV Ring
local overlay = Instance.new("ScreenGui")
overlay.Name = "PX_Overlay"
overlay.ResetOnSpawn = false
overlay.IgnoreGuiInset = true
overlay.Parent = player:WaitForChild("PlayerGui")

local espOverlay = Instance.new("Frame")
espOverlay.Size = UDim2.fromScale(1, 1)
espOverlay.BackgroundTransparency = 1
espOverlay.Parent = overlay

local circle = Instance.new("Frame")
circle.AnchorPoint = Vector2.new(0.5, 0.5)
circle.Position = UDim2.fromScale(0.5, 0.5)
circle.BackgroundTransparency = 1
circle.Visible = false
circle.Parent = overlay
Instance.new("UICorner", circle).CornerRadius = UDim.new(0.5, 0)

local cs = Instance.new("UIStroke", circle)
cs.Color = Color3.new(1, 1, 1)
cs.Thickness = 1.5

local function updateCircle() 
    circle.Size = UDim2.fromOffset(S.fov * 2, S.fov * 2) 
end
updateCircle()

------------------------------------------------
-- TABS & ELEMENTS DEFINITION
------------------------------------------------

-- Combat Tab
local CombatTab = Window:CreateTab("Combat", 4483362458) -- Crosshair icon

CombatTab:CreateToggle({
    Name = "Aimbot",
    CurrentValue = false,
    Callback = function(Value)
        S.aimbot = Value
        circle.Visible = Value
    end,
})

CombatTab:CreateDropdown({
    Name = "Aim Mode",
    Options = {"Always", "Hold"},
    CurrentOption = {"Always"},
    MultipleOptions = false,
    Callback = function(Options)
        S.aimMode = Options
    end,
})

CombatTab:CreateDropdown({
    Name = "Target Part",
    Options = {"Head", "HumanoidRootPart"},
    CurrentOption = {"Head"},
    MultipleOptions = false,
    Callback = function(Options)
        S.targetPart = Options
    end,
})

CombatTab:CreateSlider({
    Name = "Aimbot FOV",
    Range = {40, 400},
    Increment = 10,
    Suffix = "px",
    CurrentValue = 150,
    Callback = function(Value)
        S.fov = Value
        updateCircle()
    end,
})

CombatTab:CreateSlider({
    Name = "Smoothness",
    Range = {5, 100},
    Increment = 5,
    Suffix = "%",
    CurrentValue = 25,
    Callback = function(Value)
        S.smooth = Value / 100
    end,
})

CombatTab:CreateSlider({
    Name = "Max Target Distance",
    Range = {50, 1000},
    Increment = 50,
    Suffix = " studs",
    CurrentValue = 500,
    Callback = function(Value)
        S.maxDist = Value
    end,
})

CombatTab:CreateToggle({
    Name = "Wall Check",
    CurrentValue = false,
    Callback = function(Value)
        S.wallCheck = Value
    end,
})

-- Visuals Tab
local VisualsTab = Window:CreateTab("Visuals", 4483362458) -- Eye icon

VisualsTab:CreateToggle({
    Name = "ESP Box",
    CurrentValue = false,
    Callback = function(Value)
        S.espBox = Value
    end,
})

VisualsTab:CreateToggle({
    Name = "Tracers",
    CurrentValue = false,
    Callback = function(Value)
        S.tracers = Value
    end,
})

VisualsTab:CreateToggle({
    Name = "Nametags",
    CurrentValue = false,
    Callback = function(Value)
        S.nametags = Value
    end,
})

VisualsTab:CreateSlider({
    Name = "ESP Distance",
    Range = {100, 3000},
    Increment = 100,
    Suffix = " studs",
    CurrentValue = 1000,
    Callback = function(Value)
        S.espDist = Value
    end,
})

-- Movement Tab
local MovementTab = Window:CreateTab("Movement", 4483362458) -- Running icon

local flyBV
local function setFly(on)
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if flyBV then flyBV:Destroy() flyBV = nil end
    if on and root and hum then
        flyBV = Instance.new("BodyVelocity")
        flyBV.MaxForce = Vector3.one * 1e6
        flyBV.Velocity = Vector3.zero
        flyBV.Parent = root
        hum.PlatformStand = true
    elseif hum then
        hum.PlatformStand = false
    end
    S.flyOn = on and flyBV ~= nil
end

MovementTab:CreateToggle({
    Name = "Fly (F Key / Toggle)",
    CurrentValue = false,
    Callback = function(Value)
        setFly(Value)
    end,
})

MovementTab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 300},
    Increment = 10,
    Suffix = " studs",
    CurrentValue = 60,
    Callback = function(Value)
        S.flySpeed = Value
    end,
})

MovementTab:CreateToggle({
    Name = "WalkSpeed Modifier",
    CurrentValue = false,
    Callback = function(Value)
        S.speedOn = Value
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum and not Value then hum.WalkSpeed = 16 end
    end,
})

MovementTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 200},
    Increment = 4,
    Suffix = " studs",
    CurrentValue = 32,
    Callback = function(Value)
        S.speed = Value
    end,
})

------------------------------------------------
-- CORE CHEAT ENGINES (TARGETING / ESP / LOOPS)
------------------------------------------------
local function visible(part)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {player.Character}
    local origin = camera.CFrame.Position
    local hit = workspace:Raycast(origin, part.Position - origin, params)
    return not hit or hit.Instance:IsDescendantOf(part.Parent)
end

local function getTarget()
    local best, bestDist = nil, S.fov
    local center = camera.ViewportSize / 2
    for _, plr in Players:GetPlayers() do
        local char = plr.Character
        local part = char and char:FindFirstChild(S.targetPart)
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if plr ~= player and part and hum and hum.Health > 0 then
            local pos, onScreen = camera:WorldToViewportPoint(part.Position)
            local dist = (part.Position - camera.CFrame.Position).Magnitude
            if onScreen and dist <= S.maxDist then
                local d = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                if d < bestDist and (not S.wallCheck or visible(part)) then
                    best, bestDist = part, d
                end
            end
        end
    end
    return best
end

local esp = {}
local function makeEsp(plr)
    local box = Instance.new("Frame")
    box.BackgroundTransparency = 1
    box.BorderSizePixel = 0
    box.Visible = false
    box.Parent = espOverlay
    local st = Instance.new("UIStroke", box)
    st.Color = Color3.fromRGB(255, 60, 60)
    st.Thickness = 1.5

    local name = Instance.new("TextLabel")
    name.Size = UDim2.fromOffset(140, 14)
    name.BackgroundTransparency = 1
    name.TextColor3 = Color3.new(1, 1, 1)
    name.TextStrokeTransparency = 0
    name.Font = Enum.Font.GothamBold
    name.TextSize = 12
    name.Visible = false
    name.Parent = espOverlay

    local tracer = Instance.new("Frame")
    tracer.AnchorPoint = Vector2.new(0.5, 0.5)
    tracer.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    tracer.BorderSizePixel = 0
    tracer.Visible = false
    tracer.Parent = espOverlay

    esp[plr] = {box = box, name = name, tracer = tracer}
end

Players.PlayerRemoving:Connect(function(plr)
    local e = esp[plr]
    if e then e.box:Destroy() e.name:Destroy() e.tracer:Destroy() esp[plr] = nil end
end)

local function updateEsp()
    local vs = camera.ViewportSize
    for _, plr in Players:GetPlayers() do
        if plr ~= player then
            if not esp[plr] then makeEsp(plr) end
            local e = esp[plr]
            e.box.Visible, e.name.Visible, e.tracer.Visible = false, false, false

            local char = plr.Character
            local head = char and char:FindFirstChild("Head")
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if head and root and hum and hum.Health > 0 then
                local dist = (root.Position - camera.CFrame.Position).Magnitude
                local top = camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.7, 0))
                local bot = camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                if top.Z > 0 and bot.Z > 0 and dist <= S.espDist then
                    local h = math.abs(bot.Y - top.Y)
                    local w = h / 2
                    if S.espBox then
                        e.box.Size = UDim2.fromOffset(w, h)
                        e.box.Position = UDim2.fromOffset(bot.X - w / 2, top.Y)
                        e.box.Visible = true
                    end
                    if S.nametags then
                        e.name.Text = plr.DisplayName .. " [" .. math.floor(dist) .. "m]"
                        e.name.Position = UDim2.fromOffset(bot.X - 70, top.Y - 16)
                        e.name.Visible = true
                    end
                    if S.tracers then
                        local from = Vector2.new(vs.X / 2, vs.Y)
                        local to = Vector2.new(bot.X, bot.Y)
                        local diff = to - from
                        e.tracer.Size = UDim2.fromOffset(diff.Magnitude, 1.5)
                        e.tracer.Position = UDim2.fromOffset((from.X + to.X) / 2, (from.Y + to.Y) / 2)
                        e.tracer.Rotation = math.deg(math.atan2(diff.Y, diff.X))
                        e.tracer.Visible = true
                    end
                end
            end
        end
    end
end

-- Keybinds and Inputs
local aimHeld = false
UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.F then
        setFly(not S.flyOn)
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
        aimHeld = true
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aimHeld = false
    end
end)

-- Main Render Loops
RunService:BindToRenderStep("PX_Loop", Enum.RenderPriority.Camera.Value + 1, function()
    local aiming = (S.aimMode == "Always") or aimHeld
    if S.aimbot and aiming then
        local t = getTarget()
        if t then
            camera.CFrame = camera.CFrame:Lerp(CFrame.lookAt(camera.CFrame.Position, t.Position), S.smooth)
        end
    end
    updateEsp()
end)

RunService.Heartbeat:Connect(function()
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    if S.speedOn then hum.WalkSpeed = S.speed end

    if S.flyOn and flyBV then
        local cf = camera.CFrame
        local mv = controls:GetMoveVector()
        local d = cf.RightVector * mv.X - cf.LookVector * mv.Z
        if UIS:IsKeyDown(Enum.KeyCode.Space) then d += Vector3.yAxis end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then d -= Vector3.yAxis end
        flyBV.Velocity = d.Magnitude > 0 and d.Unit * S.flySpeed or Vector3.zero
    end
end)

player.CharacterAdded:Connect(function()
    flyBV = nil
    S.flyOn = false
end)
