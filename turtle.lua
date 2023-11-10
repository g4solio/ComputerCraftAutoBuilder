local settings = 
{
    modemSide = "back",
    assainedWork = nil,
    redNetID = 1,
    availableWork = 0,
    maxAvailableWork = 10,
    facingDirection = nil,
    digToolSide = ""
}

function Init()
    rednet.open(settings.modemSide)
end

function Tick()
    local id,message = rednet.receive()
    if id == settings.redNetID then
        AnalyzeMessage(message)
    end
    if not settings.assainedWork == nil then
        Work()
    end
end

function AnalyzeMessage(message)
    if message == "status" then 
        if settings.assainedWork == nil then
            local response = "unassined" 
        else 
            local response = "working" 
        end
        rednet.send(0, response)
    else
        settings.assainedWork = message
    end     
end

function Work()
    ResetWorkTokens()
   MoveToLocation(settings.assainedWork.startingPoint) 
end

function ResetWorkTokens()
    settings.availableWork = settings.maxAvailableWork
end

local RIGHT = 3 -- +x
local LEFT = 1 -- -x
local FORWARD = 0 -- +z
local BACKWARD = 2 -- -z

-- https://www.reddit.com/r/ComputerCraft/comments/p01bse/turtle_to_player/
function Face(direction)
    if settings.facingDirection == nil then
        AcquireFaceDirection()
    end
    local facingDirection = settings.facingDirection
    
    if facingDirection == direction then return end
    if (facingDirection + 1) % 4 == direction then
        turtle.turnRight()
    elseif (facingDirection - 1) % 4 == direction then
        turtle.turnLeft()
    else
        turtle.turnRight()
        turtle.turnRight()
    end
    settings.facingDirection = direction
end

function MoveToLocation(location)
    local x, y, z = gps.locate()
    if location.x == x and location.y == y and location.z == z then
        return
    end
    if location.x ~= x then
        if location.x > x then
            Face(RIGHT)
        else
            Face(LEFT)
        end
        MoveFoward(location.x - x)
    end
    if location.z ~= z then
        if location.z > z then
            Face(FORWARD)
        else
            Face(BACKWARD)
        end
        MoveFoward(location.z - z)
    end
end

function MoveFoward(length)
    for i = length,1,-1 do
        if turtle.detect() then
            turtle.dig(settings.digToolSide)
        end
        turtle.forward()
    end
end


