local S, E = pcall(function()
    _G.Stepped:Disconnect()
    _G.InputBegan:Disconnect()
end)

if S then
    game.StarterGui:SetCore("SendNotification", {
        Title = "Silent Aim",
        Text = "Silent Aim was reset, Mode: BounceBot",
        Duration = 3
    })

    _G.Stepped = nil
    _G.InputBegan = nil
end

if game.PlaceId == 4923146720 then
    return game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Error",
        Text = "BounceBot can't be used in Playground",
        Duration = 5,
        Button1 = "Ok"
    })
end

local Player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")

local IsInFooting = false

local HL = Instance.new("Highlight")
HL.Enabled = false
HL.Adornee = Player.Character
HL.FillColor = Color3.fromRGB(25, 255, 25)
HL.OutlineColor = Color3.fromRGB(0, 255, 0)
HL.Parent = game.CoreGui

local XYZ = {"X1", "Y1", "Z1", "X2", "Y2", "Z2"}
local Selected; for _, Garbage in next, getgc(true) do
    if type(Garbage) == "function" and getinfo(Garbage)["name"] == "selected1" then
        Selected = Garbage
    end
end
local Goals = {}; for _, Obj in next, workspace:GetDescendants() do
    if Obj.Name == "Goal" and Obj:isA("BasePart") then
        table.insert(Goals, Obj)
    end
end
local Shuffled = {}; for _, Garbage in next, getgc(true) do
    if type(Garbage) == "table" and rawget(Garbage, "1") and rawget(Garbage, "1") ~= true then
        for z,x in next, Garbage do
            Shuffled = Garbage
        end
    end
end

local Clicker = getupvalue(Selected, 3)

local GetKeyFromKeyTable = function()
    local Keys = getupvalue(Selected, 4)
    return Keys[1]
end

local RemoveKeyFromKeyTable = function()
    local Keys = getupvalue(Selected, 4)
    table.remove(Keys, 1)
    setupvalue(Selected, 4, Keys)
end

local GetRandomizedTable = function(TorsoPosition, ShootPosition)
    local UnrandomizedArgs = {
        X1 = TorsoPosition.X,
        Y1 = TorsoPosition.Y,
        Z1 = TorsoPosition.Z,
        X2 = ShootPosition.X,
        Y2 = ShootPosition.Y,
        Z2 = ShootPosition.Z
    }
    
    local RandomizedArgs = {
        UnrandomizedArgs[Shuffled["1"]],
        UnrandomizedArgs[Shuffled["2"]],
        UnrandomizedArgs[Shuffled["3"]],
        UnrandomizedArgs[Shuffled["4"]],
        UnrandomizedArgs[Shuffled["5"]],
        UnrandomizedArgs[Shuffled["6"]],
    }
    
    return RandomizedArgs
end

local GetCorrectPosition = function(Position)
    return Position - Player.Character.Torso.Position
end

local GetUnitPosition = function(Position)
    return Position.Unit
end

local GetGoal = function()
    local Distance, Goal = 9e9;
    
    for _, Obj in next, Goals do
        local Magnitude = (Player.Character.Torso.Position - Obj.Position).Magnitude
        
        if Distance > Magnitude then
            Distance = Magnitude
            Goal = Obj
        end
    end
    
    return Goal
end

local GetDistance = function()
    local Goal = GetGoal()
    
    return (Player.Character.Torso.Position - Goal.Position).Magnitude
end

local GetBasketball = function()
     return Player.Character:FindFirstChildOfClass("Folder") 
end

local InFootingCheck = function()
    local Distance = GetDistance()
    local Basketball = GetBasketball()
    
    local Power; if Basketball ~= nil then
        Power = Basketball.PowerValue.Value
    else
        IsInFooting = false
        return
    end
    
    if Distance > 57 and Distance < 93 then
        IsInFooting = true
    else
        IsInFooting = false
    end
end

local GetArc = function()
    local Distance = GetDistance()
    local Basketball = GetBasketball()
    
    if Distance > 57 and Distance < 63 then
        return 185
    elseif Distance > 63 and Distance < 69 then
        return 180
    elseif Distance > 69 and Distance < 74 then
        return 175
    elseif Distance > 74 and Distance < 79 then
        return 175
    elseif Distance > 79 and Distance < 82 then
        return 170
    elseif Distance > 82 and Distance < 91 then
        return 165
    elseif Distance > 91 and Distance < 93 then
        return 160
    end
end

local Shoot = function()
    local Goal = GetGoal()
    local Arc = GetArc()
    local CorrectPosition = GetCorrectPosition(Goal.Position + Vector3.new(0, Arc, 0) + Player.Character.Humanoid.MoveDirection)
    local Position = GetUnitPosition(CorrectPosition)
    local RandomizedArgs = GetRandomizedTable(Player.Character.Torso.Position, Position)
    local Basketball = GetBasketball()
    
    local Key = GetKeyFromKeyTable()
    
    if type(Key) ~= "string" then
        Key = "Shotta"
    end
    
    Clicker:FireServer(Basketball, 100, RandomizedArgs, Key)
    
    if Key ~= "Shotta" then
        RemoveKeyFromKeyTable()
    end
end
            
_G.InputBegan = UIS.InputBegan:Connect(function(Key, GPE)
    if not GPE and Key.KeyCode == Enum.KeyCode.X and Player.Character and Player.Character:FindFirstChild("Basketball") and IsInFooting then
        if Player.Character.Humanoid:GetState() ~= Enum.HumanoidStateType.Freefall then
            Player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            task.wait(0.27)
        end
        
        Shoot()
    end
end)

_G.Stepped = RS.Stepped:Connect(function()
    InFootingCheck()
    
    if IsInFooting then
        HL.Enabled = true
    else
        HL.Enabled = false
    end
    
    if HL.Adornee.Parent == nil and Player.Character then
        HL.Adornee = Player.Character
    end
end)
