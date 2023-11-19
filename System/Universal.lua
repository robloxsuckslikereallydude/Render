-- Render Custom Vape Signed File
repeat task.wait() until pcall(function() return game.HttpGet end)
local GuiLibrary = shared.GuiLibrary
local identifyexecutor = identifyexecutor or function() return "Unknown" end
local getconnections = getconnections or function() return {} end
local queueonteleport = syn and syn.queue_on_teleport or queue_on_teleport or function() end
local setclipboard = setclipboard or function(data) writefile("clipboard.txt", data) end
local httpService = game:GetService("HttpService")
local teleportService = game:GetService("TeleportService")
local playersService = game:GetService("Players")
local textService = game:GetService("TextService")
local lightingService = game:GetService("Lighting")
local textChatService = game:GetService("TextChatService")
local inputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local replicatedStorageService = game:GetService("ReplicatedStorage")
local HWID = game:GetService("RbxAnalyticsService"):GetClientId()
local tweenService = game:GetService("TweenService")
local gameCamera = workspace.CurrentCamera
local lplr = playersService.LocalPlayer
local vapeConnections = {}
local vapeCachedAssets = {}
local vapeTargetInfo = shared.VapeTargetInfo
local vapeInjected = true
local RenderFunctions = {}
local RenderStore = {Bindable = {}, raycast = RaycastParams.new()}
getgenv().RenderStore = RenderStore

if readfile == nil then
	task.spawn(error, "Render - Exploit not supported. Your exploit is missing a workspace.")
	while task.wait() do end
end 


table.insert(vapeConnections, workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	gameCamera = workspace.CurrentCamera or workspace:FindFirstChildWhichIsA("Camera")
end))

local normalvape = pcall(function() loadstring(readfile("vape/Render/oldvape/Universal.lua"))() end)
if not normalvape then 
	loadstring(game:HttpGet("https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/main/Universal.lua"))()
end

local customfunctions = pcall(function() RenderFunctions = loadstring(readfile("vape/Render/Libraries/corefunctions.lua"))() end)
if not customfunctions then 
	RenderFunctions = loadstring(game:HttpGet("https://raw.githubusercontent.com/SystemXVoid/Render/main/Libraries/corefunctions.lua"))()
end

local isfile = isfile or function(file)
	local suc, res = pcall(function() return readfile(file) end)
	return suc and res ~= nil
end

local writefile = writefile or function() end 
local isAlive = function() return false end 
local characterDescendant = function() return nil end
local playerRaycasted = function() return true end
local GetTarget = function() return {} end
local GetAllTargets = function() return {} end
local getnewserver = function() return nil end
local getTablePosition = function() return 1 end
local warningNotification = function() end 
local InfoNotification = function() end

local httprequest = syn and syn.request or http and http.request or http_request or fluxus and fluxus.request or request or function(tab)
	local success, response
	if tab.Method == "GET" then 
		success, response = pcall(function() return httpService:GetAsync(tab.Url) end)
	else
		success, response = pcall(function() return httpService:PostAsync(tab) end)
	end
	if success and type(response) == "table" then 
		return {Headers = response.Headers or {}, StatusCode = response.StatusCode or 404, Body = response.Body or "[]"}
	end
	return {Headers = {}, StatusCode = 404, Body = "[]"}
end

RenderStore.Bindable = setmetatable({}, {
	__index = function(self, index)
		self[index] = Instance.new("BindableEvent")
		return self[index]
	end
})

RenderStore.raycast.FilterType = Enum.RaycastFilterType.Include
RenderStore.raycast.FilterDescendantsInstances = {workspace}

task.spawn(function()
	local kickoverlay = game:GetService("CoreGui"):WaitForChild("RobloxPromptGui"):WaitForChild("promptOverlay")
	table.insert(vapeConnections, kickoverlay.DescendantAdded:Connect(function(v)
		if v.Name == "ErrorMessage" then 
			RenderStore.Bindable.PlayerKick:Fire()
		end
	end))
end)

local networkownerswitch = tick()
local isnetworkowner = isnetworkowner or function(part)
	local suc, res = pcall(function() return gethiddenproperty(part, "NetworkOwnershipRule") end)
	if suc and res == Enum.NetworkOwnership.Manual then 
		sethiddenproperty(part, "NetworkOwnershipRule", Enum.NetworkOwnership.Automatic)
		networkownerswitch = tick() + 8
	end
	return networkownerswitch <= tick()
end
local vapeAssetTable = {["vape/assets/VapeCape.png"] = "rbxassetid://13380453812", ["vape/assets/ArrowIndicator.png"] = "rbxassetid://13350766521"}
local getcustomasset = getsynasset or getcustomasset or function(location) return vapeAssetTable[location] or "" end
local synapsev3 = syn and syn.toast_notification and "V3" or ""
local worldtoscreenpoint = function(pos)
	if synapsev3 == "V3" then 
		local scr = worldtoscreen({pos})
		return scr[1] - Vector3.new(0, 36, 0), scr[1].Z > 0
	end
	return gameCamera.WorldToScreenPoint(gameCamera, pos)
end
local worldtoviewportpoint = function(pos)
	if synapsev3 == "V3" then 
		local scr = worldtoscreen({pos})
		return scr[1], scr[1].Z > 0
	end
	return gameCamera.WorldToViewportPoint(gameCamera, pos)
end

local function currentProfile()
	for i,v in GuiLibrary.Profiles do 
		if v.Selected then 
			return i
		end
	end
	return "default"
end

local function getvapefile(file)
	if not isfile("vape/"..v) then 
		local custom = {"MainScript.lua", "Universal.lua", "GuiLibrary.lua"}
		local success, script = pcall(function()
			local url = (custom[file] and "SystemXVoid/Render/main/System/"..file or "7GrandDadPGN/VapeV4ForRoblox/main/"..file)
			return game:HttpGet("https://raw.githubusercontent.com/"..url)
		end)
		if success and script ~= "404: Not Found" then 
			if isfolder("vape") then 
				if file:sub(#file - 4, #file) == ".lua" and custom[file] then 
					script = ("Render Custom Vape Signed File\n"..script)
				end
				writefile("vape/"..file, script)
			end
		else
			task.spawn(error, "Vape - Failed to download\n vape/"..v..". | "..(script or "404: Not Found"))
		end
		return script
	end
	return readfile("vape/"..v)
end

local function downloadVapeAsset(path)
	if not isfile(path) then
		task.spawn(function()
			local textlabel = Instance.new("TextLabel")
			textlabel.Size = UDim2.new(1, 0, 0, 36)
			textlabel.Text = "Downloading "..path
			textlabel.BackgroundTransparency = 1
			textlabel.TextStrokeTransparency = 0
			textlabel.TextSize = 30
			textlabel.Font = Enum.Font.SourceSans
			textlabel.TextColor3 = Color3.new(1, 1, 1)
			textlabel.Position = UDim2.new(0, 0, 0, -36)
			textlabel.Parent = GuiLibrary.MainGui
			repeat task.wait() until isfile(path)
			textlabel:Destroy()
		end)
		local suc, req = pcall(function() return getvapefile(path:gsub("vape/assets", "assets")) end)
        if suc and req then
		    writefile(path, req)
        else
            return ""
        end
	end
	if not vapeCachedAssets[path] then vapeCachedAssets[path] = getcustomasset(path) end
	return vapeCachedAssets[path] 
end

warningNotification = function(title, text, delay)
	local suc, res = pcall(function()
		local frame = GuiLibrary.CreateNotification(title or "Render", text or "Example Text", delay or 7, "assets/WarningNotification.png")
		frame.Frame.Frame.ImageColor3 = Color3.fromRGB(236, 129, 44)
		return frame
	end)
	return (suc and res)
end

InfoNotification = function(title, text, delay)
	local success, response = pcall(function() 
		return GuiLibrary.CreateNotification(title or "Render", text or "Example Text", delay or 7)
	end)
	return success and response
end

local function runFunction(func) func() end

local function isFriend(plr, recolor)
	if GuiLibrary.ObjectsThatCanBeSaved["Use FriendsToggle"].Api.Enabled then
		local friend = table.find(GuiLibrary.ObjectsThatCanBeSaved.FriendsListTextCircleList.Api.ObjectList, plr.Name)
		friend = friend and GuiLibrary.ObjectsThatCanBeSaved.FriendsListTextCircleList.Api.ObjectListEnabled[friend]
		if recolor then
			friend = friend and GuiLibrary.ObjectsThatCanBeSaved["Recolor visualsToggle"].Api.Enabled
		end
		return friend
	end
	return nil
end

local function isTarget(plr)
	local friend = table.find(GuiLibrary.ObjectsThatCanBeSaved.TargetsListTextCircleList.Api.ObjectList, plr.Name)
	friend = friend and GuiLibrary.ObjectsThatCanBeSaved.TargetsListTextCircleList.Api.ObjectListEnabled[friend]
	return friend
end

local function isVulnerable(plr)
	return plr.Humanoid.Health > 0 and not plr.Character.FindFirstChildWhichIsA(plr.Character, "ForceField")
end

local function getPlayerColor(plr)
	if isFriend(plr, true) then
		return Color3.fromHSV(GuiLibrary.ObjectsThatCanBeSaved["Friends ColorSliderColor"].Api.Hue, GuiLibrary.ObjectsThatCanBeSaved["Friends ColorSliderColor"].Api.Sat, GuiLibrary.ObjectsThatCanBeSaved["Friends ColorSliderColor"].Api.Value)
	end
	return tostring(plr.TeamColor) ~= "White" and plr.TeamColor.Color
end

getTablePosition = function(tab, val, first)
	local count = 0
	for i,v in tab do
		count = count + 1 
		if (first and i or v) == val then 
			break
		end
	end
	return count
end

isAlive = function(plr, nohealth) 
	plr = plr or lplr
	local alive = false
	if plr.Character and plr.Character:FindFirstChildWhichIsA("Humanoid") and plr.Character.PrimaryPart and plr.Character:FindFirstChild("Head") then 
		alive = true
	end
	local success, health = pcall(function() return plr.Character:FindFirstChildWhichIsA("Humanoid").Health end)
	if success and health <= 0 and not nohealth then
		alive = false
	end
	return alive
end

playerRaycasted = function(plr, customvector)
	plr = plr or lplr
	return workspace:Raycast(plr.Character.PrimaryPart.Position, customvector or Vector3.new(0, -10000, 0), RenderStore.objectraycast)
end

GetTarget = function(distance, healthmethod, raycast, npc)
	local magnitude, target = distance or healthmethod and 0 or math.huge, {} 
	for i,v in playersService:GetPlayers() do 
		if v ~= lplr and isAlive(v) and isAlive(lplr, true) then 
			if not RenderFunctions:GetPlayerType(2) then 
				continue
			end
			if not ({shared.vapewhitelist:GetWhitelist(v)})[2] then
				continue
			end
			if not shared.vapeentity.isPlayerTargetable(v) then 
				continue
			end
			if not playerRaycasted(v) and raycast then 
				continue
			end
			if healthmethod and v.Character.Humanoid.Health < magnitude then 
				magnitude = v.Character.Humanoid.Health
				target.Human = true
				target.RootPart = v.Character.HumanoidRootPart
				target.Humanoid = v.Character.Humanoid
				target.Player = v
				continue
			end 
			local playerdistance = (lplr.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
			if playerdistance < magnitude then 
				magnitude = playerdistance
				target.Human = true
				target.RootPart = v.Character.HumanoidRootPart
				target.Humanoid = v.Character.Humanoid
				target.Player = v
			end
		end
	end
	return target
end

characterDescendant = function(obje)
	for i,v in playersService:GetPlayers() do 
		if v.Character and part:IsDescendantOf(v.Character) then 
			return v 
		end
	end
end

GetAllTargets = function(distance, sort)
	local targets = {}
	for i,v in playersService:GetPlayers() do 
		if v ~= lplr and isAlive(v) and isAlive(lplr, true) then 
			if not RenderFunctions:GetPlayerType(2) then 
				continue
			end
			if not ({WhitelistFunctions:GetWhitelist(v)})[2] then 
				continue
			end
			if not entityLibrary.isPlayerTargetable(v) then 
				continue
			end
			local playerdistance = (lplr.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
			if playerdistance <= (distance or math.huge) then 
				table.insert(targets, {Human = true, RootPart = v.Character.PrimaryPart, Humanoid = v.Character.Humanoid, Player = v})
			end
		end
	end
	if sort then 
		table.sort(targets, sort)
	end
	return targets
end

getnewserver = function(customgame, popular, performance)
	local players, server = 0, nil
	local success, serverTable = pcall(function() return httpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..(customgame or game.PlaceId).."/servers/Public?sortOrder=Asc&limit=100", true)) end)
	if success and type(serverTable) == "table" and type(serverTable.data) == "table" then 
		for i,v in serverTable.data do 
			if v.id and v.playing and v.maxPlayers and tonumber(v.maxPlayers) > tonumber(v.playing) and tonumber(v.playing) > 0 then 
				if v.id == tostring(game.JobId) then 
					continue 
				end
				if tonumber(v.playing) < players and popular then 
					continue
				end
				if performance and v.ping and tonumber(v.ping) > 170 then
					continue
				end
				players = tonumber(v.playing)
				server = v.id
			end
		end
	end
	return server
end

local entityLibrary = loadstring(getvapefile("Libraries/entityHandler.lua"))()
task.spawn(function()
    shared.vapeentity = entityLibrary
	entityLibrary.selfDestruct()
	table.insert(vapeConnections, GuiLibrary.ObjectsThatCanBeSaved.FriendsListTextCircleList.Api.FriendRefresh.Event:Connect(function()
		entityLibrary.fullEntityRefresh()
	end))
	table.insert(vapeConnections, GuiLibrary.ObjectsThatCanBeSaved["Teams by colorToggle"].Api.Refresh.Event:Connect(function()
		entityLibrary.fullEntityRefresh()
	end))
	local oldUpdateBehavior = entityLibrary.getUpdateConnections
	entityLibrary.getUpdateConnections = function(newEntity)
		local oldUpdateConnections = oldUpdateBehavior(newEntity)
		table.insert(oldUpdateConnections, {Connect = function() 
			newEntity.Friend = isFriend(newEntity.Player) and true
			newEntity.Target = isTarget(newEntity.Player) and true
			return {Disconnect = function() end}
		end})
		return oldUpdateConnections
	end
	entityLibrary.isPlayerTargetable = function(plr)
		if isFriend(plr) then return false end
		if (not GuiLibrary.ObjectsThatCanBeSaved["Teams by colorToggle"].Api.Enabled) then return true end
		if (not lplr.Team) then return true end
		if (not plr.Team) then return true end
		if plr.Team ~= lplr.Team then return true end
        return #plr.Team:GetPlayers() == playersService.NumPlayers
	end
	entityLibrary.fullEntityRefresh()
	entityLibrary.LocalPosition = Vector3.zero

	task.spawn(function()
		local postable = {}
		repeat
			task.wait()
			if entityLibrary.isAlive then
				table.insert(postable, {Time = tick(), Position = entityLibrary.character.HumanoidRootPart.Position})
				if #postable > 100 then 
					table.remove(postable, 1)
				end
				local closestmag = 9e9
				local closestpos = entityLibrary.character.HumanoidRootPart.Position
				local currenttime = tick()
				for i, v in pairs(postable) do 
					local mag = 0.1 - (currenttime - v.Time)
					if mag < closestmag and mag > 0 then
						closestmag = mag
						closestpos = v.Position
					end
				end
				entityLibrary.LocalPosition = closestpos
			end
		until not vapeInjected
	end)
end)

local function calculateMoveVector(cameraRelativeMoveVector)
	local c, s
	local _, _, _, R00, R01, R02, _, _, R12, _, _, R22 = gameCamera.CFrame:GetComponents()
	if R12 < 1 and R12 > -1 then
		c = R22
		s = R02
	else
		c = R00
		s = -R01*math.sign(R12)
	end
	local norm = math.sqrt(c*c + s*s)
	return Vector3.new(
		(c*cameraRelativeMoveVector.X + s*cameraRelativeMoveVector.Z)/norm,
		0,
		(c*cameraRelativeMoveVector.Z - s*cameraRelativeMoveVector.X)/norm
	)
end

local raycastWallProperties = RaycastParams.new()
local function raycastWallCheck(char, checktable)
	if not checktable.IgnoreObject then 
		checktable.IgnoreObject = raycastWallProperties
		local filter = {lplr.Character, gameCamera}
		for i,v in pairs(entityLibrary.entityList) do 
			if v.Targetable then 
				table.insert(filter, v.Character)
			end 
		end
		for i,v in pairs(checktable.IgnoreTable or {}) do 
			table.insert(filter, v)
		end
		raycastWallProperties.FilterDescendantsInstances = filter
	end
	local ray = workspace.Raycast(workspace, checktable.Origin, (char[checktable.AimPart].Position - checktable.Origin), checktable.IgnoreObject)
	return not ray
end

local function EntityNearPosition(distance, checktab)
	checktab = checktab or {}
	if entityLibrary.isAlive then
		local sortedentities = {}
		for i, v in pairs(entityLibrary.entityList) do -- loop through playersService
			if not v.Targetable then continue end
            if isVulnerable(v) then -- checks
				local playerPosition = v.RootPart.Position
				local mag = (entityLibrary.character.HumanoidRootPart.Position - playerPosition).magnitude
				if checktab.Prediction and mag > distance then
					mag = (entityLibrary.LocalPosition - playerPosition).magnitude
				end
                if mag <= distance then -- mag check
					table.insert(sortedentities, {entity = v, Magnitude = v.Target and -1 or mag})
                end
            end
        end
		table.sort(sortedentities, function(a, b) return a.Magnitude < b.Magnitude end)
		for i, v in pairs(sortedentities) do 
			if checktab.WallCheck then
				if not raycastWallCheck(v.entity, checktab) then continue end
			end
			return v.entity
		end
	end
end

local function EntityNearMouse(distance, checktab)
	checktab = checktab or {}
    if entityLibrary.isAlive then
		local sortedentities = {}
		local mousepos = inputService.GetMouseLocation(inputService)
		for i, v in pairs(entityLibrary.entityList) do
			if not v.Targetable then continue end
            if isVulnerable(v) then
				local vec, vis = worldtoscreenpoint(v[checktab.AimPart].Position)
				local mag = (mousepos - Vector2.new(vec.X, vec.Y)).magnitude
                if vis and mag <= distance then
					table.insert(sortedentities, {entity = v, Magnitude = v.Target and -1 or mag})
                end
            end
        end
		table.sort(sortedentities, function(a, b) return a.Magnitude < b.Magnitude end)
		for i, v in pairs(sortedentities) do 
			if checktab.WallCheck then
				if not raycastWallCheck(v.entity, checktab) then continue end
			end
			return v.entity
		end
    end
end

local function AllNearPosition(distance, amount, checktab)
	local returnedplayer = {}
	local currentamount = 0
	checktab = checktab or {}
    if entityLibrary.isAlive then
		local sortedentities = {}
		for i, v in pairs(entityLibrary.entityList) do
			if not v.Targetable then continue end
            if isVulnerable(v) then
				local playerPosition = v.RootPart.Position
				local mag = (entityLibrary.character.HumanoidRootPart.Position - playerPosition).magnitude
				if checktab.Prediction and mag > distance then
					mag = (entityLibrary.LocalPosition - playerPosition).magnitude
				end
                if mag <= distance then
					table.insert(sortedentities, {entity = v, Magnitude = mag})
                end
            end
        end
		table.sort(sortedentities, function(a, b) return a.Magnitude < b.Magnitude end)
		for i,v in pairs(sortedentities) do 
			if checktab.WallCheck then
				if not raycastWallCheck(v.entity, checktab) then continue end
			end
			table.insert(returnedplayer, v.entity)
			currentamount = currentamount + 1
			if currentamount >= amount then break end
		end
	end
	return returnedplayer
end

local WhitelistFunctions = {StoredHashes = {}, WhitelistTable = {WhitelistedUsers = {}}, Loaded = false, CustomTags = {}, LocalPriority = 0}
do
	local shalib

	task.spawn(function()
		local whitelistloaded
		whitelistloaded = pcall(function()
			local commit = "main"
			for i,v in pairs(game:HttpGet("https://github.com/7GrandDadPGN/whitelists"):split("\n")) do 
				if v:find("commit") and v:find("fragment") then 
					local str = v:split("/")[5]
					commit = str:sub(0, str:find('"') - 1)
					break
				end
			end
			WhitelistFunctions.WhitelistTable = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://raw.githubusercontent.com/7GrandDadPGN/whitelists/"..commit.."/PlayerWhitelist.json", true))
		end)
		shalib = loadstring(getvapefile("Libraries/sha.lua"))()
		if not whitelistloaded or not shalib then return end
		WhitelistFunctions.Loaded = true
		WhitelistFunctions.LocalPriority = WhitelistFunctions:GetWhitelist(lplr)
		entityLibrary.fullEntityRefresh()
	end)

	function WhitelistFunctions:GetWhitelist(plr)
		local plrstr = WhitelistFunctions:Hash(plr.Name..plr.UserId)
		for i,v in pairs(WhitelistFunctions.WhitelistTable.WhitelistedUsers) do
			if v.hash == plrstr then
				return v.level, v.attackable or WhitelistFunctions.LocalPriority > v.level, v.tags
			end
		end
		return 0, true
	end

	function WhitelistFunctions:GetTag(plr)
		local plrstr, plrattackable, plrtag = WhitelistFunctions:GetWhitelist(plr)
		local hash = WhitelistFunctions:Hash(plr.Name..plr.UserId)
		local newtag = WhitelistFunctions.CustomTags[plr.Name] or ""
		if plrtag then
			for i2,v2 in pairs(plrtag) do
				newtag = newtag..'['..v2.text..'] '
			end
		end
		return newtag
	end

	function WhitelistFunctions:Hash(str)
		if WhitelistFunctions.StoredHashes[str] == nil and shalib then
			WhitelistFunctions.StoredHashes[str] = shalib.sha512(str.."SelfReport")
		end
		return WhitelistFunctions.StoredHashes[str] or ""
	end

	function WhitelistFunctions:CheckWhitelisted(plr)
		local playertype = WhitelistFunctions:GetWhitelist(plr)
		if playertype ~= 0 then 
			return true
		end
		return false
	end

	function WhitelistFunctions:IsSpecialIngame()
		for i,v in pairs(playersService:GetPlayers()) do 
			if WhitelistFunctions:CheckWhitelisted(v) then 
				return true
			end
		end
		return false
	end
end
shared.vapewhitelist = WhitelistFunctions

local RunLoops = {RenderStepTable = {}, StepTable = {}, HeartTable = {}}
do
	function RunLoops:BindToRenderStep(name, func)
		if RunLoops.RenderStepTable[name] == nil then
			RunLoops.RenderStepTable[name] = runService.RenderStepped:Connect(func)
		end
	end

	function RunLoops:UnbindFromRenderStep(name)
		if RunLoops.RenderStepTable[name] then
			RunLoops.RenderStepTable[name]:Disconnect()
			RunLoops.RenderStepTable[name] = nil
		end
	end

	function RunLoops:BindToStepped(name, func)
		if RunLoops.StepTable[name] == nil then
			RunLoops.StepTable[name] = runService.Stepped:Connect(func)
		end
	end

	function RunLoops:UnbindFromStepped(name)
		if RunLoops.StepTable[name] then
			RunLoops.StepTable[name]:Disconnect()
			RunLoops.StepTable[name] = nil
		end
	end

	function RunLoops:BindToHeartbeat(name, func)
		if RunLoops.HeartTable[name] == nil then
			RunLoops.HeartTable[name] = runService.Heartbeat:Connect(func)
		end
	end

	function RunLoops:UnbindFromHeartbeat(name)
		if RunLoops.HeartTable[name] then
			RunLoops.HeartTable[name]:Disconnect()
			RunLoops.HeartTable[name] = nil
		end
	end
end

GuiLibrary.SelfDestructEvent.Event:Connect(function()
	vapeInjected = false
	entityLibrary.selfDestruct()
	for i, v in pairs(vapeConnections) do
		if v.Disconnect then pcall(function() v:Disconnect() end) continue end
		if v.disconnect then pcall(function() v:disconnect() end) continue end
	end
	getgenv().RenderStore = nil
end)

local KillauraNearTarget = false
runFunction(function()
	for i,v in {"Killaura", "Reach"} do 
		pcall(GuiLibrary.RemoveObject, v.."OptionsButton")
	end
	local attackIgnore = OverlapParams.new()
	attackIgnore.FilterType = Enum.RaycastFilterType.Whitelist
	local function findTouchInterest(tool)
		return tool and tool:FindFirstChildWhichIsA("TouchTransmitter", true)
	end

	local Reach = {Enabled = false}
	local ReachRange = {Value = 1}
	Reach = GuiLibrary.ObjectsThatCanBeSaved.CombatWindow.Api.CreateOptionsButton({
		Name = "Reach", 
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat
						if entityLibrary.isAlive then
							local tool = lplr and lplr.Character and lplr.Character:FindFirstChildWhichIsA("Tool")
							local touch = findTouchInterest(tool)
							if tool and touch then
								touch = touch.Parent
								local chars = {}
								for i,v in pairs(entityLibrary.entityList) do table.insert(chars, v.Character) end
								ignorelist.FilterDescendantsInstances = chars
								local parts = workspace:GetPartBoundsInBox(touch.CFrame, touch.Size + Vector3.new(reachrange.Value, 0, reachrange.Value), ignorelist)
								for i,v in pairs(parts) do 
									firetouchinterest(touch, v, 1)
									firetouchinterest(touch, v, 0)
								end
							end
						end
						task.wait()
					until not Reach.Enabled
				end)
			end
		end
	})
	ReachRange = Reach.CreateSlider({
		Name = "Range", 
		Min = 1,
		Max = 20, 
		Function = function(val) end,
	})

	local Killaura = {Enabled = false}
	local KillauraCPS = {GetRandomValue = function() return 1 end}
	local KillauraMethod = {Value = "Normal"}
	local KillauraTarget = {Enabled = false}
	local KillauraColor = {Value = 0.44}
	local KillauraRange = {Value = 1}
	local KillauraAngle = {Value = 90}
	local KillauraFakeAngle = {Enabled = false}
	local KillauraPrediction = {Enabled = true}	
	local KillauraButtonDown = {Enabled = false}
	local KillauraTargetHighlight = {Enabled = false}
	local KillauraRangeCircle = {Enabled = false}
	local KillauraRangeCirclePart
	local KillauraSwingTick = tick()
	local KillauraBoxes = {}
	local OriginalNeckC0
	local OriginalRootC0
	for i = 1, 10 do 
		local KillauraBox = Instance.new("BoxHandleAdornment")
		KillauraBox.Transparency = 0.5
		KillauraBox.Color3 = Color3.fromHSV(KillauraColor.Hue, KillauraColor.Sat, KillauraColor.Value)
		KillauraBox.Adornee = nil
		KillauraBox.AlwaysOnTop = true
		KillauraBox.Size = Vector3.new(3, 6, 3)
		KillauraBox.ZIndex = 11
		KillauraBox.Parent = GuiLibrary.MainGui
		KillauraBoxes[i] = KillauraBox
	end

	Killaura = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "Killaura", 
		Function = function(callback)
			if callback then
				if KillauraRangeCirclePart then KillauraRangeCirclePart.Parent = gameCamera end
				RunLoops:BindToHeartbeat("Killaura", function()
					for i,v in pairs(KillauraBoxes) do 
						if v.Adornee then
							local onex, oney, onez = v.Adornee.CFrame:ToEulerAnglesXYZ() 
							v.CFrame = CFrame.new() * CFrame.Angles(-onex, -oney, -onez)
						end
					end
					if entityLibrary.isAlive then 
						if KillauraRangeCirclePart then
							KillauraRangeCirclePart.CFrame = entityLibrary.character.HumanoidRootPart.CFrame - Vector3.new(0, entityLibrary.character.Humanoid.HipHeight + (entityLibrary.character.HumanoidRootPart.Size.Y / 2) - 0.3, 0)
						end
						if KillauraFakeAngle.Enabled then 
							local Neck = entityLibrary.character.Head:FindFirstChild("Neck")
							local LowerTorso = entityLibrary.character.HumanoidRootPart.Parent and entityLibrary.character.HumanoidRootPart.Parent:FindFirstChild("LowerTorso")
							local RootC0 = LowerTorso and LowerTorso:FindFirstChild("Root")
							if Neck and RootC0 then
								if not OriginalNeckC0 then OriginalNeckC0 = Neck.C0.p end
								if not OriginalRootC0 then OriginalRootC0 = RootC0.C0.p end
								if OriginalRootC0 then
									if targetedplayer ~= nil then
										local targetPos = targetedplayer.RootPart.Position + Vector3.new(0, targetedplayer.Humanoid.HipHeight + (targetedplayer.RootPart.Size.Y / 2), 0)
										local lookCFrame = (CFrame.new(Vector3.zero, (Root.CFrame):VectorToObjectSpace((Vector3.new(targetPos.X, targetPos.Y, targetPos.Z) - entityLibrary.character.Head.Position).Unit)))
										Neck.C0 = CFrame.new(OriginalNeckC0) * CFrame.Angles(lookCFrame.LookVector.Unit.y, 0, 0)
										RootC0.C0 = (CFrame.new(Vector3.zero, (Root.CFrame):VectorToObjectSpace((Vector3.new(targetPos.X, Root.Position.Y, targetPos.Z) - Root.Position).Unit))) + OriginalRootC0
									else
										Neck.C0 = CFrame.new(OriginalNeckC0)
										RootC0.C0 = CFrame.new(OriginalRootC0)
									end
								end
							end
						end
					end
				end)
				task.spawn(function()
					repeat
						local attackedplayers = {}
						KillauraNearTarget = false
						vapeTargetInfo.Targets.Killaura = nil
						if entityLibrary.isAlive and (not KillauraButtonDown.Enabled or inputService:IsMouseButtonPressed(0)) then
							local plrs = AllNearPosition(KillauraRange.Value, 100, {Prediction = KillauraPrediction.Enabled})
							if #plrs > 0 then
								local tool = lplr.Character:FindFirstChildWhichIsA("Tool")
								local touch = findTouchInterest(tool)
								if tool and touch then
									for i,v in pairs(plrs) do
										if math.acos(entityLibrary.character.HumanoidRootPart.CFrame.lookVector:Dot((v.RootPart.Position - entityLibrary.character.HumanoidRootPart.Position).Unit)) >= (math.rad(KillauraAngle.Value) / 2) then continue end
										KillauraNearTarget = true
										if KillauraTarget.Enabled then
											table.insert(attackedplayers, v)
										end
										vapeTargetInfo.Targets.Killaura = v
										if not ({WhitelistFunctions:GetWhitelist(v.Player)})[2] then
											continue
										end
										KillauraNearTarget = true
										if KillauraPrediction.Enabled then
											if (entityLibrary.LocalPosition - v.RootPart.Position).Magnitude > KillauraRange.Value then
												continue
											end
										end
										if KillauraSwingTick <= tick() then
											tool:Activate()
											KillauraSwingTick = tick() + (1 / KillauraCPS.GetRandomValue())
										end
										if KillauraMethod.Value == "Bypass" then 
											attackIgnore.FilterDescendantsInstances = {v.Character}
											local parts = workspace:GetPartBoundsInBox(v.RootPart.CFrame, v.Character:GetExtentsSize(), attackIgnore)
											for i,v2 in pairs(parts) do 
												firetouchinterest(touch.Parent, v2, 1)
												firetouchinterest(touch.Parent, v2, 0)
											end
										elseif KillauraMethod.Value == "Normal" then
											for i,v2 in pairs(v.Character:GetChildren()) do 
												if v2:IsA("BasePart") then
													firetouchinterest(touch.Parent, v2, 1)
													firetouchinterest(touch.Parent, v2, 0)
												end
											end
										else
											firetouchinterest(touch.Parent, v.RootPart, 1)
											firetouchinterest(touch.Parent, v.RootPart, 0)
										end
									end
								end
							end
						end
						for i,v in pairs(KillauraBoxes) do 
							local attacked = attackedplayers[i]
							v.Adornee = attacked and attacked.RootPart
						end
						task.wait()
					until not Killaura.Enabled
				end)
			else
				RunLoops:UnbindFromHeartbeat("Killaura") 
                KillauraNearTarget = false
				vapeTargetInfo.Targets.Killaura = nil
				for i,v in pairs(KillauraBoxes) do v.Adornee = nil end
				if KillauraRangeCirclePart then KillauraRangeCirclePart.Parent = nil end
			end
		end,
		HoverText = "Attack players around you\nwithout aiming at them."
	})
	KillauraMethod = Killaura.CreateDropdown({
		Name = "Mode",
		List = {"Normal", "Bypass", "Root Only"},
		Function = function() end
	})
	KillauraCPS = Killaura.CreateTwoSlider({
		Name = "Attacks per second",
		Min = 1,
		Max = 20,
		Default = 8,
		Default2 = 12
	})
	KillauraRange = Killaura.CreateSlider({
		Name = "Attack range",
		Min = 1,
		Max = 150, 
		Function = function(val) 
			if KillauraRangeCirclePart then 
				KillauraRangeCirclePart.Size = Vector3.new(val * 0.7, 0.01, val * 0.7)
			end
		end
	})
	KillauraAngle = Killaura.CreateSlider({
		Name = "Max angle",
		Min = 1,
		Max = 360, 
		Function = function(val) end,
		Default = 90
	})
	KillauraColor = Killaura.CreateColorSlider({
		Name = "Target Color",
		Function = function(hue, sat, val) 
			for i,v in pairs(KillauraBoxes) do 
				v.Color3 = Color3.fromHSV(hue, sat, val)
			end
			if KillauraRangeCirclePart then 
				KillauraRangeCirclePart.Color = Color3.fromHSV(hue, sat, val)
			end
		end,
		Default = 1
	})
	KillauraButtonDown = Killaura.CreateToggle({
		Name = "Require mouse down", 
		Function = function() end
	})
	KillauraTarget = Killaura.CreateToggle({
        Name = "Show target",
        Function = function(callback) end,
		HoverText = "Shows a red box over the opponent."
    })
	KillauraPrediction = Killaura.CreateToggle({
		Name = "Prediction",
		Function = function() end
	})
	KillauraFakeAngle = Killaura.CreateToggle({
        Name = "Face target",
        Function = function() end,
		HoverText = "Makes your character face the opponent."
    })
	KillauraRangeCircle = Killaura.CreateToggle({
		Name = "Range Visualizer",
		Function = function(callback)
			if callback then 
				KillauraRangeCirclePart = Instance.new("MeshPart")
				KillauraRangeCirclePart.MeshId = "rbxassetid://3726303797"
				KillauraRangeCirclePart.Color = Color3.fromHSV(KillauraColor.Hue, KillauraColor.Sat, KillauraColor.Value)
				KillauraRangeCirclePart.CanCollide = false
				KillauraRangeCirclePart.Anchored = true
				KillauraRangeCirclePart.Material = Enum.Material.Neon
				KillauraRangeCirclePart.Size = Vector3.new(KillauraRange.Value * 0.7, 0.01, KillauraRange.Value * 0.7)
				KillauraRangeCirclePart.Parent = gameCamera
			else
				if KillauraRangeCirclePart then 
					KillauraRangeCirclePart:Destroy()
					KillauraRangeCirclePart = nil
				end
			end
		end
	})
end)

runFunction(function()
	pcall(GuiLibrary.RemoveObject, "NameTagsOptionsButton")
	local function floorNameTagPosition(pos)
		return Vector2.new(math.floor(pos.X), math.floor(pos.Y))
	end

	local function removeTags(str)
        str = str:gsub("<br%s*/>", "\n")
        return (str:gsub("<[^<>]->", ""))
    end

	local NameTagsFolder = Instance.new("Folder")
	NameTagsFolder.Name = "NameTagsFolder"
	NameTagsFolder.Parent = GuiLibrary.MainGui
	local nametagsfolderdrawing = {}
	local NameTagsColor = {Value = 0.44}
	local NameTagsDisplayName = {Enabled = false}
	local NameTagsHealth = {Enabled = false}
	local NameTagsDistance = {Enabled = false}
	local NameTagsBackground = {Enabled = true}
	local NameTagsScale = {Value = 10}
	local NameTagsFont = {Value = "SourceSans"}
	local NameTagsTeammates = {Enabled = true}
	local fontitems = {"SourceSans"}
	local nametagstrs = {}
	local nametagsizes = {}

	local nametagfuncs1 = {
		Normal = function(plr)
			if NameTagsTeammates.Enabled and (not plr.Targetable) and (not plr.Friend) then return end
			local thing = Instance.new("TextLabel")
			thing.BackgroundColor3 = Color3.new()
			thing.BorderSizePixel = 0
			thing.Visible = false
			thing.RichText = true
			thing.AnchorPoint = Vector2.new(0.5, 1)
			thing.Name = plr.Player.Name
			thing.Font = Enum.Font[NameTagsFont.Value]
			thing.TextSize = 14 * (NameTagsScale.Value / 10)
			thing.BackgroundTransparency = NameTagsBackground.Enabled and 0.5 or 1
			nametagstrs[plr.Player] = WhitelistFunctions:GetTag(plr.Player)..(NameTagsDisplayName.Enabled and plr.Player.DisplayName or plr.Player.Name)
			if NameTagsHealth.Enabled then
				local color = Color3.fromHSV(math.clamp(plr.Humanoid.Health / plr.Humanoid.MaxHealth, 0, 1) / 2.5, 0.89, 1)
				nametagstrs[plr.Player] = nametagstrs[plr.Player]..' <font color="rgb('..tostring(math.floor(color.R * 255))..','..tostring(math.floor(color.G * 255))..','..tostring(math.floor(color.B * 255))..')">'..math.round(plr.Humanoid.Health).."</font>"
			end
			if NameTagsDistance.Enabled then 
				nametagstrs[plr.Player] = '<font color="rgb(85, 255, 85)">[</font><font color="rgb(255, 255, 255)">%s</font><font color="rgb(85, 255, 85)">]</font> '..nametagstrs[plr.Player]
			end
			local nametagSize = textService:GetTextSize(removeTags(nametagstrs[plr.Player]), thing.TextSize, thing.Font, Vector2.new(100000, 100000))
			thing.Size = UDim2.new(0, nametagSize.X + 4, 0, nametagSize.Y)
			thing.Text = nametagstrs[plr.Player]
			thing.TextColor3 = getPlayerColor(plr.Player) or Color3.fromHSV(NameTagsColor.Hue, NameTagsColor.Sat, NameTagsColor.Value)
			thing.Parent = NameTagsFolder
			nametagsfolderdrawing[plr.Player] = {entity = plr, Main = thing}
		end,
		Drawing = function(plr)
			if NameTagsTeammates.Enabled and (not plr.Targetable) and (not plr.Friend) then return end
			local thing = {Main = {}, entity = plr}
			thing.Main.Text = Drawing.new("Text")
			thing.Main.Text.Size = 17 * (NameTagsScale.Value / 10)
			thing.Main.Text.Font = (math.clamp((table.find(fontitems, NameTagsFont.Value) or 1) - 1, 0, 3))
			thing.Main.Text.ZIndex = 2
			thing.Main.BG = Drawing.new("Square")
			thing.Main.BG.Filled = true
			thing.Main.BG.Transparency = 0.5
			thing.Main.BG.Visible = NameTagsBackground.Enabled
			thing.Main.BG.Color = Color3.new()
			thing.Main.BG.ZIndex = 1
			nametagstrs[plr.Player] = WhitelistFunctions:GetTag(plr.Player)..(NameTagsDisplayName.Enabled and plr.Player.DisplayName or plr.Player.Name)
			if NameTagsHealth.Enabled then
				local color = Color3.fromHSV(math.clamp(plr.Humanoid.Health / plr.Humanoid.MaxHealth, 0, 1) / 2.5, 0.89, 1)
				nametagstrs[plr.Player] = nametagstrs[plr.Player]..' '..math.round(plr.Humanoid.Health)
			end
			if NameTagsDistance.Enabled then 
				nametagstrs[plr.Player] = '[%s] '..nametagstrs[plr.Player]
			end
			thing.Main.Text.Text = nametagstrs[plr.Player]
			thing.Main.BG.Size = Vector2.new(thing.Main.Text.TextBounds.X + 4, thing.Main.Text.TextBounds.Y)
			thing.Main.Text.Color = getPlayerColor(plr.Player) or Color3.fromHSV(NameTagsColor.Hue, NameTagsColor.Sat, NameTagsColor.Value)
			nametagsfolderdrawing[plr.Player] = thing
		end
	}

	local nametagfuncs2 = {
		Normal = function(ent)
			local v = nametagsfolderdrawing[ent]
			nametagsfolderdrawing[ent] = nil
			if v then 
				v.Main:Destroy()
			end
		end,
		Drawing = function(ent)
			local v = nametagsfolderdrawing[ent]
			nametagsfolderdrawing[ent] = nil
			if v then 
				for i2,v2 in pairs(v.Main) do
					pcall(function() v2.Visible = false v2:Remove() end)
				end
			end
		end
	}

	local nametagupdatefuncs = {
		Normal = function(ent)
			local v = nametagsfolderdrawing[ent.Player]
			if v then 
				nametagstrs[ent.Player] = WhitelistFunctions:GetTag(ent.Player)..(NameTagsDisplayName.Enabled and ent.Player.DisplayName or ent.Player.Name)
				if NameTagsHealth.Enabled then
					local color = Color3.fromHSV(math.clamp(ent.Humanoid.Health / ent.Humanoid.MaxHealth, 0, 1) / 2.5, 0.89, 1)
					nametagstrs[ent.Player] = nametagstrs[ent.Player]..' <font color="rgb('..tostring(math.floor(color.R * 255))..','..tostring(math.floor(color.G * 255))..','..tostring(math.floor(color.B * 255))..')">'..math.round(ent.Humanoid.Health).."</font>"
				end
				if NameTagsDistance.Enabled then 
					nametagstrs[ent.Player] = '<font color="rgb(85, 255, 85)">[</font><font color="rgb(255, 255, 255)">%s</font><font color="rgb(85, 255, 85)">]</font> '..nametagstrs[ent.Player]
				end
				local nametagSize = textService:GetTextSize(removeTags(nametagstrs[ent.Player]), v.Main.TextSize, v.Main.Font, Vector2.new(100000, 100000))
				v.Main.Size = UDim2.new(0, nametagSize.X + 4, 0, nametagSize.Y)
				v.Main.Text = nametagstrs[ent.Player]
			end
		end,
		Drawing = function(ent)
			local v = nametagsfolderdrawing[ent.Player]
			if v then 
				nametagstrs[ent.Player] = WhitelistFunctions:GetTag(ent.Player)..(NameTagsDisplayName.Enabled and ent.Player.DisplayName or ent.Player.Name)
				if NameTagsHealth.Enabled then
					nametagstrs[ent.Player] = nametagstrs[ent.Player]..' '..math.round(ent.Humanoid.Health)
				end
				if NameTagsDistance.Enabled then 
					nametagstrs[ent.Player] = '[%s] '..nametagstrs[ent.Player]
					v.Main.Text.Text = entityLibrary.isAlive and string.format(nametagstrs[ent.Player], math.floor((entityLibrary.character.HumanoidRootPart.Position - ent.RootPart.Position).Magnitude)) or nametagstrs[ent.Player]
				else
					v.Main.Text.Text = nametagstrs[ent.Player]
				end
				v.Main.BG.Size = Vector2.new(v.Main.Text.TextBounds.X + 4, v.Main.Text.TextBounds.Y)
				v.Main.Text.Color = getPlayerColor(ent.Player) or Color3.fromHSV(NameTagsColor.Hue, NameTagsColor.Sat, NameTagsColor.Value)
			end
		end
	}

	local nametagcolorfuncs = {
		Normal = function(hue, sat, value)
			local color = Color3.fromHSV(hue, sat, value)
			for i,v in pairs(nametagsfolderdrawing) do 
				v.Main.TextColor3 = getPlayerColor(v.entity.Player) or color
			end
		end,
		Drawing = function(hue, sat, value)
			local color = Color3.fromHSV(hue, sat, value)
			for i,v in pairs(nametagsfolderdrawing) do 
				v.Main.Text.Color = getPlayerColor(v.entity.Player) or color
			end
		end
	}

	local nametagloop = {
		Normal = function()
			for i,v in pairs(nametagsfolderdrawing) do 
				local headPos, headVis = worldtoscreenpoint((v.entity.RootPart:GetRenderCFrame() * CFrame.new(0, v.entity.Head.Size.Y + v.entity.RootPart.Size.Y, 0)).Position)
				if not headVis then 
					v.Main.Visible = false
					continue
				end
				if NameTagsDistance.Enabled and entityLibrary.isAlive then
					local mag = math.floor((entityLibrary.character.HumanoidRootPart.Position - v.entity.RootPart.Position).Magnitude)
					local stringsize = tostring(mag):len()
					if nametagsizes[v.entity.Player] ~= stringsize then 
						local nametagSize = textService:GetTextSize(removeTags(string.format(nametagstrs[v.entity.Player], mag)), v.Main.TextSize, v.Main.Font, Vector2.new(100000, 100000))
						v.Main.Size = UDim2.new(0, nametagSize.X + 4, 0, nametagSize.Y)
					end
					nametagsizes[v.entity.Player] = stringsize
					v.Main.Text = string.format(nametagstrs[v.entity.Player], mag)
				end
				v.Main.Position = UDim2.new(0, headPos.X, 0, headPos.Y)
				v.Main.Visible = true
			end
		end,
		Drawing = function()
			for i,v in pairs(nametagsfolderdrawing) do 
				local headPos, headVis = worldtoscreenpoint((v.entity.RootPart:GetRenderCFrame() * CFrame.new(0, v.entity.Head.Size.Y + v.entity.RootPart.Size.Y, 0)).Position)
				if not headVis then 
					v.Main.Text.Visible = false
					v.Main.BG.Visible = false
					continue
				end
				if NameTagsDistance.Enabled and entityLibrary.isAlive then
					local mag = math.floor((entityLibrary.character.HumanoidRootPart.Position - v.entity.RootPart.Position).Magnitude)
					local stringsize = tostring(mag):len()
					v.Main.Text.Text = string.format(nametagstrs[v.entity.Player], mag)
					if nametagsizes[v.entity.Player] ~= stringsize then 
						v.Main.BG.Size = Vector2.new(v.Main.Text.TextBounds.X + 4, v.Main.Text.TextBounds.Y)
					end
					nametagsizes[v.entity.Player] = stringsize
				end
				v.Main.BG.Position = Vector2.new(headPos.X - (v.Main.BG.Size.X / 2), (headPos.Y + v.Main.BG.Size.Y))
				v.Main.Text.Position = v.Main.BG.Position + Vector2.new(2, 0)
				v.Main.Text.Visible = true
				v.Main.BG.Visible = NameTagsBackground.Enabled
			end
		end
	}

	local methodused

	local NameTags = {Enabled = false}
	NameTags = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "NameTags", 
		Function = function(callback) 
			if callback then
				methodused = NameTagsDrawing.Enabled and "Drawing" or "Normal"
				if nametagfuncs2[methodused] then
					table.insert(NameTags.Connections, entityLibrary.entityRemovedEvent:Connect(nametagfuncs2[methodused]))
				end
				if nametagfuncs1[methodused] then
					local addfunc = nametagfuncs1[methodused]
					for i,v in pairs(entityLibrary.entityList) do 
						if nametagsfolderdrawing[v.Player] then nametagfuncs2[methodused](v.Player) end
						addfunc(v)
					end
					table.insert(NameTags.Connections, entityLibrary.entityAddedEvent:Connect(function(ent)
						if nametagsfolderdrawing[ent.Player] then nametagfuncs2[methodused](ent.Player) end
						addfunc(ent)
					end))
				end
				if nametagupdatefuncs[methodused] then
					table.insert(NameTags.Connections, entityLibrary.entityUpdatedEvent:Connect(nametagupdatefuncs[methodused]))
					for i,v in pairs(entityLibrary.entityList) do 
						nametagupdatefuncs[methodused](v)
					end
				end
				if nametagcolorfuncs[methodused] then 
					table.insert(NameTags.Connections, GuiLibrary.ObjectsThatCanBeSaved.FriendsListTextCircleList.Api.FriendColorRefresh.Event:Connect(function()
						nametagcolorfuncs[methodused](NameTagsColor.Hue, NameTagsColor.Sat, NameTagsColor.Value)
					end))
				end
				if nametagloop[methodused] then 
					RunLoops:BindToRenderStep("NameTags", nametagloop[methodused])
				end
			else
				RunLoops:UnbindFromRenderStep("NameTags")
				if nametagfuncs2[methodused] then
					for i,v in pairs(nametagsfolderdrawing) do 
						nametagfuncs2[methodused](i)
					end
				end
			end
		end,
		HoverText = "Renders nametags on entities through walls."
	})
	for i,v in pairs(Enum.Font:GetEnumItems()) do 
		if v.Name ~= "SourceSans" then 
			table.insert(fontitems, v.Name)
		end
	end
	NameTagsFont = NameTags.CreateDropdown({
		Name = "Font",
		List = fontitems,
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end,
	})
	NameTagsColor = NameTags.CreateColorSlider({
		Name = "Player Color", 
		Function = function(hue, sat, val) 
			if NameTags.Enabled and nametagcolorfuncs[methodused] then 
				nametagcolorfuncs[methodused](hue, sat, val)
			end
		end
	})
	NameTagsScale = NameTags.CreateSlider({
		Name = "Scale",
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end,
		Default = 10,
		Min = 1,
		Max = 50
	})
	NameTagsBackground = NameTags.CreateToggle({
		Name = "Background", 
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end,
		Default = true
	})
	NameTagsDisplayName = NameTags.CreateToggle({
		Name = "Use Display Name", 
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end,
		Default = true
	})
	NameTagsHealth = NameTags.CreateToggle({
		Name = "Health", 
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end
	})
	NameTagsDistance = NameTags.CreateToggle({
		Name = "Distance", 
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end
	})
	NameTagsTeammates = NameTags.CreateToggle({
		Name = "Teammates", 
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end,
		Default = true
	})
	NameTagsDrawing = NameTags.CreateToggle({
		Name = "Drawing",
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end,
	
	})
end)

runFunction(function()
	local FlyTP = {Enabled = false}
	local FlyTPVertical = {Value = 15}
	FlyTP = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "FlyTP",
		NoSave = true,
		Function = function(callback)
			if callback then 
				task.spawn(function()
					repeat 
					   if not isAlive() or not isnetworkowner(lplr.Character.HumanoidRootPart) then
						   FlyTP.ToggleButton(false) 
						   break 
					   end
					  lplr.Character.HumanoidRootPart.CFrame = lplr.Character.HumanoidRootPart.CFrame + Vector3.new(0, FlyTPVertical.Value <= 0 and 1 or FlyTPVertical.Value, 0)
					  lplr.Character.HumanoidRootPart.Velocity = Vector3.new(0, 1, 0)
					  task.wait(0.1)
					until not FlyTP.Enabled
				end)
			end
		end
	})
	FlyTPVertical = FlyTP.CreateSlider({
		Name = "Vertical",
		Min = 15,
		Max = 60,
		Function = function() end
	})
end)

runFunction(function()
	local BoostJump = {Enabled = false}
	local BoostJumpPower = {Value = 5}
	local BoostJumpTime = {Value = 30}
	local boost = 5
	local toggleTick = tick()
	BoostJump = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "BoostJump",
		HoverText = "an indeed interesting high jump.",
		Function = function(callback)
			if callback then 
				task.spawn(function()
					toggleTick = tick() + (BoostJumpTime.Value / 35)
					repeat 
						if tick() > toggleTick or not isAlive() then 
							BoostJump.ToggleButton(false)
							break 
						end
						lplr.Character.HumanoidRootPart.Velocity = Vector3.new(0, boost, 0)
						boost = boost + (BoostJumpPower.Value <= 0 and 1 or BoostJumpPower.Value / 10)
						task.wait()
					until not BoostJump.Enabled
				end)
			else
				boost = 5
			end
		end
	})
	BoostJumpPower = BoostJump.CreateSlider({
		Name = "Vertical",
		Min = 10, 
		Max = 20,
		Default = 35,
		Function = function() end
	})
	BoostJumpTime = BoostJump.CreateSlider({
		Name = "Time",
		Min = 10, 
		Max = 60,
		Default = 32,
		Function = function() end
	})
end)

runFunction(function()
	local InfiniteYield = {Enabled = false}
	InfiniteYield = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "InfiniteYield",
		HoverText = "Loads the Infinite Yield script.",
		Function = function(callback)
			if callback then 
				task.spawn(function()
					if IY_LOADED then 
						return 
					end
					loadstring(RenderFunctions:GetFile("scripts/BetterIY.lua"))()
				end)
			end
		end
	})
end)

pcall(function()
	local Rejoin = {Enabled = false}
	Rejoin = GuiLibrary.ObjectsThatCanBeSaved.MatchmakingWindow.Api.CreateOptionsButton({
		Name = "Rejoin",
		Function = function(callback)
			if callback then
				task.spawn(function()
					Rejoin.ToggleButton(false)
					teleportService:Teleport(game.PlaceId)
				end)
			end
		end
	})
end)

runFunction(function()
	GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "AntiLogger",
		HoverText = "Stops most: IP loggers, and Discord webhooks.",
		Function = function(callback)
			if callback then
				task.spawn(function()
					loadstring(RenderFunctions:GetFile("scripts/antilogger.lua"))()
				end)
			end
		end
	})
end)

runFunction(function()
	local InfiniteJump = {Enabled = false}
	local InfiniteJumpMode = {Value = "Normal"}
	local InfiniteJumpBoost = {Value = 1}
	local jumpTick = tick()
	InfiniteJump = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name= "InfiniteJump",
		HoverText = "Jump freely without limitations (unless anticheat).",
		Function = function(callback)
			if callback then 
				task.spawn(function()
					table.insert(InfiniteJump.Connections, inputService.JumpRequest:Connect(function()
						if not isAlive(lplr) then 
							return 
						end
						if InfiniteJumpMode.Value == "Normal" then
							lplr.Character.HumanoidRootPart.Velocity = Vector3.new(lplr.Character.HumanoidRootPart.Velocity.X, lplr.Character.Humanoid.JumpPower, lplr.Character.HumanoidRootPart.Velocity.Z)
						else
							lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
						end
					end))
				end)
			end
		end
	})
	InfiniteJumpMode = InfiniteJump.CreateDropdown({
		Name = "Mode",
		List = {"Normal", "Hold"},
		Function = function(callback) 
			pcall(function() InfiniteJumpBoost.Object.Visible = callback == "Normal" end) 
		end
	})
	InfiniteJumpBoost = InfiniteJump.CreateSlider({
		Name = "Extra Height",
		Min = 0,
		Max = 30,
		Default = 1,
		Function = function() end
	})
	InfiniteJumpBoost.Object.Visible = false
end)

runFunction(function()
	local ServerHop = {Enabled = false}
	local ServerHopSort = {Value = "Popular"}
	local newserver
	ServerHop = GuiLibrary.ObjectsThatCanBeSaved.MatchmakingWindow.Api.CreateOptionsButton({
		Name = "ServerHop",
		Function = function(callback)
			if callback then 
				task.spawn(function()
					ServerHop.ToggleButton(false)
					if RenderStore.serverhopping then 
						return 
					end
					RenderStore.serverhopping = true
					InfoNotification("ServerHop", "Searching for a new server..", 10)
					local popularcheck = ServerHopSort.Value == "Popular"
					local performancecheck = ServerHopSort.Value == "Performance"
					repeat newserver = getnewserver(nil, popularcheck, performancecheck) task.wait() until newserver
					InfoNotification("ServerHop", "Server Found. Joining..", 10)
					teleportService:TeleportToPlaceInstance(game.PlaceId, newserver, lplr)
				end)
			end
		end
	})
	ServerHopSort = ServerHop.CreateDropdown({
		Name = "Sort",
		List = {"Popular", "Performance", "Random"},
		Function = function() end
	})
end)

runFunction(function()
	local AutoRejoin = {Enabled = false}
	local AutoRejoinSwitch = {Enabled = false}
	local server
	AutoRejoin = GuiLibrary.ObjectsThatCanBeSaved.MatchmakingWindow.Api.CreateOptionsButton({
		Name = "AutoRejoin",
		HoverText = "Automatically rejoins the game on disconnect/kick.",
		Function = function(callback)
			if callback then 
				task.spawn(function()
					table.insert(AutoRejoin.Connections, RenderStore.Bindable.PlayerKick.Event:Connect(function()
						if RenderStore.serverhopping then 
							return 
						end
						RenderStore.serverhopping = true
						if not AutoRejoinSwitch.Enabled then 
							InfoNotification("AutoRejoin", "Rejoining the server..", 10)
							teleportService:Teleport(game.PlaceId)
							return
						end
						InfoNotification("AutoRejoin", "Player disconnect detected. Searching for a new server.", 10)
						repeat server = getnewserver() task.wait() until server
						InfoNotification("AutoRejoin", "Server Found. Joining..", 10)
						teleportService:TeleportToPlaceInstance(game.PlaceId, server, lplr)
					end))
				end)
			end
		end
	})
	AutoRejoinSwitch = AutoRejoin.CreateToggle({
		Name = "ServerHop",
		HoverText = "Switches servers (good when vote kicks).",
		Function = function() end
	})
end)

runFunction(function()
	local PlayerAttach = {Enabled = false}
	local PlayerAttachNPC = {Enabled = false}
	local PlayerAttachTween = {Enabled = false}
	local PlayerAttachRaycast = {Enabled = false}
	local PlayerAttachRange = {Value = 30}
	PlayerAttach = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "PlayerAttach",
		HoverText = "Rapes others :omegalol:",
		Function = function(callback)
			if callback then 
				task.spawn(function()
					repeat 
						local target = GetTarget(PlayerAttachTween.Enabled and PlayerAttachRange.Value + 5 or PlayerAttachRange.Value, nil, PlayerAttachRaycast.Enabled, PlayerAttachNPC.Enabled)
						if not target.RootPart or not isAlive() then 
							PlayerAttach.ToggleButton(false)
							break 
						end
						lplr.Character.Humanoid.Sit = false
						if PlayerAttachTween.Enabled then 
							tweenService:Create(lplr.Character.HumanoidRootPart, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {CFrame = target.RootPart.CFrame}):Play()
						else
						   lplr.Character.HumanoidRootPart.CFrame = target.RootPart.CFrame
						end
						task.wait()
					until not PlayerAttach.Enabled
				end)
			end
		end
	})
	PlayerAttachRange = PlayerAttach.CreateSlider({
		Name = "Max Range",
		Min = 10,
		Max = 50, 
		Function = function() end,
		Default = 20
	})
	PlayerAttachNPC = PlayerAttach.CreateToggle({
		Name = "NPC",
		HoverText = "Attaches to npcs designed by the game.",
		Function = function() end
	})
	PlayerAttachRaycast = PlayerAttach.CreateToggle({
		Name = "Void Check",
		HoverText = "Doesn't target those in the void.",
		Function = function() end
	})
	PlayerAttachTween = PlayerAttach.CreateToggle({
		Name = "Tween",
		HoverText = "Smooth animation instead of teleporting.",
		Function = function() end
	})
end)

runFunction(function()
	local FPSBoost = {Enabled = false}
	local textures = {}
	local meshtextures = {}
	local specialmeshtextures = {}
	local partmaterials = {}
	local function modifypart(part)
		if characterDescendant(part) then 
			return 
		end
		if part:IsA("Texture") then 
			textures[part] = part.Texture
			table.insert(FPSBoost.Connections, part:GetPropertyChangedSignal("Texture"):Connect(function()
				part.Texture = ""
			end))
			part.Texture = ""
		end
		if part:IsA("MeshPart") then 
			meshtextures[part] = part.TextureID
			table.insert(FPSBoost.Connections, part:GetPropertyChangedSignal("TextureID"):Connect(function()
				part.TextureID = ""
			end))
			part.TextureID = ""
		end
		if part:IsA("SpecialMesh") then
			specialmeshtextures[part] = part.TextureId
			table.insert(FPSBoost.Connections, part:GetPropertyChangedSignal("TextureId"):Connect(function()
				part.TextureId = ""
			end))
			part.TextureId = ""
		end
		if part:IsA("Part") or part:IsA("UnionOperation") then 
			partmaterials[part] = part.Material
			table.insert(FPSBoost.Connections, part:GetPropertyChangedSignal("Material"):Connect(function()
				part.Material = Enum.Material.SmoothPlastic
			end))
			part.Material = Enum.Material.SmoothPlastic
		end
	end
	FPSBoost = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "FPSBoost",
		HoverText = "Removes textures of objects to slightly improve\nyour framerate.",
		Function = function(callback)
			if callback then 
				task.spawn(function()
					for i,v in workspace:GetDescendants() do 
						modifypart(v)
					end
					table.insert(FPSBoost.Connections, workspace.DescendantAdded:Connect(modifypart))
				end)
			else
				for texturepart, old in textures do 
					texturepart.Material = old
				end
				for meshpart, old in meshtextures do 
					meshpart.TextureID = old
				end
				for specialmesh, old in specialmeshtextures do 
					specialmesh.TextureId = old
				end
				for part, old in partmaterials do 
					part.Material = old
				end
			end
		end
	})
end)

runFunction(function()
	local cameraunlocker = {Enabled = false}
	local camdistance = {Value = 0}
	cameraunlocker = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "CameraUnlocker",
		HoverText = "Mods your camera's zoom distance.",
		Function = function(callback)
			if callback then -- rare moment of me not using task.spawn :troll:
			   oldzoom = lplr.CameraMaxZoomDistance
			   lplr.CameraMaxZoomDistance = camdistance.Value
			else
				lplr.CameraMaxZoomDistance = oldzoom 
			end
		end
	})
	camdistance = cameraunlock.CreateSlider({
		Name = "Distance",
		Min = 14,
		Max = 30,
		Default = 16,
		Function = function(value)
			if cameraunlock.Enabled then 
			   lplr.CameraMaxZoomDistance = camdistance.Value
			end
		end
	})
end)
