-- Terminal Login:
-- Optional file. Handles logins and registration. (Requires Terminal_Core.lua)

assert(terminal, "the Terminal core script must be added first!")

terminal.modules.login = 1 -- Login module is added, update global table

--local logPasses = {} -- name = {hash, perms},

local function logPasses()
	local s = server
	if not s then return {} end -- Error!
	if not s.logPasses then
		s.logPasses = {}
		COM_BufInsertText(s, "exec term_logins.txt -silent") -- Load passes from log file
		s.logpasstimeout = 900
	elseif s.logpasstimeout > 0 then
		s.logpasstimeout = $1-1
	else
		COM_BufInsertText(s, "exec term_logins.txt -silent") -- Reload for safety
		s.logpasstimeout = 900
	end
	return s.logPasses -- name = {hash, perms},
end

-- Command used by a server-side script to load password hashes
COM_AddCommand("loadhash", function(p, name, hash, perms)
	if p ~= server then return end
	server.logPasses[name] = {tonumber(hash), tonumber(perms)}
end, 1)

local function passwordHash(original)
	local hash = 4096
	for i=1,original:len() do
		local number = original:byte(i)
		hash = $1+number
		hash = $1*300
		hash = $1*$1
		hash = $1^^6983745
	end
	if hash < 0 then
		hash = $1-(1<<31)
	end
	hash = ($1>>8)+($1%256)*32154
	return hash
end

COM_AddCommand("login", function(p, arg1, arg2)
	-- Init args
	local name, pass
	if arg2 == nil then
		if arg1 == nil then
			CONS_Printf(p, "login [<username>] <password>: Log into your account on this server. (If username is not supplied, it will default to your current username.)")
			return
		end
		pass = arg1
		name = p.name
	else
		name = arg1
		pass = arg2
	end
	pass = passwordHash(pass)
	
	local passes = logPasses()
	
	if not (passes[name] and passes[name][1] == pass) then
		CONS_Printf(server, p.name.." tried unsuccessfully to log in.")
		CONS_Printf(p, terminal.colors.yellow.."Login incorrect."..terminal.colors.white)
		return
	end
	
	p.servperm = ($1 or 0)|passes[name][2]
	if p.name ~= name then
		print(p.name .. " has logged into "..name.."'s account.")
	else
		print(p.name .. " has logged into their account.")
	end
	p.nickservname = name
end)

COM_AddCommand("register", function(p, pass)
	if not pass then
		CONS_Printf(p, "register <password>: Register on this server under your current name, to keep the permissions you have now! The server may still have to finalize your registration manually. (Don't use a password you use elsewhere, as SRB2's communications code isn't secure enough to keep the info safe!)")
		return
	end
	pass = passwordHash(pass)
	local name = p.name
	if not p.servperm then p.servperm = 0 end
	
	local updatingpass = false
	local passes = logPasses()
	for logname,values in pairs(passes) do
		if name == logname then
			if pass == values[1] then
				updatingpass = true
				break
			else
				CONS_Printf(p, "Someone's already registered your username!")
				return
			end
		end
	end
	
	passes[name] = {pass, p.servperm}
	
	local s = server
	CONS_Printf(s, ([[
	
%sMSERV_REGISTER:%s %s
Add the following to "term_logins.txt" to complete this user's registration:
loadhash "%s" %s %s
]]):format(terminal.colors.yellow, terminal.colors.white, name, name, pass, p.servperm))
	if updatingpass then
		CONS_Printf(p, "Your password has been changed.")
	else
		CONS_Printf(p, "Your username has been registered. Use the "..terminal.colors.yellow.."login"..terminal.colors.white.." command to log into it in the future!")
		print(p.name .. " has registered on this server.")
	end
	p.nickservname = name
end)

-- Overriding "verify" and "password" to lock out the old vanilla verification system - it'll just cause confusion!
local function noOldAuth(p)
	CONS_Printf(p, terminal.colors.yellow.."verify"..terminal.colors.white.." and "..terminal.colors.yellow.."password"..terminal.colors.white.." are out. Type "..terminal.colors.yellow.."term_help logins"..terminal.colors.white.." for more information about the new authentication system in place!")
end
COM_AddCommand("verify", noOldAuth)
COM_AddCommand("password", noOldAuth)



-- Name protection, NickServ-style!
local function nickservopts() -- TODO: NickServ Ghost-style reclamation
	local s = server
	if not s then return end -- ABORT ABORT ADJGDFSOIHHO
	if not s.nickservopts then
		s.nickservopts = {
			timeout = 30, -- Timeout in seconds - 0 disables
			default = "Guest" -- Name to change them to - P_Random() is stitched onto the end of this
		}
	end
	return s.nickservopts
end

addHook("ThinkFrame", do
	if not (netgame and multiplayer) then return end -- Failsafe to keep this from running outside of a netgame?
	
	local passes = logPasses()
	local opts = nickservopts()
	if not (opts and opts.timeout) then return end
	for p in players.iterate do
		for name,values in pairs(passes) do
			if p.name == name and p.nickservname ~= name then
				if p.nickservcheck ~= name then
					p.nickservcheck = name
					CONS_Printf(p, "This name is registered. Please login within "..nickservopts().timeout.." seconds or your name will be forcibly changed.")
					p.nickservtimeout = opts.timeout*TICRATE
				elseif p.nickservtimeout == 1 then
					COM_BufInsertText(p, ("name %s%s"):format(opts.default, #p))
				else
					p.nickservtimeout = $1-1
				end
			end
		end
	end
end)


COM_AddCommand("logintime", function(p, val)
	if not terminal.HasPermission(p, terminal.permissions.text.moderator) then
		CONS_Printf(p, "You need \"moderator\" permissions to use this!")
		return
	end
	if (not tonumber(val) or tonumber(val) < 0) and val ~= "default" then
		CONS_Printf(p, "logintime <value>: Sets the timeout a player has to login to an account nickname before being forcibly renamed. Default timeout is 30 seconds. (set to 0 to disable)")
		return
	end
	local o = nickservopts()
	if val == "default" then
		o.timeout = 30
		print(p.name.." changed login timeout to default setting (30 seconds).")
		return
	end
	o.timeout = tonumber(val)
	if o.timeout then
		print(p.name.." changed login timeout to "..o.timeout.." seconds.")
	else
		print(p.name.." disabled login timeout.")
	end
end)

COM_AddCommand("defaultname", function(p, val)
	if not terminal.HasPermission(p, terminal.permissions.text.moderator) then
		CONS_Printf(p, "You need \"moderator\" permissions to use this!")
		return
	end
	if not val then
		CONS_Printf(p, "defaultname <name>: Sets the name players are forcibly changed to if they don't login. Default is \"Guest\".")
		return
	end
	local o = nickservopts()
	if val == "default" then -- This looks redundant as hell.
		o.default = "Guest"
		CONS_Printf(p, "Default guest name changed to default setting (Guest).")
		return
	end
	o.default = val
	CONS_Printf(p, ("Default guest name changed to %s."):format(val))
end)


-- Help listing
terminal.AddHelp("logins", 
[[Terminal provides a login system for account registration. Logging in will allow you to keep permissions given to you by the server. (For more info about permissions, type "term_help permissions" in the console.)

To register an account, type "register <password>" into the console. The server admin will have to complete the registration process. Once this is done, you can type "login [<username>] <password>" to log into your account. (username is the name you registered with, and will default to your current username if not given.)]])