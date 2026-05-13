--// Auto Follow Players
--// บินแบบปกติ ไม่ Tween
--// ถ้าเข้าใกล้แล้วเลือดไม่ลดใน 3 วิ เปลี่ยนคน
--// Auto Hold Blox Fruit
--// Auto Hit Nearest Player (Pain-Pain)
--// Auto Server Hop ทุก 5 นาที

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId

local FlyHeight = 0
local FlySpeed = 300
local CheckDistance = 15

local SERVER_HOP_TIME = 300 -- 5 นาที

-- กันรันซ้ำ
if _G.AutoFollowPlayers then
    _G.AutoFollowPlayers = false
    task.wait()
end

_G.AutoFollowPlayers = true
_G.AutoHitNearestPlayer = true

--========================
-- Auto Server Hop
--========================
task.spawn(function()

    task.wait(SERVER_HOP_TIME)

    if not _G.AutoFollowPlayers then
        return
    end

    local success, result = pcall(function()

        local servers = {}
        local cursor = ""

        repeat
            local url =
                "https://games.roblox.com/v1/games/"
                .. PlaceId
                .. "/servers/Public?sortOrder=Asc&limit=100&cursor="
                .. cursor

            local body = game:HttpGet(url)
            local data = HttpService:JSONDecode(body)

            for _, v in pairs(data.data) do
                if v.playing < v.maxPlayers
                and v.id ~= game.JobId then
                    table.insert(servers, v.id)
                end
            end

            cursor = data.nextPageCursor or ""

        until cursor == ""

        if #servers > 0 then

            local server =
                servers[math.random(1, #servers)]

            TeleportService:TeleportToPlaceInstance(
                PlaceId,
                server,
                LocalPlayer
            )
        end
    end)

    if not success then
        warn("Server Hop Error:", result)
    end
end)

--========================
-- Auto Hold Blox Fruit
--========================
task.spawn(function()
    while _G.AutoFollowPlayers do
        pcall(function()

            local backpack = LocalPlayer:FindFirstChild("Backpack")
            local character = LocalPlayer.Character

            if backpack and character then

                for _, tool in ipairs(backpack:GetChildren()) do
                    if tool:IsA("Tool") then

                        local tooltip = tostring(tool.ToolTip)

                        if tooltip:lower():find("blox fruit") then
                            tool.Parent = character
                            break
                        end
                    end
                end

                for _, tool in ipairs(character:GetChildren()) do
                    if tool:IsA("Tool") then

                        local tooltip = tostring(tool.ToolTip)

                        if tooltip:lower():find("blox fruit") then
                            character.Humanoid:EquipTool(tool)
                            break
                        end
                    end
                end
            end
        end)

        task.wait(1)
    end
end)

--========================
-- หาเป้าหมายบิน
--========================
local function GetNextPlayer(ignoreTable)

    local myChar = LocalPlayer.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")

    if not myHRP then
        return nil
    end

    local closestPlayer = nil
    local closestDistance = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not ignoreTable[player] then

            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChild("Humanoid")

            if hrp and hum and hum.Health > 0 then

                local dist = (myHRP.Position - hrp.Position).Magnitude

                if dist < closestDistance then
                    closestDistance = dist
                    closestPlayer = player
                end
            end
        end
    end

    return closestPlayer
end

--========================
-- Main Follow
--========================
task.spawn(function()

    local ignored = {}

    while _G.AutoFollowPlayers do

        local target = GetNextPlayer(ignored)

        if not target then
            ignored = {}
            task.wait(1)
            continue
        end

        local char = target.Character
        local hum = char and char:FindFirstChild("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")

        if hum and hrp and hum.Health > 0 then

            local oldHealth = hum.Health
            local lastDamage = tick()
            local startedCheck = false

            while _G.AutoFollowPlayers
                and target.Parent
                and hum.Health > 0 do

                local myChar = LocalPlayer.Character
                local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")

                if myHRP then

                    local targetPos =
                        hrp.Position + Vector3.new(0, FlyHeight, 0)

                    local offset = targetPos - myHRP.Position
                    local distance = offset.Magnitude

                    if distance > 3 then

                        local direction = offset.Unit

                        myHRP.CFrame =
                            myHRP.CFrame + (direction * FlySpeed * task.wait())
                    end

                    myHRP.CFrame =
                        CFrame.new(myHRP.Position, hrp.Position)

                    -- เริ่มจับเวลาเมื่อเข้าใกล้
                    if distance <= CheckDistance then

                        if not startedCheck then
                            startedCheck = true
                            lastDamage = tick()
                        end

                        -- เลือดลด
                        if hum.Health < oldHealth then
                            oldHealth = hum.Health
                            lastDamage = tick()
                        end

                        -- 3 วิเลือดไม่ลด เปลี่ยนคน
                        if tick() - lastDamage >= 3 then
                            ignored[target] = true
                            break
                        end
                    end
                end

                RunService.Heartbeat:Wait()
            end
        end

        task.wait(0.1)
    end
end)

--========================
-- Pain-Pain Remote
--========================
local function getRemote()

    local Character =
        LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

    local Tool = Character:FindFirstChild("Pain-Pain")

    if not Tool then
        return nil
    end

    return Tool:FindFirstChild("LeftClickRemote")
end

--========================
-- หา Player ใกล้สุด
--========================
local function getNearestPlayer()

    local Character = LocalPlayer.Character
    local MyHRP = Character and Character:FindFirstChild("HumanoidRootPart")

    if not MyHRP then
        return nil
    end

    local Closest = nil
    local Distance = math.huge

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer then

            local Char = v.Character
            local HRP = Char and Char:FindFirstChild("HumanoidRootPart")
            local Humanoid = Char and Char:FindFirstChildOfClass("Humanoid")

            if HRP and Humanoid and Humanoid.Health > 0 then

                local Dist =
                    (HRP.Position - MyHRP.Position).Magnitude

                if Dist < Distance then
                    Distance = Dist
                    Closest = v
                end
            end
        end
    end

    return Closest
end

--========================
-- Auto Hit
--========================
task.spawn(function()

    while _G.AutoHitNearestPlayer do

        pcall(function()

            local Remote = getRemote()

            if Remote then

                local Target = getNearestPlayer()

                if Target and Target.Character then

                    local MyHRP =
                        LocalPlayer.Character
                        and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

                    local EnemyHRP =
                        Target.Character:FindFirstChild("HumanoidRootPart")

                    if MyHRP and EnemyHRP then

                        local Direction =
                            (EnemyHRP.Position - MyHRP.Position).Unit

                        local args = {
                            vector.create(
                                Direction.X,
                                Direction.Y,
                                Direction.Z
                            ),
                            1,
                            true
                        }

                        Remote:FireServer(unpack(args))
                    end
                end
            end
        end)

        task.wait()
    end
end)
