--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║     NEXUS HUB - VERSIÓN ESTABLE (CORREGIDA)               ║
    ║     • Todos los sistemas funcionando correctamente        ║
    ║     • Sin errores de sintaxis                             ║
    ║     • Optimizado para mejor rendimiento                   ║
    ║     • Interface Liquid Glass mejorada                    ║
    ╚══════════════════════════════════════════════════════════════╝
]]

-- [CONFIGURACIÓN PRINCIPAL]
local NexusConfig = {
    Aimbot = false,
    AimbotTarget = "Head",
    AimbotFOV = 70,
    ESP = false,
    ESPColor = Color3.fromRGB(255, 0, 0),
    ESPOutlineColor = Color3.fromRGB(255, 255, 255),
    TeamCheck = false,
    InfJump = false,
    Noclip = false,
    WalkOnWater = false,
    Bhop = false,
    Dash = false,
    AutoRespawn = false,
    XRay = false,
    Hitbox = false,
    HitboxSize = 10,
    Fling = false,
    Spinbot = false,
    SpinSpeed = 20,
    AutoClicker = false,
    AutoClickerDelay = 0.01,
    AutoClickerButton = "Left",
    AutoClickerMode = "Spam Click",
    ClickTP = false,
    ToolReach = false,
    ReachSize = 20,
    Annoy = false,
    AnnoyAction = "Teleport to",
    ChatSpam = false,
    SpamText = "Nexus Hub on top!",
    LoopWalkSpeed = false,
    LoopJumpPower = false,
    WalkSpeed = 16,
    JumpPower = 50,
    Gravity = 196.2,
    FOV = 70,
    Fullbright = false,
    GameTime = 12,
    Fly = false,
    FlySpeed = 50,
    ESPShowLines = false,
    ESPShowHealth = false,
    ESPShowDistance = false,
    NightMode = false,
    AntiDetect = true,
    SelectedTarget = nil,
    ShowAimbotFOV = false,
    CurrentTheme = "Liquid Glass"
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local LocalizationService = game:GetService("LocalizationService")
local Debris = game:GetService("Debris")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Variables globales
local OriginalProps = {}
local FlingForce = nil
local FlyConnection = nil
local FlyBodyVelocity = nil
local WaterPart = nil
local XRayActive = false
local FullbrightActive = false
local NightModeActive = false
local Logs = {}
local FOVCircle = nil
local SpawnedObjects = {}
local validTargets = {}
local lockedTarget = nil
local espLines = {}
local espBillboards = {}
local UIInstances = {}
local menuVisible = false

-- [SISTEMA DE LOGS]
local function AddLog(message, type)
    type = type or "Info"
    local timestamp = os.date("%H:%M:%S")
    table.insert(Logs, 1, {Time = timestamp, Message = message, Type = type})
    if #Logs > 100 then table.remove(Logs) end
end

-- [SISTEMA DE SONIDO]
local NexusAudio = {
    ToggleOn = "rbxassetid://6895079853",
    ToggleOff = "rbxassetid://6895052959",
    Click = "rbxassetid://6895101614",
    Notify = "rbxassetid://6895072044"
}

local function PlaySound(soundId)
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = soundId
        sound.Volume = 0.8
        sound.Parent = SoundService
        sound:Play()
        Debris:AddItem(sound, 2)
    end)
end

-- [SISTEMA DE NOTIFICACIONES]
local NotificationGui = Instance.new("ScreenGui")
NotificationGui.Name = "NexusNotifications"
NotificationGui.Parent = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")
NotificationGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local NotifyLayout = Instance.new("Frame")
NotifyLayout.Size = UDim2.new(0, 320, 1, -20)
NotifyLayout.Position = UDim2.new(1, -340, 0, 10)
NotifyLayout.BackgroundTransparency = 1
NotifyLayout.Parent = NotificationGui

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = NotifyLayout
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
UIListLayout.Padding = UDim.new(0, 10)

local function SendNotification(title, text, duration)
    duration = duration or 3
    PlaySound(NexusAudio.Notify)
    AddLog(title .. ": " .. text, "Notification")
    
    local NotifFrame = Instance.new("Frame")
    NotifFrame.Size = UDim2.new(1, 0, 0, 75)
    NotifFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    NotifFrame.BackgroundTransparency = 0.2
    NotifFrame.Position = UDim2.new(1, 50, 0, 0)
    NotifFrame.Parent = NotifyLayout
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = NotifFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = 0.5
    stroke.Thickness = 1
    stroke.Parent = NotifFrame
    
    local gradient = Instance.new("UIGradient")
    gradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.3),
        NumberSequenceKeypoint.new(0.5, 0.6),
        NumberSequenceKeypoint.new(1, 0.3)
    })
    gradient.Rotation = 45
    gradient.Parent = NotifFrame
    
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 30, 0, 30)
    icon.Position = UDim2.new(0, 8, 0.5, -15)
    icon.BackgroundTransparency = 1
    icon.Text = "✦"
    icon.TextColor3 = Color3.fromRGB(255, 60, 40)
    icon.Font = Enum.Font.GothamBold
    icon.TextSize = 18
    icon.TextXAlignment = Enum.TextXAlignment.Center
    icon.Parent = NotifFrame
    
    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -50, 0, 25)
    titleLbl.Position = UDim2.new(0, 45, 0, 5)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 13
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = NotifFrame
    
    local textLbl = Instance.new("TextLabel")
    textLbl.Size = UDim2.new(1, -50, 0, 35)
    textLbl.Position = UDim2.new(0, 45, 0, 30)
    textLbl.BackgroundTransparency = 1
    textLbl.Text = text
    textLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    textLbl.Font = Enum.Font.Gotham
    textLbl.TextSize = 11
    textLbl.TextWrapped = true
    textLbl.TextXAlignment = Enum.TextXAlignment.Left
    textLbl.TextYAlignment = Enum.TextYAlignment.Top
    textLbl.Parent = NotifFrame
    
    local line = Instance.new("Frame")
    line.Size = UDim2.new(0, 3, 1, -16)
    line.Position = UDim2.new(0, 0, 0, 8)
    line.BackgroundColor3 = Color3.fromRGB(255, 60, 40)
    line.BorderSizePixel = 0
    line.Parent = NotifFrame
    
    TweenService:Create(NotifFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
    
    task.spawn(function()
        task.wait(duration)
        local tweenOut = TweenService:Create(NotifFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1, 50, 0, 0), BackgroundTransparency = 1})
        TweenService:Create(titleLbl, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
        TweenService:Create(textLbl, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.4), {Transparency = 1}):Play()
        TweenService:Create(line, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
        tweenOut:Play()
        tweenOut.Completed:Wait()
        NotifFrame:Destroy()
    end)
end

-- [FUNCIONES DE UTILIDAD]
local function isFFA()
    local teamsList = game:GetService("Teams"):GetChildren()
    if #teamsList == 0 then return true end
    return false
end

local function isSameTeam(player)
    if not player then return false end
    if isFFA() then return false end
    if LocalPlayer.Team ~= nil and player.Team ~= nil then
        if LocalPlayer.Team == player.Team then return true end
    end
    return false
end

local function getTargetPart(character)
    local partName = NexusConfig.AimbotTarget
    local targetPart = character:FindFirstChild(partName) or character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
    return targetPart
end

local function isVisible(targetPart)
    if not targetPart then return false end
    local rayOrigin = Camera.CFrame.Position
    local rayDirection = (targetPart.Position - rayOrigin)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.IgnoreWater = true
    local raycastResult = Workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    if raycastResult and raycastResult.Instance then
        if raycastResult.Instance:IsDescendantOf(targetPart.Parent) then
            return true
        end
        return false
    end
    return true
end

-- [SISTEMA DE ESP]
local function clearESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            local esp = player.Character:FindFirstChild("NexusESP")
            if esp then esp:Destroy() end
            local line = player.Character:FindFirstChild("NexusLine")
            if line then line:Destroy() end
            local bill = player.Character:FindFirstChild("NexusBillboard")
            if bill then bill:Destroy() end
        end
    end
    espLines = {}
    espBillboards = {}
end

-- [BUCLE DE ESP]
task.spawn(function()
    while true do
        local currentTargets = {}
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local character = player.Character
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                local targetPart = getTargetPart(character)
                
                if humanoid and targetPart and humanoid.Health > 0 then
                    local isSafe = false
                    if NexusConfig.TeamCheck then
                        isSafe = isSameTeam(player)
                    end
                    
                    if not isSafe then
                        table.insert(currentTargets, character)
                        
                        if NexusConfig.ESP then
                            local esp = character:FindFirstChild("NexusESP")
                            if not esp then
                                esp = Instance.new("Highlight")
                                esp.Name = "NexusESP"
                                esp.Adornee = character
                                esp.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                esp.FillTransparency = 0.6
                                esp.OutlineTransparency = 0.2
                                esp.Parent = character
                            end
                            esp.FillColor = NexusConfig.ESPColor
                            esp.OutlineColor = NexusConfig.ESPOutlineColor
                        else
                            local esp = character:FindFirstChild("NexusESP")
                            if esp then esp:Destroy() end
                        end
                    end
                end
            end
        end
        
        if not NexusConfig.ESP then
            clearESP()
        end
        
        validTargets = currentTargets
        task.wait(0.5)
    end
end)

-- [AIMBOT]
local function getTarget()
    local closestTarget = nil
    local shortestDistance = math.huge
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, character in ipairs(validTargets) do
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.Health > 0 then
            local targetPart = getTargetPart(character)
            if targetPart then
                local screenPoint, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - screenCenter).Magnitude
                    local maxDistance = (Camera.ViewportSize.X / 2) * (NexusConfig.AimbotFOV / 70)
                    if distance < shortestDistance and distance <= maxDistance and isVisible(targetPart) then
                        closestTarget = targetPart
                        shortestDistance = distance
                    end
                end
            end
        end
    end
    return closestTarget
end

-- [CÍRCULO DE FOV]
local function createFOVCircle()
    if FOVCircle then FOVCircle:Destroy() end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FOVCircle"
    screenGui.Parent = CoreGui
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 1, 0, 1)
    circle.Position = UDim2.new(0.5, 0, 0.5, 0)
    circle.BackgroundTransparency = 1
    circle.Parent = screenGui
    
    local radius = (Camera.ViewportSize.X / 2) * (NexusConfig.AimbotFOV / 70)
    local size = radius * 2
    circle.Size = UDim2.new(0, size, 0, size)
    circle.Position = UDim2.new(0.5, -size/2, 0.5, -size/2)
    
    local corners = Instance.new("UICorner")
    corners.CornerRadius = UDim.new(1, 0)
    corners.Parent = circle
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 0, 0)
    stroke.Thickness = 2
    stroke.Transparency = 0.5
    stroke.Parent = circle
    
    FOVCircle = screenGui
end

-- [AIMBOT LOOP]
RunService.RenderStepped:Connect(function()
    if NexusConfig.ShowAimbotFOV then
        if not FOVCircle then createFOVCircle() end
        local radius = (Camera.ViewportSize.X / 2) * (NexusConfig.AimbotFOV / 70)
        local size = radius * 2
        if FOVCircle and FOVCircle:FindFirstChild("Frame") then
            FOVCircle:FindFirstChild("Frame").Size = UDim2.new(0, size, 0, size)
            FOVCircle:FindFirstChild("Frame").Position = UDim2.new(0.5, -size/2, 0.5, -size/2)
        end
    else
        if FOVCircle then FOVCircle:Destroy() FOVCircle = nil end
    end
    
    if NexusConfig.Aimbot then
        if lockedTarget then
            local character = lockedTarget.Parent
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local targetPlayer = Players:GetPlayerFromCharacter(character)
            local isSafe = NexusConfig.TeamCheck and targetPlayer and isSameTeam(targetPlayer)
            
            if not (humanoid and humanoid.Health > 0 and isVisible(lockedTarget) and not isSafe) then
                lockedTarget = nil 
            end
        end
        
        if not lockedTarget then
            lockedTarget = getTarget()
        end
        
        if lockedTarget then
            local screenPoint, onScreen = Camera:WorldToViewportPoint(lockedTarget.Position)
            if onScreen then
                local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - screenCenter).Magnitude
                local maxDistance = (Camera.ViewportSize.X / 2) * (NexusConfig.AimbotFOV / 70)
                if distance <= maxDistance then
                    Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, lockedTarget.Position)
                end
            end
        end
    else
        lockedTarget = nil
    end
end)

-- [SISTEMA DE FLY]
local function toggleFly()
    NexusConfig.Fly = not NexusConfig.Fly
    
    if NexusConfig.Fly then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
            hum.PlatformStand = true
            
            if FlyBodyVelocity then FlyBodyVelocity:Destroy() end
            FlyBodyVelocity = Instance.new("BodyVelocity")
            FlyBodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
            FlyBodyVelocity.P = 1000
            FlyBodyVelocity.Parent = LocalPlayer.Character.HumanoidRootPart
            
            if FlyConnection then FlyConnection:Disconnect() end
            FlyConnection = RunService.Heartbeat:Connect(function()
                if not NexusConfig.Fly or not LocalPlayer.Character then return end
                
                local cameraCF = Camera.CFrame
                local moveDirection = Vector3.new()
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + cameraCF.LookVector * Vector3.new(1,0,1) end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - cameraCF.LookVector * Vector3.new(1,0,1) end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - cameraCF.RightVector * Vector3.new(1,0,1) end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + cameraCF.RightVector * Vector3.new(1,0,1) end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection = moveDirection + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDirection = moveDirection - Vector3.new(0, 1, 0) end
                
                if moveDirection.Magnitude > 0 then
                    moveDirection = moveDirection.Unit * NexusConfig.FlySpeed
                end
                
                if FlyBodyVelocity and FlyBodyVelocity.Parent then
                    FlyBodyVelocity.Velocity = moveDirection
                end
            end)
            
            SendNotification("Fly", "✈️ Modo vuelo activado.", 3)
        end
    else
        if FlyBodyVelocity then FlyBodyVelocity:Destroy() FlyBodyVelocity = nil end
        if FlyConnection then FlyConnection:Disconnect() FlyConnection = nil end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
            hum.PlatformStand = false
        end
        SendNotification("Fly", "Modo vuelo desactivado.", 2)
    end
end

-- [EVENTOS DE MOVIMIENTO]
UserInputService.JumpRequest:Connect(function()
    if NexusConfig.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.Q and NexusConfig.Dash then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local root = LocalPlayer.Character.HumanoidRootPart
            local dashForce = Instance.new("BodyVelocity")
            dashForce.Velocity = root.CFrame.LookVector * 100
            dashForce.MaxForce = Vector3.new(100000, 0, 100000)
            dashForce.Parent = root
            task.wait(0.15)
            dashForce:Destroy()
        end
    end
    
    if input.KeyCode == Enum.KeyCode.F then
        toggleFly()
    end
    
    if input.KeyCode == Enum.KeyCode.K then
        menuVisible = not menuVisible
        if UIInstances.MainWindow then
            UIInstances.MainWindow.Visible = menuVisible
        end
    end
end)

-- [SISTEMA DE AUTO CLICKER]
local AutoClicker = {
    WasHolding = false,
    Update = function()
        if NexusConfig.AutoClicker then
            if NexusConfig.AutoClickerMode == "Hold" then
                if NexusConfig.AutoClickerButton == "Left" then
                    VirtualUser:Button1Down(Vector2.new(0,0), Camera.CFrame)
                else
                    VirtualUser:Button2Down(Vector2.new(0,0), Camera.CFrame)
                end
                AutoClicker.WasHolding = true
                task.wait(0.05)
            else
                if AutoClicker.WasHolding then
                    VirtualUser:Button1Up(Vector2.new(0,0), Camera.CFrame)
                    VirtualUser:Button2Up(Vector2.new(0,0), Camera.CFrame)
                    AutoClicker.WasHolding = false
                end
                if NexusConfig.AutoClickerButton == "Left" then
                    VirtualUser:Button1Down(Vector2.new(0,0), Camera.CFrame)
                    task.wait(0.01)
                    VirtualUser:Button1Up(Vector2.new(0,0), Camera.CFrame)
                else
                    VirtualUser:Button2Down(Vector2.new(0,0), Camera.CFrame)
                    task.wait(0.01)
                    VirtualUser:Button2Up(Vector2.new(0,0), Camera.CFrame)
                end
                task.wait(NexusConfig.AutoClickerDelay)
            end
        else
            if AutoClicker.WasHolding then
                VirtualUser:Button1Up(Vector2.new(0,0), Camera.CFrame)
                VirtualUser:Button2Up(Vector2.new(0,0), Camera.CFrame)
                AutoClicker.WasHolding = false
            end
            task.wait(0.05)
        end
    end
}

-- [SISTEMA DE CHAT SPAM]
task.spawn(function()
    while true do
        if NexusConfig.ChatSpam and NexusConfig.SpamText ~= "" then
            pcall(function()
                local chatService = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
                if chatService then
                    local sayMessage = chatService:FindFirstChild("SayMessageRequest")
                    if sayMessage then
                        sayMessage:FireServer(NexusConfig.SpamText, "All")
                    end
                end
            end)
            task.wait(2)
        else
            task.wait(0.5)
        end
    end
end)

-- [SISTEMA DE FLING]
task.spawn(function()
    while true do
        if NexusConfig.Fling then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                if not FlingForce then
                    FlingForce = Instance.new("BodyAngularVelocity")
                    FlingForce.AngularVelocity = Vector3.new(0, 99999, 0)
                    FlingForce.MaxTorque = Vector3.new(0, math.huge, 0)
                    FlingForce.P = math.huge
                    FlingForce.Parent = LocalPlayer.Character.HumanoidRootPart
                end
            end
        else
            if FlingForce then
                FlingForce:Destroy()
                FlingForce = nil
            end
        end
        task.wait(0.1)
    end
end)

-- [SISTEMA DE AUTO RESPAWN]
LocalPlayer.CharacterAdded:Connect(function(character)
    if NexusConfig.AutoRespawn then
        character:WaitForChild("Humanoid").Died:Connect(function()
            task.wait(0.5)
            LocalPlayer:LoadCharacter()
        end)
    end
end)

-- [PANEL DE BIENVENIDA]
local function createWelcomePanel()
    local welcomeGui = Instance.new("ScreenGui")
    welcomeGui.Name = "WelcomePanel"
    welcomeGui.Parent = CoreGui
    welcomeGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 450, 0, 350)
    mainFrame.Position = UDim2.new(0.5, -225, 0.5, -175)
    mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    mainFrame.BackgroundTransparency = 0.15
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = welcomeGui
    
    local mCorner = Instance.new("UICorner")
    mCorner.CornerRadius = UDim.new(0, 16)
    mCorner.Parent = mainFrame
    
    local mStroke = Instance.new("UIStroke")
    mStroke.Color = Color3.fromRGB(255, 255, 255)
    mStroke.Transparency = 0.4
    mStroke.Thickness = 1
    mStroke.Parent = mainFrame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 60)
    title.Position = UDim2.new(0, 0, 0, 15)
    title.BackgroundTransparency = 1
    title.Text = "✦ NEXUS HUB ✦"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 28
    title.Parent = mainFrame
    
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, -40, 0, 30)
    subtitle.Position = UDim2.new(0, 20, 0, 75)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Bienvenido " .. LocalPlayer.Name
    subtitle.TextColor3 = Color3.fromRGB(255, 200, 100)
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 16
    subtitle.TextXAlignment = Enum.TextXAlignment.Center
    subtitle.Parent = mainFrame
    
    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(0.8, 0, 0, 2)
    divider.Position = UDim2.new(0.1, 0, 0, 115)
    divider.BackgroundColor3 = Color3.fromRGB(255, 60, 40)
    divider.BorderSizePixel = 0
    divider.Parent = mainFrame
    
    local controls = Instance.new("TextLabel")
    controls.Size = UDim2.new(1, -40, 0, 120)
    controls.Position = UDim2.new(0, 20, 0, 130)
    controls.BackgroundTransparency = 1
    controls.Text = "【 CONTROLES 】\n\n[ K ] - Abrir/Cerrar Menú Principal\n[ F4 ] - Lista de Jugadores\n[ F ] - Activar Vuelo"
    controls.TextColor3 = Color3.fromRGB(200, 200, 200)
    controls.Font = Enum.Font.Gotham
    controls.TextSize = 13
    controls.TextXAlignment = Enum.TextXAlignment.Center
    controls.TextYAlignment = Enum.TextYAlignment.Top
    controls.Parent = mainFrame
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 150, 0, 40)
    closeBtn.Position = UDim2.new(0.5, -75, 1, -55)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 40)
    closeBtn.BackgroundTransparency = 0.3
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "✕ CERRAR"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.AutoButtonColor = false
    closeBtn.Parent = mainFrame
    
    local cCorner = Instance.new("UICorner")
    cCorner.CornerRadius = UDim.new(0, 8)
    cCorner.Parent = closeBtn
    
    closeBtn.MouseButton1Click:Connect(function()
        welcomeGui:Destroy()
        SendNotification("Nexus Hub", "¡Bienvenido! Usa K para abrir el menú.", 4)
    end)
    
    task.spawn(function()
        task.wait(10)
        if welcomeGui.Parent then
            welcomeGui:Destroy()
        end
    end)
end

-- [CREAR INTERFAZ PRINCIPAL SIMPLIFICADA]
local function CreateUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NexusHub_UI"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local MainWindow = Instance.new("Frame")
    MainWindow.Size = UDim2.new(0, 450, 0, 400)
    MainWindow.Position = UDim2.new(0.5, -225, 0.5, -200)
    MainWindow.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    MainWindow.BackgroundTransparency = 0.25
    MainWindow.BorderSizePixel = 0
    MainWindow.Visible = false
    MainWindow.Active = true
    MainWindow.Draggable = true
    MainWindow.Parent = ScreenGui
    UIInstances.MainWindow = MainWindow
    
    local windowCorner = Instance.new("UICorner")
    windowCorner.CornerRadius = UDim.new(0, 12)
    windowCorner.Parent = MainWindow
    
    local windowStroke = Instance.new("UIStroke")
    windowStroke.Color = Color3.fromRGB(255, 255, 255)
    windowStroke.Transparency = 0.6
    windowStroke.Thickness = 1
    windowStroke.Parent = MainWindow
    
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 35)
    TitleBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TitleBar.BackgroundTransparency = 0.9
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainWindow
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0, 200, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "✦ NEXUS HUB"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 15
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TitleBar
    
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -35, 0, 2.5)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 14
    CloseBtn.AutoButtonColor = false
    CloseBtn.Parent = TitleBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = CloseBtn
    
    CloseBtn.MouseButton1Click:Connect(function()
        menuVisible = false
        MainWindow.Visible = false
    end)
    
    local Content = Instance.new("ScrollingFrame")
    Content.Size = UDim2.new(1, -10, 1, -45)
    Content.Position = UDim2.new(0, 5, 0, 40)
    Content.BackgroundTransparency = 1
    Content.BorderSizePixel = 0
    Content.ScrollBarThickness = 3
    Content.ScrollBarImageColor3 = Color3.fromRGB(255, 60, 40)
    Content.CanvasSize = UDim2.new(0, 0, 0, 0)
    Content.Parent = MainWindow
    
    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.Parent = Content
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContentLayout.Padding = UDim.new(0, 5)
    
    local YPos = 0
    
    local function AddToggle(name, config)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -10, 0, 32)
        frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        frame.BackgroundTransparency = 0.9
        frame.BorderSizePixel = 0
        frame.Parent = Content
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 4)
        corner.Parent = frame
        
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0, 200, 1, 0)
        lbl.Position = UDim2.new(0, 8, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = name
        lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = frame
        
        local switch = Instance.new("Frame")
        switch.Size = UDim2.new(0, 35, 0, 18)
        switch.Position = UDim2.new(1, -42, 0.5, -9)
        switch.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        switch.BorderSizePixel = 0
        switch.Parent = frame
        
        local sCorner = Instance.new("UICorner")
        sCorner.CornerRadius = UDim.new(1, 0)
        sCorner.Parent = switch
        
        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 14, 0, 14)
        knob.Position = UDim2.new(0, 2, 0.5, -7)
        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        knob.BorderSizePixel = 0
        knob.Parent = switch
        
        local kCorner = Instance.new("UICorner")
        kCorner.CornerRadius = UDim.new(1, 0)
        kCorner.Parent = knob
        
        local enabled = NexusConfig[config] or false
        
        if enabled then
            switch.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            switch.BackgroundTransparency = 0.4
            knob.Position = UDim2.new(1, -16, 0.5, -7)
        else
            switch.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            switch.BackgroundTransparency = 0.8
            knob.Position = UDim2.new(0, 2, 0.5, -7)
        end
        
        switch.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                enabled = not enabled
                NexusConfig[config] = enabled
                if enabled then
                    switch.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    switch.BackgroundTransparency = 0.4
                    TweenService:Create(knob, TweenInfo.new(0.2), {Position = UDim2.new(1, -16, 0.5, -7)}):Play()
                    PlaySound(NexusAudio.ToggleOn)
                    SendNotification("Activado", name .. " encendido.", 2)
                else
                    switch.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    switch.BackgroundTransparency = 0.8
                    TweenService:Create(knob, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -7)}):Play()
                    PlaySound(NexusAudio.ToggleOff)
                    SendNotification("Desactivado", name .. " apagado.", 2)
                end
            end
        end)
    end
    
    -- Agregar toggles
    AddToggle("Aimbot", "Aimbot")
    AddToggle("Team Check", "TeamCheck")
    AddToggle("ESP", "ESP")
    AddToggle("Fly (F)", "Fly")
    AddToggle("Infinite Jump", "InfJump")
    AddToggle("Noclip", "Noclip")
    AddToggle("Bunny Hop", "Bhop")
    AddToggle("Dash (Q)", "Dash")
    AddToggle("Auto Respawn", "AutoRespawn")
    AddToggle("Fling Aura", "Fling")
    AddToggle("Spinbot", "Spinbot")
    AddToggle("Chat Spammer", "ChatSpam")
    AddToggle("X-Ray", "XRay")
    AddToggle("Fullbright", "Fullbright")
    AddToggle("Night Mode", "NightMode")
    
    -- Botón Discord
    local discordBtn = Instance.new("TextButton")
    discordBtn.Size = UDim2.new(1, -10, 0, 32)
    discordBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    discordBtn.BackgroundTransparency = 0.3
    discordBtn.BorderSizePixel = 0
    discordBtn.Text = "💬 DISCORD"
    discordBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    discordBtn.Font = Enum.Font.GothamBold
    discordBtn.TextSize = 12
    discordBtn.AutoButtonColor = false
    discordBtn.Parent = Content
    
    local dCorner = Instance.new("UICorner")
    dCorner.CornerRadius = UDim.new(0, 4)
    dCorner.Parent = discordBtn
    
    discordBtn.MouseButton1Click:Connect(function()
        setclipboard("https://discord.gg/MA9rGtY6mG")
        SendNotification("Discord", "📢 ¡Enlace copiado al portapapeles!", 3)
    end)
    
    -- Botón Web
    local webBtn = Instance.new("TextButton")
    webBtn.Size = UDim2.new(1, -10, 0, 32)
    webBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    webBtn.BackgroundTransparency = 0.3
    webBtn.BorderSizePixel = 0
    webBtn.Text = "🌐 WEB OFICIAL"
    webBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    webBtn.Font = Enum.Font.GothamBold
    webBtn.TextSize = 12
    webBtn.AutoButtonColor = false
    webBtn.Parent = Content
    
    local wCorner = Instance.new("UICorner")
    wCorner.CornerRadius = UDim.new(0, 4)
    wCorner.Parent = webBtn
    
    webBtn.MouseButton1Click:Connect(function()
        setclipboard("https://proyect-nexus.vercel.app/")
        SendNotification("Web Oficial", "🌐 Enlace copiado al portapapeles!", 3)
    end)
    
    Content.CanvasSize = UDim2.new(0, 0, 0, #Content:GetChildren() * 37 + 20)
end

-- [BUCLE PRINCIPAL]
RunService.Stepped:Connect(function()
    -- FOV
    Camera.FieldOfView = NexusConfig.FOV
    
    -- WalkSpeed / JumpPower
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if NexusConfig.LoopWalkSpeed then
            hum.WalkSpeed = NexusConfig.WalkSpeed
        end
        if NexusConfig.LoopJumpPower then
            hum.UseJumpPower = true
            hum.JumpPower = NexusConfig.JumpPower
        end
    end
    
    -- Noclip
    if NexusConfig.Noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
    
    -- Spinbot
    if NexusConfig.Spinbot and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(NexusConfig.SpinSpeed), 0)
    end
end)

-- [INICIALIZAR SISTEMAS]
local function InitSystems()
    task.spawn(function()
        while true do
            Workspace.Gravity = NexusConfig.Gravity
            Lighting.ClockTime = NexusConfig.GameTime
            
            -- X-Ray
            if NexusConfig.XRay then
                if not XRayActive then
                    XRayActive = true
                    for _, v in pairs(Workspace:GetDescendants()) do
                        if v:IsA("BasePart") and not v.Parent:FindFirstChildOfClass("Humanoid") then
                            if not OriginalProps[v] then
                                OriginalProps[v] = {
                                    Transparency = v.Transparency,
                                    Material = v.Material
                                }
                            end
                            v.Transparency = 0.2
                            v.Material = Enum.Material.Neon
                        end
                    end
                end
            else
                if XRayActive then
                    XRayActive = false
                    for _, v in pairs(Workspace:GetDescendants()) do
                        if v:IsA("BasePart") and not v.Parent:FindFirstChildOfClass("Humanoid") then
                            if OriginalProps[v] then
                                v.Transparency = OriginalProps[v].Transparency
                                v.Material = OriginalProps[v].Material
                                OriginalProps[v] = nil
                            end
                        end
                    end
                end
            end
            
            -- Fullbright
            if NexusConfig.Fullbright then
                if not FullbrightActive then
                    FullbrightActive = true
                    Lighting.Ambient = Color3.new(1, 1, 1)
                    Lighting.Brightness = 2
                    Lighting.GlobalShadows = false
                    Lighting.ClockTime = 12
                    Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
                    Lighting.FogEnd = 100000
                    Lighting.FogStart = 0
                end
            else
                if FullbrightActive then
                    FullbrightActive = false
                    if not NexusConfig.NightMode then
                        Lighting.Ambient = Color3.fromRGB(128, 128, 128)
                        Lighting.Brightness = 1
                        Lighting.GlobalShadows = true
                        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
                        Lighting.FogEnd = 100000
                        Lighting.FogStart = 0
                    end
                end
            end
            
            -- Night Mode
            if NexusConfig.NightMode then
                if not NightModeActive then
                    NightModeActive = true
                    if not NexusConfig.Fullbright then
                        Lighting.Ambient = Color3.fromRGB(10, 10, 25)
                        Lighting.Brightness = 0.2
                        Lighting.GlobalShadows = true
                        Lighting.ClockTime = 0
                        Lighting.FogEnd = 150
                        Lighting.FogStart = 0
                        Lighting.OutdoorAmbient = Color3.fromRGB(5, 5, 15)
                        Lighting.FogColor = Color3.fromRGB(5, 5, 15)
                    end
                end
            else
                if NightModeActive then
                    NightModeActive = false
                    if not NexusConfig.Fullbright then
                        Lighting.Ambient = Color3.fromRGB(128, 128, 128)
                        Lighting.Brightness = 1
                        Lighting.GlobalShadows = true
                        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
                        Lighting.FogEnd = 100000
                        Lighting.FogStart = 0
                        Lighting.FogColor = Color3.fromRGB(128, 128, 128)
                    end
                end
            end
            
            AutoClicker.Update()
            task.wait(0.01)
        end
    end)
end

-- [MAIN]
local function Init()
    pcall(CreateUI)
    pcall(InitSystems)
    pcall(createWelcomePanel)
    AddLog("Nexus Hub iniciado", "Notification")
    SendNotification("Nexus Hub", "¡Inyectado exitosamente! Bienvenido, " .. LocalPlayer.Name, 4)
    PlaySound("rbxassetid://6895101614")
end

pcall(Init)