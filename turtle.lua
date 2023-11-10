local memory = 
{
    modemSide = "back",
    assainedWork = nil,
    redNetID = 1,
    facingDirection = nil,
    digToolSide = "",
}

function Init()
    rednet.open(memory.modemSide)
end

function Tick()
    local id,message = rednet.receive()
    if id == memory.redNetID then
        AnalyzeMessage(message)
    end
    if not memory.assainedWork == nil then
        Work()
    end
end

function AnalyzeMessage(message)
    if message == "status" then 
        if memory.assainedWork == nil then
            local response = "unassined" 
        else 
            local response = "working" 
        end
        rednet.send(0, response)
    else
        memory.assainedWork = message
    end     
end

function Work()
    MoveToLocation(memory.assainedWork.StartingPosition)

    for key, value in pairs(memory.assainedWork.Layout.CellMatrix) do
    --cell are rapresented from left to right, 
    --then to not destroy what placed we should do it from right to left  
        local size = table.getn(value)
        for key, value in pairs(Reverse(value)) do
            local position = memory.assainedWork.StartingPosition
            position.x = position.x + size - key - 1
            MoveToLocation()
            Face(RIGHT)
            turtle.placeDown()     
        end
    end      
end

function Reverse(tab)
    for i = 1, #tab//2, 1 do
        tab[i], tab[#tab-i+1] = tab[#tab-i+1], tab[i]
    end
    return tab
end

function ResetWorkTokens()
    memory.availableWork = memory.maxAvailableWork
end

--#region Turtle move

local RIGHT = 3 -- +x
local LEFT = 1 -- -x
local FORWARD = 0 -- +z
local BACKWARD = 2 -- -z

-- https://www.reddit.com/r/ComputerCraft/comments/p01bse/turtle_to_player/
function Face(direction)
    if memory.facingDirection == nil then
        AcquireFaceDirection()
    end
    local facingDirection = memory.facingDirection
    
    if facingDirection == direction then return end
    if (facingDirection + 1) % 4 == direction then
        turtle.turnRight()
    elseif (facingDirection - 1) % 4 == direction then
        turtle.turnLeft()
    else
        turtle.turnRight()
        turtle.turnRight()
    end
    memory.facingDirection = direction
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
    if location.y ~= y then
        local direction = "down"
        if location.y > y then
            direction = "up"
        end
        MoveUpOrDown(direction, location.y - y)            
    end
    MoveToLocation(location)
end

function MoveUpOrDown(direction, length)
    memory.availableWork = memory.availableWork - length
    if length < 0 then
        length = length * -1
    end
    for i = length,1,-1 do
        if direction == "down" then
            if turtle.detectDown() then
                turtle.digDown(memory.digToolSide)
            end
            turtle.down() 
        else
            if turtle.detectUp() then
                turtle.digUp(memory.digToolSide)
            end
            turtle.up()
        end
    end
end

function MoveFoward(length)
    memory.availableWork = memory.availableWork - length
    if length < 0 then
        length = length * -1
    end
    for i = length,1,-1 do
        if turtle.detect() then
            turtle.dig(memory.digToolSide)
        end
        turtle.forward()
    end
end
--#endregion

