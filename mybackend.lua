local Cheat = {}

local lg = {
    UserInputService = game:GetService("UserInputService"),
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    LocalPlayer = game:GetService("Players").LocalPlayer,
    fovCircle = Drawing.new("Circle"),
}

local setting = {
    aimbotEnabled = false,
    fovCircleEnabled = true,
    ignoreWalls = false,
    flying = false,
    flySpeed = 50,
    verticalSpeed = 80,
}

lg.fovCircle.Thickness = 2
lg.fovCircle.Radius = 100
lg.fovCircle.Position = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y / 2)
lg.fovCircle.Visible = false
lg.fovCircle.Color = Color3.new(1, 0, 0)

local function isInFOV(targetPosition)
    local screenPosition, onScreen = workspace.CurrentCamera:WorldToViewportPoint(targetPosition)
    if not onScreen then return false end
    local mousePosition = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y / 2)
    local distance = (Vector2.new(screenPosition.X, screenPosition.Y) - mousePosition).Magnitude
    return distance <= lg.fovCircle.Radius
end

local function hasClearLineOfSight(targetPart)
    if setting.ignoreWalls then
        return true
    end

    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {lg.LocalPlayer.Character}

    local origin = workspace.CurrentCamera.CFrame.Position
    local direction = (targetPart.Position - origin).Unit * (targetPart.Position - origin).Magnitude

    local rayResult = workspace:Raycast(origin, direction, rayParams)
    return not rayResult or rayResult.Instance:IsDescendantOf(targetPart.Parent)
end

local function getNearestPlayer()
    local localCharacter = lg.LocalPlayer.Character
    local localHumanoidRootPart = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")

    if not localHumanoidRootPart then
        return nil
    end

    local nearestPlayer = nil
    local shortestDistance = math.huge

    for _, player in pairs(lg.Players:GetPlayers()) do
        if player ~= lg.LocalPlayer and player.Team ~= lg.LocalPlayer.Team and player.Character and player.Character:FindFirstChild("Head") then
            local targetHumanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")

            if targetHumanoidRootPart and targetHumanoidRootPart:IsDescendantOf(workspace) then
                local distance = (localHumanoidRootPart.Position - targetHumanoidRootPart.Position).Magnitude
                local isInCircle = isInFOV(targetHumanoidRootPart.Position)
                local clearLOS = hasClearLineOfSight(targetHumanoidRootPart)

                if distance < shortestDistance and isInCircle and clearLOS then
                    shortestDistance = distance
                    nearestPlayer = targetHumanoidRootPart
                end
            end
        end
    end

    return nearestPlayer
end

local function isFirstPerson()
    local camera = workspace.CurrentCamera
    return (camera.CFrame.Position - camera.Focus.Position).Magnitude < 1
end

function Cheat.SetAimbot(state)
    setting.aimbotEnabled = state
    lg.fovCircle.Visible = state and setting.fovCircleEnabled
    print("Aimbot " .. (state and "activated" or "deactivated"))

    if state then
        lg.UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end

            if input.UserInputType == Enum.UserInputType.MouseButton2 then
                while setting.aimbotEnabled and lg.UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) do
                    if isFirstPerson() then
                        local nearestTarget = getNearestPlayer()

                        if nearestTarget then
                            local camera = workspace.CurrentCamera
                            camera.CFrame = CFrame.new(camera.CFrame.Position, nearestTarget.Position)
                        end
                    end

                    wait(0.03)
                end
            end
        end)

        lg.RunService.RenderStepped:Connect(function()
            lg.fovCircle.Position = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y / 2)
        end)
    end
end

function Cheat.UpdateFOVCircleSize(radius)
    lg.fovCircle.Radius = radius
    print("FOV Circle radius updated to " .. radius)
end

function Cheat.SetIgnoreWalls(state)
    setting.ignoreWalls = state
    print("Ignore walls set to " .. tostring(state))
end

function Cheat.speedmulitplaier(val)
    lg.RunService.RenderStepped:Connect(function(deltaTime)
    if lg.LocalPlayer.Character and lg.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local humanoid = lg.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        local rootPart = lg.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        
        if humanoid and rootPart then
            local currentVelocity = rootPart.AssemblyLinearVelocity
            local moveDirection = humanoid.MoveDirection
            local newVelocity = moveDirection * humanoid.WalkSpeed * val
            
            rootPart.AssemblyLinearVelocity = Vector3.new(newVelocity.X, currentVelocity.Y, newVelocity.Z)
        end
    end
end)
end

local function setCollisionFree(character, state)
    if not character then return end
    local partsToModify = {
        "HumanoidRootPart",
        "LowerTorso",
        "UpperTorso"
    }

    for _, partName in ipairs(partsToModify) do
        local part = character:FindFirstChild(partName)
        if part and part:IsA("BasePart") then
            part.CanCollide = not state
        end
    end
end

function Cheat.fly(state)
    local bodyVelocity
    local bodyGyro

    setting.flying = state

    if setting.flying then
        if not lg.LocalPlayer.Character or not lg.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            warn("Charakter oder HumanoidRootPart fehlt!")
            return
        end

        print("Flugmodus wird aktiviert...")
        local rootPart = lg.LocalPlayer.Character.HumanoidRootPart

        bodyVelocity = Instance.new("BodyVelocity", rootPart)
        bodyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
        bodyVelocity.Velocity = Vector3.zero

        bodyGyro = Instance.new("BodyGyro", rootPart)
        bodyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
        bodyGyro.CFrame = workspace.CurrentCamera.CFrame
        setCollisionFree(lg.LocalPlayer.Character, true)
        lg.RunService:BindToRenderStep("FlyMovement", Enum.RenderPriority.Character.Value, function()
            if not setting.flying then return end

            local camera = workspace.CurrentCamera
            local moveDirection = Vector3.zero
            if lg.UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveDirection += camera.CFrame.LookVector
            end
            if lg.UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveDirection -= camera.CFrame.LookVector
            end
            if lg.UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveDirection -= camera.CFrame.RightVector
            end
            if lg.UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveDirection += camera.CFrame.RightVector
            end
            if lg.UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveDirection += Vector3.new(0, 1, 0)
            end
            if lg.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                moveDirection -= Vector3.new(0, 1, 0)
            end
            if moveDirection.Magnitude > 0 then
                moveDirection = moveDirection.Unit
            end
            if bodyVelocity then
                bodyVelocity.Velocity = Vector3.new(
                    moveDirection.X * setting.flySpeed,
                    moveDirection.Y * setting.verticalSpeed,
                    moveDirection.Z * setting.flySpeed
                )
            end
            if bodyGyro then
                bodyGyro.CFrame = camera.CFrame
            end
        end)
    else
        if bodyVelocity then bodyVelocity:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end

        if lg.LocalPlayer.Character and lg.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            lg.LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.zero
        end
        setCollisionFree(lg.LocalPlayer.Character, false)
        lg.RunService:UnbindFromRenderStep("FlyMovement")
    end
end

lg.LocalPlayer.CharacterAdded:Connect(function()
    if setting.flying then
        task.wait(0.1)
        Cheat.fly(true)
    end
end)

return Cheat
