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
	local luapath = jsonpath:sub(1, -5) .. "lua" -- We assume that it ends in .json

	if GetFileExists(jsonpath) then
		if GetFileExists(luapath) then
			Print([[

--------WARNING--------
Configuration file %s takes priority over %s!
Delete %s to solve this problem.
--------  END  --------]], jsonpath, luapath, jsonpath)
		end
		return loadconfigjson(jsonpath)
	end

	if not GetFileExists(luapath) then return end

	local file, err = io.open(luapath)
	if err ~= nil then
		Print("[ERROR] Could not load configuration file %s: %s", luapath, err)
		return nil, err
	end

	local chunk, err = loadstring(file:read "*a", luapath)
	if err ~= nil then
		Print("[ERROR] Could not load configuration file %s: %s", luapath, err)
		return nil, err
	end

	local success, data = xpcall(chunk, errorhandler)
	if success == false then
		return nil, data
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
				Print("Configuration file %s was incorrect and has as such been updated!", name)
				local luapath = "config://" .. name:sub(1, -5) .. "lua"
				if GetFileExists(luapath) then
					Print("\tPlease update %s to reflect these changes", luapath)
				end
				SaveConfigFile(name, data)
			end
		end
		return data
	else
		WriteDefaultConfigFile(name, default)
		return default
	end
end

function WriteDefaultConfigFile(name, default)
	if not GetFileExists("config://" .. name) and not GetFileExists("config://" .. name:sub(1, -5) .. "lua") then
		local file = io.open("config://" .. name, "w")
		if file == nil then
			return
		end
		file:write(json.encode(default, { indent = true }))
	end
end
