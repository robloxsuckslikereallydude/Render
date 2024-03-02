return (function(ria) 
	local lplr = game:GetService('Players').LocalPlayer 
	local tween = game:GetService('TweenService')
	local httpservice = game:GetService('HttpService')
	local camera = (workspace.CurrentCamera or workspace:FindFirstChildWhichIsA('Camera') or Instance.new('Camera'))
	local gui = Instance.new('ScreenGui', lplr.PlayerGui)
	local renderinstaller = gui 
	local stepcount = 0
	local steps = {}
	local titles = {}
	local httprequest = (request and http and http.request or http_request or fluxus and fluxus.request)
	local executor = (identifyexecutor and identifyexecutor() or getexecutorname and getexecutorname() or 'your executor'):lower()
	local installing
	local activated
	local installed
	local yielding
	
	if getgenv and getgenv().renderinstaller then 
		return 
	end
	
	local function betterclone(tab)
		local newtable = table.clone(tab) 
		for i,v in next, newtable do 
			if type(v) == 'table' then 
				newtable[i] = table.clone(v) 
			end 
		end
		return newtable
	end
	
	if getgenv then 
		getgenv().shared = (shared or betterclone(_G)) 
	end
	
	gui.ResetOnSpawn = false 
	gui.IgnoreGuiInset = true 
	
	gui.ResetOnSpawn = false 
	gui.IgnoreGuiInset = true 
	
	local mainframe = Instance.new('Frame', gui)
	mainframe.Name = 'InstallerBackground'
	mainframe.Size = UDim2.new(1, 0, 1, 0)
	mainframe.BackgroundColor3 = Color3.fromRGB(6, 0, 17)
	mainframe.Visible = false
	mainframe.ZIndex = 9e9
	mainframe.Active = true
	mainframe.Draggable = true
	
	local progressbar = Instance.new('Frame', mainframe)
	progressbar.Name = 'Progressbar'
	progressbar.Position = UDim2.new(0.253, 0, 0.522, 0)
	progressbar.Size = UDim2.new(0.552, 0, 0.021, 0)
	progressbar.ZIndex = (mainframe.ZIndex + 1)
	progressbar.BackgroundColor3 = Color3.fromRGB(28, 4, 70)
	
	local progressbarmain = progressbar:Clone()
	progressbarmain.Name = 'ProgressbarBK'
	progressbarmain.ZIndex = (progressbarmain.ZIndex + 2)
	progressbarmain.Parent = mainframe
	progressbarmain.BackgroundColor3 = Color3.fromRGB(30, 6, 130)
	
	local renderlogo = Instance.new('ImageButton', mainframe)
	renderlogo.Name = 'RenderLogo'
	renderlogo.Image = 'rbxassetid://15688086520'
	renderlogo.Position = UDim2.new(0.405, 0, 0.154, 0)
	renderlogo.Size = UDim2.new(0.208, 0, 0.38, 0)
	renderlogo.BackgroundTransparency = 1
	renderlogo.ZIndex = (mainframe.ZIndex + 1)
	
	local progresstext = Instance.new('TextLabel', mainframe)
	progresstext.Name = 'ProgressText'
	progresstext.TextSize = 35
	progresstext.ZIndex = (mainframe.ZIndex + 1)
	progresstext.BackgroundTransparency = 1
	progresstext.Position = UDim2.new(0.424, 0, 0.576, 0)
	progresstext.TextColor3 = Color3.fromRGB(255, 255, 255)
	progresstext.Size = UDim2.new(0.178, 0, 0.063, 0)
	progresstext.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Bold)
	progresstext.Text = ''
	
	local timetext = progresstext:Clone()
	timetext.Name = 'TimeText'
	timetext.Parent = mainframe
	timetext.TextSize = 20 
	timetext.Size = UDim2.new(0.178, 0, 0.063, 0)
	timetext.Position = UDim2.new(0.424, 0, 0.638, 0)
	
	local actionbutton = Instance.new('TextButton', mainframe)
	actionbutton.Name = 'ActionButton'
	actionbutton.Text = 'Cancel'
	actionbutton.AutoButtonColor = false 
	actionbutton.BackgroundColor3 = Color3.fromRGB(49, 0, 147)
	actionbutton.TextSize = 20
	actionbutton.TextColor3 = Color3.fromRGB(255, 255, 255)
	actionbutton.FontFace = Font.new('rbxasset://fonts/families/SourceSansPro.json', Enum.FontWeight.Bold)
	actionbutton.Size = UDim2.new(0.178, 0, 0.063, 0)
	actionbutton.ZIndex = (mainframe.ZIndex + 1)
	actionbutton.Position = UDim2.new(0.424, 0, 0.733, 0)
	
	Instance.new('UICorner', progressbar).CornerRadius = UDim.new(1, 2)
	Instance.new('UICorner', progressbarmain).CornerRadius = UDim.new(1, 2) 
	Instance.new('UICorner', actionbutton)
	
	local guiframe = Instance.new('Frame', gui)
	guiframe.Name = 'InstallerMain'
	guiframe.BackgroundColor3 = Color3.fromRGB(4, 1, 22)
	guiframe.Size = UDim2.new(0, 466, 0, 222)
	guiframe.Position = UDim2.new(0.324, 0, 0.379, 0)
	
	Instance.new('UICorner', guiframe)
	
	local guiframestroke = Instance.new('UIStroke', guiframe)
	guiframestroke.Color = Color3.fromRGB(255, 255, 255)
	guiframestroke.Thickness = 3 
	 
	Instance.new('UIGradient', guiframestroke).Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 22, 225)), ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 16, 194))})
	
	local guitopbar = Instance.new('Frame', guiframe)
	guitopbar.BackgroundColor3 = Color3.fromRGB(29, 4, 127)
	guitopbar.Size = UDim2.new(0, 466, 0, 30)
	guitopbar.ZIndex = 8e8
	
	Instance.new('UICorner', guitopbar)
	
	local guitopbartext = Instance.new('TextLabel', guitopbar)
	guitopbartext.Name = 'InstallerText'
	guitopbartext.Text = 'Render Installer'
	guitopbartext.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Bold)
	guitopbartext.Position = UDim2.new(0.5, 0, 0.5, 0)
	guitopbartext.TextSize = 16
	guitopbartext.TextColor3 = Color3.fromRGB(255, 255, 255)
	guitopbartext.BackgroundTransparency = 1 
	guitopbartext.ZIndex = 8e8
	
	local renderlogo2 = Instance.new('ImageLabel', guiframe)
	renderlogo2.Name = 'RenderIcon'
	renderlogo2.BackgroundTransparency = 1
	renderlogo2.Size = UDim2.new(0, 117, 0, 125)
	renderlogo2.Position = UDim2.new(0.032, 0, 0.225, 0)
	renderlogo2.Image = 'rbxassetid://15688086520'
	
	local guidivider = Instance.new('Frame', guiframe)
	guidivider.Position = UDim2.new(0.321, 0, 0.132, 0)
	guidivider.Size = UDim2.new(0, 8, 0, 192)
	guidivider.BackgroundColor3 = Color3.fromRGB(23, 8, 107)
	guidivider.ZIndex = (guitopbar.ZIndex - 1)
	
	Instance.new('UICorner', guidivider).CornerRadius = UDim.new(0, 1)
	
	local function createbutton(args)
		local api = {}
		local button = Instance.new('TextButton', guiframe)
		button.Text = ''
		button.ZIndex = 8e8
		button.Position = UDim2.new(0.391, 0, 0.27, 0)
		button.Size = UDim2.new(0, 31, 0, 30)
		button.BackgroundColor3 = Color3.fromRGB(18, 3, 77)
		button.AutoButtonColor = false
		local buttontext = guitopbartext:Clone()
		buttontext.Text = args.Name
		buttontext.ZIndex = 8e8
		buttontext.Parent = button
		buttontext.Position = UDim2.new(3.5, 0, 0.5, 0) -- I will add auto positioning once more toggles just got lazy
		Instance.new('UICorner', button).CornerRadius = UDim.new(0, 5)
		api.Instance = button 
		api.ToggleOption = function(bool)
			if bool then 
				api.Enabled = true
				tween:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(18, 3, 77)}):Play()
			else 
				api.Enabled = nil 
				tween:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(33, 5, 145)}):Play()
			end 
		end
		button.MouseButton1Click:Connect(function()
			api.ToggleOption(api.Enabled == nil) 
		end)
		if args.Default then
			api.ToggleOption(true) 
		end
		return api
	end
	
	local installbutton = Instance.new('TextButton', guiframe)
	installbutton.Name = 'InstallButton'
	installbutton.Text = 'Install'
	installbutton.Position = UDim2.new(0.436, 0, 0.694, 0)
	installbutton.Size = UDim2.new(0, 188, 0, 42)
	installbutton.TextColor3 = Color3.fromRGB(255, 255, 255)
	installbutton.BackgroundColor3 = Color3.fromRGB(30, 6, 130)
	installbutton.AutoButtonColor = false
	installbutton.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Bold)
	installbutton.TextSize = 14 
	
	Instance.new('UICorner', installbutton).CornerRadius = UDim.new(0, 6)
	
	local closebutton = Instance.new('TextButton', guitopbar)
	closebutton.Name = 'CloseButton'
	closebutton.Text = ''
	closebutton.BackgroundColor3 = Color3.fromRGB(130, 8, 10)
	closebutton.Size = UDim2.new(0, 22, 0, 20)
	closebutton.Position = UDim2.new(0.032, 0, 0.156, 0)
	closebutton.ZIndex = 8e8
	
	Instance.new('UICorner', closebutton).CornerRadius = UDim.new(0, 6)
	
	installbutton.MouseButton1Click:Connect(function() -- bad code sorry
		mainframe.Visible = true 
		guiframe.Visible = false 
		activated = true
		if httprequest == nil or base64_decode == nil or writefile == nil then 
			progresstext.TextColor3 = Color3.fromRGB(255, 0, 0)
			progresstext.Text = ('Render isn\'t supported for "'..executor..'".') 
			return
		end
		installing = tick()
		for step, func in next, steps do 
			progresstext.Text = titles[step]
			local success, err = pcall(func) 
			if guiframe.Visible then 
				installing = nil
				break 
			end
			if not success then 
				task.spawn(error, 'Render Installer Step '..stepcount..' - '..err)
				local oldcolor = progresstext.TextColor3
				tween:Create(progresstext, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(255, 0, 0)}):Play() 
				task.delay(1, function()
					tween:Create(progresstext, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = oldcolor}):Play()  
				end)
			end  
			local offset = (stepcount <= 0 and 0.552 or 0.552 / stepcount)
			tween:Create(progressbarmain, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {Size = UDim2.new(offset, 0, 0.021, 0)}):Play()
		end
		tween:Create(progressbarmain, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {Size = UDim2.new(0.552, 0, 0.021, 0)}):Play()
		progresstext.Text = 'The installation has finished.'
		actionbutton.Text = 'Close The Installer'
		installing = nil 
		installed = true
		task.wait()
	end)
	
	closebutton.MouseEnter:Connect(function()
		tween:Create(closebutton, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(179, 11, 14)}):Play() 
	end)
	
	closebutton.MouseLeave:Connect(function()
		tween:Create(closebutton, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(130, 8, 10)}):Play()
	end)
	
	closebutton.MouseButton1Click:Connect(function()
		if getgenv then 
			getgenv().renderinstaller = nil 
		end
		gui:Destroy()
	end)
	
	actionbutton.MouseButton1Click:Connect(function()
		if installed then 
			if getgenv then 
				getgenv().renderinstaller = nil 
			end
			gui:Destroy() 
		else
			mainframe.Visible = false 
			guiframe.Visible = true
		end
		installing = nil
	end)
	
	task.spawn(function()
		repeat 
			if installed then break end
			if installing then 
				timetext.Text = ('ETA '..math.floor(tick() - installing)..'s') 
			else 
				timetext.Text = 'ETA 0s'
			end
			task.wait() 
		until not gui.Parent
	end)
	
	local profiles = createbutton({Name = 'Install Settings', Default = isfile and not isfile('ria.json') or isfile == nil})
	
	if getgenv then 
		getgenv().renderinstaller = gui 
	end
	
	local function writevapefile(file, data)
		for i,v in next, ({'vape', 'vape/CustomModules', 'vape/assets', 'vape/Profiles'}) do 
			if not isfolder(v) then 
				makefolder(v) 
			end
		end
		if not isfile('vape/commithash.txt') then 
			writefile('vape/commithash.txt', 'main') 
		end
		writefile('ria.json', httpservice:JSONEncode({Key = ria, Client = game:GetService('RbxAnalyticsService'):GetClientId()}))
		writefile('vape/'..file, data)
	end
	
	local function registerStep(name, func)
		table.insert(steps, func)
		table.insert(titles, name)
		stepcount = #steps
	end

	registerStep('Checking RIA key...', function()
		for i = 1, 100 do 
			local suc = pcall(function() ria = base64_decode(ria) end) -- sometimes my bot encodes keys more than once so womp womp
			if not suc then break end
		end
		local success, res = pcall(function()
			return httprequest({Url = 'https://api.renderintents.xyz/ria', Method = 'GET', Headers = {RIA = ria}})
		end) 
		if not success then 
			res = {StatusCode = 404, Body = '{"error":""}'} 
			print('die nigger')
		end
		local suc, decode = pcall(function()
			local data = httpservice:JSONDecode(res.Body) 
			if type(data) == 'table' then 
				return data 
			end
		end)
		if not suc then 
			decode = nil 
		end
		if res.StatusCode == 404 and decode and decode.error then 
			progresstext.Text = 'The script key is currently invalid/disabled.' 
			progresstext.TextColor3 = Color3.fromRGB(255, 0, 0)
			task.wait(9e9)
		end 
		if res.StatusCode == 429 then 
			progresstext.Text = 'You\'re currently being rate limited right now.' 
			progresstext.TextColor3 = Color3.fromRGB(255, 0, 0) 
			task.wait(9e9)
		end
		if (res.StatusCode == 200 or decode and decode.Discord) and not httpservice:JSONDecode(res.Body).Allowed and not bypassRIA then 
			progresstext.Text = 'The script key was registered on another device. use /resetkey in discord if mistake.' 
			progresstext.TextColor3 = Color3.fromRGB(255, 0, 0) 
			task.wait(9e9) 
		end
	end)

	local corescripts = {'GuiLibrary.lua', 'MainScript.lua', 'Universal.lua', 'NewMainScript.lua'} 
	for i,v in next, corescripts do 
		registerStep('Downloading vape/'..v, function()
			local res = httprequest({Url = 'https://raw.githubusercontent.com/robloxsuckslikereallydude/Render/source/packages/'..v, Method = 'GET'}).Body
			if res ~= '404: Not Found' then 
				writevapefile(v, res) 
			end
		end)
	end

	for i,v in next, ({'6872274481.lua', '6872265039.lua'}) do 
		registerStep('Downloading vape/CustomModules/'..v, function()
			local res = httprequest({Url = 'https://raw.githubusercontent.com/robloxsuckslikereallydude/Render/source/packages/'..v, Method = 'GET'}).Body
			if res ~= '404: Not Found' then 
				writevapefile('CustomModules/'..v, res) 
			end
		end)
	end

	local guiprofiles = {}
	local profilesfetched

	task.spawn(function()
		local res = httprequest({Url = 'https://api.github.com/repos/SystemXVoid/Render/contents/Libraries/Settings', Method = 'GET'}).Body 
		if res ~= '404: Not Found' then 
			for i,v in next, httpservice:JSONDecode(res) do 
				if type(v) == 'table' and v.name then 
					table.insert(guiprofiles, v.name) 
				end
			end
		end
		profilesfetched = true
	end)

	registerStep('Getting Profiles...', function()
		repeat task.wait() until profilesfetched
	end)

	repeat task.wait() until profilesfetched

	for i,v in next, guiprofiles do 
		registerStep('Downloading vape/Profiles/'..v, function()
			local res = game:HttpGet('https://raw.githubusercontent.com/SystemXVoid/Render/source/Libraries/Settings/'..v)
			if res ~= '404: Not Found' then 
				writevapefile('Profiles/'..v, res) 
			end
		end)
	end
end)
