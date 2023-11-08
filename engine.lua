--#region CellFactory
local cellFactoryRepository = 
{
    w = function () return WoodCell:new{MinecraftBlockIdendifier = "wood"} end,
    s = function () return StoneCell:new{MinecraftBlockIdendifier = "stone"} end
}

CellFactory = 
{
    CellFactoryRepository = cellFactoryRepository,
    DefaultCellCtor = function () return AirCell:new{MinecraftBlockIdendifier = "air"} end
}

function CellFactory:BuildCell(identifier)
    local specificCellCtor = self.CellFactoryRepository[identifier]
    specificCellCtor = specificCellCtor or self.DefaultCellCtor

    return specificCellCtor()
end
--#endregion
--#region Cells
Cell = {MinecraftBlockIdendifier = ""}

function Cell:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

WoodCell = Cell:new()

StoneCell = Cell:new()

AirCell = Cell:new()

--#endregion

Layer = {CellMatrix = {}}

Portion = {LayerArray = {}}

Building = {PortionArray = {}}


local settings = 
{
    useMultipleTurtles = false,
    turtleStatusRefreshRateSeconds = 10,
    rednetSide = "right"
}
--TODO(DG): Build Init, like opening rednet connection


function Build(building)
    for portionIndex, portionValue in building.PortionArray do
        for layerIndex, layerValue in portionValue.LayerArray do
            local workerTurtle = FindTurtleForJob()
            workerTurtle.StartWork(layerValue, layerIndex)
        end
    end
end


--#region Turtles

local messageTable = 
{
    status = "status"
}

Turtle = 
{
    nickname = "Turtle 1",
    id = 1
}

function Turtle:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Turtle:ISWorking()
    rednet.send(self.id, messageTable.status)
    while not senderId == self.id do
        local senderId, message, protocol = rednet.receive()
    end
    return message == "unassined"
end

function Turtle:StartWork(layout, layoutIndex)
    rednet.send(self.id, {  }) --TODO(DG): realize connection with turtle
end

local turtles = 
{
    Turtle:new()
}



function FindTurtleForJob()
    while true do
        for index, turtle in turtles do
            if not turtle.ISWorking() and (index == 1 or settings.useMultipleTurtles) then
                return turtle
            end
        end
        os.sleep(settings.turtleStatusRefreshRateSeconds)
    end
end

--#endregion
