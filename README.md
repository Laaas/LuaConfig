# About
JSON? Yuck. No comments, overly verbose, hard to read **and** modify,
what's there to like about it?
It's an abomination created from another abomination JS. What's it for?
Is it designed to be human-readable? Machine-readable? Unreadable?

What's even more amazing, though, is that someone though that JSON
was a good fit for configuration files in NS2.
But no longer will we suffer! No longer will we write poorly formatted
and inflexible configuration files!; We have Lua.

# Lua
Lua, which is used in NS2 for everything other than the engine itself, actually
[originated as a configuration tool](https://www.lua.org/history.html).

So I thought »Why doesn't NS2 just use Lua for configuration«, and so I made this mod.

# How to use
It's quite simple, really. You, as a server operator, install the mod onto your server. Then
you find the configuration file you want to convert, make a file with the same file stem
(i.e. the full file name without the dot and the extension), but suffix it with .lua.
Then you fill it with functionally equivalent Lua code and voilà!
When NS2 attempts to load the configuration file the next time, it will load the code inside
the Lua file.

# What if I fuck up?
If your Lua file is somehow erroneous, then the corresponding JSON file will be loaded in stead.

# Limitations
## Client-side
Client-side configuration files will **not** be able to use Lua, since LuaJIT is
inherently unsafe, unless sandboxed properly. I will add in the ability to use it
client-side too some time in the future, but it will be very limited.

## Writing to the configuration files from NS2
Whenever a configuration file is written to, the original Lua configuration file
will **not** be updated. **Instead** the JSON file is corrected.
Updating the Lua file is simply not possible without extreme levels of complexity
(and even then it would probably still not be good enough).

You must manually update the Lua configuration file so that it is equivalent
to the JSON file, but I would personally recommend you
to not use Lua configuration for anything that has to be written to by NS2 itself.

E.g. if you have a wrongly configured DiscordBridge.lua, Shine will attempt to update it and fix it.
Since the Lua file can't be updated, the JSON file will be updated.

# Example
```
setfenv(1, {})

maps = {"ns2_bandaidmap"}
time = 30
mode = "order"
mods = {
	"334982D2",
	"104BA26D",
	"706D242",
	"34E28E40",
}

return _G
```
OR (they are equivalent)
```
return {
	maps = {"ns2_bandaidmap"},
	time = 30,
	mode = "order",
	mods = {
		"334982D2",
		"104BA26D",
		"706D242",
		"34E28E40",
	},
}
```

# But I don't know Lua
[Here you go](https://www.lua.org/manual/5.1/manual.html)
Some things from [here](https://www.lua.org/manual/5.2/manual.html) also work!
