# Bullfrog
This is an extremely simple, intuitive, and easy to use framework for making roblox games!

## Structure
### Bullfrog
Place the Bullfrog module into ReplicatedStorage. I usually like to place all of my libraries into a libraries folder in ReplicatedStorage.

![image](https://user-images.githubusercontent.com/65873272/200153913-5bbdd15a-f702-4c05-830d-6416f85d3177.png)

### Startup Scripts
The structuring when using Bullfrog is as follows. Similar to Knit and other frameworks, you need two scripts to start Bullfrog. A server script and a client script. I am using the RunContext feature to group them together in ReplicatedStorage. You can have yours anywhere, maybe your server script in ServerScriptService and your client script in StarterPlayer scripts. Its up to you, I just prefer this method as it keeps things together.

![image](https://user-images.githubusercontent.com/65873272/200153950-7baec13c-9448-4465-84a8-ba0dabd116bb.png)

### Systems
This is where Bullfrog strays from most other frameworks. The typical way to setup your systems when using Bullfrog is to have a folder in ReplicatedStorage that will contain all of your systems. Now theoretically, you don't have to do it this way. In fact there are many other ways you can do it. This way just makes the most sense to me. It allows you to group all of your code into specific folders, in each folder you have the server and the client code, all in one place! This allows for much easier management and organization.

For Example: Here we have a camera system and a weapon system. You can see the camera system only has a client module. This is because systems don't need both client and server modules to work. Bullfrog will only start the environment it can find. Some systems may only have a server module, this also works. Ill elaborate more on this later. You can see below an example of how code may typically structured when using Bullfrog, everything is neatly organized and "containerized"!

![image](https://user-images.githubusercontent.com/65873272/200153820-71595195-be09-4f92-baaa-b2a78440bcc8.png)

## Usage
### Starting Bullfrog

### Creating a System

## Install
