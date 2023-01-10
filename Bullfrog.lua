--[[
    Bullfrog | Created by Jam_Toad
    Version 1: Initial release. | 11/07/2022
    Version 2: Links and comments added! | 11/12/2022
    Version 3: Improved naming | 11/19/2022
    Version 4: System and security improvements! | 12/19/2022
    Version 5: Security reversion and better string filtering! | 12/21/2022
    Version 6: Support for Functional Links! | 12/26/2022
]]

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
    Description - Creates a remote function
    Returns - The created remote function
]]
BULLFROG.createRemoteFunctionalLink = if IS_SERVER then function()
	return Instance.new("RemoteFunction")
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
			if string.match(string.lower(_child.Name), moduleType) then
				return _child
			end
		end
	end

	if not systemsDirectory then
		error("Did not specify a systems directory.")
	end

	systems = {}

	for _, _system in pairs(if type(systemsDirectory) == "table" then 
		systemsDirectory else systemsDirectory:GetChildren()) do

		local _module = findModule(_system,
			if IS_SERVER then "server" else "client")

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
				_system.onUpdateConnection =
					RUN_SERVICE.Heartbeat:Connect(_system.onUpdate)
			end)()
		end
	end

	return nil
end

--[[
    Description - Stops the systems that were setup in the setupSystems(),
    also calls onStop() and unbinds any onUpdate() functions
]]
function BULLFROG.stop()
	for _, _system in pairs(systems) do
		if _system.onStop then
			coroutine.wrap(_system.onStop)()
		end

		if _system.onUpdate and _system.onUpdateConnection then
			_system.onUpdateConnection:Disconnect()
		end
	end

	return nil
end

return BULLFROG
