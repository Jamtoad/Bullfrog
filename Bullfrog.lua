-- Bullfrog | Version 2
-- Version 1: Initial release. | 11/07/2022
-- Version 2: Links and comments added! | 11/12/2022

-- Root
local BULLFROG = {}

-- Services
local RUN_SERVICE = game:GetService("RunService")

-- Constants
local IS_SERVER = RUN_SERVICE:IsServer()

-- Variables
local systems = {}

-- Global Functions
--[[
    Description - Creates a remote event
    Returns - The created remote event
]]
BULLFROG.createRemoteLink = if IS_SERVER then function()
    return Instance.new("RemoteEvent")
end else nil

--[[
    Description - Creates a bindable event
    Returns - The created bindable event
]]
function BULLFROG.createBindableLink()
    return Instance.new("BindableEvent")
end

--[[
    Description - Gets the requested system within the same environment
    Parameters - [string] The systems name
    Returns - The requested system
    Errors - If no requested system is specified
]]
function BULLFROG.getSystem(requestedSystem)
    if not requestedSystem then
        error("Did not specify a system to get.")
    end

    if not systems[requestedSystem] then
        error("The specified system was not found" .. requestedSystem)
    end

    return systems[requestedSystem]
end

--[[
    Description - Sets up the systems within the specified systems directory,
    sets up any remote links or bindable links, and calls onSetup()
    Parameters - [object] The directory to search for systems in
    Errors - If no directory is specified
]]
function BULLFROG.setupSystems(systemsDirectory)
    local function setupLinks(system, links)    
        local function setupFolder()
            local _folder = Instance.new("Folder")
            _folder.Name = "Links"
            _folder.Parent = system
            
            return _folder
        end
        
        for name, link in pairs(links) do
            link.Name = name
            link.Parent = system:FindFirstChild("Links") or setupFolder()
        end
        
        return nil
    end
    
    local function findModule(system, moduleType)
        for _, _child in pairs(system:GetChildren()) do
            if string.match(_child.Name, moduleType .. "$") then
                return _child
            end
        end
    end
    
    if not systemsDirectory then
        error("Did not specify a systems directory.")
    end
    
    for _, _system in pairs(systemsDirectory:GetChildren()) do
        local _module = findModule(_system,
            if IS_SERVER then "Server" else "Client")
    
        if _module then
            local _requiredModule = require(_module)
            
            systems[_system.Name] = _requiredModule
            
            if IS_SERVER and _requiredModule.remoteLinks then
                setupLinks(_system, _requiredModule.remoteLinks)
            elseif not IS_SERVER then
                _requiredModule.remoteLinks = _system:FindFirstChild("Links")
            end
            
            if _requiredModule.bindableLinks then
                setupLinks(_system, _requiredModule.bindableLinks)
            end
            
            if _requiredModule.onSetup then
                _requiredModule.onSetup()
            end
        end
    end
    
    return nil
end

--[[
    Description - Starts the systems that were setup in setupSystems(),
    also calls onStart() and binds onUpdate()
]]
function BULLFROG.start()
    for _, _system in pairs(systems) do
        if _system.onStart then
            coroutine.wrap(_system.onStart)()
        end
        
        if _system.onUpdate then
            coroutine.wrap(function()
                RUN_SERVICE.Heartbeat:Connect(_system.onUpdate)
            end)()
        end
    end
    
    return nil
end

return BULLFROG
