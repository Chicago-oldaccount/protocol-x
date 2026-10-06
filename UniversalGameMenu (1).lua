-- UNIVERSAL CLIENT-ONLY MENU: Works on any game via an Executor
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local controls = require(player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")):GetControls()

local isTouch = UIS.TouchEnabled

local S = {
	-- aim
	aimbot = true, aimMode = "Always", -- "Always", or "Hold"
	fov = 150, smooth = 0.25, maxDist = 500, targetPart = "Head", wallCheck = false,
	-- visuals
	espBox = true, tracers = true, nametags = true, espDist = 1000,
	-- movement
	speedOn = false, speed = 32, flyOn = false, flySpeed = 60,
}

local BH = isTouch and 38 or 28 -- button height

------------------------------------------------ GUI
local gui = Instance.new("ScreenGui")
gui.Name = "UniversalGameMenu"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

local overlay = Instance.new("Frame") -- ESP layer
overlay.Size = UDim2.fromScale(1, 1)
overlay.BackgroundTransparency = 1
overlay.Parent = gui

local circle = Instance.new("Frame")
circle.AnchorPoint = Vector2.new(0.5, 0.5)
circle.Position = UDim2.fromScale(0.5, 0.5)
circle.BackgroundTransparency = 1
circle.Parent = gui
Instance.new("UICorner", circle).CornerRadius = UDim.new(0.5, 0)
local cs = Instance.new("UIStroke", circle)
cs.Color = Color3.new(1, 1, 1)
cs.Thickness = 1.5
local function updateCircle() circle.Size = UDim2.fromOffset(S.fov * 2, S.fov * 2) end
updateCircle()

local dot = Instance.new("Frame") -- center crosshair dot
dot.AnchorPoint = Vector2.new(0.5, 0.5)
dot.Position = UDim2.fromScale(0.5, 0.5)
dot.Size = UDim2.fromOffset(4, 4)
dot.BackgroundColor3 = Color3.new(1, 1, 1)
dot.BorderSizePixel = 0
dot.Parent = gui
Instance.new("UICorner", dot).CornerRadius = UDim.new(0.5, 0)

local win = Instance.new("Frame")
win.Size = isTouch and UDim2.fromOffset(250, 300) or UDim2.fromOffset(240, 400)
win.Position = isTouch and UDim2.fromOffset(110, 50) or UDim2.fromOffset(20, 60)
win.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
win.Active = true
win.Draggable = not isTouch
win.Visible = true
win.Parent = gui
Instance.new("UICorner", win).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 28)
title.BackgroundTransparency = 1
title.Text = isTouch and "Universal Menu" or "Universal Menu (M hide)"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = win

local menu = Instance.new("ScrollingFrame")
menu.Size = UDim2.new(1, 0, 1, -28)
menu.Position = UDim2.fromOffset(0, 28)
menu.BackgroundTransparency = 1
menu.BorderSizePixel = 0
menu.ScrollBarThickness = 4
menu.CanvasSize = UDim2.new()
menu.AutomaticCanvasSize = Enum.AutomaticSize.Y
menu.Parent = win
local layout = Instance.new("UIListLayout", menu)
layout.Padding = UDim.new(0, 5)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local order = 0
local function add(inst)
	order += 1
	inst.LayoutOrder = order
	inst.Parent = menu
	return inst
end

local function section(text)
	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, -16, 0, 22)
	l.BackgroundTransparency = 1
	l.Text = "— " .. text .. " —"
	l.TextColor3 = Color3.fromRGB(120, 180, 255)
	l.Font = Enum.Font.GothamBold
	l.TextSize = 13
	return add(l)
end

local function makeButton(text)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, -16, 0, BH)
	b.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Font = Enum.Font.Gotham
	b.TextSize = 13
	b.Text = text
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
	return add(b)
end

local function toggle(name, key, onChange)
	local b = makeButton("")
	local function refresh() b.Text = name .. ": " .. (S[key] and "ON" or "OFF") end
	refresh()
	b.Activated:Connect(function()
		S[key] = not S[key]
		refresh()
		if onChange then onChange() end
	end)
	return refresh
end

local function stepper(name, key, step, minv, maxv, onChange)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -16, 0, BH)
	row.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
	Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
	add(row)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -90, 1, 0)
	lbl.Position = UDim2.fromOffset(8, 0)
	lbl.BackgroundTransparency = 1
	lbl.TextColor3 = Color3.new(1, 1, 1)
	lbl.Font = Enum.Font.Gotham
	lbl.TextSize = 13
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = row
	local function refresh()
		lbl.Text = name .. ": " .. (math.floor(S[key] * 100 + 0.5) / 100)
	end
	refresh()
	local function btn(txt, x, d)
		local b = Instance.new("TextButton")
		b.Size = UDim2.fromOffset(34, BH - 8)
		b.Position = UDim2.new(1, x, 0, 4)
		b.BackgroundColor3 = Color3.fromRGB(70, 70, 85)
		b.TextColor3 = Color3.new(1, 1, 1)
		b.Text = txt
		b.Font = Enum.Font.GothamBold
		b.TextSize = 16
		b.Parent = row
		Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
		b.Activated:Connect(function()
			S[key] = math.clamp(S[key] + d, minv, maxv)
			refresh()
			if onChange then onChange() end
		end)
	end
	btn("-", -76, -step)
	btn("+", -38, step)
end

local function setMenu(v)
	win.Visible = v
	if not isTouch then circle.Visible = v end
end

------------------------------------------------ Targeting
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

------------------------------------------------ Menu contents
section("Aim")
toggle("Aimbot", "aimbot")
local modeBtn = makeButton("Aim Mode: " .. S.aimMode)
modeBtn.Activated:Connect(function()
	local nextMode = {Always = "Hold", Hold = "Always"}
	S.aimMode = nextMode[S.aimMode]
	modeBtn.Text = "Aim Mode: " .. S.aimMode
end)
stepper("Aim FOV", "fov", 20, 40, 400, updateCircle)
stepper("Smoothness", "smooth", 0.05, 0.05, 1)
stepper("Max Distance", "maxDist", 50, 50, 1000)
local partBtn = makeButton("Target: Head")
partBtn.Activated:Connect(function()
	S.targetPart = S.targetPart == "Head" and "HumanoidRootPart" or "Head"
	partBtn.Text = "Target: " .. (S.targetPart == "Head" and "Head" or "Body")
end)
toggle("Wall Check", "wallCheck")

section("Visuals")
toggle("ESP Box", "espBox")
toggle("Tracers", "tracers")
toggle("Nametags", "nametags")
stepper("ESP Distance", "espDist", 100, 100, 3000)

section("Movement")
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
local flyRefresh = toggle(isTouch and "Fly" or "Fly (F)", "flyOn", function() setFly(S.flyOn) end)
stepper("Fly Speed", "flySpeed", 10, 10, 300)
toggle("Speed", "speedOn", function()
	local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if hum and not S.speedOn then hum.WalkSpeed = 16 end
end)
stepper("Walk Speed", "speed", 4, 16, 200)

player.CharacterAdded:Connect(function()
	flyBV = nil
	S.flyOn = false
	flyRefresh()
end)

------------------------------------------------ Inputs
local aimHeld = false
local flyUp, flyDown = false, false
local flyUpBtn, flyDownBtn

UIS.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.M then
		setMenu(not win.Visible)
	elseif input.KeyCode == Enum.KeyCode.F then
		setFly(not S.flyOn)
		flyRefresh()
	elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
		aimHeld = true
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		aimHeld = false
	end
end)

if isTouch then
	local function touchButton(text, pos, size)
		local b = Instance.new("TextButton")
		b.AnchorPoint = Vector2.new(0.5, 0.5)
		b.Size = UDim2.fromOffset(size, size)
		b.Position = pos
		b.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
		b.BackgroundTransparency = 0.35
		b.AutoButtonColor = false
		b.Text = text
		b.TextColor3 = Color3.new(1, 1, 1)
		b.Font = Enum.Font.GothamBold
		b.TextSize = 14
		b.Parent = gui
		Instance.new("UICorner", b).CornerRadius = UDim.new(0.5, 0)
		return b
	end

	local function isPress(i)
		return i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1
	end
	local function hold(b, onDown, onUp)
		b.InputBegan:Connect(function(i) if isPress(i) then onDown() end end)
		b.InputEnded:Connect(function(i) if isPress(i) then onUp() end end)
	end

	local aimBtn = touchButton("AIM", UDim2.new(1, -120, 1, -250), 90)
	hold(aimBtn, function() aimHeld = true end, function() aimHeld = false end)

	local menuBtn = Instance.new("TextButton")
	menuBtn.AnchorPoint = Vector2.new(0.5, 0)
	menuBtn.Size = UDim2.fromOffset(80, 34)
	menuBtn.Position = UDim2.new(0.5, 0, 0, 8)
	menuBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	menuBtn.BackgroundTransparency = 0.2
	menuBtn.Text = "MENU"
	menuBtn.TextColor3 = Color3.new(1, 1, 1)
	menuBtn.Font = Enum.Font.GothamBold
	menuBtn.TextSize = 14
	menuBtn.Parent = gui
	Instance.new("UICorner", menuBtn).CornerRadius = UDim.new(0, 8)
	menuBtn.Activated:Connect(function() setMenu(not win.Visible) end)

	local flyBtn = touchButton("FLY", UDim2.new(0, 50, 0.5, -90), 56)
	flyBtn.Activated:Connect(function()
		setFly(not S.flyOn)
		flyRefresh()
	end)
	flyUpBtn = touchButton("UP", UDim2.new(0, 50, 0.5, -20), 56)
	hold(flyUpBtn, function() flyUp = true end, function() flyUp = false end)
	flyDownBtn = touchButton("DOWN", UDim2.new(0, 50, 0.5, 50), 56)
	hold(flyDownBtn, function() flyDown = true end, function() flyDown = false end)
end

------------------------------------------------ ESP Engine
local esp = {}
local function makeEsp(plr)
	local box = Instance.new("Frame")
	box.BackgroundTransparency = 1
	box.BorderSizePixel = 0
	box.Visible = false
	box.Parent = overlay
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
	name.Parent = overlay

	local tracer = Instance.new("Frame")
	tracer.AnchorPoint = Vector2.new(0.5, 0.5)
	tracer.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
	tracer.BorderSizePixel = 0
	tracer.Visible = false
	tracer.Parent = overlay

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

------------------------------------------------ Loops
RunService:BindToRenderStep("AimbotAndEsp", Enum.RenderPriority.Camera.Value + 1, function()
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
	if flyUpBtn then
		flyUpBtn.Visible = S.flyOn
		flyDownBtn.Visible = S.flyOn
	end

	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not hum then return end

	if S.speedOn then hum.WalkSpeed = S.speed end

	if S.flyOn and flyBV then
		local cf = camera.CFrame
		local mv = controls:GetMoveVector()
		local d = cf.RightVector * mv.X - cf.LookVector * mv.Z
		if flyUp or UIS:IsKeyDown(Enum.KeyCode.Space) then d += Vector3.yAxis end
		if flyDown or UIS:IsKeyDown(Enum.KeyCode.LeftControl) then d -= Vector3.yAxis end
		flyBV.Velocity = d.Magnitude > 0 and d.Unit * S.flySpeed or Vector3.zero
	end
end)
