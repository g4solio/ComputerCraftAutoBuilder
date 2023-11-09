local settings = 
{
    modemSide = "back",
    assainedWork = nil,
    redNetID = 1
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
   MoveToLocation(settings.assainedWork.startingPoint) 
end



function MoveToLocation(location)
    local x, y, z = gps.locate()
    if location.x == x and location.y == y and location.z == z then
        return
    end
    if location.x < x then
        --TODO(DG) do location
    end
end


