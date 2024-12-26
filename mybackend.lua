local Cheat = {}

local userInputService = game:GetService("UserInputService")
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local localPlayer = players.LocalPlayer

local aimbotEnabled = false
local fovCircleEnabled = true
local ignoreWalls = false

local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 2
fovCircle.Radius = 100
fovCircle.Position = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y / 2)
fovCircle.Visible = false
fovCircle.Color = Color3.new(1, 0, 0)

local function isInFOV(targetPosition)
    local screenPosition, onScreen = workspace.CurrentCamera:WorldToViewportPoint(targetPosition)
    if not onScreen then return false end
    local mousePosition = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y / 2)
    local distance = (Vector2.new(screenPosition.X, screenPosition.Y) - mousePosition).Magnitude
    return distance <= fovCircle.Radius
end

local function hasClearLineOfSight(targetPart)
    if ignoreWalls then
        return true
    end

    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {localPlayer.Character}

    local origin = workspace.CurrentCamera.CFrame.Position
    local direction = (targetPart.Position - origin).Unit * (targetPart.Position - origin).Magnitude

    local rayResult = workspace:Raycast(origin, direction, rayParams)
    return not rayResult or rayResult.Instance:IsDescendantOf(targetPart.Parent)
end

local function getNearestPlayer()
    local localCharacter = localPlayer.Character
    local localHumanoidRootPart = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")

    if not localHumanoidRootPart then
        return nil
    end

    local nearestPlayer = nil
    local shortestDistance = math.huge

    for _, player in pairs(players:GetPlayers()) do
        if player ~= localPlayer and player.Team ~= localPlayer.Team and player.Character and player.Character:FindFirstChild("Head") then
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
    aimbotEnabled = state
    fovCircle.Visible = state and fovCircleEnabled
    print("Aimbot " .. (state and "activated" or "deactivated"))

    if state then
        userInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end

            if input.UserInputType == Enum.UserInputType.MouseButton2 then
                while aimbotEnabled and userInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) do
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

        runService.RenderStepped:Connect(function()
            fovCircle.Position = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y / 2)
        end)
    end
end

function Cheat.UpdateFOVCircleSize(radius)
    fovCircle.Radius = radius
    print("FOV Circle radius updated to " .. radius)
end

function Cheat.SetIgnoreWalls(state)
    ignoreWalls = state
    print("Ignore walls set to " .. tostring(state))
end

return Cheat
