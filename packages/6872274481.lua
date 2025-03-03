--[[

    Render Intents | Bedwars
    The #1 vape mod you'll ever see.

    Version: 1.6
    discord.gg/render

]]

local GuiLibrary = shared.GuiLibrary
local httpService = game:GetService('HttpService')
local teleportService = game:GetService('TeleportService')
local playersService = game:GetService('Players')
local textService = game:GetService('TextService')
local lightingService = game:GetService('Lighting') 
local collectionService = game:GetService('CollectionService')
local textChatService = game:GetService('TextChatService')
local inputService = game:GetService('UserInputService')
local runService = game:GetService('RunService')
local replicatedStorageService = game:GetService('ReplicatedStorage')
local HWID = game:GetService('RbxAnalyticsService'):GetClientId()		
local executor = (identifyexecutor and identifyexecutor() or getexecutorname and getexecutorname() or 'Unknown')
local tweenService = game:GetService('TweenService')
local gameCamera = workspace.CurrentCamera
local lplr = playersService.LocalPlayer
local vapeConnections = {}
local vapeCachedAssets = {}
local vapeEvents = setmetatable({}, {
	__index = function(self, index)
		self[index] = Instance.new('BindableEvent')
		return self[index]
	end
})
local vapeTargetInfo = shared.VapeTargetInfo
local vapeInjected = true
local vec3 = Vector3.new
local vec2 = Vector2.new
local bedwars = {}
local bedwarsStore = {
	attackReach = 0,
	attackReachUpdate = tick(),
	blocks = {},
	blockPlacer = {},
	blockPlace = tick(),
	blockRaycast = RaycastParams.new(),
	equippedKit = 'none',
	forgeMasteryPoints = 0,
	forgeUpgrades = {},
	grapple = tick(),
	inventories = {},
	localInventory = {
		inventory = {
			items = {},
			armor = {}
		},
		hotbar = {}
	},
	localHand = {},
	matchState = 0,
	matchStateChanged = tick(),
	pots = {},
	queueType = 'bedwars_test',
	scythe = tick(),
	switchdelay = tick(),
	statistics = {
		beds = 0,
		kills = 0,
		lagbacks = 0,
		lagbackEvent = Instance.new('BindableEvent'),
		reported = 0,
		universalLagbacks = 0
	},
	whitelist = {
		chatStrings1 = {helloimusinginhaler = 'vape'},
		chatStrings2 = {vape = 'helloimusinginhaler'},
		clientUsers = {},
		oldChatFunctions = {}
	},
	usedAbilities = {},
	cloneEvent = Instance.new('BindableEvent'),
	zephyrOrb = 0
}
bedwarsStore.blockRaycast.FilterType = Enum.RaycastFilterType.Include

local AutoLeave = {}
local isAlive = function() return false end 
local playSound = function() end
local dumptable = function() return {} end
local sendmessage = function() end
local getEnemyBed = function() end 
local canRespawn = function() end
local characterDescendant = function() return nil end
local playerRaycasted = function() return true end
local tweenInProgress = function() end
local GetTarget = function() return {} end
local gethighestblock = function() return nil end
local GetAllTargets = function() return {} end
local sendprivatemessage = function() end
local getnewserver = function() return nil end
local switchserver = function() end
local getTablePosition = function() return 1 end
local warningNotification = function() end 
local GetEnumItems = function() return {} end
local getrandomvalue = function() return '' end
local getTweenSpeed = function() return 0.49 end
local isEnabled = function() return false end
local InfoNotification = function() end

table.insert(vapeConnections, workspace:GetPropertyChangedSignal('CurrentCamera'):Connect(function()
	gameCamera = workspace.CurrentCamera or workspace:FindFirstChildWhichIsA('Camera')
end))

local isfile = isfile or function(file)
	local suc, res = pcall(function() return readfile(file) end)
	return suc and res ~= nil
end
local networkownerswitch = tick()
local isnetworkowner = function(part)
	local suc, res = pcall(function() return gethiddenproperty(part, 'NetworkOwnershipRule') end)
	if suc and res == Enum.NetworkOwnership.Manual then 
		sethiddenproperty(part, 'NetworkOwnershipRule', Enum.NetworkOwnership.Automatic)
		networkownerswitch = tick() + 8
	end
	return networkownerswitch <= tick()
end

local getcustomasset = getsynasset or getcustomasset or function(location) return 'rbxasset://'..location end
local queueonteleport = syn and syn.queue_on_teleport or queue_on_teleport or function() end
local synapsev3 = syn and syn.toast_notification and 'V3' or ''
local worldtoscreenpoint = function(pos)
	if synapsev3 == 'V3' then 
		local scr = worldtoscreen({pos})
		return scr[1] - Vector3.new(0, 36, 0), scr[1].Z > 0
	end
	return gameCamera.WorldToScreenPoint(gameCamera, pos)
end
local worldtoviewportpoint = function(pos)
	if synapsev3 == 'V3' then 
		local scr = worldtoscreen({pos})
		return scr[1], scr[1].Z > 0
	end
	return gameCamera.WorldToViewportPoint(gameCamera, pos)
end

local function vapeGithubRequest(scripturl)
	if not isfile('vape/'..scripturl) then
		local suc, res = pcall(function() return game:HttpGet('https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/'..readfile('vape/commithash.txt')..'/'..scripturl, true) end)
		assert(suc, res)
		assert(res ~= '404: Not Found', res)
		if scripturl:find('.lua') then res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after commits.\n'..res end
		writefile('vape/'..scripturl, res)
	end
	return readfile('vape/'..scripturl)
end

local function downloadVapeAsset(path)
	if not isfile(path) then
		task.spawn(function()
			local textlabel = Instance.new('TextLabel')
			textlabel.Size = UDim2.new(1, 0, 0, 36)
			textlabel.Text = 'Downloading '..path
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
		local suc, req = pcall(function() return vapeGithubRequest(path:gsub('vape/assets', 'assets')) end)
        if suc and req then
		    writefile(path, req)
        else
            return ''
        end
	end
	if not vapeCachedAssets[path] then vapeCachedAssets[path] = getcustomasset(path) end
	return vapeCachedAssets[path] 
end

warningNotification = function(title, text, delay)
	local suc, res = pcall(function()
		local color = GuiLibrary.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api
		local frame = GuiLibrary.CreateNotification(title, text, delay, 'assets/WarningNotification.png')
		frame.Frame.Frame.ImageColor3 = Color3.fromHSV(color.Hue, color.Sat, color.Value)
		frame.Frame.Frame.ImageColor3 = Color3.fromHSV(color.Hue, color.Sat, color.Value)
		return frame
	end)
	return (suc and res)
end

InfoNotification = function(title, text, delay)
	local success, frame = pcall(function()
		return GuiLibrary.CreateNotification(title, text, delay)
	end)
	return success and frame
end

errorNotification = function(title, text, delay)
	local success, frame = pcall(function()
		local notification = GuiLibrary.CreateNotification(title, text, delay or 6.5, 'assets/WarningNotification.png')
		notification.IconLabel.ImageColor3 = Color3.new(220, 0, 0)
		notification.Frame.Frame.ImageColor3 = Color3.new(220, 0, 0)
	end)
	return success and frame
end

getrandomvalue = function(tab)
	return #tab > 0 and tab[math.random(1, #tab)] or ''
end

GetEnumItems = function(enum)
	local fonts = {}
	for i,v in next, Enum[enum]:GetEnumItems() do 
		table.insert(fonts, v.Name) 
	end
	return fonts
end

local function runFunction(func) func() end
local function runLunar(func) func() end

local function isFriend(plr, recolor)
	if GuiLibrary.ObjectsThatCanBeSaved['Use FriendsToggle'].Api.Enabled then
		local friend = table.find(GuiLibrary.ObjectsThatCanBeSaved.FriendsListTextCircleList.Api.ObjectList, plr.Name)
		friend = friend and GuiLibrary.ObjectsThatCanBeSaved.FriendsListTextCircleList.Api.ObjectListEnabled[friend]
		if recolor then
			friend = friend and GuiLibrary.ObjectsThatCanBeSaved['Recolor visualsToggle'].Api.Enabled
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
	return plr.Humanoid.Health > 0 and not plr.Character.FindFirstChildWhichIsA(plr.Character, 'ForceField')
end

local function getPlayerColor(plr)
	if isFriend(plr, true) then
		return Color3.fromHSV(GuiLibrary.ObjectsThatCanBeSaved['Friends ColorSliderColor'].Api.Hue, GuiLibrary.ObjectsThatCanBeSaved['Friends ColorSliderColor'].Api.Sat, GuiLibrary.ObjectsThatCanBeSaved['Friends ColorSliderColor'].Api.Value)
	end
	return tostring(plr.TeamColor) ~= 'White' and plr.TeamColor.Color
end

local function LaunchAngle(v, g, d, h, higherArc)
	local v2 = v * v
	local v4 = v2 * v2
	local root = -math.sqrt(v4 - g*(g*d*d + 2*h*v2))
	return math.atan((v2 + root) / (g * d))
end

local function LaunchDirection(start, target, v, g)
	local horizontal = Vector3.new(target.X - start.X, 0, target.Z - start.Z)
	local h = target.Y - start.Y
	local d = horizontal.Magnitude
	local a = LaunchAngle(v, g, d, h)

	if a ~= a then 
		return g == 0 and (target - start).Unit * v
	end

	local vec = horizontal.Unit * v
	local rotAxis = Vector3.new(-horizontal.Z, 0, horizontal.X)
	return CFrame.fromAxisAngle(rotAxis, a) * vec
end

local physicsUpdate = 1 / 60

local function predictGravity(playerPosition, vel, bulletTime, targetPart, Gravity)
	local estimatedVelocity = vel.Y
	local rootSize = (targetPart.Humanoid.HipHeight + (targetPart.RootPart.Size.Y / 2))
	local velocityCheck = (tick() - targetPart.JumpTick) < 0.2
	vel = vel * physicsUpdate

	for i = 1, math.ceil(bulletTime / physicsUpdate) do 
		if velocityCheck then 
			estimatedVelocity = estimatedVelocity - (Gravity * physicsUpdate)
		else
			estimatedVelocity = 0
			playerPosition = playerPosition + Vector3.new(0, -0.03, 0) -- bw hitreg is so bad that I have to add this LOL
			rootSize = rootSize - 0.03
		end

		local floorDetection = workspace:Raycast(playerPosition, Vector3.new(vel.X, (estimatedVelocity * physicsUpdate) - rootSize, vel.Z), bedwarsStore.blockRaycast)
		if floorDetection then 
			playerPosition = Vector3.new(playerPosition.X, floorDetection.Position.Y + rootSize, playerPosition.Z)
			local bouncepad = floorDetection.Instance:FindFirstAncestor('gumdrop_bounce_pad')
			if bouncepad and bouncepad:GetAttribute('PlacedByUserId') == targetPart.Player.UserId then 
				estimatedVelocity = 130 - (Gravity * physicsUpdate)
				velocityCheck = true
			else
				estimatedVelocity = targetPart.Humanoid.JumpPower - (Gravity * physicsUpdate)
				velocityCheck = targetPart.Jumping
			end
		end

		playerPosition = playerPosition + Vector3.new(vel.X, velocityCheck and estimatedVelocity * physicsUpdate or 0, vel.Z)
	end

	return playerPosition, Vector3.new(0, 0, 0)
end

local entityLibrary = shared.vapeentity
local entityLibrary = entityLibrary
local WhitelistFunctions = shared.vapewhitelist
local RunLoops = {RenderStepTable = {}, StepTable = {}, HeartTable = {}}
do
	function RunLoops:BindToRenderStep(name, func)
		if RunLoops.RenderStepTable[name] == nil then
			RunLoops.RenderStepTable[name] = runService.RenderStepped:Connect(function(...) pcall(func, unpack({...})) end)
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
			RunLoops.StepTable[name] = runService.Stepped:Connect(function(...) pcall(func, unpack({...})) end)
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
			RunLoops.HeartTable[name] = runService.Heartbeat:Connect(function(...) pcall(func, unpack({...})) end)
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
	for i, v in next, (vapeConnections) do
		if v.Disconnect then pcall(function() v:Disconnect() end) continue end
		if v.disconnect then pcall(function() v:disconnect() end) continue end
	end
	getgenv().bedwars = nil 
	getgenv().bedwarsStore = nil
	getgenv().vapeEvents = nil
end)

local function getItem(itemName, inv)
	for slot, item in next, (inv or bedwarsStore.localInventory.inventory.items) do
		if item.itemType == itemName then
			return item, slot
		end
	end
	return nil
end

local function getItemNear(itemName, inv)
	for slot, item in next, (inv or bedwarsStore.localInventory.inventory.items) do
		if item.itemType == itemName or item.itemType:find(itemName) then
			return item, slot
		end
	end
	return nil
end

local function getHotbarSlot(itemName)
	for slotNumber, slotTable in next, (bedwarsStore.localInventory.hotbar) do
		if slotTable.item and slotTable.item.itemType == itemName then
			return slotNumber - 1
		end
	end
	return nil
end

local function getShieldAttribute(char)
	local returnedShield = 0
	for attributeName, attributeValue in next, (char:GetAttributes()) do 
		if attributeName:find('Shield') and type(attributeValue) == 'number' then 
			returnedShield = returnedShield + attributeValue
		end
	end
	return returnedShield
end

local function getPickaxe()
	return getItemNear('pick')
end

local function getAxe()
	local bestAxe, bestAxeSlot = nil, nil
	for slot, item in next, (bedwarsStore.localInventory.inventory.items) do
		if item.itemType:find('axe') and item.itemType:find('pickaxe') == nil and item.itemType:find('void') == nil then
			bextAxe, bextAxeSlot = item, slot
		end
	end
	return bestAxe, bestAxeSlot
end

local function getSword()
	local bestSword, bestSwordSlot, bestSwordDamage = nil, nil, 0
	for slot, item in next, (bedwarsStore.localInventory.inventory.items) do
		local swordMeta = bedwars.ItemTable[item.itemType].sword
		if swordMeta then
			local swordDamage = swordMeta.damage or 0
			if swordDamage > bestSwordDamage then
				bestSword, bestSwordSlot, bestSwordDamage = item, slot, swordDamage
			end
		end
	end
	return bestSword, bestSwordSlot
end

local function getBow()
	local bestBow, bestBowSlot, bestBowStrength = nil, nil, 0
	for slot, item in next, (bedwarsStore.localInventory.inventory.items) do
		if item.itemType:find('bow') then 
			local tab = bedwars.ItemTable[item.itemType].projectileSource
			local ammo = tab.projectileType('arrow')	
			local dmg = bedwars.ProjectileMeta[ammo].combat.damage
			if dmg > bestBowStrength then
				bestBow, bestBowSlot, bestBowStrength = item, slot, dmg
			end
		end
	end
	return bestBow, bestBowSlot
end

local function getWool()
	local wool = getItemNear('wool')
	return wool and wool.itemType, wool and wool.amount
end

local function getBlock()
	for slot, item in next, (bedwarsStore.localInventory.inventory.items) do
		if bedwars.ItemTable[item.itemType].block then
			return item.itemType, item.amount
		end
	end
end

local function attackValue(vec)
	return {value = vec}
end

local function getSpeed()
	local speed = 0
	if lplr.Character then 
		local SpeedDamageBoost = lplr.Character:GetAttribute('SpeedBoost')
		if SpeedDamageBoost and SpeedDamageBoost > 1 then 
			speed += (8 * (SpeedDamageBoost - 1))
		end
		if bedwarsStore.grapple > tick() then
			speed += 90
		end
		if bedwarsStore.scythe > tick() then 
			speed += 65
		end
		if lplr.Character:GetAttribute('GrimReaperChannel') then 
			speed += 20
		end
		if lplr.Character:FindFirstChild('elk') then  
			speed += 19
		end
		local armor = bedwarsStore.localInventory.inventory.armor[3]
		if type(armor) ~= 'table' then armor = {itemType = ''} end
		if armor.itemType == 'speed_boots' then 
			speed += 12
		end
		if type(bedwarsStore.zephyrOrb) == 'number' and bedwarsStore.zephyrOrb > 0 then 
			speed += (RenderStore.acbypass and 28 or 22)
		end
	end
	return speed
end

local Reach = {}
local blacklistedblocks = {
	bed = true,
	ceramic = true
}
local cachedNormalSides = {}
for i,v in next, (Enum.NormalId:GetEnumItems()) do if v.Name ~= 'Bottom' then table.insert(cachedNormalSides, v) end end
local updateitem = Instance.new('BindableEvent')
local inputobj = nil
local tempconnection
tempconnection = inputService.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		inputobj = input
		tempconnection:Disconnect()
	end
end)
table.insert(vapeConnections, updateitem.Event:Connect(function(inputObj)
	if inputService:IsMouseButtonPressed(0) then
		game:GetService('ContextActionService'):CallFunction('block-break', Enum.UserInputState.Begin, inputobj)
	end
end))

local function getPlacedBlock(pos)
	local roundedPosition = bedwars.BlockController:getBlockPosition(pos)
	return bedwars.BlockController:getStore():getBlockAt(roundedPosition), roundedPosition
end

local oldpos = Vector3.zero

local function getScaffold(vec, diagonaltoggle)
	local realvec = Vector3.new(math.floor((vec.X / 3) + 0.5) * 3, math.floor((vec.Y / 3) + 0.5) * 3, math.floor((vec.Z / 3) + 0.5) * 3) 
	local speedCFrame = (oldpos - realvec)
	local returedpos = realvec
	if entityLibrary.isAlive then
		local angle = math.deg(math.atan2(-entityLibrary.character.Humanoid.MoveDirection.X, -entityLibrary.character.Humanoid.MoveDirection.Z))
		local goingdiagonal = (angle >= 130 and angle <= 150) or (angle <= -35 and angle >= -50) or (angle >= 35 and angle <= 50) or (angle <= -130 and angle >= -150)
		if goingdiagonal and ((speedCFrame.X == 0 and speedCFrame.Z ~= 0) or (speedCFrame.X ~= 0 and speedCFrame.Z == 0)) and diagonaltoggle then
			return oldpos
		end
	end
    return realvec
end

local function getBestTool(block)
	local tool = nil
	local blockmeta = bedwars.ItemTable[block]
	local blockType = blockmeta.block and blockmeta.block.breakType
	if blockType then
		local best = 0
		for i,v in next, (bedwarsStore.localInventory.inventory.items) do
			local meta = bedwars.ItemTable[v.itemType]
			if meta.breakBlock and meta.breakBlock[blockType] and meta.breakBlock[blockType] >= best then
				best = meta.breakBlock[blockType]
				tool = v
			end
		end
	end
	return tool
end

local function getOpenApps()
	local count = 0
	for i,v in next, (bedwars.AppController:getOpenApps()) do if (not tostring(v):find('Billboard')) and (not tostring(v):find('GameNametag')) then count = count + 1 end end
	return count
end

local function switchItem(tool)
	if lplr.Character.HandInvItem.Value ~= tool then
		bedwars.ClientHandler:Get(bedwars.EquipItemRemote):CallServerAsync({
			hand = tool
		})
		local started = tick()
		repeat task.wait() until (tick() - started) > 0.3 or lplr.Character.HandInvItem.Value == tool
	end
end

local function switchToAndUseTool(block, legit)
	local tool = getBestTool(block.Name)
	if tool and (entityLibrary.isAlive and lplr.Character:FindFirstChild('HandInvItem') and lplr.Character.HandInvItem.Value ~= tool.tool) then
		if legit then
			if getHotbarSlot(tool.itemType) then
				bedwars.ClientStoreHandler:dispatch({
					type = 'InventorySelectHotbarSlot', 
					slot = getHotbarSlot(tool.itemType)
				})
				vapeEvents.InventoryChanged.Event:Wait()
				updateitem:Fire(inputobj)
				return true
			else
				return false
			end
		end
		switchItem(tool.tool)
	end
end

local function isBlockCovered(pos)
	local coveredsides = 0
	for i, v in next, (cachedNormalSides) do
		local blockpos = (pos + (Vector3.FromNormalId(v) * 3))
		local block = getPlacedBlock(blockpos)
		if block then
			coveredsides = coveredsides + 1
		end
	end
	return coveredsides == #cachedNormalSides
end

local function GetPlacedBlocksNear(pos, normal)
	local blocks = {}
	local lastfound = nil
	for i = 1, 20 do
		local blockpos = (pos + (Vector3.FromNormalId(normal) * (i * 3)))
		local extrablock = getPlacedBlock(blockpos)
		local covered = isBlockCovered(blockpos)
		if extrablock then
			if bedwars.BlockController:isBlockBreakable({blockPosition = blockpos}, lplr) and (not blacklistedblocks[extrablock.Name]) then
				table.insert(blocks, extrablock.Name)
			end
			lastfound = extrablock
			if not covered then
				break
			end
		else
			break
		end
	end
	return blocks
end

local function getLastCovered(pos, normal)
	local lastfound, lastpos = nil, nil
	for i = 1, 20 do
		local blockpos = (pos + (Vector3.FromNormalId(normal) * (i * 3)))
		local extrablock, extrablockpos = getPlacedBlock(blockpos)
		local covered = isBlockCovered(blockpos)
		if extrablock then
			lastfound, lastpos = extrablock, extrablockpos
			if not covered then
				break
			end
		else
			break
		end
	end
	return lastfound, lastpos
end

local function getBestBreakSide(pos)
	local softest, softestside = 9e9, Enum.NormalId.Top
	for i,v in next, (cachedNormalSides) do
		local sidehardness = 0
		for i2,v2 in next, (GetPlacedBlocksNear(pos, v)) do	
			local blockmeta = bedwars.ItemTable[v2].block
			sidehardness = sidehardness + (blockmeta and blockmeta.health or 10)
            if blockmeta then
                local tool = getBestTool(v2)
                if tool then
                    sidehardness = sidehardness - bedwars.ItemTable[tool.itemType].breakBlock[blockmeta.breakType]
                end
            end
		end
		if sidehardness <= softest then
			softest = sidehardness
			softestside = v
		end	
	end
	return softestside, softest
end

local function EntityNearPosition(distance, ignore, overridepos)
	local closestEntity, closestMagnitude = nil, distance
	if entityLibrary.isAlive then
		for i, v in next, (entityLibrary.entityList) do
			if not v.Targetable then continue end
            if isVulnerable(v) then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.RootPart.Position).magnitude
				if overridepos and mag > distance then
					mag = (overridepos - v.RootPart.Position).magnitude
				end
                if mag <= closestMagnitude then
					closestEntity, closestMagnitude = v, mag
                end
            end
        end
		if not ignore then
			for i, v in next, (collectionService:GetTagged('Monster')) do
				if v.PrimaryPart and v:GetAttribute('Team') ~= lplr:GetAttribute('Team') then
					local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
					if overridepos and mag > distance then 
						mag = (overridepos - v2.PrimaryPart.Position).magnitude
					end
					if mag <= closestMagnitude then
						closestEntity, closestMagnitude = {Player = {Name = v.Name, UserId = (v.Name == 'Duck' and 2020831224 or 1443379645)}, Character = v, RootPart = v.PrimaryPart, JumpTick = tick() + 5, Jumping = false, Humanoid = {HipHeight = 2}}, mag
					end
				end
			end
			for i, v in next, (collectionService:GetTagged('DiamondGuardian')) do
				if v.PrimaryPart then
					local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
					if overridepos and mag > distance then 
						mag = (overridepos - v2.PrimaryPart.Position).magnitude
					end
					if mag <= closestMagnitude then
						closestEntity, closestMagnitude = {Player = {Name = 'DiamondGuardian', UserId = 1443379645}, Character = v, RootPart = v.PrimaryPart, JumpTick = tick() + 5, Jumping = false, Humanoid = {HipHeight = 2}}, mag
					end
				end
			end
			for i, v in next, (collectionService:GetTagged('GolemBoss')) do
				if v.PrimaryPart then
					local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
					if overridepos and mag > distance then 
						mag = (overridepos - v2.PrimaryPart.Position).magnitude
					end
					if mag <= closestMagnitude then
						closestEntity, closestMagnitude = {Player = {Name = 'GolemBoss', UserId = 1443379645}, Character = v, RootPart = v.PrimaryPart, JumpTick = tick() + 5, Jumping = false, Humanoid = {HipHeight = 2}}, mag
					end
				end
			end
			for i, v in next, (collectionService:GetTagged('Drone')) do
				if v.PrimaryPart and tonumber(v:GetAttribute('PlayerUserId')) ~= lplr.UserId then
					local droneplr = playersService:GetPlayerByUserId(v:GetAttribute('PlayerUserId'))
					if droneplr and droneplr.Team == lplr.Team then continue end
					local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
					if overridepos and mag > distance then 
						mag = (overridepos - v.PrimaryPart.Position).magnitude
					end
					if mag <= closestMagnitude then -- magcheck
						closestEntity, closestMagnitude = {Player = {Name = 'Drone', UserId = 1443379645}, Character = v, RootPart = v.PrimaryPart, JumpTick = tick() + 5, Jumping = false, Humanoid = {HipHeight = 2}}, mag
					end
				end
			end
		end
	end
	return closestEntity
end

local function EntityNearMouse(distance)
	local closestEntity, closestMagnitude = nil, distance
    if entityLibrary.isAlive then
		local mousepos = inputService.GetMouseLocation(inputService)
		for i, v in next, (entityLibrary.entityList) do
			if not v.Targetable then continue end
            if isVulnerable(v) then
				local vec, vis = worldtoscreenpoint(v.RootPart.Position)
				local mag = (mousepos - Vector2.new(vec.X, vec.Y)).magnitude
                if vis and mag <= closestMagnitude then
					closestEntity, closestMagnitude = v, v.Target and -1 or mag
                end
            end
        end
    end
	return closestEntity
end

local function AllNearPosition(distance, amount, sortfunction, prediction)
	local returnedplayer = {}
	local currentamount = 0
    if entityLibrary.isAlive then
		local sortedentities = {}
		for i, v in next, (entityLibrary.entityList) do
			if not v.Targetable then continue end
            if isVulnerable(v) then
				local playerPosition = v.RootPart.Position
				local mag = (entityLibrary.character.HumanoidRootPart.Position - playerPosition).magnitude
				if prediction and mag > distance then
					mag = (RenderStore.LocalPosition - playerPosition).magnitude
				end
                if mag <= distance then
					table.insert(sortedentities, v)
                end
            end
        end
		for i, v in next, (collectionService:GetTagged('Monster')) do
			if v.PrimaryPart then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
				if prediction and mag > distance then
					mag = (RenderStore.LocalPosition - v.PrimaryPart.Position).magnitude
				end
                if mag <= distance then
					if v:GetAttribute('Team') == lplr:GetAttribute('Team') then continue end
                    table.insert(sortedentities, {Player = {Name = v.Name, UserId = (v.Name == 'Duck' and 2020831224 or 1443379645), GetAttribute = function() return 'none' end}, Character = v, RootPart = v.PrimaryPart, Humanoid = v.Humanoid})
                end
			end
		end
		for i, v in next, (collectionService:GetTagged('DiamondGuardian')) do
			if v.PrimaryPart then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
				if prediction and mag > distance then
					mag = (RenderStore.LocalPosition - v.PrimaryPart.Position).magnitude
				end
                if mag <= distance then
                    table.insert(sortedentities, {Player = {Name = 'DiamondGuardian', UserId = 1443379645, GetAttribute = function() return 'none' end}, Character = v, RootPart = v.PrimaryPart, Humanoid = v.Humanoid})
                end
			end
		end
		for i, v in next, (collectionService:GetTagged('GolemBoss')) do
			if v.PrimaryPart then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
				if prediction and mag > distance then
					mag = (RenderStore.LocalPosition - v.PrimaryPart.Position).magnitude
				end
                if mag <= distance then
                    table.insert(sortedentities, {Player = {Name = 'GolemBoss', UserId = 1443379645, GetAttribute = function() return 'none' end}, Character = v, RootPart = v.PrimaryPart, Humanoid = v.Humanoid})
                end
			end
		end
		for i, v in next, (collectionService:GetTagged('Drone')) do
			if v.PrimaryPart then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
				if prediction and mag > distance then
					mag = (RenderStore.LocalPosition - v.PrimaryPart.Position).magnitude
				end
                if mag <= distance then
					if tonumber(v:GetAttribute('PlayerUserId')) == lplr.UserId then continue end
					local droneplr = playersService:GetPlayerByUserId(v:GetAttribute('PlayerUserId'))
					if droneplr and droneplr.Team == lplr.Team then continue end
                    table.insert(sortedentities, {Player = {Name = 'Drone', UserId = 1443379645}, GetAttribute = function() return 'none' end, Character = v, RootPart = v.PrimaryPart, Humanoid = v.Humanoid})
                end
			end
		end
		for i, v in next, (bedwarsStore.pots) do
			if v.PrimaryPart then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
				if prediction and mag > distance then
					mag = (RenderStore.LocalPosition - v.PrimaryPart.Position).magnitude
				end
                if mag <= distance then
                    table.insert(sortedentities, {Player = {Name = 'Pot', UserId = 1443379645, GetAttribute = function() return 'none' end}, Character = v, RootPart = v.PrimaryPart, Humanoid = {Health = 100, MaxHealth = 100}})
                end
			end
		end
		for i, v in collectionService:GetTagged('GooseBoss') do 
			if v.PrimaryPart then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
				if prediction and mag > distance then
					mag = (RenderStore.LocalPosition - v.PrimaryPart.Position).magnitude
				end
                if mag <= distance then
                    table.insert(sortedentities, {Player = {Name = 'GooseBoss', UserId = 1443379645}, GetAttribute = function() return 'none' end, Character = v, RootPart = v.PrimaryPart, Humanoid = v.Humanoid})
                end
			end
		end
		if sortfunction then
			table.sort(sortedentities, sortfunction)
		end
		for i,v in next, (sortedentities) do 
			table.insert(returnedplayer, v)
			currentamount = currentamount + 1
			if currentamount >= amount then break end
		end
	end
	return returnedplayer
end

--pasted from old source since gui code is hard
local function CreateAutoHotbarGUI(children2, argstable)
	local buttonapi = {}
	buttonapi['Hotbars'] = {}
	buttonapi['CurrentlySelected'] = 1
	local currentanim
	local amount = #children2:GetChildren()
	local sortableitems = {
		{itemType = 'swords', itemDisplayType = 'diamond_sword'},
		{itemType = 'pickaxes', itemDisplayType = 'diamond_pickaxe'},
		{itemType = 'axes', itemDisplayType = 'diamond_axe'},
		{itemType = 'shears', itemDisplayType = 'shears'},
		{itemType = 'wool', itemDisplayType = 'wool_white'},
		{itemType = 'iron', itemDisplayType = 'iron'},
		{itemType = 'diamond', itemDisplayType = 'diamond'},
		{itemType = 'emerald', itemDisplayType = 'emerald'},
		{itemType = 'bows', itemDisplayType = 'wood_bow'},
	}
	local items = bedwars.ItemTable
	if items then
		for i2,v2 in next, (items) do
			if (i2:find('axe') == nil or i2:find('void')) and i2:find('bow') == nil and i2:find('shears') == nil and i2:find('wool') == nil and v2.sword == nil and v2.armor == nil and v2['dontGiveItem'] == nil and bedwars.ItemTable[i2] and bedwars.ItemTable[i2].image then
				table.insert(sortableitems, {itemType = i2, itemDisplayType = i2})
			end
		end
	end
	local buttontext = Instance.new('TextButton')
	buttontext.AutoButtonColor = false
	buttontext.BackgroundTransparency = 1
	buttontext.Name = 'ButtonText'
	buttontext.Text = ''
	buttontext.Name = argstable['Name']
	buttontext.LayoutOrder = 1
	buttontext.Size = UDim2.new(1, 0, 0, 40)
	buttontext.Active = false
	buttontext.TextColor3 = Color3.fromRGB(162, 162, 162)
	buttontext.TextSize = 17
	buttontext.Font = Enum.Font.SourceSans
	buttontext.Position = UDim2.new(0, 0, 0, 0)
	buttontext.Parent = children2
	local toggleframe2 = Instance.new('Frame')
	toggleframe2.Size = UDim2.new(0, 200, 0, 31)
	toggleframe2.Position = UDim2.new(0, 10, 0, 4)
	toggleframe2.BackgroundColor3 = Color3.fromRGB(38, 37, 38)
	toggleframe2.Name = 'ToggleFrame2'
	toggleframe2.Parent = buttontext
	local toggleframe1 = Instance.new('Frame')
	toggleframe1.Size = UDim2.new(0, 198, 0, 29)
	toggleframe1.BackgroundColor3 = Color3.fromRGB(26, 25, 26)
	toggleframe1.BorderSizePixel = 0
	toggleframe1.Name = 'ToggleFrame1'
	toggleframe1.Position = UDim2.new(0, 1, 0, 1)
	toggleframe1.Parent = toggleframe2
	local addbutton = Instance.new('ImageLabel')
	addbutton.BackgroundTransparency = 1
	addbutton.Name = 'AddButton'
	addbutton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	addbutton.Position = UDim2.new(0, 93, 0, 9)
	addbutton.Size = UDim2.new(0, 12, 0, 12)
	addbutton.ImageColor3 = Color3.fromRGB(5, 133, 104)
	addbutton.Image = downloadVapeAsset('vape/assets/AddItem.png')
	addbutton.Parent = toggleframe1
	local children3 = Instance.new('Frame')
	children3.Name = argstable['Name']..'Children'
	children3.BackgroundTransparency = 1
	children3.LayoutOrder = amount
	children3.Size = UDim2.new(0, 220, 0, 0)
	children3.Parent = children2
	local uilistlayout = Instance.new('UIListLayout')
	uilistlayout.Parent = children3
	uilistlayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
		children3.Size = UDim2.new(1, 0, 0, uilistlayout.AbsoluteContentSize.Y)
	end)
	local uicorner = Instance.new('UICorner')
	uicorner.CornerRadius = UDim.new(0, 5)
	uicorner.Parent = toggleframe1
	local uicorner2 = Instance.new('UICorner')
	uicorner2.CornerRadius = UDim.new(0, 5)
	uicorner2.Parent = toggleframe2
	buttontext.MouseEnter:Connect(function()
		tweenService:Create(toggleframe2, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(79, 78, 79)}):Play()
	end)
	buttontext.MouseLeave:Connect(function()
		tweenService:Create(toggleframe2, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(38, 37, 38)}):Play()
	end)
	local ItemListBigFrame = Instance.new('Frame')
	ItemListBigFrame.Size = UDim2.new(1, 0, 1, 0)
	ItemListBigFrame.Name = 'ItemList'
	ItemListBigFrame.BackgroundTransparency = 1
	ItemListBigFrame.Visible = false
	ItemListBigFrame.Parent = GuiLibrary.MainGui
	local ItemListFrame = Instance.new('Frame')
	ItemListFrame.Size = UDim2.new(0, 660, 0, 445)
	ItemListFrame.Position = UDim2.new(0.5, -330, 0.5, -223)
	ItemListFrame.BackgroundColor3 = Color3.fromRGB(26, 25, 26)
	ItemListFrame.Parent = ItemListBigFrame
	local ItemListExitButton = Instance.new('ImageButton')
	ItemListExitButton.Name = 'ItemListExitButton'
	ItemListExitButton.ImageColor3 = Color3.fromRGB(121, 121, 121)
	ItemListExitButton.Size = UDim2.new(0, 24, 0, 24)
	ItemListExitButton.AutoButtonColor = false
	ItemListExitButton.Image = downloadVapeAsset('vape/assets/ExitIcon1.png')
	ItemListExitButton.Visible = true
	ItemListExitButton.Position = UDim2.new(1, -31, 0, 8)
	ItemListExitButton.BackgroundColor3 = Color3.fromRGB(26, 25, 26)
	ItemListExitButton.Parent = ItemListFrame
	local ItemListExitButtonround = Instance.new('UICorner')
	ItemListExitButtonround.CornerRadius = UDim.new(0, 16)
	ItemListExitButtonround.Parent = ItemListExitButton
	ItemListExitButton.MouseEnter:Connect(function()
		tweenService:Create(ItemListExitButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(60, 60, 60), ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
	end)
	ItemListExitButton.MouseLeave:Connect(function()
		tweenService:Create(ItemListExitButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(26, 25, 26), ImageColor3 = Color3.fromRGB(121, 121, 121)}):Play()
	end)
	ItemListExitButton.MouseButton1Click:Connect(function()
		ItemListBigFrame.Visible = false
		GuiLibrary.MainGui.ScaledGui.ClickGui.Visible = true
	end)
	local ItemListFrameShadow = Instance.new('ImageLabel')
	ItemListFrameShadow.AnchorPoint = Vector2.new(0.5, 0.5)
	ItemListFrameShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
	ItemListFrameShadow.Image = downloadVapeAsset('vape/assets/WindowBlur.png')
	ItemListFrameShadow.BackgroundTransparency = 1
	ItemListFrameShadow.ZIndex = -1
	ItemListFrameShadow.Size = UDim2.new(1, 6, 1, 6)
	ItemListFrameShadow.ImageColor3 = Color3.new(0, 0, 0)
	ItemListFrameShadow.ScaleType = Enum.ScaleType.Slice
	ItemListFrameShadow.SliceCenter = Rect.new(10, 10, 118, 118)
	ItemListFrameShadow.Parent = ItemListFrame
	local ItemListFrameText = Instance.new('TextLabel')
	ItemListFrameText.Size = UDim2.new(1, 0, 0, 41)
	ItemListFrameText.BackgroundTransparency = 1
	ItemListFrameText.Name = 'WindowTitle'
	ItemListFrameText.Position = UDim2.new(0, 0, 0, 0)
	ItemListFrameText.TextXAlignment = Enum.TextXAlignment.Left
	ItemListFrameText.Font = Enum.Font.SourceSans
	ItemListFrameText.TextSize = 17
	ItemListFrameText.Text = '    New AutoHotbar'
	ItemListFrameText.TextColor3 = Color3.fromRGB(201, 201, 201)
	ItemListFrameText.Parent = ItemListFrame
	local ItemListBorder1 = Instance.new('Frame')
	ItemListBorder1.BackgroundColor3 = Color3.fromRGB(40, 39, 40)
	ItemListBorder1.BorderSizePixel = 0
	ItemListBorder1.Size = UDim2.new(1, 0, 0, 1)
	ItemListBorder1.Position = UDim2.new(0, 0, 0, 41)
	ItemListBorder1.Parent = ItemListFrame
	local ItemListFrameCorner = Instance.new('UICorner')
	ItemListFrameCorner.CornerRadius = UDim.new(0, 4)
	ItemListFrameCorner.Parent = ItemListFrame
	local ItemListFrame1 = Instance.new('Frame')
	ItemListFrame1.Size = UDim2.new(0, 112, 0, 113)
	ItemListFrame1.Position = UDim2.new(0, 10, 0, 71)
	ItemListFrame1.BackgroundColor3 = Color3.fromRGB(38, 37, 38)
	ItemListFrame1.Name = 'ItemListFrame1'
	ItemListFrame1.Parent = ItemListFrame
	local ItemListFrame2 = Instance.new('Frame')
	ItemListFrame2.Size = UDim2.new(0, 110, 0, 111)
	ItemListFrame2.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	ItemListFrame2.BorderSizePixel = 0
	ItemListFrame2.Name = 'ItemListFrame2'
	ItemListFrame2.Position = UDim2.new(0, 1, 0, 1)
	ItemListFrame2.Parent = ItemListFrame1
	local ItemListFramePicker = Instance.new('ScrollingFrame')
	ItemListFramePicker.Size = UDim2.new(0, 495, 0, 220)
	ItemListFramePicker.Position = UDim2.new(0, 144, 0, 122)
	ItemListFramePicker.BorderSizePixel = 0
	ItemListFramePicker.ScrollBarThickness = 3
	ItemListFramePicker.ScrollBarImageTransparency = 0.8
	ItemListFramePicker.VerticalScrollBarInset = Enum.ScrollBarInset.None
	ItemListFramePicker.BackgroundTransparency = 1
	ItemListFramePicker.Parent = ItemListFrame
	local ItemListFramePickerGrid = Instance.new('UIGridLayout')
	ItemListFramePickerGrid.CellPadding = UDim2.new(0, 4, 0, 3)
	ItemListFramePickerGrid.CellSize = UDim2.new(0, 51, 0, 52)
	ItemListFramePickerGrid.Parent = ItemListFramePicker
	ItemListFramePickerGrid:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
		ItemListFramePicker.CanvasSize = UDim2.new(0, 0, 0, ItemListFramePickerGrid.AbsoluteContentSize.Y * (1 / GuiLibrary['MainRescale'].Scale))
	end)
	local ItemListcorner = Instance.new('UICorner')
	ItemListcorner.CornerRadius = UDim.new(0, 5)
	ItemListcorner.Parent = ItemListFrame1
	local ItemListcorner2 = Instance.new('UICorner')
	ItemListcorner2.CornerRadius = UDim.new(0, 5)
	ItemListcorner2.Parent = ItemListFrame2
	local selectedslot = 1
	local hoveredslot = 0
	
	local refreshslots
	local refreshList
	refreshslots = function()
		local startnum = 144
		local oldhovered = hoveredslot
		for i2,v2 in next, (ItemListFrame:GetChildren()) do
			if v2.Name:find('ItemSlot') then
				v2:Remove()
			end
		end
		for i3,v3 in next, (ItemListFramePicker:GetChildren()) do
			if v3:IsA('TextButton') then
				v3:Remove()
			end
		end
		for i4,v4 in next, (sortableitems) do
			local ItemFrame = Instance.new('TextButton')
			ItemFrame.Text = ''
			ItemFrame.BackgroundColor3 = Color3.fromRGB(31, 30, 31)
			ItemFrame.Parent = ItemListFramePicker
			ItemFrame.AutoButtonColor = false
			local ItemFrameIcon = Instance.new('ImageLabel')
			ItemFrameIcon.Size = UDim2.new(0, 32, 0, 32)
			ItemFrameIcon.Image = bedwars.getIcon({itemType = v4.itemDisplayType}, true) 
			ItemFrameIcon.ResampleMode = (bedwars.getIcon({itemType = v4.itemDisplayType}, true):find('rbxasset://') and Enum.ResamplerMode.Pixelated or Enum.ResamplerMode.Default)
			ItemFrameIcon.Position = UDim2.new(0, 10, 0, 10)
			ItemFrameIcon.BackgroundTransparency = 1
			ItemFrameIcon.Parent = ItemFrame
			local ItemFramecorner = Instance.new('UICorner')
			ItemFramecorner.CornerRadius = UDim.new(0, 5)
			ItemFramecorner.Parent = ItemFrame
			ItemFrame.MouseButton1Click:Connect(function()
				for i5,v5 in next, (buttonapi['Hotbars'][buttonapi['CurrentlySelected']]['Items']) do
					if v5.itemType == v4.itemType then
						buttonapi['Hotbars'][buttonapi['CurrentlySelected']]['Items'][tostring(i5)] = nil
					end
				end
				buttonapi['Hotbars'][buttonapi['CurrentlySelected']]['Items'][tostring(selectedslot)] = v4
				refreshslots()
				refreshList()
			end)
		end
		for i = 1, 9 do
			local item = buttonapi['Hotbars'][buttonapi['CurrentlySelected']]['Items'][tostring(i)]
			local ItemListFrame3 = Instance.new('Frame')
			ItemListFrame3.Size = UDim2.new(0, 55, 0, 56)
			ItemListFrame3.Position = UDim2.new(0, startnum - 2, 0, 380)
			ItemListFrame3.BackgroundTransparency = (selectedslot == i and 0 or 1)
			ItemListFrame3.BackgroundColor3 = Color3.fromRGB(35, 34, 35)
			ItemListFrame3.Name = 'ItemSlot'
			ItemListFrame3.Parent = ItemListFrame
			local ItemListFrame4 = Instance.new('TextButton')
			ItemListFrame4.Size = UDim2.new(0, 51, 0, 52)
			ItemListFrame4.BackgroundColor3 = (oldhovered == i and Color3.fromRGB(31, 30, 31) or Color3.fromRGB(20, 20, 20))
			ItemListFrame4.BorderSizePixel = 0
			ItemListFrame4.AutoButtonColor = false
			ItemListFrame4.Text = ''
			ItemListFrame4.Name = 'ItemListFrame4'
			ItemListFrame4.Position = UDim2.new(0, 2, 0, 2)
			ItemListFrame4.Parent = ItemListFrame3
			local ItemListImage = Instance.new('ImageLabel')
			ItemListImage.Size = UDim2.new(0, 32, 0, 32)
			ItemListImage.BackgroundTransparency = 1
			local img = (item and bedwars.getIcon({itemType = item.itemDisplayType}, true) or '')
			ItemListImage.Image = img
			ItemListImage.ResampleMode = (img:find('rbxasset://') and Enum.ResamplerMode.Pixelated or Enum.ResamplerMode.Default)
			ItemListImage.Position = UDim2.new(0, 10, 0, 10)
			ItemListImage.Parent = ItemListFrame4
			local ItemListcorner3 = Instance.new('UICorner')
			ItemListcorner3.CornerRadius = UDim.new(0, 5)
			ItemListcorner3.Parent = ItemListFrame3
			local ItemListcorner4 = Instance.new('UICorner')
			ItemListcorner4.CornerRadius = UDim.new(0, 5)
			ItemListcorner4.Parent = ItemListFrame4
			ItemListFrame4.MouseEnter:Connect(function()
				ItemListFrame4.BackgroundColor3 = Color3.fromRGB(31, 30, 31)
				hoveredslot = i
			end)
			ItemListFrame4.MouseLeave:Connect(function()
				ItemListFrame4.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
				hoveredslot = 0
			end)
			ItemListFrame4.MouseButton1Click:Connect(function()
				selectedslot = i
				refreshslots()
			end)
			ItemListFrame4.MouseButton2Click:Connect(function()
				buttonapi['Hotbars'][buttonapi['CurrentlySelected']]['Items'][tostring(i)] = nil
				refreshslots()
				refreshList()
			end)
			startnum = startnum + 55
		end
	end	

	local function createHotbarButton(num, items)
		num = tonumber(num) or #buttonapi['Hotbars'] + 1
		local hotbarbutton = Instance.new('TextButton')
		hotbarbutton.Size = UDim2.new(1, 0, 0, 30)
		hotbarbutton.BackgroundTransparency = 1
		hotbarbutton.LayoutOrder = num
		hotbarbutton.AutoButtonColor = false
		hotbarbutton.Text = ''
		hotbarbutton.Parent = children3
		buttonapi['Hotbars'][num] = {['Items'] = items or {}, Object = hotbarbutton, ['Number'] = num}
		local hotbarframe = Instance.new('Frame')
		hotbarframe.BackgroundColor3 = (num == buttonapi['CurrentlySelected'] and Color3.fromRGB(54, 53, 54) or Color3.fromRGB(31, 30, 31))
		hotbarframe.Size = UDim2.new(0, 200, 0, 27)
		hotbarframe.Position = UDim2.new(0, 10, 0, 1)
		hotbarframe.Parent = hotbarbutton
		local uicorner3 = Instance.new('UICorner')
		uicorner3.CornerRadius = UDim.new(0, 5)
		uicorner3.Parent = hotbarframe
		local startpos = 11
		for i = 1, 9 do
			local item = buttonapi['Hotbars'][num]['Items'][tostring(i)]
			local hotbarbox = Instance.new('ImageLabel')
			hotbarbox.Name = i
			hotbarbox.Size = UDim2.new(0, 17, 0, 18)
			hotbarbox.Position = UDim2.new(0, startpos, 0, 5)
			hotbarbox.BorderSizePixel = 0
			hotbarbox.Image = (item and bedwars.getIcon({itemType = item.itemDisplayType}, true) or '')
			hotbarbox.ResampleMode = ((item and bedwars.getIcon({itemType = item.itemDisplayType}, true) or ''):find('rbxasset://') and Enum.ResamplerMode.Pixelated or Enum.ResamplerMode.Default)
			hotbarbox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
			hotbarbox.Parent = hotbarframe
			startpos = startpos + 18
		end
		hotbarbutton.MouseButton1Click:Connect(function()
			if buttonapi['CurrentlySelected'] == num then
				ItemListBigFrame.Visible = true
				GuiLibrary.MainGui.ScaledGui.ClickGui.Visible = false
				refreshslots()
			end
			buttonapi['CurrentlySelected'] = num
			refreshList()
		end)
		hotbarbutton.MouseButton2Click:Connect(function()
			if buttonapi['CurrentlySelected'] == num then
				buttonapi['CurrentlySelected'] = (num == 2 and 0 or 1)
			end
			table.remove(buttonapi['Hotbars'], num)
			refreshList()
		end)
	end

	refreshList = function()
		local newnum = 0
		local newtab = {}
		for i3,v3 in next, (buttonapi['Hotbars']) do
			newnum = newnum + 1
			newtab[newnum] = v3
		end
		buttonapi['Hotbars'] = newtab
		for i,v in next, (children3:GetChildren()) do
			if v:IsA('TextButton') then
				v:Remove()
			end
		end
		for i2,v2 in next, (buttonapi['Hotbars']) do
			createHotbarButton(i2, v2['Items'])
		end
		GuiLibrary['Settings'][children2.Name..argstable['Name']..'ItemList'] = {['Type'] = 'ItemList', ['Items'] = buttonapi['Hotbars'], ['CurrentlySelected'] = buttonapi['CurrentlySelected']}
	end
	buttonapi['RefreshList'] = refreshList

	buttontext.MouseButton1Click:Connect(function()
		createHotbarButton()
	end)

	GuiLibrary['Settings'][children2.Name..argstable['Name']..'ItemList'] = {['Type'] = 'ItemList', ['Items'] = buttonapi['Hotbars'], ['CurrentlySelected'] = buttonapi['CurrentlySelected']}
	GuiLibrary.ObjectsThatCanBeSaved[children2.Name..argstable['Name']..'ItemList'] = {['Type'] = 'ItemList', ['Items'] = buttonapi['Hotbars'], ['Api'] = buttonapi, Object = buttontext}

	return buttonapi
end

GuiLibrary.LoadSettingsEvent.Event:Connect(function(res)
	for i,v in next, (res) do
		local obj = GuiLibrary.ObjectsThatCanBeSaved[i]
		if obj and v.Type == 'ItemList' and obj.Api then
			obj.Api.Hotbars = v.Items
			obj.Api.CurrentlySelected = v.CurrentlySelected
			obj.Api.RefreshList()
		end
	end
end)

runFunction(function()
	local function getWhitelistedBed(bed)
		if bed then
			for i,v in next, (playersService:GetPlayers()) do
				if v:GetAttribute('Team') and bed and bed:GetAttribute('Team'..(v:GetAttribute('Team') or 0)..'NoBreak') then
					local plrtype, plrattackable = WhitelistFunctions:GetWhitelist(v)
					if not plrattackable then 
						return true
					end
				end
			end
		end
		return false
	end

	local function dumpRemote(tab)
		for i,v in next, (tab) do
			if v == 'Client' then
				return tab[i + 1]
			end
		end
		return ''
	end

	local KnitGotten, KnitClient
	repeat
		KnitGotten, KnitClient = pcall(function()
			return debug.getupvalue(require(lplr.PlayerScripts.TS.knit).setup, 6)
		end)
		if KnitGotten then break end
		task.wait()
	until KnitGotten
	repeat task.wait() until debug.getupvalue(KnitClient.Start, 1)
	local Flamework = require(replicatedStorageService['rbxts_include']['node_modules']['@flamework'].core.out).Flamework
	local Client = require(replicatedStorageService.TS.remotes).default.Client
	local InventoryUtil = require(replicatedStorageService.TS.inventory['inventory-util']).InventoryUtil
	local oldRemoteGet = getmetatable(Client).Get

	getmetatable(Client).Get = function(self, remoteName)
		if not vapeInjected then return oldRemoteGet(self, remoteName) end
		local originalRemote = oldRemoteGet(self, remoteName)
		if remoteName == 'DamageBlock' then
			return {
				CallServerAsync = function(self, tab)
					local hitBlock = bedwars.BlockController:getStore():getBlockAt(tab.blockRef.blockPosition)
					if hitBlock and hitBlock.Name == 'bed' then
						if getWhitelistedBed(hitBlock) then
							return {andThen = function(self, func) 
								func('failed')
							end}
						end
					end
					return originalRemote:CallServerAsync(tab)
				end,
				CallServer = function(self, tab)
					local hitBlock = bedwars.BlockController:getStore():getBlockAt(tab.blockRef.blockPosition)
					if hitBlock and hitBlock.Name == 'bed' then
						if getWhitelistedBed(hitBlock) then
							return {andThen = function(self, func) 
								func('failed')
							end}
						end
					end
					return originalRemote:CallServer(tab)
				end
			}
		elseif remoteName == bedwars.AttackRemote then
			return {
				instance = originalRemote.instance,
				SendToServer = function(self, attackTable, ...)
					local suc, plr = pcall(function() return playersService:GetPlayerFromCharacter(attackTable.entityInstance) end)
					if suc and plr then
						local playertype, playerattackable = WhitelistFunctions:GetWhitelist(plr)
						if not playerattackable then 
							return nil 
						end
						if Reach.Enabled then
							local attackMagnitude = ((RenderStore.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - attackTable.validate.targetPosition.value).magnitude
							if attackMagnitude > 18 then
								return nil 
							end
							attackTable.validate.selfPosition = attackValue(attackTable.validate.selfPosition.value + (attackMagnitude > 14.4 and (CFrame.lookAt(attackTable.validate.selfPosition.value, attackTable.validate.targetPosition.value).lookVector * 4) or Vector3.zero))
						end
						bedwarsStore.attackReach = math.floor((attackTable.validate.selfPosition.value - attackTable.validate.targetPosition.value).magnitude * 100) / 100
						bedwarsStore.attackReachUpdate = tick() + 1
					end
					return originalRemote:SendToServer(attackTable, ...)
				end
			}
		elseif remoteName == 'ActivateGravestone' then 
			return {
				SendToServer = function(self, necromancerTab, ...) 
					local success, plr = pcall(function()
						return playersService:GetPlayerByUserId(necromancerTab.skeletonData.associatedPlayerUserId) 
					end)
					if plr and not RenderFunctions:GetPlayerType(2, plr) then 
						return nil
					end
					return originalRemote:SendToServer(necromancerTab, ...)
				end
			} 
		elseif remoteName == 'SendToLobby' then 
			return {
				SendToServer = function(self, ...) 
					pcall(GuiLibrary.SaveSettings)
					return originalRemote:SendToServer(self, ...)
				end
			} 
		end
		return originalRemote
	end

	bedwars = {
		AnimationType = require(replicatedStorageService.TS.animation['animation-type']).AnimationType,
		AnimationUtil = require(replicatedStorageService['rbxts_include']['node_modules']['@easy-games']['game-core'].out['shared'].util['animation-util']).AnimationUtil,
		AppController = require(replicatedStorageService['rbxts_include']['node_modules']['@easy-games']['game-core'].out.client.controllers['app-controller']).AppController,
		AbilityController = Flamework.resolveDependency('@easy-games/game-core:client/controllers/ability/ability-controller@AbilityController'),
		AbilityUIController = 	Flamework.resolveDependency('@easy-games/game-core:client/controllers/ability/ability-ui-controller@AbilityUIController'),
		AttackRemote = dumpRemote(debug.getconstants(KnitClient.Controllers.SwordController.sendServerRequest)),
		BalloonController = KnitClient.Controllers.BalloonController,
		BalanceFile = require(replicatedStorageService.TS.balance['balance-file']).BalanceFile,
		BatteryEffectController = KnitClient.Controllers.BatteryEffectsController,
		BatteryRemote = dumpRemote(debug.getconstants(debug.getproto(debug.getproto(KnitClient.Controllers.BatteryController.KnitStart, 1), 1))),
		BlockBreaker = KnitClient.Controllers.BlockBreakController.blockBreaker,
		BlockController = require(replicatedStorageService['rbxts_include']['node_modules']['@easy-games']['block-engine'].out).BlockEngine,
		BlockCpsController = KnitClient.Controllers.BlockCpsController,
		BlockPlacer = require(replicatedStorageService['rbxts_include']['node_modules']['@easy-games']['block-engine'].out.client.placement['block-placer']).BlockPlacer,
		BlockEngine = require(lplr.PlayerScripts.TS.lib['block-engine']['client-block-engine']).ClientBlockEngine,
		BlockEngineClientEvents = require(replicatedStorageService['rbxts_include']['node_modules']['@easy-games']['block-engine'].out.client['block-engine-client-events']).BlockEngineClientEvents,
		BlockPlacementController = KnitClient.Controllers.BlockPlacementController,
		BowConstantsTable = debug.getupvalue(KnitClient.Controllers.ProjectileController.enableBeam, 6),
		ProjectileController = KnitClient.Controllers.ProjectileController,
		ChestController = KnitClient.Controllers.ChestController,
		CannonHandController = KnitClient.Controllers.CannonHandController,
		CannonAimRemote = dumpRemote(debug.getconstants(debug.getproto(KnitClient.Controllers.CannonController.startAiming, 5))),
		CannonLaunchRemote = dumpRemote(debug.getconstants(KnitClient.Controllers.CannonHandController.launchSelf)),
		ClickHold = require(replicatedStorageService['rbxts_include']['node_modules']['@easy-games']['game-core'].out.client.ui.lib.util['click-hold']).ClickHold,
		ClientHandler = Client,
		ClientConstructor = require(replicatedStorageService['rbxts_include']['node_modules']['@rbxts'].net.out.client),
		ClientHandlerDamageBlock = require(replicatedStorageService['rbxts_include']['node_modules']['@easy-games']['block-engine'].out.shared.remotes).BlockEngineRemotes.Client,
		ClientStoreHandler = require(lplr.PlayerScripts.TS.ui.store).ClientStore,
		CombatConstant = require(replicatedStorageService.TS.combat['combat-constant']).CombatConstant,
		CombatController = KnitClient.Controllers.CombatController,
		ConstantManager = require(replicatedStorageService['rbxts_include']['node_modules']['@easy-games']['game-core'].out['shared'].constant['constant-manager']).ConstantManager,
		ConsumeSoulRemote = dumpRemote(debug.getconstants(KnitClient.Controllers.GrimReaperController.consumeSoul)),
		CooldownController = Flamework.resolveDependency('@easy-games/game-core:client/controllers/cooldown/cooldown-controller@CooldownController'),
		DamageIndicator = KnitClient.Controllers.DamageIndicatorController.spawnDamageIndicator,
		DamageIndicatorController = KnitClient.Controllers.DamageIndicatorController,
		DefaultKillEffect = require(lplr.PlayerScripts.TS.controllers.game.locker['kill-effect'].effects['default-kill-effect']),
		DropItem = KnitClient.Controllers.ItemDropController.dropItemInHand,
		DropItemRemote = dumpRemote(debug.getconstants(KnitClient.Controllers.ItemDropController.dropItemInHand)),
		DragonSlayerController = KnitClient.Controllers.DragonSlayerController,
		DragonRemote = dumpRemote(debug.getconstants(debug.getproto(debug.getproto(KnitClient.Controllers.DragonSlayerController.KnitStart, 2), 1))),
		ElkConstants = require(replicatedStorageService.TS.mount["mount-constants"]["elk-constants"]).ElkConstants,
		EatRemote = dumpRemote(debug.getconstants(debug.getproto(KnitClient.Controllers.ConsumeController.onEnable, 1))),
		EquipItemRemote = dumpRemote(debug.getconstants(debug.getproto(require(replicatedStorageService.TS.entity.entities['inventory-entity']).InventoryEntity.equipItem, 3))),
		EmoteMeta = require(replicatedStorageService.TS.locker.emote['emote-meta']).EmoteMeta,
		FishermanTable = KnitClient.Controllers.FishermanController,
		FovController = KnitClient.Controllers.FovController,
		ForgeController = KnitClient.Controllers.ForgeController,
		ForgeConstants = debug.getupvalue(KnitClient.Controllers.ForgeController.getPurchaseableForgeUpgrades, 2),
		ForgeUtil = debug.getupvalue(KnitClient.Controllers.ForgeController.getPurchaseableForgeUpgrades, 5),
		GameAnimationUtil = require(replicatedStorageService.TS.animation['animation-util']).GameAnimationUtil,
		EntityUtil = require(replicatedStorageService.TS.entity['entity-util']).EntityUtil,
		getIcon = function(item, showinv)
			local itemmeta = bedwars.ItemTable[item.itemType]
			if itemmeta and showinv then
				return itemmeta.image or ''
			end
			return ''
		end,
		getInventory = function(plr)
			local suc, result = pcall(function() 
				return InventoryUtil.getInventory(plr) 
			end)
			return (suc and result or {
				items = {},
				armor = {},
				hand = nil
			})
		end,
		GrimReaperController = KnitClient.Controllers.GrimReaperController,
		GuitarHealRemote = dumpRemote(debug.getconstants(KnitClient.Controllers.GuitarController.performHeal)),
		HangGliderController = KnitClient.Controllers.HangGliderController,
		HighlightController = KnitClient.Controllers.EntityHighlightController,
		ItemTable = debug.getupvalue(require(replicatedStorageService.TS.item['item-meta']).getItemMeta, 1),
		InfernalShieldController = KnitClient.Controllers.InfernalShieldController,
		KatanaController = KnitClient.Controllers.DaoController,
		KillEffectMeta = require(replicatedStorageService.TS.locker['kill-effect']['kill-effect-meta']).KillEffectMeta,
		KillEffectController = KnitClient.Controllers.KillEffectController,
		KnockbackUtil = require(replicatedStorageService.TS.damage['knockback-util']).KnockbackUtil,
		LobbyClientEvents = KnitClient.Controllers.QueueController,
		MapController = KnitClient.Controllers.MapController,
		MatchEndScreenController = Flamework.resolveDependency('client/controllers/game/match/match-end-screen-controller@MatchEndScreenController'),
		MinerRemote = dumpRemote(debug.getconstants(debug.getproto(KnitClient.Controllers.MinerController.onKitEnabled, 1))),
		MageRemote = dumpRemote(debug.getconstants(debug.getproto(KnitClient.Controllers.MageController.registerTomeInteraction, 1))),
		MageKitUtil = require(replicatedStorageService.TS.games.bedwars.kit.kits.mage['mage-kit-util']).MageKitUtil,
		MageController = KnitClient.Controllers.MageController,
		MissileController = KnitClient.Controllers.GuidedProjectileController,
		PickupMetalRemote = dumpRemote(debug.getconstants(debug.getproto(debug.getproto(KnitClient.Controllers.MetalDetectorController.KnitStart, 1), 2))),
		PickupRemote = dumpRemote(debug.getconstants(KnitClient.Controllers.ItemDropController.checkForPickup)),
		ProjectileMeta = require(replicatedStorageService.TS.projectile['projectile-meta']).ProjectileMeta,
		ProjectileRemote = dumpRemote(debug.getconstants(debug.getupvalue(KnitClient.Controllers.ProjectileController.launchProjectileWithValues, 2))),
		QueryUtil = require(replicatedStorageService['rbxts_include']['node_modules']['@easy-games']['game-core'].out).GameQueryUtil,
		QueueCard = require(lplr.PlayerScripts.TS.controllers.global.queue.ui['queue-card']).QueueCard,
		QueueMeta = require(replicatedStorageService.TS.game['queue-meta']).QueueMeta,
		RavenTable = KnitClient.Controllers.RavenController,
		RelicController = KnitClient.Controllers.RelicVotingController,
		ReportRemote = dumpRemote(debug.getconstants(require(lplr.PlayerScripts.TS.controllers.global.report['report-controller']).default.reportPlayer)),
		ResetRemote = dumpRemote(debug.getconstants(debug.getproto(KnitClient.Controllers.ResetController.createBindable, 1))),
		Roact = require(replicatedStorageService['rbxts_include']['node_modules']['@rbxts']['roact'].src),
		RuntimeLib = require(replicatedStorageService['rbxts_include'].RuntimeLib),
		ScytheController = KnitClient.Controllers.ScytheController,
		Shop = require(replicatedStorageService.TS.games.bedwars.shop['bedwars-shop']).BedwarsShop,
		ShopItems = debug.getupvalue(debug.getupvalue(require(replicatedStorageService.TS.games.bedwars.shop['bedwars-shop']).BedwarsShop.getShopItem, 1), 3),
		SoundList = require(replicatedStorageService.TS.sound['game-sound']).GameSound,
		SoundManager = require(replicatedStorageService['rbxts_include']['node_modules']['@easy-games']['game-core'].out).SoundManager,
		SpawnRavenRemote = dumpRemote(debug.getconstants(KnitClient.Controllers.RavenController.spawnRaven)),
		SprintController = KnitClient.Controllers.SprintController,
		StopwatchController = KnitClient.Controllers.StopwatchController,
		SwordController = KnitClient.Controllers.SwordController,
		TreeRemote = dumpRemote(debug.getconstants(debug.getproto(debug.getproto(KnitClient.Controllers.BigmanController.KnitStart, 1), 2))),
		TrinityRemote = dumpRemote(debug.getconstants(debug.getproto(KnitClient.Controllers.AngelController.onKitEnabled, 1))),
		TopBarController = KnitClient.Controllers.TopBarController,
		ViewmodelController = KnitClient.Controllers.ViewmodelController,
		WeldTable = require(replicatedStorageService.TS.util['weld-util']).WeldUtil,
		ZephyrController = KnitClient.Controllers.WindWalkerController
	}

	bedwarsStore.blockPlacer = bedwars.BlockPlacer.new(bedwars.BlockEngine, 'wool_white')
	bedwars.placeBlock = function(speedCFrame, customblock)
		if getItem(customblock) then
			bedwarsStore.blockPlacer.blockType = customblock
			return bedwarsStore.blockPlacer:placeBlock(Vector3.new(speedCFrame.X / 3, speedCFrame.Y / 3, speedCFrame.Z / 3))
		end
	end

	getgenv().bedwars = bedwars 
	getgenv().bedwarsStore = bedwarsStore
	getgenv().vapeEvents = vapeEvents

	local healthbarblocktable = {
		blockHealth = -1,
		breakingBlockPosition = Vector3.zero
	}

	local failedBreak = 0
	bedwars.breakBlock = function(pos, effects, normal, bypass, anim)
		if isEnabled('InfiniteFly') then 
			return
		end
		if lplr:GetAttribute('DenyBlockBreak') then
			return
		end
		local block, blockpos = nil, nil
		if not bypass then block, blockpos = getLastCovered(pos, normal) end
		if not block then block, blockpos = getPlacedBlock(pos) end
		if blockpos and block then
			if bedwars.BlockEngineClientEvents.DamageBlock:fire(block.Name, blockpos, block):isCancelled() then
				return
			end
			local blockhealthbarpos = {blockPosition = Vector3.zero}
			local blockdmg = 0
			if block and block.Parent ~= nil then
				if ((RenderStore.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - (blockpos * 3)).magnitude > 30 then return end
				bedwarsStore.blockPlace = tick() + 0.1
				switchToAndUseTool(block)
				blockhealthbarpos = {
					blockPosition = blockpos
				}
				task.spawn(function()
					bedwars.ClientHandlerDamageBlock:Get('DamageBlock'):CallServerAsync({
						blockRef = blockhealthbarpos, 
						hitPosition = blockpos * 3, 
						hitNormal = Vector3.FromNormalId(normal)
					}):andThen(function(result)
						if result ~= 'failed' then
							failedBreak = 0
							if healthbarblocktable.blockHealth == -1 or blockhealthbarpos.blockPosition ~= healthbarblocktable.breakingBlockPosition then
								local blockdata = bedwars.BlockController:getStore():getBlockData(blockhealthbarpos.blockPosition)
								local blockhealth = blockdata and blockdata:GetAttribute(lplr.Name .. '_Health') or block:GetAttribute('Health')
								healthbarblocktable.blockHealth = blockhealth
								healthbarblocktable.breakingBlockPosition = blockhealthbarpos.blockPosition
							end
							healthbarblocktable.blockHealth = result == 'destroyed' and 0 or healthbarblocktable.blockHealth
							blockdmg = bedwars.BlockController:calculateBlockDamage(lplr, blockhealthbarpos)
							healthbarblocktable.blockHealth = math.max(healthbarblocktable.blockHealth - blockdmg, 0)
							if effects then
								bedwars.BlockBreaker:updateHealthbar(blockhealthbarpos, healthbarblocktable.blockHealth, block:GetAttribute('MaxHealth'), blockdmg, block)
								if healthbarblocktable.blockHealth <= 0 then
									bedwars.BlockBreaker.breakEffect:playBreak(block.Name, blockhealthbarpos.blockPosition, lplr)
									bedwars.BlockBreaker.healthbarMaid:DoCleaning()
									healthbarblocktable.breakingBlockPosition = Vector3.zero
								else
									bedwars.BlockBreaker.breakEffect:playHit(block.Name, blockhealthbarpos.blockPosition, lplr)
								end
							end
							local animation
							if anim then
								animation = bedwars.AnimationUtil:playAnimation(lplr, bedwars.BlockController:getAnimationController():getAssetId(1))
								bedwars.ViewmodelController:playAnimation(15)
							end
							task.wait(0.3)
							if animation ~= nil then
								animation:Stop()
								animation:Destroy()
							end
						else
							failedBreak = failedBreak + 1
						end
					end)
				end)
				task.wait(physicsUpdate)
			end
		end
	end	

	local function updateStore(newStore, oldStore)
		if newStore.Game ~= oldStore.Game then 
			bedwarsStore.matchState = newStore.Game.matchState
			bedwarsStore.queueType = newStore.Game.queueType or 'bedwars_test'
			bedwarsStore.forgeMasteryPoints = newStore.Game.forgeMasteryPoints
			bedwarsStore.forgeUpgrades = newStore.Game.forgeUpgrades
		end
		if newStore.Bedwars ~= oldStore.Bedwars then 
			bedwarsStore.equippedKit = newStore.Bedwars.kit ~= 'none' and newStore.Bedwars.kit or ''
		end
		if newStore.Inventory ~= oldStore.Inventory then
			local newInventory = (newStore.Inventory and newStore.Inventory.observedInventory or {inventory = {}})
			local oldInventory = (oldStore.Inventory and oldStore.Inventory.observedInventory or {inventory = {}})
			bedwarsStore.localInventory = newStore.Inventory.observedInventory
			if newInventory ~= oldInventory then
				vapeEvents.InventoryChanged:Fire()
			end
			if newInventory.inventory.items ~= oldInventory.inventory.items then
				vapeEvents.InventoryAmountChanged:Fire()
			end
			if newInventory.inventory.hand ~= oldInventory.inventory.hand then 
				local currentHand = newStore.Inventory.observedInventory.inventory.hand
				local handType = ''
				if currentHand then
					local handData = bedwars.ItemTable[currentHand.itemType]
					handType = handData.sword and 'sword' or handData.block and 'block' or currentHand.itemType:find('bow') and 'bow'
				end
				bedwarsStore.localHand = {tool = currentHand and currentHand.tool, Type = handType, amount = currentHand and currentHand.amount or 0}
			end
		end
	end

	table.insert(vapeConnections, bedwars.ClientStoreHandler.changed:connect(updateStore))
	updateStore(bedwars.ClientStoreHandler:getState(), {})

	for i, v in next, ({'MatchEndEvent', 'EntityDeathEvent', 'EntityDamageEvent', 'BedwarsBedBreak', 'BalloonPopped', 'AngelProgress'}) do 
		bedwars.ClientHandler:WaitFor(v):andThen(function(connection)
			table.insert(vapeConnections, connection:Connect(function(...)
				vapeEvents[v]:Fire(...)
			end))
		end)
	end
	for i, v in next, ({'PlaceBlockEvent', 'BreakBlockEvent'}) do 
		bedwars.ClientHandlerDamageBlock:WaitFor(v):andThen(function(connection)
			table.insert(vapeConnections, connection:Connect(function(...)
				vapeEvents[v]:Fire(...)
			end))
		end)
	end

	bedwarsStore.blocks = collectionService:GetTagged('block')
	bedwarsStore.blockRaycast.FilterDescendantsInstances = {bedwarsStore.blocks}
	table.insert(vapeConnections, collectionService:GetInstanceAddedSignal('block'):Connect(function(block)
		table.insert(bedwarsStore.blocks, block)
		bedwarsStore.blockRaycast.FilterDescendantsInstances = {bedwarsStore.blocks}
	end))
	table.insert(vapeConnections, collectionService:GetInstanceRemovedSignal('block'):Connect(function(block)
		block = table.find(bedwarsStore.blocks, block)
		if block then 
			table.remove(bedwarsStore.blocks, block)
			bedwarsStore.blockRaycast.FilterDescendantsInstances = {bedwarsStore.blocks}
		end
	end))
	for _, ent in next, (collectionService:GetTagged('entity')) do 
		if ent.Name == 'DesertPotEntity' then 
			table.insert(bedwarsStore.pots, ent)
		end
	end
	table.insert(vapeConnections, collectionService:GetInstanceAddedSignal('entity'):Connect(function(ent)
		if ent.Name == 'DesertPotEntity' then 
			table.insert(bedwarsStore.pots, ent)
		end
	end))
	table.insert(vapeConnections, collectionService:GetInstanceRemovedSignal('entity'):Connect(function(ent)
		ent = table.find(bedwarsStore.pots, ent)
		if ent then 
			table.remove(bedwarsStore.pots, ent)
		end
	end))

	local oldZephyrUpdate = bedwars.ZephyrController.updateJump
	bedwars.ZephyrController.updateJump = function(self, orb, ...)
		bedwarsStore.zephyrOrb = lplr.Character and lplr.Character:GetAttribute('Health') > 0 and orb or 0
		return oldZephyrUpdate(self, orb, ...)
	end

	GuiLibrary.SelfDestructEvent.Event:Connect(function()
		bedwars.ZephyrController.updateJump = oldZephyrUpdate
		getmetatable(bedwars.ClientHandler).Get = oldRemoteGet
		bedwarsStore.blockPlacer:disable()
		textChatService.OnIncomingMessage = nil
	end)
	
	local teleportedServers = false
	table.insert(vapeConnections, lplr.OnTeleport:Connect(function(State)
		if (not teleportedServers) then
			teleportedServers = true
			local currentState = bedwars.ClientStoreHandler and bedwars.ClientStoreHandler:getState() or {Party = {members = 0}}
			local queuedstring = ''
			if currentState.Party and currentState.Party.members and #currentState.Party.members > 0 then
				queuedstring = queuedstring..'shared.vapeteammembers = '..#currentState.Party.members..'\n'
			end
			if bedwarsStore.TPString then
				queuedstring = queuedstring.."shared.vapeoverlay = "..bedwarsStore.TPString.."\n"
			end
			queueonteleport(queuedstring)
		end
	end))
end)

do
	entityLibrary.animationCache = {}
	entityLibrary.groundTick = tick()
	entityLibrary.selfDestruct()
	entityLibrary.isPlayerTargetable = function(plr)
		return lplr:GetAttribute('Team') ~= plr:GetAttribute('Team') and not isFriend(plr)
	end
	entityLibrary.characterAdded = function(plr, char, localcheck)
		local id = game:GetService('HttpService'):GenerateGUID(true)
		entityLibrary.entityIds[plr.Name] = id
        if char then
            task.spawn(function()
                local humrootpart = char:WaitForChild('HumanoidRootPart', 10)
                local head = char:WaitForChild('Head', 10)
                local hum = char:WaitForChild('Humanoid', 10)
				if entityLibrary.entityIds[plr.Name] ~= id then return end
                if humrootpart and hum and head then
					local childremoved
                    local newent
                    if localcheck then
                        entityLibrary.isAlive = true
                        entityLibrary.character.Head = head
                        entityLibrary.character.Humanoid = hum
                        entityLibrary.character.HumanoidRootPart = humrootpart
						table.insert(entityLibrary.entityConnections, char.AttributeChanged:Connect(function(...)
							vapeEvents.AttributeChanged:Fire(...)
						end))
                    else
						newent = {
                            Player = plr,
                            Character = char,
                            HumanoidRootPart = humrootpart,
                            RootPart = humrootpart,
                            Head = head,
                            Humanoid = hum,
                            Targetable = entityLibrary.isPlayerTargetable(plr),
                            Team = plr.Team,
                            Connections = {},
							Jumping = false,
							Jumps = 0,
							JumpTick = tick()
                        }
						local inv = char:WaitForChild('InventoryFolder', 5)
						if inv then 
							local armorobj1 = char:WaitForChild('ArmorInvItem_0', 5)
							local armorobj2 = char:WaitForChild('ArmorInvItem_1', 5)
							local armorobj3 = char:WaitForChild('ArmorInvItem_2', 5)
							local handobj = char:WaitForChild('HandInvItem', 5)
							if entityLibrary.entityIds[plr.Name] ~= id then return end
							if armorobj1 then
								table.insert(newent.Connections, armorobj1.Changed:Connect(function() 
									task.delay(0.3, function() 
										if entityLibrary.entityIds[plr.Name] ~= id then return end
										bedwarsStore.inventories[plr] = bedwars.getInventory(plr) 
										entityLibrary.entityUpdatedEvent:Fire(newent)
									end)
								end))
							end
							if armorobj2 then
								table.insert(newent.Connections, armorobj2.Changed:Connect(function() 
									task.delay(0.3, function() 
										if entityLibrary.entityIds[plr.Name] ~= id then return end
										bedwarsStore.inventories[plr] = bedwars.getInventory(plr) 
										entityLibrary.entityUpdatedEvent:Fire(newent)
									end)
								end))
							end
							if armorobj3 then
								table.insert(newent.Connections, armorobj3.Changed:Connect(function() 
									task.delay(0.3, function() 
										if entityLibrary.entityIds[plr.Name] ~= id then return end
										bedwarsStore.inventories[plr] = bedwars.getInventory(plr) 
										entityLibrary.entityUpdatedEvent:Fire(newent)
									end)
								end))
							end
							if handobj then
								table.insert(newent.Connections, handobj.Changed:Connect(function() 
									task.delay(0.3, function() 
										if entityLibrary.entityIds[plr.Name] ~= id then return end
										bedwarsStore.inventories[plr] = bedwars.getInventory(plr)
										entityLibrary.entityUpdatedEvent:Fire(newent)
									end)
								end))
							end
						end
						if entityLibrary.entityIds[plr.Name] ~= id then return end
						task.delay(0.3, function() 
							if entityLibrary.entityIds[plr.Name] ~= id then return end
							bedwarsStore.inventories[plr] = bedwars.getInventory(plr) 
							entityLibrary.entityUpdatedEvent:Fire(newent)
						end)
						table.insert(newent.Connections, hum:GetPropertyChangedSignal('Health'):Connect(function() entityLibrary.entityUpdatedEvent:Fire(newent) end))
						table.insert(newent.Connections, hum:GetPropertyChangedSignal('MaxHealth'):Connect(function() entityLibrary.entityUpdatedEvent:Fire(newent) end))
						table.insert(newent.Connections, hum.AnimationPlayed:Connect(function(state) 
							local animnum = tonumber(({state.Animation.AnimationId:gsub('%D+', '')})[1])
							if animnum then
								if not entityLibrary.animationCache[state.Animation.AnimationId] then 
									entityLibrary.animationCache[state.Animation.AnimationId] = game:GetService('MarketplaceService'):GetProductInfo(animnum)
								end
								if entityLibrary.animationCache[state.Animation.AnimationId].Name:lower():find('jump') then
									newent.Jumps = newent.Jumps + 1
								end
							end
						end))
						table.insert(newent.Connections, char.AttributeChanged:Connect(function(attr) if attr:find('Shield') then entityLibrary.entityUpdatedEvent:Fire(newent) end end))
						table.insert(entityLibrary.entityList, newent)
						entityLibrary.entityAddedEvent:Fire(newent)
                    end
					if entityLibrary.entityIds[plr.Name] ~= id then return end
					childremoved = char.ChildRemoved:Connect(function(part)
						if part.Name == 'HumanoidRootPart' or part.Name == 'Head' or part.Name == 'Humanoid' then			
							if localcheck then
								if char == lplr.Character then
									if part.Name == 'HumanoidRootPart' then
										entityLibrary.isAlive = false
										local root = char:FindFirstChild('HumanoidRootPart')
										if not root then 
											root = char:WaitForChild('HumanoidRootPart', 3)
										end
										if root then 
											entityLibrary.character.HumanoidRootPart = root
											entityLibrary.isAlive = true
										end
									else
										entityLibrary.isAlive = false
									end
								end
							else
								childremoved:Disconnect()
								entityLibrary.removeEntity(plr)
							end
						end
					end)
					if newent then 
						table.insert(newent.Connections, childremoved)
					end
					table.insert(entityLibrary.entityConnections, childremoved)
                end
            end)
        end
    end
	entityLibrary.entityAdded = function(plr, localcheck, custom)
		table.insert(entityLibrary.entityConnections, plr:GetPropertyChangedSignal('Character'):Connect(function()
            if plr.Character then
                entityLibrary.refreshEntity(plr, localcheck)
            else
                if localcheck then
                    entityLibrary.isAlive = false
                else
                    entityLibrary.removeEntity(plr)
                end
            end
        end))
        table.insert(entityLibrary.entityConnections, plr:GetAttributeChangedSignal('Team'):Connect(function()
			local tab = {}
			for i,v in next, entityLibrary.entityList do
                if v.Targetable ~= entityLibrary.isPlayerTargetable(v.Player) then 
                    table.insert(tab, v)
                end
            end
			for i,v in next, tab do 
				entityLibrary.refreshEntity(v.Player)
			end
            if localcheck then
                entityLibrary.fullEntityRefresh()
            else
				entityLibrary.refreshEntity(plr, localcheck)
            end
        end))
		if plr.Character then
            task.spawn(entityLibrary.refreshEntity, plr, localcheck)
        end
    end
	entityLibrary.fullEntityRefresh()
	task.spawn(function()
		repeat
			task.wait()
			if entityLibrary.isAlive then
				entityLibrary.groundTick = entityLibrary.character.Humanoid.FloorMaterial ~= Enum.Material.Air and tick() or entityLibrary.groundTick
			end
			for i,v in next, (entityLibrary.entityList) do 
				local state = v.Humanoid:GetState()
				v.JumpTick = (state ~= Enum.HumanoidStateType.Running and state ~= Enum.HumanoidStateType.Landed) and tick() or v.JumpTick
				v.Jumping = (tick() - v.JumpTick) < 0.2 and v.Jumps > 1
				if (tick() - v.JumpTick) > 0.2 then 
					v.Jumps = 0
				end
			end
		until not vapeInjected
	end)
end

runFunction(function()
	local handsquare = Instance.new('ImageLabel')
	handsquare.Size = UDim2.new(0, 26, 0, 27)
	handsquare.BackgroundColor3 = Color3.fromRGB(26, 25, 26)
	handsquare.Position = UDim2.new(0, 72, 0, 44)
	handsquare.Parent = vapeTargetInfo.Object.GetCustomChildren().Frame.MainInfo
	local handround = Instance.new('UICorner')
	handround.CornerRadius = UDim.new(0, 4)
	handround.Parent = handsquare
	local helmetsquare = handsquare:Clone()
	helmetsquare.Position = UDim2.new(0, 100, 0, 44)
	helmetsquare.Parent = vapeTargetInfo.Object.GetCustomChildren().Frame.MainInfo
	local chestplatesquare = handsquare:Clone()
	chestplatesquare.Position = UDim2.new(0, 127, 0, 44)
	chestplatesquare.Parent = vapeTargetInfo.Object.GetCustomChildren().Frame.MainInfo
	local bootssquare = handsquare:Clone()
	bootssquare.Position = UDim2.new(0, 155, 0, 44)
	bootssquare.Parent = vapeTargetInfo.Object.GetCustomChildren().Frame.MainInfo
	local uselesssquare = handsquare:Clone()
	uselesssquare.Position = UDim2.new(0, 182, 0, 44)
	uselesssquare.Parent = vapeTargetInfo.Object.GetCustomChildren().Frame.MainInfo
	local oldupdate = vapeTargetInfo.UpdateInfo
	vapeTargetInfo.UpdateInfo = function(tab, targetsize)
		local bkgcheck = vapeTargetInfo.Object.GetCustomChildren().Frame.MainInfo.BackgroundTransparency == 1
		handsquare.BackgroundTransparency = bkgcheck and 1 or 0
		helmetsquare.BackgroundTransparency = bkgcheck and 1 or 0
		chestplatesquare.BackgroundTransparency = bkgcheck and 1 or 0
		bootssquare.BackgroundTransparency = bkgcheck and 1 or 0
		uselesssquare.BackgroundTransparency = bkgcheck and 1 or 0
		pcall(function()
			for i,v in next, (shared.VapeTargetInfo.Targets) do
				local inventory = bedwarsStore.inventories[v.Player] or {}
					if inventory.hand then
						handsquare.Image = bedwars.getIcon(inventory.hand, true)
					else
						handsquare.Image = ''
					end
					if inventory.armor[4] then
						helmetsquare.Image = bedwars.getIcon(inventory.armor[4], true)
					else
						helmetsquare.Image = ''
					end
					if inventory.armor[5] then
						chestplatesquare.Image = bedwars.getIcon(inventory.armor[5], true)
					else
						chestplatesquare.Image = ''
					end
					if inventory.armor[6] then
						bootssquare.Image = bedwars.getIcon(inventory.armor[6], true)
					else
						bootssquare.Image = ''
					end
				break
			end
		end)
		return oldupdate(tab, targetsize)
	end
end)

GuiLibrary.RemoveObject('SilentAimOptionsButton')
GuiLibrary.RemoveObject('ReachOptionsButton')
GuiLibrary.RemoveObject('MouseTPOptionsButton')
GuiLibrary.RemoveObject('PhaseOptionsButton')
GuiLibrary.RemoveObject('AutoClickerOptionsButton')
GuiLibrary.RemoveObject('SpiderOptionsButton')
GuiLibrary.RemoveObject('LongJumpOptionsButton')
GuiLibrary.RemoveObject('HitBoxesOptionsButton')
GuiLibrary.RemoveObject('KillauraOptionsButton')
GuiLibrary.RemoveObject('TriggerBotOptionsButton')
GuiLibrary.RemoveObject('AutoLeaveOptionsButton')
GuiLibrary.RemoveObject('SpeedOptionsButton')
GuiLibrary.RemoveObject('FlyOptionsButton')
GuiLibrary.RemoveObject('ClientKickDisablerOptionsButton')
GuiLibrary.RemoveObject('NameTagsOptionsButton')
GuiLibrary.RemoveObject('SafeWalkOptionsButton')
GuiLibrary.RemoveObject('FOVChangerOptionsButton')
GuiLibrary.RemoveObject('AntiVoidOptionsButton')
GuiLibrary.RemoveObject('SongBeatsOptionsButton')
GuiLibrary.RemoveObject('TargetStrafeOptionsButton')

runFunction(function()
	local AimAssist = {}
	local AimAssistClickAim = {}
	local AimAssistStrafe = {}
	local AimSpeed = {Value = 1}
	local AimAssistTargetFrame = {Players = {}}
	AimAssist = GuiLibrary.ObjectsThatCanBeSaved.CombatWindow.Api.CreateOptionsButton({
		Name = 'AimAssist',
		Function = function(calling)
			if calling then
				RunLoops:BindToRenderStep('AimAssist', function(dt)
					vapeTargetInfo.Targets.AimAssist = nil
					if ((not AimAssistClickAim.Enabled) or (tick() - bedwars.SwordController.lastSwing) < 0.4) then
						local plr = EntityNearPosition(18)
						if plr then
							vapeTargetInfo.Targets.AimAssist = {
								Humanoid = {
									Health = (plr.Character:GetAttribute('Health') or plr.Humanoid.Health) + getShieldAttribute(plr.Character),
									MaxHealth = plr.Character:GetAttribute('MaxHealth') or plr.Humanoid.MaxHealth
								},
								Player = plr.Player
							}
							if bedwarsStore.localHand.Type == 'sword' then
								if isEnabled('Lobby Check', 'Toggle') then
									if bedwarsStore.matchState == 0 then return end
								end
								if AimAssistTargetFrame.Walls.Enabled then 
									if not bedwars.SwordController:canSee({instance = plr.Character, player = plr.Player, getInstance = function() return plr.Character end}) then return end
								end
								gameCamera.CFrame = gameCamera.CFrame:lerp(CFrame.new(gameCamera.CFrame.p, plr.Character.HumanoidRootPart.Position), ((1 / AimSpeed.Value) + (AimAssistStrafe.Enabled and (inputService:IsKeyDown(Enum.KeyCode.A) or inputService:IsKeyDown(Enum.KeyCode.D)) and 0.01 or 0)))
							end
						end
					end
				end)
			else
				RunLoops:UnbindFromRenderStep('AimAssist')
				vapeTargetInfo.Targets.AimAssist = nil
			end
		end,
		HoverText = 'Smoothly aims to closest valid target with sword'
	})
	AimAssistTargetFrame = AimAssist.CreateTargetWindow({Default3 = true})
	AimAssistClickAim = AimAssist.CreateToggle({
		Name = 'Click Aim',
		Function = function() end,
		Default = true,
		HoverText = 'Only aim while mouse is down'
	})
	AimAssistStrafe = AimAssist.CreateToggle({
		Name = 'Strafe increase',
		Function = function() end,
		HoverText = 'Increase speed while strafing away from target'
	})
	AimSpeed = AimAssist.CreateSlider({
		Name = 'Smoothness',
		Min = 1,
		Max = 100, 
		Function = function(val) end,
		Default = 50
	})
end)

runFunction(function()
	local autoclicker = {}
	local noclickdelay = {}
	local autoclickercps = {GetRandomValue = function() return 1 end}
	local verifastcik = {Value = 1}
	local autoclickerblocks = {}
	local autoclickertimed = {}
	local autoclickermousedown = false

	local function isNotHoveringOverGui()
		local mousepos = inputService:GetMouseLocation() - Vector2.new(0, 36)
		for i,v in next, (lplr.PlayerGui:GetGuiObjectsAtPosition(mousepos.X, mousepos.Y)) do 
			if v.Active then
				return false
			end
		end
		for i,v in next, (game:GetService('CoreGui'):GetGuiObjectsAtPosition(mousepos.X, mousepos.Y)) do 
			if v.Parent:IsA('ScreenGui') and v.Parent.Enabled then
				if v.Active then
					return false
				end
			end
		end
		return true
	end

	local function clickAction()
		if entityLibrary.isAlive then
			if not autoclicker.Enabled or not autoclickermousedown then return end
			if not isNotHoveringOverGui() then return end
			if getOpenApps() > (bedwarsStore.equippedKit == 'hannah' and 4 or 3) then return end
			if GuiLibrary.ObjectsThatCanBeSaved['Lobby CheckToggle'].Api.Enabled then
				if bedwarsStore.matchState == 0 then return end
			end
			if bedwarsStore.localHand.Type == 'sword' then
				if bedwars.KatanaController.chargingMaid == nil then
					task.spawn(function()
						while autoclickermousedown do
							bedwars.SwordController:swingSwordAtMouse()
							task.wait(math.max((verifastcik.Value / autoclickercps.GetRandomValue()), noclickdelay.Enabled and 0 or (autoclickertimed.Enabled and 0.38 or 0)))
						end
					end)
				end
			elseif bedwarsStore.localHand.Type == 'block' then 
				if autoclickerblocks.Enabled and bedwars.BlockPlacementController.blockPlacer then
					task.spawn(function()
						while autoclickermousedown do
							if (workspace:GetServerTimeNow() - bedwars.BlockCpsController.lastPlaceTimestamp) > ((1 / 12) * 0.5) then
								local mouseinfo = bedwars.BlockPlacementController.blockPlacer.clientManager:getBlockSelector():getMouseInfo(0)
								if mouseinfo then
									if mouseinfo.placementPosition == mouseinfo.placementPosition then
										bedwars.BlockPlacementController.blockPlacer:placeBlock(mouseinfo.placementPosition)
									end
								end
								task.wait(verifastcik.Value / autoclickercps.GetRandomValue())
							end
						end
					end)
				end
			end
		end
	end

	autoclicker = GuiLibrary.ObjectsThatCanBeSaved.CombatWindow.Api.CreateOptionsButton({
		Name = 'AutoClicker',
		Function = function(calling)
			if calling then
				table.insert(autoclicker.Connections, inputService.InputBegan:Connect(function(input, gameProcessed)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						autoclickermousedown = true
						clickAction()
					elseif input.UserInputType == Enum.UserInputType.Touch then
						autoclickermousedown = true
						clickAction()
					end
				end))

				table.insert(autoclicker.Connections, inputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						autoclickermousedown = false
					end
				end))

				table.insert(autoclicker.Connections, inputService.TouchStarted:Connect(function(touch, gameProcessed)
					if touch.UserInputType == Enum.UserInputType.Touch then
						autoclickermousedown = true
						clickAction()
					end
				end))

				table.insert(autoclicker.Connections, inputService.TouchEnded:Connect(function(touch)
					if touch.UserInputType == Enum.UserInputType.Touch then
						autoclickermousedown = false
					end
				end))
			end
		end,
		HoverText = 'Hold attack button to automatically click'
	})
	autoclickercps = autoclicker.CreateTwoSlider({
		Name = 'CPS',
		Min = 1,
		Max = 50,
		Function = function(val) end,
		Default = 8,
		Default2 = 12
	})
	autoclickertimed = autoclicker.CreateToggle({
		Name = 'Timed',
		Function = function() end
	})
	verifastcik = autoclicker.CreateSlider({
	  Name = 'Faster(less value)',
	  Min = 1,
	  Max = 10,
	  Default = 1,
	  Function = function() end,
	  HoverText = 'less value = more edging'
	})
	autoclickerblocks = autoclicker.CreateToggle({
		Name = 'Place Blocks', 
		Function = function() end, 
		Default = true,
		HoverText = 'Automatically places blocks when left click is held.'
	})

	local noclickfunc
	noclickdelay = GuiLibrary.ObjectsThatCanBeSaved.CombatWindow.Api.CreateOptionsButton({
		Name = 'NoClickDelay',
		Function = function(calling)
			if calling then
				noclickfunc = bedwars.SwordController.isClickingTooFast
				bedwars.SwordController.isClickingTooFast = function(self) 
					self.lastSwing = tick()
					return false 
				end
			else
				bedwars.SwordController.isClickingTooFast = noclickfunc
			end
		end,
		HoverText = 'Remove the CPS cap'
	})
end)

runFunction(function()
	local ReachValue = {Value = 14}
	Reach = GuiLibrary.ObjectsThatCanBeSaved.CombatWindow.Api.CreateOptionsButton({
		Name = 'Reach',
		Function = function(calling)
			if calling then
				bedwars.CombatConstant.RAYCAST_SWORD_CHARACTER_DISTANCE = ReachValue.Value + 2
			else
				bedwars.CombatConstant.RAYCAST_SWORD_CHARACTER_DISTANCE = 14.4
			end
		end, 
		HoverText = 'Extends attack reach'
	})
	ReachValue = Reach.CreateSlider({
		Name = 'Reach',
		Min = 0,
		Max = 18,
		Function = function(val)
			if Reach.Enabled then
				bedwars.CombatConstant.RAYCAST_SWORD_CHARACTER_DISTANCE = val + 2
			end
		end,
		Default = 18
	})
end)

runFunction(function()
	local Sprint = {}
	local oldSprintFunction
	Sprint = GuiLibrary.ObjectsThatCanBeSaved.CombatWindow.Api.CreateOptionsButton({
		Name = 'Sprint',
		Function = function(calling)
			if calling then
				if inputService.TouchEnabled then
					pcall(function() lplr.PlayerGui.MobileUI['2'].Visible = false end)
				end
				oldSprintFunction = bedwars.SprintController.stopSprinting
				bedwars.SprintController.stopSprinting = function(...)
					local originalCall = oldSprintFunction(...)
					bedwars.SprintController:startSprinting()
					return originalCall
				end
				table.insert(Sprint.Connections, lplr.CharacterAdded:Connect(function(char)
					char:WaitForChild('Humanoid', 9e9)
					task.wait(0.5)
					bedwars.SprintController:stopSprinting()
				end))
				task.spawn(function()
					bedwars.SprintController:startSprinting()
				end)
			else
				if inputService.TouchEnabled then
					pcall(function() lplr.PlayerGui.MobileUI['2'].Visible = true end)
				end
				bedwars.SprintController.stopSprinting = oldSprintFunction
				bedwars.SprintController:stopSprinting()
			end
		end,
		HoverText = 'Sets your sprinting to true.'
	})
end)

runFunction(function()
	local Velocity = {}
	local VelocityHorizontal = {Value = 100}
	local VelocityVertical = {Value = 100}
	local applyKnockback
	Velocity = GuiLibrary.ObjectsThatCanBeSaved.CombatWindow.Api.CreateOptionsButton({
		Name = 'Velocity',
		Function = function(calling)
			if calling then
				applyKnockback = bedwars.KnockbackUtil.applyKnockback
				bedwars.KnockbackUtil.applyKnockback = function(root, mass, dir, knockback, ...)
					knockback = knockback or {}
					if VelocityHorizontal.Value == 0 and VelocityVertical.Value == 0 then return end
					knockback.horizontal = (knockback.horizontal or 1) * (VelocityHorizontal.Value / 100)
					knockback.vertical = (knockback.vertical or 1) * (VelocityVertical.Value / 100)
					return applyKnockback(root, mass, dir, knockback, ...)
				end
			else
				bedwars.KnockbackUtil.applyKnockback = applyKnockback
			end
		end,
		HoverText = 'Reduces knockback taken'
	})
	VelocityHorizontal = Velocity.CreateSlider({
		Name = 'Horizontal',
		Min = 0,
		Max = 100,
		Percent = true,
		Function = function(val) end,
		Default = 0
	})
	VelocityVertical = Velocity.CreateSlider({
		Name = 'Vertical',
		Min = 0,
		Max = 100,
		Percent = true,
		Function = function(val) end,
		Default = 0
	})
end)

runFunction(function()
	local AutoLeaveDelay = {Value = 1}
	local AutoPlayAgain = {}
	local AutoLeaveStaff = {}
	local AutoLeaveRealLeave = {}
	local AutoLeaveStaff2 = {}
	local AutoLeaveRandom = {}
	local stafftable = {}
	local leaveAttempted = false

	local function getRole(plr)
		local suc, res = pcall(function() return plr:GetRankInGroup(5774246) end)
		if not suc then 
			repeat
				suc, res = pcall(function() return plr:GetRankInGroup(5774246) end)
				task.wait()
			until suc
		end
		if plr.UserId == 1774814725 then 
			return 200
		end
		return res
	end

	local whitelisted = {'SprintOptionsButton', 'AutoClickerOptionsButton', 'AutoReportOptionsButton', 'AutoReportV2OptionsButton', 'AutoLeaveOptionsButton', 'ReachOptionsButton'}
	local blacklisted = {'GamingChairOptionsButton', 'NoClickDelayOptionsButton'}
	local function dumpparty()
		local players = {}
		for i,v in bedwars.ClientStoreHandler:getState().Party.members do 
			local player = playersService:FindFirstChild(v.name) 
			if player then 
				table.insert(players, player.Name)
			end
		end
		return players
	end
	local function autoleavelockdown(player)
		stafftable[player.Name] = {queueType = bedwarsStore.queueType, party = dumpparty()}
		if not AutoLeaveStaff.Enabled then 
			return 
		end
		if AutoLeaveRealLeave.Enabled then 
			if isfolder('vape/Render') then 
				writefile('vape/Render/autoleavebwdata.txt', httpService:JSONEncode(stafftable))
			end
			queueonteleport('getgenv().AutoLeaveSession = '..bedwarsStore.queueType)
			bedwars.ClientHandler:Get('TeleportToLobby'):SendToServer() 
		end
		if AutoLeaveStaff2.Enabled then 
			task.spawn(errorNotification, 'AutoLeave', 'A staff memeber has been detected ('..player.DisplayName..')!', 60)
			for i,v in GuiLibrary.ObjectsThatCanBeSaved do 
				if v.Type == 'OptionsButton' and v.Api.Enabled then 
					local canremove = (table.find(whitelisted, i) == nil or tostring(v.Object.Parent.Parent):find('Render') == nil or table.find(blacklisted, i))
					if canremove then 
						GuiLibrary.SaveSettings = function() end
						v.Api.ToggleButton()
						task.spawn(GuiLibrary.RemoveObject, i)
					end
				end
			end
		else
			for i = 1, 3 do 
				pcall(GuiLibrary.SelfDestruct)
			end
			game:GetService('StarterGui'):SetCore('SendNotification', {Title = 'AutoLeave', Text = 'A staff has been detected ('..player.DisplayName..')!', Duration = 60})
		end
	end

	local function autoLeaveAdded(plr)
		task.spawn(function()
			if not shared.VapeFullyLoaded then
				repeat task.wait() until shared.VapeFullyLoaded
			end
			if getRole(plr) >= 100 then
				autoleavelockdown(plr)
			end
		end)
	end

	local function isEveryoneDead()
		if #bedwars.ClientStoreHandler:getState().Party.members > 0 then
			for i,v in next, (bedwars.ClientStoreHandler:getState().Party.members) do
				local plr = playersService:FindFirstChild(v.name)
				if plr and isAlive(plr, true) then
					return false
				end
			end
			return true
		else
			return true
		end
	end

	AutoLeave = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = 'AutoLeave', 
		Function = function(calling)
			if calling then
				table.insert(AutoLeave.Connections, vapeEvents.EntityDeathEvent.Event:Connect(function(deathTable)
					if (not leaveAttempted) and deathTable.finalKill and deathTable.entityInstance == lplr.Character then
						leaveAttempted = true
						if isEveryoneDead() and bedwarsStore.matchState ~= 2 then
							task.wait(1 + (AutoLeaveDelay.Value / 10))
							if bedwars.ClientStoreHandler:getState().Game.customMatch == nil and bedwars.ClientStoreHandler:getState().Party.leader.userId == lplr.UserId then
								if not AutoPlayAgain.Enabled then
									bedwars.ClientHandler:Get('TeleportToLobby'):SendToServer()
								else
									if AutoLeaveRandom.Enabled then 
										local listofmodes = {}
										for i,v in next, (bedwars.QueueMeta) do
											if not v.disabled and not v.voiceChatOnly and not v.rankCategory then table.insert(listofmodes, i) end
										end
										bedwars.LobbyClientEvents:joinQueue(listofmodes[math.random(1, #listofmodes)])
									else
										bedwars.LobbyClientEvents:joinQueue(bedwarsStore.queueType)
									end
								end
							end
						end
					end
				end))
				table.insert(AutoLeave.Connections, vapeEvents.MatchEndEvent.Event:Connect(function(deathTable)
					task.wait(AutoLeaveDelay.Value / 10)
					if not AutoLeave.Enabled then return end
					if leaveAttempted then return end
					leaveAttempted = true
					if bedwars.ClientStoreHandler:getState().Game.customMatch == nil and bedwars.ClientStoreHandler:getState().Party.leader.userId == lplr.UserId then
						if not AutoPlayAgain.Enabled then
							bedwars.ClientHandler:Get('TeleportToLobby'):SendToServer()
						else
							if bedwars.ClientStoreHandler:getState().Party.queueState == 0 then
								if AutoLeaveRandom.Enabled then 
									local listofmodes = {}
									for i,v in next, (bedwars.QueueMeta) do
										if not v.disabled and not v.voiceChatOnly and not v.rankCategory then table.insert(listofmodes, i) end
									end
									bedwars.LobbyClientEvents:joinQueue(listofmodes[math.random(1, #listofmodes)])
								else
									bedwars.LobbyClientEvents:joinQueue(bedwarsStore.queueType)
								end
							end
						end
					end
				end))
				table.insert(AutoLeave.Connections, playersService.PlayerAdded:Connect(autoLeaveAdded))
				for i, plr in next, (playersService:GetPlayers()) do
					autoLeaveAdded(plr)
				end
			end
		end,
		HoverText = 'Leaves if a staff member joins your game or when the match ends.'
	})
	AutoLeaveDelay = AutoLeave.CreateSlider({
		Name = 'Delay',
		Min = 0,
		Max = 50,
		Default = 0,
		Function = function() end,
		HoverText = 'Delay before going back to the hub.'
	})
	AutoPlayAgain = AutoLeave.CreateToggle({
		Name = 'Play Again',
		Function = function() end,
		HoverText = 'Automatically queues a new game.',
		Default = true
	})
	AutoLeaveStaff = AutoLeave.CreateToggle({
		Name = 'Staff',
		Function = function(calling) 
			if AutoLeaveStaff2.Object then 
				AutoLeaveStaff2.Object.Visible = calling
			end
		end,
		HoverText = 'Automatically uninjects when staff joins',
		Default = true
	})
	AutoLeaveStaff2 = AutoLeave.CreateToggle({
		Name = 'Staff AutoConfig',
		Function = function() end,
		HoverText = 'Instead of uninjecting, It will now reconfig vape temporarily to a more legit config.',
		Default = true
	})
	AutoLeaveRealLeave = AutoLeave.CreateToggle({
		Name = 'Staff Lobby',
		HoverText = 'Automatcally teleports you to the lobby on staff join.',
		Default = true,
		Function = function() end,
	})
	AutoLeaveRandom = AutoLeave.CreateToggle({
		Name = 'Random',
		Function = function(calling) end,
		HoverText = 'Chooses a random mode'
	})
	AutoLeaveStaff2.Object.Visible = false
end)

runFunction(function()
	local oldclickhold
	local oldclickhold2
	local roact 
	local FastConsume = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = 'FastConsume',
		Function = function(calling)
			if calling then
				oldclickhold = bedwars.ClickHold.startClick
				oldclickhold2 = bedwars.ClickHold.showProgress
				bedwars.ClickHold.showProgress = function(p5)
					local roact = debug.getupvalue(oldclickhold2, 1)
					local countdown = roact.mount(roact.createElement('ScreenGui', {}, { roact.createElement('Frame', {
						[roact.Ref] = p5.wrapperRef, 
						Size = UDim2.new(0, 0, 0, 0), 
						Position = UDim2.new(0.5, 0, 0.55, 0), 
						AnchorPoint = Vector2.new(0.5, 0), 
						BackgroundColor3 = Color3.fromRGB(0, 0, 0), 
						BackgroundTransparency = 0.8
					}, { roact.createElement('Frame', {
							[roact.Ref] = p5.progressRef, 
							Size = UDim2.new(0, 0, 1, 0), 
							BackgroundColor3 = Color3.fromRGB(255, 255, 255), 
							BackgroundTransparency = 0.5
						}) }) }), lplr:FindFirstChild('PlayerGui'))
					p5.handle = countdown
					local sizetween = tweenService:Create(p5.wrapperRef:getValue(), TweenInfo.new(0.1), {
						Size = UDim2.new(0.11, 0, 0.005, 0)
					})
					table.insert(p5.tweens, sizetween)
					sizetween:Play()
					local countdowntween = tweenService:Create(p5.progressRef:getValue(), TweenInfo.new(p5.durationSeconds * (FastConsumeVal.Value / 40), Enum.EasingStyle.Linear), {
						Size = UDim2.new(1, 0, 1, 0)
					})
					table.insert(p5.tweens, countdowntween)
					countdowntween:Play()
					return countdown
				end
				bedwars.ClickHold.startClick = function(p4)
					p4.startedClickTime = tick()
					local u2 = p4:showProgress()
					local clicktime = p4.startedClickTime
					bedwars.RuntimeLib.Promise.defer(function()
						task.wait(p4.durationSeconds * (FastConsumeVal.Value / 40))
						if u2 == p4.handle and clicktime == p4.startedClickTime and p4.closeOnComplete then
							p4:hideProgress()
							if p4.onComplete ~= nil then
								p4.onComplete()
							end
							if p4.onPartialComplete ~= nil then
								p4.onPartialComplete(1)
							end
							p4.startedClickTime = -1
						end
					end)
				end
			else
				bedwars.ClickHold.startClick = oldclickhold
				bedwars.ClickHold.showProgress = oldclickhold2
				oldclickhold = nil
				oldclickhold2 = nil
			end
		end,
		HoverText = 'Use/Consume items quicker.'
	})
	FastConsumeVal = FastConsume.CreateSlider({
		Name = 'Ticks',
		Min = 0,
		Max = 40,
		Default = 0,
		Function = function() end
	})
end)

local autobankballoon = false
runFunction(function()
	local Fly = {}
	local FlyMode = {Value = 'CFrame'}
	local FlyVerticalSpeed = {Value = 40}
	local FlyVertical = {}
	local FlyAutoPop = {}
	local FlyAnyway = {}
	local FlyAnywayProgressBar = {}
	local FlyDamageAnimation = {}
	local FlyTP = {}
	local FlyAnywayProgressBarFrame
	local olddeflate
	local FlyUp = false
	local FlyDown = false
	local FlyCoroutine
	local groundtime = tick()
	local onground = false
	local lastonground = false
	local alternatelist = {'Normal', 'AntiCheat A', 'AntiCheat B'}

	local function inflateBalloon()
		if not Fly.Enabled then return end
		if entityLibrary.isAlive and (lplr.Character:GetAttribute('InflatedBalloons') or 0) < 1 then
			autobankballoon = true
			if getItem('balloon') then
				bedwars.BalloonController:inflateBalloon()
				return true
			end
		end
		return false
	end

	Fly = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = 'Fly',
		Function = function(calling)
			if calling then
				olddeflate = bedwars.BalloonController.deflateBalloon
				bedwars.BalloonController.deflateBalloon = function() end

				table.insert(Fly.Connections, inputService.InputBegan:Connect(function(input1)
					if FlyVertical.Enabled and inputService:GetFocusedTextBox() == nil then
						if input1.KeyCode == Enum.KeyCode.Space or input1.KeyCode == Enum.KeyCode.ButtonA then
							FlyUp = true
						end
						if input1.KeyCode == Enum.KeyCode.LeftShift or input1.KeyCode == Enum.KeyCode.ButtonL2 then
							FlyDown = true
						end
					end
				end))
				table.insert(Fly.Connections, inputService.InputEnded:Connect(function(input1)
					if input1.KeyCode == Enum.KeyCode.Space or input1.KeyCode == Enum.KeyCode.ButtonA then
						FlyUp = false
					end
					if input1.KeyCode == Enum.KeyCode.LeftShift or input1.KeyCode == Enum.KeyCode.ButtonL2 then
						FlyDown = false
					end
				end))
				if inputService.TouchEnabled then
					pcall(function()
						local jumpButton = lplr.PlayerGui.TouchGui.TouchControlFrame.JumpButton
						table.insert(Fly.Connections, jumpButton:GetPropertyChangedSignal('ImageRectOffset'):Connect(function()
							FlyUp = jumpButton.ImageRectOffset.X == 146
						end))
						FlyUp = jumpButton.ImageRectOffset.X == 146
					end)
				end
				table.insert(Fly.Connections, vapeEvents.BalloonPopped.Event:Connect(function(poppedTable)
					if poppedTable.inflatedBalloon and poppedTable.inflatedBalloon:GetAttribute('BalloonOwner') == lplr.UserId then 
						lastonground = not onground
						repeat task.wait() until (lplr.Character:GetAttribute('InflatedBalloons') or 0) <= 0 or not Fly.Enabled
						inflateBalloon() 
					end
				end))
				table.insert(Fly.Connections, vapeEvents.AutoBankBalloon.Event:Connect(function()
					repeat task.wait() until getItem('balloon')
					inflateBalloon()
				end))

				local balloons
				if entityLibrary.isAlive and (not bedwarsStore.queueType:find('mega')) then
					balloons = inflateBalloon()
				end
				local megacheck = bedwarsStore.queueType:find('mega') or bedwarsStore.queueType == 'winter_event'

				task.spawn(function()
					repeat task.wait() until bedwarsStore.queueType ~= 'bedwars_test' or (not Fly.Enabled)
					if not Fly.Enabled then return end
					megacheck = bedwarsStore.queueType:find('mega') or bedwarsStore.queueType == 'winter_event'
				end)

				local flyAllowed = entityLibrary.isAlive and ((lplr.Character:GetAttribute('InflatedBalloons') and lplr.Character:GetAttribute('InflatedBalloons') > 0) or bedwarsStore.matchState == 2 or megacheck) and 1 or 0
				if flyAllowed <= 0 and shared.damageanim and (not balloons) then 
					shared.damageanim()
					bedwars.SoundManager:playSound(bedwars.SoundList['DAMAGE_'..math.random(1, 3)])
				end

				if FlyAnywayProgressBarFrame and flyAllowed <= 0 and (not balloons) then 
					FlyAnywayProgressBarFrame.Visible = true
					FlyAnywayProgressBarFrame.Frame:TweenSize(UDim2.new(1, 0, 0, 20), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0, true)
				end

				groundtime = tick() + (2.6 + (entityLibrary.groundTick - tick()))
				FlyCoroutine = coroutine.create(function()
					repeat
						repeat task.wait() until (groundtime - tick()) < 0.6 and not onground
						flyAllowed = ((lplr.Character and lplr.Character:GetAttribute('InflatedBalloons') and lplr.Character:GetAttribute('InflatedBalloons') > 0) or bedwarsStore.matchState == 2 or megacheck) and 1 or 0
						if (not Fly.Enabled) then break end
						local Flytppos = -99999
						if flyAllowed <= 0 and FlyTP.Enabled and entityLibrary.isAlive then 
							local ray = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, Vector3.new(0, -1000, 0), bedwarsStore.blockRaycast)
							if ray then 
								Flytppos = entityLibrary.character.HumanoidRootPart.Position.Y
								local args = {entityLibrary.character.HumanoidRootPart.CFrame:GetComponents()}
								args[2] = ray.Position.Y + (entityLibrary.character.HumanoidRootPart.Size.Y / 2) + entityLibrary.character.Humanoid.HipHeight
								entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(unpack(args))
								task.wait(0.12)
								if (not Fly.Enabled) then break end
								flyAllowed = ((lplr.Character and lplr.Character:GetAttribute('InflatedBalloons') and lplr.Character:GetAttribute('InflatedBalloons') > 0) or bedwarsStore.matchState == 2 or megacheck) and 1 or 0
								if flyAllowed <= 0 and Flytppos ~= -99999 and entityLibrary.isAlive then 
									local args = {entityLibrary.character.HumanoidRootPart.CFrame:GetComponents()}
									args[2] = Flytppos
									entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(unpack(args))
								end
							end
						end
					until (not Fly.Enabled)
				end)
				coroutine.resume(FlyCoroutine)

				RunLoops:BindToHeartbeat('Fly', function(delta) 
					if GuiLibrary.ObjectsThatCanBeSaved['Lobby CheckToggle'].Api.Enabled then 
						if bedwars.matchState == 0 then return end
					end
					if entityLibrary.isAlive then
						local playerMass = (entityLibrary.character.HumanoidRootPart:GetMass() - 1.4) * (delta * 100)
						flyAllowed = ((lplr.Character:GetAttribute('InflatedBalloons') and lplr.Character:GetAttribute('InflatedBalloons') > 0) or bedwarsStore.matchState == 2 or megacheck) and 1 or 0
						playerMass = playerMass + (flyAllowed > 0 and 4 or 0) * (tick() % 0.4 < 0.2 and -1 or 1)

						if FlyAnywayProgressBarFrame then
							FlyAnywayProgressBarFrame.Visible = flyAllowed <= 0
							FlyAnywayProgressBarFrame.BackgroundColor3 = Color3.fromHSV(GuiLibrary.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Hue, GuiLibrary.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Sat, GuiLibrary.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Value)
							FlyAnywayProgressBarFrame.Frame.BackgroundColor3 = Color3.fromHSV(GuiLibrary.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Hue, GuiLibrary.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Sat, GuiLibrary.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Value)
						end

						if flyAllowed <= 0 then 
							local newray = getPlacedBlock(entityLibrary.character.HumanoidRootPart.Position + Vector3.new(0, (entityLibrary.character.Humanoid.HipHeight * -2) - 1, 0))
							onground = newray and true or false
							if lastonground ~= onground then 
								if (not onground) then 
									groundtime = tick() + (2.6 + (entityLibrary.groundTick - tick()))
									if FlyAnywayProgressBarFrame then 
										FlyAnywayProgressBarFrame.Frame:TweenSize(UDim2.new(0, 0, 0, 20), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, groundtime - tick(), true)
									end
								else
									if FlyAnywayProgressBarFrame then 
										FlyAnywayProgressBarFrame.Frame:TweenSize(UDim2.new(1, 0, 0, 20), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0, true)
									end
								end
							end
							if FlyAnywayProgressBarFrame then 
								FlyAnywayProgressBarFrame.TextLabel.Text = math.max(onground and 2.5 or math.floor((groundtime - tick()) * 10) / 10, 0)..'s'
							end
							lastonground = onground
						else
							onground = true
							lastonground = true
						end

						local flyVelocity = entityLibrary.character.Humanoid.MoveDirection * (FlyMode.Value == 'Normal' and FlySpeed.Value or 20)
						entityLibrary.character.HumanoidRootPart.Velocity = flyVelocity + (Vector3.new(0, playerMass + (FlyUp and FlyVerticalSpeed.Value or 0) + (FlyDown and -FlyVerticalSpeed.Value or 0), 0))
						if FlyMode.Value ~= 'Normal' then
							entityLibrary.character.HumanoidRootPart.CFrame = entityLibrary.character.HumanoidRootPart.CFrame + (entityLibrary.character.Humanoid.MoveDirection * ((FlySpeed.Value + getSpeed()) - 20)) * delta
						end
					end
				end)
			else
				pcall(function() coroutine.close(FlyCoroutine) end)
				autobankballoon = false
				waitingforballoon = false
				lastonground = nil
				FlyUp = false
				FlyDown = false
				RunLoops:UnbindFromHeartbeat('Fly')
				if FlyAnywayProgressBarFrame then 
					FlyAnywayProgressBarFrame.Visible = false
				end
				if FlyAutoPop.Enabled then
					if entityLibrary.isAlive and lplr.Character:GetAttribute('InflatedBalloons') then
						for i = 1, lplr.Character:GetAttribute('InflatedBalloons') do
							olddeflate()
						end
					end
				end
				bedwars.BalloonController.deflateBalloon = olddeflate
				olddeflate = nil
			end
		end,
		HoverText = 'Makes you go zoom (longer Fly discovered by exelys and Cqded)',
		ExtraText = function() 
			return 'Heatseeker'
		end
	})
	FlySpeed = Fly.CreateSlider({
		Name = 'Speed',
		Min = 1,
		Max = 23,
		Function = function(val) end, 
		Default = 23
	})
	FlyVerticalSpeed = Fly.CreateSlider({
		Name = 'Vertical Speed',
		Min = 1,
		Max = 100,
		Function = function(val) end, 
		Default = 44
	})
	FlyVertical = Fly.CreateToggle({
		Name = 'Y Level',
		Function = function() end, 
		Default = true
	})
	FlyAutoPop = Fly.CreateToggle({
		Name = 'Pop Balloon',
		Function = function() end, 
		HoverText = 'Pops balloons when Fly is disabled.'
	})
	local oldcamupdate
	local camcontrol
	local Flydamagecamera = {}
	FlyDamageAnimation = Fly.CreateToggle({
		Name = 'Damage Animation',
		Function = function(calling) 
			if Flydamagecamera.Object then 
				Flydamagecamera.Object.Visible = calling
			end
			if calling then 
				task.spawn(function()
					repeat
						task.wait(0.1)
						for i,v in next, (getconnections(gameCamera:GetPropertyChangedSignal('CameraType'))) do 
							if v.Function then
								camcontrol = debug.getupvalue(v.Function, 1)
							end
						end
					until camcontrol
					local caminput = require(lplr.PlayerScripts.PlayerModule.CameraModule.CameraInput)
					local num = Instance.new('IntValue')
					local numanim
					shared.damageanim = function()
						if numanim then numanim:Cancel() end
						if Flydamagecamera.Enabled then
							num.Value = 1000
							numanim = tweenService:Create(num, TweenInfo.new(0.5), {Value = 0})
							numanim:Play()
						end
					end
					oldcamupdate = camcontrol.Update
					camcontrol.Update = function(self, dt) 
						if camcontrol.activeCameraController then
							camcontrol.activeCameraController:UpdateMouseBehavior()
							local newCameraCFrame, newCameraFocus = camcontrol.activeCameraController:Update(dt)
							gameCamera.CFrame = newCameraCFrame * CFrame.Angles(0, 0, math.rad(num.Value / 100))
							gameCamera.Focus = newCameraFocus
							if camcontrol.activeTransparencyController then
								camcontrol.activeTransparencyController:Update(dt)
							end
							if caminput.getInputEnabled() then
								caminput.resetInputForFrameEnd()
							end
						end
					end
				end)
			else
				shared.damageanim = nil
				if camcontrol then 
					camcontrol.Update = oldcamupdate
				end
			end
		end
	})
	Flydamagecamera = Fly.CreateToggle({
		Name = 'Camera Animation',
		Function = function() end,
		Default = true
	})
	Flydamagecamera.Object.BorderSizePixel = 0
	Flydamagecamera.Object.BackgroundTransparency = 0
	Flydamagecamera.Object.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	Flydamagecamera.Object.Visible = false
	FlyAnywayProgressBar = Fly.CreateToggle({
		Name = 'Progress Bar',
		Function = function(calling) 
			if calling then 
				FlyAnywayProgressBarFrame = Instance.new('Frame')
				FlyAnywayProgressBarFrame.AnchorPoint = Vector2.new(0.5, 0)
				FlyAnywayProgressBarFrame.Position = UDim2.new(0.5, 0, 1, -200)
				FlyAnywayProgressBarFrame.Size = UDim2.new(0.2, 0, 0, 20)
				FlyAnywayProgressBarFrame.BackgroundTransparency = 0.5
				FlyAnywayProgressBarFrame.BorderSizePixel = 0
				FlyAnywayProgressBarFrame.BackgroundColor3 = Color3.new(0, 0, 0)
				FlyAnywayProgressBarFrame.Visible = Fly.Enabled
				FlyAnywayProgressBarFrame.Parent = GuiLibrary.MainGui
				local FlyAnywayProgressBarFrame2 = FlyAnywayProgressBarFrame:Clone()
				FlyAnywayProgressBarFrame2.AnchorPoint = Vector2.new(0, 0)
				FlyAnywayProgressBarFrame2.Position = UDim2.new(0, 0, 0, 0)
				FlyAnywayProgressBarFrame2.Size = UDim2.new(1, 0, 0, 20)
				FlyAnywayProgressBarFrame2.BackgroundTransparency = 0
				FlyAnywayProgressBarFrame2.Visible = true
				FlyAnywayProgressBarFrame2.Parent = FlyAnywayProgressBarFrame
				local FlyAnywayProgressBartext = Instance.new('TextLabel')
				FlyAnywayProgressBartext.Text = '2s'
				FlyAnywayProgressBartext.Font = Enum.Font.Gotham
				FlyAnywayProgressBartext.TextStrokeTransparency = 0
				FlyAnywayProgressBartext.TextColor3 =  Color3.new(0.9, 0.9, 0.9)
				FlyAnywayProgressBartext.TextSize = 20
				FlyAnywayProgressBartext.Size = UDim2.new(1, 0, 1, 0)
				FlyAnywayProgressBartext.BackgroundTransparency = 1
				FlyAnywayProgressBartext.Position = UDim2.new(0, 0, -1, 0)
				FlyAnywayProgressBartext.Parent = FlyAnywayProgressBarFrame
			else
				if FlyAnywayProgressBarFrame then FlyAnywayProgressBarFrame:Destroy() FlyAnywayProgressBarFrame = nil end
			end
		end,
		HoverText = 'show amount of Fly time',
		Default = true
	})
	FlyTP = Fly.CreateToggle({
		Name = 'TP Down',
		Function = function() end,
		Default = true
	})
end)

runFunction(function()
	local GrappleExploit = {}
	local GrappleExploitMode = {Value = 'Normal'}
	local GrappleExploitVerticalSpeed = {Value = 40}
	local GrappleExploitVertical = {}
	local GrappleExploitUp = false
	local GrappleExploitDown = false
	local alternatelist = {'Normal', 'AntiCheat A', 'AntiCheat B'}
	local projectileRemote = bedwars.ClientHandler:Get(bedwars.ProjectileRemote)

	--me when I have to fix bw code omegalol
	bedwars.ClientHandler:Get('GrapplingHookFunctions'):Connect(function(p4)
		if p4.hookFunction == 'PLAYER_IN_TRANSIT' then
			bedwars.CooldownController:setOnCooldown('grappling_hook', 3.5)
		end
	end)

	GrappleExploit = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = 'GrappleExploit',
		Function = function(calling)
			if calling then
				local grappleHooked = false
				table.insert(GrappleExploit.Connections, bedwars.ClientHandler:Get('GrapplingHookFunctions'):Connect(function(p4)
					if p4.hookFunction == 'PLAYER_IN_TRANSIT' then
						bedwarsStore.grapple = tick() + 1.8
						grappleHooked = true
						GrappleExploit.ToggleButton(false)
					end
				end))

				local fireball = getItem('grappling_hook')
				if fireball then 
					task.spawn(function()
						repeat task.wait() until bedwars.CooldownController:getRemainingCooldown('grappling_hook') == 0 or (not GrappleExploit.Enabled)
						if (not GrappleExploit.Enabled) then return end
						switchItem(fireball.tool)
						local pos = entityLibrary.character.HumanoidRootPart.CFrame.p
						local offsetshootpos = (CFrame.new(pos, pos + Vector3.new(0, -60, 0)) * CFrame.new(Vector3.new(-bedwars.BowConstantsTable.RelX, -bedwars.BowConstantsTable.RelY, -bedwars.BowConstantsTable.RelZ))).p
						projectileRemote:CallServerAsync(fireball['tool'], nil, 'grappling_hook_projectile', offsetshootpos, pos, Vector3.new(0, -60, 0), game:GetService('HttpService'):GenerateGUID(true), {drawDurationSeconds = 1}, workspace:GetServerTimeNow() - 0.045)
					end)
				else
					warningNotification('GrappleExploit', 'missing grapple hook', 3)
					GrappleExploit.ToggleButton(false)
					return
				end

				local startCFrame = entityLibrary.isAlive and entityLibrary.character.HumanoidRootPart.CFrame
				RunLoops:BindToHeartbeat('GrappleExploit', function(delta) 
					if GuiLibrary.ObjectsThatCanBeSaved['Lobby CheckToggle'].Api.Enabled then 
						if bedwars.matchState == 0 then return end
					end
					if entityLibrary.isAlive then
						entityLibrary.character.HumanoidRootPart.Velocity = Vector3.zero
						entityLibrary.character.HumanoidRootPart.CFrame = startCFrame
					end
				end)
			else
				GrappleExploitUp = false
				GrappleExploitDown = false
				RunLoops:UnbindFromHeartbeat('GrappleExploit')
			end
		end,
		HoverText = 'Makes you go zoom (longer GrappleExploit discovered by exelys and Cqded)',
		ExtraText = function() 
			if GuiLibrary.ObjectsThatCanBeSaved['Text GUIAlternate TextToggle']['Api'].Enabled then 
				return alternatelist[table.find(GrappleExploitMode['List'], GrappleExploitMode.Value)]
			end
			return GrappleExploitMode.Value 
		end
	})
end)

local vapeOriginalRoot
runFunction(function()
	local InfiniteFly = {}
	local InfiniteFlyMode = {Value = 'CFrame'}
	local InfiniteFlySpeed = {Value = 23}
	local InfiniteFlyVerticalSpeed = {Value = 40}
	local InfiniteFlyVertical = {}
	local InfiniteFlyUp = false
	local InfiniteFlyDown = false
	local alternatelist = {'Normal', 'AntiCheat A', 'AntiCheat B'}
	local clonesuccess = false
	local disabledproper = true
	local oldcloneroot
	local cloned
	local clone
	local bodyvelo
	local FlyOverlap = OverlapParams.new()
	FlyOverlap.MaxParts = 9e9
	FlyOverlap.FilterDescendantsInstances = {}
	FlyOverlap.RespectCanCollide = true

	local function disablefunc()
		if bodyvelo then bodyvelo:Destroy() end
		RunLoops:UnbindFromHeartbeat('InfiniteFlyOff')
		disabledproper = true
		if not oldcloneroot or not oldcloneroot.Parent then return end
		lplr.Character.Parent = game
		vapeOriginalRoot = nil
		oldcloneroot.Parent = lplr.Character
		lplr.Character.PrimaryPart = oldcloneroot
		lplr.Character.Parent = workspace
		oldcloneroot.CanCollide = true
		for i,v in next, (lplr.Character:GetDescendants()) do 
			pcall(function()
				if v:IsA('Weld') or v:IsA('Motor6D') then 
					if v.Part0 == clone then v.Part0 = oldcloneroot end
					if v.Part1 == clone then v.Part1 = oldcloneroot end
				end
				if v:IsA('BodyVelocity') then 
					v:Destroy()
				end 
			end)
		end
		for i,v in next, (oldcloneroot:GetChildren()) do 
			if v:IsA('BodyVelocity') then 
				pcall(function() v:Destroy() end)
			end
		end
		local oldclonepos = clone.Position.Y
		if clone then 
			clone:Destroy()
			bedwarsStore.infiniteflyclone = nil
			clone = nil
		end
		lplr.Character.Humanoid.HipHeight = hip or 2
		local origcf = {oldcloneroot.CFrame:GetComponents()}
		origcf[2] = oldclonepos
		oldcloneroot.CFrame = CFrame.new(unpack(origcf))
		oldcloneroot = nil
	end

	InfiniteFly = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = 'InfiniteFly',
		Function = function(calling)
			if calling then
				if not entityLibrary.isAlive then 
					disabledproper = true
				end
				if not disabledproper then 
					warningNotification('InfiniteFly', 'Wait for the last fly to finish', 3)
					InfiniteFly.ToggleButton(false)
					return 
				end
				table.insert(InfiniteFly.Connections, inputService.InputBegan:Connect(function(input1)
					if InfiniteFlyVertical.Enabled and inputService:GetFocusedTextBox() == nil then
						if input1.KeyCode == Enum.KeyCode.Space or input1.KeyCode == Enum.KeyCode.ButtonA then
							InfiniteFlyUp = true
						end
						if input1.KeyCode == Enum.KeyCode.LeftShift or input1.KeyCode == Enum.KeyCode.ButtonL2 then
							InfiniteFlyDown = true
						end
					end
				end))
				table.insert(InfiniteFly.Connections, inputService.InputEnded:Connect(function(input1)
					if input1.KeyCode == Enum.KeyCode.Space or input1.KeyCode == Enum.KeyCode.ButtonA then
						InfiniteFlyUp = false
					end
					if input1.KeyCode == Enum.KeyCode.LeftShift or input1.KeyCode == Enum.KeyCode.ButtonL2 then
						InfiniteFlyDown = false
					end
				end))
				if inputService.TouchEnabled then
					pcall(function()
						local jumpButton = lplr.PlayerGui.TouchGui.TouchControlFrame.JumpButton
						table.insert(InfiniteFly.Connections, jumpButton:GetPropertyChangedSignal('ImageRectOffset'):Connect(function()
							InfiniteFlyUp = jumpButton.ImageRectOffset.X == 146
						end))
						InfiniteFlyUp = jumpButton.ImageRectOffset.X == 146
					end)
				end
				clonesuccess = false
				if entityLibrary.isAlive and entityLibrary.character.Humanoid.Health > 0 and isnetworkowner(entityLibrary.character.HumanoidRootPart) then
					cloned = lplr.Character
					oldcloneroot = entityLibrary.character.HumanoidRootPart
					if not lplr.Character.Parent then 
						InfiniteFly.ToggleButton(false)
						return
					end
					lplr.Character.Parent = game
					clone = oldcloneroot:Clone()
					clone.Parent = lplr.Character
					oldcloneroot.Parent = gameCamera
					bedwars.QueryUtil:setQueryIgnored(oldcloneroot, true)
					clone.CFrame = oldcloneroot.CFrame
					lplr.Character.PrimaryPart = clone
					lplr.Character.Parent = workspace
					bedwarsStore.infiniteflyclone = clone
					for i,v in next, (lplr.Character:GetDescendants()) do 
						pcall(function()
							if v:IsA('Weld') or v:IsA('Motor6D') then 
								if v.Part0 == oldcloneroot then v.Part0 = clone end
								if v.Part1 == oldcloneroot then v.Part1 = clone end
							end
							if v:IsA('BodyVelocity') then 
								v:Destroy()
							end 
						end)
					end
					for i,v in next, (oldcloneroot:GetChildren()) do 
						if v:IsA('BodyVelocity') then 
							pcall(function() v:Destroy() end)
						end
					end
					if hip then 
						lplr.Character.Humanoid.HipHeight = hip
					end
					hip = lplr.Character.Humanoid.HipHeight
					clonesuccess = true
				end
				if not clonesuccess then 
					warningNotification('InfiniteFly', 'Character missing', 3)
					InfiniteFly.ToggleButton(false)
					return 
				end
				local goneup = false
				RunLoops:BindToHeartbeat('InfiniteFly', function(delta) 
					if GuiLibrary.ObjectsThatCanBeSaved['Lobby CheckToggle'].Api.Enabled then 
						if bedwarsStore.matchState == 0 then return end
					end
					if entityLibrary.isAlive then
						if isnetworkowner(oldcloneroot) then 
							local playerMass = (entityLibrary.character.HumanoidRootPart:GetMass() - 1.4) * (delta * 100)
							
							local flyVelocity = entityLibrary.character.Humanoid.MoveDirection * (InfiniteFlyMode.Value == 'Normal' and InfiniteFlySpeed.Value or 20)
							entityLibrary.character.HumanoidRootPart.Velocity = flyVelocity + (Vector3.new(0, playerMass + (InfiniteFlyUp and InfiniteFlyVerticalSpeed.Value or 0) + (InfiniteFlyDown and -InfiniteFlyVerticalSpeed.Value or 0), 0))
							if InfiniteFlyMode.Value ~= 'Normal' then
								entityLibrary.character.HumanoidRootPart.CFrame = entityLibrary.character.HumanoidRootPart.CFrame + (entityLibrary.character.Humanoid.MoveDirection * ((InfiniteFlySpeed.Value + getSpeed()) - 20)) * delta
							end

							local speedCFrame = {oldcloneroot.CFrame:GetComponents()}
							speedCFrame[1] = clone.CFrame.X
							if speedCFrame[2] < 1000 or (not goneup) then 
								task.spawn(InfoNotification, 'InfiniteFly', 'Teleported Up', 3)
								speedCFrame[2] = 100000
								goneup = true
							end
							speedCFrame[3] = clone.CFrame.Z
							oldcloneroot.CFrame = CFrame.new(unpack(speedCFrame))
							oldcloneroot.Velocity = Vector3.new(clone.Velocity.X, oldcloneroot.Velocity.Y, clone.Velocity.Z)
						else
							InfiniteFly.ToggleButton(false)
						end
					end
				end)
			else
				RunLoops:UnbindFromHeartbeat('InfiniteFly')
				if clonesuccess and oldcloneroot and clone and lplr.Character.Parent == workspace and oldcloneroot.Parent ~= nil and disabledproper and cloned == lplr.Character then 
					local rayparams = RaycastParams.new()
					rayparams.FilterDescendantsInstances = {lplr.Character, gameCamera}
					rayparams.RespectCanCollide = true
					local ray = workspace:Raycast(Vector3.new(oldcloneroot.Position.X, clone.CFrame.p.Y, oldcloneroot.Position.Z), Vector3.new(0, -1000, 0), rayparams)
					local origcf = {clone.CFrame:GetComponents()}
					local landpos = {oldcloneroot.Position.X, ray and ray.Position.Y + (entityLibrary.character.Humanoid.HipHeight + (oldcloneroot.Size.Y / 2)) or clone.CFrame.p.Y, oldcloneroot.Position.Z}
					origcf[1] = oldcloneroot.Position.X
					origcf[2] = ray and ray.Position.Y + (entityLibrary.character.Humanoid.HipHeight + (oldcloneroot.Size.Y / 2)) or clone.CFrame.p.Y
					origcf[3] = oldcloneroot.Position.Z
					oldcloneroot.CanCollide = true
					bodyvelo = Instance.new('BodyVelocity')
					bodyvelo.MaxForce = Vector3.new(0, 9e9, 0)
					bodyvelo.Velocity = Vector3.new(0, -1, 0)
					bodyvelo.Parent = oldcloneroot
					oldcloneroot.Velocity = Vector3.new(clone.Velocity.X, -1, clone.Velocity.Z)
					RunLoops:BindToHeartbeat('InfiniteFlyOff', function(dt)
						if oldcloneroot then 
							oldcloneroot.Velocity = Vector3.new(clone.Velocity.X, -1, clone.Velocity.Z)
							local bruh = {clone.CFrame:GetComponents()}
							bruh[2] = oldcloneroot.CFrame.Y
							local newcf = CFrame.new(unpack(bruh))
							FlyOverlap.FilterDescendantsInstances = {lplr.Character, gameCamera}
							local allowed = true
							for i,v in next, (workspace:GetPartBoundsInRadius(newcf.p, 2, FlyOverlap)) do 
								if (v.Position.Y + (v.Size.Y / 2)) > (newcf.p.Y + 0.5) then 
									allowed = false
									break
								end
							end
							if allowed then
								oldcloneroot.CFrame = newcf
							end
						end
					end)
					oldcloneroot.CFrame = CFrame.new(unpack(origcf))
					entityLibrary.character.Humanoid:ChangeState(Enum.HumanoidStateType.Landed)
					disabledproper = false
					if isnetworkowner(oldcloneroot) then 
						InfoNotification('InfiniteFly', 'Waiting 1.5s to not flag', 3)
						task.delay(1.5, disablefunc)
					else
						disablefunc()
					end
				end
				InfiniteFlyUp = false
				InfiniteFlyDown = false
			end
		end,
		HoverText = 'Makes you go zoom',
		ExtraText = function()
			return 'Heatseeker'
		end
	})
	InfiniteFlySpeed = InfiniteFly.CreateSlider({
		Name = 'Speed',
		Min = 1,
		Max = 23,
		Function = function(val) end, 
		Default = 23
	})
	InfiniteFlyVerticalSpeed = InfiniteFly.CreateSlider({
		Name = 'Vertical Speed',
		Min = 1,
		Max = 100,
		Function = function(val) end, 
		Default = 44
	})
	InfiniteFlyVertical = InfiniteFly.CreateToggle({
		Name = 'Y Level',
		Function = function() end, 
		Default = true
	})
end)

local killauraNearPlayer
runFunction(function()
	local killauraboxes = {}
    local killauratargetframe = {Players = {}}
	local killaurasortmethod = {Value = 'Distance'}
    local killaurarealremote = bedwars.ClientHandler:Get(bedwars.AttackRemote).instance
	local killaurauseitems = {}
	local killaurafacemode = {Value = 'Lunar'}
    local killauramethod = {Value = 'Normal'}
	local killauraothermethod = {Value = 'Normal'}
    local killauraanimmethod = {Value = 'Normal'}
    local killaurarange = {Value = 14}
    local killauraangle = {Value = 360}
    local killauratargets = {Value = 10}
	local killauraautoblock = {}
    local killauramouse = {}
    local killauracframe = {}
    local killauragui = {}
    local killauratarget = {}
    local killaurasound = {}
    local killauraswing = {}
	local killaurasync = {}
    local killaurahandcheck = {}
    local killauraanimation = {}
	local killauraanimationtween = {}
	local killauracolor = {Value = 0.44}
	local killauranovape = {}
	local killauranorender = {}
	local killauratargethighlight = {}
	local killaurarangecircle = {}
	local killauraparticlecolor = {Hue = 0, Sat = 0, Value = 0}
	local killaurarangecirclepart
	local killauraaimcircle = {}
	local killauraaimcirclepart
	local killauraparticle = {}
	local killauraparticlepart
    local Killauranear = false
    local killauraplaying = false
    local oldViewmodelAnimation = function() end
    local oldPlaySound = function() end
    local originalArmC0 = nil
	local killauracurrentanim
	local animationdelay = tick()

	local function getStrength(plr)
		local inv = bedwarsStore.inventories[plr.Player]
		local strength = 0
		local strongestsword = 0
		if inv then
			for i,v in next, (inv.items) do 
				local itemmeta = bedwars.ItemTable[v.itemType]
				if itemmeta and itemmeta.sword and itemmeta.sword.damage > strongestsword then 
					strongestsword = itemmeta.sword.damage / 100
				end	
			end
			strength = strength + strongestsword
			for i,v in next, (inv.armor) do 
				local itemmeta = bedwars.ItemTable[v.itemType]
				if itemmeta and itemmeta.armor then 
					strength = strength + (itemmeta.armor.damageReductionMultiplier or 0)
				end
			end
			strength = strength
		end
		return strength
	end

	local kitpriolist = {
		hannah = 5,
		spirit_assassin = 4,
		dasher = 3,
		jade = 2,
		regent = 1
	}

	local custominoutspeeds = {
		Future = 0.2,
		FasterSmooth = 0.2,
		Smooth = 0.2,
		BingChilling = 0.25
	}

	local killaurasortmethods = {
		Distance = function(a, b)
			return (a.RootPart.Position - entityLibrary.character.HumanoidRootPart.Position).Magnitude < (b.RootPart.Position - entityLibrary.character.HumanoidRootPart.Position).Magnitude
		end,
		Health = function(a, b) 
			return a.Player.Character:GetAttribute('Health') < b.Player.Character:GetAttribute('Health')
		end,
		Threat = function(a, b) 
			return getStrength(a) > getStrength(b)
		end,
		Kit = function(a, b)
			return (kitpriolist[a.Player:GetAttribute('PlayingAsKit')] or 0) > (kitpriolist[b.Player:GetAttribute('PlayingAsKit')] or 0)
		end,
		Switch = false -- :omegalol:
	}

	local originalNeckC0
	local originalRootC0
	local anims = {
		Normal = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.05},
			{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.05}
		},
		Slow = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.15},
			{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.15}
		},
		New = {
			{CFrame = CFrame.new(0.69, -0.77, 1.47) * CFrame.Angles(math.rad(-33), math.rad(57), math.rad(-81)), Time = 0.12},
			{CFrame = CFrame.new(0.74, -0.92, 0.88) * CFrame.Angles(math.rad(147), math.rad(71), math.rad(53)), Time = 0.12}
		},
		Latest = {
			{CFrame = CFrame.new(0.69, -0.7, 0.1) * CFrame.Angles(math.rad(-65), math.rad(55), math.rad(-51)), Time = 0.1},
			{CFrame = CFrame.new(0.16, -1.16, 0.5) * CFrame.Angles(math.rad(-179), math.rad(54), math.rad(33)), Time = 0.1}
		},
		['Vertical Spin'] = {
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-90), math.rad(8), math.rad(5)), Time = 0.1},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(180), math.rad(3), math.rad(13)), Time = 0.1},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(90), math.rad(-5), math.rad(8)), Time = 0.1},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(-0), math.rad(-0)), Time = 0.1}
		},
		Exhibition = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.1},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2}
		},
		['Exhibition Old'] = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.15},
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.05},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.1},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.05},
			{CFrame = CFrame.new(0.63, -0.1, 1.37) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.15}
		},
		Funny = {
			{CFrame = CFrame.new(0, 0, 1.5) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)),Time = 0.15},
			{CFrame = CFrame.new(0, 0, -1.5) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)),Time = 0.15},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.15},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-55), math.rad(0), math.rad(0)), Time = 0.15}
		},
		FunnyFuture = {
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-60), math.rad(0), math.rad(0)),Time = 0.25},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)),Time = 0.25}
		},
		Goofy = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.25},
			{CFrame = CFrame.new(-1, -1, 1) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)),Time = 0.25},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(-33)),Time = 0.25}
		},
		Future = {
			{CFrame = CFrame.new(0.69, -0.7, 0.10) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.20},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)),Time = 0.25}
		},
		Pop = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.15},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)),Time = 0.25},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-30), math.rad(80), math.rad(-90)), Time = 0.35},
			{CFrame = CFrame.new(0, 1, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.35}
		},
		FunnyV2 = {
			{CFrame = CFrame.new(0.10, -0.5, -1) * CFrame.Angles(math.rad(295), math.rad(80), math.rad(300)), Time = 0.45},
			{CFrame = CFrame.new(-5, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.45},
			{CFrame = CFrame.new(5, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.45},
		},
		Smooth = {
			{CFrame = CFrame.new(-0.42, 0, 0.30) * CFrame.Angles(math.rad(0), math.rad(80), math.rad(60)), Time = 0.25},
			{CFrame = CFrame.new(-0.42, 0, 0.30) * CFrame.Angles(math.rad(0), math.rad(100), math.rad(60)), Time = 0.25},
			{CFrame = CFrame.new(-0.42, 0, 0.30) * CFrame.Angles(math.rad(0), math.rad(60), math.rad(60)), Time = 0.25},
		},
		FasterSmooth = {
			{CFrame = CFrame.new(-0.42, 0, 0.30) * CFrame.Angles(math.rad(0), math.rad(80), math.rad(60)), Time = 0.11},
			{CFrame = CFrame.new(-0.42, 0, 0.30) * CFrame.Angles(math.rad(0), math.rad(100), math.rad(60)), Time = 0.11},
			{CFrame = CFrame.new(-0.42, 0, 0.30) * CFrame.Angles(math.rad(0), math.rad(60), math.rad(60)), Time = 0.11},
		},
		PopV2 = {
			{CFrame = CFrame.new(0.10, -0.3, -0.30) * CFrame.Angles(math.rad(295), math.rad(80), math.rad(290)), Time = 0.09},
			{CFrame = CFrame.new(0.10, 0.10, -1) * CFrame.Angles(math.rad(295), math.rad(80), math.rad(300)), Time = 0.1},
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.15},
		},
		Bob = {
			{CFrame = CFrame.new(-0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2},
			{CFrame = CFrame.new(-0.7, -2.5, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2}
		},
		Knife = {
			{CFrame = CFrame.new(-0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2},
			{CFrame = CFrame.new(1, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2},
			{CFrame = CFrame.new(4, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2},
		},
		FunnyExhibition = {
			{CFrame = CFrame.new(-1.5, -0.50, 0.20) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.10},
			{CFrame = CFrame.new(-0.55, -0.20, 1.5) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2},
		},
		Remake = {
			{CFrame = CFrame.new(-0.10, -0.45, -0.20) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-50)), Time = 0.01},
			{CFrame = CFrame.new(0.7, -0.71, -1) * CFrame.Angles(math.rad(-90), math.rad(50), math.rad(-38)), Time = 0.2},
			{CFrame = CFrame.new(0.63, -0.1, 1.50) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.15}
		},
		PopV3 = {
			{CFrame = CFrame.new(0.69, -0.10, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.1},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.1},
			{CFrame = CFrame.new(0.69, -2, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.1}
		},
		PopV4 = {
			{CFrame = CFrame.new(0.69, -0.10, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.01},
			{CFrame = CFrame.new(0.7, -0.30, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.01},
			{CFrame = CFrame.new(0.69, -2, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.01}
		},
		Shake = {
			{CFrame = CFrame.new(0.69, -0.8, 0.6) * CFrame.Angles(math.rad(-60), math.rad(30), math.rad(-35)), Time = 0.05},
			{CFrame = CFrame.new(0.8, -0.71, 0.30) * CFrame.Angles(math.rad(-60), math.rad(39), math.rad(-55)), Time = 0.02},
			{CFrame = CFrame.new(0.8, -2, 0.45) * CFrame.Angles(math.rad(-60), math.rad(30), math.rad(-55)), Time = 0.03}
		},
		Idk = {
			{CFrame = CFrame.new(0, -0.1, -0.30) * CFrame.Angles(math.rad(-20), math.rad(20), math.rad(0)), Time = 0.30},
			{CFrame = CFrame.new(0, -0.50, -0.30) * CFrame.Angles(math.rad(-40), math.rad(41), math.rad(0)), Time = 0.32},
			{CFrame = CFrame.new(0, -0.1, -0.30) * CFrame.Angles(math.rad(-60), math.rad(0), math.rad(0)), Time = 0.32}
		},
		Block = {
			{CFrame = CFrame.new(1, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(45), math.rad(0), math.rad(0)), Time = 0.2},
			{CFrame = CFrame.new(1, 0, 0) * CFrame.Angles(math.rad(-60), math.rad(0), math.rad(0)), Time = 0.2},
			{CFrame = CFrame.new(0.3, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2}
		},
		BingChilling = {
			{CFrame = CFrame.new(0.07, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.1},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2}
		},
		['Womp Womp'] = {
			{CFrame = CFrame.new(0.07, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(15), math.rad(-90)), Time = 0.1},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2}
		},
		['Yomp Yomp'] = {
			{CFrame = CFrame.new(0.07, -0.7, 0.6) * CFrame.Angles(math.rad(0), math.rad(15), math.rad(-20)), Time = 0.1},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2}
		},
		FunnyV3 = {
			{CFrame = CFrame.new(0.8, 10.7, 3.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.1},
            {CFrame = CFrame.new(5.7, -1.7, 5.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.15},
            {CFrame = CFrame.new(2.95, -5.06, -6.25) * CFrame.Angles(math.rad(-179), math.rad(61), math.rad(80)), Time = 0.15}
		},
		["Lunar Old"] = {
			{CFrame = CFrame.new(0.150, -0.8, 0.1) * CFrame.Angles(math.rad(-45), math.rad(40), math.rad(-75)), Time = 0.15},
			{CFrame = CFrame.new(0.02, -0.8, 0.05) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-95)), Time = 0.15}
		},
		["Lunar New"] = {
			{CFrame = CFrame.new(0.86, -0.8, 0.1) * CFrame.Angles(math.rad(-45), math.rad(40), math.rad(-75)), Time = 0.17},
			{CFrame = CFrame.new(0.73, -0.8, 0.05) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-95)), Time = 0.17}
		},
		["Lunar Fast"] = {
			{CFrame = CFrame.new(0.95, -0.8, 0.1) * CFrame.Angles(math.rad(-45), math.rad(40), math.rad(-75)), Time = 0.15},
			{CFrame = CFrame.new(0.40, -0.8, 0.05) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-95)), Time = 0.15}
		},
		["Liquid Bounce"] = {
			{CFrame = CFrame.new(-0.01, -0.3, -1.01) * CFrame.Angles(math.rad(-35), math.rad(90), math.rad(-90)), Time = 0.45},
    		{CFrame = CFrame.new(-0.01, -0.3, -1.01) * CFrame.Angles(math.rad(-35), math.rad(70), math.rad(-90)), Time = 0.45},
			{CFrame = CFrame.new(-0.01, -0.3, 0.4) * CFrame.Angles(math.rad(-35), math.rad(70), math.rad(-90)), Time = 0.32}
		},
		["Auto Block"] = {
			{CFrame = CFrame.new(-0.6, -0.2, 0.3) * CFrame.Angles(math.rad(0), math.rad(80), math.rad(65)), Time = 0.15},
			{CFrame = CFrame.new(-0.6, -0.2, 0.3) * CFrame.Angles(math.rad(0), math.rad(110), math.rad(65)), Time = 0.15},
			{CFrame = CFrame.new(-0.6, -0.2, 0.3) * CFrame.Angles(math.rad(0), math.rad(65), math.rad(65)), Time = 0.15}
		},
		Meteor = {
			{CFrame = CFrame.new(0.150, -0.8, 0.1) * CFrame.Angles(math.rad(-45), math.rad(40), math.rad(-75)), Time = 0.15},
			{CFrame = CFrame.new(0.02, -0.8, 0.05) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-95)), Time = 0.15}
		},
		Switch = {
			{CFrame = CFrame.new(0.69, -0.7, 0.1) * CFrame.Angles(math.rad(-65), math.rad(55), math.rad(-51)), Time = 0.1},
			{CFrame = CFrame.new(0.16, -1.16, 0.5) * CFrame.Angles(math.rad(-179), math.rad(54), math.rad(33)), Time = 0.1}
		},
		Sideways = {
			{CFrame = CFrame.new(5, -3, 2) * CFrame.Angles(math.rad(120), math.rad(160), math.rad(140)), Time = 0.12},
			{CFrame = CFrame.new(5, -2.5, -1) * CFrame.Angles(math.rad(80), math.rad(180), math.rad(180)), Time = 0.12},
			{CFrame = CFrame.new(5, -3.4, -3.3) * CFrame.Angles(math.rad(45), math.rad(160), math.rad(190)), Time = 0.12},
			{CFrame = CFrame.new(5, -2.5, -1) * CFrame.Angles(math.rad(80), math.rad(180), math.rad(180)), Time = 0.12}
		},
		Stand = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.1}
		}
	}

	local function closestpos(block, pos)
		local blockpos = block:GetRenderCFrame()
		local startpos = (blockpos * CFrame.new(-(block.Size / 2))).p
		local endpos = (blockpos * CFrame.new((block.Size / 2))).p
		local speedCFrame = block.Position + (pos - block.Position)
		local x = startpos.X > endpos.X and endpos.X or startpos.X
		local y = startpos.Y > endpos.Y and endpos.Y or startpos.Y
		local z = startpos.Z > endpos.Z and endpos.Z or startpos.Z
		local x2 = startpos.X < endpos.X and endpos.X or startpos.X
		local y2 = startpos.Y < endpos.Y and endpos.Y or startpos.Y
		local z2 = startpos.Z < endpos.Z and endpos.Z or startpos.Z
		return Vector3.new(math.clamp(speedCFrame.X, x, x2), math.clamp(speedCFrame.Y, y, y2), math.clamp(speedCFrame.Z, z, z2))
	end

	local function getAttackData()
		if GuiLibrary.ObjectsThatCanBeSaved['Lobby CheckToggle'].Api.Enabled then 
			if bedwarsStore.matchState == 0 then return false end
		end
		if killauramouse.Enabled then
			if not inputService:IsMouseButtonPressed(0) then return false end
		end
		if killauragui.Enabled then
			if getOpenApps() > (bedwarsStore.equippedKit == 'hannah' and 4 or 3) then return false end
		end
		local sword = killaurahandcheck.Enabled and bedwarsStore.localHand or getSword()
		if not sword or not sword.tool then return false end
		local swordmeta = bedwars.ItemTable[sword.tool.Name]
		if killaurahandcheck.Enabled then
			if bedwarsStore.localHand.Type ~= 'sword' or bedwars.KatanaController.chargingMaid then return false end
		end
		return sword, swordmeta
	end

	local function autoBlockLoop()
		if not killauraautoblock.Enabled or not Killaura.Enabled then return end
		repeat
			if bedwarsStore.blockPlace < tick() and entityLibrary.isAlive then
				local shield = getItem('infernal_shield')
				if shield then 
					switchItem(shield.tool)
					if not lplr.Character:GetAttribute('InfernalShieldRaised') then
						bedwars.InfernalShieldController:raiseShield()
					end
				end
			end
			task.wait()
		until (not Killaura.Enabled) or (not killauraautoblock.Enabled)
	end

    Killaura = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
        Name = 'Killaura',
        Function = function(calling)
            if calling then
				if killauraaimcirclepart then killauraaimcirclepart.Parent = gameCamera end
				if killaurarangecirclepart then killaurarangecirclepart.Parent = gameCamera end
				if killauraparticlepart then killauraparticlepart.Parent = gameCamera end
				task.spawn(function()
					repeat 
						if killauraNearPlayer and killaurauseitems.Enabled then 
							local saber = (getItem('infernal_saber') or {})
							local data = {
								HellBladeRelease = {
									args = {player = lplr, weapon = saber.tool, chargeTime = 1},
									item = 'infernal_saber'
								}
							}
							for remote, v in next, data do 
								task.spawn(function()
									if getItem(v.item) and not isEnabled('InfiniteFly') then
									   bedwars.ClientHandler:Get(remote):SendToServer(v.args)
									end
								end)
							end
						end
						task.wait()
					until not Killaura.Enabled
				end)
				task.spawn(function()
					local oldNearPlayer
					repeat
						task.wait()
						if killauraanimation.Enabled then
							if killauraNearPlayer then
								pcall(function()
									if originalArmC0 == nil then
										originalArmC0 = gameCamera.Viewmodel.RightHand.RightWrist.C0
									end
									if killauraplaying == false then
										killauraplaying = true
										for i,v in next, (anims[killauraanimmethod.Value]) do 
											if (not Killaura.Enabled) or (not killauraNearPlayer) then break end
											if not oldNearPlayer and killauraanimationtween.Enabled then
												gameCamera.Viewmodel.RightHand.RightWrist.C0 = originalArmC0 * v.CFrame
												continue
											end
											killauracurrentanim = tweenService:Create(gameCamera.Viewmodel.RightHand.RightWrist, TweenInfo.new(v.Time), {C0 = originalArmC0 * v.CFrame})
											killauracurrentanim:Play()
											task.wait(v.Time - 0.01)
										end
										killauraplaying = false
									end
								end)	
							end
							oldNearPlayer = killauraNearPlayer
						end
					until Killaura.Enabled == false
				end)

                oldViewmodelAnimation = bedwars.ViewmodelController.playAnimation
                oldPlaySound = bedwars.SoundManager.playSound
                bedwars.SoundManager.playSound = function(tab, soundid, ...)
                    if (soundid == bedwars.SoundList.SWORD_SWING_1 or soundid == bedwars.SoundList.SWORD_SWING_2) and Killaura.Enabled and killaurasound.Enabled and killauraNearPlayer then
                        return nil
                    end
                    return oldPlaySound(tab, soundid, ...)
                end
                bedwars.ViewmodelController.playAnimation = function(Self, id, ...)
                    if id == 15 and killauraNearPlayer and killauraswing.Enabled and entityLibrary.isAlive then
                        return nil
                    end
                    if id == 15 and killauraNearPlayer and killauraanimation.Enabled and entityLibrary.isAlive then
                        return nil
                    end
                    return oldViewmodelAnimation(Self, id, ...)
                end

				local targetedPlayer
				RunLoops:BindToHeartbeat('Killaura', function()
					for i,v in next, (killauraboxes) do 
						if v:IsA('BoxHandleAdornment') and v.Adornee then
							local cf = v.Adornee and v.Adornee.CFrame
							local onex, oney, onez = cf:ToEulerAnglesXYZ() 
							v.CFrame = CFrame.new() * CFrame.Angles(-onex, -oney, -onez)
						end
					end
					if entityLibrary.isAlive then
						if killauraaimcirclepart then 
							killauraaimcirclepart.Position = targetedPlayer and closestpos(targetedPlayer.RootPart, entityLibrary.character.HumanoidRootPart.Position) or Vector3.new(99999, 99999, 99999)
						end
						if killauraparticlepart then 
							killauraparticlepart.Position = targetedPlayer and targetedPlayer.RootPart.Position or Vector3.new(99999, 99999, 99999)
						end
						local Root = entityLibrary.character.HumanoidRootPart
						if Root then
							if killaurarangecirclepart then 
								killaurarangecirclepart.Position = Root.Position - Vector3.new(0, entityLibrary.character.Humanoid.HipHeight, 0)
							end
							local Neck = entityLibrary.character.Head:FindFirstChild('Neck')
							local LowerTorso = Root.Parent and Root.Parent:FindFirstChild('LowerTorso')
							local RootC0 = LowerTorso and LowerTorso:FindFirstChild('Root')
							if Neck and RootC0 then
								if originalNeckC0 == nil then
									originalNeckC0 = Neck.C0.p
								end
								if originalRootC0 == nil then
									originalRootC0 = RootC0.C0.p
								end
								if originalRootC0 and killauracframe.Enabled then
									if targetedPlayer ~= nil then
										if killaurafacemode.Value == 'Lunar' then
											local newcframe = targetedPlayer.RootPart.CFrame
											local newlookvector = lplr.Character.HumanoidRootPart.Position - newcframe.Position
											newlookvector = newlookvector / newlookvector.magnitude
											lplr.Character.HumanoidRootPart.CFrame = CFrame.lookAt(lplr.Character.HumanoidRootPart.CFrame.Position,newcframe.Position, newlookvector * (newlookvector * vec3(0, 1, 0)))
										else
											local targetPos = targetedPlayer.RootPart.Position + Vector3.new(0, 2, 0)
											local direction = (Vector3.new(targetPos.X, targetPos.Y, targetPos.Z) - entityLibrary.character.Head.Position).Unit
											local direction2 = (Vector3.new(targetPos.X, Root.Position.Y, targetPos.Z) - Root.Position).Unit
											local lookCFrame = (CFrame.new(Vector3.zero, (Root.CFrame):VectorToObjectSpace(direction)))
											local lookCFrame2 = (CFrame.new(Vector3.zero, (Root.CFrame):VectorToObjectSpace(direction2)))
											Neck.C0 = CFrame.new(originalNeckC0) * CFrame.Angles(lookCFrame.LookVector.Unit.y, 0, 0)
											RootC0.C0 = lookCFrame2 + originalRootC0
										end
									else
										if killaurafacemode.Value == 'Vape' then
											Neck.C0 = CFrame.new(originalNeckC0)
											RootC0.C0 = CFrame.new(originalRootC0)
										end
									end
								end
							end
						end
					end
				end)
				if killauraautoblock.Enabled then 
					task.spawn(autoBlockLoop)
				end
                task.spawn(function()
					repeat
						task.wait()
						if not Killaura.Enabled then break end
						vapeTargetInfo.Targets.Killaura = nil
						local plrs = AllNearPosition(killaurarange.Value, 10, killaurasortmethods[killaurasortmethod.Value], true)
						local firstPlayerNear
						if #plrs > 0 then
							local sword, swordmeta = getAttackData()
							if sword then
								task.spawn(switchItem, sword.tool)
								for i, plr in next, (plrs) do
									local root = plr.RootPart
									if not root then 
										continue
									end
									local localfacing = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
									local vec = (plr.RootPart.Position - entityLibrary.character.HumanoidRootPart.Position).unit
									local angle = math.acos(localfacing:Dot(vec))
									if angle >= (math.rad(killauraangle.Value) / 2) then
										continue
									end
									local selfrootpos = entityLibrary.character.HumanoidRootPart.Position
									if killauratargetframe.Walls.Enabled then
										if not bedwars.SwordController:canSee({player = plr.Player, getInstance = function() return plr.Character end}) then continue end
									end
									if not ({WhitelistFunctions:GetWhitelist(plr.Player)})[2] then
										continue
									end
									if not RenderFunctions:GetPlayerType(2, plr.Player) then 
										continue
									end
									if killauranovape.Enabled and bedwarsStore.whitelist.clientUsers[plr.Player.Name] then
										continue
									end
									if killauranorender.Enabled and table.find(RenderFunctions.configUsers, plr.Player) then
									   continue
									end
									if killaurasortmethod.Value == 'Switch' or not firstPlayerNear then 
										firstPlayerNear = true 
										killauraNearPlayer = true
										targetedPlayer = plr
										vapeTargetInfo.Targets.Killaura = {
											Humanoid = {
												Health = (plr.Character:GetAttribute('Health') or plr.Humanoid.Health) + getShieldAttribute(plr.Character),
												MaxHealth = plr.Character:GetAttribute('MaxHealth') or plr.Humanoid.MaxHealth
											},
											Player = plr.Player
										}
										RenderStore.UpdateTargetUI(vapeTargetInfo.Targets.Killaura)
										if animationdelay <= tick() then
											animationdelay = tick() + (swordmeta.sword.respectAttackSpeedForEffects and swordmeta.sword.attackSpeed or (killaurasync.Enabled and 0.24 or 0.14))
											if not killauraswing.Enabled then 
												bedwars.SwordController:playSwordEffect(swordmeta, false)
											end
											--[[if swordmeta.displayName:find('Scythe') then 
												bedwars.ScytheController:playLocalAnimation()
											end]]
										end
									end
									if (workspace:GetServerTimeNow() - bedwars.SwordController.lastAttack) < 0.02 then 
										break
									end
									local selfpos = selfrootpos + (killaurarange.Value > 14 and (selfrootpos - root.Position).magnitude > 14.4 and (CFrame.lookAt(selfrootpos, root.Position).lookVector * ((selfrootpos - root.Position).magnitude - 14)) or Vector3.zero)
									bedwars.SwordController.lastAttack = workspace:GetServerTimeNow()
									bedwarsStore.attackReach = math.floor((selfrootpos - root.Position).magnitude * 100) / 100
									bedwarsStore.attackReachUpdate = tick() + 1
									killaurarealremote:FireServer({
										weapon = sword.tool,
										chargedAttack = {chargeRatio = swordmeta.sword.chargedAttack and bedwarsStore.queueType ~= 'bridge_duel' and not swordmeta.sword.chargedAttack.disableOnGrounded and 0.999 or 0},
										entityInstance = plr.Character,
										validate = {
											raycast = {
												cameraPosition = attackValue(root.Position), 
												cursorDirection = attackValue(CFrame.new(selfpos, root.Position).lookVector)
											},
											targetPosition = attackValue(root.Position),
											selfPosition = attackValue(selfpos)
										}
									})
									if killaurasortmethod.Value ~= 'Switch' then 
										break 
									end
								end
							end
						end
						if not firstPlayerNear then 
							targetedPlayer = nil
							killauraNearPlayer = false
							pcall(function()
								if originalArmC0 == nil then
									originalArmC0 = gameCamera.Viewmodel.RightHand.RightWrist.C0
								end
								if gameCamera.Viewmodel.RightHand.RightWrist.C0 ~= originalArmC0 then
									pcall(function()
										killauracurrentanim:Cancel()
									end)
									if killauraanimationtween.Enabled then 
										gameCamera.Viewmodel.RightHand.RightWrist.C0 = originalArmC0
									else
										killauracurrentanim = tweenService:Create(gameCamera.Viewmodel.RightHand.RightWrist, TweenInfo.new(custominoutspeeds[killauraanimmethod.Value] or 0.1), {C0 = originalArmC0})
										killauracurrentanim:Play()
									end
								end
							end)
						end
						for i,v in next, (killauraboxes) do 
							local attacked = killauratarget.Enabled and plrs[i] or nil
							v.Adornee = attacked and ((not killauratargethighlight.Enabled) and attacked.RootPart or (not GuiLibrary.ObjectsThatCanBeSaved.ChamsOptionsButton.Api.Enabled) and attacked.Character or nil)
						end
					until (not Killaura.Enabled)
				end)
            else
				vapeTargetInfo.Targets.Killaura = nil
				RunLoops:UnbindFromHeartbeat('Killaura') 
                killauraNearPlayer = false
				for i,v in next, (killauraboxes) do v.Adornee = nil end
				if killauraaimcirclepart then killauraaimcirclepart.Parent = nil end
				if killaurarangecirclepart then killaurarangecirclepart.Parent = nil end
				if killauraparticlepart then killauraparticlepart.Parent = nil end
                bedwars.ViewmodelController.playAnimation = oldViewmodelAnimation
                bedwars.SoundManager.playSound = oldPlaySound
                oldViewmodelAnimation = nil
                pcall(function()
					if entityLibrary.isAlive then
						local Root = entityLibrary.character.HumanoidRootPart
						if Root then
							local Neck = Root.Parent.Head.Neck
							if originalNeckC0 and originalRootC0 then 
								Neck.C0 = CFrame.new(originalNeckC0)
								Root.Parent.LowerTorso.Root.C0 = CFrame.new(originalRootC0)
							end
						end
					end
                    if originalArmC0 == nil then
                        originalArmC0 = gameCamera.Viewmodel.RightHand.RightWrist.C0
                    end
                    if gameCamera.Viewmodel.RightHand.RightWrist.C0 ~= originalArmC0 then
						pcall(function()
							killauracurrentanim:Cancel()
						end)
						if killauraanimationtween.Enabled then 
							gameCamera.Viewmodel.RightHand.RightWrist.C0 = originalArmC0
						else
							killauracurrentanim = tweenService:Create(gameCamera.Viewmodel.RightHand.RightWrist, TweenInfo.new(0.1), {C0 = originalArmC0})
							killauracurrentanim:Play()
						end
                    end
                end)
            end
        end,
        HoverText = 'Attack players around you\nwithout aiming at them.'
    })
    killauratargetframe = Killaura.CreateTargetWindow({})
	local sortmethods = {'Distance'}
	for i,v in next, (killaurasortmethods) do if i ~= 'Distance' then table.insert(sortmethods, i) end end
	killaurasortmethod = Killaura.CreateDropdown({
		Name = 'Sort',
		Function = function() end,
		List = sortmethods
	})
	killaurafacemode = Killaura.CreateDropdown({
		Name = 	'Face Mode',
		List = {
			'Lunar',
			'Vape'
		},
		HoverText = 'Mode to face the opponent',
		Value = 'Lunar',
		Function = function() end
	})
    killaurarange = Killaura.CreateSlider({
        Name = 'Attack range',
        Min = 1,
        Max = 22,
        Function = function(val) 
			if killaurarangecirclepart then 
				killaurarangecirclepart.Size = Vector3.new(val * 0.7, 0.01, val * 0.7)
			end
		end, 
        Default = 22
    })
    killauraangle = Killaura.CreateSlider({
        Name = 'Max angle',
        Min = 1,
        Max = 360,
        Function = function(val) end,
        Default = 360
    })
	local animmethods = {}
	for i,v in next, (anims) do table.insert(animmethods, i) end
    killauraanimmethod = Killaura.CreateDropdown({
        Name = 'Animation', 
        List = animmethods,
        Function = function(val) end
    })
	local oldviewmodel
	local oldraise
	local oldeffect
	killauraautoblock = Killaura.CreateToggle({
		Name = 'AutoBlock',
		Function = function(calling)
			if calling then 
				oldviewmodel = bedwars.ViewmodelController.setHeldItem
				bedwars.ViewmodelController.setHeldItem = function(self, newItem, ...)
					if newItem and newItem.Name == 'infernal_shield' then 
						return
					end
					return oldviewmodel(self, newItem)
				end
				oldraise = bedwars.InfernalShieldController.raiseShield
				bedwars.InfernalShieldController.raiseShield = function(self)
					if os.clock() - self.lastShieldRaised < 0.4 then
						return
					end
					self.lastShieldRaised = os.clock()
					self.infernalShieldState:SendToServer({raised = true})
					self.raisedMaid:GiveTask(function()
						self.infernalShieldState:SendToServer({raised = false})
					end)
				end
				oldeffect = bedwars.InfernalShieldController.playEffect
				bedwars.InfernalShieldController.playEffect = function()
					return
				end
				if bedwars.ViewmodelController.heldItem and bedwars.ViewmodelController.heldItem.Name == 'infernal_shield' then 
					local sword, swordmeta = getSword()
					if sword then 
						bedwars.ViewmodelController:setHeldItem(sword.tool)
					end
				end
				task.spawn(autoBlockLoop)
			else
				bedwars.ViewmodelController.setHeldItem = oldviewmodel
				bedwars.InfernalShieldController.raiseShield = oldraise
				bedwars.InfernalShieldController.playEffect = oldeffect
			end
		end,
		Default = true
	})
    killauramouse = Killaura.CreateToggle({
        Name = 'Require mouse down',
        Function = function() end,
		HoverText = 'Only attacks when left click is held.',
        Default = false
    })
    killauragui = Killaura.CreateToggle({
        Name = 'GUI Check',
        Function = function() end,
		HoverText = 'Attacks when you are not in a GUI.'
    })
    killauratarget = Killaura.CreateToggle({
        Name = 'Show target',
        Function = function(calling) 
			if killauratargethighlight.Object then 
				killauratargethighlight.Object.Visible = calling
			end
		end,
		HoverText = 'Shows a red box over the opponent.'
    })
	killauratargethighlight = Killaura.CreateToggle({
		Name = 'Use New Highlight',
		Function = function(calling) 
			for i,v in next, (killauraboxes) do 
				v:Remove()
			end
			for i = 1, 10 do 
				local killaurabox
				if calling then 
					killaurabox = Instance.new('Highlight')
					killaurabox.FillTransparency = 0.39
					killaurabox.FillColor = Color3.fromHSV(killauracolor.Hue, killauracolor.Sat, killauracolor.Value)
					killaurabox.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					killaurabox.OutlineTransparency = 1
					killaurabox.Parent = GuiLibrary.MainGui
				else
					killaurabox = Instance.new('BoxHandleAdornment')
					killaurabox.Transparency = 0.39
					killaurabox.Color3 = Color3.fromHSV(killauracolor.Hue, killauracolor.Sat, killauracolor.Value)
					killaurabox.Adornee = nil
					killaurabox.AlwaysOnTop = true
					killaurabox.Size = Vector3.new(3, 6, 3)
					killaurabox.ZIndex = 11
					killaurabox.Parent = GuiLibrary.MainGui
				end
				killauraboxes[i] = killaurabox
			end
		end
	})
	killauratargethighlight.Object.BorderSizePixel = 0
	killauratargethighlight.Object.BackgroundTransparency = 0
	killauratargethighlight.Object.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	killauratargethighlight.Object.Visible = false
	killauracolor = Killaura.CreateColorSlider({
		Name = 'Target Color',
		Function = function(hue, sat, val) 
			for i,v in next, (killauraboxes) do 
				v[(killauratargethighlight.Enabled and 'FillColor' or 'Color3')] = Color3.fromHSV(hue, sat, val)
			end
			if killauraaimcirclepart then 
				killauraaimcirclepart.Color = Color3.fromHSV(hue, sat, val)
			end
			if killaurarangecirclepart then 
				killaurarangecirclepart.Color = Color3.fromHSV(hue, sat, val)
			end
		end,
		Default = 1
	})
	for i = 1, 10 do 
		local killaurabox = Instance.new('BoxHandleAdornment')
		killaurabox.Transparency = 0.5
		killaurabox.Color3 = Color3.fromHSV(killauracolor['Hue'], killauracolor['Sat'], killauracolor.Value)
		killaurabox.Adornee = nil
		killaurabox.AlwaysOnTop = true
		killaurabox.Size = Vector3.new(3, 6, 3)
		killaurabox.ZIndex = 11
		killaurabox.Parent = GuiLibrary.MainGui
		killauraboxes[i] = killaurabox
	end
    killauracframe = Killaura.CreateToggle({
        Name = 'Face target',
        Function = function() end,
		HoverText = 'Makes your character face the opponent.'
    })
	killaurarangecircle = Killaura.CreateToggle({
		Name = 'Range Visualizer',
		Function = function(calling)
			pcall(function() 
				if calling then 
					if Killaura.Enabled then 
						killaurarangecirclepart.Parent = gameCamera
					else 
						killaurarangecirclepart.Parent = game
					end
					killaurarangecirclepart = Instance.new('MeshPart')
					killaurarangecirclepart.MeshId = 'rbxassetid://3726303797'
					killaurarangecirclepart.Color = Color3.fromHSV(killauracolor['Hue'], killauracolor['Sat'], killauracolor.Value)
					killaurarangecirclepart.CanCollide = false
					killaurarangecirclepart.Anchored = true
					killaurarangecirclepart.Material = Enum.Material.Neon
					killaurarangecirclepart.Size = Vector3.new(killaurarange.Value * 0.7, 0.01, killaurarange.Value * 0.7)
					bedwars.QueryUtil:setQueryIgnored(killaurarangecirclepart, true)
				else
					if killaurarangecirclepart then 
						killaurarangecirclepart:Destroy()
						killaurarangecirclepart = nil
					end
				end 
			end)
		end
	})
	killauraaimcircle = Killaura.CreateToggle({
		Name = 'Aim Visualizer',
		Function = function(calling)
			if calling then 
				killauraaimcirclepart = Instance.new('Part')
				killauraaimcirclepart.Shape = Enum.PartType.Ball
				killauraaimcirclepart.Color = Color3.fromHSV(killauracolor['Hue'], killauracolor['Sat'], killauracolor.Value)
				killauraaimcirclepart.CanCollide = false
				killauraaimcirclepart.Anchored = true
				killauraaimcirclepart.Material = Enum.Material.Neon
				killauraaimcirclepart.Size = Vector3.new(0.5, 0.5, 0.5)
				if Killaura.Enabled then 
					killauraaimcirclepart.Parent = gameCamera
				end
				bedwars.QueryUtil:setQueryIgnored(killauraaimcirclepart, true)
			else
				if killauraaimcirclepart then 
					killauraaimcirclepart:Destroy()
					killauraaimcirclepart = nil
				end
			end
		end
	})
	killauraparticle = Killaura.CreateToggle({
		Name = 'Crit Particle',
		Function = function(calling)
			if calling then 
				killauraparticlepart = Instance.new('Part')
				killauraparticlepart.Transparency = 1
				killauraparticlepart.CanCollide = false
				killauraparticlepart.Anchored = true
				killauraparticlepart.Size = Vector3.new(3, 6, 3)
				killauraparticlepart.Parent = cam
				bedwars.QueryUtil:setQueryIgnored(killauraparticlepart, true)
				local particle = Instance.new('ParticleEmitter')
				particle.Lifetime = NumberRange.new(0.5)
				particle.Rate = 500
				particle.Speed = NumberRange.new(0)
				particle.RotSpeed = NumberRange.new(180)
				particle.Enabled = true
				particle.Size = NumberSequence.new(0.3)
				particle.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(67, 10, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 98, 255))})
				particle.Parent = killauraparticlepart
				task.spawn(function()
					repeat task.wait() until killauraparticlecolor.Object
					particle.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHSV(killauraparticlecolor.Hue, killauraparticlecolor.Sat, killauraparticlecolor.Value)), ColorSequenceKeypoint.new(1, Color3.fromHSV(killauraparticlecolor.Hue, killauraparticlecolor.Sat, killauraparticlecolor.Value))})
				end)
			else
				if killauraparticlepart then 
					killauraparticlepart:Destroy()
					killauraparticlepart = nil
				end
			end
		end
	})
	killauraparticlecolor = Killaura.CreateColorSlider({
		Name = 'Crit Particle Color',
		Function = function(h, s, v)
			pcall(function() killauraparticlepart.ParticleEmitter.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHSV(h, s, v)), ColorSequenceKeypoint.new(1, Color3.fromHSV(h, s, v))}) end)
		end
	})
    killaurasound = Killaura.CreateToggle({
        Name = 'No Swing Sound',
        Function = function() end,
		HoverText = 'Removes the swinging sound.'
    })
    killauraswing = Killaura.CreateToggle({
        Name = 'No Swing',
        Function = function() end,
		HoverText = 'Removes the swinging animation.'
    })
    killaurahandcheck = Killaura.CreateToggle({
        Name = 'Limit to items',
        Function = function() end,
		HoverText = 'Only attacks when your sword is held.'
    })
	killaurauseitems = Killaura.CreateToggle({
		Name = 'Abilities',
		HoverText = 'Abuses the abilities of items.',
		Default = true,
		Function = function() end
	})
    killauraanimation = Killaura.CreateToggle({
        Name = 'Custom Animation',
        Function = function(calling)
			if killauraanimationtween.Object then killauraanimationtween.Object.Visible = calling end
		end,
		HoverText = 'Uses a custom animation for swinging'
    })
	killauraanimationtween = Killaura.CreateToggle({
		Name = 'No Tween',
		Function = function() end,
		HoverText = 'Disable\'s the in and out ease'
	})
	killauraanimationtween.Object.Visible = false
	killaurasync = Killaura.CreateToggle({
        Name = 'Synced Animation',
        Function = function() end,
		HoverText = 'Times animation with hit attempt'
    })
	killauranovape = Killaura.CreateToggle({
		Name = 'No Vape',
		Function = function() end,
		HoverText = 'no hit vape user'
	})
	killauranorender = Killaura.CreateToggle({
		Name = 'Ignore render',
		Function = function() if Killaura.Enabled then Killaura.ToggleButton(false) Killaura.ToggleButton(false) end end,
		HoverText = 'ignores render users under your rank.\n(they can\'t attack you back :omegalol:)'
	})
	killauranovape.Object.Visible = false
	killauranorender.Object.Visible = false
	task.spawn(function()
		repeat task.wait() until WhitelistFunctions.Loaded
		killauranovape.Object.Visible = WhitelistFunctions.LocalPriority ~= 0
	end)
	task.spawn(function()
		repeat task.wait() until RenderFunctions.WhitelistLoaded
		killauranorender.Object.Visible = RenderFunctions:GetPlayerType(3, plr.Player) > 1.5
	end)
end)

local LongJump = {}
runFunction(function()
	local damagetimer = 0
	local damagetimertick = 0
	local directionvec
	local LongJumpSpeed = {Value = 1.5}
	local projectileRemote = bedwars.ClientHandler:Get(bedwars.ProjectileRemote)

	local function calculatepos(vec)
		local returned = vec
		if entityLibrary.isAlive then 
			local newray = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, returned, bedwarsStore.blockRaycast)
			if newray then returned = (newray.Position - entityLibrary.character.HumanoidRootPart.Position) end
		end
		return returned
	end

	local damagemethods = {
		fireball = function(fireball, pos)
			if not LongJump.Enabled then return end
			pos = pos - (entityLibrary.character.HumanoidRootPart.CFrame.lookVector * 0.2)
			if not (getPlacedBlock(pos - Vector3.new(0, 3, 0)) or getPlacedBlock(pos - Vector3.new(0, 6, 0))) then
				local sound = Instance.new('Sound')
				sound.SoundId = 'rbxassetid://4809574295'
				sound.Parent = workspace
				sound.Ended:Connect(function()
					sound:Destroy()
				end)
				sound:Play()
			end
			local origpos = pos
			local offsetshootpos = (CFrame.new(pos, pos + Vector3.new(0, -60, 0)) * CFrame.new(Vector3.new(-bedwars.BowConstantsTable.RelX, -bedwars.BowConstantsTable.RelY, -bedwars.BowConstantsTable.RelZ))).p
			local ray = workspace:Raycast(pos, Vector3.new(0, -30, 0), bedwarsStore.blockRaycast)
			if ray then
				pos = ray.Position
				offsetshootpos = pos
			end
			task.spawn(function()
				bedwarsStore.switchdelay = tick() + 1.2
				task.spawn(function()
					local delay = tick() + 0.35
					repeat 
						switchItem(fireball.tool)
						task.wait(0.1)
					until tick() > delay
				end)
				task.wait()
				bedwars.ProjectileController:createLocalProjectile(bedwars.ProjectileMeta.fireball, 'fireball', 'fireball', offsetshootpos, '', Vector3.new(0, -60, 0), {drawDurationSeconds = 1})
				projectileRemote:CallServerAsync(fireball.tool, 'fireball', 'fireball', offsetshootpos, pos, Vector3.new(0, -60, 0), game:GetService('HttpService'):GenerateGUID(true), {drawDurationSeconds = 1}, workspace:GetServerTimeNow() - 0.045, 'fireball')
			end)
		end,
		tnt = function(tnt, pos2)
			if not LongJump.Enabled then return end
			local pos = Vector3.new(pos2.X, getScaffold(Vector3.new(0, pos2.Y - (((entityLibrary.character.HumanoidRootPart.Size.Y / 2) + entityLibrary.character.Humanoid.HipHeight) - 1.5), 0)).Y, pos2.Z)
			local block = bedwars.placeBlock(pos, 'tnt')
		end,
		cannon = function(tnt, pos2)
			task.spawn(function()
				local pos = Vector3.new(pos2.X, getScaffold(Vector3.new(0, pos2.Y - (((entityLibrary.character.HumanoidRootPart.Size.Y / 2) + entityLibrary.character.Humanoid.HipHeight) - 1.5), 0)).Y, pos2.Z)
				local block = bedwars.placeBlock(pos, 'cannon')
				task.delay(0.1, function()
					local block, pos2 = getPlacedBlock(pos)
					if block and block.Name == 'cannon' and (entityLibrary.character.HumanoidRootPart.CFrame.p - block.Position).Magnitude < 20 then 
						switchToAndUseTool(block)
						local vec = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
						local damage = bedwars.BlockController:calculateBlockDamage(lplr, {
							blockPosition = pos2
						})
						bedwars.ClientHandler:Get(bedwars.CannonAimRemote):SendToServer({
							cannonBlockPos = pos2,
							lookVector = vec
						})
						local broken = 0.1
						if damage < block:GetAttribute('Health') then 
							task.spawn(function()
								broken = 0.4
								bedwars.breakBlock(block.Position, true, getBestBreakSide(block.Position), true, true)
							end)
						end
						task.delay(broken, function()
							for i = 1, 3 do 
								local call = bedwars.ClientHandler:Get(bedwars.CannonLaunchRemote):CallServer({cannonBlockPos = bedwars.BlockController:getBlockPosition(block.Position)})
								if call then
									bedwars.breakBlock(block.Position, true, getBestBreakSide(block.Position), true, true)
									task.delay(0.1, function()
										damagetimer = LongJumpSpeed.Value * 5
										damagetimertick = tick() + 2.5
										directionvec = Vector3.new(vec.X, 0, vec.Z).Unit
									end)
									break
								end
								task.wait(0.1)
							end
						end)
					end
				end)	
			end)
		end,
		wood_dao = function(tnt, pos2)
			task.spawn(function()
				bedwarsStore.switchdelay = tick() + 2.6
				for i = 1, 5 do 
					switchItem(tnt.tool) 
				end
				if not (not lplr.Character:GetAttribute('CanDashNext') or lplr.Character:GetAttribute('CanDashNext') < workspace:GetServerTimeNow()) then
					repeat task.wait() until (not lplr.Character:GetAttribute('CanDashNext') or lplr.Character:GetAttribute('CanDashNext') < workspace:GetServerTimeNow()) or not LongJump.Enabled
				end
				if LongJump.Enabled then
					local vec = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
					replicatedStorageService['events-@easy-games/game-core:shared/game-core-networking@getEvents.Events'].useAbility:FireServer('dash', {
						direction = vec,
						origin = entityLibrary.character.HumanoidRootPart.CFrame.p,
						weapon = tnt.itemType
					})
					damagetimer = LongJumpSpeed.Value * 3.5
					damagetimertick = tick() + 2.5
					directionvec = Vector3.new(vec.X, 0, vec.Z).Unit
				end
			end)
		end,
		jade_hammer = function(tnt, pos2)
			task.spawn(function()
				if not bedwars.AbilityController:canUseAbility('jade_hammer_jump') then
					repeat task.wait() until bedwars.AbilityController:canUseAbility('jade_hammer_jump') or not LongJump.Enabled
					task.wait(0.1)
				end
				if bedwars.AbilityController:canUseAbility('jade_hammer_jump') and LongJump.Enabled then
					bedwars.AbilityController:useAbility('jade_hammer_jump')
					local vec = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
					damagetimer = LongJumpSpeed.Value * 2.75
					damagetimertick = tick() + 2.5
					directionvec = Vector3.new(vec.X, 0, vec.Z).Unit
				end
			end)
		end,
		void_axe = function(tnt, pos2)
			task.spawn(function()
				if not bedwars.AbilityController:canUseAbility('void_axe_jump') then
					repeat task.wait() until bedwars.AbilityController:canUseAbility('void_axe_jump') or not LongJump.Enabled
					task.wait(0.1)
				end
				if bedwars.AbilityController:canUseAbility('void_axe_jump') and LongJump.Enabled then
					bedwars.AbilityController:useAbility('void_axe_jump')
					local vec = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
					damagetimer = LongJumpSpeed.Value * 2.75
					damagetimertick = tick() + 2.5
					directionvec = Vector3.new(vec.X, 0, vec.Z).Unit
				end
			end)
		end
	}
	damagemethods.stone_dao = damagemethods.wood_dao
	damagemethods.iron_dao = damagemethods.wood_dao
	damagemethods.diamond_dao = damagemethods.wood_dao
	damagemethods.emerald_dao = damagemethods.wood_dao

	local oldgrav
	local LongJumpacprogressbarframe = Instance.new('Frame')
	LongJumpacprogressbarframe.AnchorPoint = Vector2.new(0.5, 0)
	LongJumpacprogressbarframe.Position = UDim2.new(0.5, 0, 1, -200)
	LongJumpacprogressbarframe.Size = UDim2.new(0.2, 0, 0, 20)
	LongJumpacprogressbarframe.BackgroundTransparency = 0.5
	LongJumpacprogressbarframe.BorderSizePixel = 0
	LongJumpacprogressbarframe.BackgroundColor3 = Color3.fromHSV(GuiLibrary.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Hue, GuiLibrary.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Sat, GuiLibrary.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Value)
	LongJumpacprogressbarframe.Visible = LongJump.Enabled
	LongJumpacprogressbarframe.Parent = GuiLibrary.MainGui
	local LongJumpacprogressbarframe2 = LongJumpacprogressbarframe:Clone()
	LongJumpacprogressbarframe2.AnchorPoint = Vector2.new(0, 0)
	LongJumpacprogressbarframe2.Position = UDim2.new(0, 0, 0, 0)
	LongJumpacprogressbarframe2.Size = UDim2.new(1, 0, 0, 20)
	LongJumpacprogressbarframe2.BackgroundTransparency = 0
	LongJumpacprogressbarframe2.Visible = true
	LongJumpacprogressbarframe2.BackgroundColor3 = Color3.fromHSV(GuiLibrary.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Hue, GuiLibrary.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Sat, GuiLibrary.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Value)
	LongJumpacprogressbarframe2.Parent = LongJumpacprogressbarframe
	local LongJumpacprogressbartext = Instance.new('TextLabel')
	LongJumpacprogressbartext.Text = '2.5s'
	LongJumpacprogressbartext.Font = Enum.Font.Gotham
	LongJumpacprogressbartext.TextStrokeTransparency = 0
	LongJumpacprogressbartext.TextColor3 =  Color3.new(0.9, 0.9, 0.9)
	LongJumpacprogressbartext.TextSize = 20
	LongJumpacprogressbartext.Size = UDim2.new(1, 0, 1, 0)
	LongJumpacprogressbartext.BackgroundTransparency = 1
	LongJumpacprogressbartext.Position = UDim2.new(0, 0, -1, 0)
	LongJumpacprogressbartext.Parent = LongJumpacprogressbarframe
	LongJump = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = 'LongJump',
		Function = function(calling)
			if calling then
				table.insert(LongJump.Connections, vapeEvents.EntityDamageEvent.Event:Connect(function(damageTable)
					if damageTable.entityInstance == lplr.Character and (not damageTable.knockbackMultiplier or not damageTable.knockbackMultiplier.disabled) then 
						local knockbackBoost = damageTable.knockbackMultiplier and damageTable.knockbackMultiplier.horizontal and damageTable.knockbackMultiplier.horizontal * LongJumpSpeed.Value or LongJumpSpeed.Value
						if damagetimertick < tick() or knockbackBoost >= damagetimer then
							damagetimer = knockbackBoost
							damagetimertick = tick() + 2.5
							local newDirection = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
							directionvec = Vector3.new(newDirection.X, 0, newDirection.Z).Unit
						end
					end
				end))
				task.spawn(function()
					task.spawn(function()
						repeat
							task.wait()
							if LongJumpacprogressbarframe then
								LongJumpacprogressbarframe.BackgroundColor3 = Color3.fromHSV(GuiLibrary.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Hue, GuiLibrary.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Sat, GuiLibrary.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Value)
								LongJumpacprogressbarframe2.BackgroundColor3 = Color3.fromHSV(GuiLibrary.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Hue, GuiLibrary.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Sat, GuiLibrary.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Value)
							end
						until (not LongJump.Enabled)
					end)
					local LongJumpOrigin = entityLibrary.isAlive and entityLibrary.character.HumanoidRootPart.Position
					local tntcheck
					for i,v in next, (damagemethods) do 
						local item = getItem(i)
						if item then
							if i == 'tnt' then 
								local pos = getScaffold(LongJumpOrigin)
								tntcheck = Vector3.new(pos.X, LongJumpOrigin.Y, pos.Z)
								v(item, pos)
							else
								v(item, LongJumpOrigin)
							end
							break
						end
					end
					local changecheck
					LongJumpacprogressbarframe.Visible = true
					RunLoops:BindToHeartbeat('LongJump', function(dt)
						if entityLibrary.isAlive then 
							if entityLibrary.character.Humanoid.Health <= 0 then 
								LongJump.ToggleButton(false)
								return
							end
							if not LongJumpOrigin then 
								LongJumpOrigin = entityLibrary.character.HumanoidRootPart.Position
							end
							local newval = damagetimer ~= 0
							if changecheck ~= newval then 
								if newval then 
									LongJumpacprogressbarframe2:TweenSize(UDim2.new(0, 0, 0, 20), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 2.5, true)
								else
									LongJumpacprogressbarframe2:TweenSize(UDim2.new(1, 0, 0, 20), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0, true)
								end
								changecheck = newval
							end
							if newval then 
								local newnum = math.max(math.floor((damagetimertick - tick()) * 10) / 10, 0)
								if LongJumpacprogressbartext then 
									LongJumpacprogressbartext.Text = newnum..'s'
								end
								if directionvec == nil then 
									directionvec = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
								end
								local longJumpCFrame = Vector3.new(directionvec.X, 0, directionvec.Z)
								local newvelo = longJumpCFrame.Unit == longJumpCFrame.Unit and longJumpCFrame.Unit * (newnum > 1 and damagetimer or 20) or Vector3.zero
								newvelo = Vector3.new(newvelo.X, 0, newvelo.Z)
								longJumpCFrame = longJumpCFrame * (getSpeed() + 3) * dt
								local ray = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, longJumpCFrame, bedwarsStore.blockRaycast)
								if ray then 
									longJumpCFrame = Vector3.zero
									newvelo = Vector3.zero
								end
								lplr.Character.HumanoidRootPart.CFrame = (lplr.Character.HumanoidRootPart.CFrame + Vector3.new(0, 0.2, 0))
								entityLibrary.character.HumanoidRootPart.Velocity = newvelo
								entityLibrary.character.HumanoidRootPart.CFrame = entityLibrary.character.HumanoidRootPart.CFrame + longJumpCFrame
							else
								LongJumpacprogressbartext.Text = '2.5s'
								entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(LongJumpOrigin, LongJumpOrigin + entityLibrary.character.HumanoidRootPart.CFrame.lookVector)
								entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
								if tntcheck then 
									entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(tntcheck + entityLibrary.character.HumanoidRootPart.CFrame.lookVector, tntcheck + (entityLibrary.character.HumanoidRootPart.CFrame.lookVector * 2))
								end
							end
						else
							if LongJumpacprogressbartext then 
								LongJumpacprogressbartext.Text = '2.5s'
							end
							LongJumpOrigin = nil
							tntcheck = nil
						end
					end)
				end)
			else
				LongJumpacprogressbarframe.Visible = false
				RunLoops:UnbindFromHeartbeat('LongJump')
				directionvec = nil
				tntcheck = nil
				LongJumpOrigin = nil
				damagetimer = 0
				damagetimertick = 0
			end
		end, 
		HoverText = 'Lets you jump farther (Not landing on same level & Spamming can lead to lagbacks)'
	})
	LongJumpSpeed = LongJump.CreateSlider({
		Name = 'Speed',
		Min = 1,
		Max = 52,
		Function = function() end,
		Default = 52
	})
end)

runFunction(function()
	local NoFall = {}
	local oldfall
	NoFall = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = 'NoFall',
		Function = function(calling)
			if calling then
				task.spawn(function()
					repeat
						task.wait(0.5)
						bedwars.ClientHandler:Get('GroundHit'):SendToServer()
					until (not NoFall.Enabled)
				end)
			end
		end, 
		HoverText = 'Prevents taking fall damage.'
	})
end)

runFunction(function()
	local NoSlowdown = {}
	local OldSetSpeedFunc
	NoSlowdown = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = 'NoSlowdown',
		Function = function(calling)
			if calling then
				OldSetSpeedFunc = bedwars.SprintController.setSpeed
				bedwars.SprintController.setSpeed = function(tab1, val1)
					local hum = entityLibrary.character.Humanoid
					if hum then
						hum.WalkSpeed = math.max(20 * tab1.moveSpeedMultiplier, 20)
					end
				end
				bedwars.SprintController:setSpeed(20)
			else
				bedwars.SprintController.setSpeed = OldSetSpeedFunc
				bedwars.SprintController:setSpeed(20)
				OldSetSpeedFunc = nil
			end
		end, 
		HoverText = 'Prevents slowing down when using items.'
	})
end)

local spiderActive = false
local holdingshift = false
runFunction(function()
	local activatePhase = false
	local oldActivatePhase = false
	local PhaseDelay = tick()
	local Phase = {}
	local PhaseStudLimit = {Value = 1}
	local PhaseModifiedParts = {}
	local raycastparameters = RaycastParams.new()
	raycastparameters.RespectCanCollide = true
	raycastparameters.FilterType = Enum.RaycastFilterType.Whitelist
	local overlapparams = OverlapParams.new()
	overlapparams.RespectCanCollide = true

	local function isPointInMapOccupied(p)
		overlapparams.FilterDescendantsInstances = {lplr.Character, gameCamera}
		local possible = workspace:GetPartBoundsInBox(CFrame.new(p), Vector3.new(1, 2, 1), overlapparams)
		return (#possible == 0)
	end

	Phase = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = 'Phase',
		Function = function(calling)
			if calling then
				RunLoops:BindToHeartbeat('Phase', function()
					if entityLibrary.isAlive and entityLibrary.character.Humanoid.MoveDirection ~= Vector3.zero and (not GuiLibrary.ObjectsThatCanBeSaved.SpiderOptionsButton.Api.Enabled or holdingshift) then
						if PhaseDelay <= tick() then
							raycastparameters.FilterDescendantsInstances = {bedwarsStore.blocks, collectionService:GetTagged('spawn-cage'), workspace.SpectatorPlatform}
							local PhaseRayCheck = workspace:Raycast(entityLibrary.character.Head.CFrame.p, entityLibrary.character.Humanoid.MoveDirection * 1.15, raycastparameters)
							if PhaseRayCheck then
								local PhaseDirection = (PhaseRayCheck.Normal.Z ~= 0 or not PhaseRayCheck.Instance:GetAttribute('GreedyBlock')) and 'Z' or 'X'
								if PhaseRayCheck.Instance.Size[PhaseDirection] <= PhaseStudLimit.Value * 3 and PhaseRayCheck.Instance.CanCollide and PhaseRayCheck.Normal.Y == 0 then
									local PhaseDestination = entityLibrary.character.HumanoidRootPart.CFrame + (PhaseRayCheck.Normal * (-(PhaseRayCheck.Instance.Size[PhaseDirection]) - (entityLibrary.character.HumanoidRootPart.Size.X / 1.5)))
									if isPointInMapOccupied(PhaseDestination.p) then
										PhaseDelay = tick() + 1
										entityLibrary.character.HumanoidRootPart.CFrame = PhaseDestination
									end
								end
							end
						end
					end
				end)
			else
				RunLoops:UnbindFromHeartbeat('Phase')
			end
		end,
		HoverText = 'Lets you Phase/Clip through walls. (Hold shift to use Phase over spider)'
	})
	PhaseStudLimit = Phase.CreateSlider({
		Name = 'Blocks',
		Min = 1,
		Max = 3,
		Function = function() end
	})
end)

runFunction(function()
	local oldCalculateAim
	local BowAimbotProjectiles = {}
	local BowAimbotPart = {Value = 'HumanoidRootPart'}
	local BowAimbotFOV = {Value = 1000}
	local BowAimbot = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = 'ProjectileAimbot',
		Function = function(calling)
			if calling then
				oldCalculateAim = bedwars.ProjectileController.calculateImportantLaunchValues
				bedwars.ProjectileController.calculateImportantLaunchValues = function(self, projmeta, worldmeta, shootpospart, ...)
					local plr = EntityNearMouse(BowAimbotFOV.Value)
					if plr then
						local startPos = self:getLaunchPosition(shootpospart)
						if not startPos then
							return oldCalculateAim(self, projmeta, worldmeta, shootpospart, ...)
						end

						if (not BowAimbotProjectiles.Enabled) and projmeta.projectile:find('arrow') == nil then
							return oldCalculateAim(self, projmeta, worldmeta, shootpospart, ...)
						end

						local projmetatab = projmeta:getProjectileMeta()
						local projectilePrediction = (worldmeta and projmetatab.predictionLifetimeSec or projmetatab.lifetimeSec or 3)
						local projectileSpeed = (projmetatab.launchVelocity or 100)
						local gravity = (projmetatab.gravitationalAcceleration or 196.2)
						local projectileGravity = gravity * projmeta.gravityMultiplier
						local offsetStartPos = startPos + projmeta.fromPositionOffset
						local pos = plr.Character[BowAimbotPart.Value].Position
						local playerGravity = workspace.Gravity
						local balloons = plr.Character:GetAttribute('InflatedBalloons')

						if balloons and balloons > 0 then 
							playerGravity = (workspace.Gravity * (1 - ((balloons >= 4 and 1.2 or balloons >= 3 and 1 or 0.975))))
						end

						if plr.Character.PrimaryPart:FindFirstChild('rbxassetid://8200754399') then 
							playerGravity = (workspace.Gravity * 0.3)
						end

						local shootpos, shootvelo = predictGravity(pos, plr.Character.HumanoidRootPart.Velocity, (pos - offsetStartPos).Magnitude / projectileSpeed, plr, playerGravity)
						if projmeta.projectile == 'telepearl' then
							shootpos = pos
							shootvelo = Vector3.zero
						end
						
						local newlook = CFrame.new(offsetStartPos, shootpos) * CFrame.new(Vector3.new(-bedwars.BowConstantsTable.RelX, -bedwars.BowConstantsTable.RelY, 0))
						shootpos = newlook.p + (newlook.lookVector * (offsetStartPos - shootpos).magnitude)
						local calculated = LaunchDirection(offsetStartPos, shootpos, projectileSpeed, projectileGravity, false)
						oldmove = plr.Character.Humanoid.MoveDirection
						if calculated then
							return {
								initialVelocity = calculated,
								positionFrom = offsetStartPos,
								deltaT = projectilePrediction,
								gravitationalAcceleration = projectileGravity,
								drawDurationSeconds = 5
							}
						end
					end
					return oldCalculateAim(self, projmeta, worldmeta, shootpospart, ...)
				end
			else
				bedwars.ProjectileController.calculateImportantLaunchValues = oldCalculateAim
			end
		end
	})
	BowAimbotPart = BowAimbot.CreateDropdown({
		Name = 'Part',
		List = {'HumanoidRootPart', 'Head'},
		Function = function() end
	})
	BowAimbotFOV = BowAimbot.CreateSlider({
		Name = 'FOV',
		Function = function() end,
		Min = 1,
		Max = 1000,
		Default = 1000
	})
	BowAimbotProjectiles = BowAimbot.CreateToggle({
		Name = 'Other Projectiles',
		Function = function() end,
		Default = true
	})
end)

local Scaffold = {}
runFunction(function()
	local scaffoldtext = Instance.new('TextLabel')
	scaffoldtext.Font = Enum.Font.SourceSans
	scaffoldtext.TextSize = 20
	scaffoldtext.BackgroundTransparency = 1
	scaffoldtext.TextColor3 = Color3.fromRGB(255, 0, 0)
	scaffoldtext.Size = UDim2.new(0, 0, 0, 0)
	scaffoldtext.Position = UDim2.new(0.5, 0, 0.5, 30)
	scaffoldtext.Text = '0'
	scaffoldtext.Visible = false
	scaffoldtext.Parent = GuiLibrary.MainGui
	local ScaffoldExpand = {Value = 1}
	local ScaffoldDiagonal = {}
	local ScaffoldTower = {}
	local ScaffoldDownwards = {}
	local ScaffoldStopMotion = {}
	local ScaffoldBlockCount = {}
	local ScaffoldHandCheck = {}
	local ScaffoldMouseCheck = {}
	local ScaffoldAnimation = {}
	local scaffoldstopmotionval = false
	local scaffoldposcheck = tick()
	local scaffoldstopmotionpos = Vector3.zero
	local scaffoldposchecklist = {}
	task.spawn(function()
		for x = -3, 3, 3 do 
			for y = -3, 3, 3 do 
				for z = -3, 3, 3 do 
					if Vector3.new(x, y, z) ~= Vector3.new(0, 0, 0) then 
						table.insert(scaffoldposchecklist, Vector3.new(x, y, z)) 
					end 
				end 
			end 
		end
	end)

	local function checkblocks(pos)
		for i,v in next, (scaffoldposchecklist) do
			if getPlacedBlock(pos + v) then
				return true
			end
		end
		return false
	end

	local function closestpos(block, pos)
		local startpos = block.Position - (block.Size / 2) - Vector3.new(1.5, 1.5, 1.5)
		local endpos = block.Position + (block.Size / 2) + Vector3.new(1.5, 1.5, 1.5)
		local speedCFrame = block.Position + (pos - block.Position)
		return Vector3.new(math.clamp(speedCFrame.X, startpos.X, endpos.X), math.clamp(speedCFrame.Y, startpos.Y, endpos.Y), math.clamp(speedCFrame.Z, startpos.Z, endpos.Z))
	end

	local function getclosesttop(newmag, pos)
		local closest, closestmag = pos, newmag * 3
		if entityLibrary.isAlive then 
			for i,v in next, (bedwarsStore.blocks) do 
				local close = closestpos(v, pos)
				local mag = (close - pos).magnitude
				if mag <= closestmag then 
					closest = close
					closestmag = mag
				end
			end
		end
		return closest
	end

	local oldspeed
	Scaffold = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = 'Scaffold',
		Function = function(calling)
			if calling then
				scaffoldtext.Visible = ScaffoldBlockCount.Enabled
				if entityLibrary.isAlive then 
					scaffoldstopmotionpos = entityLibrary.character.HumanoidRootPart.CFrame.p
				end
				task.spawn(function()
					repeat
						task.wait()
						if ScaffoldHandCheck.Enabled then 
							if bedwarsStore.localHand.Type ~= 'block' then continue end
						end
						if ScaffoldMouseCheck.Enabled then 
							if not inputService:IsMouseButtonPressed(0) then continue end
						end
						if entityLibrary.isAlive then
							local wool, woolamount = getWool()
							if bedwarsStore.localHand.Type == 'block' then
								wool = bedwarsStore.localHand.tool.Name
								woolamount = getItem(bedwarsStore.localHand.tool.Name).amount or 0
							elseif (not wool) then 
								wool, woolamount = getBlock()
							end

							scaffoldtext.Text = (woolamount and tostring(woolamount) or '0')
							scaffoldtext.TextColor3 = woolamount and (woolamount >= 128 and Color3.fromRGB(9, 255, 198) or woolamount >= 64 and Color3.fromRGB(255, 249, 18)) or Color3.fromRGB(255, 0, 0)
							if not wool then continue end

							local towering = ScaffoldTower.Enabled and inputService:IsKeyDown(Enum.KeyCode.Space) and game:GetService('UserInputService'):GetFocusedTextBox() == nil
							if towering then
								if (not scaffoldstopmotionval) and ScaffoldStopMotion.Enabled then
									scaffoldstopmotionval = true
									scaffoldstopmotionpos = entityLibrary.character.HumanoidRootPart.CFrame.p
								end
								entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(entityLibrary.character.HumanoidRootPart.Velocity.X, 28, entityLibrary.character.HumanoidRootPart.Velocity.Z)
								if ScaffoldStopMotion.Enabled and scaffoldstopmotionval then
									entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(Vector3.new(scaffoldstopmotionpos.X, entityLibrary.character.HumanoidRootPart.CFrame.p.Y, scaffoldstopmotionpos.Z))
								end
							else
								scaffoldstopmotionval = false
							end
							
							for i = 1, ScaffoldExpand.Value do
								local speedCFrame = getScaffold((entityLibrary.character.HumanoidRootPart.Position + ((scaffoldstopmotionval and Vector3.zero or entityLibrary.character.Humanoid.MoveDirection) * (i * 4))) + Vector3.new(0, -((entityLibrary.character.HumanoidRootPart.Size.Y / 2) + entityLibrary.character.Humanoid.HipHeight + (inputService:IsKeyDown(Enum.KeyCode.LeftShift) and ScaffoldDownwards.Enabled and 4.5 or 1.5))), 0)
								speedCFrame = Vector3.new(speedCFrame.X, speedCFrame.Y - (towering and 4 or 0), speedCFrame.Z)
								if speedCFrame ~= oldpos then
									if not checkblocks(speedCFrame) then
										local oldspeedCFrame = speedCFrame
										speedCFrame = getScaffold(getclosesttop(20, speedCFrame))
										if getPlacedBlock(speedCFrame) then speedCFrame = oldspeedCFrame end
									end
									if ScaffoldAnimation.Enabled then 
										if not getPlacedBlock(speedCFrame) then
										bedwars.ViewmodelController:playAnimation(bedwars.AnimationType.FP_USE_ITEM)
										end
									end
									task.spawn(bedwars.placeBlock, speedCFrame, wool, ScaffoldAnimation.Enabled)
									if ScaffoldExpand.Value > 1 then 
										task.wait()
									end
									oldpos = speedCFrame
								end
							end
						end
					until (not Scaffold.Enabled)
				end)
			else
				scaffoldtext.Visible = false
				oldpos = Vector3.zero
				oldpos2 = Vector3.zero
			end
		end, 
		HoverText = 'Helps you make bridges/scaffold walk.'
	})
	ScaffoldExpand = Scaffold.CreateSlider({
		Name = 'Expand',
		Min = 1,
		Max = 8,
		Function = function(val) end,
		Default = 1,
		HoverText = 'Build range'
	})
	ScaffoldDiagonal = Scaffold.CreateToggle({
		Name = 'Diagonal', 
		Function = function(calling) end,
		Default = true
	})
	ScaffoldTower = Scaffold.CreateToggle({
		Name = 'Tower', 
		Function = function(calling) 
			if ScaffoldStopMotion.Object then
				ScaffoldTower.Object.ToggleArrow.Visible = calling
				ScaffoldStopMotion.Object.Visible = calling
			end
		end
	})
	ScaffoldMouseCheck = Scaffold.CreateToggle({
		Name = 'Require mouse down', 
		Function = function(calling) end,
		HoverText = 'Only places when left click is held.',
	})
	ScaffoldDownwards  = Scaffold.CreateToggle({
		Name = 'Downwards', 
		Function = function(calling) end,
		HoverText = 'Goes down when left shift is held.'
	})
	ScaffoldStopMotion = Scaffold.CreateToggle({
		Name = 'Stop Motion',
		Function = function() end,
		HoverText = 'Stops your movement when going up'
	})
	ScaffoldStopMotion.Object.BackgroundTransparency = 0
	ScaffoldStopMotion.Object.BorderSizePixel = 0
	ScaffoldStopMotion.Object.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	ScaffoldStopMotion.Object.Visible = ScaffoldTower.Enabled
	ScaffoldBlockCount = Scaffold.CreateToggle({
		Name = 'Block Count',
		Function = function(calling) 
			if Scaffold.Enabled then
				scaffoldtext.Visible = calling 
			end
		end,
		HoverText = 'Shows the amount of blocks in the middle.'
	})
	ScaffoldHandCheck = Scaffold.CreateToggle({
		Name = 'Whitelist Only',
		Function = function() end,
		HoverText = 'Only builds with blocks in your hand.'
	})
	ScaffoldAnimation = Scaffold.CreateToggle({
		Name = 'Animation',
		Function = function() end
	})
end)

local antivoidvelo
local damagetick = tick()
runFunction(function()
	local Speed = {}
	local SpeedMode = {Value = 'CFrame'}
	local SpeedValue = {Value = 1}
	local SpeedValueLarge = {Value = 1}
	local SpeedDamageBoost = {}
	local SpeedJump = {}
	local SpeedJumpHeight = {Value = 20}
	local SpeedJumpAlways = {}
	local SpeedJumpSound = {}
	local SpeedJumpVanilla = {}
	local SpeedAnimation = {}
	local raycastparameters = RaycastParams.new()
	local newroot
	local root
	local lastmove = tick()
	local clonehip
	local function cloneFunction()
		--[[if not isAlive(lplr, true) then 
			repeat task.wait() until isAlive(lplr, true) 
			task.wait(1.5)
		end
		root = lplr.Character.HumanoidRootPart
		lplr.Character.Parent = game
		newroot = root:Clone()
		newroot.Parent = lplr.Character
		root.Parent = gameCamera
		bedwars.QueryUtil:setQueryIgnored(root, true)
		newroot.CFrame = root.CFrame
		lplr.Character.PrimaryPart = newroot
		lplr.Character.Parent = workspace
		root.Transparency = 0.7 
		for i,v in next, lplr.Character:GetDescendants() do 
			if v:IsA('Weld') or v:IsA('Motor6D') then 
				if v.Part0 == root then v.Part0 = newroot end
				if v.Part1 == root then v.Part1 = newroot end
			end
			if v:IsA('BodyVelocity') then 
				v:Destroy()
			end
		end
		for i,v in next, root:GetChildren() do 
			if v:IsA('BodyVelocity') then 
				v:Destroy()
			end
		end
		if clonehip then 
			lplr.Character.Humanoid.HipHeight = clonehip
		end
		clonehip = lplr.Character.Humanoid.HipHeight
		local bodyvelo = Instance.new('BodyVelocity') 
		bodyvelo.MaxForce = Vector3.new(0, 9e9, 0)
		bodyvelo.Velocity = Vector3.zero
		bodyvelo.Parent = newroot
		task.spawn(function()
			repeat
				bodyvelo.Velocity = Vector3.zero
				if tick() > lastmove then 
					newroot.CFrame = root.CFrame
					lastmove = tick() + math.random(0.8, 0.25)
				end
				task.wait()
			until not newroot.Parent
		end)
		entityLibrary.character.HumanoidRootPart = newroot]]
	end

	local alternatelist = {'Normal', 'AntiCheat A', 'AntiCheat B'}
	Speed = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = 'Speed',
		Function = function(calling)
			if calling then
				task.spawn(cloneFunction)
				table.insert(Speed.Connections, lplr.CharacterAdded:Connect(cloneFunction))
				table.insert(Speed.Connections, vapeEvents.EntityDamageEvent.Event:Connect(function(damageTable)
					if damageTable.entityInstance == lplr.Character and (damageTable.damageType ~= 0 or damageTable.extra and damageTable.extra.chargeRatio ~= nil) and (not (damageTable.knockbackMultiplier and damageTable.knockbackMultiplier.disabled or damageTable.knockbackMultiplier and damageTable.knockbackMultiplier.horizontal == 0)) and SpeedDamageBoost.Enabled then 
						damagetick = tick() + 0.4
					end
				end))
				RunLoops:BindToHeartbeat('Speed', function(delta)
					if GuiLibrary.ObjectsThatCanBeSaved['Lobby CheckToggle'].Api.Enabled then
						if bedwarsStore.matchState == 0 then return end
					end
					if entityLibrary.isAlive then
						if not (isnetworkowner(entityLibrary.character.HumanoidRootPart) and entityLibrary.character.Humanoid:GetState() ~= Enum.HumanoidStateType.Climbing and (not spiderActive) and (not GuiLibrary.ObjectsThatCanBeSaved.InfiniteFlyOptionsButton.Api.Enabled) and (not GuiLibrary.ObjectsThatCanBeSaved.FlyOptionsButton.Api.Enabled)) then return end
						if GuiLibrary.ObjectsThatCanBeSaved.GrappleExploitOptionsButton and GuiLibrary.ObjectsThatCanBeSaved.GrappleExploitOptionsButton.Api.Enabled then return end
						if LongJump.Enabled then return end
						if SpeedAnimation.Enabled then
							for i, v in next, (entityLibrary.character.Humanoid:GetPlayingAnimationTracks()) do
								if v.Name == 'WalkAnim' or v.Name == 'RunAnim' then
									v:AdjustSpeed(entityLibrary.character.Humanoid.WalkSpeed / 16)
								end
							end
						end

						local speedValue = SpeedValue.Value + getSpeed()
						if damagetick > tick() then speedValue = speedValue + 20 end

						local speedVelocity = entityLibrary.character.Humanoid.MoveDirection * (SpeedMode.Value == 'Normal' and SpeedValue.Value or 20)
						entityLibrary.character.HumanoidRootPart.Velocity = antivoidvelo or Vector3.new(speedVelocity.X, entityLibrary.character.HumanoidRootPart.Velocity.Y, speedVelocity.Z)
						if SpeedMode.Value ~= 'Normal' then 
							local speedCFrame = entityLibrary.character.Humanoid.MoveDirection * (speedValue - 20) * delta
							raycastparameters.FilterDescendantsInstances = {lplr.Character}
							local ray = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, speedCFrame, raycastparameters)
							if ray then speedCFrame = (ray.Position - entityLibrary.character.HumanoidRootPart.Position) end
							entityLibrary.character.HumanoidRootPart.CFrame = entityLibrary.character.HumanoidRootPart.CFrame + speedCFrame
						end

						if SpeedJump.Enabled and (not Scaffold.Enabled) and (SpeedJumpAlways.Enabled or killauraNearPlayer) then
							if (entityLibrary.character.Humanoid.FloorMaterial ~= Enum.Material.Air) and entityLibrary.character.Humanoid.MoveDirection ~= Vector3.zero then
								if SpeedJumpSound.Enabled then 
									pcall(function() entityLibrary.character.HumanoidRootPart.Jumping:Play() end)
								end
								if SpeedJumpVanilla.Enabled then 
									entityLibrary.character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
								else
									entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(entityLibrary.character.HumanoidRootPart.Velocity.X, SpeedJumpHeight.Value, entityLibrary.character.HumanoidRootPart.Velocity.Z)
								end
							end 
						end
					end
				end)
			else
				RunLoops:UnbindFromHeartbeat('Speed')
			end
		end, 
		HoverText = 'Increases your movement.',
		ExtraText = function() 
			return 'Heatseeker'
		end
	})
	SpeedValue = Speed.CreateSlider({
		Name = 'Speed',
		Min = 1,
		Max = 23,
		Function = function(val) end,
		Default = 23
	})
	SpeedValueLarge = Speed.CreateSlider({
		Name = 'Big Mode Speed',
		Min = 1,
		Max = 23,
		Function = function(val) end,
		Default = 23
	})
	SpeedDamageBoost = Speed.CreateToggle({
		Name = 'Damage Boost',
		Function = function() end,
		Default = true
	})
	SpeedJump = Speed.CreateToggle({
		Name = 'AutoJump', 
		Function = function(calling) 
			if SpeedJumpHeight.Object then SpeedJumpHeight.Object.Visible = calling end
			if SpeedJumpAlways.Object then
				SpeedJump.Object.ToggleArrow.Visible = calling
				SpeedJumpAlways.Object.Visible = calling
			end
			if SpeedJumpSound.Object then SpeedJumpSound.Object.Visible = calling end
			if SpeedJumpVanilla.Object then SpeedJumpVanilla.Object.Visible = calling end
		end,
		Default = true
	})
	SpeedJumpHeight = Speed.CreateSlider({
		Name = 'Jump Height',
		Min = 0,
		Max = 30,
		Default = 25,
		Function = function() end
	})
	SpeedJumpAlways = Speed.CreateToggle({
		Name = 'Always Jump',
		Function = function() end
	})
	SpeedJumpSound = Speed.CreateToggle({
		Name = 'Jump Sound',
		Function = function() end
	})
	SpeedJumpVanilla = Speed.CreateToggle({
		Name = 'Real Jump',
		Function = function() end
	})
	SpeedAnimation = Speed.CreateToggle({
		Name = 'Slowdown Anim',
		Function = function() end
	})
end)

runFunction(function()
	local function roundpos(dir, pos, size)
		local suc, res = pcall(function() return Vector3.new(math.clamp(dir.X, pos.X - (size.X / 2), pos.X + (size.X / 2)), math.clamp(dir.Y, pos.Y - (size.Y / 2), pos.Y + (size.Y / 2)), math.clamp(dir.Z, pos.Z - (size.Z / 2), pos.Z + (size.Z / 2))) end)
		return suc and res or Vector3.zero
	end

	local Spider = {}
	local SpiderSpeed = {Value = 0}
	local SpiderMode = {Value = 'Normal'}
	local SpiderPart
	Spider = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = 'Spider',
		Function = function(calling)
			if calling then
				table.insert(Spider.Connections, inputService.InputBegan:Connect(function(input1)
					if input1.KeyCode == Enum.KeyCode.LeftShift then 
						holdingshift = true
					end
				end))
				table.insert(Spider.Connections, inputService.InputEnded:Connect(function(input1)
					if input1.KeyCode == Enum.KeyCode.LeftShift then 
						holdingshift = false
					end
				end))
				RunLoops:BindToHeartbeat('Spider', function()
					if entityLibrary.isAlive and (GuiLibrary.ObjectsThatCanBeSaved.PhaseOptionsButton.Api.Enabled == false or holdingshift == false) then
						if SpiderMode.Value == 'Normal' then
							local vec = entityLibrary.character.Humanoid.MoveDirection * 2
							local newray = getPlacedBlock(entityLibrary.character.HumanoidRootPart.Position + (vec + Vector3.new(0, 0.1, 0)))
							local newray2 = getPlacedBlock(entityLibrary.character.HumanoidRootPart.Position + (vec - Vector3.new(0, entityLibrary.character.Humanoid.HipHeight, 0)))
							if newray and (not newray.CanCollide) then newray = nil end 
							if newray2 and (not newray2.CanCollide) then newray2 = nil end 
							if spiderActive and (not newray) and (not newray2) then
								entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(entityLibrary.character.HumanoidRootPart.Velocity.X, 0, entityLibrary.character.HumanoidRootPart.Velocity.Z)
							end
							spiderActive = ((newray or newray2) and true or false)
							if (newray or newray2) then
								entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(newray2 and newray == nil and entityLibrary.character.HumanoidRootPart.Velocity.X or 0, SpiderSpeed.Value, newray2 and newray == nil and entityLibrary.character.HumanoidRootPart.Velocity.Z or 0)
							end
						else
							if not SpiderPart then 
								SpiderPart = Instance.new('TrussPart')
								SpiderPart.Size = Vector3.new(2, 2, 2)
								SpiderPart.Transparency = 1
								SpiderPart.Anchored = true
								SpiderPart.Parent = gameCamera
							end
							local newray2, newray2pos = getPlacedBlock(entityLibrary.character.HumanoidRootPart.Position + ((entityLibrary.character.HumanoidRootPart.CFrame.lookVector * 1.5) - Vector3.new(0, entityLibrary.character.Humanoid.HipHeight, 0)))
							if newray2 and (not newray2.CanCollide) then newray2 = nil end
							spiderActive = (newray2 and true or false)
							if newray2 then 
								newray2pos = newray2pos * 3
								local newpos = roundpos(entityLibrary.character.HumanoidRootPart.Position, Vector3.new(newray2pos.X, math.min(entityLibrary.character.HumanoidRootPart.Position.Y, newray2pos.Y), newray2pos.Z), Vector3.new(1.1, 1.1, 1.1))
								SpiderPart.Position = newpos
							else
								SpiderPart.Position = Vector3.zero
							end
						end
					end
				end)
			else
				if SpiderPart then SpiderPart:Destroy() end
				RunLoops:UnbindFromHeartbeat('Spider')
				holdingshift = false
			end
		end,
		HoverText = 'Lets you climb up walls'
	})
	SpiderMode = Spider.CreateDropdown({
		Name = 'Mode',
		List = {'Normal', 'Classic'},
		Function = function() 
			if SpiderPart then SpiderPart:Destroy() end
		end
	})
	SpiderSpeed = Spider.CreateSlider({
		Name = 'Speed',
		Min = 0,
		Max = 40,
		Function = function() end,
		Default = 40
	})
end)

runFunction(function()
	local TargetStrafe = {}
	local TargetStrafeRange = {Value = 18}
	local oldmove
	local controlmodule
	local block
	TargetStrafe = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = 'TargetStrafe',
		Function = function(calling)
			if calling then 
				task.spawn(function()
					if not controlmodule then
						local suc = pcall(function() controlmodule = require(lplr.PlayerScripts.PlayerModule).controls end)
						if not suc then controlmodule = {} end
					end
					oldmove = controlmodule.moveFunction
					local ang = 0
					local oldplr
					block = Instance.new('Part')
					block.Anchored = true
					block.CanCollide = false
					block.Parent = gameCamera
					controlmodule.moveFunction = function(Self, vec, facecam, ...)
						if entityLibrary.isAlive then
							local plr = AllNearPosition(TargetStrafeRange.Value + 5, 10)[1]
							plr = plr and (not workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, (plr.RootPart.Position - entityLibrary.character.HumanoidRootPart.Position), bedwarsStore.blockRaycast)) and workspace:Raycast(plr.RootPart.Position, Vector3.new(0, -70, 0), bedwarsStore.blockRaycast) and plr or nil
							if plr ~= oldplr then
								if plr then
									local x, y, z = CFrame.new(plr.RootPart.Position, entityLibrary.character.HumanoidRootPart.Position):ToEulerAnglesXYZ()
									ang = math.deg(z)
								end
								oldplr = plr
							end
							if plr then 
								facecam = false
								local localPos = CFrame.new(plr.RootPart.Position)
								local ray = workspace:Blockcast(localPos, Vector3.new(3, 3, 3), CFrame.Angles(0, math.rad(ang), 0).lookVector * TargetStrafeRange.Value, bedwarsStore.blockRaycast)
								local newPos = localPos + (CFrame.Angles(0, math.rad(ang), 0).lookVector * (ray and ray.Distance - 1 or TargetStrafeRange.Value))
								local factor = getSpeed() > 0 and 6 or 4
								if not workspace:Raycast(newPos.p, Vector3.new(0, -70, 0), bedwarsStore.blockRaycast) then 
									newPos = localPos
									factor = 40
								end
								if ((entityLibrary.character.HumanoidRootPart.Position * Vector3.new(1, 0, 1)) - (newPos.p * Vector3.new(1, 0, 1))).Magnitude < 4 or ray then
									ang = ang + factor % 360
								end
								block.Position = newPos.p
								vec = (newPos.p - entityLibrary.character.HumanoidRootPart.Position) * Vector3.new(1, 0, 1)
							end
						end
						return oldmove(Self, vec, facecam, ...)
					end
				end)
			else
				block:Destroy()
				controlmodule.moveFunction = oldmove
			end
		end
	})
	TargetStrafeRange = TargetStrafe.CreateSlider({
		Name = 'Range',
		Min = 0,
		Max = 18,
		Function = function() end
	})
end)

runFunction(function()
	local BedESP = {}
	local BedESPFolder = Instance.new('Folder')
	BedESPFolder.Name = 'BedESPFolder'
	BedESPFolder.Parent = GuiLibrary.MainGui
	local BedESPTable = {}
	local BedESPColor = {Value = 0.44}
	local BedESPTransparency = {Value = 1}
	local BedESPOnTop = {}
	BedESP = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = 'BedESP',
		Function = function(calling) 
			if calling then
				table.insert(BedESP.Connections, collectionService:GetInstanceAddedSignal('bed'):Connect(function(bed)
					task.wait(0.2)
					if not BedESP.Enabled then return end
					local BedFolder = Instance.new('Folder')
					BedFolder.Parent = BedESPFolder
					BedESPTable[bed] = BedFolder
					for bedespnumber, bedesppart in next, (bed:GetChildren()) do
						local boxhandle = Instance.new('BoxHandleAdornment')
						boxhandle.Size = bedesppart.Size + Vector3.new(.01, .01, .01)
						boxhandle.AlwaysOnTop = true
						boxhandle.ZIndex = (bedesppart.Name == 'Covers' and 10 or 0)
						boxhandle.Visible = true
						boxhandle.Adornee = bedesppart
						boxhandle.Color3 = bedesppart.Color
						boxhandle.Name = bedespnumber
						boxhandle.Parent = BedFolder
					end
				end))
				table.insert(BedESP.Connections, collectionService:GetInstanceRemovedSignal('bed'):Connect(function(bed)
					if BedESPTable[bed] then 
						BedESPTable[bed]:Destroy()
						BedESPTable[bed] = nil
					end
				end))
				for i, bed in next, (collectionService:GetTagged('bed')) do 
					local BedFolder = Instance.new('Folder')
					BedFolder.Parent = BedESPFolder
					BedESPTable[bed] = BedFolder
					for bedespnumber, bedesppart in next, (bed:GetChildren()) do
						if bedesppart:IsA('BasePart') then
							local boxhandle = Instance.new('BoxHandleAdornment')
							boxhandle.Size = bedesppart.Size + Vector3.new(.01, .01, .01)
							boxhandle.AlwaysOnTop = true
							boxhandle.ZIndex = (bedesppart.Name == 'Covers' and 10 or 0)
							boxhandle.Visible = true
							boxhandle.Adornee = bedesppart
							boxhandle.Color3 = bedesppart.Color
							boxhandle.Parent = BedFolder
						end
					end
				end
			else
				BedESPFolder:ClearAllChildren()
				table.clear(BedESPTable)
			end
		end,
		HoverText = 'Render Beds through walls' 
	})
end)

runFunction(function()
	local function getallblocks2(pos, normal)
		local blocks = {}
		local lastfound = nil
		for i = 1, 20 do
			local blockpos = (pos + (Vector3.FromNormalId(normal) * (i * 3)))
			local extrablock = getPlacedBlock(blockpos)
			local covered = true
			if extrablock and extrablock.Parent ~= nil then
				if bedwars.BlockController:isBlockBreakable({blockPosition = blockpos}, lplr) then
					table.insert(blocks, extrablock:GetAttribute('NoBreak') and 'unbreakable' or extrablock.Name)
				else
					table.insert(blocks, 'unbreakable')
					break
				end
				lastfound = extrablock
				if covered == false then
					break
				end
			else
				break
			end
		end
		return blocks
	end

	local function getallbedblocks(pos)
		local blocks = {}
		for i,v in next, (cachedNormalSides) do
			for i2,v2 in next, (getallblocks2(pos, v)) do	
				if table.find(blocks, v2) == nil and v2 ~= 'bed' then
					table.insert(blocks, v2)
				end
			end
			for i2,v2 in next, (getallblocks2(pos + Vector3.new(0, 0, 3), v)) do	
				if table.find(blocks, v2) == nil and v2 ~= 'bed' then
					table.insert(blocks, v2)
				end
			end
		end
		return blocks
	end

	local function refreshAdornee(v)
		local bedblocks = getallbedblocks(v.Adornee.Position)
		for i2,v2 in next, (v.Frame:GetChildren()) do
			if v2:IsA('ImageLabel') then
				v2:Remove()
			end
		end
		for i3,v3 in next, (bedblocks) do
			local blockimage = Instance.new('ImageLabel')
			blockimage.Size = UDim2.new(0, 32, 0, 32)
			blockimage.BackgroundTransparency = 1
			blockimage.Image = bedwars.getIcon({itemType = v3}, true)
			blockimage.Parent = v.Frame
		end
	end

	local BedPlatesFolder = Instance.new('Folder')
	BedPlatesFolder.Name = 'BedPlatesFolder'
	BedPlatesFolder.Parent = GuiLibrary.MainGui
	local BedPlatesTable = {}
	local BedPlates = {}

	local function addBed(v)
		local billboard = Instance.new('BillboardGui')
		billboard.Parent = BedPlatesFolder
		billboard.Name = 'bed'
		billboard.StudsOffsetWorldSpace = Vector3.new(0, 3, 1.5)
		billboard.Size = UDim2.new(0, 42, 0, 42)
		billboard.AlwaysOnTop = true
		billboard.Adornee = v
		BedPlatesTable[v] = billboard
		local frame = Instance.new('Frame')
		frame.Size = UDim2.new(1, 0, 1, 0)
		frame.BackgroundColor3 = Color3.new(0, 0, 0)
		frame.BackgroundTransparency = 0.5
		frame.Parent = billboard
		local uilistlayout = Instance.new('UIListLayout')
		uilistlayout.FillDirection = Enum.FillDirection.Horizontal
		uilistlayout.Padding = UDim.new(0, 4)
		uilistlayout.VerticalAlignment = Enum.VerticalAlignment.Center
		uilistlayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		uilistlayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
			billboard.Size = UDim2.new(0, math.max(uilistlayout.AbsoluteContentSize.X + 12, 42), 0, 42)
		end)
		uilistlayout.Parent = frame
		local uicorner = Instance.new('UICorner')
		uicorner.CornerRadius = UDim.new(0, 4)
		uicorner.Parent = frame
		refreshAdornee(billboard)
	end

	BedPlates = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = 'BedPlates',
		Function = function(calling)
			if calling then
				table.insert(BedPlates.Connections, vapeEvents.PlaceBlockEvent.Event:Connect(function(p5)
					for i, v in next, (BedPlatesFolder:GetChildren()) do 
						if v.Adornee then
							if ((p5.blockRef.blockPosition * 3) - v.Adornee.Position).magnitude <= 20 then
								refreshAdornee(v)
							end
						end
					end
				end))
				table.insert(BedPlates.Connections, vapeEvents.BreakBlockEvent.Event:Connect(function(p5)
					for i, v in next, (BedPlatesFolder:GetChildren()) do 
						if v.Adornee then
							if ((p5.blockRef.blockPosition * 3) - v.Adornee.Position).magnitude <= 20 then
								refreshAdornee(v)
							end
						end
					end
				end))
				table.insert(BedPlates.Connections, collectionService:GetInstanceAddedSignal('bed'):Connect(function(v)
					addBed(v)
				end))
				table.insert(BedPlates.Connections, collectionService:GetInstanceRemovedSignal('bed'):Connect(function(v)
					if BedPlatesTable[v] then 
						BedPlatesTable[v]:Destroy()
						BedPlatesTable[v] = nil
					end
				end))
				for i, v in next, (collectionService:GetTagged('bed')) do
					addBed(v)
				end
			else
				BedPlatesFolder:ClearAllChildren()
			end
		end
	})
end)

runFunction(function()
	local ChestESPList = {ObjectList = {}, RefreshList = function() end}
	local function nearchestitem(item)
		for i,v in next, (ChestESPList.ObjectList) do 
			if item:find(v) then return v end
		end
	end
	local function refreshAdornee(v)
		local chest = v.Adornee.ChestFolderValue.Value
        local chestitems = chest and chest:GetChildren() or {}
		for i2,v2 in next, (v.Frame:GetChildren()) do
			if v2:IsA('ImageLabel') then
				v2:Remove()
			end
		end
		v.Enabled = false
		local alreadygot = {}
		for itemNumber, item in next, (chestitems) do
			if alreadygot[item.Name] == nil and (table.find(ChestESPList.ObjectList, item.Name) or nearchestitem(item.Name)) then 
				alreadygot[item.Name] = true
				v.Enabled = true
                local blockimage = Instance.new('ImageLabel')
                blockimage.Size = UDim2.new(0, 32, 0, 32)
                blockimage.BackgroundTransparency = 1
                blockimage.Image = bedwars.getIcon({itemType = item.Name}, true)
                blockimage.Parent = v.Frame
            end
		end
	end

	local ChestESPFolder = Instance.new('Folder')
	ChestESPFolder.Name = 'ChestESPFolder'
	ChestESPFolder.Parent = GuiLibrary.MainGui
	local ChestESP = {}
	local ChestESPBackground = {}

	local function chestfunc(v)
		task.spawn(function()
			local billboard = Instance.new('BillboardGui')
			billboard.Parent = ChestESPFolder
			billboard.Name = 'chest'
			billboard.StudsOffsetWorldSpace = Vector3.new(0, 3, 0)
			billboard.Size = UDim2.new(0, 42, 0, 42)
			billboard.AlwaysOnTop = true
			billboard.Adornee = v
			local frame = Instance.new('Frame')
			frame.Size = UDim2.new(1, 0, 1, 0)
			frame.BackgroundColor3 = Color3.new(0, 0, 0)
			frame.BackgroundTransparency = ChestESPBackground.Enabled and 0.5 or 1
			frame.Parent = billboard
			local uilistlayout = Instance.new('UIListLayout')
			uilistlayout.FillDirection = Enum.FillDirection.Horizontal
			uilistlayout.Padding = UDim.new(0, 4)
			uilistlayout.VerticalAlignment = Enum.VerticalAlignment.Center
			uilistlayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			uilistlayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
				billboard.Size = UDim2.new(0, math.max(uilistlayout.AbsoluteContentSize.X + 12, 42), 0, 42)
			end)
			uilistlayout.Parent = frame
			local uicorner = Instance.new('UICorner')
			uicorner.CornerRadius = UDim.new(0, 4)
			uicorner.Parent = frame
			local chest = v:WaitForChild('ChestFolderValue').Value
			if chest then 
				table.insert(ChestESP.Connections, chest.ChildAdded:Connect(function(item)
					if table.find(ChestESPList.ObjectList, item.Name) or nearchestitem(item.Name) then 
						refreshAdornee(billboard)
					end
				end))
				table.insert(ChestESP.Connections, chest.ChildRemoved:Connect(function(item)
					if table.find(ChestESPList.ObjectList, item.Name) or nearchestitem(item.Name) then 
						refreshAdornee(billboard)
					end
				end))
				refreshAdornee(billboard)
			end
		end)
	end

	ChestESP = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = 'ChestESP',
		Function = function(calling)
			if calling then
				task.spawn(function()
					table.insert(ChestESP.Connections, collectionService:GetInstanceAddedSignal('chest'):Connect(chestfunc))
					for i,v in next, (collectionService:GetTagged('chest')) do chestfunc(v) end
				end)
			else
				ChestESPFolder:ClearAllChildren()
			end
		end
	})
	ChestESPList = ChestESP.CreateTextList({
		Name = 'ItemList',
		TempText = 'item or part of item',
		AddFunction = function()
			if ChestESP.Enabled then 
				ChestESP.ToggleButton(false)
				ChestESP.ToggleButton(false)
			end
		end,
		RemoveFunction = function()
			if ChestESP.Enabled then 
				ChestESP.ToggleButton(false)
				ChestESP.ToggleButton(false)
			end
		end
	})
	ChestESPBackground = ChestESP.CreateToggle({
		Name = 'Background',
		Function = function()
			if ChestESP.Enabled then 
				ChestESP.ToggleButton(false)
				ChestESP.ToggleButton(false)
			end
		end,
		Default = true
	})
end)

runFunction(function()
	local FieldOfViewValue = {Value = 70}
	local oldfov
	local oldfov2
	local FieldOfView = {}
	local FieldOfViewZoom = {}
	FieldOfView = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = 'FOVChanger',
		Function = function(calling)
			if calling then
				if FieldOfViewZoom.Enabled then
					task.spawn(function()
						repeat
							task.wait()
						until not inputService:IsKeyDown(Enum.KeyCode[FieldOfView.Keybind ~= '' and FieldOfView.Keybind or 'C'])
						if FieldOfView.Enabled then
							FieldOfView.ToggleButton(false)
						end
					end)
				end
				oldfov = bedwars.FovController.setFOV
				oldfov2 = bedwars.FovController.getFOV
				bedwars.FovController.setFOV = function(self, fov) return oldfov(self, FieldOfViewValue.Value) end
				bedwars.FovController.getFOV = function(self, fov) return FieldOfViewValue.Value end
			else
				bedwars.FovController.setFOV = oldfov
				bedwars.FovController.getFOV = oldfov2
			end
			bedwars.FovController:setFOV(bedwars.ClientStoreHandler:getState().Settings.fov)
		end
	})
	FieldOfViewValue = FieldOfView.CreateSlider({
		Name = 'FOV',
		Min = 30,
		Max = 120,
		Function = function(val)
			if FieldOfView.Enabled then
				bedwars.FovController:setFOV(bedwars.ClientStoreHandler:getState().Settings.fov)
			end
		end
	})
	FieldOfViewZoom = FieldOfView.CreateToggle({
		Name = 'Zoom',
		Function = function() end,
		HoverText = 'optifine zoom lol'
	})
end)

runFunction(function()
	pcall(GuiLibrary.RemoveObject, 'FPSBoostOptionsButton')
	local old
	local old2
	local oldhitpart 
	local FPSBoost = {}
	local removetextures = {}
	local removetexturessmooth = {}
	local fpsboostdamageindicator = {}
	local fpsboostdamageeffect = {}
	local fpsboostkilleffect = {}
	local originaltextures = {}
	local originaleffects = {}

	local function fpsboosttextures()
		task.spawn(function()
			repeat task.wait() until bedwarsStore.matchState ~= 0
			for i,v in next, (bedwarsStore.blocks) do
				if v:GetAttribute('PlacedByUserId') == 0 then
					v.Material = FPSBoost.Enabled and removetextures.Enabled and Enum.Material.SmoothPlastic or (v.Name:find('glass') and Enum.Material.SmoothPlastic or Enum.Material.Fabric)
					originaltextures[v] = originaltextures[v] or v.MaterialVariant
					v.MaterialVariant = FPSBoost.Enabled and removetextures.Enabled and '' or originaltextures[v]
					for i2,v2 in next, (v:GetChildren()) do 
						pcall(function() 
							v2.Material = FPSBoost.Enabled and removetextures.Enabled and Enum.Material.SmoothPlastic or (v.Name:find('glass') and Enum.Material.SmoothPlastic or Enum.Material.Fabric)
							originaltextures[v2] = originaltextures[v2] or v2.MaterialVariant
							v2.MaterialVariant = FPSBoost.Enabled and removetextures.Enabled and '' or originaltextures[v2]
						end)
					end
				end
			end
		end)
	end

	FPSBoost = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = 'FPSBoost',
		Function = function(calling)
			local damagetab = debug.getupvalue(bedwars.DamageIndicator, 2)
			if calling then
				wasenabled = true
				fpsboosttextures()
				if fpsboostdamageindicator.Enabled then 
					damagetab.strokeThickness = 0
					damagetab.textSize = 0
					damagetab.blowUpDuration = 0
					damagetab.blowUpSize = 0
				end
				if fpsboostkilleffect.Enabled then 
					for i,v in next, (bedwars.KillEffectController.killEffects) do 
						originaleffects[i] = v
						bedwars.KillEffectController.killEffects[i] = {new = function(char) return {onKill = function() end, isPlayDefaultKillEffect = function() return char == lplr.Character end} end}
					end
				end
				if fpsboostdamageeffect.Enabled then 
					oldhitpart = bedwars.DamageIndicatorController.hitEffectPart
					bedwars.DamageIndicatorController.hitEffectPart = nil
				end
				old = bedwars.HighlightController.highlight
				old2 = getmetatable(bedwars.StopwatchController).tweenOutGhost
				local highlighttable = {}
				getmetatable(bedwars.StopwatchController).tweenOutGhost = function(p17, p18)
					p18:Destroy()
				end
				bedwars.HighlightController.highlight = function() end
			else
				for i,v in next, (originaleffects) do 
					bedwars.KillEffectController.killEffects[i] = v
				end
				fpsboosttextures()
				if oldhitpart then 
					bedwars.DamageIndicatorController.hitEffectPart = oldhitpart
				end
				debug.setupvalue(bedwars.KillEffectController.KnitStart, 2, require(lplr.PlayerScripts.TS['client-sync-events']).ClientSyncEvents)
				damagetab.strokeThickness = 1.5
				damagetab.textSize = 28
				damagetab.blowUpDuration = 0.125
				damagetab.blowUpSize = 76
				debug.setupvalue(bedwars.DamageIndicator, 10, tweenService)
				if bedwars.DamageIndicatorController.hitEffectPart then 
					bedwars.DamageIndicatorController.hitEffectPart.Attachment.Cubes.Enabled = true
					bedwars.DamageIndicatorController.hitEffectPart.Attachment.Shards.Enabled = true
				end
				bedwars.HighlightController.highlight = old
				getmetatable(bedwars.StopwatchController).tweenOutGhost = old2
				old = nil
				old2 = nil
			end
		end
	})
	removetextures = FPSBoost.CreateToggle({
		Name = 'Remove Textures',
		Function = function(calling) if FPSBoost.Enabled then FPSBoost.ToggleButton(false) FPSBoost.ToggleButton(false) end end
	})
	fpsboostdamageindicator = FPSBoost.CreateToggle({
		Name = 'Remove Damage Indicator',
		Function = function(calling) if FPSBoost.Enabled then FPSBoost.ToggleButton(false) FPSBoost.ToggleButton(false) end end
	})
	fpsboostdamageeffect = FPSBoost.CreateToggle({
		Name = 'Remove Damage Effect',
		Function = function(calling) if FPSBoost.Enabled then FPSBoost.ToggleButton(false) FPSBoost.ToggleButton(false) end end
	})
	fpsboostkilleffect = FPSBoost.CreateToggle({
		Name = 'Remove Kill Effect',
		Function = function(calling) if FPSBoost.Enabled then FPSBoost.ToggleButton(false) FPSBoost.ToggleButton(false) end end
	})
end)

runFunction(function()
	local GameFixer = {}
	local GameFixerHit = {}
	GameFixer = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = 'GameFixer',
		Function = function(calling)
			if calling then
				if GameFixerHit.Enabled then 
					debug.setconstant(bedwars.SwordController.swingSwordAtMouse, 23, 'raycast')
					debug.setupvalue(bedwars.SwordController.swingSwordAtMouse, 4, bedwars.QueryUtil)
				end
				debug.setconstant(bedwars.QueueCard.render, 9, 0.1)
			else
				if GameFixerHit.Enabled then 
					debug.setconstant(bedwars.SwordController.swingSwordAtMouse, 23, 'Raycast')
					debug.setupvalue(bedwars.SwordController.swingSwordAtMouse, 4, workspace)
				end
				debug.setconstant(bedwars.QueueCard.render, 9, 0.01)
			end
		end,
		HoverText = 'Fixes game bugs'
	})
	GameFixerHit = GameFixer.CreateToggle({
		Name = 'Hit Fix',
		Function = function(calling)
			if GameFixer.Enabled then
				if calling then 
					debug.setconstant(bedwars.SwordController.swingSwordAtMouse, 23, 'raycast')
					debug.setupvalue(bedwars.SwordController.swingSwordAtMouse, 4, bedwars.QueryUtil)
				else
					debug.setconstant(bedwars.SwordController.swingSwordAtMouse, 23, 'Raycast')
					debug.setupvalue(bedwars.SwordController.swingSwordAtMouse, 4, workspace)
				end
			end
		end,
		HoverText = 'Fixes the raycast function used for extra reach',
		Default = true
	})
end)

runFunction(function()
	local transformed = false
	local GameTheme = {}
	local GameThemeMode = {Value = 'GameTheme'}

	local themefunctions = {
		Old = function()
			task.spawn(function()
				local oldbedwarstabofimages = "{'clay_orange':'rbxassetid://7017703219','iron':'rbxassetid://6850537969','glass':'rbxassetid://6909521321','log_spruce':'rbxassetid://6874161124','ice':'rbxassetid://6874651262','marble':'rbxassetid://6594536339','zipline_base':'rbxassetid://7051148904','iron_helmet':'rbxassetid://6874272559','marble_pillar':'rbxassetid://6909323822','clay_dark_green':'rbxassetid://6763635916','wood_plank_birch':'rbxassetid://6768647328','watering_can':'rbxassetid://6915423754','emerald_helmet':'rbxassetid://6931675766','pie':'rbxassetid://6985761399','wood_plank_spruce':'rbxassetid://6768615964','diamond_chestplate':'rbxassetid://6874272898','wool_pink':'rbxassetid://6910479863','wool_blue':'rbxassetid://6910480234','wood_plank_oak':'rbxassetid://6910418127','diamond_boots':'rbxassetid://6874272964','clay_yellow':'rbxassetid://4991097283','tnt':'rbxassetid://6856168996','lasso':'rbxassetid://7192710930','clay_purple':'rbxassetid://6856099740','melon_seeds':'rbxassetid://6956387796','apple':'rbxassetid://6985765179','carrot_seeds':'rbxassetid://6956387835','log_oak':'rbxassetid://6763678414','emerald_chestplate':'rbxassetid://6931675868','wool_yellow':'rbxassetid://6910479606','emerald_boots':'rbxassetid://6931675942','clay_light_brown':'rbxassetid://6874651634','balloon':'rbxassetid://7122143895','cannon':'rbxassetid://7121221753','leather_boots':'rbxassetid://6855466456','melon':'rbxassetid://6915428682','wool_white':'rbxassetid://6910387332','log_birch':'rbxassetid://6763678414','clay_pink':'rbxassetid://6856283410','grass':'rbxassetid://6773447725','obsidian':'rbxassetid://6910443317','shield':'rbxassetid://7051149149','red_sandstone':'rbxassetid://6708703895','diamond_helmet':'rbxassetid://6874272793','wool_orange':'rbxassetid://6910479956','log_hickory':'rbxassetid://7017706899','guitar':'rbxassetid://7085044606','wool_purple':'rbxassetid://6910479777','diamond':'rbxassetid://6850538161','iron_chestplate':'rbxassetid://6874272631','slime_block':'rbxassetid://6869284566','stone_brick':'rbxassetid://6910394475','hammer':'rbxassetid://6955848801','ceramic':'rbxassetid://6910426690','wood_plank_maple':'rbxassetid://6768632085','leather_helmet':'rbxassetid://6855466216','stone':'rbxassetid://6763635916','slate_brick':'rbxassetid://6708836267','sandstone':'rbxassetid://6708657090','snow':'rbxassetid://6874651192','wool_red':'rbxassetid://6910479695','leather_chestplate':'rbxassetid://6876833204','clay_red':'rbxassetid://6856283323','wool_green':'rbxassetid://6910480050','clay_white':'rbxassetid://7017705325','wool_cyan':'rbxassetid://6910480152','clay_black':'rbxassetid://5890435474','sand':'rbxassetid://6187018940','clay_light_green':'rbxassetid://6856099550','clay_dark_brown':'rbxassetid://6874651325','carrot':'rbxassetid://3677675280','clay':'rbxassetid://6856190168','iron_boots':'rbxassetid://6874272718','emerald':'rbxassetid://6850538075','zipline':'rbxassetid://7051148904'}"
				local oldbedwarsicontab = game:GetService('HttpService'):JSONDecode(oldbedwarstabofimages)
				local oldbedwarssoundtable = {
					['QUEUE_JOIN'] = 'rbxassetid://6691735519',
					['QUEUE_MATCH_FOUND'] = 'rbxassetid://6768247187',
					['UI_CLICK'] = 'rbxassetid://6732690176',
					['UI_OPEN'] = 'rbxassetid://6732607930',
					['BEDWARS_UPGRADE_SUCCESS'] = 'rbxassetid://6760677364',
					['BEDWARS_PURCHASE_ITEM'] = 'rbxassetid://6760677364',
					['SWORD_SWING_1'] = 'rbxassetid://6760544639',
					['SWORD_SWING_2'] = 'rbxassetid://6760544595',
					['DAMAGE_1'] = 'rbxassetid://6765457325',
					['DAMAGE_2'] = 'rbxassetid://6765470975',
					['DAMAGE_3'] = 'rbxassetid://6765470941',
					['CROP_HARVEST'] = 'rbxassetid://4864122196',
					['CROP_PLANT_1'] = 'rbxassetid://5483943277',
					['CROP_PLANT_2'] = 'rbxassetid://5483943479',
					['CROP_PLANT_3'] = 'rbxassetid://5483943723',
					['ARMOR_EQUIP'] = 'rbxassetid://6760627839',
					['ARMOR_UNEQUIP'] = 'rbxassetid://6760625788',
					['PICKUP_ITEM_DROP'] = 'rbxassetid://6768578304',
					['PARTY_INCOMING_INVITE'] = 'rbxassetid://6732495464',
					['ERROR_NOTIFICATION'] = 'rbxassetid://6732495464',
					['INFO_NOTIFICATION'] = 'rbxassetid://6732495464',
					['END_GAME'] = 'rbxassetid://6246476959',
					['GENERIC_BLOCK_PLACE'] = 'rbxassetid://4842910664',
					['GENERIC_BLOCK_BREAK'] = 'rbxassetid://4819966893',
					['GRASS_BREAK'] = 'rbxassetid://5282847153',
					['WOOD_BREAK'] = 'rbxassetid://4819966893',
					['STONE_BREAK'] = 'rbxassetid://6328287211',
					['WOOL_BREAK'] = 'rbxassetid://4842910664',
					['TNT_EXPLODE_1'] = 'rbxassetid://7192313632',
					['TNT_HISS_1'] = 'rbxassetid://7192313423',
					['FIREBALL_EXPLODE'] = 'rbxassetid://6855723746',
					['SLIME_BLOCK_BOUNCE'] = 'rbxassetid://6857999096',
					['SLIME_BLOCK_BREAK'] = 'rbxassetid://6857999170',
					['SLIME_BLOCK_HIT'] = 'rbxassetid://6857999148',
					['SLIME_BLOCK_PLACE'] = 'rbxassetid://6857999119',
					['BOW_DRAW'] = 'rbxassetid://6866062236',
					['BOW_FIRE'] = 'rbxassetid://6866062104',
					['ARROW_HIT'] = 'rbxassetid://6866062188',
					['ARROW_IMPACT'] = 'rbxassetid://6866062148',
					['TELEPEARL_THROW'] = 'rbxassetid://6866223756',
					['TELEPEARL_LAND'] = 'rbxassetid://6866223798',
					['CROSSBOW_RELOAD'] = 'rbxassetid://6869254094',
					['VOICE_1'] = 'rbxassetid://5283866929',
					['VOICE_2'] = 'rbxassetid://5283867710',
					['VOICE_HONK'] = 'rbxassetid://5283872555',
					['FORTIFY_BLOCK'] = 'rbxassetid://6955762535',
					['EAT_FOOD_1'] = 'rbxassetid://4968170636',
					['KILL'] = 'rbxassetid://7013482008',
					['ZIPLINE_TRAVEL'] = 'rbxassetid://7047882304',
					['ZIPLINE_LATCH'] = 'rbxassetid://7047882233',
					['ZIPLINE_UNLATCH'] = 'rbxassetid://7047882265',
					['SHIELD_BLOCKED'] = 'rbxassetid://6955762535',
					['GUITAR_LOOP'] = 'rbxassetid://7084168540',
					['GUITAR_HEAL_1'] = 'rbxassetid://7084168458',
					['CANNON_MOVE'] = 'rbxassetid://7118668472',
					['CANNON_FIRE'] = 'rbxassetid://7121064180',
					['BALLOON_INFLATE'] = 'rbxassetid://7118657911',
					['BALLOON_POP'] = 'rbxassetid://7118657873',
					['FIREBALL_THROW'] = 'rbxassetid://7192289445',
					['LASSO_HIT'] = 'rbxassetid://7192289603',
					['LASSO_SWING'] = 'rbxassetid://7192289504',
					['LASSO_THROW'] = 'rbxassetid://7192289548',
					['GRIM_REAPER_CONSUME'] = 'rbxassetid://7225389554',
					['GRIM_REAPER_CHANNEL'] = 'rbxassetid://7225389512',
					['TV_STATIC'] = 'rbxassetid://7256209920',
					['TURRET_ON'] = 'rbxassetid://7290176291',
					['TURRET_OFF'] = 'rbxassetid://7290176380',
					['TURRET_ROTATE'] = 'rbxassetid://7290176421',
					['TURRET_SHOOT'] = 'rbxassetid://7290187805',
					['WIZARD_LIGHTNING_CAST'] = 'rbxassetid://7262989886',
					['WIZARD_LIGHTNING_LAND'] = 'rbxassetid://7263165647',
					['WIZARD_LIGHTNING_STRIKE'] = 'rbxassetid://7263165347',
					['WIZARD_ORB_CAST'] = 'rbxassetid://7263165448',
					['WIZARD_ORB_TRAVEL_LOOP'] = 'rbxassetid://7263165579',
					['WIZARD_ORB_CONTACT_LOOP'] = 'rbxassetid://7263165647',
					['BATTLE_PASS_PROGRESS_LEVEL_UP'] = 'rbxassetid://7331597283',
					['BATTLE_PASS_PROGRESS_EXP_GAIN'] = 'rbxassetid://7331597220',
					['FLAMETHROWER_UPGRADE'] = 'rbxassetid://7310273053',
					['FLAMETHROWER_USE'] = 'rbxassetid://7310273125',
					['BRITTLE_HIT'] = 'rbxassetid://7310273179',
					['EXTINGUISH'] = 'rbxassetid://7310273015',
					['RAVEN_SPACE_AMBIENT'] = 'rbxassetid://7341443286',
					['RAVEN_WING_FLAP'] = 'rbxassetid://7341443378',
					['RAVEN_CAW'] = 'rbxassetid://7341443447',
					['JADE_HAMMER_THUD'] = 'rbxassetid://7342299402',
					['STATUE'] = 'rbxassetid://7344166851',
					['CONFETTI'] = 'rbxassetid://7344278405',
					['HEART'] = 'rbxassetid://7345120916',
					['SPRAY'] = 'rbxassetid://7361499529',
					['BEEHIVE_PRODUCE'] = 'rbxassetid://7378100183',
					['DEPOSIT_BEE'] = 'rbxassetid://7378100250',
					['CATCH_BEE'] = 'rbxassetid://7378100305',
					['BEE_NET_SWING'] = 'rbxassetid://7378100350',
					['ASCEND'] = 'rbxassetid://7378387334',
					['BED_ALARM'] = 'rbxassetid://7396762708',
					['BOUNTY_CLAIMED'] = 'rbxassetid://7396751941',
					['BOUNTY_ASSIGNED'] = 'rbxassetid://7396752155',
					['BAGUETTE_HIT'] = 'rbxassetid://7396760547',
					['BAGUETTE_SWING'] = 'rbxassetid://7396760496',
					['TESLA_ZAP'] = 'rbxassetid://7497477336',
					['SPIRIT_TRIGGERED'] = 'rbxassetid://7498107251',
					['SPIRIT_EXPLODE'] = 'rbxassetid://7498107327',
					['ANGEL_LIGHT_ORB_CREATE'] = 'rbxassetid://7552134231',
					['ANGEL_LIGHT_ORB_HEAL'] = 'rbxassetid://7552134868',
					['ANGEL_VOID_ORB_CREATE'] = 'rbxassetid://7552135942',
					['ANGEL_VOID_ORB_HEAL'] = 'rbxassetid://7552136927',
					['DODO_BIRD_JUMP'] = 'rbxassetid://7618085391',
					['DODO_BIRD_DOUBLE_JUMP'] = 'rbxassetid://7618085771',
					['DODO_BIRD_MOUNT'] = 'rbxassetid://7618085486',
					['DODO_BIRD_DISMOUNT'] = 'rbxassetid://7618085571',
					['DODO_BIRD_SQUAWK_1'] = 'rbxassetid://7618085870',
					['DODO_BIRD_SQUAWK_2'] = 'rbxassetid://7618085657',
					['SHIELD_CHARGE_START'] = 'rbxassetid://7730842884',
					['SHIELD_CHARGE_LOOP'] = 'rbxassetid://7730843006',
					['SHIELD_CHARGE_BASH'] = 'rbxassetid://7730843142',
					['ROCKET_LAUNCHER_FIRE'] = 'rbxassetid://7681584765',
					['ROCKET_LAUNCHER_FLYING_LOOP'] = 'rbxassetid://7681584906',
					['SMOKE_GRENADE_POP'] = 'rbxassetid://7681276062',
					['SMOKE_GRENADE_EMIT_LOOP'] = 'rbxassetid://7681276135',
					['GOO_SPIT'] = 'rbxassetid://7807271610',
					['GOO_SPLAT'] = 'rbxassetid://7807272724',
					['GOO_EAT'] = 'rbxassetid://7813484049',
					['LUCKY_BLOCK_BREAK'] = 'rbxassetid://7682005357',
					['AXOLOTL_SWITCH_TARGETS'] = 'rbxassetid://7344278405',
					['HALLOWEEN_MUSIC'] = 'rbxassetid://7775602786',
					['SNAP_TRAP_SETUP'] = 'rbxassetid://7796078515',
					['SNAP_TRAP_CLOSE'] = 'rbxassetid://7796078695',
					['SNAP_TRAP_CONSUME_MARK'] = 'rbxassetid://7796078825',
					['GHOST_VACUUM_SUCKING_LOOP'] = 'rbxassetid://7814995865',
					['GHOST_VACUUM_SHOOT'] = 'rbxassetid://7806060367',
					['GHOST_VACUUM_CATCH'] = 'rbxassetid://7815151688',
					['FISHERMAN_GAME_START'] = 'rbxassetid://7806060544',
					['FISHERMAN_GAME_PULLING_LOOP'] = 'rbxassetid://7806060638',
					['FISHERMAN_GAME_PROGRESS_INCREASE'] = 'rbxassetid://7806060745',
					['FISHERMAN_GAME_FISH_MOVE'] = 'rbxassetid://7806060863',
					['FISHERMAN_GAME_LOOP'] = 'rbxassetid://7806061057',
					['FISHING_ROD_CAST'] = 'rbxassetid://7806060976',
					['FISHING_ROD_SPLASH'] = 'rbxassetid://7806061193',
					['SPEAR_HIT'] = 'rbxassetid://7807270398',
					['SPEAR_THROW'] = 'rbxassetid://7813485044',
				}
				for i,v in next, (bedwars.CombatController.killSounds) do 
					bedwars.CombatController.killSounds[i] = oldbedwarssoundtable.KILL
				end
				for i,v in next, (bedwars.CombatController.multiKillLoops) do 
					bedwars.CombatController.multiKillLoops[i] = ''
				end
				for i,v in next, (bedwars.ItemTable) do 
					if oldbedwarsicontab[i] then 
						v.image = oldbedwarsicontab[i]
					end
				end			
				for i,v in next, (oldbedwarssoundtable) do 
					local item = bedwars.SoundList[i]
					if item then
						bedwars.SoundList[i] = v
					end
				end	
				local damagetab = debug.getupvalue(bedwars.DamageIndicator, 2)
				damagetab.strokeThickness = false
				damagetab.textSize = 32
				damagetab.blowUpDuration = 0
				damagetab.baseColor = Color3.fromRGB(214, 0, 0)
				damagetab.blowUpSize = 32
				damagetab.blowUpCompleteDuration = 0
				damagetab.anchoredDuration = 0
				debug.setconstant(bedwars.ViewmodelController.show, 37, '')
				debug.setconstant(bedwars.DamageIndicator, 83, Enum.Font.LuckiestGuy)
				debug.setconstant(bedwars.DamageIndicator, 102, 'Enabled')
				debug.setconstant(bedwars.DamageIndicator, 118, 0.3)
				debug.setconstant(bedwars.DamageIndicator, 128, 0.5)
				debug.setupvalue(bedwars.DamageIndicator, 10, {
					Create = function(self, obj, ...)
						task.spawn(function()
							obj.Parent.Parent.Parent.Parent.Velocity = Vector3.new((math.random(-50, 50) / 100) * damagetab.velX, (math.random(50, 60) / 100) * damagetab.velY, (math.random(-50, 50) / 100) * damagetab.velZ)
							local textcompare = obj.Parent.TextColor3
							if textcompare ~= Color3.fromRGB(85, 255, 85) then
								local newtween = tweenService:Create(obj.Parent, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
									TextColor3 = (textcompare == Color3.fromRGB(76, 175, 93) and Color3.new(0, 0, 0) or Color3.new(1, 1, 1))
								})
								task.wait(0.15)
								newtween:Play()
							end
						end)
						return tweenService:Create(obj, ...)
					end
				})
				sethiddenproperty(lightingService, 'Technology', 'ShadowMap')
				lightingService.Ambient = Color3.fromRGB(69, 69, 69)
				lightingService.Brightness = 3
				lightingService.EnvironmentDiffuseScale = 1
				lightingService.EnvironmentSpecularScale = 1
				lightingService.OutdoorAmbient = Color3.fromRGB(69, 69, 69)
				lightingService.Atmosphere.Density = 0.1
				lightingService.Atmosphere.Offset = 0.25
				lightingService.Atmosphere.Color = Color3.fromRGB(198, 198, 198)
				lightingService.Atmosphere.Decay = Color3.fromRGB(104, 112, 124)
				lightingService.Atmosphere.Glare = 0
				lightingService.Atmosphere.Haze = 0
				lightingService.ClockTime = 13
				lightingService.GeographicLatitude = 0
				lightingService.GlobalShadows = false
				lightingService.TimeOfDay = '13:00:00'
				lightingService.Sky.SkyboxBk = 'rbxassetid://7018684000'
				lightingService.Sky.SkyboxDn = 'rbxassetid://6334928194'
				lightingService.Sky.SkyboxFt = 'rbxassetid://7018684000'
				lightingService.Sky.SkyboxLf = 'rbxassetid://7018684000'
				lightingService.Sky.SkyboxRt = 'rbxassetid://7018684000'
				lightingService.Sky.SkyboxUp = 'rbxassetid://7018689553'
			end)
		end,
		Winter = function() 
			task.spawn(function()
				for i,v in next, (lightingService:GetChildren()) do
					if v:IsA('Atmosphere') or v:IsA('Sky') or v:IsA('PostEffect') then
						v:Remove()
					end
				end
				local sky = Instance.new('Sky')
				sky.StarCount = 5000
				sky.SkyboxUp = 'rbxassetid://8139676647'
				sky.SkyboxLf = 'rbxassetid://8139676988'
				sky.SkyboxFt = 'rbxassetid://8139677111'
				sky.SkyboxBk = 'rbxassetid://8139677359'
				sky.SkyboxDn = 'rbxassetid://8139677253'
				sky.SkyboxRt = 'rbxassetid://8139676842'
				sky.SunTextureId = 'rbxassetid://6196665106'
				sky.SunAngularSize = 11
				sky.MoonTextureId = 'rbxassetid://8139665943'
				sky.MoonAngularSize = 30
				sky.Parent = lightingService
				local sunray = Instance.new('SunRaysEffect')
				sunray.Intensity = 0.03
				sunray.Parent = lightingService
				local bloom = Instance.new('BloomEffect')
				bloom.Threshold = 2
				bloom.Intensity = 1
				bloom.Size = 2
				bloom.Parent = lightingService
				local atmosphere = Instance.new('Atmosphere')
				atmosphere.Density = 0.3
				atmosphere.Offset = 0.25
				atmosphere.Color = Color3.fromRGB(198, 198, 198)
				atmosphere.Decay = Color3.fromRGB(104, 112, 124)
				atmosphere.Glare = 0
				atmosphere.Haze = 0
				atmosphere.Parent = lightingService
				local damagetab = debug.getupvalue(bedwars.DamageIndicator, 2)
				damagetab.strokeThickness = false
				damagetab.textSize = 32
				damagetab.blowUpDuration = 0
				damagetab.baseColor = Color3.fromRGB(70, 255, 255)
				damagetab.blowUpSize = 32
				damagetab.blowUpCompleteDuration = 0
				damagetab.anchoredDuration = 0
				debug.setconstant(bedwars.DamageIndicator, 83, Enum.Font.LuckiestGuy)
				debug.setconstant(bedwars.DamageIndicator, 102, 'Enabled')
				debug.setconstant(bedwars.DamageIndicator, 118, 0.3)
				debug.setconstant(bedwars.DamageIndicator, 128, 0.5)
				debug.setupvalue(bedwars.DamageIndicator, 10, {
					Create = function(self, obj, ...)
						task.spawn(function()
							obj.Parent.Parent.Parent.Parent.Velocity = Vector3.new((math.random(-50, 50) / 100) * damagetab.velX, (math.random(50, 60) / 100) * damagetab.velY, (math.random(-50, 50) / 100) * damagetab.velZ)
							local textcompare = obj.Parent.TextColor3
							if textcompare ~= Color3.fromRGB(85, 255, 85) then
								local newtween = tweenService:Create(obj.Parent, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
									TextColor3 = (textcompare == Color3.fromRGB(76, 175, 93) and Color3.new(1, 1, 1) or Color3.new(0, 0, 0))
								})
								task.wait(0.15)
								newtween:Play()
							end
						end)
						return tweenService:Create(obj, ...)
					end
				})
				debug.setconstant(require(lplr.PlayerScripts.TS.controllers.global.hotbar.ui.healthbar['hotbar-healthbar']).HotbarHealthbar.render, 16, 4653055)
			end)
			task.spawn(function()
				local snowpart = Instance.new('Part')
				snowpart.Size = Vector3.new(240, 0.5, 240)
				snowpart.Name = 'SnowParticle'
				snowpart.Transparency = 1
				snowpart.CanCollide = false
				snowpart.Position = Vector3.new(0, 120, 286)
				snowpart.Anchored = true
				snowpart.Parent = workspace
				local snow = Instance.new('ParticleEmitter')
				snow.RotSpeed = NumberRange.new(300)
				snow.VelocitySpread = 35
				snow.Rate = 28
				snow.Texture = 'rbxassetid://8158344433'
				snow.Rotation = NumberRange.new(110)
				snow.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0.16939899325371,0),NumberSequenceKeypoint.new(0.23365999758244,0.62841498851776,0.37158501148224),NumberSequenceKeypoint.new(0.56209099292755,0.38797798752785,0.2771390080452),NumberSequenceKeypoint.new(0.90577298402786,0.51912599802017,0),NumberSequenceKeypoint.new(1,1,0)})
				snow.Lifetime = NumberRange.new(8,14)
				snow.Speed = NumberRange.new(8,18)
				snow.EmissionDirection = Enum.NormalId.Bottom
				snow.SpreadAngle = Vector2.new(35,35)
				snow.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,0,0),NumberSequenceKeypoint.new(0.039760299026966,1.3114800453186,0.32786899805069),NumberSequenceKeypoint.new(0.7554469704628,0.98360699415207,0.44038599729538),NumberSequenceKeypoint.new(1,0,0)})
				snow.Parent = snowpart
				local windsnow = Instance.new('ParticleEmitter')
				windsnow.Acceleration = Vector3.new(0,0,1)
				windsnow.RotSpeed = NumberRange.new(100)
				windsnow.VelocitySpread = 35
				windsnow.Rate = 28
				windsnow.Texture = 'rbxassetid://8158344433'
				windsnow.EmissionDirection = Enum.NormalId.Bottom
				windsnow.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0.16939899325371,0),NumberSequenceKeypoint.new(0.23365999758244,0.62841498851776,0.37158501148224),NumberSequenceKeypoint.new(0.56209099292755,0.38797798752785,0.2771390080452),NumberSequenceKeypoint.new(0.90577298402786,0.51912599802017,0),NumberSequenceKeypoint.new(1,1,0)})
				windsnow.Lifetime = NumberRange.new(8,14)
				windsnow.Speed = NumberRange.new(8,18)
				windsnow.Rotation = NumberRange.new(110)
				windsnow.SpreadAngle = Vector2.new(35,35)
				windsnow.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,0,0),NumberSequenceKeypoint.new(0.039760299026966,1.3114800453186,0.32786899805069),NumberSequenceKeypoint.new(0.7554469704628,0.98360699415207,0.44038599729538),NumberSequenceKeypoint.new(1,0,0)})
				windsnow.Parent = snowpart
				repeat
					task.wait()
					if entityLibrary.isAlive then 
						snowpart.Position = entityLibrary.character.HumanoidRootPart.Position + Vector3.new(0, 100, 0)
					end
				until not vapeInjected
			end)
		end,
		Halloween = function()
			task.spawn(function()
				for i,v in next, (lightingService:GetChildren()) do
					if v:IsA('Atmosphere') or v:IsA('Sky') or v:IsA('PostEffect') then
						v:Remove()
					end
				end
				lightingService.TimeOfDay = '00:00:00'
				pcall(function() workspace.Clouds:Destroy() end)
				local damagetab = debug.getupvalue(bedwars.DamageIndicator, 2)
				damagetab.strokeThickness = false
				damagetab.textSize = 32
				damagetab.blowUpDuration = 0
				damagetab.baseColor = Color3.fromRGB(255, 100, 0)
				damagetab.blowUpSize = 32
				damagetab.blowUpCompleteDuration = 0
				damagetab.anchoredDuration = 0
				debug.setconstant(bedwars.DamageIndicator, 83, Enum.Font.LuckiestGuy)
				debug.setconstant(bedwars.DamageIndicator, 102, 'Enabled')
				debug.setconstant(bedwars.DamageIndicator, 118, 0.3)
				debug.setconstant(bedwars.DamageIndicator, 128, 0.5)
				debug.setupvalue(bedwars.DamageIndicator, 10, {
					Create = function(self, obj, ...)
						task.spawn(function()
							obj.Parent.Parent.Parent.Parent.Velocity = Vector3.new((math.random(-50, 50) / 100) * damagetab.velX, (math.random(50, 60) / 100) * damagetab.velY, (math.random(-50, 50) / 100) * damagetab.velZ)
							local textcompare = obj.Parent.TextColor3
							if textcompare ~= Color3.fromRGB(85, 255, 85) then
								local newtween = tweenService:Create(obj.Parent, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
									TextColor3 = (textcompare == Color3.fromRGB(76, 175, 93) and Color3.new(0, 0, 0) or Color3.new(0, 0, 0))
								})
								task.wait(0.15)
								newtween:Play()
							end
						end)
						return tweenService:Create(obj, ...)
					end
				})
				local colorcorrection = Instance.new('ColorCorrectionEffect')
				colorcorrection.TintColor = Color3.fromRGB(255, 185, 81)
				colorcorrection.Brightness = 0.05
				colorcorrection.Parent = lightingService
				debug.setconstant(require(lplr.PlayerScripts.TS.controllers.global.hotbar.ui.healthbar['hotbar-healthbar']).HotbarHealthbar.render, 16, 16737280)
			end)
		end,
		Valentines = function()
			task.spawn(function()
				for i,v in next, (lightingService:GetChildren()) do
					if v:IsA('Atmosphere') or v:IsA('Sky') or v:IsA('PostEffect') then
						v:Remove()
					end
				end
				local sky = Instance.new('Sky')
				sky.SkyboxBk = 'rbxassetid://1546230803'
				sky.SkyboxDn = 'rbxassetid://1546231143'
				sky.SkyboxFt = 'rbxassetid://1546230803'
				sky.SkyboxLf = 'rbxassetid://1546230803'
				sky.SkyboxRt = 'rbxassetid://1546230803'
				sky.SkyboxUp = 'rbxassetid://1546230451'
				sky.Parent = lightingService
				pcall(function() workspace.Clouds:Destroy() end)
				local damagetab = debug.getupvalue(bedwars.DamageIndicator, 2)
				damagetab.strokeThickness = false
				damagetab.textSize = 32
				damagetab.blowUpDuration = 0
				damagetab.baseColor = Color3.fromRGB(255, 132, 178)
				damagetab.blowUpSize = 32
				damagetab.blowUpCompleteDuration = 0
				damagetab.anchoredDuration = 0
				debug.setconstant(bedwars.DamageIndicator, 83, Enum.Font.LuckiestGuy)
				debug.setconstant(bedwars.DamageIndicator, 102, 'Enabled')
				debug.setconstant(bedwars.DamageIndicator, 118, 0.3)
				debug.setconstant(bedwars.DamageIndicator, 128, 0.5)
				debug.setupvalue(bedwars.DamageIndicator, 10, {
					Create = function(self, obj, ...)
						task.spawn(function()
							obj.Parent.Parent.Parent.Parent.Velocity = Vector3.new((math.random(-50, 50) / 100) * damagetab.velX, (math.random(50, 60) / 100) * damagetab.velY, (math.random(-50, 50) / 100) * damagetab.velZ)
							local textcompare = obj.Parent.TextColor3
							if textcompare ~= Color3.fromRGB(85, 255, 85) then
								local newtween = tweenService:Create(obj.Parent, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
									TextColor3 = (textcompare == Color3.fromRGB(76, 175, 93) and Color3.new(0, 0, 0) or Color3.new(0, 0, 0))
								})
								task.wait(0.15)
								newtween:Play()
							end
						end)
						return tweenService:Create(obj, ...)
					end
				})
				local colorcorrection = Instance.new('ColorCorrectionEffect')
				colorcorrection.TintColor = Color3.fromRGB(255, 199, 220)
				colorcorrection.Brightness = 0.05
				colorcorrection.Parent = lightingService
				debug.setconstant(require(lplr.PlayerScripts.TS.controllers.global.hotbar.ui.healthbar['hotbar-healthbar']).HotbarHealthbar.render, 16, 16745650)
			end)
		end
	}

	GameTheme = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = 'GameTheme',
		Function = function(calling) 
			if calling then 
				if not transformed then
					transformed = true
					themefunctions[GameThemeMode.Value]()
					repeat task.wait() until shared.VapeFullyLoaded
					if isEnabled('Atmosphere') then 
						GuiLibrary.ObjectsThatCanBeSaved.AtmosphereOptionsButton.Api.ToggleButton()
						GuiLibrary.ObjectsThatCanBeSaved.AtmosphereOptionsButton.Api.ToggleButton() 
					end
					task.wait()
					if isEnabled('HealthbarMods') then 
						GuiLibrary.ObjectsThatCanBeSaved.HealthbarModsOptionsButton.Api.ToggleButton()
						GuiLibrary.ObjectsThatCanBeSaved.HealthbarModsOptionsButton.Api.ToggleButton() 
					end
				else
					GameTheme.ToggleButton(false)
				end
			else
				InfoNotification('GameTheme', 'Disabled Next Game', 10)
			end
		end,
		ExtraText = function()
			return GameThemeMode.Value
		end
	})
	GameThemeMode = GameTheme.CreateDropdown({
		Name = 'Theme',
		Function = function() end,
		List = {'Old', 'Winter', 'Halloween', 'Valentines'}
	})
end)

runFunction(function()
	local oldkilleffect
	local KillEffectMode = {Value = 'Gravity'}
	local KillEffectList = {Value = 'None'}
	local KillEffectName2 = {}
	local killeffects = {
		Gravity = function(p3, p4, p5, p6)
			p5:BreakJoints()
			task.spawn(function()
				local partvelo = {}
				for i,v in next, (p5:GetDescendants()) do 
					if v:IsA('BasePart') then 
						partvelo[v.Name] = v.Velocity * 3
					end
				end
				p5.Archivable = true
				local clone = p5:Clone()
				clone.Humanoid.Health = 100
				clone.Parent = workspace
				local nametag = clone:FindFirstChild('Nametag', true)
				if nametag then nametag:Destroy() end
				game:GetService('Debris'):AddItem(clone, 30)
				p5:Destroy()
				task.wait(0.01)
				clone.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
				clone:BreakJoints()
				task.wait(0.01)
				for i,v in next, (clone:GetDescendants()) do 
					if v:IsA('BasePart') then 
						local bodyforce = Instance.new('BodyForce')
						bodyforce.Force = Vector3.new(0, (workspace.Gravity - 10) * v:GetMass(), 0)
						bodyforce.Parent = v
						v.CanCollide = true
						v.Velocity = partvelo[v.Name] or Vector3.zero
					end
				end
			end)
		end,
		Lightning = function(p3, p4, p5, p6)
			p5:BreakJoints()
			local startpos = 1125
			local startcf = p5.PrimaryPart.CFrame.p - Vector3.new(0, 8, 0)
			local newpos = Vector3.new((math.random(1, 10) - 5) * 2, startpos, (math.random(1, 10) - 5) * 2)
			for i = startpos - 75, 0, -75 do 
				local newpos2 = Vector3.new((math.random(1, 10) - 5) * 2, i, (math.random(1, 10) - 5) * 2)
				if i == 0 then 
					newpos2 = Vector3.zero
				end
				local part = Instance.new('Part')
				part.Size = Vector3.new(1.5, 1.5, 77)
				part.Material = Enum.Material.SmoothPlastic
				part.Anchored = true
				part.Material = Enum.Material.Neon
				part.CanCollide = false
				part.CFrame = CFrame.new(startcf + newpos + ((newpos2 - newpos) * 0.5), startcf + newpos2)
				part.Parent = workspace
				local part2 = part:Clone()
				part2.Size = Vector3.new(3, 3, 78)
				part2.Color = Color3.new(0.7, 0.7, 0.7)
				part2.Transparency = 0.7
				part2.Material = Enum.Material.SmoothPlastic
				part2.Parent = workspace
				game:GetService('Debris'):AddItem(part, 0.5)
				game:GetService('Debris'):AddItem(part2, 0.5)
				bedwars.QueryUtil:setQueryIgnored(part, true)
				bedwars.QueryUtil:setQueryIgnored(part2, true)
				if i == 0 then 
					local soundpart = Instance.new('Part')
					soundpart.Transparency = 1
					soundpart.Anchored = true 
					soundpart.Size = Vector3.zero
					soundpart.Position = startcf
					soundpart.Parent = workspace
					bedwars.QueryUtil:setQueryIgnored(soundpart, true)
					local sound = Instance.new('Sound')
					sound.SoundId = 'rbxassetid://6993372814'
					sound.Volume = 2
					sound.Pitch = 0.5 + (math.random(1, 3) / 10)
					sound.Parent = soundpart
					sound:Play()
					sound.Ended:Connect(function()
						soundpart:Destroy()
					end)
				end
				newpos = newpos2
			end
		end
	}
	local KillEffectName = {}
	for i,v in next, (bedwars.KillEffectMeta) do 
		table.insert(KillEffectName, v.name)
		KillEffectName[v.name] = i
	end
	table.sort(KillEffectName, function(a, b) return a:lower() < b:lower() end)
	local KillEffect = {}
	KillEffect = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = 'KillEffect',
		Function = function(calling)
			if calling then 
				task.spawn(function()
					repeat task.wait() until bedwarsStore.matchState ~= 0 or not KillEffect.Enabled
					if KillEffect.Enabled then
						lplr:SetAttribute('KillEffectType', 'none')
						if KillEffectMode.Value == 'Bedwars' then 
							lplr:SetAttribute('KillEffectType', KillEffectName[KillEffectList.Value])
						end
					end
				end)
				oldkilleffect = bedwars.DefaultKillEffect.onKill
				bedwars.DefaultKillEffect.onKill = function(p3, p4, p5, p6)
					killeffects[KillEffectMode.Value](p3, p4, p5, p6)
				end
			else
				bedwars.DefaultKillEffect.onKill = oldkilleffect
			end
		end
	})
	local modes = {'Bedwars'}
	for i,v in next, (killeffects) do 
		table.insert(modes, i)
	end
	KillEffectMode = KillEffect.CreateDropdown({
		Name = 'Mode',
		Function = function() 
			if KillEffect.Enabled then 
				KillEffect.ToggleButton(false)
				KillEffect.ToggleButton(false)
			end
		end,
		List = modes
	})
	KillEffectList = KillEffect.CreateDropdown({
		Name = 'Bedwars',
		Function = function() 
			if KillEffect.Enabled then 
				KillEffect.ToggleButton(false)
				KillEffect.ToggleButton(false)
			end
		end,
		List = KillEffectName
	})
end)

runFunction(function()
	local KitESP = {}
	local espobjs = {}
	local espfold = Instance.new('Folder')
	espfold.Parent = GuiLibrary.MainGui

	local function espadd(v, icon)
		local billboard = Instance.new('BillboardGui')
		billboard.Parent = espfold
		billboard.Name = 'iron'
		billboard.StudsOffsetWorldSpace = Vector3.new(0, 3, 1.5)
		billboard.Size = UDim2.new(0, 32, 0, 32)
		billboard.AlwaysOnTop = true
		billboard.Adornee = v
		local image = Instance.new('ImageLabel')
		image.BackgroundTransparency = 0.5
		image.BorderSizePixel = 0
		image.Image = bedwars.getIcon({itemType = icon}, true)
		image.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		image.Size = UDim2.new(0, 32, 0, 32)
		image.AnchorPoint = Vector2.new(0.5, 0.5)
		image.Parent = billboard
		local uicorner = Instance.new('UICorner')
		uicorner.CornerRadius = UDim.new(0, 4)
		uicorner.Parent = image
		espobjs[v] = billboard
	end

	local function addKit(tag, icon)
		table.insert(KitESP.Connections, collectionService:GetInstanceAddedSignal(tag):Connect(function(v)
			espadd(v.PrimaryPart, icon)
		end))
		table.insert(KitESP.Connections, collectionService:GetInstanceRemovedSignal(tag):Connect(function(v)
			if espobjs[v.PrimaryPart] then
				espobjs[v.PrimaryPart]:Destroy()
				espobjs[v.PrimaryPart] = nil
			end
		end))
		for i,v in next, (collectionService:GetTagged(tag)) do 
			espadd(v.PrimaryPart, icon)
		end
	end

	KitESP = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = 'KitESP',
		Function = function(calling) 
			if calling then
				task.spawn(function()
					repeat task.wait() until bedwarsStore.equippedKit ~= ''
					if KitESP.Enabled then
						if bedwarsStore.equippedKit == 'metal_detector' then
							addKit('hidden-metal', 'iron')
						elseif bedwarsStore.equippedKit == 'beekeeper' then
							addKit('bee', 'bee')
						elseif bedwarsStore.equippedKit == 'bigman' then
							addKit('treeOrb', 'natures_essence_1')
						end
					end
				end)
			else
				espfold:ClearAllChildren()
				table.clear(espobjs)
			end
		end
	})
end)

runFunction(function()
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
	local NameTagsDisplayName = {}
	local NameTagsHealth = {}
	local NameTagsDistance = {}
	local NameTagsBackground = {}
	local NameTagsScale = {Value = 10}
	local NameTagsFont = {Value = "SourceSans"}
	local NameTagsTeammates = {}
	local NameTagsShowInventory = {}
	local NameTagsRangeLimit = {Value = 0}
	local fontitems = {"SourceSans"}
	local nametagstrs = {}
	local nametagsizes = {}
	local kititems = {
		jade = "jade_hammer",
		archer = "tactical_crossbow",
		angel = "",
		cowgirl = "lasso",
		dasher = "wood_dao",
		axolotl = "axolotl",
		yeti = "snowball",
		smoke = "smoke_block",
		trapper = "snap_trap",
		pyro = "flamethrower",
		davey = "cannon",
		regent = "void_axe", 
		baker = "apple",
		builder = "builder_hammer",
		farmer_cletus = "carrot_seeds",
		melody = "guitar",
		barbarian = "rageblade",
		gingerbread_man = "gumdrop_bounce_pad",
		spirit_catcher = "spirit",
		fisherman = "fishing_rod",
		oil_man = "oil_consumable",
		santa = "tnt",
		miner = "miner_pickaxe",
		sheep_herder = "crook",
		beast = "speed_potion",
		metal_detector = "metal_detector",
		cyber = "drone",
		vesta = "damage_banner",
		lumen = "light_sword",
		ember = "infernal_saber",
		queen_bee = "bee"
	}

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
			local rendertag = RenderFunctions.playerTags[plr.Player] 
			if rendertag then 
				nametagstrs[plr.Player] = '['..rendertag.Text..'] '..nametagstrs[plr.Player]
			end
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
			local hand = Instance.new("ImageLabel")
			hand.Size = UDim2.new(0, 30, 0, 30)
			hand.Name = "Hand"
			hand.BackgroundTransparency = 1
			hand.Position = UDim2.new(0, -30, 0, -30)
			hand.Image = ""
			hand.Parent = thing
			local helmet = hand:Clone()
			helmet.Name = "Helmet"
			helmet.Position = UDim2.new(0, 5, 0, -30)
			helmet.Parent = thing
			local chest = hand:Clone()
			chest.Name = "Chestplate"
			chest.Position = UDim2.new(0, 35, 0, -30)
			chest.Parent = thing
			local boots = hand:Clone()
			boots.Name = "Boots"
			boots.Position = UDim2.new(0, 65, 0, -30)
			boots.Parent = thing
			local kit = hand:Clone()
			kit.Name = "Kit"
			task.spawn(function()
				repeat task.wait() until plr.Player:GetAttribute("PlayingAsKit") ~= ""
				if kit then
					kit.Image = kititems[plr.Player:GetAttribute("PlayingAsKit")] and bedwars.getIcon({itemType = kititems[plr.Player:GetAttribute("PlayingAsKit")]}, NameTagsShowInventory.Enabled) or ""
				end
			end)
			kit.Position = UDim2.new(0, -30, 0, -65)
			kit.Parent = thing
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
			local rendertag = RenderFunctions.playerTags[plr.Player] 
			if rendertag then 
				nametagstrs[plr.Player] = '['..rendertag.Text..'] '..nametagstrs[plr.Player]
			end
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
				for i2,v2 in next, (v.Main) do
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
				local rendertag = RenderFunctions.playerTags[ent.Player] 
				if rendertag then 
					nametagstrs[plr.Player] = '['..rendertag.Text..'] '..nametagstrs[ent.Player]
				end
				if NameTagsHealth.Enabled then
					local color = Color3.fromHSV(math.clamp(ent.Humanoid.Health / ent.Humanoid.MaxHealth, 0, 1) / 2.5, 0.89, 1)
					nametagstrs[ent.Player] = nametagstrs[ent.Player]..' <font color="rgb('..tostring(math.floor(color.R * 255))..','..tostring(math.floor(color.G * 255))..','..tostring(math.floor(color.B * 255))..')">'..math.round(ent.Humanoid.Health).."</font>"
				end
				if NameTagsDistance.Enabled then 
					nametagstrs[ent.Player] = '<font color="rgb(85, 255, 85)">[</font><font color="rgb(255, 255, 255)">%s</font><font color="rgb(85, 255, 85)">]</font> '..nametagstrs[ent.Player]
				end
				if NameTagsShowInventory.Enabled then 
					local inventory = bedwarsStore.inventories[ent.Player] or {armor = {}}
					if inventory.hand then
						v.Main.Hand.Image = bedwars.getIcon(inventory.hand, NameTagsShowInventory.Enabled)
						if v.Main.Hand.Image:find("rbxasset://") then
							v.Main.Hand.ResampleMode = Enum.ResamplerMode.Pixelated
						end
					else
						v.Main.Hand.Image = ""
					end
					if inventory.armor[4] then
						v.Main.Helmet.Image = bedwars.getIcon(inventory.armor[4], NameTagsShowInventory.Enabled)
						if v.Main.Helmet.Image:find("rbxasset://") then
							v.Main.Helmet.ResampleMode = Enum.ResamplerMode.Pixelated
						end
					else
						v.Main.Helmet.Image = ""
					end
					if inventory.armor[5] then
						v.Main.Chestplate.Image = bedwars.getIcon(inventory.armor[5], NameTagsShowInventory.Enabled)
						if v.Main.Chestplate.Image:find("rbxasset://") then
							v.Main.Chestplate.ResampleMode = Enum.ResamplerMode.Pixelated
						end
					else
						v.Main.Chestplate.Image = ""
					end
					if inventory.armor[6] then
						v.Main.Boots.Image = bedwars.getIcon(inventory.armor[6], NameTagsShowInventory.Enabled)
						if v.Main.Boots.Image:find("rbxasset://") then
							v.Main.Boots.ResampleMode = Enum.ResamplerMode.Pixelated
						end
					else
						v.Main.Boots.Image = ""
					end
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
				local rendertag = RenderFunctions.playerTags[ent.Player] 
				if rendertag then 
					nametagstrs[plr.Player] = '['..rendertag.Text..'] '..nametagstrs[ent.Player]
				end
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
			for i,v in next, (nametagsfolderdrawing) do 
				v.Main.TextColor3 = getPlayerColor(v.entity.Player) or color
			end
		end,
		Drawing = function(hue, sat, value)
			local color = Color3.fromHSV(hue, sat, value)
			for i,v in next, (nametagsfolderdrawing) do 
				v.Main.Text.Color = getPlayerColor(v.entity.Player) or color
			end
		end
	}

	local nametagloop = {
		Normal = function()
			for i,v in next, (nametagsfolderdrawing) do 
				local headPos, headVis = worldtoscreenpoint((v.entity.RootPart:GetRenderCFrame() * CFrame.new(0, v.entity.Head.Size.Y + v.entity.RootPart.Size.Y, 0)).Position)
				if not headVis then 
					v.Main.Visible = false
					continue
				end
				local mag = entityLibrary.isAlive and math.floor((entityLibrary.character.HumanoidRootPart.Position - v.entity.RootPart.Position).Magnitude) or 0
				if NameTagsRangeLimit.Value ~= 0 and mag > NameTagsRangeLimit.Value then 
					v.Main.Visible = false
					continue
				end
				if NameTagsDistance.Enabled then
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
			for i,v in next, (nametagsfolderdrawing) do 
				local headPos, headVis = worldtoscreenpoint((v.entity.RootPart:GetRenderCFrame() * CFrame.new(0, v.entity.Head.Size.Y + v.entity.RootPart.Size.Y, 0)).Position)
				if not headVis then 
					v.Main.Text.Visible = false
					v.Main.BG.Visible = false
					continue
				end
				local mag = entityLibrary.isAlive and math.floor((entityLibrary.character.HumanoidRootPart.Position - v.entity.RootPart.Position).Magnitude) or 0
				if NameTagsRangeLimit.Value ~= 0 and mag > NameTagsRangeLimit.Value then 
					v.Main.Text.Visible = false
					v.Main.BG.Visible = false
					continue
				end
				if NameTagsDistance.Enabled then
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

	local NameTags = {}
	NameTags = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "NameTags", 
		Function = function(calling) 
			if calling then
				methodused = NameTagsDrawing.Enabled and "Drawing" or "Normal"
				if nametagfuncs2[methodused] then
					table.insert(NameTags.Connections, entityLibrary.entityRemovedEvent:Connect(nametagfuncs2[methodused]))
				end
				if nametagfuncs1[methodused] then
					local addfunc = nametagfuncs1[methodused]
					for i,v in next, (entityLibrary.entityList) do 
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
					for i,v in next, (entityLibrary.entityList) do 
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
					for i,v in next, (nametagsfolderdrawing) do 
						nametagfuncs2[methodused](i)
					end
				end
			end
		end,
		HoverText = "Renders nametags on entities through walls."
	})
	for i,v in next, (Enum.Font:GetEnumItems()) do 
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
	NameTagsRangeLimit = NameTags.CreateSlider({
		Name = "Range",
		Function = function() end,
		Min = 0,
		Max = 1000,
		Default = 0
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
	NameTagsShowInventory = NameTags.CreateToggle({
		Name = "Equipment",
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end,
		Default = true
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
	local SongBeats = {}
	local SongBeatsList = {ObjectList = {}}
	local SongBeatsIntensity = {Value = 5}
	local SongTween
	local SongAudio

	local function PlaySong(arg)
		local args = arg:split(':')
		local song = isfile(args[1]) and getcustomasset(args[1]) or tonumber(args[1]) and 'rbxassetid://'..args[1]
		if not song then 
			warningNotification('SongBeats', 'missing music file '..args[1], 5)
			SongBeats.ToggleButton(false)
			return
		end
		local bpm = 1 / (args[2] / 60)
		SongAudio = Instance.new('Sound')
		SongAudio.SoundId = song
		SongAudio.Parent = workspace
		SongAudio:Play()
		repeat
			repeat task.wait() until SongAudio.IsLoaded or (not SongBeats.Enabled) 
			if (not SongBeats.Enabled) then break end
			local newfov = math.min(bedwars.FovController:getFOV() * (bedwars.SprintController.sprinting and 1.1 or 1), 120)
			gameCamera.FieldOfView = newfov - SongBeatsIntensity.Value
			if SongTween then SongTween:Cancel() end
			SongTween = game:GetService('TweenService'):Create(gameCamera, TweenInfo.new(0.2), {FieldOfView = newfov})
			SongTween:Play()
			task.wait(bpm)
		until (not SongBeats.Enabled) or SongAudio.IsPaused
	end

	SongBeats = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = 'SongBeats',
		Function = function(calling)
			if calling then 
				task.spawn(function()
					if #SongBeatsList.ObjectList <= 0 then 
						warningNotification('SongBeats', 'no songs', 5)
						SongBeats.ToggleButton(false)
						return
					end
					local lastChosen
					repeat
						local newSong
						repeat newSong = SongBeatsList.ObjectList[Random.new():NextInteger(1, #SongBeatsList.ObjectList)] task.wait() until newSong ~= lastChosen or #SongBeatsList.ObjectList <= 1
						lastChosen = newSong
						PlaySong(newSong)
						if not SongBeats.Enabled then break end
						task.wait(2)
					until (not SongBeats.Enabled)
				end)
			else
				if SongAudio then SongAudio:Destroy() end
				if SongTween then SongTween:Cancel() end
				gameCamera.FieldOfView = bedwars.FovController:getFOV() * (bedwars.SprintController.sprinting and 1.1 or 1)
			end
		end
	})
	SongBeatsList = SongBeats.CreateTextList({
		Name = 'SongList',
		TempText = 'songpath:bpm'
	})
	SongBeatsIntensity = SongBeats.CreateSlider({
		Name = 'Intensity',
		Function = function() end,
		Min = 1,
		Max = 10,
		Default = 5
	})
end)

--[[runFunction(function()
	local performed = false
	GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = 'UICleanup',
		Function = function(calling)
			if calling and not performed and executor:lower():find('fluxus') == nil then 
				performed = true
				task.spawn(function()
					local hotbar = require(lplr.PlayerScripts.TS.controllers.global.hotbar.ui['hotbar-app']).HotbarApp
					local hotbaropeninv = require(lplr.PlayerScripts.TS.controllers.global.hotbar.ui['hotbar-open-inventory']).HotbarOpenInventory
					local topbarbutton = require(replicatedStorageService['rbxts_include']['node_modules']['@easy-games']['game-core'].out).TopBarButton
					local gametheme = require(replicatedStorageService['rbxts_include']['node_modules']['@easy-games']['game-core'].out.shared.ui['game-theme']).GameTheme
					bedwars.AppController:closeApp('TopBarApp')
					local oldrender = topbarbutton.render
					topbarbutton.render = function(self) 
						local res = oldrender(self)
						if not self.props.Text then
							return bedwars.Roact.createElement('TextButton', {Visible = false}, {})
						end
						return res
					end
					hotbaropeninv.render = function(self) 
						return bedwars.Roact.createElement('TextButton', {Visible = false}, {})
					end
					pcall(function()
						debug.setconstant(hotbar.render, 52, 0.9975)
						debug.setconstant(hotbar.render, 73, 100)
						debug.setconstant(hotbar.render, 89, 1)
						debug.setconstant(hotbar.render, 90, 0.04)
						debug.setconstant(hotbar.render, 91, -0.03)
						debug.setconstant(hotbar.render, 109, 1.35)
						debug.setconstant(hotbar.render, 110, 0)
						debug.setconstant(debug.getupvalue(hotbar.render, 11).render, 30, 1)
						debug.setconstant(debug.getupvalue(hotbar.render, 11).render, 31, 0.175)
						debug.setconstant(debug.getupvalue(hotbar.render, 11).render, 33, -0.101)
						debug.setconstant(debug.getupvalue(hotbar.render, 18).render, 71, 0)
						debug.setconstant(debug.getupvalue(hotbar.render, 18).tweenPosition, 16, 0) 
					end)
					gametheme.topBarBGTransparency = 0.5
					bedwars.TopBarController:mountHud()
					game:GetService('StarterGui'):SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
					bedwars.AbilityUIController.abilityButtonsScreenGui.Visible = false
					bedwars.MatchEndScreenController.waitUntilDisplay = function() return false end
					task.spawn(function()
						repeat
							task.wait()
							local gui = lplr.PlayerGui:FindFirstChild('StatusEffectHudScreen')
							if gui then gui.Enabled = false break end
						until false
					end)
					task.spawn(function()
						repeat task.wait() until bedwarsStore.matchState ~= 0
						if bedwars.ClientStoreHandler:getState().Game.customMatch == nil then 
							debug.setconstant(bedwars.QueueCard.render, 9, 0.1)
						end
					end)
					local slot = bedwars.ClientStoreHandler:getState().Inventory.observedInventory.hotbarSlot
					bedwars.ClientStoreHandler:dispatch({
						type = 'InventorySelectHotbarSlot',
						slot = slot + 1 % 8
					})
					bedwars.ClientStoreHandler:dispatch({
						type = 'InventorySelectHotbarSlot',
						slot = slot
					})
				end)
			end
		end
	})
end)]]

runFunction(function()
	local AntiAFK = {}
	AntiAFK = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'AntiAFK',
		Function = function(calling)
			if calling then 
				task.spawn(function()
					repeat 
						task.wait(5) 
						bedwars.ClientHandler:Get('AfkInfo'):SendToServer({
							afk = false
						})
					until (not AntiAFK.Enabled)
				end)
			end
		end
	})
end)

runFunction(function()
	local AutoBalloonPart
	local AutoBalloonConnection
	local AutoBalloonDelay = {Value = 10}
	local AutoBalloonLegit = {}
	local AutoBalloonypos = 0
	local balloondebounce = false
	local AutoBalloon = {}
	AutoBalloon = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'AutoBalloon', 
		Function = function(calling)
			if calling then
				task.spawn(function()
					repeat task.wait() until bedwarsStore.matchState ~= 0 or  not vapeInjected
					if vapeInjected and AutoBalloonypos == 0 and AutoBalloon.Enabled then
						local lowestypos = 99999
						for i,v in next, (bedwarsStore.blocks) do 
							local newray = workspace:Raycast(v.Position + Vector3.new(0, 800, 0), Vector3.new(0, -1000, 0), bedwarsStore.blockRaycast)
							if i % 200 == 0 then 
								task.wait(0.06)
							end
							if newray and newray.Position.Y <= lowestypos then
								lowestypos = newray.Position.Y
							end
						end
						AutoBalloonypos = lowestypos - 8
					end
				end)
				task.spawn(function()
					repeat task.wait() until AutoBalloonypos ~= 0
					if AutoBalloon.Enabled then
						AutoBalloonPart = Instance.new('Part')
						AutoBalloonPart.CanCollide = false
						AutoBalloonPart.Size = Vector3.new(10000, 1, 10000)
						AutoBalloonPart.Anchored = true
						AutoBalloonPart.Transparency = 1
						AutoBalloonPart.Material = Enum.Material.Neon
						AutoBalloonPart.Color = Color3.fromRGB(135, 29, 139)
						AutoBalloonPart.Position = Vector3.new(0, AutoBalloonypos - 50, 0)
						AutoBalloonConnection = AutoBalloonPart.Touched:Connect(function(touchedpart)
							if entityLibrary.isAlive and touchedpart == lplr.Character.HumanoidRootPart and balloondebounce == false then
								autobankballoon = true
								balloondebounce = true
								local oldtool = bedwarsStore.localHand.tool
								for i = 1, 3 do
									if getItem('balloon') and (AutoBalloonLegit.Enabled and getHotbarSlot('balloon') or AutoBalloonLegit.Enabled == false) and (lplr.Character:GetAttribute('InflatedBalloons') and lplr.Character:GetAttribute('InflatedBalloons') < 3 or lplr.Character:GetAttribute('InflatedBalloons') == nil) then
										if AutoBalloonLegit.Enabled then
											if getHotbarSlot('balloon') then
												bedwars.ClientStoreHandler:dispatch({
													type = 'InventorySelectHotbarSlot', 
													slot = getHotbarSlot('balloon')
												})
												task.wait(AutoBalloonDelay.Value / 100)
												bedwars.BalloonController:inflateBalloon()
											end
										else
											task.wait(AutoBalloonDelay.Value / 100)
											bedwars.BalloonController:inflateBalloon()
										end
									end
								end
								if AutoBalloonLegit.Enabled and oldtool and getHotbarSlot(oldtool.Name) then
									task.wait(0.2)
									bedwars.ClientStoreHandler:dispatch({
										type = 'InventorySelectHotbarSlot', 
										slot = (getHotbarSlot(oldtool.Name) or 0)
									})
								end
								balloondebounce = false
								autobankballoon = false
							end
						end)
						AutoBalloonPart.Parent = workspace
					end
				end)
			else
				if AutoBalloonConnection then AutoBalloonConnection:Disconnect() end
				if AutoBalloonPart then
					AutoBalloonPart:Remove() 
				end
			end
		end, 
		HoverText = 'Automatically Inflates Balloons'
	})
	AutoBalloonDelay = AutoBalloon.CreateSlider({
		Name = 'Delay',
		Min = 1,
		Max = 50,
		Default = 20,
		Function = function() end,
		HoverText = 'Delay to inflate balloons.'
	})
	AutoBalloonLegit = AutoBalloon.CreateToggle({
		Name = 'Legit Mode',
		Function = function() end,
		HoverText = 'Switches to balloons in hotbar and inflates them.'
	})
end)

local autobankapple = false
runFunction(function()
	local AutoBuy = {}
	local AutoBuyArmor = {}
	local AutoBuySword = {}
	local AutoBuyUpgrades = {}
	local AutoBuyGen = {}
	local AutoBuyProt = {}
	local AutoBuySharp = {}
	local AutoBuyDestruction = {}
	local AutoBuyDiamond = {}
	local AutoBuyAlarm = {}
	local AutoBuyGui = {}
	local AutoBuyTierSkip = {}
	local AutoBuyRange = {Value = 20}
	local AutoBuyCustom = {ObjectList = {}, RefreshList = function() end}
	local AutoBankUIToggle = {}
	local AutoBankDeath = {}
	local AutoBankStay = {}
	local buyingthing = false
	local shoothook
	local bedwarsshopnpcs = {}
	local id
	local armors = {
		[1] = 'leather_chestplate',
		[2] = 'iron_chestplate',
		[3] = 'diamond_chestplate',
		[4] = 'emerald_chestplate'
	}

	local swords = {
		[1] = 'wood_sword',
		[2] = 'stone_sword',
		[3] = 'iron_sword',
		[4] = 'diamond_sword',
		[5] = 'emerald_sword'
	}

	local axes = {
		[1] = 'wood_axe',
		[2] = 'stone_axe',
		[3] = 'iron_axe',
		[4] = 'diamond_axe'
	}

	local pickaxes = {
		[1] = 'wood_pickaxe',
		[2] = 'stone_pickaxe',
		[3] = 'iron_pickaxe',
		[4] = 'diamond_pickaxe'
	}

	task.spawn(function()
		repeat task.wait() until bedwarsStore.matchState ~= 0 or not vapeInjected
		for i,v in next, (collectionService:GetTagged('BedwarsItemShop')) do
			table.insert(bedwarsshopnpcs, {Position = v.Position, TeamUpgradeNPC = true, Id = v.Name})
		end
		for i,v in next, (collectionService:GetTagged('BedwarsTeamUpgrader')) do
			table.insert(bedwarsshopnpcs, {Position = v.Position, TeamUpgradeNPC = false, Id = v.Name})
		end
	end)

	local function nearNPC(range)
		local npc, npccheck, enchant, newid = nil, false, false, nil
		if entityLibrary.isAlive then
			local enchanttab = {}
			for i,v in next, (collectionService:GetTagged('broken-enchant-table')) do 
				table.insert(enchanttab, v)
			end
			for i,v in next, (collectionService:GetTagged('enchant-table')) do 
				table.insert(enchanttab, v)
			end
			for i,v in next, (enchanttab) do 
				if ((RenderStore.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - v.Position).magnitude <= 6 then
					if ((not v:GetAttribute('Team')) or v:GetAttribute('Team') == lplr:GetAttribute('Team')) then
						npc, npccheck, enchant = true, true, true
					end
				end
			end
			for i, v in next, (bedwarsshopnpcs) do
				if ((RenderStore.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - v.Position).magnitude <= (range or 20) then
					npc, npccheck, enchant = true, (v.TeamUpgradeNPC or npccheck), false
					newid = v.TeamUpgradeNPC and v.Id or newid
				end
			end
			local suc, res = pcall(function() return lplr.leaderstats.Bed.Value == '✅'  end)
			if AutoBankDeath.Enabled and (workspace:GetServerTimeNow() - lplr.Character:GetAttribute('LastDamageTakenTime')) < 2 and suc and res then 
				return nil, false, false
			end
			if AutoBankStay.Enabled then 
				return nil, false, false
			end
		end
		return npc, not npccheck, enchant, newid
	end

	local function buyItem(itemtab, waitdelay)
		if not id then return end
		local res
		bedwars.ClientHandler:Get('BedwarsPurchaseItem'):CallServerAsync({
			shopItem = itemtab,
			shopId = id
		}):andThen(function(p11)
			if p11 then
				bedwars.SoundManager:playSound(bedwars.SoundList.BEDWARS_PURCHASE_ITEM)
				bedwars.ClientStoreHandler:dispatch({
					type = 'BedwarsAddItemPurchased', 
					itemType = itemtab.itemType
				})
			end
			res = p11
		end)
		if waitdelay then 
			repeat task.wait() until res ~= nil
		end
	end

	local function buyUpgrade(upgradetype, inv, upgrades)
		if not AutoBuyUpgrades.Enabled then return end
		local teamupgrade = bedwars.Shop.getUpgrade(bedwars.Shop.TeamUpgrades, upgradetype)
		local teamtier = teamupgrade.tiers[upgrades[upgradetype] and upgrades[upgradetype] + 2 or 1]
		if teamtier then 
			local teamcurrency = getItem(teamtier.currency, inv.items)
			if teamcurrency and teamcurrency.amount >= teamtier.price then 
				bedwars.ClientHandler:Get('BedwarsPurchaseTeamUpgrade'):CallServerAsync({
					upgradeId = upgradetype, 
					tier = upgrades[upgradetype] and upgrades[upgradetype] + 1 or 0
				}):andThen(function(suc)
					if suc then
						bedwars.SoundManager:playSound(bedwars.SoundList.BEDWARS_PURCHASE_ITEM)
					end
				end)
			end
		end
	end

	local function getAxeNear(inv)
		for i5, v5 in next, (inv or bedwarsStore.localInventory.inventory.items) do
			if v5.itemType:find('axe') and v5.itemType:find('pickaxe') == nil then
				return v5.itemType
			end
		end
		return nil
	end

	local function getPickaxeNear(inv)
		for i5, v5 in next, (inv or bedwarsStore.localInventory.inventory.items) do
			if v5.itemType:find('pickaxe') then
				return v5.itemType
			end
		end
		return nil
	end

	local function getShopItem(itemType)
		if itemType == 'axe' then 
			itemType = getAxeNear() or 'wood_axe'
			itemType = axes[table.find(axes, itemType) + 1] or itemType
		end
		if itemType == 'pickaxe' then 
			itemType = getPickaxeNear() or 'wood_pickaxe'
			itemType = pickaxes[table.find(pickaxes, itemType) + 1] or itemType
		end
		for i,v in next, (bedwars.ShopItems) do 
			if v.itemType == itemType then return v end
		end
		return nil
	end

	local buyfunctions = {
		Armor = function(inv, upgrades, shoptype) 
			if AutoBuyArmor.Enabled == false or shoptype ~= 'item' then return end
			local currentarmor = (inv.armor[2] ~= 'empty' and inv.armor[2].itemType:find('chestplate') ~= nil) and inv.armor[2] or nil
			local armorindex = (currentarmor and table.find(armors, currentarmor.itemType) or 0) + 1
			if armors[armorindex] == nil then return end
			local highestbuyable = nil
			for i = armorindex, #armors, 1 do 
				local shopitem = getShopItem(armors[i])
				if shopitem and (AutoBuyTierSkip.Enabled or i == armorindex) then 
					local currency = getItem(shopitem.currency, inv.items)
					if currency and currency.amount >= shopitem.price then 
						highestbuyable = shopitem
						bedwars.ClientStoreHandler:dispatch({
							type = 'BedwarsAddItemPurchased', 
							itemType = shopitem.itemType
						})
					end
				end
			end
			if highestbuyable and (highestbuyable.ignoredByKit == nil or table.find(highestbuyable.ignoredByKit, bedwarsStore.equippedKit) == nil) then 
				buyItem(highestbuyable)
			end
		end,
		Sword = function(inv, upgrades, shoptype)
			if AutoBuySword.Enabled == false or shoptype ~= 'item' then return end
			local currentsword = getItemNear('sword', inv.items)
			local swordindex = (currentsword and table.find(swords, currentsword.itemType) or 0) + 1
			if currentsword ~= nil and table.find(swords, currentsword.itemType) == nil then return end
			local highestbuyable = nil
			for i = swordindex, #swords, 1 do 
				local shopitem = getShopItem(swords[i])
				if shopitem then 
					local currency = getItem(shopitem.currency, inv.items)
					if currency and currency.amount >= shopitem.price and (shopitem.category ~= 'Armory' or upgrades.armory) then 
						highestbuyable = shopitem
						bedwars.ClientStoreHandler:dispatch({
							type = 'BedwarsAddItemPurchased', 
							itemType = shopitem.itemType
						})
					end
				end
			end
			if highestbuyable and (highestbuyable.ignoredByKit == nil or table.find(highestbuyable.ignoredByKit, bedwarsStore.equippedKit) == nil) then 
				buyItem(highestbuyable)
			end
		end,
		Protection = function(inv, upgrades)
			if not AutoBuyProt.Enabled then return end
			buyUpgrade('armor', inv, upgrades)
		end,
		Sharpness = function(inv, upgrades)
			if not AutoBuySharp.Enabled then return end
			buyUpgrade('damage', inv, upgrades)
		end,
		Generator = function(inv, upgrades)
			if not AutoBuyGen.Enabled then return end
			buyUpgrade('generator', inv, upgrades)
		end,
		Destruction = function(inv, upgrades)
			if not AutoBuyDestruction.Enabled then return end
			buyUpgrade('destruction', inv, upgrades)
		end,
		Diamond = function(inv, upgrades)
			if not AutoBuyDiamond.Enabled then return end
			buyUpgrade('diamond_generator', inv, upgrades)
		end,
		Alarm = function(inv, upgrades)
			if not AutoBuyAlarm.Enabled then return end
			buyUpgrade('alarm', inv, upgrades)
		end
	}

	AutoBuy = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'AutoBuy', 
		Function = function(calling)
			if calling then 
				buyingthing = false 
				task.spawn(function()
					repeat
						task.wait() 
						local found, npctype, enchant, newid = nearNPC(AutoBuyRange.Value)
						id = newid
						if found then
							local inv = bedwarsStore.localInventory.inventory
							local currentupgrades = bedwars.ClientStoreHandler:getState().Bedwars.teamUpgrades
							if bedwarsStore.equippedKit == 'dasher' then 
								swords = {
									[1] = 'wood_dao',
									[2] = 'stone_dao',
									[3] = 'iron_dao',
									[4] = 'diamond_dao',
									[5] = 'emerald_dao'
								}
							elseif bedwarsStore.equippedKit == 'ice_queen' then 
								swords[5] = 'ice_sword'
							elseif bedwarsStore.equippedKit == 'ember' then 
								swords[5] = 'infernal_saber'
							elseif bedwarsStore.equippedKit == 'lumen' then 
								swords[5] = 'light_sword'
							end
							if (AutoBuyGui.Enabled == false or (bedwars.AppController:isAppOpen('BedwarsItemShopApp') or bedwars.AppController:isAppOpen('BedwarsTeamUpgradeApp'))) and (not enchant) then
								for i,v in next, (AutoBuyCustom.ObjectList) do 
									local autobuyitem = v:split('/')
									if #autobuyitem >= 3 and autobuyitem[4] ~= 'true' then 
										local shopitem = getShopItem(autobuyitem[1])
										if shopitem then 
											local currency = getItem(shopitem.currency, inv.items)
											local actualitem = getItem(shopitem.itemType == 'wool_white' and getWool() or shopitem.itemType, inv.items)
											if currency and currency.amount >= shopitem.price and (actualitem == nil or actualitem.amount < tonumber(autobuyitem[2])) then 
												buyItem(shopitem, tonumber(autobuyitem[2]) > 1)
											end
										end
									end
								end
								for i,v in next, (buyfunctions) do v(inv, currentupgrades, npctype and 'upgrade' or 'item') end
								for i,v in next, (AutoBuyCustom.ObjectList) do 
									local autobuyitem = v:split('/')
									if #autobuyitem >= 3 and autobuyitem[4] == 'true' then 
										local shopitem = getShopItem(autobuyitem[1])
										if shopitem then 
											local currency = getItem(shopitem.currency, inv.items)
											local actualitem = getItem(shopitem.itemType == 'wool_white' and getWool() or shopitem.itemType, inv.items)
											if currency and currency.amount >= shopitem.price and (actualitem == nil or actualitem.amount < tonumber(autobuyitem[2])) then 
												buyItem(shopitem, tonumber(autobuyitem[2]) > 1)
											end
										end
									end
								end
							end
						end
						if RenderPerformance then 
							task.wait(0.10)
						end
					until (not AutoBuy.Enabled)
				end)
			end
		end,
		HoverText = 'Automatically Buys Swords, Armor, and Team Upgrades\nwhen you walk near the NPC'
	})
	AutoBuyRange = AutoBuy.CreateSlider({
		Name = 'Range',
		Function = function() end,
		Min = 1,
		Max = 20,
		Default = 20
	})
	AutoBuyArmor = AutoBuy.CreateToggle({
		Name = 'Buy Armor',
		Function = function() end, 
		Default = true
	})
	AutoBuySword = AutoBuy.CreateToggle({
		Name = 'Buy Sword',
		Function = function() end, 
		Default = true
	})
	AutoBuyUpgrades = AutoBuy.CreateToggle({
		Name = 'Buy Team Upgrades',
		Function = function(calling) 
			if AutoBuyUpgrades.Object then AutoBuyUpgrades.Object.ToggleArrow.Visible = calling end
			if AutoBuyGen.Object then AutoBuyGen.Object.Visible = calling end
			if AutoBuyProt.Object then AutoBuyProt.Object.Visible = calling end
			if AutoBuySharp.Object then AutoBuySharp.Object.Visible = calling end
			if AutoBuyDestruction.Object then AutoBuyDestruction.Object.Visible = calling end
			if AutoBuyDiamond.Object then AutoBuyDiamond.Object.Visible = calling end
			if AutoBuyAlarm.Object then AutoBuyAlarm.Object.Visible = calling end
		end, 
		Default = true
	})
	AutoBuyGen = AutoBuy.CreateToggle({
		Name = 'Buy Team Generator',
		Function = function() end, 
	})
	AutoBuyProt = AutoBuy.CreateToggle({
		Name = 'Buy Protection',
		Function = function() end, 
		Default = true
	})
	AutoBuySharp = AutoBuy.CreateToggle({
		Name = 'Buy Sharpness',
		Function = function() end, 
		Default = true
	})
	AutoBuyDestruction = AutoBuy.CreateToggle({
		Name = 'Buy Destruction',
		Function = function() end, 
	})
	AutoBuyDiamond = AutoBuy.CreateToggle({
		Name = 'Buy Diamond Generator',
		Function = function() end, 
	})
	AutoBuyAlarm = AutoBuy.CreateToggle({
		Name = 'Buy Alarm',
		Function = function() end, 
	})
	AutoBuyGui = AutoBuy.CreateToggle({
		Name = 'Shop GUI Check',
		Function = function() end, 	
	})
	AutoBuyTierSkip = AutoBuy.CreateToggle({
		Name = 'Tier Skip',
		Function = function() end, 
		Default = true
	})
	AutoBuyGen.Object.BackgroundTransparency = 0
	AutoBuyGen.Object.BorderSizePixel = 0
	AutoBuyGen.Object.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	AutoBuyGen.Object.Visible = AutoBuyUpgrades.Enabled
	AutoBuyProt.Object.BackgroundTransparency = 0
	AutoBuyProt.Object.BorderSizePixel = 0
	AutoBuyProt.Object.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	AutoBuyProt.Object.Visible = AutoBuyUpgrades.Enabled
	AutoBuySharp.Object.BackgroundTransparency = 0
	AutoBuySharp.Object.BorderSizePixel = 0
	AutoBuySharp.Object.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	AutoBuySharp.Object.Visible = AutoBuyUpgrades.Enabled
	AutoBuyDestruction.Object.BackgroundTransparency = 0
	AutoBuyDestruction.Object.BorderSizePixel = 0
	AutoBuyDestruction.Object.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	AutoBuyDestruction.Object.Visible = AutoBuyUpgrades.Enabled
	AutoBuyDiamond.Object.BackgroundTransparency = 0
	AutoBuyDiamond.Object.BorderSizePixel = 0
	AutoBuyDiamond.Object.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	AutoBuyDiamond.Object.Visible = AutoBuyUpgrades.Enabled
	AutoBuyAlarm.Object.BackgroundTransparency = 0
	AutoBuyAlarm.Object.BorderSizePixel = 0
	AutoBuyAlarm.Object.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	AutoBuyAlarm.Object.Visible = AutoBuyUpgrades.Enabled
	AutoBuyCustom = AutoBuy.CreateTextList({
		Name = 'BuyList',
		TempText = 'item/amount/priority/after',
		SortFunction = function(a, b)
			local amount1 = a:split('/')
			local amount2 = b:split('/')
			amount1 = #amount1 and tonumber(amount1[3]) or 1
			amount2 = #amount2 and tonumber(amount2[3]) or 1
			return amount1 < amount2
		end
	})
	AutoBuyCustom.Object.AddBoxBKG.AddBox.TextSize = 14

	local AutoBank = {}
	local AutoBankRange = {Value = 20}
	local AutoBankApple = {}
	local AutoBankBalloon = {}
	local AutoBankTransmitted, AutoBankTransmittedType = false, false
	local autobankoldapple
	local autobankoldballoon
	local autobankui

	local function refreshbank()
		if autobankui then
			local echest = replicatedStorageService.Inventories:FindFirstChild(lplr.Name..'_personal')
			for i,v in next, (autobankui:GetChildren()) do 
				if echest:FindFirstChild(v.Name) then 
					v.Amount.Text = echest[v.Name]:GetAttribute('Amount')
				else
					v.Amount.Text = ''
				end
			end
		end
	end

	AutoBank = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'AutoBank',
		Function = function(calling)
			if calling then
				autobankui = Instance.new('Frame')
				autobankui.Size = UDim2.new(0, 240, 0, 40)
				autobankui.AnchorPoint = Vector2.new(0.5, 0)
				autobankui.Position = UDim2.new(0.5, 0, 0, -240)
				autobankui.Visible = AutoBankUIToggle.Enabled
				task.spawn(function()
					repeat
						task.wait()
						if autobankui then 
							local hotbar = lplr.PlayerGui:FindFirstChild('hotbar')
							if hotbar then 
								local healthbar = hotbar['1']:FindFirstChild('HotbarHealthbarContainer')
								if healthbar then 
									autobankui.Position = UDim2.new(0.5, 0, 0, healthbar.AbsolutePosition.Y - 50)
								end
							end
						else
							break
						end
					until (not AutoBank.Enabled)
				end)
				autobankui.BackgroundTransparency = 1
				autobankui.Parent = GuiLibrary.MainGui
				local emerald = Instance.new('ImageLabel')
				emerald.Image = bedwars.getIcon({itemType = 'emerald'}, true)
				emerald.Size = UDim2.new(0, 40, 0, 40)
				emerald.Name = 'emerald'
				emerald.Position = UDim2.new(0, 120, 0, 0)
				emerald.BackgroundTransparency = 1
				emerald.Parent = autobankui
				local emeraldtext = Instance.new('TextLabel')
				emeraldtext.TextSize = 20
				emeraldtext.BackgroundTransparency = 1
				emeraldtext.Size = UDim2.new(1, 0, 1, 0)
				emeraldtext.Font = Enum.Font.SourceSans
				emeraldtext.TextStrokeTransparency = 0.3
				emeraldtext.Name = 'Amount'
				emeraldtext.Text = ''
				emeraldtext.TextColor3 = Color3.new(1, 1, 1)
				emeraldtext.Parent = emerald
				local diamond = emerald:Clone()
				diamond.Image = bedwars.getIcon({itemType = 'diamond'}, true)
				diamond.Position = UDim2.new(0, 80, 0, 0)
				diamond.Name = 'diamond'
				diamond.Parent = autobankui
				local gold = emerald:Clone()
				gold.Image = bedwars.getIcon({itemType = 'gold'}, true)
				gold.Position = UDim2.new(0, 40, 0, 0)
				gold.Name = 'gold'
				gold.Parent = autobankui
				local iron = emerald:Clone()
				iron.Image = bedwars.getIcon({itemType = 'iron'}, true)
				iron.Position = UDim2.new(0, 0, 0, 0)
				iron.Name = 'iron'
				iron.Parent = autobankui
				local apple = emerald:Clone()
				apple.Image = bedwars.getIcon({itemType = 'apple'}, true)
				apple.Position = UDim2.new(0, 160, 0, 0)
				apple.Name = 'apple'
				apple.Parent = autobankui
				local balloon = emerald:Clone()
				balloon.Image = bedwars.getIcon({itemType = 'balloon'}, true)
				balloon.Position = UDim2.new(0, 200, 0, 0)
				balloon.Name = 'balloon'
				balloon.Parent = autobankui
				local echest = replicatedStorageService.Inventories:FindFirstChild(lplr.Name..'_personal')
				if entityLibrary.isAlive and echest and (bedwars.AppController:isAppOpen('BedwarsItemShopApp') or AutoBankStay.Enabled) then
					task.spawn(function()
						local chestitems = bedwarsStore.localInventory.inventory.items
						for i3,v3 in next, (chestitems) do
							if (v3.itemType == 'emerald' or v3.itemType == 'iron' or v3.itemType == 'diamond' or v3.itemType == 'gold' or (v3.itemType == 'apple' and AutoBankApple.Enabled) or (v3.itemType == 'balloon' and AutoBankBalloon.Enabled)) then
								bedwars.ClientHandler:GetNamespace('Inventory'):Get('ChestGiveItem'):CallServer(echest, v3.tool)
								refreshbank()
							end
						end
					end)
				else
					task.spawn(function()
						refreshbank()
					end)
				end
				table.insert(AutoBank.Connections, replicatedStorageService.Inventories.DescendantAdded:Connect(function(p3)
					if p3.Parent.Name == lplr.Name then
						if echest == nil then 
							echest = replicatedStorageService.Inventories:FindFirstChild(lplr.Name..'_personal')
						end	
						if not echest then return end
						if p3.Name == 'apple' and AutoBankApple.Enabled then 
							if autobankapple then return end
						elseif p3.Name == 'balloon' and AutoBankBalloon.Enabled then 
							if autobankballoon then vapeEvents.AutoBankBalloon:Fire() return end
						elseif (p3.Name == 'emerald' or p3.Name == 'iron' or p3.Name == 'diamond' or p3.Name == 'gold') then
							if not ((not AutoBankTransmitted) or (AutoBankTransmittedType and p3.Name ~= 'diamond')) then return end
						else
							return
						end
						bedwars.ClientHandler:GetNamespace('Inventory'):Get('ChestGiveItem'):CallServer(echest, p3)
						refreshbank()
					end
				end))
				task.spawn(function()
					repeat
						task.wait()
						local found, npctype = nearNPC(AutoBankRange.Value)
						if echest == nil then 
							echest = replicatedStorageService.Inventories:FindFirstChild(lplr.Name..'_personal')
						end
						if autobankballoon then 
							local chestitems = echest and echest:GetChildren() or {}
							if #chestitems > 0 then
								for i3,v3 in next, (chestitems) do
									if v3:IsA('Accessory') and v3.Name == 'balloon' then
										if (not getItem('balloon')) then
											task.spawn(function()
												bedwars.ClientHandler:GetNamespace('Inventory'):Get('ChestGetItem'):CallServer(echest, v3)
												refreshbank()
											end)
										end
									end
								end
							end
						end
						if autobankballoon ~= autobankoldballoon and AutoBankBalloon.Enabled then 
							if entityLibrary.isAlive then
								if not autobankballoon then
									local chestitems = bedwarsStore.localInventory.inventory.items
									if #chestitems > 0 then
										for i3,v3 in next, (chestitems) do
											if v3 and v3.itemType == 'balloon' then
												task.spawn(function()
													bedwars.ClientHandler:GetNamespace('Inventory'):Get('ChestGiveItem'):CallServer(echest, v3.tool)
													refreshbank()
												end)
											end
										end
									end
								end
							end
							autobankoldballoon = autobankballoon
						end
						if autobankapple then 
							local chestitems = echest and echest:GetChildren() or {}
							if #chestitems > 0 then
								for i3,v3 in next, (chestitems) do
									if v3:IsA('Accessory') and v3.Name == 'apple' then
										if (not getItem('apple')) then
											task.spawn(function()
												bedwars.ClientHandler:GetNamespace('Inventory'):Get('ChestGetItem'):CallServer(echest, v3)
												refreshbank()
											end)
										end
									end
								end
							end
						end
						if (autobankapple ~= autobankoldapple) and AutoBankApple.Enabled then 
							if entityLibrary.isAlive then
								if not autobankapple then
									local chestitems = bedwarsStore.localInventory.inventory.items
									if #chestitems > 0 then
										for i3,v3 in next, (chestitems) do
											if v3 and v3.itemType == 'apple' then
												task.spawn(function()
													bedwars.ClientHandler:GetNamespace('Inventory'):Get('ChestGiveItem'):CallServer(echest, v3.tool)
													refreshbank()
												end)
											end
										end
									end
								end
							end
							autobankoldapple = autobankapple
						end
						if found ~= AutoBankTransmitted or npctype ~= AutoBankTransmittedType then
							AutoBankTransmitted, AutoBankTransmittedType = found, npctype
							if entityLibrary.isAlive then
								local chestitems = bedwarsStore.localInventory.inventory.items
								if #chestitems > 0 then
									for i3,v3 in next, (chestitems) do
										if v3 and (v3.itemType == 'emerald' or v3.itemType == 'iron' or v3.itemType == 'diamond' or v3.itemType == 'gold') then
											if (not AutoBankTransmitted) or (AutoBankTransmittedType and v3.Name ~= 'diamond') then 
												task.spawn(function()
													pcall(function()
														bedwars.ClientHandler:GetNamespace('Inventory'):Get('ChestGiveItem'):CallServer(echest, v3.tool)
													end)
													refreshbank()
												end)
											end
										end
									end
								end
							end
						end
						if found then 
							local chestitems = echest and echest:GetChildren() or {}
							if #chestitems > 0 then
								for i3,v3 in next, (chestitems) do
									if v3:IsA('Accessory') and ((npctype == false and (v3.Name == 'emerald' or v3.Name == 'iron' or v3.Name == 'gold')) or v3.Name == 'diamond') then
										task.spawn(function()
											pcall(function()
												bedwars.ClientHandler:GetNamespace('Inventory'):Get('ChestGetItem'):CallServer(echest, v3)
											end)
											refreshbank()
										end)
									end
								end
							end
						end
					until (not AutoBank.Enabled)
				end)
			else
				if autobankui then
					autobankui:Destroy()
					autobankui = nil
				end
				local echest = replicatedStorageService.Inventories:FindFirstChild(lplr.Name..'_personal')
				local chestitems = echest and echest:GetChildren() or {}
				if #chestitems > 0 then
					for i3,v3 in next, (chestitems) do
						if v3:IsA('Accessory') and (v3.Name == 'emerald' or v3.Name == 'iron' or v3.Name == 'diamond' or v3.Name == 'apple' or v3.Name == 'balloon') then
							task.spawn(function()
								pcall(function()
									bedwars.ClientHandler:GetNamespace('Inventory'):Get('ChestGetItem'):CallServer(echest, v3)
								end)
								refreshbank()
							end)
						end
					end
				end
			end
		end
	})
	AutoBankUIToggle = AutoBank.CreateToggle({
		Name = 'UI',
		Function = function(calling)
			if autobankui then autobankui.Visible = calling end
		end,
		Default = true
	})
	AutoBankApple = AutoBank.CreateToggle({
		Name = 'Apple',
		Function = function(calling) 
			if not calling then 
				local echest = replicatedStorageService.Inventories:FindFirstChild(lplr.Name..'_personal')
				local chestitems = echest and echest:GetChildren() or {}
				for i3,v3 in next, (chestitems) do
					if v3:IsA('Accessory') and v3.Name == 'apple' then
						task.spawn(function()
							bedwars.ClientHandler:GetNamespace('Inventory'):Get('ChestGetItem'):CallServer(echest, v3)
							refreshbank()
						end)
					end
				end
			end
		end,
		Default = true
	})
	AutoBankBalloon = AutoBank.CreateToggle({
		Name = 'Balloon',
		Function = function(calling) 
			if not calling then 
				local echest = replicatedStorageService.Inventories:FindFirstChild(lplr.Name..'_personal')
				local chestitems = echest and echest:GetChildren() or {}
				for i3,v3 in next, (chestitems) do
					if v3:IsA('Accessory') and v3.Name == 'balloon' then
						task.spawn(function()
							bedwars.ClientHandler:GetNamespace('Inventory'):Get('ChestGetItem'):CallServer(echest, v3)
							refreshbank()
						end)
					end
				end
			end
		end,
		Default = true
	})
	AutoBankDeath = AutoBank.CreateToggle({
		Name = 'Damage',
		Function = function() end,
		HoverText = 'puts away resources when you take damage to prevent losing on death'
	})
	AutoBankRange = AutoBank.CreateSlider({
		Name = 'Range',
		Function = function() end,
		Min = 1,
		Max = 20,
		Default = 20
	})
end)

runFunction(function()
	local AutoConsume = {}
	local AutoConsumeHealth = {Value = 100}
	local AutoConsumeSpeed = {}
	local AutoConsumeDelay = tick()

	local function AutoConsumeFunc()
		if entityLibrary.isAlive then
			local speedpotion = getItem('speed_potion')
			if lplr.Character:GetAttribute('Health') <= (lplr.Character:GetAttribute('MaxHealth') - (100 - AutoConsumeHealth.Value)) then
				autobankapple = true
				local item = getItem('apple')
				local pot = getItem('heal_splash_potion')
				if (item or pot) and AutoConsumeDelay <= tick() then
					if item then
						bedwars.ClientHandler:Get(bedwars.EatRemote):CallServerAsync({
							item = item.tool
						})
						AutoConsumeDelay = tick() + 0.6
					else
						local newray = workspace:Raycast((oldcloneroot or entityLibrary.character.HumanoidRootPart).Position, Vector3.new(0, -76, 0), bedwarsStore.blockRaycast)
						if newray ~= nil then
							bedwars.ClientHandler:Get(bedwars.ProjectileRemote):CallServerAsync(pot.tool, 'heal_splash_potion', 'heal_splash_potion', (oldcloneroot or entityLibrary.character.HumanoidRootPart).Position, (oldcloneroot or entityLibrary.character.HumanoidRootPart).Position, Vector3.new(0, -70, 0), game:GetService('HttpService'):GenerateGUID(), {drawDurationSeconds = 1})
						end
					end
				end
			else
				autobankapple = false
			end
			if speedpotion and (not lplr.Character:GetAttribute('StatusEffect_speed')) and AutoConsumeSpeed.Enabled then 
				bedwars.ClientHandler:Get(bedwars.EatRemote):CallServerAsync({
					item = speedpotion.tool
				})
			end
			if lplr.Character:GetAttribute('Shield_POTION') and ((not lplr.Character:GetAttribute('Shield_POTION')) or lplr.Character:GetAttribute('Shield_POTION') == 0) then
				local shield = getItem('big_shield') or getItem('mini_shield')
				if shield then
					bedwars.ClientHandler:Get(bedwars.EatRemote):CallServerAsync({
						item = shield.tool
					})
				end
			end
		end
	end

	AutoConsume = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'AutoConsume',
		Function = function(calling)
			if calling then
				table.insert(AutoConsume.Connections, vapeEvents.InventoryAmountChanged.Event:Connect(AutoConsumeFunc))
				table.insert(AutoConsume.Connections, vapeEvents.AttributeChanged.Event:Connect(function(changed)
					if changed:find('Shield') or changed:find('Health') or changed:find('speed') then 
						AutoConsumeFunc()
					end
				end))
				AutoConsumeFunc()
			end
		end,
		HoverText = 'Automatically heals for you when health or shield is under threshold.'
	})
	AutoConsumeHealth = AutoConsume.CreateSlider({
		Name = 'Health',
		Min = 1,
		Max = 99,
		Default = 70,
		Function = function() end
	})
	AutoConsumeSpeed = AutoConsume.CreateToggle({
		Name = 'Speed Potions',
		Function = function() end,
		Default = true
	})
end)

runFunction(function()
	local AutoHotbarList = {Hotbars = {}, CurrentlySelected = 1}
	local AutoHotbarMode = {Value = 'Toggle'}
	local AutoHotbarClear = {}
	local AutoHotbar = {}
	local AutoHotbarActive = false

	local function getCustomItem(v2)
		local realitem = v2.itemType
		if realitem == 'swords' then
			local sword = getSword()
			realitem = sword and sword.itemType or 'wood_sword'
		elseif realitem == 'pickaxes' then
			local pickaxe = getPickaxe()
			realitem = pickaxe and pickaxe.itemType or 'wood_pickaxe'
		elseif realitem == 'axes' then
			local axe = getAxe()
			realitem = axe and axe.itemType or 'wood_axe'
		elseif realitem == 'bows' then
			local bow = getBow()
			realitem = bow and bow.itemType or 'wood_bow'
		elseif realitem == 'wool' then
			realitem = getWool() or 'wool_white'
		end
		return realitem
	end
	
	local function findItemInTable(tab, item)
		for i, v in next, (tab) do
			if v and v.itemType then
				if item.itemType == getCustomItem(v) then
					return i
				end
			end
		end
		return nil
	end

	local function findinhotbar(item)
		for i,v in next, (bedwarsStore.localInventory.hotbar) do
			if v.item and v.item.itemType == item.itemType then
				return i, v.item
			end
		end
	end

	local function findininventory(item)
		for i,v in next, (bedwarsStore.localInventory.inventory.items) do
			if v.itemType == item.itemType then
				return v
			end
		end
	end

	local function AutoHotbarSort()
		task.spawn(function()
			if AutoHotbarActive then return end
			AutoHotbarActive = true
			local items = (AutoHotbarList.Hotbars[AutoHotbarList.CurrentlySelected] and AutoHotbarList.Hotbars[AutoHotbarList.CurrentlySelected].Items or {})
			for i, v in next, (bedwarsStore.localInventory.inventory.items) do 
				local customItem
				local hotbarslot = findItemInTable(items, v)
				if hotbarslot then
					local oldhotbaritem = bedwarsStore.localInventory.hotbar[tonumber(hotbarslot)]
					if oldhotbaritem.item and oldhotbaritem.item.itemType == v.itemType then continue end
					if oldhotbaritem.item then 
						bedwars.ClientStoreHandler:dispatch({
							type = 'InventoryRemoveFromHotbar', 
							slot = tonumber(hotbarslot) - 1
						})
						vapeEvents.InventoryChanged.Event:Wait()
					end
					local newhotbaritemslot, newhotbaritem = findinhotbar(v)
					if newhotbaritemslot then
						bedwars.ClientStoreHandler:dispatch({
							type = 'InventoryRemoveFromHotbar', 
							slot = newhotbaritemslot - 1
						})
						vapeEvents.InventoryChanged.Event:Wait()
					end
					if oldhotbaritem.item and newhotbaritemslot then 
						local nextitem1, nextitem1num = findininventory(oldhotbaritem.item)
						bedwars.ClientStoreHandler:dispatch({
							type = 'InventoryAddToHotbar', 
							item = nextitem1, 
							slot = newhotbaritemslot - 1
						})
						vapeEvents.InventoryChanged.Event:Wait()
					end
					local nextitem2, nextitem2num = findininventory(v)
					bedwars.ClientStoreHandler:dispatch({
						type = 'InventoryAddToHotbar', 
						item = nextitem2, 
						slot = tonumber(hotbarslot) - 1
					})
					vapeEvents.InventoryChanged.Event:Wait()
				else
					if AutoHotbarClear.Enabled then 
						local newhotbaritemslot, newhotbaritem = findinhotbar(v)
						if newhotbaritemslot then
							bedwars.ClientStoreHandler:dispatch({
								type = 'InventoryRemoveFromHotbar', 
								slot = newhotbaritemslot - 1
							})
							vapeEvents.InventoryChanged.Event:Wait()
						end
					end
				end
			end
			AutoHotbarActive = false
		end)
	end

	AutoHotbar = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'AutoHotbar',
		Function = function(calling) 
			if calling then
				AutoHotbarSort()
				if AutoHotbarMode.Value == 'On Key' then
					if AutoHotbar.Enabled then 
						AutoHotbar.ToggleButton(false)
					end
				else
					table.insert(AutoHotbar.Connections, vapeEvents.InventoryAmountChanged.Event:Connect(function()
						if not AutoHotbar.Enabled then return end
						AutoHotbarSort()
					end))
				end
			end
		end,
		HoverText = 'Automatically arranges hotbar to your liking.'
	})
	AutoHotbarMode = AutoHotbar.CreateDropdown({
		Name = 'Activation',
		List = {'On Key', 'Toggle'},
		Function = function(val)
			if AutoHotbar.Enabled then
				AutoHotbar.ToggleButton(false)
				AutoHotbar.ToggleButton(false)
			end
		end
	})
	AutoHotbarList = CreateAutoHotbarGUI(AutoHotbar.Children, {
		Name = 'lol'
	})
	AutoHotbarClear = AutoHotbar.CreateToggle({
		Name = 'Clear Hotbar',
		Function = function() end
	})
end)

runFunction(function()
	local AutoKit = {}
	local HannahExploitCheck = {}
	local HannahExploitRange = {Value = 50}
	local EvelynnExploitRange = {Value = 50}
	local AutoKitToggles = {}
	local healtick = tick()
	local function lowestTeamate()
		local health, lowest = math.huge, nil
		for i,v in next, playersService:GetPlayers() do 
			if v ~= lplr and v:GetAttribute('Team') == lplr:GetAttribute('Team') and isAlive(v) then 
				local h = v.Character:GetAttribute('Health') 
				local max = v.Character:GetAttribute('MaxHealth')
				local magnitude = (lplr.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
				if h < max and h < health and magnitude < 30 then 
					health = h 
					lowest = v
				end
			end
		end
		return lowest
	end
	local function getTeamate()
		local magnitude, teamate = math.huge, nil
		for i,v in next, playersService:GetPlayers() do 
			if v ~= lplr and v:GetAttribute('Team') == lplr:GetAttribute('Team') and isAlive(v) then 
				local m = (lplr.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude 
				if m < magnitude and mag < 45 then 
					magnitude = m 
					teamate = v
				end
			end
		end
		return teamate
	end
	local betterkitnames = {
		melody = 'Melody',
		bigman = 'Elder Tree',
		metal_detector = 'Metal Detector',
		battery = 'Cobalt',
		grim_reaper = 'Grim Reaper',
		farmer_cletus = 'Farmer Cletus',
		dragon_slayer = 'Kaliyah',
		mage = 'Whim',
		angel = 'Trinity',
		miner = 'Miner',
		hannah = 'Hannah',
		jailor = 'Warden',
		warlock = 'Eldric',
		necromancer = 'Crypt',
		pinata = 'Lucia',
		spirit_assassin = 'Evelynn'
	}
	local autokitstuff = {
		melody = function()
			repeat
				task.wait(0.1)
				if getItem('guitar') then
					local plr = lowestTeamate()
					if plr and healtick <= tick() then 
						bedwars.ClientHandler:Get(bedwars.GuitarHealRemote):SendToServer({
							healTarget = plr.Character
						})
						healtick = tick() + 2
					end
				end
			until not AutoKit.Enabled
		end,
		bigman = function() 
			repeat
				task.wait()
				for i,v in next, collectionService:GetTagged('treeOrb') do
					if isAlive(lplr, true) and v:FindFirstChild('Spirit') and (lplr.Character.HumanoidRootPart.Position - v.Spirit.Position).Magnitude <= 20 then
						if bedwars.ClientHandler:Get(bedwars.TreeRemote):CallServer({treeOrbSecret = v:GetAttribute('TreeOrbSecret')}) then
							v:Destroy()
							collectionService:RemoveTag(v, 'treeOrb')
						end
					end
				end
			until not AutoKit.Enabled
		end,
		metal_detector = function()
			repeat
				task.wait()
				for i,v in next, collectionService:GetTagged('hidden-metal') do
					if isAlive(lplr, true) and v.PrimaryPart and (lplr.Character.HumanoidRootPart.Position - v.PrimaryPart.Position).Magnitude <= 20 then
						bedwars.ClientHandler:Get(bedwars.PickupMetalRemote):SendToServer({
							id = v:GetAttribute('Id')
						}) 
					end
				end
			until not AutoKit.Enabled
		end,
		battery = function()
			repeat
				task.wait()
				for i,v in next, bedwars.BatteryEffectController.liveBatteries do
					if isAlive(lplr, true) and (lplr.Character.HumanoidRootPart.Position - v.position).Magnitude <= 10 then
						bedwars.ClientHandler:Get(bedwars.BatteryRemote):SendToServer({
							batteryId = i
						})
					end
				end
			until not AutoKit.Enabled
		end, 
		grim_reaper = function()
			repeat
				task.wait()
				for i,v in next, bedwars.GrimReaperController.soulsByPosition do
					if isAlive(lplr, true) and lplr.Character:GetAttribute('Health') <= (lplr.Character:GetAttribute('MaxHealth') - 10) and v.PrimaryPart and (lplr.Character.HumanoidRootPart.Position - v.PrimaryPart.Position).Magnitude <= 120 and (not lplr.Character:GetAttribute('GrimReaperChannel')) and not isEnabled('InfiniteFly') then
						bedwars.ClientHandler:Get(bedwars.ConsumeSoulRemote):CallServer({
							secret = v:GetAttribute('GrimReaperSoulSecret')
						})
						v:Destroy()
					end
				end
			until not AutoKit.Enabled
		end,
		farmer_cletus = function()
			repeat
				task.wait()
				for i,v in next, collectionService:GetTagged('BedwarsHarvestableCrop') do
					if isAlive(lplr, true) and (lplr.Character.HumanoidRootPart.Position - v.Position).Magnitude <= 10 then
						bedwars.ClientHandler:Get('BedwarsHarvestCrop'):CallServerAsync({
							position = bedwars.BlockController:getBlockPosition(v.Position)
						}):andThen(function(suc)
							if suc then
								bedwars.GameAnimationUtil.playAnimation(lplr.Character, 1)
								bedwars.SoundManager:playSound(bedwars.SoundList.CROP_HARVEST)
							end
						end)
					end
				end
			until not AutoKit.Enabled
		end,
		dragon_slayer = function()
			repeat
				task.wait(0.1)
				if isAlive(lplr, true) then
					for i,v in next, bedwars.DragonSlayerController.dragonEmblems do 
						if v.stackCount >= 3 then 
							bedwars.DragonSlayerController:deleteEmblem(i)
							local localPos = lplr.Character:GetPrimaryPartCFrame().Position
							local punchCFrame = CFrame.new(localPos, (i:GetPrimaryPartCFrame().Position * Vector3.new(1, 0, 1)) + Vector3.new(0, localPos.Y, 0))
							lplr.Character:SetPrimaryPartCFrame(punchCFrame)
							bedwars.DragonSlayerController:playPunchAnimation(punchCFrame - punchCFrame.Position)
							bedwars.ClientHandler:Get(bedwars.DragonRemote):SendToServer({
								target = i
							})
						end
					end
				end
			until not AutoKit.Enabled
		end,
		mage = function()
			repeat
				task.wait(0.1)
				if isAlive(lplr, true) then
					for i, v in next, collectionService:GetTagged('TomeGuidingBeam') do 
						local obj = v.Parent and v.Parent.Parent and v.Parent.Parent.Parent
						if obj and (lplr.Character.HumanoidRootPart.Position - obj.PrimaryPart.Position).Magnitude < 5 and obj:GetAttribute('TomeSecret') then
							local res = bedwars.ClientHandler:Get(bedwars.MageRemote):CallServer({secret = obj:GetAttribute('TomeSecret')})
							if res.success and res.element then 
								bedwars.GameAnimationUtil.playAnimation(lplr, bedwars.AnimationType.PUNCH)
								bedwars.ViewmodelController:playAnimation(bedwars.AnimationType.FP_USE_ITEM)
								bedwars.MageController:destroyTomeGuidingBeam()
								bedwars.MageController:playLearnLightBeamEffect(lplr, obj)
								local sound = bedwars.MageKitUtil.MageElementVisualizations[res.element].learnSound
								if sound and sound ~= '' then 
									bedwars.SoundManager:playSound(sound)
								end
								task.delay(bedwars.BalanceFile.LEARN_TOME_DURATION, function()
									bedwars.MageController:fadeOutTome(obj)
									if lplr.Character and res.element then
										bedwars.MageKitUtil.changeMageKitAppearance(lplr, lplr.Character, res.element)	
									end
								end)
							end
						end
					end
				end
			until not AutoKit.Enabled
		end,
		angel = function()
			table.insert(AutoKit.Connections, vapeEvents.AngelProgress.Event:Connect(function()
				task.wait(0.5)
				if not AutoKit.Enabled then return end
				local objectTable = AutoKitToggles.angel.Objects
				local ability = 'Void'
				for i,v in next, objectTable do 
					if i:find('Ability') then 
						ability = v.Value 
						break
					end
				end
				if bedwars.ClientStoreHandler:getState().Kit.angelProgress >= 1 and lplr.Character:GetAttribute('AngelType') == nil then
					bedwars.ClientHandler:Get(bedwars.TrinityRemote):SendToServer({
						angel = ability
					})
				end
			end))
		end,
		miner = function()
			repeat
				task.wait(0.1)
				if isAlive(lplr, true) then
					for i,v in next, collectionService:GetTagged('petrified-player') do 
						bedwars.ClientHandler:Get(bedwars.MinerRemote):SendToServer({
							petrifyId = v:GetAttribute('PetrifyId')
						})
					end
				end
			until not AutoKit.Enabled
		end,
		hannah = function()
			table.insert(AutoKit.Connections, workspace.DescendantAdded:Connect(function(v)
				if v.Name ~= 'HannahExecuteInteraction' or not v:IsA('ProximityPrompt') or not isAlive(lplr, true) then 
					return 
				end
				local character = characterDescendant(v)
				local check = isEnabled('AutoKitRange Check', 'Toggle')
				local range = GuiLibrary.ObjectsThatCanBeSaved.AutoKitRangeSlider.Api.Value
				local player = (character and playersService:GetPlayerFromCharacter(character))
				if isEnabled('InfiniteFly') or not player then 
					return 
				end
				if isAlive(player) and not playerRaycasted(player) then 
					return 
				end
				if check and (lplr.Character.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude > range then 
					return 
				end
				repeat 
					if bedwars.ClientHandler:Get('HannahPromptTrigger'):CallServer({user = lplr, victimEntity = character}) or not isAlive(player) then 
						break 
					end
					task.wait(0.1)
				until not AutoKit.Enabled
			end))
		end,
		jailor = function()
			table.insert(AutoKit.Connections, workspace.DescendantAdded:Connect(function(v)
				if tostring(v.Parent) ~= 'JailorSoul' or not v:IsA('ProximityPrompt') or not isAlive() then 
					return 
				end
				local soul = v.Parent:GetAttribute('Id')
				repeat 
					bedwars.ClientHandler:Get('CollectCollectableEntity'):SendToServer({id = soul, collectableName = 'JailorSoul'}) 
					task.wait(0.1)
				until v.Parent == nil or not isAlive() or not AutoKit.Enabled
			end))
		end,
		necromancer = function()
			repeat 
				for i,v in next, collectionService:GetTagged('Gravestone') do
					if v.PrimaryPart and isAlive() and not isEnabled('InfiniteFly') then
						local magnitude = (lplr.Character.HumanoidRootPart.Position - v.PrimaryPart.Position).Magnitude 
						local plr = playersService:GetPlayerByUserId(v:GetAttribute('GravestonePlayerUserId')) 
						if plr and not RenderFunctions:GetPlayerType(2, plr) or magnitude > 17 then 
							continue
						end
						bedwars.ClientHandler:Get('ActivateGravestone'):CallServer({
							skeletonData = {
								armorType = v:GetAttribute('ArmorType'),
								weaponType = v:GetAttribute('SwordType'),
								associatedPlayerUserId = v:GetAttribute('GravestonePlayerUserId')
							},
							position = v:GetAttribute('GravestonePosition'),
							secret = v:GetAttribute('GravestoneSecret')
						})
					end
				end 
				task.wait(0.1) 
			until not AutoKit.Enabled
		end,
		pinata = function()
			repeat 
				for i,v in next, collectionService:GetTagged(lplr.Name..':pinata') do 
					if getItem('candy') then 
						bedwars.ClientHandler:Get('DepositCoins'):CallServer(v)
					end
				end
				task.wait(0.1)
			until not AutoKit.Enabled
		end,
		spirit_assassin = function()
			repeat 
				for i,v in next, collectionService:GetTagged('EvelynnSoul') do 
					if isAlive(lplr, true) and not isEnabled('InfiniteFly') then 
						if bedwars.ClientHandler:Get('UseSpirit'):CallServer({secret = v:GetAttribute('SpiritSecret')}) then 
							collectionService:RemoveTag(v, 'EvelynnSoul') 
							v:Destroy()
						end
					end
				end
				task.wait(0.1)
			until not AutoKit.Enabled
		end
	}
	local function autoKitCreateObject(args)
		local objectTable = AutoKitToggles[args.Kit].Objects
		task.spawn(function()
			 repeat 
				local kit = bedwarsStore.equippedKit
				if vapeInjected and kit ~= 'none' then
					local object = AutoKit[args.Method](args)
					objectTable[object.Object.Name] = object
					break 
				end
				task.wait()
			until not vapeInjected 
		end)
	end
	AutoKit = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'AutoKit',
		ExtraText = function()
			local kit = bedwarsStore.equippedKit 
			if autokitstuff[kit] and AutoKitToggles[kit].MainToggle.Enabled then 
				return betterkitnames[kit] or kit 
			end
			return 'none'
		end,
		HoverText = 'Automatically uses kit abilities',
		Function = function(calling)
			if calling then 
				repeat
					local kit = bedwarsStore.equippedKit
					if AutoKit.Enabled and autokitstuff[kit] and kit ~= 'none' then 
						if AutoKitToggles[kit].MainToggle.Enabled then 
							task.spawn(autokitstuff[kit])
						end
						break 
					end
					task.wait()
				until not AutoKit.Enabled
			end
		end
	})
	for i,v in next, autokitstuff do 
		AutoKitToggles[i] = {Objects = {}}
		AutoKitToggles[i].MainToggle = AutoKit.CreateToggle({
			Name = betterkitnames[i] or i,
			HoverText = 'Toggle for AutoKit to use this kit.',
			Default = true,
			Function = function(calling)
				task.delay(calling and 0.001 or 1, function()
					if AutoKit.Enabled then
						AutoKit.ToggleButton()
						AutoKit.ToggleButton()
					end 
				end)
			end 
		})
		task.spawn(function()
			repeat task.wait() until shared.VapeFullyLoaded
			repeat
				local kit = bedwarsStore.equippedKit
				if vapeInjected and kit ~= 'none' and AutoKitToggles[i] then 
					AutoKitToggles[i].MainToggle.Object.Visible = (kit == i)  
					for i2, v2 in next, AutoKitToggles[i].Objects do 
						if v2.Object.Visible then 
						   v2.Object.Visible = (kit == i)   
						end
					end
					break 
				end
				task.wait()
			until not vapeInjected
		end)
	end
	HannahExploitCheck = autoKitCreateObject({
		Name = 'Range Check',
		Method = 'CreateToggle',
		Kit = 'hannah',
		Default = true,
		Function = function(calling) 
			pcall(function() HannahExploitRange.Object.Visible = calling end)
		end
	})
	HannahExploitRange = autoKitCreateObject({
		Name = 'Range',
		Method = 'CreateSlider',
		Kit = 'hannah',
		Min = 10,
		Max = 100, 
		Default = 50,
		Function = function() end
	})
end)

runFunction(function()
	local alreadyreportedlist = {}
	local AutoReportV2 = {}
	local AutoReportV2Notify = {}
	AutoReportV2 = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'AutoReportV2',
		Function = function(calling)
			if calling then 
				task.spawn(function()
					repeat
						task.wait()
						for i,v in next, playersService:GetPlayers() do 
							if RenderFunctions:GetPlayerType(3, v) ~= 1 then 
								continue 
							end
							if v ~= lplr and alreadyreportedlist[v] == nil and v:GetAttribute('PlayerConnected') and WhitelistFunctions:GetWhitelist(v) == 0 then 
								task.wait(1)
								alreadyreportedlist[v] = true
								bedwars.ClientHandler:Get(bedwars.ReportRemote):SendToServer(v.UserId)
								bedwarsStore.statistics.reported = bedwarsStore.statistics.reported + 1
								if AutoReportV2Notify.Enabled then 
									InfoNotification('AutoReportV2', 'Reported '..v.Name, 15)
								end
							end
						end
					until (not AutoReportV2.Enabled)
				end)
			end	
		end,
		HoverText = 'dv mald'
	})
	AutoReportV2Notify = AutoReportV2.CreateToggle({
		Name = 'Notify',
		Function = function() end
	})
end)

runFunction(function()
	local justsaid = ''
	local leavesaid = false
	local alreadyreported = {}

	local function removerepeat(str)
		local newstr = ''
		local lastlet = ''
		for i,v in next, (str:split('')) do 
			if v ~= lastlet then
				newstr = newstr..v 
				lastlet = v
			end
		end
		return newstr
	end

	local reporttable = {
		gay = 'Bullying',
		gae = 'Bullying',
		gey = 'Bullying',
		hack = 'Scamming',
		exploit = 'Scamming',
		cheat = 'Scamming',
		hecker = 'Scamming',
		haxker = 'Scamming',
		hacer = 'Scamming',
		report = 'Bullying',
		fat = 'Bullying',
		black = 'Bullying',
		getalife = 'Bullying',
		fatherless = 'Bullying',
		report = 'Bullying',
		fatherless = 'Bullying',
		disco = 'Offsite Links',
		yt = 'Offsite Links',
		dizcourde = 'Offsite Links',
		retard = 'Swearing',
		bad = 'Bullying',
		trash = 'Bullying',
		nolife = 'Bullying',
		nolife = 'Bullying',
		loser = 'Bullying',
		killyour = 'Bullying',
		kys = 'Bullying',
		hacktowin = 'Bullying',
		bozo = 'Bullying',
		kid = 'Bullying',
		adopted = 'Bullying',
		linlife = 'Bullying',
		commitnotalive = 'Bullying',
		vape = 'Offsite Links',
		futureclient = 'Offsite Links',
		download = 'Offsite Links',
		youtube = 'Offsite Links',
		die = 'Bullying',
		lobby = 'Bullying',
		ban = 'Bullying',
		wizard = 'Bullying',
		wisard = 'Bullying',
		witch = 'Bullying',
		magic = 'Bullying',
	}
	local reporttableexact = {
		L = 'Bullying',
	}
	

	local function findreport(msg)
		local checkstr = removerepeat(msg:gsub('%W+', ''):lower())
		for i,v in next, (reporttable) do 
			if checkstr:find(i) then 
				return v, i
			end
		end
		for i,v in next, (reporttableexact) do 
			if checkstr == i then 
				return v, i
			end
		end
		for i,v in next, (AutoToxicPhrases5.ObjectList) do 
			if checkstr:find(v) then 
				return 'Bullying', v
			end
		end
		return nil
	end

	AutoToxic = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'AutoToxic',
		Function = function(calling)
			if calling then 
				table.insert(AutoToxic.Connections, vapeEvents.BedwarsBedBreak.Event:Connect(function(bedTable)
					if AutoToxicBedDestroyed.Enabled and bedTable.brokenBedTeam.id == lplr:GetAttribute('Team') then
						local custommsg = #AutoToxicPhrases6.ObjectList > 0 and AutoToxicPhrases6.ObjectList[math.random(1, #AutoToxicPhrases6.ObjectList)] or 'Who needs a bed when you got Render <name>? | renderintents.xyz'
						if custommsg then
							custommsg = custommsg:gsub('<name>', (bedTable.player.DisplayName or bedTable.player.Name))
						end
						textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(custommsg)
					elseif AutoToxicBedBreak.Enabled and bedTable.player.UserId == lplr.UserId then
						local custommsg = #AutoToxicPhrases7.ObjectList > 0 and AutoToxicPhrases7.ObjectList[math.random(1, #AutoToxicPhrases7.ObjectList)] or 'Your bed has been sent to the abyss <teamname>! | renderintents.xyz'
						if custommsg then
							local team = bedwars.QueueMeta[bedwarsStore.queueType].teams[tonumber(bedTable.brokenBedTeam.id)]
							local teamname = team and team.displayName:lower() or 'white'
							custommsg = custommsg:gsub('<teamname>', teamname)
						end
						sendmessage(custommsg)
					end
				end))
				table.insert(AutoToxic.Connections, vapeEvents.EntityDeathEvent.Event:Connect(function(deathTable)
					if deathTable.finalKill then
						local killer = playersService:GetPlayerFromCharacter(deathTable.fromEntity)
						local killed = playersService:GetPlayerFromCharacter(deathTable.entityInstance)
						if not killed or not killer then return end
						if killed == lplr then 
							if (not leavesaid) and killer ~= lplr and AutoToxicDeath.Enabled then
								leavesaid = true
								local custommsg = #AutoToxicPhrases3.ObjectList > 0 and AutoToxicPhrases3.ObjectList[math.random(1, #AutoToxicPhrases3.ObjectList)] or 'I was too laggy <name>. That\'s why you won. | renderintents.xyz'
								if custommsg then
									custommsg = custommsg:gsub('<name>', (killer.DisplayName or killer.Name))
								end
								sendmessage(custommsg)
							end
						else
							if killer == lplr and AutoToxicFinalKill.Enabled then 
								local custommsg = #AutoToxicPhrases2.ObjectList > 0 and AutoToxicPhrases2.ObjectList[math.random(1, #AutoToxicPhrases2.ObjectList)] or '<name> things could have ended for you so differently, if you\'ve used Render. | renderintents.xyz'
								if custommsg == lastsaid then
									custommsg = #AutoToxicPhrases2.ObjectList > 0 and AutoToxicPhrases2.ObjectList[math.random(1, #AutoToxicPhrases2.ObjectList)] or '<name> things could have ended for you so differently, if you\'ve used Render. | renderintents.xyz'
								else
									lastsaid = custommsg
								end
								if custommsg then
									custommsg = custommsg:gsub('<name>', (killed.DisplayName or killed.Name))
								end
								sendmessage(custommsg)
							end
						end
					end
				end))
				table.insert(AutoToxic.Connections, vapeEvents.MatchEndEvent.Event:Connect(function(winstuff)
					local myTeam = bedwars.ClientStoreHandler:getState().Game.myTeam
					if myTeam and myTeam.id == winstuff.winningTeamId or lplr.Neutral then
						if AutoToxicGG.Enabled then
							sendmessage('gg')
						end
						if AutoToxicWin.Enabled then
							sendmessage(#AutoToxicPhrases.ObjectList > 0 and AutoToxicPhrases.ObjectList[math.random(1, #AutoToxicPhrases.ObjectList)] or 'Render is simply better everyone. | renderintents.xyz')
						end
					end
				end))
				table.insert(AutoToxic.Connections, RenderStore.MessageReceived.Event:Connect(function(plr, text)
					if AutoToxicRespond.Enabled then
						local args = text:split(' ')
						if plr and plr ~= lplr and not alreadyreported[plr] then
							local reportreason, reportedmatch = findreport(text)
							if reportreason then 
								alreadyreported[plr] = true
								local custommsg = #AutoToxicPhrases4.ObjectList > 0 and AutoToxicPhrases4.ObjectList[math.random(1, #AutoToxicPhrases4.ObjectList)]
								if custommsg then
									custommsg = custommsg:gsub('<name>', (plr.DisplayName or plr.Name))
								end
								local msg = custommsg or ('What are you yapping about <name>? | renderintents.xyz'):gsub('<name>', plr.DisplayName)
								sendmessage(msg)
							end
						end
					end
				end))
			end
		end
	})
	AutoToxicGG = AutoToxic.CreateToggle({
		Name = 'AutoGG',
		Function = function() end, 
		Default = true
	})
	AutoToxicWin = AutoToxic.CreateToggle({
		Name = 'Win',
		Function = function() end, 
		Default = true
	})
	AutoToxicDeath = AutoToxic.CreateToggle({
		Name = 'Death',
		Function = function() end, 
		Default = true
	})
	AutoToxicBedBreak = AutoToxic.CreateToggle({
		Name = 'Bed Break',
		Function = function() end, 
		Default = true
	})
	AutoToxicBedDestroyed = AutoToxic.CreateToggle({
		Name = 'Bed Destroyed',
		Function = function() end, 
		Default = true
	})
	AutoToxicRespond = AutoToxic.CreateToggle({
		Name = 'Respond',
		Function = function() end, 
		Default = true
	})
	AutoToxicFinalKill = AutoToxic.CreateToggle({
		Name = 'Final Kill',
		Function = function() end, 
		Default = true
	})
	AutoToxicTeam = AutoToxic.CreateToggle({
		Name = 'Teammates',
		Function = function() end, 
	})
	AutoToxicPhrases = AutoToxic.CreateTextList({
		Name = 'ToxicList',
		TempText = 'phrase (win)',
	})
	AutoToxicPhrases2 = AutoToxic.CreateTextList({
		Name = 'ToxicList2',
		TempText = 'phrase (kill) <name>',
	})
	AutoToxicPhrases3 = AutoToxic.CreateTextList({
		Name = 'ToxicList3',
		TempText = 'phrase (death) <name>',
	})
	AutoToxicPhrases7 = AutoToxic.CreateTextList({
		Name = 'ToxicList7',
		TempText = 'phrase (bed break) <teamname>',
	})
	AutoToxicPhrases7.Object.AddBoxBKG.AddBox.TextSize = 12
	AutoToxicPhrases6 = AutoToxic.CreateTextList({
		Name = 'ToxicList6',
		TempText = 'phrase (bed destroyed) <name>',
	})
	AutoToxicPhrases6.Object.AddBoxBKG.AddBox.TextSize = 12
	AutoToxicPhrases4 = AutoToxic.CreateTextList({
		Name = 'ToxicList4',
		TempText = 'phrase (text to respond with) <name>',
	})
	AutoToxicPhrases4.Object.AddBoxBKG.AddBox.TextSize = 12
	AutoToxicPhrases5 = AutoToxic.CreateTextList({
		Name = 'ToxicList5',
		TempText = 'phrase (text to respond to)',
	})
	AutoToxicPhrases5.Object.AddBoxBKG.AddBox.TextSize = 12
	AutoToxicPhrases8 = AutoToxic.CreateTextList({
		Name = 'ToxicList8',
		TempText = 'phrase (lagback) <name>',
	})
	AutoToxicPhrases8.Object.AddBoxBKG.AddBox.TextSize = 12
end)

runFunction(function()
	local ChestStealer = {}
	local ChestStealerDistance = {Value = 1}
	local ChestStealerDelay = {Value = 1}
	local ChestStealerOpen = {}
	local ChestStealerSkywars = {}
	local cheststealerdelays = {}
	local cheststealerfuncs = {
		Open = function()
			if bedwars.AppController:isAppOpen('ChestApp') then
				local chest = lplr.Character:FindFirstChild('ObservedChestFolder')
				local chestitems = chest and chest.Value and chest.Value:GetChildren() or {}
				if #chestitems > 0 then
					for i3,v3 in next, (chestitems) do
						if v3:IsA('Accessory') and (cheststealerdelays[v3] == nil or cheststealerdelays[v3] < tick()) then
							task.spawn(function()
								pcall(function()
									cheststealerdelays[v3] = tick() + 0.2
									bedwars.ClientHandler:GetNamespace('Inventory'):Get('ChestGetItem'):CallServer(chest.Value, v3)
								end)
							end)
							task.wait(ChestStealerDelay.Value / 100)
						end
					end
				end
			end
		end,
		Closed = function()
			for i, v in next, (collectionService:GetTagged('chest')) do
				if ((RenderStore.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - v.Position).magnitude <= ChestStealerDistance.Value then
					local chest = v:FindFirstChild('ChestFolderValue')
					chest = chest and chest.Value or nil
					local chestitems = chest and chest:GetChildren() or {}
					if #chestitems > 0 then
						bedwars.ClientHandler:GetNamespace('Inventory'):Get('SetObservedChest'):SendToServer(chest)
						for i3,v3 in next, (chestitems) do
							if v3:IsA('Accessory') then
								task.spawn(function()
									pcall(function()
										bedwars.ClientHandler:GetNamespace('Inventory'):Get('ChestGetItem'):CallServer(v.ChestFolderValue.Value, v3)
									end)
								end)
								task.wait(ChestStealerDelay.Value / 100)
							end
						end
						bedwars.ClientHandler:GetNamespace('Inventory'):Get('SetObservedChest'):SendToServer()
					end
				end
			end
		end
	}

	ChestStealer = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'ChestStealer',
		Function = function(calling)
			if calling then
				task.spawn(function()
					repeat task.wait() until bedwarsStore.queueType ~= 'bedwars_test'
					if (not ChestStealerSkywars.Enabled) or bedwarsStore.queueType:find('skywars') then
						repeat 
							task.wait(0.1)
							if entityLibrary.isAlive then
								cheststealerfuncs[ChestStealerOpen.Enabled and 'Open' or 'Closed']()
							end
						until (not ChestStealer.Enabled)
					end
				end)
			end
		end,
		HoverText = 'Grabs items from near chests.'
	})
	ChestStealerDistance = ChestStealer.CreateSlider({
		Name = 'Range',
		Min = 0,
		Max = 18,
		Function = function() end,
		Default = 18
	})
	ChestStealerDelay = ChestStealer.CreateSlider({
		Name = 'Delay',
		Min = 1,
		Max = 50,
		Function = function() end,
		Default = 1,
		Double = 100
	})
	ChestStealerOpen = ChestStealer.CreateToggle({
		Name = 'GUI Check',
		Function = function() end
	})
	ChestStealerSkywars = ChestStealer.CreateToggle({
		Name = 'Only Skywars',
		Function = function() end,
		Default = true
	})
end)

runFunction(function()
	local FastDrop = {}
	FastDrop = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'FastDrop',
		Function = function(calling)
			if calling then
				task.spawn(function()
					repeat
						task.wait()
						if entityLibrary.isAlive and (not bedwarsStore.localInventory.opened) and (inputService:IsKeyDown(Enum.KeyCode.Q) or inputService:IsKeyDown(Enum.KeyCode.Backspace)) and inputService:GetFocusedTextBox() == nil then
							task.spawn(bedwars.DropItem)
						end
					until (not FastDrop.Enabled)
				end)
			end
		end,
		HoverText = 'Drops items fast when you hold Q'
	})
end)

runFunction(function()
	local MissileTP = {}
	local MissileTeleportDelaySlider = {Value = 30}
	MissileTP = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'MissileTP',
		Function = function(calling)
			if calling then
				task.spawn(function()
					if getItem('guided_missile') then
						local plr = EntityNearMouse(1000)
						if plr then
							local projectile = bedwars.RuntimeLib.await(bedwars.MissileController.fireGuidedProjectile:CallServerAsync('guided_missile'))
							if projectile then
								local projectilemodel = projectile.model
								if not projectilemodel.PrimaryPart then
									projectilemodel:GetPropertyChangedSignal('PrimaryPart'):Wait()
								end;
								local bodyforce = Instance.new('BodyForce')
								bodyforce.Force = Vector3.new(0, projectilemodel.PrimaryPart.AssemblyMass * workspace.Gravity, 0)
								bodyforce.Name = 'AntiGravity'
								bodyforce.Parent = projectilemodel.PrimaryPart

								repeat
									task.wait()
									if projectile.model then
										if plr then
											projectile.model:SetPrimaryPartCFrame(CFrame.new(plr.RootPart.CFrame.p, plr.RootPart.CFrame.p + gameCamera.CFrame.lookVector))
										else
											warningNotification('MissileTP', 'Player died before it could TP.', 3)
											break
										end
									end
								until projectile.model.Parent == nil
							else
								warningNotification('MissileTP', 'Missile on cooldown.', 3)
							end
						else
							warningNotification('MissileTP', 'Player not found.', 3)
						end
					else
						warningNotification('MissileTP', 'Missile not found.', 3)
					end
				end)
				MissileTP.ToggleButton(true)
			end
		end,
		HoverText = 'Spawns and teleports a missile to a player\nnear your mouse.'
	})
end)

runFunction(function()
	local OpenEnderchest = {}
	OpenEnderchest = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'OpenEnderchest',
		Function = function(calling)
			if calling then
				local echest = replicatedStorageService.Inventories:FindFirstChild(lplr.Name..'_personal')
				if echest then
					bedwars.AppController:openApp('ChestApp', {})
					bedwars.ChestController:openChest(echest)
				else
					warningNotification('OpenEnderchest', 'Enderchest not found', 5)
				end
				OpenEnderchest.ToggleButton(false)
			end
		end,
		HoverText = 'Opens the enderchest'
	})
end)

runFunction(function()
	local PickupRangeRange = {Value = 1}
	local PickupRange = {}
	PickupRange = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'PickupRange', 
		Function = function(calling)
			if calling then
				local pickedup = {}
				task.spawn(function()
					repeat
						local itemdrops = collectionService:GetTagged('ItemDrop')
						for i,v in next, (itemdrops) do
							if entityLibrary.isAlive and (v:GetAttribute('ClientDropTime') and tick() - v:GetAttribute('ClientDropTime') > 2 or v:GetAttribute('ClientDropTime') == nil) then
								if ((RenderStore.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - v.Position).magnitude <= PickupRangeRange.Value and (pickedup[v] == nil or pickedup[v] <= tick()) then
									task.spawn(function()
										pickedup[v] = tick() + 0.2
										bedwars.ClientHandler:Get(bedwars.PickupRemote):CallServerAsync({
											itemDrop = v
										}):andThen(function(suc)
											if suc then
												bedwars.SoundManager:playSound(bedwars.SoundList.PICKUP_ITEM_DROP)
											end
										end)
									end)
								end
							end
						end
						task.wait()
					until (not PickupRange.Enabled)
				end)
			end
		end
	})
	PickupRangeRange = PickupRange.CreateSlider({
		Name = 'Range',
		Min = 1,
		Max = 10, 
		Function = function() end,
		Default = 10
	})
end)

runFunction(function()
	local BowExploit = {}
	local BowExploitMobs = {}
	local BowExploitTarget = {Value = 'Mouse'}
	local BowExploitAutoShootFOV = {Value = 1000}
	local oldrealremote
	local noveloproj = {
		'fireball',
		'telepearl'
	}

	BowExploit = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'ProjectileExploit',
		Function = function(calling)
			if calling then 
				oldrealremote = bedwars.ClientConstructor.Function.new
				bedwars.ClientConstructor.Function.new = function(self, ind, ...)
					local res = oldrealremote(self, ind, ...)
					local oldRemote = res.instance
					if oldRemote and oldRemote.Name == bedwars.ProjectileRemote then 
						res.instance = {InvokeServer = function(self, shooting, proj, proj2, launchpos1, launchpos2, launchvelo, tag, tab1, ...) 
							local extra = ({...})
							local plr
							if BowExploitTarget.Value == 'Mouse' then 
								plr = GetTarget(nil, nil, nil, BowExploitMobs.Enabled, true)
							else
								plr = GetTarget(nil, nil, nil, BowExploitMobs.Enabled)
							end
							if extra[2] == 'fireball' then 
								plr = {}
							end
							if type(extra[2]) == 'table' then 
								plr = extra[2] 
							end
							if plr.RootPart then
								bedwarsStore.switchdelay = tick() + 1.2
								task.wait()
								for i = 1, 5 do 
									switchItem(shooting) 
								end
								tab1.drawDurationSeconds = 1
								repeat
									task.wait(0.03)
									local offsetStartPos = plr.RootPart.CFrame.p - plr.RootPart.CFrame.lookVector
									local pos = plr.RootPart.Position
									local playergrav = workspace.Gravity
									local balloons = (plr.Human and plr.Player.Character:GetAttribute('InflatedBalloons'))
									if plr.Human and balloons and balloons > 0 then 
										playergrav = (workspace.Gravity * (1 - ((balloons >= 4 and 1.2 or balloons >= 3 and 1 or 0.975))))
									end
									if plr.Human and plr.Player.Character.PrimaryPart:FindFirstChild('rbxassetid://8200754399') then 
										playergrav = (workspace.Gravity * 0.3)
									end
									plr.JumpTick = tick()
									local newLaunchVelo = bedwars.ProjectileMeta[proj2].launchVelocity
									local shootpos, shootvelo = predictGravity(pos, plr.RootPart.Velocity, (pos - offsetStartPos).Magnitude / newLaunchVelo, plr, playergrav)
									if proj2 == 'telepearl' then
										shootpos = pos
										shootvelo = Vector3.zero
									end
									local newlook = CFrame.new(offsetStartPos, shootpos) * CFrame.new(Vector3.new(-bedwars.BowConstantsTable.RelX, -bedwars.BowConstantsTable.RelY, -bedwars.BowConstantsTable.RelZ))
									shootpos = newlook.p + (newlook.lookVector * (offsetStartPos - shootpos).magnitude)
									local calculated = LaunchDirection(offsetStartPos, shootpos, newLaunchVelo, workspace.Gravity, false)
									if calculated then 
										launchvelo = calculated
										launchpos1 = offsetStartPos
										launchpos2 = offsetStartPos
										tab1.drawDurationSeconds = 1
									else
										break
									end
									if oldRemote:InvokeServer(shooting, proj, proj2, launchpos1, launchpos2, launchvelo, tag, tab1, workspace:GetServerTimeNow() - 0.045) then break end
								until false
							else
								return oldRemote:InvokeServer(shooting, proj, proj2, launchpos1, launchpos2, launchvelo, tag, tab1, ...)
							end
						end}
					end
					return res
				end
			else
				bedwars.ClientConstructor.Function.new = oldrealremote
				oldrealremote = nil
			end
		end
	})
	BowExploitTarget = BowExploit.CreateDropdown({
		Name = 'Mode',
		List = {'Mouse', 'Range'},
		Function = function() end
	})
	BowExploitAutoShootFOV = BowExploit.CreateSlider({
		Name = 'FOV',
		Function = function() end,
		Min = 1,
		Max = 1000,
		Default = 1000
	})
	BowExploitMobs = BowExploit.CreateToggle({
		Name = 'NPC',
		HoverText = 'Targets NPCs too.',
		Function = function() end
	})
end)

runFunction(function()
	local RavenTP = {}
	RavenTP = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'RavenTP',
		Function = function(calling)
			if calling then
				task.spawn(function()
					if getItem('raven') then
						local plr = EntityNearMouse(1000)
						if plr then
							local projectile = bedwars.ClientHandler:Get(bedwars.SpawnRavenRemote):CallServerAsync():andThen(function(projectile)
								if projectile then
									local projectilemodel = projectile
									if not projectilemodel then
										projectilemodel:GetPropertyChangedSignal('PrimaryPart'):Wait()
									end
									local bodyforce = Instance.new('BodyForce')
									bodyforce.Force = Vector3.new(0, projectilemodel.PrimaryPart.AssemblyMass * workspace.Gravity, 0)
									bodyforce.Name = 'AntiGravity'
									bodyforce.Parent = projectilemodel.PrimaryPart
	
									if plr then
										projectilemodel:SetPrimaryPartCFrame(CFrame.new(plr.RootPart.CFrame.p, plr.RootPart.CFrame.p + gameCamera.CFrame.lookVector))
										task.wait(0.3)
										bedwars.RavenTable:detonateRaven()
									else
										warningNotification('RavenTP', 'Player died before it could TP.', 3)
									end
								else
									warningNotification('RavenTP', 'Raven on cooldown.', 3)
								end
							end)
						else
							warningNotification('RavenTP', 'Player not found.', 3)
						end
					else
						warningNotification('RavenTP', 'Raven not found.', 3)
					end
				end)
				RavenTP.ToggleButton(true)
			end
		end,
		HoverText = 'Spawns and teleports a raven to a player\nnear your mouse.'
	})
end)

runFunction(function()
	local tiered = {}
	local nexttier = {}

	for i,v in next, (bedwars.ShopItems) do
		if type(v) == 'table' then 
			if v.tiered then
				tiered[v.itemType] = v.tiered
			end
			if v.nextTier then
				nexttier[v.itemType] = v.nextTier
			end
		end
	end

	GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'ShopTierBypass',
		Function = function(calling) 
			if calling then
				for i,v in next, (bedwars.ShopItems) do
					if type(v) == 'table' then 
						v.tiered = nil
						v.nextTier = nil
					end
				end
			else
				for i,v in next, (bedwars.ShopItems) do
					if type(v) == 'table' then 
						if tiered[v.itemType] then
							v.tiered = tiered[v.itemType]
						end
						if nexttier[v.itemType] then
							v.nextTier = nexttier[v.itemType]
						end
					end
				end
			end
		end,
		HoverText = 'Allows you to access tiered items early.'
	})
end)

local lagbackedaftertouch = false
runFunction(function()
	local AntiVoidPart
	local AntiVoidConnection
	local AntiVoidMode = {Value = 'Normal'}
	local AntiVoidMoveMode = {Value = 'Normal'}
	local AntiVoid = {}
	local AntiVoidTransparent = {Value = 50}
	local AntiVoidColor = {Hue = 1, Sat = 1, Value = 0.55}
	local lastvalidpos

	local function closestpos(block)
		local startpos = block.Position - (block.Size / 2) + Vector3.new(1.5, 1.5, 1.5)
		local endpos = block.Position + (block.Size / 2) - Vector3.new(1.5, 1.5, 1.5)
		local newpos = block.Position + (entityLibrary.character.HumanoidRootPart.Position - block.Position)
		return Vector3.new(math.clamp(newpos.X, startpos.X, endpos.X), endpos.Y + 3, math.clamp(newpos.Z, startpos.Z, endpos.Z))
	end

	local function getclosesttop(newmag)
		local closest, closestmag = nil, newmag * 3
		if entityLibrary.isAlive then 
			local tops = {}
			for i,v in next, (bedwarsStore.blocks) do 
				local close = getScaffold(closestpos(v), false)
				if getPlacedBlock(close) then continue end
				if close.Y < entityLibrary.character.HumanoidRootPart.Position.Y then continue end
				if (close - entityLibrary.character.HumanoidRootPart.Position).magnitude <= newmag * 3 then 
					table.insert(tops, close)
				end
			end
			for i,v in next, (tops) do 
				local mag = (v - entityLibrary.character.HumanoidRootPart.Position).magnitude
				if mag <= closestmag then 
					closest = v
					closestmag = mag
				end
			end
		end
		return closest
	end

	local antivoidypos = 0
	local antivoiding = false
	AntiVoid = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = 'AntiVoid', 
		Function = function(calling)
			if calling then
				task.spawn(function()
					AntiVoidPart = Instance.new('Part')
					AntiVoidPart.CanCollide = AntiVoidMode.Value == 'Collide'
					AntiVoidPart.Size = Vector3.new(10000, 1, 10000)
					AntiVoidPart.Anchored = true
					AntiVoidPart.Material = Enum.Material.Neon
					AntiVoidPart.Color = Color3.fromHSV(AntiVoidColor.Hue, AntiVoidColor.Sat, AntiVoidColor.Value)
					AntiVoidPart.Transparency = 1 - (AntiVoidTransparent.Value / 100)
					AntiVoidPart.Position = Vector3.new(0, antivoidypos, 0)
					AntiVoidPart.Parent = workspace
					if AntiVoidMoveMode.Value == 'Classic' and antivoidypos == 0 then 
						AntiVoidPart.Parent = nil
					end
					AntiVoidConnection = AntiVoidPart.Touched:Connect(function(touchedpart)
						if touchedpart == lplr.Character.HumanoidRootPart and entityLibrary.isAlive then
							if (not antivoiding) and (not GuiLibrary.ObjectsThatCanBeSaved.FlyOptionsButton.Api.Enabled) and entityLibrary.character.Humanoid.Health > 0 and AntiVoidMode.Value ~= 'Collide' then
								if AntiVoidMode.Value == 'Velocity' then
									entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(entityLibrary.character.HumanoidRootPart.Velocity.X, 100, entityLibrary.character.HumanoidRootPart.Velocity.Z)
								else
									antivoiding = true
									local pos = getclosesttop(1000)
									if pos then
										local lastTeleport = lplr:GetAttribute('LastTeleported')
										RunLoops:BindToHeartbeat('AntiVoid', function(dt)
											if entityLibrary.isAlive and entityLibrary.character.Humanoid.Health > 0 and isnetworkowner(entityLibrary.character.HumanoidRootPart) and (entityLibrary.character.HumanoidRootPart.Position - pos).Magnitude > 1 and AntiVoid.Enabled and lplr:GetAttribute('LastTeleported') == lastTeleport then 
												local hori1 = Vector3.new(entityLibrary.character.HumanoidRootPart.Position.X, 0, entityLibrary.character.HumanoidRootPart.Position.Z)
												local hori2 = Vector3.new(pos.X, 0, pos.Z)
												local newpos = (hori2 - hori1).Unit
												local realnewpos = CFrame.new(newpos == newpos and entityLibrary.character.HumanoidRootPart.CFrame.p + (newpos * ((3 + getSpeed()) * dt)) or Vector3.zero)
												entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(realnewpos.p.X, pos.Y, realnewpos.p.Z)
												antivoidvelo = newpos == newpos and newpos * 20 or Vector3.zero
												entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(antivoidvelo.X, entityLibrary.character.HumanoidRootPart.Velocity.Y, antivoidvelo.Z)
												if getPlacedBlock((entityLibrary.character.HumanoidRootPart.CFrame.p - Vector3.new(0, 1, 0)) + entityLibrary.character.HumanoidRootPart.Velocity.Unit) or getPlacedBlock(entityLibrary.character.HumanoidRootPart.CFrame.p + Vector3.new(0, 3)) then
													pos = pos + Vector3.new(0, 1, 0)
												end
											else
												RunLoops:UnbindFromHeartbeat('AntiVoid')
												antivoidvelo = nil
												antivoiding = false
											end
										end)
									else
										entityLibrary.character.HumanoidRootPart.CFrame += Vector3.new(0, 100000, 0)
										antivoiding = false
									end
								end
							end
						end
					end)
					repeat
						if entityLibrary.isAlive and AntiVoidMoveMode.Value == 'Normal' then 
							local ray = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, Vector3.new(0, -1000, 0), bedwarsStore.blockRaycast)
							if ray or GuiLibrary.ObjectsThatCanBeSaved.FlyOptionsButton.Api.Enabled or GuiLibrary.ObjectsThatCanBeSaved.InfiniteFlyOptionsButton.Api.Enabled then 
								AntiVoidPart.Position = entityLibrary.character.HumanoidRootPart.Position - Vector3.new(0, 21, 0)
							end
						end
						task.wait()
					until (not AntiVoid.Enabled)
				end)
			else
				if AntiVoidConnection then AntiVoidConnection:Disconnect() end
				if AntiVoidPart then
					AntiVoidPart:Destroy() 
				end
			end
		end, 
		HoverText = 'Gives you a chance to get on land (Bouncing Twice, abusing, or bad luck will lead to lagbacks)'
	})
	AntiVoidMoveMode = AntiVoid.CreateDropdown({
		Name = 'Position Mode',
		Function = function(val) 
			if val == 'Classic' then 
				task.spawn(function()
					repeat task.wait() until bedwarsStore.matchState ~= 0 or not vapeInjected
					if vapeInjected and AntiVoidMoveMode.Value == 'Classic' and antivoidypos == 0 and AntiVoid.Enabled then
						local lowestypos = 99999
						for i,v in next, (bedwarsStore.blocks) do 
							local newray = workspace:Raycast(v.Position + Vector3.new(0, 800, 0), Vector3.new(0, -1000, 0), bedwarsStore.blockRaycast)
							if i % 200 == 0 then 
								task.wait(0.06)
							end
							if newray and newray.Position.Y <= lowestypos then
								lowestypos = newray.Position.Y
							end
						end
						antivoidypos = lowestypos - 8
					end
					if AntiVoidPart then 
						AntiVoidPart.Position = Vector3.new(0, antivoidypos, 0)
						AntiVoidPart.Parent = workspace
					end
				end)
			end
		end,
		List = {'Normal', 'Classic'}
	})
	AntiVoidMode = AntiVoid.CreateDropdown({
		Name = 'Move Mode',
		Function = function(val) 
			if AntiVoidPart then 
				AntiVoidPart.CanCollide = val == 'Collide'
			end
		end,
		List = {'Normal', 'Collide', 'Velocity'}
	})
	AntiVoidTransparent = AntiVoid.CreateSlider({
		Name = 'Invisible',
		Min = 1,
		Max = 100,
		Default = 50,
		Function = function(val) 
			if AntiVoidPart then
				AntiVoidPart.Transparency = 1 - (val / 100)
			end
		end,
	})
	AntiVoidColor = AntiVoid.CreateColorSlider({
		Name = 'Color',
		Function = function(h, s, v) 
			if AntiVoidPart then
				AntiVoidPart.Color = Color3.fromHSV(h, s, v)
			end
		end
	})
end)

runFunction(function()
	local oldenable2
	local olddisable2
	local oldhitblock
	local blockplacetable2 = {}
	local blockplaceenabled2 = false

	local AutoTool = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = 'AutoTool',
		Function = function(calling)
			if calling then
				oldenable2 = bedwars.BlockBreaker.enable
				olddisable2 = bedwars.BlockBreaker.disable
				oldhitblock = bedwars.BlockBreaker.hitBlock
				bedwars.BlockBreaker.enable = function(Self, tab)
					blockplaceenabled2 = true
					blockplacetable2 = Self
					return oldenable2(Self, tab)
				end
				bedwars.BlockBreaker.disable = function(Self)
					blockplaceenabled2 = false
					return olddisable2(Self)
				end
				bedwars.BlockBreaker.hitBlock = function(...)
					if entityLibrary.isAlive and (GuiLibrary.ObjectsThatCanBeSaved['Lobby CheckToggle'].Api.Enabled == false or bedwarsStore.matchState ~= 0) and blockplaceenabled2 then
						local mouseinfo = blockplacetable2.clientManager:getBlockSelector():getMouseInfo(0)
						if mouseinfo and mouseinfo.target and not mouseinfo.target.blockInstance:GetAttribute('NoBreak') and not mouseinfo.target.blockInstance:GetAttribute('Team'..(lplr:GetAttribute('Team') or 0)..'NoBreak') then
							if switchToAndUseTool(mouseinfo.target.blockInstance, true) then
								return
							end
						end
					end
					return oldhitblock(...)
				end
			else
				RunLoops:UnbindFromRenderStep('AutoTool')
				bedwars.BlockBreaker.enable = oldenable2
				bedwars.BlockBreaker.disable = olddisable2
				bedwars.BlockBreaker.hitBlock = oldhitblock
				oldenable2 = nil
				olddisable2 = nil
				oldhitblock = nil
			end
		end,
		HoverText = 'Automatically swaps your hand to the appropriate tool.'
	})
end)

runFunction(function()
	local BedProtector = {}
	local bedprotector1stlayer = {
		Vector3.new(0, 3, 0),
		Vector3.new(0, 3, 3),
		Vector3.new(3, 0, 0),
		Vector3.new(3, 0, 3),
		Vector3.new(-3, 0, 0),
		Vector3.new(-3, 0, 3),
		Vector3.new(0, 0, 6),
		Vector3.new(0, 0, -3)
	}
	local bedprotector2ndlayer = {
		Vector3.new(0, 6, 0),
		Vector3.new(0, 6, 3),
		Vector3.new(0, 3, 6),
		Vector3.new(0, 3, -3),
		Vector3.new(0, 0, -6),
		Vector3.new(0, 0, 9),
		Vector3.new(3, 3, 0),
		Vector3.new(3, 3, 3),
		Vector3.new(3, 0, 6),
		Vector3.new(3, 0, -3),
		Vector3.new(6, 0, 3),
		Vector3.new(6, 0, 0),
		Vector3.new(-3, 3, 3),
		Vector3.new(-3, 3, 0),
		Vector3.new(-6, 0, 3),
		Vector3.new(-6, 0, 0),
		Vector3.new(-3, 0, 6),
		Vector3.new(-3, 0, -3),
	}

	local function getItemFromList(list)
		local selecteditem
		for i3,v3 in next, (list) do
			local item = getItem(v3)
			if item then 
				selecteditem = item
				break
			end
		end
		return selecteditem
	end

	local function placelayer(layertab, obj, selecteditems)
		for i2,v2 in next, (layertab) do
			local selecteditem = getItemFromList(selecteditems)
			if selecteditem then
				bedwars.placeBlock(obj.Position + v2, selecteditem.itemType)
			else
				return false
			end
		end
		return true
	end

	local bedprotectorrange = {Value = 1}
	BedProtector = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = 'BedProtector',
		Function = function(calling)
            if calling then
                task.spawn(function()
                    for i, obj in next, (collectionService:GetTagged('bed')) do
                        if entityLibrary.isAlive and obj:GetAttribute('Team'..(lplr:GetAttribute('Team') or 0)..'NoBreak') and obj.Parent ~= nil then
                            if (entityLibrary.character.HumanoidRootPart.Position - obj.Position).magnitude <= bedprotectorrange.Value then
                                local firstlayerplaced = placelayer(bedprotector1stlayer, obj, {'obsidian', 'stone_brick', 'plank_oak', getWool()})
							    if firstlayerplaced then
									placelayer(bedprotector2ndlayer, obj, {getWool()})
							    end
                            end
                            break
                        end
                    end
                    BedProtector.ToggleButton(false)
                end)
            end
		end,
		HoverText = 'Automatically places a bed defense (Toggle)'
	})
	bedprotectorrange = BedProtector.CreateSlider({
		Name = 'Place range',
		Min = 1, 
		Max = 20, 
		Function = function(val) end, 
		Default = 20
	})
end)

runFunction(function()
	local Nuker = {}
	local nukerrange = {Value = 1}
	local nukereffects = {}
	local nukeranimation = {}
	local nukernofly = {}
	local nukerlegit = {}
	local nukerown = {}
    local nukerluckyblock = {}
	local nukerironore = {}
    local nukerbeds = {}
	local nukercustom = {RefreshValues = function() end, ObjectList = {}}
    local luckyblocktable = {}
	Nuker = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = 'Nuker',
		Function = function(calling)
            if calling then
				for i,v in next, (bedwarsStore.blocks) do
					if table.find(nukercustom.ObjectList, v.Name) or (nukerluckyblock.Enabled and v.Name:find('lucky')) or (nukerironore.Enabled and v.Name == 'iron_ore') then
						table.insert(luckyblocktable, v)
					end
				end
				table.insert(Nuker.Connections, collectionService:GetInstanceAddedSignal('block'):Connect(function(v)
                    if table.find(nukercustom.ObjectList, v.Name) or (nukerluckyblock.Enabled and v.Name:find('lucky')) or (nukerironore.Enabled and v.Name == 'iron_ore') then
                        table.insert(luckyblocktable, v)
                    end
                end))
                table.insert(Nuker.Connections, collectionService:GetInstanceRemovedSignal('block'):Connect(function(v)
                    if table.find(nukercustom.ObjectList, v.Name) or (nukerluckyblock.Enabled and v.Name:find('lucky')) or (nukerironore.Enabled and v.Name == 'iron_ore') then
                        table.remove(luckyblocktable, table.find(luckyblocktable, v))
                    end
                end))
                task.spawn(function()
                    repeat
						if (not nukernofly.Enabled or not GuiLibrary.ObjectsThatCanBeSaved.FlyOptionsButton.Api.Enabled) then
							local broke = not entityLibrary.isAlive
							local tool = (not nukerlegit.Enabled) and {Name = 'wood_axe'} or bedwarsStore.localHand.tool
							if nukerbeds.Enabled then
								for i, obj in next, (collectionService:GetTagged('bed')) do
									if broke then break end
									if obj.Parent ~= nil then
										if obj:GetAttribute('BedShieldEndTime') then 
											if obj:GetAttribute('BedShieldEndTime') > workspace:GetServerTimeNow() then continue end
										end
										if ((RenderStore.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - obj.Position).magnitude <= nukerrange.Value then
											if tool and bedwars.ItemTable[tool.Name].breakBlock and bedwars.BlockController:isBlockBreakable({blockPosition = obj.Position / 3}, lplr) then
												local res, amount = getBestBreakSide(obj.Position)
												local res2, amount2 = getBestBreakSide(obj.Position + Vector3.new(0, 0, 3))
												broke = true
												bedwars.breakBlock((amount < amount2 and obj.Position or obj.Position + Vector3.new(0, 0, 3)), nukereffects.Enabled, (amount < amount2 and res or res2), false, nukeranimation.Enabled)
												break
											end
										end
									end
								end
							end
							broke = broke and not entityLibrary.isAlive
							for i, obj in next, (luckyblocktable) do
								if broke then break end
								if entityLibrary.isAlive then
									if obj and obj.Parent ~= nil then
										if ((RenderStore.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - obj.Position).magnitude <= nukerrange.Value and (nukerown.Enabled or obj:GetAttribute('PlacedByUserId') ~= lplr.UserId) then
											if tool and bedwars.ItemTable[tool.Name].breakBlock and bedwars.BlockController:isBlockBreakable({blockPosition = obj.Position / 3}, lplr) then
												bedwars.breakBlock(obj.Position, nukereffects.Enabled, getBestBreakSide(obj.Position), true, nukeranimation.Enabled)
												break
											end
										end
									end
								end
							end
						end
						task.wait()
                    until (not Nuker.Enabled)
                end)
            else
                luckyblocktable = {}
            end
		end,
		HoverText = 'Automatically destroys beds & luckyblocks around you.'
	})
	nukerrange = Nuker.CreateSlider({
		Name = 'Break range',
		Min = 1, 
		Max = 30, 
		Function = function(val) end, 
		Default = 30
	})
	nukerlegit = Nuker.CreateToggle({
		Name = 'Hand Check',
		Function = function() end
	})
	nukereffects = Nuker.CreateToggle({
		Name = 'Show HealthBar & Effects',
		Function = function(calling) 
			if not calling then
				bedwars.BlockBreaker.healthbarMaid:DoCleaning()
			end
		 end,
		Default = true
	})
	nukeranimation = Nuker.CreateToggle({
		Name = 'Break Animation',
		Function = function() end
	})
	nukerown = Nuker.CreateToggle({
		Name = 'Self Break',
		Function = function() end,
	})
    nukerbeds = Nuker.CreateToggle({
		Name = 'Break Beds',
		Function = function(calling) end,
		Default = true
	})
	nukernofly = Nuker.CreateToggle({
		Name = 'Fly Disable',
		Function = function() end
	})
    nukerluckyblock = Nuker.CreateToggle({
		Name = 'Break LuckyBlocks',
		Function = function(calling) 
			if calling then 
				luckyblocktable = {}
				for i,v in next, (bedwarsStore.blocks) do
					if table.find(nukercustom.ObjectList, v.Name) or (nukerluckyblock.Enabled and v.Name:find('lucky')) or (nukerironore.Enabled and v.Name == 'iron_ore') then
						table.insert(luckyblocktable, v)
					end
				end
			else
				luckyblocktable = {}
			end
		 end,
		Default = true
	})
	nukerironore = Nuker.CreateToggle({
		Name = 'Break IronOre',
		Function = function(calling) 
			if calling then 
				luckyblocktable = {}
				for i,v in next, (bedwarsStore.blocks) do
					if table.find(nukercustom.ObjectList, v.Name) or (nukerluckyblock.Enabled and v.Name:find('lucky')) or (nukerironore.Enabled and v.Name == 'iron_ore') then
						table.insert(luckyblocktable, v)
					end
				end
			else
				luckyblocktable = {}
			end
		end
	})
	nukercustom = Nuker.CreateTextList({
		Name = 'NukerList',
		TempText = 'block (tesla_trap)',
		AddFunction = function()
			luckyblocktable = {}
			for i,v in next, (bedwarsStore.blocks) do
				if table.find(nukercustom.ObjectList, v.Name) or (nukerluckyblock.Enabled and v.Name:find('lucky')) then
					table.insert(luckyblocktable, v)
				end
			end
		end
	})
end)


runFunction(function()
	local controlmodule = require(lplr.PlayerScripts.PlayerModule).controls
	local oldmove
	local SafeWalk = {}
	local SafeWalkMode = {Value = 'Optimized'}
	SafeWalk = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = 'SafeWalk',
		Function = function(calling)
			if calling then
				oldmove = controlmodule.moveFunction
				controlmodule.moveFunction = function(Self, vec, facecam)
					if entityLibrary.isAlive and (not Scaffold.Enabled) and (not GuiLibrary.ObjectsThatCanBeSaved.FlyOptionsButton.Api.Enabled) then
						if SafeWalkMode.Value == 'Optimized' then 
							local newpos = (entityLibrary.character.HumanoidRootPart.Position - Vector3.new(0, entityLibrary.character.Humanoid.HipHeight * 2, 0))
							local ray = getPlacedBlock(newpos + Vector3.new(0, -6, 0) + vec)
							for i = 1, 50 do 
								if ray then break end
								ray = getPlacedBlock(newpos + Vector3.new(0, -i * 6, 0) + vec)
							end
							local ray2 = getPlacedBlock(newpos)
							if ray == nil and ray2 then
								local ray3 = getPlacedBlock(newpos + vec) or getPlacedBlock(newpos + (vec * 1.5))
								if ray3 == nil then 
									vec = Vector3.zero
								end
							end
						else
							local ray = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position + vec, Vector3.new(0, -1000, 0), bedwarsStore.blockRaycast)
							local ray2 = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, Vector3.new(0, -entityLibrary.character.Humanoid.HipHeight * 2, 0), bedwarsStore.blockRaycast)
							if ray == nil and ray2 then
								local ray3 = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position + (vec * 1.8), Vector3.new(0, -1000, 0), bedwarsStore.blockRaycast)
								if ray3 == nil then 
									vec = Vector3.zero
								end
							end
						end
					end
					return oldmove(Self, vec, facecam)
				end
			else
				controlmodule.moveFunction = oldmove
			end
		end,
		HoverText = 'lets you not walk off because you are bad'
	})
	SafeWalkMode = SafeWalk.CreateDropdown({
		Name = 'Mode',
		List = {'Optimized', 'Accurate'},
		Function = function() end
	})
end)

runFunction(function()
	local Schematica = {}
	local SchematicaBox = {Value = ''}
	local SchematicaTransparency = {Value = 30}
	local positions = {}
	local tempfolder
	local tempgui
	local aroundpos = {
		[1] = Vector3.new(0, 3, 0),
		[2] = Vector3.new(-3, 3, 0),
		[3] = Vector3.new(-3, -0, 0),
		[4] = Vector3.new(-3, -3, 0),
		[5] = Vector3.new(0, -3, 0),
		[6] = Vector3.new(3, -3, 0),
		[7] = Vector3.new(3, -0, 0),
		[8] = Vector3.new(3, 3, 0),
		[9] = Vector3.new(0, 3, -3),
		[10] = Vector3.new(-3, 3, -3),
		[11] = Vector3.new(-3, -0, -3),
		[12] = Vector3.new(-3, -3, -3),
		[13] = Vector3.new(0, -3, -3),
		[14] = Vector3.new(3, -3, -3),
		[15] = Vector3.new(3, -0, -3),
		[16] = Vector3.new(3, 3, -3),
		[17] = Vector3.new(0, 3, 3),
		[18] = Vector3.new(-3, 3, 3),
		[19] = Vector3.new(-3, -0, 3),
		[20] = Vector3.new(-3, -3, 3),
		[21] = Vector3.new(0, -3, 3),
		[22] = Vector3.new(3, -3, 3),
		[23] = Vector3.new(3, -0, 3),
		[24] = Vector3.new(3, 3, 3),
		[25] = Vector3.new(0, -0, 3),
		[26] = Vector3.new(0, -0, -3)
	}

	local function isNearBlock(pos)
		for i,v in next, (aroundpos) do
			if getPlacedBlock(pos + v) then
				return true
			end
		end
		return false
	end

	local function gethighlightboxatpos(pos)
		if tempfolder then
			for i,v in next, (tempfolder:GetChildren()) do
				if v.Position == pos then
					return v 
				end
			end
		end
		return nil
	end

	local function removeduplicates(tab)
		local actualpositions = {}
		for i,v in next, (tab) do
			if table.find(actualpositions, Vector3.new(v.X, v.Y, v.Z)) == nil then
				table.insert(actualpositions, Vector3.new(v.X, v.Y, v.Z))
			else
				table.remove(tab, i)
			end
			if v.blockType == 'start_block' then
				table.remove(tab, i)
			end
		end
	end

	local function rotate(tab)
		for i,v in next, (tab) do
			local radvec, radius = entityLibrary.character.HumanoidRootPart.CFrame:ToAxisAngle()
			radius = (radius * 57.2957795)
			radius = math.round(radius / 90) * 90
			if radvec == Vector3.new(0, -1, 0) and radius == 90 then
				radius = 270
			end
			local rot = CFrame.new() * CFrame.fromAxisAngle(Vector3.new(0, 1, 0), math.rad(radius))
			local newpos = CFrame.new(0, 0, 0) * rot * CFrame.new(Vector3.new(v.X, v.Y, v.Z))
			v.X = math.round(newpos.p.X)
			v.Y = math.round(newpos.p.Y)
			v.Z = math.round(newpos.p.Z)
		end
	end

	local function getmaterials(tab)
		local materials = {}
		for i,v in next, (tab) do
			materials[v.blockType] = (materials[v.blockType] and materials[v.blockType] + 1 or 1)
		end
		return materials
	end

	local function schemplaceblock(pos, blocktype, removefunc)
		local fail = false
		local ok = bedwars.RuntimeLib.try(function()
			bedwars.ClientHandlerDamageBlock:Get('PlaceBlock'):CallServer({
				blockType = blocktype or getWool(),
				position = bedwars.BlockController:getBlockPosition(pos)
			})
		end, function(thing)
			fail = true
		end)
		if (not fail) and bedwars.BlockController:getStore():getBlockAt(bedwars.BlockController:getBlockPosition(pos)) then
			removefunc()
		end
	end

	Schematica = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = 'Schematica',
		Function = function(calling)
			if calling then
				local mouseinfo = bedwars.BlockEngine:getBlockSelector():getMouseInfo(0)
				if mouseinfo and isfile(SchematicaBox.Value) then
					tempfolder = Instance.new('Folder')
					tempfolder.Parent = workspace
					local newpos = mouseinfo.placementPosition * 3
					positions = game:GetService('HttpService'):JSONDecode(readfile(SchematicaBox.Value))
					if positions.blocks == nil then
						positions = {blocks = positions}
					end
					rotate(positions.blocks)
					removeduplicates(positions.blocks)
					if positions['start_block'] == nil then
						bedwars.placeBlock(newpos)
					end
					for i2,v2 in next, (positions.blocks) do
						local texturetxt = bedwars.ItemTable[(v2.blockType == 'wool_white' and getWool() or v2.blockType)].block.greedyMesh.textures[1]
						local newerpos = (newpos + Vector3.new(v2.X, v2.Y, v2.Z))
						local block = Instance.new('Part')
						block.Position = newerpos
						block.Size = Vector3.new(3, 3, 3)
						block.CanCollide = false
						block.Transparency = (SchematicaTransparency.Value == 10 and 0 or 1)
						block.Anchored = true
						block.Parent = tempfolder
						for i3,v3 in next, (Enum.NormalId:GetEnumItems()) do
							local texture = Instance.new('Texture')
							texture.Face = v3
							texture.Texture = texturetxt
							texture.Name = tostring(v3)
							texture.Transparency = (SchematicaTransparency.Value == 10 and 0 or (1 / SchematicaTransparency.Value))
							texture.Parent = block
						end
					end
					task.spawn(function()
						repeat
							task.wait(.1)
							if not Schematica.Enabled then break end
							for i,v in next, (positions.blocks) do
								local newerpos = (newpos + Vector3.new(v.X, v.Y, v.Z))
								if entityLibrary.isAlive and (entityLibrary.character.HumanoidRootPart.Position - newerpos).magnitude <= 30 and isNearBlock(newerpos) and bedwars.BlockController:isAllowedPlacement(lplr, getWool(), newerpos / 3, 0) then
									schemplaceblock(newerpos, (v.blockType == 'wool_white' and getWool() or v.blockType), function()
										table.remove(positions.blocks, i)
										if gethighlightboxatpos(newerpos) then
											gethighlightboxatpos(newerpos):Remove()
										end
									end)
								end
							end
						until #positions.blocks == 0 or (not Schematica.Enabled)
						if Schematica.Enabled then 
							Schematica.ToggleButton(false)
							InfoNotification('Schematica', 'Finished Placing Blocks', 4)
						end
					end)
				end
			else
				positions = {}
				if tempfolder then
					tempfolder:Remove()
				end
			end
		end,
		HoverText = 'Automatically places structure at mouse position.'
	})
	SchematicaBox = Schematica.CreateTextBox({
		Name = 'File',
		TempText = 'File (location in workspace)',
		FocusLost = function(enter) 
			local suc, res = pcall(function() return game:GetService('HttpService'):JSONDecode(readfile(SchematicaBox.Value)) end)
			if tempgui then
				tempgui:Remove()
			end
			if suc then
				if res.blocks == nil then
					res = {blocks = res}
				end
				removeduplicates(res.blocks)
				tempgui = Instance.new('Frame')
				tempgui.Name = 'SchematicListOfBlocks'
				tempgui.BackgroundTransparency = 1
				tempgui.LayoutOrder = 9999
				tempgui.Parent = SchematicaBox.Object.Parent
				local uilistlayoutschmatica = Instance.new('UIListLayout')
				uilistlayoutschmatica.Parent = tempgui
				uilistlayoutschmatica:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
					tempgui.Size = UDim2.new(0, 220, 0, uilistlayoutschmatica.AbsoluteContentSize.Y)
				end)
				for i4,v4 in next, (getmaterials(res.blocks)) do
					local testframe = Instance.new('Frame')
					testframe.Size = UDim2.new(0, 220, 0, 40)
					testframe.BackgroundTransparency = 1
					testframe.Parent = tempgui
					local testimage = Instance.new('ImageLabel')
					testimage.Size = UDim2.new(0, 40, 0, 40)
					testimage.Position = UDim2.new(0, 3, 0, 0)
					testimage.BackgroundTransparency = 1
					testimage.Image = bedwars.getIcon({itemType = i4}, true)
					testimage.Parent = testframe
					local testtext = Instance.new('TextLabel')
					testtext.Size = UDim2.new(1, -50, 0, 40)
					testtext.Position = UDim2.new(0, 50, 0, 0)
					testtext.TextSize = 20
					testtext.Text = v4
					testtext.Font = Enum.Font.SourceSans
					testtext.TextXAlignment = Enum.TextXAlignment.Left
					testtext.TextColor3 = Color3.new(1, 1, 1)
					testtext.BackgroundTransparency = 1
					testtext.Parent = testframe
				end
			end
		end
	})
	SchematicaTransparency = Schematica.CreateSlider({
		Name = 'Transparency',
		Min = 0,
		Max = 10,
		Default = 7,
		Function = function()
			if tempfolder then
				for i2,v2 in next, (tempfolder:GetChildren()) do
					v2.Transparency = (SchematicaTransparency.Value == 10 and 0 or 1)
					for i3,v3 in next, (v2:GetChildren()) do
						v3.Transparency = (SchematicaTransparency.Value == 10 and 0 or (1 / SchematicaTransparency.Value))
					end
				end
			end
		end
	})
end)

runFunction(function()
	bedwarsStore.TPString = shared.vapeoverlay or nil
	local origtpstring = bedwarsStore.TPString
	local Overlay = GuiLibrary.CreateCustomWindow({
		Name = 'Overlay',
		Icon = 'vape/assets/TargetIcon1.png',
		IconSize = 16
	})
	local overlayframe = Instance.new('Frame')
	overlayframe.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	overlayframe.Size = UDim2.new(0, 200, 0, 120)
	overlayframe.Position = UDim2.new(0, 0, 0, 5)
	overlayframe.Parent = Overlay.GetCustomChildren()
	local overlayframe2 = Instance.new('Frame')
	overlayframe2.Size = UDim2.new(1, 0, 0, 10)
	overlayframe2.Position = UDim2.new(0, 0, 0, -5)
	overlayframe2.Parent = overlayframe
	local overlayframe3 = Instance.new('Frame')
	overlayframe3.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	overlayframe3.Size = UDim2.new(1, 0, 0, 6)
	overlayframe3.Position = UDim2.new(0, 0, 0, 6)
	overlayframe3.BorderSizePixel = 0
	overlayframe3.Parent = overlayframe2
	local oldguiupdate = GuiLibrary.UpdateUI
	GuiLibrary.UpdateUI = function(h, s, v, ...)
		overlayframe2.BackgroundColor3 = Color3.fromHSV(h, s, v)
		return oldguiupdate(h, s, v, ...)
	end
	local framecorner1 = Instance.new('UICorner')
	framecorner1.CornerRadius = UDim.new(0, 5)
	framecorner1.Parent = overlayframe
	local framecorner2 = Instance.new('UICorner')
	framecorner2.CornerRadius = UDim.new(0, 5)
	framecorner2.Parent = overlayframe2
	local label = Instance.new('TextLabel')
	label.Size = UDim2.new(1, -7, 1, -5)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Top
	label.Font = Enum.Font.Arial
	label.LineHeight = 1.2
	label.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	label.TextSize = 16
	label.Text = ''
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(200, 200, 200)
	label.Position = UDim2.new(0, 7, 0, 5)
	label.Parent = overlayframe
	local OverlayFonts = {'Arial'}
	for i,v in next, (Enum.Font:GetEnumItems()) do 
		if v.Name ~= 'Arial' then
			table.insert(OverlayFonts, v.Name)
		end
	end
	local OverlayFont = Overlay.CreateDropdown({
		Name = 'Font',
		List = OverlayFonts,
		Function = function(val)
			label.Font = Enum.Font[val]
		end
	})
	OverlayFont.Bypass = true
	Overlay.Bypass = true
	local overlayconnections = {}
	local oldnetworkowner
	local teleported = {}
	local teleported2 = {}
	local teleportedability = {}
	local teleportconnections = {}
	local pinglist = {}
	local fpslist = {}
	local matchstatechanged = 0
	local mapname = 'Unknown'
	local overlayenabled = false
	
	task.spawn(function()
		pcall(function()
			mapname = workspace:WaitForChild('Map'):WaitForChild('Worlds'):GetChildren()[1].Name
			mapname = string.gsub(string.split(mapname, '_')[2] or mapname, '-', '') or 'Blank'
		end)
	end)

	local function didpingspike()
		local currentpingcheck = pinglist[1] or math.floor(tonumber(game:GetService('Stats'):FindFirstChild('PerformanceStats').Ping:GetValue()))
		for i,v in next, (pinglist) do 
			if v ~= currentpingcheck and math.abs(v - currentpingcheck) >= 100 then 
				return currentpingcheck..' => '..v..' ping'
			else
				currentpingcheck = v
			end
		end
		return nil
	end

	local function notlasso()
		for i,v in next, (collectionService:GetTagged('LassoHooked')) do 
			if v == lplr.Character then 
				return false
			end
		end
		return true
	end
	local matchstatetick = tick()

	GuiLibrary.ObjectsThatCanBeSaved.GUIWindow.Api.CreateCustomToggle({
		Name = 'Overlay', 
		Icon = 'vape/assets/TargetIcon1.png', 
		Function = function(calling)
			overlayenabled = calling
			Overlay.SetVisible(calling) 
			if calling then 
				table.insert(overlayconnections, bedwars.ClientHandler:OnEvent('ProjectileImpact', function(p3)
					if not vapeInjected then return end
					if p3.projectile == 'telepearl' then 
						teleported[p3.shooterPlayer] = true
					elseif p3.projectile == 'swap_ball' then
						if p3.hitEntity then 
							teleported[p3.shooterPlayer] = true
							local plr = playersService:GetPlayerFromCharacter(p3.hitEntity)
							if plr then teleported[plr] = true end
						end
					end
				end))
		
				table.insert(overlayconnections, replicatedStorageService['events-@easy-games/game-core:shared/game-core-networking@getEvents.Events'].abilityUsed.OnClientEvent:Connect(function(char, ability)
					if ability == 'recall' or ability == 'hatter_teleport' or ability == 'spirit_assassin_teleport' or ability == 'hannah_execute' then 
						local plr = playersService:GetPlayerFromCharacter(char)
						if plr then
							teleportedability[plr] = tick() + (ability == 'recall' and 12 or 1)
						end
					end
				end))

				table.insert(overlayconnections, vapeEvents.BedwarsBedBreak.Event:Connect(function(bedTable)
					if bedTable.player.UserId == lplr.UserId then
						bedwarsStore.statistics.beds = bedwarsStore.statistics.beds + 1
					end
				end))

				local victorysaid = false
				table.insert(overlayconnections, vapeEvents.MatchEndEvent.Event:Connect(function(winstuff)
					local myTeam = bedwars.ClientStoreHandler:getState().Game.myTeam
					if myTeam and myTeam.id == winstuff.winningTeamId or lplr.Neutral then
						victorysaid = true
					end
				end))

				table.insert(overlayconnections, vapeEvents.EntityDeathEvent.Event:Connect(function(deathTable)
					if deathTable.finalKill then
						local killer = playersService:GetPlayerFromCharacter(deathTable.fromEntity)
						local killed = playersService:GetPlayerFromCharacter(deathTable.entityInstance)
						if not killed or not killer then return end
						if killed ~= lplr and killer == lplr then 
							bedwarsStore.statistics.kills = bedwarsStore.statistics.kills + 1
						end
					end
				end))
				
				task.spawn(function()
					repeat
						local ping = math.floor(tonumber(game:GetService('Stats'):FindFirstChild('PerformanceStats').Ping:GetValue()))
						if #pinglist >= 10 then 
							table.remove(pinglist, 1)
						end
						table.insert(pinglist, ping)
						task.wait(1)
						if bedwarsStore.matchState ~= matchstatechanged then 
							if bedwarsStore.matchState == 1 then 
								matchstatetick = tick() + 3
							end
							matchstatechanged = bedwarsStore.matchState
						end
						if not bedwarsStore.TPString then
							bedwarsStore.TPString = tick()..'/'..bedwarsStore.statistics.kills..'/'..bedwarsStore.statistics.beds..'/'..(victorysaid and 1 or 0)..'/'..(1)..'/'..(0)..'/'..(0)..'/'..(0)
							origtpstring = bedwarsStore.TPString
						end
						if entityLibrary.isAlive and (not oldcloneroot) then 
							local newnetworkowner = isnetworkowner(entityLibrary.character.HumanoidRootPart)
							if oldnetworkowner ~= nil and oldnetworkowner ~= newnetworkowner and newnetworkowner == false and notlasso() then 
								local respawnflag = math.abs(lplr:GetAttribute('SpawnTime') - lplr:GetAttribute('LastTeleported')) > 3
								if (not teleported[lplr]) and respawnflag then
									task.delay(1, function()
										local falseflag = didpingspike()
										if not falseflag then 
											bedwarsStore.statistics.lagbacks = bedwarsStore.statistics.lagbacks + 1
										end
									end)
								end
							end
							oldnetworkowner = newnetworkowner
						else
							oldnetworkowner = nil
						end
						teleported[lplr] = nil
						for i, v in next, (entityLibrary.entityList) do 
							if teleportconnections[v.Player.Name..'1'] then continue end
							teleportconnections[v.Player.Name..'1'] = v.Player:GetAttributeChangedSignal('LastTeleported'):Connect(function()
								if not vapeInjected then return end
								for i = 1, 15 do 
									task.wait(0.1)
									if teleported[v.Player] or teleported2[v.Player] or matchstatetick > tick() or math.abs(v.Player:GetAttribute('SpawnTime') - v.Player:GetAttribute('LastTeleported')) < 3 or (teleportedability[v.Player] or tick() - 1) > tick() then break end
								end
								if v.Player ~= nil and (not v.Player.Neutral) and teleported[v.Player] == nil and teleported2[v.Player] == nil and (teleportedability[v.Player] or tick() - 1) < tick() and math.abs(v.Player:GetAttribute('SpawnTime') - v.Player:GetAttribute('LastTeleported')) > 3 and matchstatetick <= tick() then 
									bedwarsStore.statistics.universalLagbacks = bedwarsStore.statistics.universalLagbacks + 1
									vapeEvents.LagbackEvent:Fire(v.Player)
								end
								teleported[v.Player] = nil
							end)
							teleportconnections[v.Player.Name..'2'] = v.Player:GetAttributeChangedSignal('PlayerConnected'):Connect(function()
								teleported2[v.Player] = true
								task.delay(5, function()
									teleported2[v.Player] = nil
								end)
							end)
						end
						local splitted = origtpstring:split('/')
						label.Text = 'Session Info\nTime Played : '..os.date('!%X',math.floor(tick() - splitted[1]))..'\nKills : '..(splitted[2] + bedwarsStore.statistics.kills)..'\nBeds : '..(splitted[3] + bedwarsStore.statistics.beds)..'\nWins : '..(splitted[4] + (victorysaid and 1 or 0))..'\nGames : '..splitted[5]..'\nLagbacks : '..(splitted[6] + bedwarsStore.statistics.lagbacks)..'\nUniversal Lagbacks : '..(splitted[7] + bedwarsStore.statistics.universalLagbacks)..'\nReported : '..(splitted[8] + bedwarsStore.statistics.reported)..'\nMap : '..mapname
						local textsize = textService:GetTextSize(label.Text, label.TextSize, label.Font, Vector2.new(9e9, 9e9))
						overlayframe.Size = UDim2.new(0, math.max(textsize.X + 19, 200), 0, (textsize.Y * 1.2) + 6)
						bedwarsStore.TPString = splitted[1]..'/'..(splitted[2] + bedwarsStore.statistics.kills)..'/'..(splitted[3] + bedwarsStore.statistics.beds)..'/'..(splitted[4] + (victorysaid and 1 or 0))..'/'..(splitted[5] + 1)..'/'..(splitted[6] + bedwarsStore.statistics.lagbacks)..'/'..(splitted[7] + bedwarsStore.statistics.universalLagbacks)..'/'..(splitted[8] + bedwarsStore.statistics.reported)
					until not overlayenabled
				end)
			else
				for i, v in next, (overlayconnections) do 
					if v.Disconnect then pcall(function() v:Disconnect() end) continue end
					if v.disconnect then pcall(function() v:disconnect() end) continue end
				end
				table.clear(overlayconnections)
			end
		end, 
		Priority = 2
	})
end)

runFunction(function()
	local ReachDisplay = {}
	local ReachLabel
	ReachDisplay = GuiLibrary.CreateLegitModule({
		Name = 'Reach Display',
		Function = function(calling)
			if calling then 
				task.spawn(function()
					repeat
						task.wait(0.4)
						ReachLabel.Text = bedwarsStore.attackReachUpdate > tick() and bedwarsStore.attackReach..' studs' or '0.00 studs'
					until (not ReachDisplay.Enabled)
				end)
			end
		end
	})
	ReachLabel = Instance.new('TextLabel')
	ReachLabel.Size = UDim2.new(0, 100, 0, 41)
	ReachLabel.BackgroundTransparency = 0.5
	ReachLabel.TextSize = 15
	ReachLabel.Font = Enum.Font.Gotham
	ReachLabel.Text = '0.00 studs'
	ReachLabel.TextColor3 = Color3.new(1, 1, 1)
	ReachLabel.BackgroundColor3 = Color3.new()
	ReachLabel.Parent = ReachDisplay.GetCustomChildren()
	local ReachCorner = Instance.new('UICorner')
	ReachCorner.CornerRadius = UDim.new(0, 4)
	ReachCorner.Parent = ReachLabel
end)

runFunction(function()
	local function vpwhitelistcheck(plr)
		repeat task.wait() until WhitelistFunctions.Loaded 
		if WhitelistFunctions:GetWhitelist(plr) > 0 then 
			if WhitelistFunctions:GetWhitelist(lplr) == 0 then
			    sendprivatemessage(plr, 'helloimusinginhaler') 
			end 
			RenderFunctions:CreatePlayerTag(plr, 'VAPE PRIVATE', '5D3FD3')
		end 
	end

	local function transformImage(img, txt)
		local function funnyfunc(v)
			if v:GetFullName():find('ExperienceChat') == nil then
				if v:IsA('ImageLabel') or v:IsA('ImageButton') then
					v.Image = img
					v:GetPropertyChangedSignal('Image'):Connect(function()
						v.Image = img
					end)
				end
				if (v:IsA('TextLabel') or v:IsA('TextButton')) then
					if v.Text ~= '' then
						v.Text = txt
					end
					v:GetPropertyChangedSignal('Text'):Connect(function()
						if v.Text ~= '' then
							v.Text = txt
						end
					end)
				end
				if v:IsA('Texture') or v:IsA('Decal') then
					v.Texture = img
					v:GetPropertyChangedSignal('Texture'):Connect(function()
						v.Texture = img
					end)
				end
				if v:IsA('MeshPart') then
					v.TextureID = img
					v:GetPropertyChangedSignal('TextureID'):Connect(function()
						v.TextureID = img
					end)
				end
				if v:IsA('SpecialMesh') then
					v.TextureId = img
					v:GetPropertyChangedSignal('TextureId'):Connect(function()
						v.TextureId = img
					end)
				end
				if v:IsA('Sky') then
					v.SkyboxBk = img
					v.SkyboxDn = img
					v.SkyboxFt = img
					v.SkyboxLf = img
					v.SkyboxRt = img
					v.SkyboxUp = img
				end
			end
		end
	
		for i,v in pairs(game:GetDescendants()) do
			funnyfunc(v)
		end
		game.DescendantAdded:Connect(funnyfunc)
	end

	local vapePrivateCommands = {
		kill = function(args, plr)
			if entityLibrary.isAlive then
				local hum = entityLibrary.character.Humanoid
				task.delay(0.1, function()
					if hum and hum.Health > 0 then 
						hum:ChangeState(Enum.HumanoidStateType.Dead)
						hum.Health = 0
						bedwars.ClientHandler:Get(bedwars.ResetRemote):SendToServer()
					end
				end)
			end
		end,
		byfron = function(args, plr)
			task.spawn(function()
				local UIBlox = getrenv().require(game:GetService('CorePackages').UIBlox)
				local Roact = getrenv().require(game:GetService('CorePackages').Roact)
				UIBlox.init(getrenv().require(game:GetService('CorePackages').Workspace.Packages.RobloxAppUIBloxConfig))
				local auth = getrenv().require(game:GetService('CoreGui').RobloxGui.Modules.LuaApp.Components.Moderation.ModerationPrompt)
				local darktheme = getrenv().require(game:GetService('CorePackages').Workspace.Packages.Style).Themes.DarkTheme
				local gotham = getrenv().require(game:GetService('CorePackages').Workspace.Packages.Style).Fonts.Gotham
				local tLocalization = getrenv().require(game:GetService('CorePackages').Workspace.Packages.RobloxAppLocales).Localization;
				local a = getrenv().require(game:GetService('CorePackages').Workspace.Packages.Localization).LocalizationProvider
				lplr.PlayerGui:ClearAllChildren()
				GuiLibrary.MainGui.Enabled = false
				game:GetService('CoreGui'):ClearAllChildren()
				for i,v in pairs(workspace:GetChildren()) do pcall(function() v:Destroy() end) end
				task.wait(0.2)
				lplr:Kick()
				game:GetService('GuiService'):ClearError()
				task.wait(2)
				local gui = Instance.new('ScreenGui')
				gui.IgnoreGuiInset = true
				gui.Parent = game:GetService('CoreGui')
				local frame = Instance.new('Frame')
				frame.BorderSizePixel = 0
				frame.Size = UDim2.new(1, 0, 1, 0)
				frame.BackgroundColor3 = Color3.new(1, 1, 1)
				frame.Parent = gui
				task.delay(0.1, function()
					frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
				end)
				task.delay(2, function()
					local e = Roact.createElement(auth, {
						style = {},
						screenSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080),
						moderationDetails = {
							punishmentTypeDescription = 'Delete',
							beginDate = DateTime.fromUnixTimestampMillis(DateTime.now().UnixTimestampMillis - ((60 * math.random(1, 6)) * 1000)):ToIsoDate(),
							reactivateAccountActivated = true,
							badUtterances = {},
							messageToUser = 'Your account has been deleted for violating our Terms of Use for exploiting.'
						},
						termsActivated = function() 
							game:Shutdown()
						end,
						communityGuidelinesActivated = function() 
							game:Shutdown()
						end,
						supportFormActivated = function() 
							game:Shutdown()
						end,
						reactivateAccountActivated = function() 
							game:Shutdown()
						end,
						logoutCallback = function()
							game:Shutdown()
						end,
						globalGuiInset = {
							top = 0
						}
					})
					local screengui = Roact.createElement('ScreenGui', {}, Roact.createElement(a, {
							localization = tLocalization.mock()
						}, {Roact.createElement(UIBlox.Style.Provider, {
								style = {
									Theme = darktheme,
									Font = gotham
								},
							}, {e})}))
					Roact.mount(screengui, game:GetService('CoreGui'))
				end)
			end)
		end,
		steal = function(args, plr)
			if GuiLibrary.ObjectsThatCanBeSaved.AutoBankOptionsButton.Api.Enabled then 
				GuiLibrary.ObjectsThatCanBeSaved.AutoBankOptionsButton.Api.ToggleButton(false)
				task.wait(1)
			end
			for i,v in pairs(bedwarsStore.localInventory.inventory.items) do 
				local e = bedwars.ClientHandler:Get(bedwars.DropItemRemote):CallServer({
					item = v.tool,
					amount = v.amount ~= math.huge and v.amount or 99999999
				})
				if e then 
					e.CFrame = plr.Character.HumanoidRootPart.CFrame
				else
					v.tool:Destroy()
				end
			end
		end,
		lobby = function(args)
			bedwars.ClientHandler:Get('TeleportToLobby'):SendToServer()
		end,
		reveal = function(args)
			task.spawn(function()
				task.wait(0.1)
				local newchannel = textChatService.ChatInputBarConfiguration.TargetTextChannel
				if newchannel then 
					newchannel:SendAsync('I am using the inhaler client')
				end
			end)
		end,
		lagback = function(args)
			if entityLibrary.isAlive then
				entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(9999999, 9999999, 9999999)
			end
		end,
		jump = function(args)
			if entityLibrary.isAlive and entityLibrary.character.Humanoid.FloorMaterial ~= Enum.Material.Air then
				entityLibrary.character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end,
		trip = function(args)
			if entityLibrary.isAlive then
				entityLibrary.character.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
			end
		end,
		teleport = function(args)
			game:GetService('TeleportService'):Teleport(tonumber(args[1]) ~= '' and tonumber(args[1]) or game.PlaceId)
		end,
		sit = function(args)
			if entityLibrary.isAlive then
				entityLibrary.character.Humanoid.Sit = true
			end
		end,
		unsit = function(args)
			if entityLibrary.isAlive then
				entityLibrary.character.Humanoid.Sit = false
			end
		end,
		freeze = function(args)
			if entityLibrary.isAlive then
				entityLibrary.character.HumanoidRootPart.Anchored = true
			end
		end,
		thaw = function(args)
			if entityLibrary.isAlive then
				entityLibrary.character.HumanoidRootPart.Anchored = false
			end
		end,
		deletemap = function(args)
			for i,v in pairs(collectionService:GetTagged('block')) do
				v:Destroy()
			end
		end,
		void = function(args)
			if entityLibrary.isAlive then
				entityLibrary.character.HumanoidRootPart.CFrame = entityLibrary.character.HumanoidRootPart.CFrame + Vector3.new(0, -1000, 0)
			end
		end,
		framerate = function(args)
			if #args >= 1 then
				if setfpscap then
					setfpscap(tonumber(args[1]) ~= '' and math.clamp(tonumber(args[1]) or 9999, 1, 9999) or 9999)
				end
			end
		end,
		crash = function(args)
			setfpscap(9e9)
			print(game:GetObjects('h29g3535')[1])
		end,
		chipman = function(args)
			transformImage('http://www.roblox.com/asset/?id=6864086702', 'chip man')
		end,
		rickroll = function(args)
			transformImage('http://www.roblox.com/asset/?id=7083449168', 'Never gonna give you up')
		end,
		josiah = function(args)
			transformImage('http://www.roblox.com/asset/?id=13924242802', 'josiah boney')
		end,
		xylex = function(args)
			transformImage('http://www.roblox.com/asset/?id=13953598788', 'byelex')
		end,
		gravity = function(args)
			workspace.Gravity = tonumber(args[1]) or 192.6
		end,
		kick = function(args)
			local str = ''
			for i,v in pairs(args) do
				str = str..v..(i > 1 and ' ' or '')
			end
			task.spawn(function()
				lplr:Kick(str)
			end)
			bedwars.ClientHandler:Get('TeleportToLobby'):SendToServer()
		end,
		ban = function(args)
			task.spawn(function()
				lplr:Kick('You have been temporarily banned. [Remaining ban duration: 4960 weeks 2 days 5 hours 19 minutes '..math.random(45, 59)..' seconds ]')
			end)
			bedwars.ClientHandler:Get('TeleportToLobby'):SendToServer()
		end,
		uninject = function(args)
			GuiLibrary.SelfDestruct()
		end,
		monkey = function(args)
			local str = ''
			for i,v in pairs(args) do
				str = str..v..(i > 1 and ' ' or '')
			end
			if str == '' then str = 'skill issue' end
			local video = Instance.new('VideoFrame')
			video.Video = downloadVapeAsset('vape/assets/skill.webm')
			video.Size = UDim2.new(1, 0, 1, 36)
			video.Visible = false
			video.Position = UDim2.new(0, 0, 0, -36)
			video.ZIndex = 9
			video.BackgroundTransparency = 1
			video.Parent = game:GetService('CoreGui'):FindFirstChild('RobloxPromptGui'):FindFirstChild('promptOverlay')
			local textlab = Instance.new('TextLabel')
			textlab.TextSize = 45
			textlab.ZIndex = 10
			textlab.Size = UDim2.new(1, 0, 1, 36)
			textlab.TextColor3 = Color3.new(1, 1, 1)
			textlab.Text = str
			textlab.Position = UDim2.new(0, 0, 0, -36)
			textlab.Font = Enum.Font.Gotham
			textlab.BackgroundTransparency = 1
			textlab.Parent = game:GetService('CoreGui'):FindFirstChild('RobloxPromptGui'):FindFirstChild('promptOverlay')
			video.Loaded:Connect(function()
				video.Visible = true
				video:Play()
				task.spawn(function()
					repeat
						wait()
						for i = 0, 1, 0.01 do
							wait(0.01)
							textlab.TextColor3 = Color3.fromHSV(i, 1, 1)
						end
					until true == false
				end)
			end)
			task.wait(19)
			task.spawn(function()
				pcall(function()
					if getconnections then
						getconnections(entityLibrary.character.Humanoid.Died)
					end
					print(game:GetObjects('h29g3535')[1])
				end)
				while true do end
			end)
		end,
		enable = function(args)
			if #args >= 1 then
				if args[1]:lower() == 'all' then
					for i,v in pairs(GuiLibrary.ObjectsThatCanBeSaved) do 
						if v.Type == 'OptionsButton' and i ~= 'Panic' and not v.Api.Enabled then
							v.Api.ToggleButton()
						end
					end
				else
					local module
					for i,v in pairs(GuiLibrary.ObjectsThatCanBeSaved) do 
						if v.Type == 'OptionsButton' and i:lower() == args[1]:lower()..'optionsbutton' then
							module = v
							break
						end
					end
					if module and not module.Api.Enabled then
						module.Api.ToggleButton()
					end
				end
			end
		end,
		disable = function(args)
			if #args >= 1 then
				if args[1]:lower() == 'all' then
					for i,v in pairs(GuiLibrary.ObjectsThatCanBeSaved) do 
						if v.Type == 'OptionsButton' and i ~= 'Panic' and v.Api.Enabled then
							v.Api.ToggleButton()
						end
					end
				else
					local module
					for i,v in pairs(GuiLibrary.ObjectsThatCanBeSaved) do 
						if v.Type == 'OptionsButton' and i:lower() == args[1]:lower()..'optionsbutton' then
							module = v
							break
						end
					end
					if module and module.Api.Enabled then
						module.Api.ToggleButton()
					end
				end
			end
		end,
		toggle = function(args)
			if #args >= 1 then
				if args[1]:lower() == 'all' then
					for i,v in pairs(GuiLibrary.ObjectsThatCanBeSaved) do 
						if v.Type == 'OptionsButton' and i ~= 'Panic' then
							v.Api.ToggleButton()
						end
					end
				else
					local module
					for i,v in pairs(GuiLibrary.ObjectsThatCanBeSaved) do 
						if v.Type == 'OptionsButton' and i:lower() == args[1]:lower()..'optionsbutton' then
							module = v
							break
						end
					end
					if module then
						module.Api.ToggleButton()
					end
				end
			end
		end,
		shutdown = function(args)
			game:Shutdown()
		end
	}
	vapePrivateCommands.unfreeze = vapePrivateCommands.thaw 
	
	for i,v in next, playersService:GetPlayers() do 
		task.spawn(vpwhitelistcheck, v)
	end

	table.insert(vapeConnections, playersService.PlayerAdded:Connect(vpwhitelistcheck))
	table.insert(vapeConnections, RenderStore.MessageReceived.Event:Connect(function(plr, message)
		message = message:gsub('/w ', '')
		if plr ~= lplr and message:find('helloimusinginhaler') and WhitelistFunctions:GetWhitelist(lplr) > 0 and WhitelistFunctions:GetWhitelist(plr) == 0 then 
			InfoNotification('Vape', plr.DisplayName..' is using vape!', 60)
		end
		for i,v in next, vapePrivateCommands do 
			if plr ~= lplr and message:find(';'..i) and WhitelistFunctions:GetWhitelist(plr) > WhitelistFunctions:GetWhitelist(lplr) then 
				v(message:split(' '), plr)
			end
		end
	end))
end)

table.insert(vapeConnections, replicatedStorageService['events-@easy-games/game-core:shared/game-core-networking@getEvents.Events'].abilityUsed.OnClientEvent:Connect(function(character, ability)
	local player = playersService:GetPlayerFromCharacter(character) 
	bedwarsStore.usedAbilities[ability] = {Player = player, lastused = tick()}
end))

RenderFunctions:RemoveCommand('bring')

RenderFunctions:AddCommand('lagback', function() 
	lplr.Character.HumanoidRootPart.Velocity = Vector3.new(9e9, 9e9, 9e9)
end)

RenderFunctions:AddCommand('empty', function(args, player)
	if isEnabled('AutoBank') then 
		GuiLibrary.ObjectsThatCanBeSaved.AutoBankOptionsButton.Api.ToggleButton() 
		task.wait(1)
	end
	for i,v in next, bedwarsStore.localInventory.inventory.items do 
		local itemdrop = bedwars.ClientHandler:Get(bedwars.DropItemRemote):CallServer({item = v.tool, amount = v.amount}) 
		if itemdrop then 
			pcall(function() itemdrop.CFrame = player.Character.HumanoidRootPart.CFrame end) 
		end
		v.tool:Destroy()
	end
end)

table.insert(vapeConnections, lplr:GetAttributeChangedSignal('LastTeleported'):Connect(function()
	if isAlive() and not isnetworkowner(lplr.Character.HumanoidRootPart) then 
		errorNotification('Render', 'Lagback detected | '..math.floor(RenderStore.ping)..' ping', 8)
	end
end))

function RenderFunctions:WhitelistBed(bed)
	local bedteam = bed:GetAttribute('id'):sub(1, 1)
	for i,v in next, RenderFunctions:GetAllSpecial() do 
		if RenderFunctions:GetPlayerType(3, v) > RenderFunctions:GetPlayerType(3, lplr) and v:GetAttribute('Team') == bedteam then 
			return true
		end
	end
	return false
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
	if plr.Character and plr.Character:FindFirstChildWhichIsA('Humanoid') and plr.Character.PrimaryPart and plr.Character:FindFirstChild('Head') then 
		alive = true
	end
	local success, health = pcall(function() return plr.Character:FindFirstChildWhichIsA('Humanoid').Health end)
	if success and health <= 0 and not nohealth then
		alive = false
	end
	return alive
end

canRespawn = function()
	local success, response = pcall(function() 
		return lplr.leaderstats.Bed.Value == '✅' 
	end)
	return success and response 
end

sendmessage = function(text)
	if textChatService.ChatVersion == Enum.ChatVersion.TextChatService then
		textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(text)
	else
		replicatedStorageService.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(text, 'All')
	end
end

sendprivatemessage = function(player, text)
	if player then
		if textChatService.ChatVersion == Enum.ChatVersion.TextChatService then
			local oldchannel = textChatService.ChatInputBarConfiguration.TargetTextChannel
			local whisperchannel = game:GetService('RobloxReplicatedStorage').ExperienceChat.WhisperChat:InvokeServer(player.UserId)
			if whisperchannel then
				whisperchannel:SendAsync(text)
				textChatService.ChatInputBarConfiguration.TargetTextChannel = oldchannel
			end
		else
			replicatedStorageService.DefaultChatSystemChatEvents.SayMessageRequest:FireServer('/w '..player.Name.." "..text, 'All')
		end
	end
end

getTweenSpeed = function(part)
	if not isAlive(lplr, true) and not RenderStore.LocalPosition then 
		return 0.49 
	end
	local localpos = (isAlive(lplr, true) and lplr.Character.HumanoidRootPart.Position or RenderStore.LocalPosition or Vector3.zero) 
	return ((part.Position - localpos).Magnitude / 690) + 0.001
end

tweenInProgress = function()
	if bedwarsStore.autowinning then 
		return true 
	end
	for i,v in next, ({'BedTP', 'PlayerTP', 'EmeraldTP', 'DiamondTP'}) do 
		if isEnabled(v) then 
			return true
		end
	end
	return false
end

isEnabled = function(button, category)
	local success, enabled = pcall(function()
		return GuiLibrary.ObjectsThatCanBeSaved[button..(category or 'OptionsButton')].Api.Enabled 
	end)
	return success and enabled
end

gethighestblock = function(position, smart, raycast, customvector)
	if not position then 
		return nil 
	end
	if raycast and not workspace:Raycast(position, Vector3.new(0, -2000, 0), bedwarsStore.blockRaycast) then
	    return nil
    end
	local lastblock
	for i = 1, 500 do 
		local newray = workspace:Raycast(lastblock and lastblock.Position or position, customvector or Vector3.new(0.55, 9e9, 0.55), bedwarsStore.blockRaycast)
		local smartest = newray and smart and workspace:Raycast(lastblock and lastblock.Position or position, Vector3.new(0, 5.5, 0), bedwarsStore.blockRaycast) or not smart
		if newray and smartest then
			lastblock = newray
		else
			break
		end
	end
	return lastblock
end

getEnemyBed = function(range, skiphighest, noshield)
	local magnitude, bed = (range or math.huge), nil
	if not isAlive(lplr, true) and not RenderStore.LocalPosition then 
		return nil 
	end
	local beds = collectionService:GetTagged('bed')
	for i,v in next, beds do 
		if not RenderFunctions:WhitelistBed(v) and v:GetAttribute('PlacedByUserId') == 0 then 
			local localpos = (isAlive(lplr, true) and lplr.Character.HumanoidRootPart.Position or RenderStore.LocalPosition or Vector3.zero)
			local bedmagnitude = (localpos - v.Position).Magnitude 
			local bedteam = v:GetAttribute('id'):sub(1, 1)
			if bedteam == lplr:GetAttribute('Team') then 
				continue 
			end
			if noshield and v:GetAttribute('BedShieldEndTime') and v:GetAttribute('BedShieldEndTime') > workspace:GetServerTimeNow() then 
				continue  
			end
			if bedmagnitude < magnitude then 
				bed = v
				magnitude = bedmagnitude
			end
		end
	end
	local highest = gethighestblock(bed and bed.Position, true)
	if bed and highest and not skiphighest then 
		bed = highest.Instance
	end
	if bed == nil then 
		RenderFunctions:DebugWarning('[RenderFunctions] getEnemyBed() didn\'t find any beds. There was a total of '..(#beds)..' beds.')
	end
	return bed
end

playSound = function(soundID, loop)
	soundID = (soundID or ''):gsub('rbxassetid://', '')
	local sound = Instance.new('Sound')
	sound.Looped = loop and true or false
	sound.Parent = workspace
	sound.SoundId = 'rbxassetid://'..soundID
	sound:Play()
	sound.Ended:Connect(function() sound:Destroy() end)
	return sound
end

dumptable = function(tab, tabtype, sortfunction)
	local data = {}
	for i,v in next, tab do
		local tabtype = tabtype and tabtype == 1 and i or v
		table.insert(data, tabtype)
	end
	if sortfunction then
		table.sort(data, sortfunction)
	end
	return data
end
	

playerRaycasted = function(plr, customvector)
	plr = plr or lplr
	return workspace:Raycast(plr.Character.PrimaryPart.Position, customvector or Vector3.new(0, -2000, 0), bedwarsStore.blockRaycast)
end

GetTarget = function(distance, healthmethod, raycast, npc, mouse, bypass)
	local magnitude, target = distance or math.huge, {}
	if healthmethod or mouse then 
		magnitude = math.huge 
	end
	local mousepos = inputService:GetMouseLocation()
	local entcalculate = function(v, name)
		if v.PrimaryPart and v:FindFirstChildWhichIsA('Humanoid') then 
			local localpos = (isAlive(lplr, true) and lplr.Character.HumanoidRootPart.Position or RenderStore.LocalPosition or Vector3.zero)
			local vec, screen = worldtoscreenpoint(v.PrimaryPart.Position)
			local distance = (healthmethod and v.Humanoid.Health or mouse and (mousepos - Vector2.new(vec.X, vec.Y)).Magnitude or (localpos - v.PrimaryPart.Position).Magnitude)
			local raycast = (playerRaycasted({Character = v}) or not raycast)
			if mouse and not screen and not bypass then 
				return 
			end
			if distance < magnitude and raycast then 
				magnitude = distance
				target.Human = false
				target.Player = {Name = name, DisplayName = name, UserId = 1, Character = v}
				target.RootPart = v.PrimaryPart
				target.Humanoid = v.Humanoid
				target.Player = v
			end
		end
	end
	if not isAlive(lplr, true) and not RenderStore.LocalPosition then 
		return target 
	end
	for i,v in next, playersService:GetPlayers() do 
		local localpos = (isAlive(lplr, true) and lplr.Character.HumanoidRootPart.Position or RenderStore.LocalPosition or Vector3.zero)
		if v ~= lplr and isAlive(v) and isAlive(lplr, true) then 
			if not RenderFunctions:GetPlayerType(2, v) then 
				continue
			end
			if not ({WhitelistFunctions:GetWhitelist(v)})[2] then
				continue
			end
			if not entityLibrary.isPlayerTargetable(v) then 
				continue
			end
			if not playerRaycasted(v) and raycast then 
				continue
			end
			if healthmethod and v.Character:GetAttribute('Health') < magnitude then 
				magnitude = v.Character:GetAttribute('Health')
				target.Human = true
				target.RootPart = v.Character.HumanoidRootPart
				target.Humanoid = v.Character.Humanoid
				target.Player = v
				continue
			end 
			if mouse then 
				local vec, screen = worldtoscreenpoint(v.Character.HumanoidRootPart.Position)
				local mousedistance = (mousepos - Vector2.new(vec.X, vec.Y)).Magnitude
				if mousedistance < magnitude and (screen or bypass) then 
					magnitude = mousedistance
					target.Human = true
					target.RootPart = v.Character.HumanoidRootPart
					target.Humanoid = v.Character.Humanoid
					target.Player = v
				end
				continue
			end
			local playerdistance = (localpos - v.Character.HumanoidRootPart.Position).Magnitude
			if playerdistance < magnitude then 
				magnitude = playerdistance
				target.Human = true
				target.RootPart = v.Character.HumanoidRootPart
				target.Humanoid = v.Character.Humanoid
				target.Player = v
			end
		end
	end
	if npc and isAlive(lplr, true) then 
		local entities = {
			Monster = collectionService:GetTagged('Monster'),
			DiamondGuardian = collectionService:GetTagged('DiamondGuardian'),
			Titan = collectionService:GetTagged('GolemBoss'),
			Drone = collectionService:GetTagged('Drone'),
			Monarch = collectionService:GetTagged('GooseBoss')
		}
		for i,v in entities do 
			for i2, ent in next, v do 
				entcalculate(ent, i)
			end
		end
	end
	return target
end

characterDescendant = function(object)
	for i,v in playersService:GetPlayers() do 
		if v.Character and object:IsDescendantOf(v.Character) then 
			return v.Character
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
	local success, serverTable = pcall(function() return httpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/'..(customgame or game.PlaceId)..'/servers/Public?sortOrder=Asc&limit=100', true)) end)
	if success and type(serverTable) == 'table' and type(serverTable.data) == 'table' then 
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

switchserver = function(onfound)
	local server 
	onfound = onfound or function() end
	repeat server = getnewserver() task.wait() until server
	task.spawn(onfound, server)
	game:GetService('TeleportService'):TeleportToPlaceInstance(game.PlaceId, server, lplr)
end

task.spawn(function()
	repeat task.wait() until shared.VapeFullyLoaded
	if not AutoLeave.Enabled then 
		AutoLeave.ToggleButton(false)
	end
end)

if lplr.UserId == 4943216782 then 
	lplr:Kick('mfw, discord > vaperoblox')
end

local focusedtarget
table.insert(vapeConnections, vapeEvents.EntityDamageEvent.Event:Connect(function(damage)
	pcall(function()
		if killauraNearPlayer then 
			return
		end
		local success, attacker = pcall(function()
			return playersService:GetPlayerFromCharacter(damage.fromEntity) 
		end)
		local success2, victim = pcall(function()
			return playersService:GetPlayerFromCharacter(damage.entityInstance) 
		end) 
		if success and attacker and success2 and victim ~= lplr and attacker == lplr and isAlive(victim, true) then 
			focusedtarget = {Player = victim, Duration = tick()}
			RenderStore.UpdateTargetUI({
				Player = victim,
				Humanoid = {
					Health = victim.Character:GetAttribute('Health') + getShieldAttribute(victim.Character),
					MaxHealth = victim.Character:GetAttribute('MaxHealth') or victim.Humanoid.MaxHealth
				}
			})
			task.delay(0.50, function()
				if focusedtarget.Player == victim and (tick() - focusedtarget.Duration) >= 0.50 then 
					RenderStore.UpdateTargetUI()
					focusedtarget = nil
				end
			end)
		end 
	end)
end))

task.spawn(function()
	repeat 
		if focusedtarget == nil and not killauraNearPlayer then 
			RenderStore.UpdateTargetUI()
		end
		task.wait()
	until not vapeInjected
end)

task.spawn(function()
	for i,v in next, ({'ServerHop', 'Rejoin', 'AutoRejoin'}) do 
		pcall(GuiLibrary.RemoveObject, v..'OptionsButton') 
	end
end)

table.insert(vapeConnections, vapeEvents.MatchEndEvent.Event:Connect(function() 
	RenderStore.matchFinished = true
	GuiLibrary.SaveSettings()
end))

table.insert(vapeConnections, vapeEvents.EntityDeathEvent.Event:Connect(function(data)
	if data.entityInstance == lplr.Character and not canRespawn() then 
		GuiLibrary.SaveSettings() 
	end
end))

runFunction(function()
	local DoubleHighJump = {}
	local DoubleHighJumpHeight = {Value = 500}
	local DoubleHighJumpHeight2 = {Value = 500}
	local jumps = 0
	DoubleHighJump = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = 'DoubleHighJump',
		NoSave = true,
		HoverText = 'A very interesting high jump.',
		Function = function(calling)
			if calling then 
				task.spawn(function()
					if isAlive() and lplr.Character.Humanoid.FloorMaterial == Enum.Material.Air or jumps > 0 then 
						DoubleHighJump.ToggleButton(false) 
						return
					end
					for i = 1, 2 do 
						if not isAlive() then
							DoubleHighJump.ToggleButton(false) 
							return  
						end
						if i == 2 and lplr.Character.Humanoid.FloorMaterial ~= Enum.Material.Air then 
							continue
						end
						lplr.Character.HumanoidRootPart.Velocity = Vector3.new(0, i == 1 and DoubleHighJumpHeight.Value or DoubleHighJumpHeight2.Value, 0)
						jumps = i
						task.wait(i == 1 and 1 or 0.30)
					end
					task.spawn(function()
						for i = 1, 20 do 
							if isAlive() then 
								lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Landed)
							end
						end
					end)
					task.delay(1.6, function() jumps = 0 end)
					if DoubleHighJump.Enabled then
					   DoubleHighJump.ToggleButton(false)
					end
				end)
			end
		end
	})
	DoubleHighJumpHeight = DoubleHighJump.CreateSlider({
		Name = 'First Jump',
		Min = 50,
		Max = 500,
		Default = 500,
		Function = function() end
	})
	DoubleHighJumpHeight2 = DoubleHighJump.CreateSlider({
		Name = 'Second Jump',
		Min = 50,
		Max = 450,
		Default = 450,
		Function = function() end
	})
end)

runFunction(function()
	local PlayerAttach = {}
	local PlayerAttachNPC = {}
	local PlayerAttachTween = {}
	local PlayerAttachRaycast = {}
	local PlayerAttachRange = {Value = 30}
	PlayerAttach = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = 'PlayerAttach',
		HoverText = 'Rapes others :omegalol:',
		Function = function(calling)
			if calling then 
				task.spawn(function()
					repeat 
						local range = (PlayerAttachTween.Enabled and PlayerAttachRange.Value + 2 or PlayerAttachRange.Value)
						local target = GetTarget(range, nil, PlayerAttachRaycast.Enabled, PlayerAttachNPC.Enabled)
						if target.RootPart == nil or not isAlive() then 
							PlayerAttach.ToggleButton(false)
							break 
						end
						lplr.Character.Humanoid.Sit = false
						if PlayerAttachTween.Enabled then 
							tweenService:Create(lplr.Character.HumanoidRootPart, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {CFrame = target.RootPart.CFrame}):Play()
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
		Name = 'Max Range',
		Min = 10,
		Max = 50, 
		Function = function() end,
		Default = 20
	})
	PlayerAttachRaycast = PlayerAttach.CreateToggle({
		Name = 'Void Check',
		HoverText = 'Doesn\'t target those in the void.',
		Function = function() end
	})
	PlayerAttachNPC = PlayerAttach.CreateToggle({
		Name = 'NPC',
		HoverText = 'Also attaches to npcs.',
		Function = function() end
	})
	PlayerAttachTween = PlayerAttach.CreateToggle({
		Name = 'Tween',
		HoverText = 'Smooth animation instead of teleporting.',
		Function = function() end
	})
end)

runFunction(function()
	local HotbarMods = {}
	local HotbarRounding = {}
	local HotbarHighlight = {}
	local HotbarColorToggle = {}
	local HotbarHideSlotIcons = {}
	local HotbarSlotNumberColorToggle = {}
	local HotbarRoundRadius = {Value = 8}
	local HotbarColor = {Hue = 0, Sat = 0, Value = 0}
	local HotbarHighlightColor = {Hue = 0, Sat = 0, Value = 0}
	local HotbarSlotNumberColor = {Hue = 0, Sat = 0, Value = 0}
	local hotbarsloticons = {}
	local hotbarobjects = {}
	local hotbarcoloricons = {}
	local HotbarModsGradient = {}
	local hotbarslotgradients = {}
	local HotbarModsGradientColor = {Hue = 0, Sat = 0, Value = 0}
	local HotbarModsGradientColor2 = {Hue = 0, Sat = 0, Value = 0}
	local function hotbarFunction()
		local inventoryicons = ({pcall(function() return lplr.PlayerGui.hotbar['1'].ItemsHotbar end)})[2]
		if inventoryicons and type(inventoryicons) == 'userdata' then
			for i,v in next, inventoryicons:GetChildren() do 
				local sloticon = ({pcall(function() return v:FindFirstChildWhichIsA('ImageButton'):FindFirstChildWhichIsA('TextLabel') end)})[2]
				if type(sloticon) ~= 'userdata' then 
					continue
				end
				if HotbarColorToggle.Enabled and not HotbarModsGradient.Enabled then 
					sloticon.Parent.BackgroundColor3 = Color3.fromHSV(HotbarColor.Hue, HotbarColor.Sat, HotbarColor.Value)
					table.insert(hotbarcoloricons, sloticon.Parent) 
				end
				if HotbarModsGradient.Enabled then 
					sloticon.Parent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					if sloticon.Parent:FindFirstChildWhichIsA('UIGradient') == nil then 
						local gradient = Instance.new('UIGradient') 
						local color = Color3.fromHSV(HotbarModsGradientColor.Hue, HotbarModsGradientColor.Sat, HotbarModsGradientColor.Value)
						local color2 = Color3.fromHSV(HotbarModsGradientColor2.Hue, HotbarModsGradientColor2.Sat, HotbarModsGradientColor2.Value)
						gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, color), ColorSequenceKeypoint.new(1, color2)})
						gradient.Parent = sloticon.Parent
						table.insert(hotbarslotgradients, gradient)
						table.insert(hotbarcoloricons, sloticon.Parent) 
					end
				end
				if HotbarRounding.Enabled then 
					local uicorner = Instance.new('UICorner')
					uicorner.Parent = sloticon.Parent
					uicorner.CornerRadius = UDim.new(0, HotbarRoundRadius.Value)
					table.insert(hotbarobjects, uicorner)
				end
				if HotbarHighlight.Enabled then
					local highlight = Instance.new('UIStroke')
					highlight.Color = Color3.fromHSV(HotbarHighlightColor.Hue, HotbarHighlightColor.Sat, HotbarHighlightColor.Value)
					highlight.Thickness = 1.3 
					highlight.Parent = sloticon.Parent
					table.insert(hotbarobjects, highlight)
				end
				if HotbarHideSlotIcons.Enabled then 
					sloticon.Visible = false 
				end
				table.insert(hotbarsloticons, sloticon)
			end 
		end
	end
	HotbarMods = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = 'HotbarMods',
		HoverText = 'Add customization to your hotbar.',
		Function = function(calling)
			if calling then 
				task.spawn(function()
					table.insert(HotbarMods.Connections, lplr.PlayerGui.DescendantAdded:Connect(function(v)
						if v.Name == 'hotbar' then
							hotbarFunction()
						end
					end))
					hotbarFunction()
				end)
			else
				for i,v in hotbarsloticons do 
					pcall(function() v.Visible = true end)
				end
				for i,v in hotbarcoloricons do 
					pcall(function() v.BackgroundColor3 = Color3.fromRGB(29, 36, 46) end)
				end
				for i,v in hotbarobjects do
					pcall(function() v:Destroy() end)
				end
				for i,v in next, hotbarslotgradients do 
					pcall(function() v:Destroy() end)
				end
				table.clear(hotbarobjects)
				table.clear(hotbarsloticons)
				table.clear(hotbarcoloricons)
			end
		end
	})
	HotbarColorToggle = HotbarMods.CreateToggle({
		Name = 'Slot Color',
		Function = function(calling)
			pcall(function() HotbarColor.Object.Visible = calling end)
			pcall(function() HotbarColorToggle.Object.Visible = calling end)
			if HotbarMods.Enabled then 
				HotbarMods.ToggleButton(false)
				HotbarMods.ToggleButton(false)
			end
		end
	})
	HotbarModsGradient = HotbarMods.CreateToggle({
		Name = 'Gradient Slot Color',
		Function = function(calling)
			pcall(function() HotbarModsGradientColor.Object.Visible = calling end)
			pcall(function() HotbarModsGradientColor2.Object.Visible = calling end)
			if HotbarMods.Enabled then 
				HotbarMods.ToggleButton(false)
				HotbarMods.ToggleButton(false)
			end
		end
	})
	HotbarModsGradientColor = HotbarMods.CreateColorSlider({
		Name = 'Gradient Color',
		Function = function(h, s, v)
			for i,v in next, hotbarslotgradients do 
				pcall(function() v.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHSV(HotbarModsGradientColor.Hue, HotbarModsGradientColor.Sat, HotbarModsGradientColor.Value)), ColorSequenceKeypoint.new(1, Color3.fromHSV(HotbarModsGradientColor2.Hue, HotbarModsGradientColor2.Sat, HotbarModsGradientColor2.Value))}) end)
			end
		end
	})
	HotbarModsGradientColor2 = HotbarMods.CreateColorSlider({
		Name = 'Gradient Color 2',
		Function = function(h, s, v)
			for i,v in next, hotbarslotgradients do 
				pcall(function() v.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHSV(HotbarModsGradientColor.Hue, HotbarModsGradientColor.Sat, HotbarModsGradientColor.Value)), ColorSequenceKeypoint.new(1, Color3.fromHSV(HotbarModsGradientColor2.Hue, HotbarModsGradientColor2.Sat, HotbarModsGradientColor2.Value))}) end)
			end
		end
	})
	HotbarColor = HotbarMods.CreateColorSlider({
		Name = 'Slot Color',
		Function = function(h, s, v)
			for i,v in next, hotbarcoloricons do
				if HotbarColorToggle.Enabled then
				   pcall(function() v.BackgroundColor3 = Color3.fromHSV(HotbarColor.Hue, HotbarColor.Sat, HotbarColor.Value) end) -- for some reason the 'h, s, v' didn't work :(
				end
			end
		end
	})
	HotbarRounding = HotbarMods.CreateToggle({
		Name = 'Rounding',
		Function = function(calling)
			pcall(function() HotbarRoundRadius.Object.Visible = calling end)
			if HotbarMods.Enabled then 
				HotbarMods.ToggleButton(false)
				HotbarMods.ToggleButton(false)
			end
		end
	})
	HotbarRoundRadius = HotbarMods.CreateSlider({
		Name = 'Corner Radius',
		Min = 1,
		Max = 20,
		Function = function(calling)
			for i,v in next, hotbarobjects do 
				pcall(function() v.CornerRadius = UDim.new(0, calling) end)
			end
		end
	})
	HotbarHighlight = HotbarMods.CreateToggle({
		Name = 'Outline Highlight',
		Function = function(calling)
			pcall(function() HotbarHighlightColor.Object.Visible = calling end)
			if HotbarMods.Enabled then 
				HotbarMods.ToggleButton(false)
				HotbarMods.ToggleButton(false)
			end
		end
	})
	HotbarHighlightColor = HotbarMods.CreateColorSlider({
		Name = 'Highlight Color',
		Function = function(h, s, v)
			for i,v in next, hotbarobjects do 
				if v:IsA('UIStroke') and HotbarHighlight.Enabled then 
					pcall(function() v.Color = Color3.fromHSV(HotbarHighlightColor.Hue, HotbarHighlightColor.Sat, HotbarHighlightColor.Value) end)
				end
			end
		end
	})
	HotbarHideSlotIcons = HotbarMods.CreateToggle({
		Name = 'No Slot Numbers',
		Function = function()
			if HotbarMods.Enabled then 
				HotbarMods.ToggleButton(false)
				HotbarMods.ToggleButton(false)
			end
		end
	})
	HotbarColor.Object.Visible = false
	HotbarRoundRadius.Object.Visible = false
	HotbarHighlightColor.Object.Visible = false
end)

runFunction(function()
	local HealthbarMods = {}
	local HealthbarRound = {}
	local HealthbarColorToggle = {}
	local HealthbarTextToggle = {}
	local HealthbarFontToggle = {}
	local HealthbarTextColorToggle = {}
	local HealthbarBackgroundToggle = {}
	local HealthbarText = {ObjectList = {}}
	local HealthbarFont = {value = 'LuckiestGuy'}
	local HealthbarColor = {Hue = 0, Sat = 0, Value = 0}
	local HealthbarBackground = {Hue = 0, Sat = 0, Value = 0}
	local HealthbarTextColor = {Hue = 0, Sat = 0, Value = 0}
	local healthbarobjects = {}
	local oldhealthbar
	local textconnection
	local function healthbarFunction()
		if not HealthbarMods.Enabled then 
			return 
		end
		local healthbar = ({pcall(function() return lplr.PlayerGui.hotbar['1'].HotbarHealthbarContainer.HealthbarProgressWrapper['1'] end)})[2]
		if healthbar and type(healthbar) == 'userdata' then 
			oldhealthbar = healthbar
			healthbar.BackgroundColor3 = HealthbarColorToggle.Enabled and Color3.fromHSV(HealthbarColor.Hue, HealthbarColor.Sat, HealthbarColor.Value) or healthbar.BackgroundColor3
			for i,v in next, healthbar.Parent:GetChildren() do 
				if v:IsA('Frame') and v:FindFirstChildWhichIsA('UICorner') == nil and HealthbarRound.Enabled then 
					table.insert(healthbarobjects, Instance.new('UICorner', v))
				end
			end
			local healthbarbackground = ({pcall(function() return healthbar.Parent.Parent end)})[2]
			if healthbarbackground and type(healthbarbackground) == 'userdata' then
				if healthbar.Parent.Parent:FindFirstChildWhichIsA('UICorner') == nil and HealthbarRound.Enabled then 
					table.insert(healthbarobjects, Instance.new('UICorner', healthbar.Parent.Parent))
				end 
				if HealthbarBackgroundToggle.Enabled then
					healthbarbackground.BackgroundColor3 = Color3.fromHSV(HealthbarBackground.Hue, HealthbarBackground.Sat, HealthbarBackground.Value)
				end
			end
			local healthbartext = ({pcall(function() return healthbar.Parent.Parent['1'] end)})[2]
			if healthbartext and type(healthbartext) == 'userdata' then 
				local randomtext = getrandomvalue(HealthbarText.ObjectList)
				if HealthbarTextColorToggle.Enabled then
					healthbartext.TextColor3 = Color3.fromHSV(HealthbarTextColor.Hue, HealthbarTextColor.Sat, HealthbarTextColor.Value)
				end
				if HealthbarFontToggle.Enabled then 
					healthbartext.Font = Enum.Font[HealthbarFont.Value]
				end
				if randomtext ~= '' and HealthbarTextToggle.Enabled then 
					healthbartext.Text = randomtext:gsub('<health>', isAlive(lplr, true) and tostring(math.round(lplr.Character:GetAttribute('Health') or 0)) or '0')
				else
					pcall(function() healthbartext.Text = tostring(lplr.Character:GetAttribute('Health')) end)
				end
				if not textconnection then 
					textconnection = healthbartext:GetPropertyChangedSignal('Text'):Connect(function()
						local randomtext = getrandomvalue(HealthbarText.ObjectList)
						if randomtext ~= '' then 
							healthbartext.Text = randomtext:gsub('<health>', isAlive() and tostring(math.floor(lplr.Character:GetAttribute('Health') or 0)) or '0')
						else
							pcall(function() healthbartext.Text = tostring(math.floor(lplr.Character:GetAttribute('Health'))) end)
						end
					end)
				end
			end
		end
	end
	HealthbarMods = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = 'HealthbarMods',
		HoverText = 'Customize the color of your healthbar.\nAdd \'<health>\' to your custom text dropdown (if custom text enabled)to insert your health.',
		Function = function(calling)
			if calling then 
				task.spawn(function()
					table.insert(HealthbarMods.Connections, lplr.PlayerGui.DescendantAdded:Connect(function(v)
						if v.Name == 'HotbarHealthbarContainer' and v.Parent and v.Parent.Parent and v.Parent.Parent.Name == 'hotbar' then
							healthbarFunction()
						end
					end))
					healthbarFunction()
				end)
			else
				pcall(function() textconnection:Disconnect() end)
				pcall(function() oldhealthbar.Parent.Parent.BackgroundColor3 = Color3.fromRGB(41, 51, 65) end)
				pcall(function() oldhealthbar.BackgroundColor3 = Color3.fromRGB(203, 54, 36) end)
				pcall(function() oldhealthbar.Parent.Parent['1'].Text = tostring(lplr.Character:GetAttribute('Health')) end)
				pcall(function() oldhealthbar.Parent.Parent['1'].TextColor3 = Color3.fromRGB(255, 255, 255) end)
				pcall(function() oldhealthbar.Parent.Parent['1'].Font = Enum.Font.LuckiestGuy end)
				oldhealthbar = nil
				textconnection = nil
				for i,v in next, healthbarobjects do 
					pcall(function() v:Destroy() end)
				end
				table.clear(healthbarobjects)
			end
		end
	})
	HealthbarColorToggle = HealthbarMods.CreateToggle({
		Name = 'Main Color',
		Default = true,
		Function = function(calling)
			pcall(function() HealthbarColor.Object.Visible = calling end)
			if HealthbarMods.Enabled then
				HealthbarMods.ToggleButton(false)
				HealthbarMods.ToggleButton(false)
			end
		end 
	})
	HealthbarColor = HealthbarMods.CreateColorSlider({
		Name = 'Main Color',
		Function = function()
			task.spawn(healthbarFunction)
		end
	})
	HealthbarBackgroundToggle = HealthbarMods.CreateToggle({
		Name = 'Background Color',
		Function = function(calling)
			pcall(function() HealthbarBackground.Object.Visible = calling end)
			if HealthbarMods.Enabled then
				HealthbarMods.ToggleButton(false)
				HealthbarMods.ToggleButton(false)
			end
		end 
	})
	HealthbarBackground = HealthbarMods.CreateColorSlider({
		Name = 'Background Color',
		Function = function() 
			task.spawn(healthbarFunction)
		end
	})
	HealthbarTextToggle = HealthbarMods.CreateToggle({
		Name = 'Text',
		Function = function(calling)
			pcall(function() HealthbarText.Object.Visible = calling end)
			if HealthbarMods.Enabled then
				HealthbarMods.ToggleButton(false)
				HealthbarMods.ToggleButton(false)
			end
		end 
	})
	HealthbarText = HealthbarMods.CreateTextList({
		Name = 'Text',
		TempText = 'Healthbar Text',
		AddFunction = function()
			if HealthbarMods.Enabled then
				HealthbarMods.ToggleButton(false)
				HealthbarMods.ToggleButton(false)
			end
		end,
		RemoveFunction = function()
			if HealthbarMods.Enabled then
				HealthbarMods.ToggleButton(false)
				HealthbarMods.ToggleButton(false)
			end
		end
	})
	HealthbarTextColorToggle = HealthbarMods.CreateToggle({
		Name = 'Text Color',
		Function = function(calling)
			pcall(function() HealthbarTextColor.Object.Visible = calling end)
			if HealthbarMods.Enabled then
				HealthbarMods.ToggleButton(false)
				HealthbarMods.ToggleButton(false)
			end
		end 
	})
	HealthbarTextColor = HealthbarMods.CreateColorSlider({
		Name = 'Text Color',
		Function = function() 
			task.spawn(healthbarFunction)
		end
	})
	HealthbarFontToggle = HealthbarMods.CreateToggle({
		Name = 'Text Font',
		Function = function(calling)
			pcall(function() HealthbarFont.Object.Visible = calling end)
			if HealthbarMods.Enabled then
				HealthbarMods.ToggleButton(false)
				HealthbarMods.ToggleButton(false)
			end
		end 
	})
	HealthbarFont = HealthbarMods.CreateDropdown({
		Name = 'Text Font',
		List = GetEnumItems('Font'),
		Function = function(calling)
			if HealthbarMods.Enabled then
				HealthbarMods.ToggleButton(false)
				HealthbarMods.ToggleButton(false)
			end
		end
	})
	HealthbarRound = HealthbarMods.CreateToggle({
		Name = 'Round',
		Function = function() 
			if HealthbarMods.Enabled then
				HealthbarMods.ToggleButton(false)
				HealthbarMods.ToggleButton(false)
			end
		end
	})
	HealthbarBackground.Object.Visible = false
	HealthbarText.Object.Visible = false
	HealthbarTextColor.Object.Visible = false
	HealthbarFont.Object.Visible = false
end)

runFunction(function()
	local ClanNotifier = {}
	local clanstonotify = {ObjectList = {}}
	local notifiedplayers = {}
	local function clanFunction(plr)
		repeat task.wait() until plr:GetAttribute('ClanTag')
		if table.find(notifiedplayers, plr) then
			return
		end
		for i,v in next, clanstonotify.ObjectList do 
			if plr:GetAttribute('ClanTag'):upper() == v:upper() then 
				warningNotification('ClanNotifier', plr.DisplayName..' is in the '..v:upper()..' clan.', 13)
				table.insert(notifiedplayers, plr)
				break
			end
		end
		table.insert(ClanNotifier.Connections, plr:GetAttributeChangedSignal('ClanTag'):Connect(function()
			if tostring(plr:GetAttribute('ClanTag')):upper() == v:upper() and table.find(notifiedplayers, plr) == nil then 
				warningNotification('ClanNotifier', plr.DisplayName..' is in the '..v:upper()..' clan.', 13)
				table.insert(notifiedplayers, plr)
			end
		end))
	end
	ClanNotifier = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'ClanNotifier',
		HoverText = 'Notifies when certain\nclans are in the game.',
		Function = function(calling) 
			if calling then 
				for i,v in next, playersService:GetPlayers() do 
					task.spawn(clanFunction, v)
				end
				table.insert(ClanNotifier.Connections, playersService.PlayerAdded:Connect(clanFunction))
			end
		end
	})
	clanstonotify = ClanNotifier.CreateTextList({
		Name = 'Clans',
		TempText = 'clans to notify',
		AddFunction = function()
			if ClanNotifier.Enabled then 
				ClanNotifier.ToggleButton()
				ClanNotifier.ToggleButton()
			end
		end,
		RemoveFunction = function() end
	})
end)

runFunction(function()
	local BedTP = {}
	local BedTPAutoRaycast = {}
	local BedTPAutoSpeed = {}
	local BedTPTween = {Value = 50}
	local BedTPYLevel = {Value = 25}
	local BedTPTeleport = {Value = 'Respawn'}
	local BedTPMethod = {Value = 'Linear'}
	local oldmovefunc
	local bedtween
	local bypassmethods = {
		Respawn = function()
			if isEnabled('InfiniteFly') then 
				return 
			end 
			if not canRespawn() then 
				return 
			end
			for i = 1, 30 do 
				if isAlive(lplr, true) and lplr.Character.Humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
					lplr.Character.Humanoid:TakeDamage(lplr.Character.Humanoid.Health)
					lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
				end
			end
			lplr.CharacterAdded:Wait()
			repeat task.wait() until isAlive(lplr, true) 
			local bed = getEnemyBed(nil, BedTPAutoRaycast.Enabled == false) 
			if bed == nil or not BedTP.Enabled then 
				return 
			end
			task.wait(0.1)
			local localposition = lplr.Character.HumanoidRootPart.Position
			local tweenspeed = (BedTPAutoSpeed.Enabled and ((bed.Position - localposition).Magnitude / 690) + 0.001 or (BedTPTween.Value / 650) + 0.5)
			local tweenstyle = (BedTPAutoSpeed.Enabled and Enum.EasingStyle.Linear or Enum.EasingStyle[BedTPMethod.Value])
			bedtween = tweenService:Create(lplr.Character.HumanoidRootPart, TweenInfo.new(tweenspeed, tweenstyle), {CFrame = bed.CFrame + Vector3.new(0, BedTPAutoRaycast.Enabled and 5 or BedTPYLevel.Value)})
			bedtween:Play()
			bedtween.Completed:Wait() 
		end,
		Recall = function()
			if not isAlive(lplr, true) or lplr.Character.Humanoid.FloorMaterial == Enum.Material.Air then 
				errorNotification('BedTP', 'Recall ability not available.', 7)
				return 
			end
			if not bedwars.AbilityController:canUseAbility('recall') then 
				errorNotification('BedTP', 'Recall ability not available.', 7)
				return
			end
			pcall(function()
				oldmovefunc = require(lplr.PlayerScripts.PlayerModule).controls.moveFunction 
				require(lplr.PlayerScripts.PlayerModule).controls.moveFunction = function() end
			end)
			bedwars.AbilityController:useAbility('recall')
			local teleported
			table.insert(BedTP.Connections, lplr:GetAttributeChangedSignal('LastTeleported'):Connect(function() teleported = true end))
			repeat task.wait() until teleported or not BedTP.Enabled or not isAlive(lplr, true) -- ik I could just use lplr:GetAttributeChangedSignal('LastTeleported'):Wait() but nah
			task.wait()
			local bed = getEnemyBed(nil, BedTPAutoRaycast.Enabled == false) 
			if bed == nil or not BedTP.Enabled or not isAlive(lplr, true) then 
				return 
			end
			local localposition = lplr.Character.HumanoidRootPart.Position
			local tweenspeed = (BedTPAutoSpeed.Enabled and ((bed.Position - localposition).Magnitude / 1000) + 0.001 * (math.random(5, 30)) or (BedTPTween.Value / 1000) + 0.1)
			local tweenstyle = (BedTPAutoSpeed.Enabled and Enum.EasingStyle.Linear or Enum.EasingStyle[BedTPMethod.Value])
			bedtween = tweenService:Create(lplr.Character.HumanoidRootPart, TweenInfo.new(tweenspeed, tweenstyle), {CFrame = bed.CFrame + Vector3.new(0, BedTPAutoRaycast.Enabled and 5 or BedTPYLevel.Value)})
			bedtween:Play()
			bedtween.Completed:Wait()
		end
	}
	BedTP = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = 'BedTP',
		HoverText = 'Tweens you to a nearby bed.',
		Function = function(calling) 
			if calling then 
				if getEnemyBed(nil, BedTPAutoRaycast.Enabled == false) == nil or not shared.VapeFullyLoaded then 
					BedTP.ToggleButton()
					return 
				end
				bypassmethods[isAlive() and BedTPTeleport.Value or 'Respawn']()
				if BedTP.Enabled then 
					BedTP.ToggleButton()
				end 
			else
				pcall(function() bedtween:Cancel() end)
				if oldmovefunc then 
					pcall(function() require(lplr.PlayerScripts.PlayerModule).controls.moveFunction = oldmovefunc end)
				end
				oldmovefunc = nil
			end
		end
	})
	BedTPAutoRaycast = BedTP.CreateToggle({
		Name = 'Highest Block',
		HoverText = 'Gets the highest block from the bed\n(useful for bed defenses).',
		Default = true,
		Function = function() 
			if calling then 
				pcall(function() BedTPYLevel.Object.Visible = false end) 
			else 
				pcall(function() BedTPYLevel.Object.Visible = true end) 
			end
		end
	})
	BedTPTeleport = BedTP.CreateDropdown({
		Name = 'Teleport Method',
		List = {'Respawn', 'Recall'},
		Function = function() end
	})
	BedTPAutoSpeed = BedTP.CreateToggle({
		Name = 'Auto Speed',
		HoverText = 'Automatically uses a "good" tween speed.',
		Default = true,
		Function = function(calling) 
			if calling then 
				pcall(function() BedTPTween.Object.Visible = false end) 
			else 
				pcall(function() BedTPTween.Object.Visible = true end) 
			end
		end
	})
	BedTPYLevel = BedTP.CreateSlider({
		Name = 'Extra Velo',
		Min = 20, 
		Max = 350,
		Default = 200,
		Function = function() end
	})
	BedTPTween = BedTP.CreateSlider({
		Name = 'Tween Speed',
		Min = 20, 
		Max = 350,
		Default = 200,
		Function = function() end
	})
	BedTPMethod = BedTP.CreateDropdown({
		Name = 'Tween Method',
		List = GetEnumItems('EasingStyle'),
		Function = function() end
	})
	BedTPTween.Object.Visible = false
	BedTPYLevel.Object.Visible = false
end)

runFunction(function()
	local PlayerTP = {}
	local PlayerTPTeleport = {Value = 'Respawn'}
	local PlayerTPSort = {Value = 'Distance'}
	local PlayerTPMethod = {Value = 'Linear'}
	local PlayerTPAutoSpeed = {}
	local PlayerTPSpeed = {Value = 200}
	local PlayerTPTarget = {Value = ''}
	local playertween
	local oldmovefunc
	local bypassmethods = { -- was too lazy to write most of the code here again, so pasted from the BedTP. 
	    Respawn = function() 
			if isEnabled('InfiniteFly') then 
				return 
			end
			if not canRespawn() then 
				return 
			end
			for i = 1, 30 do 
				if isAlive(lplr, true) and lplr.Character.Humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
					lplr.Character.Humanoid:TakeDamage(lplr.Character.Humanoid.Health)
					lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
				end
			end
			lplr.CharacterAdded:Wait()
			repeat task.wait() until isAlive(lplr, true) 
			task.wait(0.1)
			local target = GetTarget(nil, PlayerTPSort.Value == 'Health', true)
			if target.RootPart == nil or not PlayerTP.Enabled then 
				return
			end
			local localposition = lplr.Character.HumanoidRootPart.Position
			local tweenspeed = (PlayerTPAutoSpeed.Enabled and ((target.RootPart.Position - localposition).Magnitude / 470) + 0.001 * 2 or (PlayerTPSpeed.Value / 1000) + 0.1)
			local tweenstyle = (PlayerTPAutoSpeed.Enabled and Enum.EasingStyle.Linear or Enum.EasingStyle[PlayerTPMethod.Value])
			playertween = tweenService:Create(lplr.Character.HumanoidRootPart, TweenInfo.new(tweenspeed, tweenstyle), {CFrame = target.RootPart.CFrame}) 
			playertween:Play() 
			playertween.Completed:Wait()
		end,
		Recall = function()
			if not isAlive(lplr, true) or lplr.Character.Humanoid.FloorMaterial == Enum.Material.Air then 
				errorNotification('PlayerTP', 'Recall ability not available.', 7)
				return 
			end
			if not bedwars.AbilityController:canUseAbility('recall') then 
				errorNotification('PlayerTP', 'Recall ability not available.', 7)
				return
			end
			pcall(function()
				oldmovefunc = require(lplr.PlayerScripts.PlayerModule).controls.moveFunction 
				require(lplr.PlayerScripts.PlayerModule).controls.moveFunction = function() end
			end)
			bedwars.AbilityController:useAbility('recall')
			local teleported
			table.insert(PlayerTP.Connections, lplr:GetAttributeChangedSignal('LastTeleported'):Connect(function() teleported = true end))
			repeat task.wait() until teleported or not PlayerTP.Enabled or not isAlive(lplr, true) 
			task.wait()
			local target = GetTarget(nil, PlayerTPSort.Value == 'Health', true)
			if target.RootPart == nil or not isAlive(lplr, true) or not PlayerTP.Enabled then 
				return
			end
			local localposition = lplr.Character.HumanoidRootPart.Position
			local tweenspeed = (PlayerTPAutoSpeed.Enabled and ((target.RootPart.Position - localposition).Magnitude / 1000) + 0.001 or (PlayerTPSpeed.Value / 1000) + 0.1)
			local tweenstyle = (PlayerTPAutoSpeed.Enabled and Enum.EasingStyle.Linear or Enum.EasingStyle[PlayerTPMethod.Value])
			playertween = tweenService:Create(lplr.Character.HumanoidRootPart, TweenInfo.new(tweenspeed, tweenstyle), {CFrame = target.RootPart.CFrame}) 
			playertween:Play() 
			playertween.Completed:Wait()
		end
	}
	PlayerTP = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = 'PlayerTP',
		HoverText = 'Tweens you to a nearby target.',
		Function = function(calling)
			if calling then 
				if GetTarget(nil, PlayerTPSort.Value == 'Health', true).RootPart and shared.VapeFullyLoaded then 
					bypassmethods[isAlive() and PlayerTPTeleport.Value or 'Respawn']() 
				end
				if PlayerTP.Enabled then 
					PlayerTP.ToggleButton()
				end
			else
				pcall(function() playertween:Disconnect() end)
				if oldmovefunc then 
					pcall(function() require(lplr.PlayerScripts.PlayerModule).controls.moveFunction = oldmovefunc end)
				end
				oldmovefunc = nil
			end
		end
	})
	PlayerTPTeleport = PlayerTP.CreateDropdown({
		Name = 'Teleport Method',
		List = {'Respawn', 'Recall'},
		Function = function() end
	})
	PlayerTPAutoSpeed = PlayerTP.CreateToggle({
		Name = 'Auto Speed',
		HoverText = 'Automatically uses a "good" tween speed.',
		Default = true,
		Function = function(calling) 
			if calling then 
				pcall(function() PlayerTPSpeed.Object.Visible = false end) 
			else 
				pcall(function() PlayerTPSpeed.Object.Visible = true end) 
			end
		end
	})
	PlayerTPSpeed = PlayerTP.CreateSlider({
		Name = 'Tween Speed',
		Min = 20, 
		Max = 350,
		Default = 200,
		Function = function() end
	})
	PlayerTPMethod = PlayerTP.CreateDropdown({
		Name = 'Teleport Method',
		List = GetEnumItems('EasingStyle'),
		Function = function() end
	})
	PlayerTPSpeed.Object.Visible = false
end)

runFunction(function()
	local function getItemDrop(drop)
		if not isAlive(lplr, true) and not RenderStore.LocalPosition then 
			return nil
		end
		local itemdrop, magnitude = nil, math.huge
		for i,v in next, collectionService:GetTagged('ItemDrop') do 
			if v.Name == drop then 
				local localpos = (isAlive(lplr, true) and lplr.Character.HumanoidRootPart.Position or RenderStore.LocalPosition)
				local newdistance = (localpos - v.Position).Magnitude 
				if newdistance < magnitude then 
					magnitude = newdistance 
					itemdrop = v 
				end
			end
		end
		return itemdrop
	end

	local DiamondTP = {}
	local DiamondTPAutoSpeed = {}
	local DiamondTPSpeed = {Value = 200}
	local DiamondTPTeleport = {Value = 'Respawn'}
	local DiamondTPMethod = {Value = 'Linear'}
	local diamondtween 
	local oldmovefunc 
	local bypassmethods = {
		Respawn = function() 
			if isEnabled('InfiniteFly') then 
				return 
			end
			if not canRespawn() then 
				return 
			end
			for i = 1, 30 do 
				if isAlive(lplr, true) and lplr.Character.Humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
					lplr.Character.Humanoid:TakeDamage(lplr.Character.Humanoid.Health)
					lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
				end
			end
			lplr.CharacterAdded:Wait()
			repeat task.wait() until isAlive(lplr, true) 
			task.wait(0.1)
			local item = getItemDrop('diamond')
			if item == nil or not DiamondTP.Enabled then 
				return
			end
			local localposition = lplr.Character.HumanoidRootPart.Position
			local tweenspeed = (DiamondTPAutoSpeed.Enabled and ((item.Position - localposition).Magnitude / 470) + 0.001 * 2 or (DiamondTPSpeed.Value / 1000) + 0.1)
			local tweenstyle = (DiamondTPAutoSpeed.Enabled and Enum.EasingStyle.Linear or Enum.EasingStyle[DiamondTPTeleport.Value])
			diamondtween = tweenService:Create(lplr.Character.HumanoidRootPart, TweenInfo.new(tweenspeed, tweenstyle), {CFrame = item.CFrame}) 
			diamondtween:Play() 
			diamondtween.Completed:Wait()
		end,
		Recall = function()
			if not isAlive(lplr, true) or lplr.Character.Humanoid.FloorMaterial == Enum.Material.Air then 
				errorNotification('DiamondTP', 'Recall ability not available.', 7)
				return 
			end
			if not bedwars.AbilityController:canUseAbility('recall') then 
				errorNotification('DiamondTP', 'Recall ability not available.', 7)
				return
			end
			pcall(function()
				oldmovefunc = require(lplr.PlayerScripts.PlayerModule).controls.moveFunction 
				require(lplr.PlayerScripts.PlayerModule).controls.moveFunction = function() end
			end)
			bedwars.AbilityController:useAbility('recall')
			local teleported
			table.insert(DiamondTP.Connections, lplr:GetAttributeChangedSignal('LastTeleported'):Connect(function() teleported = true end))
			repeat task.wait() until teleported or not DiamondTP.Enabled or not isAlive(lplr, true) 
			task.wait()
			local item = getItemDrop('diamond')
			if item == nil or not isAlive(lplr, true) then 
				return
			end
			local localposition = lplr.Character.HumanoidRootPart.Position
			local tweenspeed = (DiamondTPAutoSpeed.Enabled and ((item.Position - localposition).Magnitude / 470) + 0.001 * 2 or (DiamondTPSpeed.Value / 1000) + 0.1)
			local tweenstyle = (DiamondTPAutoSpeed.Enabled and Enum.EasingStyle.Linear or Enum.EasingStyle[DiamondTPTeleport.Value])
			diamondtween = tweenService:Create(lplr.Character.HumanoidRootPart, TweenInfo.new(tweenspeed, tweenstyle), {CFrame = item.CFrame}) 
			diamondtween:Play() 
			diamondtween.Completed:Wait()
		end
	}
	DiamondTP = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = 'DiamondTP',
		HoverText = 'Tweens you to a nearby diamond drop.',
		Function = function(calling)
			if calling then 
				if getItemDrop('diamond') then 
					bypassmethods[isAlive() and DiamondTPTeleport.Value or 'Respawn']() 
				end
				if DiamondTP.Enabled then 
					DiamondTP.ToggleButton()
				end 
			else
				pcall(function() diamondtween:Cancel() end) 
				if oldmovefunc then 
					pcall(function() require(lplr.PlayerScripts.PlayerModule).controls.moveFunction = oldmovefunc end)
				end
				oldmovefunc = nil
			end
		end
	})
	DiamondTPTeleport = DiamondTP.CreateDropdown({
		Name = 'Teleport Method',
		List = {'Respawn', 'Recall'},
		Function = function() end
	})
	DiamondTPAutoSpeed = DiamondTP.CreateToggle({
		Name = 'Auto Speed',
		HoverText = 'Automatically uses a "good" tween speed.',
		Default = true,
		Function = function(calling) 
			if calling then 
				pcall(function() DiamondTPSpeed.Object.Visible = false end) 
			else 
				pcall(function() DiamondTPSpeed.Object.Visible = true end) 
			end
		end
	})
	DiamondTPSpeed = DiamondTP.CreateSlider({
		Name = 'Tween Speed',
		Min = 20, 
		Max = 350,
		Default = 200,
		Function = function() end
	})
	DiamondTPMethod = DiamondTP.CreateDropdown({
		Name = 'Teleport Method',
		List = GetEnumItems('EasingStyle'),
		Function = function() end
	})
	DiamondTPSpeed.Object.Visible = false

	local EmeraldTP = {}
	local EmeraldTPAutoSpeed = {}
	local EmeraldTPSpeed = {Value = 200}
	local EmeraldTPTeleport = {Value = 'Respawn'}
	local EmeraldTPMethod = {Value = 'Linear'}
	local emeraldtween 
	local bypassmethods = {
		Respawn = function() 
			if isEnabled('InfiniteFly') then 
				return 
			end
			if not canRespawn() then 
				return 
			end
			for i = 1, 30 do 
				if isAlive(lplr, true) and lplr.Character.Humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
					lplr.Character.Humanoid:TakeDamage(lplr.Character.Humanoid.Health)
					lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
				end
			end
			lplr.CharacterAdded:Wait()
			repeat task.wait() until isAlive(lplr, true) 
			task.wait(0.1)
			local item = getItemDrop('emerald')
			if item == nil or not EmeraldTP.Enabled then 
				return
			end
			local localposition = lplr.Character.HumanoidRootPart.Position
			local tweenspeed = (EmeraldTPAutoSpeed.Enabled and ((item.Position - localposition).Magnitude / 470) + 0.001 * 2 or (EmeraldTPSpeed.Value / 1000) + 0.1)
			local tweenstyle = (EmeraldTPAutoSpeed.Enabled and Enum.EasingStyle.Linear or Enum.EasingStyle[EmeraldTPTeleport.Value])
			emeraldtween = tweenService:Create(lplr.Character.HumanoidRootPart, TweenInfo.new(tweenspeed, tweenstyle), {CFrame = item.CFrame}) 
			emeraldtween:Play() 
			emeraldtween.Completed:Wait()
		end,
		Recall = function()
			if not isAlive(lplr, true) or lplr.Character.Humanoid.FloorMaterial == Enum.Material.Air then 
				errorNotification('EmeraldTP', 'Recall ability not available.', 7)
				return 
			end
			if not bedwars.AbilityController:canUseAbility('recall') then 
				errorNotification('EmeraldTP', 'Recall ability not available.', 7)
				return
			end
			pcall(function()
				oldmovefunc = require(lplr.PlayerScripts.PlayerModule).controls.moveFunction 
				require(lplr.PlayerScripts.PlayerModule).controls.moveFunction = function() end
			end)
			bedwars.AbilityController:useAbility('recall')
			local teleported
			table.insert(EmeraldTP.Connections, lplr:GetAttributeChangedSignal('LastTeleported'):Connect(function() teleported = true end))
			repeat task.wait() until teleported or not EmeraldTP.Enabled or not isAlive(lplr, true) 
			task.wait()
			local item = getItemDrop('emerald')
			if item == nil or not isAlive(lplr, true) then 
				return
			end
			local localposition = lplr.Character.HumanoidRootPart.Position
			local tweenspeed = (EmeraldTPAutoSpeed.Enabled and ((item.Position - localposition).Magnitude / 470) + 0.001 * 2 or (EmeraldTPSpeed.Value / 1000) + 0.1)
			local tweenstyle = (EmeraldTPAutoSpeed.Enabled and Enum.EasingStyle.Linear or Enum.EasingStyle[EmeraldTPTeleport.Value])
			emeraldtween = tweenService:Create(lplr.Character.HumanoidRootPart, TweenInfo.new(tweenspeed, tweenstyle), {CFrame = item.CFrame}) 
			emeraldtween:Play() 
			emeraldtween.Completed:Wait()
		end
	}
	EmeraldTP = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = 'EmeraldTP',
		HoverText = 'Tweens you to a nearby diamond drop.',
		Function = function(calling)
			if calling then 
				if getItemDrop('emerald') then 
					bypassmethods[isAlive() and EmeraldTPTeleport.Value or 'Respawn']() 
				end
				if EmeraldTP.Enabled then 
					EmeraldTP.ToggleButton()
				end 
			else
				pcall(function() emeraldtween:Cancel() end) 
				if oldmovefunc then 
					pcall(function() require(lplr.PlayerScripts.PlayerModule).controls.moveFunction = oldmovefunc end)
				end
				oldmovefunc = nil
			end
		end
	})
	EmeraldTPTeleport = EmeraldTP.CreateDropdown({
		Name = 'Teleport Method',
		List = {'Respawn', 'Recall'},
		Function = function() end
	})
	EmeraldTPAutoSpeed = EmeraldTP.CreateToggle({
		Name = 'Auto Speed',
		HoverText = 'Automatically uses a "good" tween speed.',
		Default = true,
		Function = function(calling) 
			if calling then 
				pcall(function() EmeraldTPSpeed.Object.Visible = false end) 
			else 
				pcall(function() EmeraldTPSpeed.Object.Visible = true end) 
			end
		end
	})
	EmeraldTPSpeed = EmeraldTP.CreateSlider({
		Name = 'Tween Speed',
		Min = 20, 
		Max = 350,
		Default = 200,
		Function = function() end
	})
	EmeraldTPMethod = EmeraldTP.CreateDropdown({
		Name = 'Teleport Method',
		List = GetEnumItems('EasingStyle'),
		Function = function() end
	})
	EmeraldTPSpeed.Object.Visible = false
end)

runFunction(function()
	local HackerDetector = {}
	local HackerDetectorInfFly = {}
	local HackerDetectorTeleport = {}
	local HackerDetectorNuker = {}
	local HackerDetectorFunny = {}
	local HackerDetectorInvis = {}
	local HackerDetectorName = {}
	local HackerDetectorSpeed = {}
	local HackerDetectorFileCache = {}
	local pastesploit
	local detectedusers = {
		InfiniteFly = {},
		Teleport = {},
		Nuker = {},
		AnticheatBypass = {},
		Invisibility = {},
		Speed = {},
		Name = {},
		Cache = {}
	}
	local distances = { -- more stuff will be added in future idk
		windwalker = 80
	}
	local function cachedetection(player, detection)
		if not HackerDetectorFileCache.Enabled then 
			return 
		end
		local success, response = pcall(function()
			return httpService:JSONDecode(readfile('vape/Render/exploiters.json')) 
		end)
		if type(response) ~= 'table' then 
			response = {}
		end
		if response[player.Name] then 
			if table.find(response[player.Name], detection) == nil then 
				table.insert(response[player.Name].Detections, detection) 
			end
		else
			response[player.Name] = {DisplayName = player.DisplayName, UserId = tostring(player.DisplayName), Detections = {detection}}
		end
		if isfolder('vape/Render') then 
			writefile('vape/Render/exploiters.json', httpService:JSONEncode(response))
		end
	end
	local detectionmethods = {
		Teleport = function(plr)
			if table.find(detectedusers.Teleport, plr) then 
				return 
			end
			if bedwarsStore.queueType:find('bedwars') == nil or plr:GetAttribute('Spectator') then 
				return 
			end
			local lastbwteleport = plr:GetAttribute('LastTeleported')
			table.insert(HackerDetector.Connections, plr:GetAttributeChangedSignal('LastTeleported'):Connect(function() lastbwteleport = plr:GetAttribute('LastTeleported') end))
			table.insert(HackerDetector.Connections, plr.CharacterAdded:Connect(function()
				oldpos = Vector3.zero
				if table.find(detectedusers.Teleport, plr) then 
					return 
				end
				 repeat task.wait() until isAlive(plr, true)
				 local oldpos2 = plr.Character.HumanoidRootPart.Position 
				 task.delay(2, function()
					if isAlive(plr, true) then 
						local newdistance = (plr.Character.HumanoidRootPart.Position - oldpos2).Magnitude 
						if newdistance >= 400 and (plr:GetAttribute('LastTeleported') - lastbwteleport) == 0 then 
							InfoNotification('HackerDetector', plr.DisplayName..' is using Teleport Exploit!', 100) 
							table.insert(detectedusers.Teleport, plr)
							cachedetection(plr, 'Teleport')
							if RenderFunctions.playerTags[plr] == nil then 
								RenderFunctions:CreatePlayerTag(plr, 'SCRIPT KIDDIE', 'FF0000') 
							end
						end 
					end
				 end)
			end))
		end,
		Speed = function(plr) 
			repeat task.wait() until (bedwarsStore.matchState ~= 0 or not HackerDetector.Enabled or not HackerDetectorSpeed.Enabled)
			if table.find(detectedusers.Speed, plr) then 
				return 
			end
			local lastbwteleport = plr:GetAttribute('LastTeleported')
			local oldpos = Vector3.zero 
			table.insert(HackerDetector.Connections, plr:GetAttributeChangedSignal('LastTeleported'):Connect(function() lastbwteleport = plr:GetAttribute('LastTeleported') end)) 
			table.insert(HackerDetector.Connections, plr.CharacterAdded:Connect(function() oldpos = Vector3.zero end))
			repeat 
				if isAlive(plr, true) then 
					local magnitude = (plr.Character.HumanoidRootPart.Position - oldpos).Magnitude
					if (plr:GetAttribute('LastTeleported') - lastbwteleport) ~= 0 and magnitude >= ((distances[plr:GetAttribute('PlayingAsKit') or ''] or 25) + (playerRaycasted(plr, Vector3.new(0, -15, 0)) and 0 or 40)) then 
						InfoNotification('HackerDetector', plr.DisplayName..' is using speed!', 60)
						if RenderFunctions.playerTags[plr] == nil then 
							RenderFunctions:CreatePlayerTag(plr, 'SCRIPT KIDDIE', 'FF0000') 
						end
					end
					oldpos = plr.Character.HumanoidRootPart.Position
					task.wait(2.5)
					lastbwteleport = plr:GetAttribute('LastTeleported')
				end
			until not task.wait() or table.find(detectedusers.Speed, plr) or (not HackerDetector.Enabled or not HackerDetectorSpeed.Enabled)
		end,
		InfiniteFly = function(plr) 
			repeat 
				if isAlive(plr, true) then 
					local magnitude = (RenderStore.LocalPosition - plr.Character.HumanoidRootPart.Position).Magnitude
					if magnitude >= 10000 and playerRaycast(plr) == nil and playerRaycast({Character = {PrimaryPart = {Position = RenderStore.LocalPosition}}}) then 
						InfoNotification('HackerDetector', plr.DisplayName..' is using InfiniteFly!', 60) 
						cachedetection(plr, 'InfiniteFly')
						table.insert(detectedusers.InfiniteFly, plr)
						if RenderFunctions.playerTags[plr] == nil then 
							RenderFunctions:CreatePlayerTag(plr, 'SCRIPT KIDDIE', 'FF0000') 
						end
					end
					task.wait(2.5)
				end
			until not task.wait() or table.find(detectedusers.InfiniteFly, plr) or (not HackerDetector.Enabled or not HackerDetectorInfFly.Enabled)
		end,
		Invisibility = function(plr) 
			if table.find(detectedusers.Invisibility, plr) then 
				return 
			end
			repeat 
				for i,v in next, (isAlive(plr, true) and plr.Character.Humanoid:GetPlayingAnimationTracks() or {}) do 
					if v.Animation.AnimationId == 'http://www.roblox.com/asset/?id=11335949902' or v.Animation.AnimationId == 'rbxassetid://11335949902' then 
						InfoNotification('HackerDetector', plr.DisplayName..' is using Invisibility!', 60) 
						table.insert(detectedusers.Invisibility, plr)
						cachedetection(plr, 'Invisibility')
						if RenderFunctions.playerTags[plr] == nil then 
							RenderFunctions:CreatePlayerTag(plr, 'SCRIPT KIDDIE', 'FF0000') 
						end
					end
				end
				task.wait(0.5)
			until table.find(detectedusers.Invisibility, plr) or (not HackerDetector.Enabled or not HackerDetectorInvis.Enabled)
		end,
		Name = function(plr) 
			repeat task.wait() until pastesploit 
			local lines = pastesploit:split('\n') 
			for i,v in next, lines do 
				if v:find('local Owner = ') then 
					local name = lines[i]:gsub('local Owner =', ''):gsub('"', ''):gsub("'", '') 
					if plr.Name == name then 
						InfoNotification('HackerDetector', plr.DisplayName..' is the owner of Godsploit! They\'re is most likely cheating.', 60) 
						cachedetection(plr, 'Name')
						if RenderFunctions.playerTags[plr] == nil then 
							RenderFunctions:CreatePlayerTag(plr, 'SCRIPT KIDDIE', 'FF0000') 
						end 
					end
				end
			end
			for i,v in next, ({'godsploit', 'alsploit', 'renderintents'}) do 
				local user = plr.Name:lower():find(v) 
				local display = plr.DisplayName:lower():find(v)
				if user or display then 
					InfoNotification('HackerDetector', plr.DisplayName..' has "'..v..'" in their '..(user and 'username' or 'display name')..'! They might be cheating.', 20)
					cachedetection(plr, 'Name') 
					return 
				end
			end
		end, 
		Cache = function(plr)
			local success, response = pcall(function()
				return httpService:JSONDecode(readfile('vape/Render/exploiters.json')) 
			end) 
			if type(response) == 'table' and response[plr.Name] then 
				InfoNotification('HackerDetector', plr.DisplayName..' is cached on the exploiter database!', 30)
				table.insert(detectedusers.Cached, plr)
				if RenderFunctions.playerTags[plr] == nil then 
					RenderFunctions:CreatePlayerTag(plr, 'SCRIPT KIDDIE', 'FF0000') 
				end
			end
		end
	}
	local function bootdetections(player)
		local detectiontoggles = {InfiniteFly = HackerDetectorInfFly, Teleport = HackerDetectorTeleport, Nuker = HackerDetectorNuker, Invisibility = HackerDetectorInvis, Speed = HackerDetectorSpeed, Name = HackerDetectorName, Cache = HackerDetectorFileCache}
		for i, detection in next, detectionmethods do 
			if detectiontoggles[i].Enabled then
			   task.spawn(detection, player)
			end
		end
	end
	HackerDetector = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'HackerDetector',
		HoverText = 'Notify when someone is\nsuspected of using exploits.',
		ExtraText = function() return 'Vanilla' end,
		Function = function(calling) 
			if calling then 
				for i,v in next, playersService:GetPlayers() do 
					if v ~= lplr then 
						bootdetections(v) 
					end 
				end
				table.insert(HackerDetector.Connections, playersService.PlayerAdded:Connect(bootdetections))
			end
		end
	})
	HackerDetectorTeleport = HackerDetector.CreateToggle({
		Name = 'Teleport',
		Default = true,
		Function = function() end
	})
	HackerDetectorInfFly = HackerDetector.CreateToggle({
		Name = 'InfiniteFly',
		Default = true,
		Function = function() end
	})
	HackerDetectorInvis = HackerDetector.CreateToggle({
		Name = 'Invisibility',
		Default = true,
		Function = function() end
	})
	HackerDetectorNuker = HackerDetector.CreateToggle({
		Name = 'Nuker',
		Default = true,
		Function = function() end
	})
	HackerDetectorSpeed = HackerDetector.CreateToggle({
		Name = 'Speed',
		Default = true,
		Function = function() end
	})
	HackerDetectorName = HackerDetector.CreateToggle({
		Name = 'Name',
		Default = true,
		Function = function() end
	})
	HackerDetectorFileCache = HackerDetector.CreateToggle({
		Name = 'Cached detections',
		HoverText = 'Writes (vape/Render/exploiters.json)\neverytime someone is detected.',
		Default = true,
		Function = function() end
	})
	task.spawn(function()
		repeat 
			if pastesploit == nil then 
				task.spawn(function()
					pcall(function() pastesploit = game:HttpGet('https://raw.githubusercontent.com/AlSploit/GodSploit/'..RenderFunctions:GithubHash('GodSploit', 'AlSploit')..'/MainScript') end)
				end)
			end
			task.wait(10) 
		until not vapeInjected
	end)
end)

runFunction(function()
	local HealthNotifications = {}
	local HealthNotificationInfFly = {}
	local HealthSlider = {Value = 50}
	local HealthSound = {}
	local oldhealth = 0
	local notallowed
	HealthNotifications = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'HealthAlerts',
		HoverText = 'Runs actions whenever your health was under threshold.',
		ExtraText = function() return 'Bedwars' end,
		Function = function(calling)
			if calling then
				task.spawn(function()
					repeat task.wait() until isAlive() or not HealthNotifications.Enabled
					if not HealthNotifications.Enabled then 
						return 
					end
					table.insert(HealthNotifications.Connections, lplr.Character:GetAttributeChangedSignal('Health'):Connect(function()
						if not isAlive() then return end
						local health = lplr.Character:GetAttribute('Health')
						local maxhealth = lplr.Character:GetAttribute('MaxHealth')
						if health == oldhealth then return end
						if health > oldhealth then 
							oldhealth = health 
							return
						end
						oldhealth = health
						if notallowed then 
							return 
						end
						if health < maxhealth and health <= HealthSlider.Value then
							if HealthNotificationInfFly.Enabled and not isEnabled('InfiniteFly') and not isEnabled('Autowin') then 
								GuiLibrary.ObjectsThatCanBeSaved.InfiniteFlyOptionsButton.Api.ToggleButton()  
								if isEnabled('Fly') then 
									GuiLibrary.ObjectsThatCanBeSaved.FlyOptionsButton.Api.ToggleButton() 
								end
							end
							task.spawn(playSound, HealthNotificationsID.Value ~= '' and HealthNotificationsID.Value or '7396762708')
							notallowed = true
							InfoNotification('HealthNotifications', 'Your health is '..(health < HealthSlider.Value and 'below' or 'at')..' '..HealthSlider.Value, 10)
							task.spawn(function()
								repeat task.wait() until isAlive(lplr, true) and lplr.Character:GetAttribute('Health') > HealthSlider.Value 
								notallowed = false
							end)
						end
					end))
					table.insert(HealthNotifications.Connections, lplr.CharacterAdded:Connect(function()
						HealthNotifications.ToggleButton(false)
						HealthNotifications.ToggleButton(false)
					end))
				end)
			else
				strikedhealth = nil
				oldhealth = 0
			end
		end
	})
	HealthNotificationsID = HealthNotifications.CreateTextBox({
		Name = 'SongID',
		TempText = 'Song ID',
		HoverText = 'Song ID to play',
		FocusLost = function(enter)
			if HealthNotifications.Enabled then
				HealthNotifications.ToggleButton(false)
				HealthNotifications.ToggleButton(false)
			end
		end
	})
	HealthSlider = HealthNotifications.CreateSlider({
		Name = 'Health',
		Min = 5,
		Max = 80,
		Default = 30,
		Function = function() end
	})
	HealthNotificationInfFly = HealthNotifications.CreateToggle({
		Name = 'InfiniteFly',
		HoverText = 'Toggles InfiniteFly when health\nreaches exact/below threshold.',
		Default = true,
		Function = function() end
	})
	HealthSound = HealthNotifications.CreateToggle({
		Name = 'Sound',
		HoverText = 'Plays an alarm sound on trigger.',
		Default = true,
		Function = function() end
	})
end)

runFunction(function()
	local DamageIndicator = {}
	local DamageIndicatorColorToggle = {}
	local DamageIndicatorColor = {Hue = 0, Sat = 0, Value = 0}
	local DamageIndicatorTextToggle = {}
	local DamageIndicatorText = {ObjectList = {}}
	local DamageIndicatorFontToggle = {}
	local DamageIndicatorFont = {Value = 'GothamBlack'}
	local DamageIndicatorTextObjects = {}
    local DamageMessages, OrigIndicator, OrgInd = {
		'Pow!',
		'Pop!',
		'Hit!',
		'Smack!',
		'Bang!',
		'Boom!',
		'Whoop!',
		'Damage!',
		'-9e9!',
		'Whack!',
		'Crash!',
		'Slam!',
		'Zap!',
		'Snap!',
		'Thump!'
	}, nil, OrigIndicator
	local RGBColors = {
		Color3.fromRGB(255, 0, 0),
		Color3.fromRGB(255, 127, 0),
		Color3.fromRGB(255, 255, 0),
		Color3.fromRGB(0, 255, 0),
		Color3.fromRGB(0, 0, 255),
		Color3.fromRGB(75, 0, 130),
		Color3.fromRGB(148, 0, 211)
	}
	local orgI, mz, vz = 1, 5, 10
    local DamageIndicatorMode = {Value = 'Rainbow'}
	local DamageIndicatorMode2 = {Value = 'Gradient'}
	DamageIndicator = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = 'DamageIndicator',
		Function = function(calling)
			if calling then
				task.spawn(function()
					table.insert(DamageIndicator.Connections, workspace.DescendantAdded:Connect(function(v)
						pcall(function()
                            if v.Name ~= 'DamageIndicatorPart' then return end
							local indicatorobj = v:FindFirstChildWhichIsA('BillboardGui'):FindFirstChildWhichIsA('Frame'):FindFirstChildWhichIsA('TextLabel')
							if indicatorobj then
                                if DamageIndicatorColorToggle.Enabled then
                                    -- indicatorobj.TextColor3 = Color3.fromHSV(DamageIndicatorColor.Hue, DamageIndicatorColor.Sat, DamageIndicatorColor.Value)
                                    if DamageIndicatorMode.Value == 'Rainbow' then
                                        if DamageIndicatorMode2.Value == 'Gradient' then
                                            indicatorobj.TextColor3 = Color3.fromHSV(tick() % mz / mz, orgI, orgI)
                                        else
                                            runService.Stepped:Connect(function()
                                                orgI = (orgI % #RGBColors) + 1
                                                indicatorobj.TextColor3 = RGBColors[orgI]
                                            end)
                                        end
                                    elseif DamageIndicatorMode.Value == 'Custom' then
                                        indicatorobj.TextColor3 = Color3.fromHSV(
                                            DamageIndicatorColor.Hue, 
                                            DamageIndicatorColor.Sat, 
                                            DamageIndicatorColor.Value
                                        )
                                    else
                                        indicatorobj.TextColor3 = Color3.fromRGB(127, 0, 255)
                                    end
                                end
                                if DamageIndicatorTextToggle.Enabled then
                                    if DamageIndicatorMode1.Value == 'Custom' then
                                        indicatorobj.Text = getrandomvalue(DamageIndicatorText.ObjectList) ~= '' and getrandomvalue(DamageIndicatorText.ObjectList) or indicatorobject.Text
									elseif DamageIndicatorMode1.Value == 'Multiple' then
										indicatorobj.Text = DamageMessages[math.random(orgI, #DamageMessages)]
									else
										indicatorobj.Text = DamageIndicatorCustom.Value or 'Render Intents on top!'
									end
								end
								indicatorobj.Font = DamageIndicatorFontToggle.Enabled and Enum.Font[DamageIndicatorFont.Value] or indicatorobject.Font
							end
						end)
					end))
				end)
			end
		end
	})
    DamageIndicatorMode = DamageIndicator.CreateDropdown({
		Name = 'Color Mode',
		List = {
			'Rainbow',
			'Custom',
			'Lunar'
		},
		HoverText = 'Mode to color the Damage Indicator',
		Value = 'Rainbow',
		Function = function() end
	})
	DamageIndicatorMode2 = DamageIndicator.CreateDropdown({
		Name = 'Rainbow Mode',
		List = {
			'Gradient',
			'Paint'
		},
		HoverText = 'Mode to color the Damage Indicator\nwith Rainbow Color Mode',
		Value = 'Gradient',
		Function = function() end
	})
    DamageIndicatorMode1 = DamageIndicator.CreateDropdown({
		Name = 'Text Mode',
		List = {
            'Custom',
			'Multiple',
			'Lunar'
		},
		HoverText = 'Mode to change the Damage Indicator Text',
		Value = 'Custom',
		Function = function() end
	})
	DamageIndicatorColorToggle = DamageIndicator.CreateToggle({
		Name = 'Custom Color',
		Function = function(calling) pcall(function() DamageIndicatorColor.Object.Visible = calling end) end
	})
	DamageIndicatorColor = DamageIndicator.CreateColorSlider({
		Name = 'Text Color',
		Function = function() end
	})
	DamageIndicatorTextToggle = DamageIndicator.CreateToggle({
		Name = 'Custom Text',
		HoverText = 'random messages for the indicator',
		Function = function(calling) pcall(function() DamageIndicatorText.Object.Visible = calling end) end
	})
	DamageIndicatorText = DamageIndicator.CreateTextList({
		Name = 'Text',
		TempText = 'Indicator Text',
		AddFunction = function() end
	})
	DamageIndicatorFontToggle = DamageIndicator.CreateToggle({
		Name = 'Custom Font',
		Function = function(calling) pcall(function() DamageIndicatorFont.Object.Visible = calling end) end
	})
	DamageIndicatorFont = DamageIndicator.CreateDropdown({
		Name = 'Font',
		List = GetEnumItems('Font'),
		Function = function() end
	})
	DamageIndicatorColor.Object.Visible = DamageIndicatorColorToggle.Enabled
	DamageIndicatorText.Object.Visible = DamageIndicatorTextToggle.Enabled
	DamageIndicatorFont.Object.Visible = DamageIndicatorFontToggle.Enabled
end)

runFunction(function() 
	local ViewmodelMods = {}
	local ViewmodelHighlight = {Value = 'Normal'}
	local ViewmodelThird = {}
	local ViewmodelMaterial = {Value = 'SmoothPlastic'}
	local ViewmodelTransparency = {Value = 0}
	local ViewmodelColor = {Hue = 0, Sat = 0, Value = 0}
	local ViewmodelColorToggle = {}
	local ViewmodelAttributes = {}
	local ViewmodelNoBob = {}
	local viewmodelstuff = {}
	local nobobdepth = {Value = 8}
	local nobobhorizontal = {Value = 8}
	local nobobvertical = {Value = -2}
	local rotationx = {Value = 0}
	local rotationy = {Value = 0}
	local rotationz = {Value = 0}
	local oldviewmodelanim
	local oldviewmodelC1
	local updatefuncs = {
		Normal = function(part, original) 
			local highlight = original or Instance.new('Highlight')
			highlight.FillColor = Color3.fromHSV(ViewmodelColor.Hue, ViewmodelColor.Sat, ViewmodelColor.Value)
			highlight.FillTransparency = (ViewmodelTransparency.Value / 85)
			highlight.OutlineTransparency = 1
			highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			highlight.Parent = part
			table.insert(viewmodelstuff, highlight)
			if ViewmodelColorToggle.Enabled then 
				part.TextureID = ''
			    part.Material = Enum.Material[ViewmodelMaterial.Value] 
			end
		end,
		Classic = function(part)
			if ViewmodelColorToggle.Enabled then 
				part.TextureID = ''
				part.Material = Enum.Material[ViewmodelMaterial.Value]
				part.Color = Color3.fromHSV(ViewmodelColor.Hue, ViewmodelColor.Sat, ViewmodelColor.Value)
			end
		end
	}
	local function viewmodelFunction(handle)
		local exist, handle = pcall(function()
			return handle and handle:IsA('Part') and handle or gameCamera.Viewmodel:FindFirstChildWhichIsA('Accessory').Handle
		end)
		if exist then 
			updatefuncs[ViewmodelHighlight.Value](handle, handle:FindFirstChildWhichIsA('Highlight'))
		end
		local exist2, handle2 = pcall(function()
			for i,v in next, lplr.Character:GetChildren() do 
				if v:IsA('Accessory') and v.Name == handle.Parent.Name and v:GetAttribute('InvItem') then 
					return v.Handle
				end
			end
		end)
		if exist2 and handle2 and ViewmodelThird.Enabled and ViewmodelHighlight.Value == 'Classic' then 
			updatefuncs[ViewmodelHighlight.Value](handle2, handle2:FindFirstChildWhichIsA('Highlight'))
		end
	end
	ViewmodelMods = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = 'ViewModelMods',
		HoverText = 'Customize the first person\nviewmodel experience.',
		Function = function(calling)
			if calling then 
				local viewmodel = gameCamera:WaitForChild('Viewmodel')
				viewmodelFunction()
				table.insert(ViewmodelMods.Connections, viewmodel.ChildAdded:Connect(viewmodelFunction)) 
				oldviewmodelanim = bedwars.ViewmodelController.playAnimation 
				bedwars.ViewmodelController.playAnimation = function(self, animid, details)
					if animid == bedwars.AnimationType.FP_WALK and ViewmodelAttributes.Enabled and ViewmodelNoBob.Enabled then 
						return 
					end 
					return oldviewmodelanim(self, animid, details)
				end
				if ViewmodelAttributes.Enabled then 
					lplr.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_DEPTH_OFFSET', -(nobobdepth.Value / 10))
					lplr.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_HORIZONTAL_OFFSET', (nobobhorizontal.Value / 10))
					lplr.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_VERTICAL_OFFSET', (nobobvertical.Value / 10))
					pcall(function() oldviewmodelC1 = viewmodel.RightHand.RightWrist.C1 end)
				end
			else
				if oldviewmodelanim then 
					bedwars.ViewmodelController.playAnimation = oldviewmodelanim 
					oldviewmodelanim = nil
				end
				if oldviewmodelC1 then 
					pcall(function() gameCamera.Viewmodel.RightHand.RightWrist.C1 = oldviewmodelC1 end)
					oldviewmodelC1 = nil
				end
				lplr.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_DEPTH_OFFSET', 0)
				lplr.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_HORIZONTAL_OFFSET', 0)
				lplr.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_VERTICAL_OFFSET', 0)
				for i,v in next, viewmodelstuff do 
					pcall(function() v:Destroy() end) 
				end
				table.clear(viewmodelstuff)
			end
		end
	})
	ViewmodelHighlight = ViewmodelMods.CreateDropdown({
		Name = 'Mode',
		List = {'Normal', 'Classic'},
		Function = function(value)
			pcall(function() ViewmodelThird.Object.Visible = (value ~= 'Normal') end)
			pcall(function() ViewmodelTransparency.Visible = (value ~= 'Classic') end)
			if ViewmodelMods.Enabled then 
				ViewmodelMods.ToggleButton()
				ViewmodelMods.ToggleButton() 
			end
		end
	})
	ViewmodelColorToggle = ViewmodelMods.CreateToggle({
		Name = 'Color',
		Function = function() 
			if ViewmodelMods.Enabled then
			   viewmodelFunction() 
			end
		end
	})
	ViewmodelColor = ViewmodelMods.CreateColorSlider({
		Name = 'Color',
		Function = function() 
			if ViewmodelMods.Enabled then
			   viewmodelFunction() 
			end
		end
	})
	ViewmodelTransparency = ViewmodelMods.CreateSlider({
		Name = 'Transparency',
		Min = 0, 
		Max = 85, 
		Default = 15,
		Function = function() 
			if ViewmodelMods.Enabled then
				viewmodelFunction() 
			 end 
		end
	})
	ViewmodelThird = ViewmodelMods.CreateToggle({
		Name = 'Hand',
		Default = true,
		HoverText = 'Also changes the tool in third person.',
		Function = function() 
			if ViewmodelMods.Enabled then
				viewmodelFunction() 
			 end
		end
	})
	ViewmodelMaterial = ViewmodelMods.CreateDropdown({
		Name = 'Material',
		List = GetEnumItems('Material'),
		Function = function()
			if ViewmodelMods.Enabled then
				viewmodelFunction() 
			 end 
		end
	})
	ViewmodelAttributes = ViewmodelMods.CreateToggle({
		Name = 'Attributes',
		HoverText = 'Size & Rotations for viewmodel.',
		Function = function(calling)
			pcall(function() ViewmodelNoBob.Object.Visible = calling end)
			pcall(function() nobobdepth.Object.Visible = calling end)
			pcall(function() nobobhorizontal.Object.Visible = calling end)
			pcall(function() nobobvertical.Object.Visible = calling end)
			pcall(function() rotationx.Object.Visible = calling end)
			pcall(function() rotationy.Object.Visible = calling end)
			pcall(function() rotationz.Object.Visible = calling end)
			if ViewmodelMods.Enabled then 
				ViewmodelMods.ToggleButton() 
				ViewmodelMods.ToggleButton()
			end
		end
	})
	ViewmodelNoBob = ViewmodelMods.CreateToggle({
		Name = 'No Bobbing',
		HoverText = 'No ugly bobbing.',
		Function = function()
			if ViewmodelMods.Enabled and ViewmodelAttributes.Enabled then 
				ViewmodelMods.ToggleButton() 
				ViewmodelMods.ToggleButton()
			end
		end
	})
	nobobdepth = ViewmodelMods.CreateSlider({
		Name = 'Depth',
		Min = 0,
		Max = 24,
		Default = 8,
		Function = function(val)
			if ViewmodelMods.Enabled and ViewmodelAttributes.Enabled then
				lplr.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_DEPTH_OFFSET', -(val / 10))
			end
		end
	})
	nobobhorizontal = ViewmodelMods.CreateSlider({
		Name = 'Horizontal',
		Min = 0,
		Max = 24,
		Default = 8,
		Function = function(val)
			if ViewmodelMods.Enabled and ViewmodelAttributes.Enabled then
				lplr.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_HORIZONTAL_OFFSET', (val / 10))
			end
		end
	})
	nobobvertical = ViewmodelMods.CreateSlider({
		Name = 'Vertical',
		Min = 0,
		Max = 24,
		Default = -2,
		Function = function(val)
			if ViewmodelMods.Enabled and ViewmodelAttributes.Enabled then
				lplr.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_VERTICAL_OFFSET', (val / 10))
			end
		end
	})
	rotationx = ViewmodelMods.CreateSlider({
		Name = 'RotX',
		Min = 0,
		Max = 360,
		Function = function(val)
			if ViewmodelMods.Enabled and ViewmodelAttributes.Enabled then
				gameCamera.Viewmodel.RightHand.RightWrist.C1 = oldviewmodelC1 * CFrame.Angles(math.rad(rotationx.Value), math.rad(rotationy.Value), math.rad(rotationz.Value))
			end
		end
	})
	rotationy = ViewmodelMods.CreateSlider({
		Name = 'RotY',
		Min = 0,
		Max = 360,
		Function = function(val)
			if ViewmodelMods.Enabled and ViewmodelAttributes.Enabled then
				gameCamera.Viewmodel.RightHand.RightWrist.C1 = oldviewmodelC1 * CFrame.Angles(math.rad(rotationx.Value), math.rad(rotationy.Value), math.rad(rotationz.Value))
			end
		end
	})
	rotationz = ViewmodelMods.CreateSlider({
		Name = 'RotZ',
		Min = 0,
		Max = 360,
		Function = function(val)
			if ViewmodelMods.Enabled and ViewmodelAttributes.Enabled then
				gameCamera.Viewmodel.RightHand.RightWrist.C1 = oldviewmodelC1 * CFrame.Angles(math.rad(rotationx.Value), math.rad(rotationy.Value), math.rad(rotationz.Value))
			end
		end
	})
	ViewmodelNoBob.Object.Visible = false
	nobobdepth.Object.Visible = false
	nobobhorizontal.Object.Visible = false
	nobobvertical.Object.Visible = false
	rotationx.Object.Visible = false
	rotationy.Object.Visible = false
	rotationz.Object.Visible = false
end)

runFunction(function()
	local ProjectileAura = {}
	local ProjectileAuraSort = {Value = 'Distance'}
	local ProjectileAuraMobs = {}
	local ProjectileAuraRangeSlider = {Value = 50}
	local ProjectileAuraRange = {}
	local ProjectileAuraBlacklist = {ObjectList = {}}
	local ProjectileMobIgnore = {'spear'}
	local ProjectileAuraDelay = {Value = 0}
	local ProjectileAuraSwitchDelay = {Value = 0}
	local crackerdelay = tick()
	local specialprojectiles = {
		rainbow_bow = 'rainbow_arrow',
		orions_belt_bow = 'star',
		fireball = 'fireball',
		frosted_snowball = 'frosted_snowball',
		snowball = 'snowball',
		spear = 'spear',
		carrot_cannon = 'carrot_rocket',
		light_sword = 'sword_wave1',
		firecrackers = 'firecrackers'
	}
	local biggestTargets = {
		spirit_assassin = 1,
		hannah = 2,
		melody = 3,
		kaliyah = 4
	}
	local sortfunctions = {
		Distance = function()
			return GetTarget(ProjectileAuraRange.Enabled and ProjectileAuraRangeSlider.Value, nil, true, ProjectileAuraMobs.Enabled)
		end,
		Health = function()
			return GetTarget(nil, true, true, ProjectileAuraMobs.Enabled)
		end,
		Mouse = function()
			return GetTarget(nil, nil, true, ProjectileAuraMobs.Enabled, true, true)
		end, 
		Kit = function() 
			local target, prio = {}, -1
			for i,v in next, GetAllTargets() do
				local kit = (v.Player:GetAttribute('PlayingAsKit') or 'none')
				local kitprio = (biggestTargets[kit] or 0)
				if kitprio > prio then 
					target = v
				end
			end
			if prio < 1 then 
				return GetTarget(nil, nil, true)
			end
			return target
		end
	}
	local function betterswitch(item)
		if tostring(item) == 'firecrackers' then 
			if crackerdelay > tick() then 
				return 
			else 
				crackerdelay = tick() + 3.5 
			end 
		end
		if tick() > bedwarsStore.switchdelay then 
			switchItem(item) 
		end
		local oldval = ProjectileAuraSwitchDelay.Value
		local valdelay = (tick() + ProjectileAuraSwitchDelay.Value)
		repeat task.wait() until (tick() > valdelay or ProjectileAuraSwitchDelay.Value ~= oldval)
	end
	local function getarrow()
		for i,v in next, bedwarsStore.localInventory.inventory.items do  
			if v.itemType:find('arrow') then 
				return v 
			end
		end
	end
	local function getammo(item)
		if (item.itemType:find('bow') or item.itemType:find('headhunter')) and specialprojectiles[item.itemType] == nil then 
			return getarrow() or {} 
		end
		if item.itemType:find('ninja_chakram') then 
			return getItem(item.itemType) 
		end
		if item.itemType == 'light_sword' then 
			return {tool = 'sword_wave1'} 
		end
		local special = specialprojectiles[item.itemType]
		for i,v in next, ProjectileAuraBlacklist.ObjectList do 
			if item.itemType:find(v:lower()) then 
				return {} 
			end 
		end 
		if special then 
			return getItem(special) or {} 
		end
		return {}
	end
	ProjectileAura = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = 'ProjectileAura',
		HoverText = 'Automatically shoots hostile projectiles\nwithout aiming.',
		Function = function(calling)
			if calling then 
				repeat 
					local range = (ProjectileAuraRange.Enabled and ProjectileAuraRangeSlider.Value or 9e9)
					local target = sortfunctions[ProjectileAuraSort.Value]()
					if target.RootPart and target.RootPart.Parent:FindFirstChildWhichIsA('ForceField') == nil then 
						for i,v in next, bedwarsStore.localInventory.inventory.items do 
							local ammo = getammo(v)
							if target.Human == nil and table.find(ProjectileMobIgnore, v.itemType) or tweenInProgress() then 
								continue 
							end 
							if bedwarsStore.matchState ~= 0 and bedwarsStore.equippedKit == 'dragon_sword' then 
								bedwars.ClientHandler:Get('DragonSwordFire'):SendToServer({target = target.RootPart.Parent}) 
							end
							if ammo.tool then 
								betterswitch(v.tool)
								bedwars.ClientHandler:Get(bedwars.ProjectileRemote):CallServerAsync(v.tool, tostring(ammo.tool), tostring(ammo.tool) == 'star' and 'star_projectile' or tostring(ammo.tool) == 'mage_spell_base' and target.RootPart.Position + Vector3.new(0, 3, 0) or tostring(ammo.tool), target.RootPart.Position + Vector3.new(0, 3, 0), target.RootPart.Position + Vector3.new(0, 3, 0), Vector3.new(0, -1, 0), httpService:GenerateGUID(), {drawDurationSeconds = 1}, workspace:GetServerTimeNow(), target)
							end
						end
					end
					bedwarsStore.switchdelay += (ProjectileAuraDelay.Value * 0.2)
					if RenderStore.ping > 1000 then 
						bedwarsStore.switchdelay += (bedwarsStore.switchdelay + 8)
					end
					task.wait(getItem('star') and 0 or killauraNearPlayer and 0.25 or ProjectileAuraDelay.Value + 0.15)
				until not ProjectileAura.Enabled
			end
		end
	})
	ProjectileAuraBlacklist = ProjectileAura.CreateTextList({
		Name = 'Blacklisted Projectiles',
		TempText = 'blacklisted items',
		AddFunction = function() end
	})
	ProjectileAuraSort = ProjectileAura.CreateDropdown({
		Name = 'Sort',
		List = dumptable(sortfunctions, 1),
		Function = function(method)
			pcall(function() ProjectileAuraRange.Object.Visible = (method == 'Distance') end) 
			pcall(function() ProjectileAuraRangeSlider.Object.Visible = (method == 'Distance' and ProjectileAuraRange.Enabled) end) 
			pcall(function() ProjectileAuraMobs.Object.Visible = (method ~= 'Kit') end)
		end
	})
	ProjectileAuraDelay = ProjectileAura.CreateSlider({
		Name = 'Target Delay',
		Min = 0,
		Max = 60,
		Function = function() 
			bedwarsStore.switchdelay = tick() 
		end
	})
	ProjectileAuraSwitchDelay = ProjectileAura.CreateSlider({
		Name = 'Switch Delay',
		Min = 0,
		Max = 60,
		Function = function() 
			bedwarsStore.switchdelay = tick() 
		end
	})
	ProjectileAuraRange = ProjectileAura.CreateToggle({
		Name = 'Range Check',
		Function = function(calling) 
			pcall(function() ProjectileAuraRangeSlider.Object.Visible = calling end)
		end 
	}) 
	ProjectileAuraRangeSlider = ProjectileAura.CreateSlider({
		Name = 'Range',
		Min = 5,
		Max = 80,
		Default = 75,
		Function = function() end
	})
	ProjectileAuraMobs = ProjectileAura.CreateToggle({
		Name = 'NPC',
		HoverText = 'Targets NPCs too.',
		Function = function() end 
	})
	ProjectileAuraRange.Object.Visible = false
	ProjectileAuraRangeSlider.Object.Visible = false
	ProjectileAuraMobs.Object.Visible = false
end)

runFunction(function()
	local AutoRewind = {}
	local deathtween
	local deathposition 
	AutoRewind = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'AutoRewind',
		HoverText = 'Automatically teleports you to\nthe position you died whenever you respawn.',
		Function = function(calling)
			if calling then 
				table.insert(AutoRewind.Connections, lplr.CharacterAdded:Connect(function()
					local cachedpos = deathposition
					repeat task.wait() until isAlive(lplr, true) 
					task.wait(0.1)
					if tweenInProgress() or not cachedpos then return end
					local speed = getTweenSpeed({Position = cachedpos})
					deathtween = tweenService:Create(lplr.Character.HumanoidRootPart, TweenInfo.new(speed / 2, Enum.EasingStyle.Linear), {CFrame = CFrame.new(cachedpos)})
					deathtween:Play()
					deathtween.Completed:Wait()
					deathtween = nil
				end))
				table.insert(AutoRewind.Connections, runService.Heartbeat:Connect(function()
					if isAlive() and bedwarsStore.matchState ~= 0 and not deathtween then 
						local block = (gethighestblock(lplr.Character.HumanoidRootPart.Position, true) or playerRaycasted() or {}).Instance
						if block then 
							deathposition = (block.Position + Vector3.new(0, 5, 0))
						end 
					end
				end))
			else
				pcall(function() deathtween:Cancel() end) 
				deathtween = nil
			end
		end
	})
end)

--[[runFunction(function()
	local ConfettiExploit = {}
	local ConfettiDelay = {Value = 10}
	local confettiTick = tick()
	ConfettiExploit = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = 'ConfettiExploit',
		HoverText = 'annoying ong',
		Function = function(calling)
			if calling then 
				repeat 
					local allowed = (isEnabled('Lobby Check', 'Toggle') and bedwarsStore.matchState ~= 0 or not isEnabled('Lobby Check', 'Toggle'))
					if tick() > confettiTick and bedwars.AbilityController:canUseAbility('PARTY_POPPER') and allowed and isAlive() and RenderStore.ping < 800 then 
						bedwars.AbilityController:useAbility('PARTY_POPPER')
						confettiTick = tick() + (ConfettiDelay.Value / 15)
					end
					task.wait()
				until not ConfettiExploit.Enabled
			end
		end
	})
	ConfettiDelay = ConfettiExploit.CreateSlider({
		Name = 'Delay',
		Min = 10,
		Max = 300,
		Function = function()
			confettiTick = tick()
		end
	})
end)]]

--[[runFunction(function()
	local DragonExploit = {}
	local DragonBreatheDelay = {Value = 10}
	local breatheTick = tick()
	DragonExploit = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = 'DragonExploit',
		HoverText = 'Yet another "useful" module.',
		Function = function(calling)
			if calling then 
				repeat 
					local allowed = (isEnabled('Lobby Check', 'Toggle') and bedwarsStore.matchState ~= 0 or not isEnabled('Lobby Check', 'Toggle'))
					if tick() > breatheTick and allowed and isAlive() and RenderStore.ping < 800 then 
						bedwars.ClientHandler:Get('DragonBreath'):SendToServer({player = lplr}) 
						breatheTick = (tick() + ((DragonBreatheDelay.Value / 15) + 1))
					end
					task.wait()
				until not DragonExploit.Enabled
			end
		end
	})
	DragonBreatheDelay = DragonExploit.CreateSlider({
		Name = 'Delay',
		Min = 10,
		Max = 300,
		Function = function()
			breatheTick = tick()
		end
	})
end)]]

--[[runFunction(function()
	local TerraExploit = {}
	local TerraDelay = {Value = 10}
	local TerraTick = tick()
	TerraExploit = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = 'TerraExploit',
		HoverText = 'annoying ong',
		Function = function(calling)
			if calling then 
				repeat 
					local allowed = (isEnabled('Lobby Check', 'Toggle') and bedwarsStore.matchState ~= 0 or not isEnabled('Lobby Check', 'Toggle'))
					if tick() > TerraTick and bedwars.AbilityController:canUseAbility('BLOCK_KICK') and allowed and isAlive() and RenderStore.ping < 800 and not isEnabled('BedTP') then 
						bedwars.AbilityController:useAbility('BLOCK_KICK')
						TerraTick = tick() + (TerraDelay.Value / 15)
					end
					task.wait()
				until not TerraExploit.Enabled
			end
		end
	})
	TerraDelay = TerraExploit.CreateSlider({
		Name = 'Delay',
		Min = 1,
		Max = 300,
		Function = function()
			TerraTick = tick()
		end
	})
end)]]



runFunction(function() 
	local JoinQueue = {}
	local queuetojoin = {Value = ''}
	local function dumpmeta()
		local queuemeta = {}
		for i,v in next, bedwars.QueueMeta do 
			if v.title ~= 'Sandbox' and not v.disabled then 
				table.insert(queuemeta, v.title) 
			end 
		end 
		return queuemeta
	end
	JoinQueue = GuiLibrary.ObjectsThatCanBeSaved.MatchmakingWindow.Api.CreateOptionsButton({
		Name = 'JoinQueue',
		NoSave = true,
		HoverText = 'Starts a match for the provided gamemode.',
		Function = function(calling)
			if calling then 
				for i,v in next, bedwars.QueueMeta do 
					if v.title == queuetojoin.Value then 
						replicatedStorageService['events-@easy-games/lobby:shared/event/lobby-events@getEvents.Events'].leaveQueue:FireServer()
						task.wait(0.1)
						bedwars.LobbyClientEvents:joinQueue(i) 
						break
					end
				end
				JoinQueue.ToggleButton()
			end
		end
	})
	queuetojoin = JoinQueue.CreateDropdown({
		Name = 'QueueType',
		List = dumpmeta(),
		Function = function() end
	})
	task.spawn(function()
		repeat task.wait() until shared.VapeFullyLoaded 
		for i,v in next, bedwars.QueueMeta do 
			if i == bedwarsStore.queueType then 
				queuetojoin.SetValue(v.title) 
			end
		end
	end)
end)

runLunar(function()
	local RemotesConnect = {}
	local RemotesConnectDelay = {Value = 10}
	local RemotesConnectParty = {}
	local RemotesConnectDragon = {}
    local RemotesConnectTerra = {}
	local remotedelay = tick()
	RemotesConnect = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'RemotesConnect',
        HoverText = 'Spams bedwars remotes',
		Function = function(callback)
			if callback then
				repeat 
					if tick() >= remotedelay and RenderStore.ping < 600 then 
						if RemotesConnectParty.Enabled and bedwars.AbilityController:canUseAbility('PARTY_POPPER') then 
							bedwars.AbilityController:useAbility('PARTY_POPPER') 
						end
						if RemotesConnectDragon.Enabled then 
							bedwars.ClientHandler:Get('DragonBreath'):SendToServer({player = lplr})
						end
						if RemotesConnectTerra.Enabled and bedwars.CooldownController:getRemainingCooldown('BLOCK_KICK') == 0 then 
							bedwars.AbilityController:useAbility('BLOCK_KICK') 
						end
						remotedelay = (tick() + (30 / RemotesConnectDelay.Value))
					end 
					task.wait()
				until not RemotesConnect.Enabled
			end
		end
	})
	RemotesConnectDelay = RemotesConnect.CreateSlider({
		Name = 'Delay',
		Min = 0,
		Max = 50,
		Default = 10,
		HoverText = 'Delay to Spam the Remotes',
		Function = function(val) 
			remotedelay = tick() 
		end,
	})
	RemotesConnectParty = RemotesConnect.CreateToggle({
		Name = 'Party Popper',
		Default = true,
		HoverText = 'Spams the Party Popper Remote',
		Function = function() end
	})
	RemotesConnectDragon = RemotesConnect.CreateToggle({
		Name = 'Dragon',
		Default = true,
		HoverText = 'Spams the Dragon Breath Remote',
		Function = function() end
	})
    RemotesConnectTerra = RemotesConnect.CreateToggle({
		Name = 'Terra',
		Default = true,
		HoverText = 'Spams the Terra Block Kick Remote',
		Function = function() end
	})
end)

runLunar(function()
	local NoKillFeed = {}
	NoKillFeed = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = 'NoKillFeed',
        HoverText = 'Removes the Kill Feed',
		Function = function(callback)
			if callback then
				pcall(function()
					lplr.PlayerGui.KillFeedGui.Parent = workspace
				end)
			else
				workspace.KillFeedGui.Parent = lplr.PlayerGui
			end
		end,
        Default = false
	})
end)

runLunar(function()
	local Clipper = {}
	local ClipperMode = {Value = 'Low'}
	local ClipperCF = {Value = 10}
	local ClipperNotify1 = {Value = 2}
	local ClipperNotify = {}
	local ClipperTP = {}
	local function ClipperOff()
		Clipper.ToggleButton(false)
		return
	end
	local function ClipTP()
		if ClipperMode.Value == 'Low' then
			entityLibrary.character.HumanoidRootPart.CFrame -= vec3(0, ClipperCF.Value, 0)
		else
			entityLibrary.character.HumanoidRootPart.CFrame += vec3(0, ClipperCF.Value, 0)
		end
		if ClipperNotify.Enabled then
			warningNotification2('Clipper', 'Teleported '..ClipperCF.Value..' studs', ClipperNotify1.Value)
		end
		ClipperOff()
	end
	Clipper = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = 'Clipper',
        HoverText = 'Teleports your CFrame',
		Function = function(callback)
			if callback then
				task.spawn(function()
					if entityLibrary.isAlive then
						local TPPos
						if ClipperMode.Value == 'Low' then
							TPPos = entityLibrary.character.HumanoidRootPart.Position - vec3(0, ClipperCF.Value, 0)
						else
							TPPos = entityLibrary.character.HumanoidRootPart.Position + vec3(0, ClipperCF.Value, 0)
						end
						if ClipperTP.Enabled then
							ClipTP()
						else
							if getPlacedBlock(TPPos) == nil then
								ClipTP()
							else
								if ClipperNotify.Enabled then
									warningNotification2('Clipper', 'Disabled to prevent suffocation', ClipperNotify1.Value)
								end
								ClipperOff()
							end
						end
					end
				end)
			end
		end,
        Default = false,
        ExtraText = function()
            return ClipperMode.Value
        end
	})
	ClipperMode = Clipper.CreateDropdown({
		Name = 'Mode',
		List = {
			'Low',
			'High'
		},
		HoverText = 'Mode to TP',
		Value = 'Low',
		Function = function() end
	})
	ClipperCF = Clipper.CreateSlider({
		Name = 'CFrame',
		Min = 1,
		Max = 100,
		HoverText = 'CFrame TP Amount',
		Function = function() end,
		Default = 10
	})
	ClipperNotify1 = Clipper.CreateSlider({
		Name = 'Notification Duration',
		Min = 1,
		Max = 10,
		HoverText = 'Duration of the Notification',
		Function = function() end,
		Default = 2
	})
	ClipperNotify = Clipper.CreateToggle({
		Name = 'Notification',
		Default = true,
		HoverText = 'Notifies you when certain actions happen',
		Function = function() end
	})
	ClipperTP = Clipper.CreateToggle({
		Name = 'Teleport Anyways',
		Default = false,
		HoverText = 'Teleports anyways even if you have\na change of getting suffocated',
		Function = function() end
	})
end)

runLunar(function()
	local function modulescheck()
		if isEnabled('InfiniteFly') or isEnabled('LunarBoost') or isEnabled('LunarFly') then
			return true
		end
	end
	local GravityModule = {}
	local GravityValue = {Value = 100}
	GravityModule = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "Gravity",
		HoverText = "Modifies the Gravity",
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat task.wait()
						if modulescheck() == nil then
							workspace.Gravity = GravityValue.Value
						end
					until not GravityModule.Enabled
				end)
			else
				workspace.Gravity = 196.2
			end
		end
	})
	GravityValue = GravityModule.CreateSlider({
		Name = "Gravity",
		Min = 0,
		Max = 196,
		Default = 100,
		Function = function(val) end
	})
end)

runLunar(function()	
	TagEraser = GuiLibrary["ObjectsThatCanBeSaved"]["UtilityWindow"]["Api"]["CreateOptionsButton"]({
		Name = 'TagEraser',
        HoverText = 'Removes your nametag',
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat task.wait()
						pcall(function() lplr.Character.Head.Nametag:Destroy() end)
					until not TagEraser.Enabled
				end)
			end
		end,
        Default = false
	})
end)

pcall(function()
    local texturepack = {}
	local packDropdown = {Value = "Melo Pack"}

	local ogpackloader = game:GetObjects("rbxassetid://14027120450")
	local ogtxtpack = ogpackloader[1]
	ogtxtpack.Name = "OG Pack"
	ogtxtpack.Parent = replicatedStorageService
	task.wait()
	local melopackloader = game:GetObjects("rbxassetid://14774202839")
	local melotxtpack = melopackloader[1]
	melotxtpack.Name = "Melo's Pack"
	melotxtpack.Parent = replicatedStorageService
	task.wait()
	local azzapackloader = game:GetObjects("rbxassetid://14803122185")
	local azzatxtpack = azzapackloader[1]
	azzatxtpack.Name = "4zze's Pack"
	azzatxtpack.Parent = replicatedStorageService
	local viewmodelCon
	local textures = {
		["OG Pack"] = ogtxtpack,
		["Melo's Pack"] = melotxtpack,
		["4zze's Pack"] = azzatxtpack
	}

	local function refreshViewmodel(child)
		for i,v in next, (textures[packDropdown.Value]:GetChildren()) do
			if string.lower(v.Name) == child.Name and child.Parent.Name ~= child.Name then
				-- first person viewmodel check
				for i1,v1 in next, (child:GetDescendants()) do
					if v1:IsA("Part") or v1:IsA("MeshPart") then
						v1.Transparency = 1
					end
				end
				-- third person viewmodel check
				for i1,v1 in next, (game.Players.LocalPlayer.Character:GetChildren()) do
					if v1.Name == string.lower(v.Name) then
						for i2,v2 in next, (v1:GetDescendants()) do
							if v2.Name ~= child.Name then
								if v2:IsA("Part") or v2:IsA("MeshPart") then
									v2.Transparency = 1
									v2:GetPropertyChangedSignal("Transparency"):Connect(function()
										v2.Transparency = 1
									end)
								end
							end
						end
					end
				end
				-- first person txtpack renderer
				local vmmodel = v:Clone()
				vmmodel.CFrame = child.Handle.CFrame 
				vmmodel.CFrame = vmmodel.CFrame * (packDropdown.Value == "OG Pack" and CFrame.new(0, -0.2, 0) or packDropdown.Value == "Melo's Pack" and CFrame.new(0.2, -0.2, 0) or packDropdown.Value == "4zze's Pack" and CFrame.new(0.8,0.1,0.7)) * CFrame.Angles(math.rad(90),math.rad(-130),math.rad(0))
				if string.lower(child.Name) == "rageblade" then vmmodel.CFrame = vmmodel.CFrame * CFrame.Angles(math.rad(-180),math.rad(100),math.rad(0)) end
				if string.lower(child.Name):find("pickaxe") then vmmodel.CFrame = vmmodel.CFrame * CFrame.Angles(math.rad(-55),math.rad(-30),math.rad(50)) end
				if string.lower(child.Name):find("scythe") then vmmodel.CFrame = vmmodel.CFrame * CFrame.Angles(math.rad(-65),math.rad(-80),math.rad(100)) * CFrame.new(-2.8,0.4,-0.8) end
				if (string.lower(child.Name):find("axe")) and not (string.lower(child.Name):find("pickaxe")) then vmmodel.CFrame = vmmodel.CFrame * CFrame.Angles(math.rad(-55),math.rad(-30),math.rad(50)) * (packDropdown.Value == "Melo's Pack" and CFrame.new(-0.2,0,0.2) or packDropdown.Value == "4zze's Pack" and CFrame.new(-1.5,0,-0.8)) end
				vmmodel.Parent = child
				local vmmodelweld = Instance.new("WeldConstraint",vmmodel)
				vmmodelweld.Part0 = vmmodelweld.Parent
				vmmodelweld.Part1 = child.Handle
				-- third person txtpack renderer
				local charmodel = v:Clone()
				charmodel.CFrame = game.Players.LocalPlayer.Character[child.Name]:FindFirstChild("Handle").CFrame
				charmodel.CFrame = charmodel.CFrame * (packDropdown.Value == "OG Pack" and CFrame.new(0, -0.5, 0) or packDropdown.Value == "Melo's Pack" and CFrame.new(0.2, -0.9, 0) or packDropdown.Value == "4zze's Pack" and CFrame.new(0.1,-1.2,0)) * CFrame.Angles(math.rad(90),math.rad(-130),math.rad(0))
				if string.lower(child.Name) == "rageblade" then charmodel.CFrame = charmodel.CFrame * CFrame.Angles(math.rad(-180),math.rad(100),math.rad(0)) * CFrame.new(0.8,0,-1.1) end
				if string.lower(child.Name):find("pickaxe") then charmodel.CFrame = charmodel.CFrame * CFrame.Angles(math.rad(-55),math.rad(-30),math.rad(50)) * CFrame.new(-0.8,-0.2,1.1) end
				if string.lower(child.Name):find("scythe") then charmodel.CFrame = charmodel.CFrame * CFrame.Angles(math.rad(-65),math.rad(-80),math.rad(100)) * CFrame.new(-1.8,-0.5,0) end
				if (string.lower(child.Name):find("axe")) and not (string.lower(child.Name):find("pickaxe")) then charmodel.CFrame = charmodel.CFrame * CFrame.Angles(math.rad(-55),math.rad(-30),math.rad(50)) * CFrame.new(-1.4,-0.2,0.6) end
				charmodel.Anchored = false
				charmodel.CanCollide = false
				charmodel.Parent = game.Players.LocalPlayer.Character[child.Name]
				local charmodelweld = Instance.new("WeldConstraint",charmodel)
				charmodelweld.Part0 = charmodelweld.Parent
				charmodelweld.Part1 = game.Players.LocalPlayer.Character[child.Name].Handle
			end
		end
	end

	texturepack = GuiLibrary["ObjectsThatCanBeSaved"]["RenderWindow"]["Api"]["CreateOptionsButton"]({
        Name = "TexturePack",
        HoverText = "Modifies your renderer",
        Function = function(callback)
            if callback then
				if gameCamera.Viewmodel:FindFirstChildWhichIsA("Accessory") then refreshViewmodel(gameCamera.Viewmodel:FindFirstChildWhichIsA("Accessory")) end
				viewmodelCon = workspace.Camera.Viewmodel.ChildAdded:Connect(function(child)
					refreshViewmodel(child)
				end)
            else
                if viewmodelCon then pcall(function() viewmodelCon:Disconnect() end) end
            end
        end,
		ExtraText = function()
            return packDropdown.Value
        end
    })
	packDropdown = texturepack.CreateDropdown({
		Name = "Texture",
		List = {"OG Pack","Melo's Pack","4zze's Pack"},
		Function = function(val) end
	})
end)

runLunar(function()
	local CustomClouds = {}
	local Clouds = {}
	local CustomCloudsColor = {
		Hue = 1,
		Sat = 0,
		Value = 1
	}
	local CloudTransparency = {Value = 0}
	local CustomCloudsNeon = {}
	CustomClouds = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "CustomClouds",
        HoverText = "Customizes the clouds",
		Function = function(callback)
			if callback then
				task.spawn(function()
					Clouds = workspace:WaitForChild('Clouds'):GetChildren()
					for i,v in next, (Clouds) do
						if v:IsA("Part") then
							v.Transparency = CloudTransparency.Value / 100
							v.Color = Color3.fromHSV(CustomCloudsColor.Hue, CustomCloudsColor.Sat, CustomCloudsColor.Value)
							if CustomCloudsNeon.Enabled then 
								v.Material = Enum.Material.Neon
							else
								v.Material = Enum.Material.SmoothPlastic
							end
						end
					end
				end)
			else
				task.spawn(function()
					for i,v in next, (Clouds) do
						if v:IsA("Part") then
							v.Transparency = 0
							v.Color = Color3.fromRGB(255, 255, 255)
							v.Material = Enum.Material.SmoothPlastic
						end
					end
				end)
			end
		end
	})
	CustomCloudsColor = CustomClouds.CreateColorSlider({
		Name = "Color",
		Function = function(h,s,v)
			if CustomClouds.Enabled then
				task.spawn(function()
					for i,v in next, (Clouds) do
						if v:IsA("Part") then
							v.Transparency = CloudTransparency.Value / 100
							v.Color = Color3.fromHSV(CustomCloudsColor.Hue,CustomCloudsColor.Sat,CustomCloudsColor.Value)
							if CustomCloudsNeon.Enabled then 
								v.Material = Enum.Material.Neon
							else
								v.Material = Enum.Material.SmoothPlastic
							end
						end
					end
				end)
			end
		end,
	})
	CloudTransparency = CustomClouds.CreateSlider({
		Name = "Cloud Transparency",
		Min = 0,
		Max = 100,
		Double = 100,
		Function = function(val)
			if CustomClouds.Enabled then
				task.spawn(function()
					for i,v in next, (Clouds) do
						if v:IsA("Part") then
							v.Transparency = val / 100
							v.Color = Color3.fromHSV(CustomCloudsColor.Hue,CustomCloudsColor.Sat,CustomCloudsColor.Value)
							if CustomCloudsNeon.Enabled then 
								v.Material = Enum.Material.Neon
							else
								v.Material = Enum.Material.SmoothPlastic
							end
						end
					end
				end)
			end
		end
	})
	CustomCloudsNeon = CustomClouds.CreateToggle({
		Name = "Neon",
		Function = function(callback)
			if CustomClouds.Enabled then
				task.spawn(function()
					for i,v in next, (Clouds) do
						if v:IsA("Part") then
							v.Transparency = CloudTransparency.Value / 100
							v.Color = Color3.fromHSV(CustomCloudsColor.Hue, CustomCloudsColor.Sat, CustomCloudsColor.Value)
							if callback then 
								v.Material = Enum.Material.Neon
							else
								v.Material = Enum.Material.SmoothPlastic
							end
						end
					end
				end)
			end
		end,
	})
end)

runFunction(function() 
	local Invisibility = {}
	local collideparts = {}
	local invisvisual = {}
	local visualrootcolor = {Hue = 0, Sat = 0, Sat = 0}
	local oldcamoffset = Vector3.zero
	local oldcolor
	Invisibility = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = 'Invisibility',
		HoverText = 'Makes your invisible.',
		Function = function(calling)
			if calling then 
				repeat task.wait() until ((isAlive(lplr, true) or not Invisibility.Enabled) and (isEnabled('Lobby Check', 'Toggle') == false or bedwars.matchState ~= 0))
				if not Invisibility.Enabled then 
					return 
				end
				task.wait(0.5)
				local anim = Instance.new('Animation')
				anim.AnimationId = 'rbxassetid://11335949902'
				local anim2 = lplr.Character.Humanoid.Animator:LoadAnimation(anim) 
				for i,v in next, lplr.Character:GetDescendants() do 
					if v:IsA('BasePart') and v.CanCollide and v ~= lplr.Character.HumanoidRootPart then 
						v.CanCollide = false 
						table.insert(collideparts, v) 
					end 
				end
				table.insert(Invisibility.Connections, runService.Stepped:Connect(function()
					for i,v in next, collideparts do 
						pcall(function() v.CanCollide = false end)
					end
				end))
				repeat 
					if isEnabled('AnimationPlayer') then 
						GuiLibrary.ObjectsThatCanBeSaved.AnimationPlayerOptionsButton.Api.ToggleButton()
					end
					if isAlive(lplr, true) and isnetworkowner(lplr.Character.HumanoidRootPart) then 
						lplr.Character.HumanoidRootPart.Transparency = (invisvisual.Enabled and 0.6 or 1)
						oldcolor = lplr.Character.HumanoidRootPart.Color
						lplr.Character.HumanoidRootPart.Color = Color3.fromHSV(visualrootcolor.Hue, visualrootcolor.Sat, visualrootcolor.Value)
						anim2:Play(0.000001, 9e9, 0.000001) 
					else 
						if Invisibility.Enabled then 
							Invisibility.ToggleButton() 
							Invisibility.ToggleButton()
							break 
						end
					end	
					task.wait()
				until not Invisibility.Enabled
			else
				for i,v in next, collideparts do 
					pcall(function() v.CanCollide = true end) 
				end
				table.clear(collideparts)
				if isAlive(lplr, true) then 
					lplr.Character.HumanoidRootPart.Transparency = 1 
					lplr.Character.HumanoidRootPart.Color = oldcolor
					task.wait()
				    bedwars.SwordController:swingSwordAtMouse() 
				end
			end
		end
	})
	invisvisual = Invisibility.CreateToggle({
		Name = 'Show Root',
		Function = function(calling)
			pcall(function() visualrootcolor.Object.Visible = calling end) 
		end
	})
	visualrootcolor = Invisibility.CreateColorSlider({
		Name = 'Root Color',
		Function = function() end
	})
	visualrootcolor.Object.Visible = false
end)

runFunction(function()
	local Autowin = {}
	local AutowinWL = {}
	local autowinwhitelisted = {ObjectList = {}}
	local noreset
	local function matchqueue(id)
		for i,v in next, bedwars.QueueMeta do 
			if v.title:lower():find(id:lower()) or i:lower():find(id:lower()) then 
				return i
			end
		end
	end
	local function bedTeleport()
		repeat task.wait() until isAlive(lplr, true)
		local bed = getEnemyBed(nil, true, true)
		local realbed = getEnemyBed()
		local bedtween = tweenService:Create(lplr.Character.HumanoidRootPart, TweenInfo.new(0.49, Enum.EasingStyle.Linear), {CFrame = bed.CFrame + Vector3.new(0, 5, 0)})
		bedtween:Play()
		bedtween.Completed:Wait() 
		task.wait(1)
		if isAlive(lplr, true) and (lplr.Character.HumanoidRootPart.Position - bed.Position).Magnitude > 20 then 
			return
		end
		repeat task.wait() until (not isAlive(lplr, true) or getEnemyBed() ~= realbed or (realbed:GetAttribute('BedShieldEndTime') or 1) > workspace:GetServerTimeNow() or not Autowin.Enabled or not isnetworkowner(lplr.Character.HumanoidRootPart))
		if isAlive(lplr, true) and isnetworkowner(lplr.Character.HumanoidRootPart) then 
			noreset = GetTarget(45, nil, true).RootPart 
		end
	end
	local function playerTeleport()
		local target = GetTarget(nil, nil, true)
		local first
		repeat 
			if isAlive(lplr, true) then 
				target = GetTarget(first and 50, nil, true)
				if target.RootPart == nil then 
					break 
				end
				local localspeed = (first and getTweenSpeed(target.RootPart) or 0.49)
				local playertween = tweenService:Create(lplr.Character.HumanoidRootPart, TweenInfo.new(localspeed, Enum.EasingStyle.Linear), {CFrame = target.RootPart.CFrame})
				playertween:Play()
				target = GetTarget(first and 50, nil, true)
				if not first then 
					first = true
					playertween.Completed:Wait()
				end 
			end 
			task.wait()
		until (not isAlive(lplr, true) or target.RootPart == nil or not Autowin.Enabled or not isnetworkowner(lplr.Character.HumanoidRootPart))
	end
	local function deathFunction()
		if Autowin.Enabled and isAlive(lplr, true) and not noreset then 
			lplr.Character.Humanoid:TakeDamage(lplr.Character.Humanoid.Health)
			lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
		end
		repeat task.wait() until isAlive()
	end
	Autowin = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = 'Autowin',
		HoverText = 'Automatically plays the game lol. (currently buggy atm)',
		Function = function(calling)
			if calling then
				repeat task.wait() until bedwarsStore.matchState ~= 0 or not Autowin.Enabled 
				if bedwarsStore.queueType:find('bedwars') == nil and bedwarsStore.queueType:find('winstreak') == nil and Autowin.Enabled then 
					return
				end
				if AutowinWL.Enabled then 
					local queueallowed
					for i,v in next, autowinwhitelisted.ObjectList do 
						if bedwarsStore.queueType == matchqueue(v) then 
							queueallowed = true 
						end
					end
					if not queueallowed then 
						return 
					end
				end
				if not Autowin.Enabled then return end
				bedwarsStore.autowinning = true
				repeat 
					if getEnemyBed(nil, true, true) then 
						deathFunction()
						bedTeleport()
					else
						deathFunction()
						playerTeleport()
					end 
					task.wait()
				until not Autowin.Enabled
			else
				bedwarsStore.autowinning = nil
			end
		end
	})
	AutowinWL = Autowin.CreateToggle({
		Name = 'Whitelist',
		HoverText = 'Only runs in whitelisted gamemodes.',
		Function = function(calling) 
			pcall(function() autowinwhitelisted.Object.Visible = calling end)
		end
	})
	autowinwhitelisted = Autowin.CreateTextList({
		Name = 'Gamemodes Allowed',
		TempText = 'gamemodes',
		AddFunction = function() end,
		RemoveFunction = function() end
	})
	autowinwhitelisted.Object.Visible = false
end)

