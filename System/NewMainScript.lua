local isfile = isfile or function(file)
	return pcall(function() return readfile(file) end) and true or false
end

local writefile = writefile or function() return "" end
local isfolder = isfolder or function() return false end
local makefolder = makefolder or function() end

local function getvapefile(file)
	if not isfolder("vape") then 
		makefolder("vape")
	end
	if not isfile("vape/"..file) then 
		local custom = {"MainScript.lua", "Universal.lua", "GuiLibrary.lua"}
		local success, script = pcall(function()
			local url = (table.find(custom, file) and "SystemXVoid/Render/main/System/"..file or "7GrandDadPGN/VapeV4ForRoblox/main/"..file)
			return game:HttpGet("https://raw.githubusercontent.com/"..url)
		end)
		if success and script ~= "404: Not Found" then 
			if file:sub(#file - 4, #file) == ".lua" and custom[file] then 
				script = ("Render Custom Vape Signed File\n"..script)
			end
			writefile("vape/"..file, script)
		else
			task.spawn(error, "Vape - Failed to download\n vape/"..file..". | "..(script or "404: Not Found"))
		end
		return script
	end
	return readfile("vape/"..file)
end

if isfolder("vape") and not isfile("vape/commithash.txt") then 
	writefile("vape/commithash.txt", "main")
end

loadstring(getvapefile("MainScript.lua"))()
