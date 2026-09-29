if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local NoclipEnabled = false
local IsTeleportingAll = false 
local IsInvisible = false
local RealCharacter = nil
local OriginalC0s = {} 
local OriginalMassless = {} 
local HeightOffset = Vector3.new(0, 150, 0)

local AimbotEnabled = false
local TeleportEnabled = false
local FOV_RADIUS = 350
local MAX_DISTANCE = 300
local TARGET_PART = "Head"
local LockedTarget = nil
local TP_SPEED = 350

local SpeedEnabled = false
local SpeedConnection = nil

-- CẤU HÌNH ESP WALLHACK
local ESPEnabled = false
local ESPObjects = {}

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.Color = Color3.fromRGB(0, 255, 0)
FOVCircle.Filled = false
FOVCircle.Radius = FOV_RADIUS
FOVCircle.Visible = false

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
if PlayerGui:FindFirstChild("MiniHub") then PlayerGui.MiniHub:Destroy() end

local Gui = Instance.new("ScreenGui")
Gui.Name = "MiniHub"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.Parent = PlayerGui

-- ==========================================
-- NÚT BẤM THU GỌN / ĐÓNG MỞ MENU (MINIMIZE BUTTON)
-- ==========================================
local ToggleMenuBtn = Instance.new("TextButton")
ToggleMenuBtn.Name = "ToggleMenuBtn"
ToggleMenuBtn.Size = UDim2.fromOffset(90, 35)
ToggleMenuBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
ToggleMenuBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ToggleMenuBtn.Text = "🐉 KAIJU"
ToggleMenuBtn.Font = Enum.Font.GothamBold
ToggleMenuBtn.TextSize = 14
ToggleMenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleMenuBtn.Active = true
ToggleMenuBtn.Parent = Gui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent = ToggleMenuBtn

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Thickness = 1.5
ToggleStroke.Color = Color3.fromRGB(100, 100, 100)
ToggleStroke.Parent = ToggleMenuBtn

-- ==========================================
-- MENU CHÍNH (MAIN FRAME)
-- ==========================================
local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(250, 400)
Main.Position = UDim2.new(0.5, -125, 0.4, -200)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.BorderSizePixel = 0
Main.Active = true
Main.Visible = false
Main.Parent = Gui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 2
MainStroke.Color = Color3.fromRGB(60, 60, 60)
MainStroke.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "🐉 KAIJU HUB (ALL-IN-ONE)"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Parent = Main

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.9, 0, 0, 30)
StatusLabel.Position = UDim2.new(0.05, 0, 0.1, 0)
StatusLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
StatusLabel.Text = "Hệ thống sẵn sàng"
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 12
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.Parent = Main

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 6)
InputCorner.Parent = StatusLabel

local function CreateButton(name, text, pos, bgC3, textC3)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(0.9, 0, 0, 32)
    btn.Position = pos
    btn.BackgroundColor3 = bgC3
    btn.Text = text
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.TextColor3 = textC3
    btn.Parent = Main
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    return btn
end

local NoclipBtn   = CreateButton("NoclipBtn", "Noclip: TẮT", UDim2.new(0.05, 0, 0.19, 0), Color3.fromRGB(40, 40, 40), Color3.fromRGB(255, 100, 100))
local TeleportBtn = CreateButton("TeleportBtn", "Dịch chuyển Server: TẮT", UDim2.new(0.05, 0, 0.29, 0), Color3.fromRGB(255, 85, 85), Color3.fromRGB(255, 255, 255))
local InvisBtn    = CreateButton("InvisBtn", "Invisible: OFF", UDim2.new(0.05, 0, 0.39, 0), Color3.fromRGB(200, 50, 50), Color3.fromRGB(255, 255, 255))
local AimBtn      = CreateButton("AimBtn", "AIMBOT: OFF", UDim2.new(0.05, 0, 0.49, 0), Color3.fromRGB(200, 50, 50), Color3.fromRGB(255, 255, 255))
local AimTPBtn    = CreateButton("AimTPBtn", "AIM TP: OFF", UDim2.new(0.05, 0, 0.59, 0), Color3.fromRGB(200, 50, 50), Color3.fromRGB(255, 255, 255))
local SpeedBtn    = CreateButton("SpeedBtn", "Tốc độ 350: TẮT", UDim2.new(0.05, 0, 0.69, 0), Color3.fromRGB(200, 50, 50), Color3.fromRGB(255, 255, 255))
local ESPBtn      = CreateButton("ESPBtn", "ESP WALLHACK: TẮT", UDim2.new(0.05, 0, 0.79, 0), Color3.fromRGB(200, 50, 50), Color3.fromRGB(255, 255, 255))

-- SỰ KIỆN ĐÓNG/MỞ MENU KHI BẤM NÚT 🐉 KAIJU
ToggleMenuBtn.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
    if Main.Visible then
        ToggleMenuBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        ToggleMenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end)

-- LOGIC DRAGGABLE CHO MENU CHÍNH VÀ NÚT BẤM THU GỌN
local function EnableDrag(guiFrame)
    local dragging, dragInput, dragStart, startPos
    guiFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    guiFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            guiFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end
EnableDrag(Main)
EnableDrag(ToggleMenuBtn)

-- LOGIC HOẠT ĐỘNG NOCLIP
RunService.Stepped:Connect(function()
    if NoclipEnabled and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

NoclipBtn.MouseButton1Click:Connect(function()
    NoclipEnabled = not NoclipEnabled
    if NoclipEnabled then
        NoclipBtn.Text = "Noclip: BẬT"
        NoclipBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        NoclipBtn.Text = "Noclip: TẮT"
        NoclipBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end)

-- LOGIC HOẠT ĐỘNG TELEPORT ALL
TeleportBtn.MouseButton1Click:Connect(function()
    IsTeleportingAll = not IsTeleportingAll 
    if IsTeleportingAll then
        TeleportBtn.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
        TeleportBtn.Text = "Dịch chuyển: SIÊU CỰC ĐẠI 🔥"
        StatusLabel.Text = "Đang lặp qua toàn server..."
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
        
        task.spawn(function()
            while IsTeleportingAll do
                local allPlayers = Players:GetPlayers()
                local myRoot = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                if myRoot then
                    for _, targetPlayer in pairs(allPlayers) do
                        if not IsTeleportingAll then break end
                        if targetPlayer ~= Player and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            myRoot.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 0.3)
                            task.wait()
                        end
                    end
                end
                RunService.Heartbeat:Wait()
            end
        end)
    else
        TeleportBtn.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
        TeleportBtn.Text = "Dịch chuyển Server: TẮT"
        StatusLabel.Text = "Đã dừng dịch chuyển!"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
        task.wait(0.25) 
        if not IsTeleportingAll then 
            StatusLabel.Text = "Hệ thống sẵn sàng"
            StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end
end)

-- LOGIC TÀNG HÌNH (INVISIBLE)
local function TurnInvisible()
    RealCharacter = Player.Character
    if not RealCharacter then return end
    local RealRoot = RealCharacter:FindFirstChild("HumanoidRootPart")
    if not RealRoot then return end

    table.clear(OriginalC0s)
    table.clear(OriginalMassless)

    for _, part in pairs(RealCharacter:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            OriginalMassless[part] = part.Massless
            part.Massless = true 
        end
    end

    for _, motor in pairs(RealCharacter:GetDescendants()) do
        if motor:IsA("Motor6D") and motor.Name ~= "RootJoint" then
            OriginalC0s[motor] = motor.C0 
        end
    end

    for _, accessory in pairs(RealCharacter:GetChildren()) do
        if accessory:IsA("Accessory") and accessory:FindFirstChild("Handle") then
            local handle = accessory.Handle
            OriginalMassless[handle] = handle.Massless
            handle.Transparency = 1
            handle.Massless = true
        end
    end
    
    local Camera = workspace.CurrentCamera
    Camera.CameraSubject = RealCharacter:FindFirstChildOfClass("Humanoid")
end

local function TurnVisible()
    IsInvisible = false
    if RealCharacter then
        for motor, originalC0 in pairs(OriginalC0s) do
            if motor and motor.Parent then motor.C0 = originalC0 end
        end
        for part, wasMassless in pairs(OriginalMassless) do
            if part and part.Parent then
                part.Massless = wasMassless
                if part.Name == "Handle" then part.Transparency = 0 end
            end
        end
    end
end

InvisBtn.MouseButton1Click:Connect(function()
    IsInvisible = not IsInvisible
    if IsInvisible then
        InvisBtn.Text = "Invisible: ON"
        InvisBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50) 
        TurnInvisible()
    else
        InvisBtn.Text = "Invisible: OFF"
        InvisBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50) 
        TurnVisible()
    end
end)

RunService.Heartbeat:Connect(function()
    if IsInvisible and RealCharacter then
        local RealRoot = RealCharacter:FindFirstChild("HumanoidRootPart")
        if RealRoot then
            for motor, _ in pairs(OriginalC0s) do
                if motor and motor.Parent then motor.C0 = CFrame.new(HeightOffset) end
            end
            for _, part in pairs(RealCharacter:GetChildren()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.Velocity = Vector3.new(0, 0, 0)
                    part.RotVelocity = Vector3.new(0, 0, 0)
                end
            end
        end
    end
end)

Player.CharacterAdded:Connect(function()
    IsInvisible = false
    InvisBtn.Text = "Invisible: OFF"
    InvisBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
end)

-- LOGIC HOẠT ĐỘNG AIMBOT (ĐÃ FIX SỬA LỖI KHÔNG KHÓA MỤC TIÊU)
local function isVisible(targetPlayer)
    if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild(TARGET_PART) then return false end
    local targetPart = targetPlayer.Character[TARGET_PART]
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetPlayer.Character, workspace.CurrentCamera}
    local origin = Camera.CFrame.Position
    local direction = targetPart.Position - origin
    local raycastResult = workspace:Raycast(origin, direction, raycastParams)
    return raycastResult == nil
end

local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(TARGET_PART) and player.Character:FindFirstChildOfClass("Humanoid") then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            local targetPart = player.Character[TARGET_PART]
            
            local distanceStuds = (targetPart.Position - Camera.CFrame.Position).Magnitude
            
            if humanoid.Health > 0 and distanceStuds <= MAX_DISTANCE then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen or TeleportEnabled then
                    local targetPos2D = Vector2.new(screenPos.X, screenPos.Y)
                    local distanceToCenter = (targetPos2D - screenCenter).Magnitude
                    
                    if (TeleportEnabled or distanceToCenter <= FOV_RADIUS) and distanceToCenter < shortestDistance then
                        if isVisible(player) or TeleportEnabled then
                            closestPlayer = player
                            shortestDistance = distanceToCenter
                        end
                    end
                end
            end
        end
    end
    return closestPlayer
end

local aimConnection
local function startAimbot()
    aimConnection = RunService.RenderStepped:Connect(function(deltaTime)
        local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        FOVCircle.Position = screenCenter

        if not AimbotEnabled then 
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                LocalPlayer.Character:FindFirstChildOfClass("Humanoid").AutoRotate = true
            end
            return 
        end

        if LockedTarget then
            if not LockedTarget.Parent or not LockedTarget.Character or 
               not LockedTarget.Character:FindFirstChild(TARGET_PART) or 
               LockedTarget.Character:FindFirstChildOfClass("Humanoid").Health <= 0 or 
               (LockedTarget.Character[TARGET_PART].Position - Camera.CFrame.Position).Magnitude > MAX_DISTANCE then
                LockedTarget = nil
            elseif not TeleportEnabled then
                local targetPart = LockedTarget.Character[TARGET_PART]
                local _, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if not onScreen or not isVisible(LockedTarget) then LockedTarget = nil end
            end
        end

        if not LockedTarget then LockedTarget = getClosestPlayer() end

        if LockedTarget and LockedTarget.Character and LockedTarget.Character:FindFirstChild(TARGET_PART) then
            local targetPart = LockedTarget.Character[TARGET_PART]
            local targetPos = targetPart.Position
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos)

            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                local myRoot = LocalPlayer.Character.HumanoidRootPart
                local myHumanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                local enemyRoot = LockedTarget.Character:FindFirstChild("HumanoidRootPart")
                
                if enemyRoot then
                    myHumanoid.AutoRotate = false
                    
                    if TeleportEnabled then
                        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                            if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
                        end
                        
                        local tpPosition = enemyRoot.Position - (enemyRoot.CFrame.LookVector * 3.5)
                        local currentPos = myRoot.Position
                        local distanceToTP = (tpPosition - currentPos).Magnitude
                        
                        myRoot.Velocity = Vector3.new(0, 0, 0)
                        myRoot.RotVelocity = Vector3.new(0, 0, 0)
                        
                        if distanceToTP > 40 then
                            local direction = (tpPosition - currentPos).Unit
                            local nextPos = currentPos + (direction * math.min(distanceToTP, TP_SPEED * deltaTime))
                            myRoot.CFrame = CFrame.lookAt(nextPos, enemyRoot.Position)
                        else
                            myRoot.CFrame = CFrame.lookAt(tpPosition, enemyRoot.Position)
                        end
                    end
                end
            end
        else
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                LocalPlayer.Character:FindFirstChildOfClass("Humanoid").AutoRotate = true
            end
        end
    end)
end

local function stopAimbot()
    if aimConnection then aimConnection:Disconnect(); aimConnection = nil end
    FOVCircle.Visible = false
    LockedTarget = nil
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").AutoRotate = true
    end
end

AimBtn.MouseButton1Click:Connect(function()
    AimbotEnabled = not AimbotEnabled
    if AimbotEnabled then
        AimBtn.Text = "AIMBOT: ON"
        AimBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        FOVCircle.Visible = true
        StatusLabel.Text = "Hệ thống sẵn sàng"
        StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        if not aimConnection then startAimbot() end
    else
        AimBtn.Text = "AIMBOT: OFF"
        AimBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        TeleportEnabled = false
        AimTPBtn.Text = "AIM TP: OFF"
        AimTPBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        stopAimbot()
    end
end)

AimTPBtn.MouseButton1Click:Connect(function()
    if not AimbotEnabled then 
        StatusLabel.Text = "Hãy bật AIMBOT trước!"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        return 
    end
    TeleportEnabled = not TeleportEnabled
    if TeleportEnabled then
        AimTPBtn.Text = "AIM TP: ON"
        AimTPBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        StatusLabel.Text = "Hệ thống sẵn sàng"
        StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    else
        AimTPBtn.Text = "AIM TP: OFF"
        AimTPBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end)

-- LOGIC SPEED HACK
local function setSpeed(character)
    if not SpeedEnabled then return end
    local humanoid = character:WaitForChild("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = 350 
        if SpeedConnection then SpeedConnection:Disconnect() end
        SpeedConnection = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            if SpeedEnabled and humanoid.WalkSpeed ~= 350 then
                humanoid.WalkSpeed = 350
            end
        end)
    end
end 

SpeedBtn.MouseButton1Click:Connect(function()
SpeedBtn.MouseButton1Click:Connect(function()
    SpeedEnabled = not SpeedEnabled
    if SpeedEnabled then
        SpeedBtn.Text = "Tốc độ 350: BẬT"
        SpeedBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        if LocalPlayer.Character then setSpeed(LocalPlayer.Character) end
    else
        SpeedBtn.Text = "Tốc độ 350: TẮT"
        SpeedBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        if SpeedConnection then SpeedConnection:Disconnect(); SpeedConnection = nil end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    if SpeedEnabled then setSpeed(char) end
end)


-- ==========================================
-- KHU VỰC ESP WALLHACK
-- ==========================================
local function CreateESP(player)
    if ESPObjects[player] then return end

    local objects = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        HealthBarOutline = Drawing.new("Square"),
        HealthBar = Drawing.new("Square")
    }

    objects.Box.Color = Color3.fromRGB(255, 0, 0)
    objects.Box.Thickness = 1.5
    objects.Box.Filled = false
    objects.Box.Visible = false

    objects.Name.Color = Color3.fromRGB(255, 255, 255)
    objects.Name.Size = 14
    objects.Name.Center = true
    objects.Name.Outline = true
    objects.Name.Visible = false
    objects.Name.Font = 2

    objects.Distance.Visible = false

    objects.HealthBarOutline.Color = Color3.fromRGB(0, 0, 0)
    objects.HealthBarOutline.Thickness = 1
    objects.HealthBarOutline.Filled = true
    objects.HealthBarOutline.Visible = false

    objects.HealthBar.Color = Color3.fromRGB(0, 255, 0)
    objects.HealthBar.Thickness = 1
    objects.HealthBar.Filled = true
    objects.HealthBar.Visible = false

    ESPObjects[player] = objects
end

local function RemoveESP(player)
    if ESPObjects[player] then
        for _, obj in pairs(ESPObjects[player]) do
            obj:Remove()
        end
        ESPObjects[player] = nil
    end
end

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then CreateESP(p) end
end
Players.PlayerAdded:Connect(function(p)
    if p ~= LocalPlayer then CreateESP(p) end
end)
Players.PlayerRemoving:Connect(RemoveESP)

RunService.RenderStepped:Connect(function()
    for player, obj in pairs(ESPObjects) do
        if not ESPEnabled then
            for _, drawingObj in pairs(obj) do drawingObj.Visible = false end
            continue
        end

        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChildOfClass("Humanoid") then
            local character = player.Character
            local rootPart = character.HumanoidRootPart
            local humanoid = character:FindFirstChildOfClass("Humanoid")

            if humanoid.Health > 0 then
                local rootPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)

                if onScreen then
                    local scale = 1 / (rootPos.Z * math.tan(math.rad(Camera.FieldOfView / 2))) * 1000
                    local boxWidth = 3 * scale
                    local boxHeight = 4.5 * scale

                    obj.Box.Size = Vector2.new(boxWidth, boxHeight)
                    obj.Box.Position = Vector2.new(rootPos.X - boxWidth / 2, rootPos.Y - boxHeight / 2)
                    obj.Box.Visible = true

                    obj.Name.Text = player.Name
                    obj.Name.Position = Vector2.new(rootPos.X, rootPos.Y - boxHeight / 2 - 16)
                    obj.Name.Visible = true

                    local dist = math.floor((rootPart.Position - Camera.CFrame.Position).Magnitude)
                    obj.Distance.Text = tostring(dist) .. " studs"
                    obj.Distance.Position = Vector2.new(rootPos.X, rootPos.Y + boxHeight / 2 + 2)
                    obj.Distance.Visible = true

                    local healthPercentage = humanoid.Health / humanoid.MaxHealth
                    local barHeight = boxHeight * healthPercentage
                    
                    obj.HealthBarOutline.Size = Vector2.new(4, boxHeight)
                    obj.HealthBarOutline.Position = Vector2.new(rootPos.X - boxWidth / 2 - 7, rootPos.Y - boxHeight / 2)
                    obj.HealthBarOutline.Visible = true

                    obj.HealthBar.Size = Vector2.new(2, barHeight)
                    obj.HealthBar.Position = Vector2.new(rootPos.X - boxWidth / 2 - 6, rootPos.Y + boxHeight / 2 - barHeight)
                    obj.HealthBar.Color = Color3.fromHSV(healthPercentage * 0.33, 1, 1)
                    obj.HealthBar.Visible = true
                    
                    continue
                end
            end
        end
        for _, drawingObj in pairs(obj) do drawingObj.Visible = false end
    end
end)

ESPBtn.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    if ESPEnabled then
        ESPBtn.Text = "ESP WALLHACK: BẬT"
        ESPBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    else
        ESPBtn.Text = "ESP WALLHACK: TẮT"
        ESPBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end)
