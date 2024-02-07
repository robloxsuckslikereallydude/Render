local sessionId = game:GetService('RbxAnalyticsService'):GetSessionId()

local isfile = isfile or function(file)
    local success, filecontents = pcall(function() return readfile(file) end)
    return success and type(filecontents) == 'string'
end 

if shared == nil then
	getgenv().shared = {} 
end

if queue_on_teleport == nil then
	getgenv().queue_on_teleport = function(str)
    		if not isfile('serverhop.txt') then writefile('serverhop.txt', sessionId) end
    		appendfile('serverhop.txt', '\nsplit\n'..str)
	end
	if syn then 
    		setreadonly(syn, false)
    		syn.queue_on_teleport = queue_on_teleport 
	end
	if isfile('serverhop.txt') then 
    		local lines = readfile('serverhop.txt'):split('\n')
    		delfile('serverhop.txt')
    		if lines[1] == sessionId then 
        		table.remove(lines, 1)
        		for i, v in table.concat(lines, '\n'):split('split') do 
            			task.spawn(loadstring(v))
        		end
		end
	end
end

if isfile('vape/MainScript.lua') then 
	loadfile('vape/MainScript.lua')()
else 
	local mainscript = game:HttpGet('https://raw.githubusercontent.com/SystemXVoid/Render/source/packages/MainScript.lua') 
	task.spawn(function() loadstring(mainscript)() end)
	writefile('vape/MainScript.lua', mainscript)
end
