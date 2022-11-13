# Bullfrog
This is an extremely simple, intuitive, and easy to use framework for making roblox games! Not to mention it is extremely lightweight! The length of the entire module is only about 100 lines of code if you don't count the comments.

## Structure
### Bullfrog
Place the Bullfrog module into ReplicatedStorage. I usually like to place all of my libraries into a libraries folder in ReplicatedStorage.

![image](https://user-images.githubusercontent.com/65873272/200153913-5bbdd15a-f702-4c05-830d-6416f85d3177.png)

### Startup Scripts
The structuring when using Bullfrog is as follows. Similar to Knit and other frameworks, you need two scripts to start Bullfrog. A server script and a local script. I am using the RunContext feature to group them together in ReplicatedStorage. You can have yours anywhere, maybe your server script in ServerScriptService and your client script in StarterPlayer scripts. Its up to you, I just prefer this method as it keeps things together.

![image](https://user-images.githubusercontent.com/65873272/200153950-7baec13c-9448-4465-84a8-ba0dabd116bb.png)

### Systems
This is where Bullfrog strays from most other frameworks. The typical way to setup your systems when using Bullfrog is to have a folder in ReplicatedStorage that will contain all of your systems. Now theoretically, you don't have to do it this way. This way just makes the most sense to me. It allows you to group all of your code into specific folders, in each folder you have the server and the client code, all in one place! This allows for much easier management and organization. I believe this is what makes Bullfrog special!

For Example: Here we have a camera system and a weapon system. You can see the camera system only has a client module. This is because systems don't need both client and server modules to work. Bullfrog will only start the environment it can find. Some systems may only have a server module, this also works. You may also notice that the modules in the weapons system have submodules. Ill elaborate more on all this later. You can see below an example of how code may typically structured when using Bullfrog, everything is neatly organized and containerized!

#### Typical Setup

![image](https://user-images.githubusercontent.com/65873272/200153820-71595195-be09-4f92-baaa-b2a78440bcc8.png)

#### Split Setup
Like I was saying earlier there are also other ways to structure this. Here is another example. In this setup the systems are divided among the server / client boundaries along with the startup scripts. This I suppose is more secure, but it gives up containerization and organization for security. This could be valuable to some people. I personally stick to the typical setup as I would rather forfeit some security to maintain sanity when working with a large codebase.

**Client**

![image](https://user-images.githubusercontent.com/65873272/200154637-032fbeaf-7833-4557-9337-836949dce0cb.png)

**Server**

![image](https://user-images.githubusercontent.com/65873272/200154705-7e4cdfbc-e253-4bd8-a202-ab81fd1a67a4.png)

## Usage
### Starting Bullfrog
As mentioned earlier you need both a server script and a local script to start Bullfrog. Inside of each script you would write something like this.
```lua
local Bullfrog = require(game:GetService("ReplicatedStorage").Libraries.Bullfrog)

Bullfrog.setupSystems(game:GetService("ReplicatedStorage").Systems)
Bullfrog.start()
```
Boom! Now Bullfrog is running! It was as easy as that!

### Creating a System
If you were looking at the structure examples above you may have noticed that systems are just folders. This is correct! Systems are created in Studio rather than through code. In order to create a system all you have to do is add a folder to your Systems folder and call it whatever you'd like. Make sure the name makes sense as its what youll use to get the system later. Once youve created this new system folder add a module script to it and call it "Client" or "Server". You can have one of each or both! If you for example only have a "Client" module than that system will only run on the client. If you only have a "Server" module than that system will 
only run on the server. If you have both then it will run on both! Just like that you've setup a new system! Easy right?

### Getting Another System
For easy access between systems on the same environment Bullfrog provides `getSystem()`! In the below example the WeaponSystem gets the CameraSystem and alters its FOV property.

**Weapon System**
```lua
local WeaponClientModule = {}

local Bullfrog = require(game:GetService("ReplicatedStorage").Libraries.Bullfrog)

local CameraSystem

function WeaponClientModule.onStart()
     CameraSystem = Bullfrog.getSystem("CameraSystem")
     CameraSystem.FOV = 90
end

return WeaponClientModule
```

**Camera System**
```lua
local CameraClientModule = {}

CameraClientModule.FOV = 50

return CameraClientModule
```

### Lifetime Functions
You may have noticed the `onStart()` function above. Bullfrog provides some very handy, but completely optional lifetime functions. `onSetup()`, `onStart()`, and `onUpdate()`. These can be easily added to your "Client" or "Server" module. Here is an example of how to do so. As well as an explanation of each function via a comment.
```lua
local ClientModule = {}

function ClientModule.onSetup()
    -- Runs when this system is grabbed via setupSystems().
end

function ClientModule.onStart()
    -- Runs when start() is called. Its safe to access other systems at this point.
end

function ClientModule.onUpdate(deltaTime)
    -- Runs every frame after start() is called.
end

return ClientModule
```

### Links
Bullfrog provides an extremely simple way to setup server / client communcation. These are called Links! There are two types of Links; Remote Links and Bindable Links. They function exactly the same as their Remote Event and Bindable Event counterparts. In the future I may add more features to them, so be on the lookout! Links are contained on a per system basis. This makes organization much easier! Here is an example on how to use them!

**Server Module**
```Lua
local ServerModule = {}

local Bullfrog = require(game:GetService("ReplicatedStorage").Libraries.Bullfrog)

ServerModule.remoteLinks = {
     testRemoteLink = Bullfrog.createRemoteLink()
}

ServerModule.onStart()
     ServerModule.remoteLinks.testRemoteLink:FireAllClients()
end

return ServerModule
```
**Client Module**
```Lua
local ClientModule = {}

local Bullfrog = require(game:GetService("ReplicatedStorage").Libraries.Bullfrog)

local function onTestRemoteLink()
     print("Fired!")
end

function ClientModule.onSetup()
     ClientModule.remoteLinks.testRemoteLink.onClientEvent:Connect(onTestRemoteLink)
end

return ClientModule
```
I know it may look like there is a lot going on here, but its really simple! If you have any experience with Roblox's event system than you may already be catching on! We create a table in the server script called `remoteLinks` this is case sensitive and it's how Bullfrog determines if there are links that need to be created! Inside this table we can create any number of Remote Links by specifying a name and then calling the `Bullfrog.createRemoteLink()` function. Now you have a Remote Link! These function the exact same way as Remote Events. Now you may be asking how do I listen for this Link on the client? Simple! When you access the `remoteLinks` table on the client you are accessing a cope of the server version of that table. This can be accessed by doing `ClientModule.remoteLinks`. Beware, this table can only be accessed after `onSetup()` is called. Also `createRemoteLink()` can only be called from the server. `createBindableLink()` can be called from both the server and the client and functions in mostly the same way as Bindable Events. 

**Cross System Communication**
Cross system communication can be accomplished with some help from the `Bullfrog.getSystem()` function. Here is an example in which two server scripts communicate with each other using a Bindable Link.
```lua
local ServerModule = {}

local Bullfrog = require(game:GetService("ReplicatedStorage").Libraries.Bullfrog)

ServerModule.bindableLinks = {
     testBindableLink = Bullfrog.createBindableLink()
}

ServerModule.onStart()
     ServerModule.testBindableLink:Fire("Hello World")
end  

return ServerModule
```
```lua
local ServerModule = {}

local Bullfrog = require(game:GetService("ReplicatedStorage").Libraries.Bullfrog)

local function onTestBindableLink(text)
     print(text)
end  

ServerModule.onStart()
     Bullfrog.getSystem("otherSystem").bindableLinks.testBindableLink.Event:Connect(ontestBindableLink)
end  

return ServerModule
```
Just like in the Remote Links example we use a reserved table called `bindableLink` to tell Bullfrog what Bindable Links to create. We then fire() that Bindable Link and in another system we use `getSystem()` to get the Bindable Link and connect it. These two examples show you the basics on how to use Links in Bullfrog! The Roblox Docs can also help you with networking questions as well, as Links are just a wrapper and use the same API.

## Install
### Roblox Workflow
You can get Bullfrog off the Roblox Marketplace here.
https://www.roblox.com/library/11486909913/Bullfrog

### Rojo Workflow
Get the `.rbxm` file from the releases page. This file can be used to sync to Studio when using Rojo.

### Raw Files
You can find both the `.lua` and the `.rbxm` files here in the releases section.

## Complete API
`setupRemoteLink()` - Creates a Remote Link aka Remote Event | NOTE - This is a server only function. Client scripts cannot access this.

`setupBindableLink()` - Creates a Bindable Link aka Bindable Event

`getSystem(systemName)` - Gets the requested system. If one is not found then it will return an error. | NOTE - You cannot use this to get systems across the server / client boundary.

`setupSystems(systemDirectory)` - This will loop through the specified systemDirectory and get all of the children. It will then check if that system has a module for the current environment. If it finds one it will require it and add it to the systems pool. If the module has a onSetup() function this is when it gets called.

`start()` - Loops through all the setup systems and if those systems have a onStart() module it will call them, thereby starting the systems.

`onSetup()` - Gets called when a system is required via setupSystems()

`onStart()` - Gets called when start() is called.

`onUpdate(deltaTime)` - Gets called every heartbeat and has an optional argument of delta time or time since last frame.
