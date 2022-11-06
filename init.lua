--[[
    Bullfrog
    Version 1
    11/04/2022

    API
        getSystem()
        setupSystems()
        start()
    
    Lifetime Functions
        onSetup()
        onStart()
        onUpdate()
]]

-- Root
local BULLFROG = {}

-- Services
local RUN_SERVICE = game:GetService("RunService")

-- Constants
local IS_SERVER = RUN_SERVICE:IsServer()

-- Variables
local _systems = {}

function BULLFROG.getSystem(requestedSystem)
    if not requestedSystem then
        error("Did not specify a system to get.")
    end

    if not _systems[requestedSystem] then
        error("The specified system was not found" .. requestedSystem)
    end

    return _systems[requestedSystem]
end

function BULLFROG.setupSystems(systemsDirectory)
    if not systemsDirectory then
        error("Did not specify a systems directory.")
    end

    for _, _system in pairs(systemsDirectory:GetChildren()) do
        local _module = _system:FindFirstChild(
            if IS_SERVER then
                "Server"
            else
                "Client"
        )
    
        if _module then
            local _requiredModule = require(_module)
            
            _systems[_system.Name] = _requiredModule
            
            if _requiredModule.onSetup then
                _requiredModule.onSetup()
            end
        end
    end
end

function BULLFROG.start()
    for _, _system in pairs(_systems) do
        if _system.onStart then
            coroutine.wrap(_system.onStart)()
        end
        
        if _system.onUpdate then
            RUN_SERVICE.Heartbeat:Connect(_system.onUpdate)
        end
    end
end

return BULLFROG
