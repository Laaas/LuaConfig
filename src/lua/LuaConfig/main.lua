-- Run when entry file is read

ModLoader.SetupFileHook("lua/shine/core/shared/config.lua", "lua/LuaConfig/shine_config.lua", "post")

local byte = string.byte

local function loadconfigjson(path)
	local file, err = io.open(path)
	if err == nil then
		return json.decode(file:read "*a")
	else
		return file, err
	end
end

local function errorhandler(e)
	Shared.Message(debug.traceback(e, 2))
	return e
end

local function loadconfig(jsonpath)
	local luapath = path:sub(-4) .. "lua" -- We assume that it ends in .json
	if not GetFileExists(luapath) then
		return loadconfigjson(jsonpath)
	end

	local file, err = io.open(luapath)
	if err ~= nil then
		Print("Could not load configuration file %s: %s\nNB: Reading JSON file as fallback", luapath, err)
		return loadconfigjson(jsonpath)
	end

	local chunk, err = loadstring(file:read "*a", luapath)
	if err ~= nil then
		Print("Could not load configuration file %s: %s\nNB: Reading JSON file as fallback", luapath, err)
		return loadconfigjson(jsonpath)
	end

	local data, err = xpcall(chunk, errorhandler)
	if err ~= nil then
		Print "NB: Reading JSON file as fallback"
		return loadconfigjson(jsonpath)
	end

	return data
end

_G.__LuaConfig = {loadconfig = loadconfig}

function LoadConfigFile(name, default, check)
	local data = loadconfig("config://" .. name)
	if data ~= nil then
		if default and check then
			local updated
			updated, data = CheckConfig(data, default)

			if updated then
				local new = name:sub(-4) .. "-corrected.json"
				Print("Configuration file %s was incorrect! Please rectify it with the changes in %s", name, new)
				SaveConfigFile(new, data) 
			end
		end
		return data
	else
		WriteDefaultConfigFile(name, default)
		return default
	end
end
