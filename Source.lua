--[[
    AimHot v8, created, edited and founded by Herrtt#3868

    I decided to make it open source for all the new scripters out there (including me), don't ripoff or claim this as your own.
    When I get time I will comment a lot of the stuff here.

]]



-- Extremly bad code starts below here

local DEBUG_MODE = true -- warnings, prints and profiles dont change idiot thanks

-- Ok I declare some variables here for micro optimization. I might declare again in the blocks because I am lazy to check here
local game, workspace = game, workspace

local cf, v3, v2, udim2 = CFrame, Vector3, Vector2, UDim2
local string, math, table, Color3, tonumber, tostring = string, math, table, Color3, tonumber, tostring

local cfnew = cf.new
local cf0 = cfnew()

local v3new = v3.new
local v30 = v3new()

local v2new = v2.new
local v20 = v2new()

local setmetatable = setmetatable
local getmetatable = getmetatable

local type, typeof = type, typeof

local Instance = Instance

local drawing = Drawing or drawing

local mousemoverel = mousemoverel

local getrawmetatable = getrawmetatable
local setreadonly = setreadonly
local newcclosure = newcclosure

local readfile = readfile
local writefile = writefile
local appendfile = appendfile

local warn, print = DEBUG_MODE and warn or function() end, DEBUG_MODE and print or function() end


local required = {
    mousemoverel, drawing, getrawmetatable, setreadonly, readfile, writefile, appendfile, newcclosure
}

for i,v in pairs(required) do
    if v == nil then
        warn("Your exploit is not supported (may consider purchasing a better one?)!")
        return -- Only pros return in top-level function
    end
end

local servs
servs = setmetatable(
{
    Get = function(self, serv)
        if servs[serv] then return servs[serv] end
        local s = game:GetService(serv)
        if s then servs[serv] = s end
        return s
    end;
}, {
    __index = function(self, index)
        local s = game:GetService(index)
        if s then servs[index] = s end
        return s
    end;
})

local connections = {}
local function bindEvent(event, callback) -- Let me disconnect in peace
    local con = event:Connect(callback)
    table.insert(connections, con)
    return con
end

local players = servs.Players
local runservice = servs.RunService
local http = servs.HttpService
local uis = servs.UserInputService

local function jsonEncode(t)
    return http:JSONEncode(t)
end
local function jsonDecode(t)
    return http:JSONDecode(t)
end

local function existsFile(name)
    return pcall(function()
        return readfile(name)
    end)
end

local function mergetab(a,b)
    local c = a
    for i,v in pairs(b) do 
        c[i] = v 
    end
    return c
end

local locpl = players.LocalPlayer
local mouse = locpl:GetMouse()
local camera = workspace.CurrentCamera

local findFirstChild = Instance.new("Part").FindFirstChild
local findFirstChildOfClass = Instance.new("Part").FindFirstChildOfClass

local mycharacter = locpl.Character
local myroot = mycharacter and findFirstChild(mycharacter, "HumanoidRootPart") or mycharacter and mycharacter.PrimaryPart
bindEvent(locpl.CharacterAdded, function(char)
    mycharacter = char
    wait(.1)
    myroot = mycharacter and findFirstChild(mycharacter, "HumanoidRootPart") or mycharacter.PrimaryPart
end)
bindEvent(locpl.CharacterRemoving, function()
    mycharacter = nil
    myroot = nil
end)

-- Just to check another aimhot instance is running and close it
local uid = tick() .. math.random(1,100000) .. math.random(1,100000)
if shared.ah8 and shared.ah8.close and shared.ah8.uid~=uid then shared.ah8:close() end

-- Main shitty script should start below here

warn("AH8_MAIN : Running script...")

local event = {} 
local utility = {}
local serializer = {}

local settings = {}

local hud = loadstring(game:HttpGet("https://pastebin.com/raw/3hREvLEU", DEBUG_MODE == true and false or DEBUG_MODE == false and true))()

local aimbot = {}

local visuals = {}

local crosshair = {}
local esp = {}
local boxes = {}
local tracers = {}

local run = {}
local ah8 = {enabled = true;}

-- Some libraries

do
    --/ Events : custom event system, bindables = gay

    local type = type;
    local coroutine = coroutine;
    local create = coroutine.create;
    local resume = coroutine.resume;

    local function spawn(f, ...)
        resume(create(f), ...)
    end

    function event.new(t)
        local self = t or {}
        
        local n = 0
        local connections = {}
        function self:connect(func)
            if type(func) ~= "function" then return end

            n = n + 1
            local my = n
            connections[n] = func

            local connected = true
            local function disconnect()
                if connected ~= true then return end
                connected = false

                connections[n] = nil
            end

            return disconnect
        end


        local function fire(...)
            for i,v in pairs(connections) do
                v(...)
            end
        end

        return fire, self
    end
end

do
    --/ Utility : To make it easier for me to edit

    local getPlayers = players.GetPlayers
    local getPartsObscuringTarget = camera.GetPartsObscuringTarget
    local worldToViewportPoint = camera.WorldToViewportPoint
    local worldToScreenPoint = camera.WorldToScreenPoint
    local raynew = Ray.new
    local findPartOnRayWithIgnoreList = workspace.FindPartOnRayWithIgnoreList

    local function raycast(ray, ignore, callback)
        local ignore = ignore or {}

        local hit, pos, normal, material = findPartOnRayWithIgnoreList(workspace, ray, ignore)
        while hit and callback do
            local Continue, _ignore = callback(hit)
            if not Continue then
                break
            end
            if _ignore then
                table.insert(ignore, _ignore)
            else
                table.insert(ignore, hit)
            end
            hit, pos, normal, material = findPartOnRayWithIgnoreList(workspace, ray, ignore)
        end
        return hit, pos, normal, material
    end
    function utility.isalive(_1, _2)
        if _1 == nil then return end
        local Char, RoootPart
        if _2 ~= nil then
            Char, RootPart = _1,_2
        else
            Char = _1.Character
            RootPart = Char and (Char:FindFirstChild("HumanoidRootPart") or Char.PrimaryPart)
        end

        --local Char = plr.Character
        if Char and RootPart then
           -- local RootPart = Char:FindFirstChild("HumanoidRootPart") or Char.PrimaryPart
            local Human = Char:FindFirstChildOfClass("Humanoid")
            if RootPart and Human then
                if Human.Health > 0 then
                    return true
                end
            end
        end

        return false
    end
    function utility.isvisible(char, root, max, ...)
        local pos = root.Position

        local camp = camera.CFrame.p
        local dist = (camp - pos).Magnitude
        local ray = raynew(camp, (pos - camp).unit * dist)


        local hitt = 0
        local hit = raycast(ray, {mycharacter, ..., cam}, function(hit)

            if hit.CanCollide ~= false then-- hit.Transparency ~= 1 then¨
                hitt = hitt + 1
                return hitt < max
            end
        
            if hit:IsDescendantOf(char) then
                return
            end
            return true
        end)

        return hit == nil and true or hit:IsDescendantOf(char), hitt
    end
    function utility.sameteam(player, p1)
        local p0 = p1 or locpl
        return (player.Team~=nil and player.Team==p0.Team) and player.Neutral == false or false
    end
    function utility.getDistanceFromMouse(position)
        local screenpos = worldToScreenPoint(camera, position)
        if screenpos.Z > 0 then
            return (v2new(mouse.X, mouse.Y) - v2new(screenpos.X, screenpos.Y)).Magnitude
        end
        return 9999
    end

    function utility.getClosestMouseTarget(settings)
        local closest, temp = nil, settings.fov or math.huge
        local plr

        for i,v in pairs(getPlayers(players)) do
            if (locpl ~= v and (settings.ignoreteam==true and utility.sameteam(v)==false or settings.ignoreteam == false)) then
                local character = v.Character-- or utility.getCharacter(v)
                if character then
                    local part = findFirstChild(character, settings.name or "HumanoidRootPart") or findFirstChild(character, "HumanoidRootPart")
                    if part then
                        local legal = true

                        if legal then
                            if settings.checkifalive then
                                local isalive = utility.isalive(character, part)
                                if not isalive then
                                    legal = false
                                end
                            end
                        end

                        if legal then
                            local visible = true
                            if settings.ignorewalls == false then
                                local vis = utility.isvisible(character, part, (settings.maxobscuringparts or 0))
                                if not vis then
                                    legal = false
                                end
                            end
                        end

                        if legal then
                            local distance = utility.getDistanceFromMouse(part:GetRenderCFrame().p)
                            if temp > distance then
                                temp = distance
                                closest = part
                                plr = v
                            end
                        end
                    end
                end
            end
        end -- who doesnt love 5 ends in a row?

        return closest, temp, plr
    end
    function utility.getClosestTarget(settings)

        local closest, temp = nil, math.huge
        --local myroot = mycharacter and (findFirstChild(mycharacter, settings.name or "HumanoidRootPart") or findFirstChild(mycharacter, "HumanoidRootPart"))
        
        if myroot then
            for i,v in pairs(getPlayers(players)) do
                if (locpl ~= v) and (settings.ignoreteam==true and utility.sameteam(v)==false or settings.ignoreteam == false) then
                    local character = v.Character-- or utility.getCharacter(v)
                    if character then
                        local part = findFirstChild(character, settings.name or "HumanoidRootPart") or findFirstChild(character, "HumanoidRootPart")
                        if part then
                            local visible = true
                            if settings.ignorewalls == false then
                                local vis, p = utility.isvisible(character, part, (settings.maxobscuringparts or 0))
                                if p <= (settings.maxobscuringparts or 0) then
                                    visible = vis
                                end
                            end

                            if visible then
                                local distance = (myroot.Position - part.Position).Magnitude
                                if temp > distance then
                                    temp = distance
                                    closest = part
                                end
                            end
                        end
                    end
                end
            end
        end

        return closest, temp
    end
end


local serialize
local deserialize
do
    --/ Serializer : garbage : slow as fuck
	
	local function hex_encode(IN, len)
	    local B,K,OUT,I,D=16,"0123456789ABCDEF","",0,nil
	    while IN>0 do
	        I=I+1
	        IN,D=math.floor(IN/B), IN%B+1
	        OUT=string.sub(K,D,D)..OUT
	    end
		if len then
			OUT = ('0'):rep(len - #OUT) .. OUT
		end
	    return OUT
	end
	local function hex_decode(IN) 
		return tonumber(IN, 16) 
	end

    local types = {
        ["nil"] = "0";
        ["boolean"] = "1";
        ["number"] = "2";
        ["string"] = "3";
        ["table"] = "4";

		["Vector3"] = "5";
		["CFrame"] = "6";
        ["Instance"] = "7";
	
		["Color3"] = "8";
    }
    local rtypes = (function()
        local a = {}
        for i,v in pairs(types) do
            a[v] = i
        end
        return a
    end)()

    local typeof = typeof or type
    local function encode(t, ...)
        local type = typeof(t)
        local s = types[type]
        local c = ''
        if type == "nil" then
            c = types[type] .. "0"
        elseif type == "boolean" then
            local t = t == true and '1' or '0'
            c = s .. t
        elseif type == "number" then
            local new = tostring(t)
            local len = #new
            c = s .. len .. "." .. new
        elseif type == "string" then
            local new = t
            local len = #new
            c = s .. len .. "." .. new
		elseif type == "Vector3" then
			local x,y,z = tostring(t.X), tostring(t.Y), tostring(t.Z)
			local new = hex_encode(#x, 2) .. x .. hex_encode(#y, 2) .. y .. hex_encode(#z, 2) .. z
			c = s .. new
		elseif type == "CFrame" then
			local a = {t:GetComponents()}
			local new = ''
			for i,v in pairs(a) do
				local l = tostring(v)
				new = new .. hex_encode(#l, 2) .. l
			end
			c = s .. new
		elseif type == "Color3" then
			local a = {t.R, t.G, t.B}
			local new = ''
			for i,v in pairs(a) do
				local l = tostring(v)
				new = new .. hex_encode(#l, 2) .. l
			end
			c = s .. new
        elseif type == "table" then
            return serialize(t, ...)
        end
        return c
    end
    local function decode(t, extra)
        local p = 0
        local function read(l)
            l = l or 1
            p = p + l
            return t:sub(p-l + 1, p)
        end
        local function get(a)
            local k = ""
            while p < #t do
                if t:sub(p+1,p+1) == a then
                    break
                else
                    k = k .. read()
                end
            end
            return k
        end
        local type = rtypes[read()]
        local c

        if type == "nil" then
            read()
        elseif type == "boolean" then
            local d = read()
            c = d == "1" and true or false
        elseif type == "number" then
            local length = tonumber(get("."))
            local d = read(length+1):sub(2,-1)
            c = tonumber(d)
        elseif type == "string" then
            local length = tonumber(get(".")) --read()
            local d = read(length+1):sub(2,-1)
            c = d
		elseif type == "Vector3" then
			local function getnext()
				local length = hex_decode(read(2))
				local a = read(tonumber(length))
				return tonumber(a)
			end
			local x,y,z = getnext(),getnext(),getnext()
			c = Vector3.new(x, y, z)
		elseif type == "CFrame" then
			local a = {}
			for i = 1,12 do
				local l = hex_decode(read(2))
				local b = read(tonumber(l))
				a[i] = tonumber(b)
			end
			c = CFrame.new(unpack(a))
        elseif type == "Instance" then
			local pos = hex_decode(read(2))
			c = extra[tonumber(pos)]
		elseif type == "Color3" then
			local a = {}
			for i = 1,3 do
				local l = hex_decode(read(2))
				local b = read(tonumber(l))
				a[i] = tonumber(b)
			end
			c = Color3.new(unpack(a))
        end
        return c
    end

    function serialize(data, p)
		if data == nil then return end
        local type = typeof(data)
        if type == "table" then
            local extra = {}
            local s = types[type]
            local new = ""
            local p = p or 0
            for i,v in pairs(data) do
                local i1,v1
                local t0,t1 = typeof(i), typeof(v)

				local a,b
                if t0 == "Instance" then
                    p = p + 1
                    extra[p] = i
                    i1 = types[t0] .. hex_encode(p, 2)
                else
                    i1, a = encode(i, p)
					if a then
						for i,v in pairs(a) do
							extra[i] = v
						end
					end
                end
                
                if t1 == "Instance" then
                    p = p + 1
                    extra[p] = v
                    v1 = types[t1] .. hex_encode(p, 2)
                else
                    v1, b = encode(v, p)
					if b then
						for i,v in pairs(b) do
							extra[i] = v
						end
					end
                end
                new = new .. i1 .. v1
            end
            return s .. #new .. "." .. new, extra
		elseif type == "Instance" then
			return types[type] .. hex_encode(1, 2), {data}
        else
            return encode(data), {}
        end
    end

    function deserialize(data, extra)
		if data == nil then return end
		extra = extra or {}
		
        local type = rtypes[data:sub(1,1)]
        if type == "table" then

            local p = 0
            local function read(l)
                l = l or 1
                p = p + l
                return data:sub(p-l + 1, p)
            end
            local function get(a)
                local k = ""
                while p < #data do
                    if data:sub(p+1,p+1) == a then
                        break
                    else
                        k = k .. read()
                    end
                end
                return k
            end

            local length = tonumber(get("."):sub(2, -1))
            read()

            local new = {}

            local l = 0
            while p <= length do
                l = l + 1

				local function getnext()
					local i
                    local t = read()
                    local type = rtypes[t]

                    if type == "nil" then
                        i = decode(t .. read())
                    elseif type == "boolean" then
                        i = decode(t .. read())
                    elseif type == "number" then
                        local l = get(".")
                        
                        local dc = t .. l .. read()
                        local a = read(tonumber(l))
                        dc = dc .. a

                        i = decode(dc)
                 	elseif type == "string" then
                        local l = get(".")
                        local dc = t .. l .. read()
                        local a = read(tonumber(l))
                        dc = dc .. a

                        i = decode(dc)
					 elseif type == "Vector3" then
						local function getnext()
							local length = hex_decode(read(2))
							local a = read(tonumber(length))
							return tonumber(a)
						end
						local x,y,z = getnext(),getnext(),getnext()
						i = Vector3.new(x, y, z)
					elseif type == "CFrame" then
						local a = {}
						for i = 1,12 do
							local l = hex_decode(read(2))
							local b = read(tonumber(l)) -- why did I decide to do this
							a[i] = tonumber(b)
						end
						i = CFrame.new(unpack(a))
					elseif type == "Instance" then
						local pos = hex_decode(read(2))
						i = extra[tonumber(pos)]
					elseif type == "Color3" then
						local a = {}
						for i = 1,3 do
							local l = hex_decode(read(2))
							local b = read(tonumber(l))
							a[i] = tonumber(b)
						end
						i = Color3.new(unpack(a))
                    elseif type == "table" then
                        local l = get(".")
                        local dc = t .. l .. read() .. read(tonumber(l))
                        i = deserialize(dc, extra)
                    end
					return i
				end
                local i = getnext()
                local v = getnext()

               new[(typeof(i) ~= "nil" and i or l)] =  v
            end


            return new
		elseif type == "Instance" then
			local pos = tonumber(hex_decode(data:sub(2,3)))
			return extra[pos]
        else
            return decode(data, extra)
        end
    end
end


-- great you have come a far way now stop before my horrible scripting will infect you moron

do
    --/ Settings

    -- TODO: Other datatypes.
    settings.fileName = "AimHot_v8_settings.txt" -- Lovely
    settings.saved = {}

    function settings:Get(name, default)
        local self = {}
        local value = settings.saved[name]
        if value == nil and default ~= nil then
            value = default
            settings.saved[name] = value
            settings:Set(name, value)
        end
        self.Value = value
        function self:Set(val)
            self.Value = val
            settings.saved[name] = val
            settings:Set(name, val)
        end
        return self  --value or default
    end

    function settings:Set(name, value)
        local r = settings.saved[name]
        settings.saved[name] = value
        return r
    end

    function settings:Save()
        local savesettings = settings:GetAll() or {}
        local new = mergetab(savesettings, settings.saved)
        local js = serialize(new)

        writefile(settings.fileName, js)
    end

    function settings:GetAll()
        if not existsFile(settings.fileName) then
            return
        end
        local fileContents = readfile(settings.fileName)

        local data
        pcall(function()
            data = deserialize(fileContents)
        end)
        return data
    end

    function settings:Load()
        if not existsFile(settings.fileName) then
            return
        end
        local fileContents = readfile(settings.fileName)

        local data
        pcall(function()
            data = deserialize(fileContents)
        end)

        if data then
            data = mergetab(settings.saved, data)
        end
        settings.saved = data
        return data
    end
    settings:Load()
end

-- Aiming aim bot aim aim stuff bot

do
    --/ Aimbot

    -- Do I want to make this decent?
    local aimbot_settings = {}
    aimbot_settings.ignoreteam = settings:Get("aimbot.ignoreteam", true)
    aimbot_settings.sensitivity = settings:Get("aimbot.sensitivity", .5)
    aimbot_settings.locktotarget = settings:Get("aimbot.locktotarget", true)
    aimbot_settings.checkifalive = settings:Get("aimbot.checkifalive", true)

    aimbot_settings.ignorewalls = settings:Get("aimbot.ignorewalls", true)
    aimbot_settings.maxobscuringparts = settings:Get("aimbot.maxobscuringparts", 0)


    aimbot_settings.enabled = settings:Get("aimbot.enabled", false)
    aimbot_settings.keybind = settings:Get("aimbot.keybind", "MouseButton2")
    aimbot_settings.presstoenable = settings:Get("aimbot.presstoenable", true)

    aimbot_settings.fovsize = settings:Get("aimbot.fovsize", 400)
    aimbot_settings.fovenabled = settings:Get("aimbot.fovenabled", true)
    aimbot_settings.fovsides = settings:Get("aimbot.fovsides", 10)
    aimbot_settings.fovthickness = settings:Get("aimbot.fovthickness", 1)
    
    aimbot.fovshow = aimbot_settings.fovenabled.Value

    setmetatable(aimbot, {
        __index = function(self, index)
            if aimbot_settings[index] ~= nil then
                local Value = aimbot_settings[index]
                if typeof(Value) == "table" then
                    return typeof(Value) == "table" and Value.Value
                else
                    return Value
                end
            end
            warn(("AH8_ERROR : AimbotSettings : Tried to index %s"):format(tostring(index)))
        end;
        __newindex = function(self, index, value)
            if typeof(value) ~= "function" then
                if aimbot_settings[index] then
                    local v = aimbot_settings[index]
                    if typeof(v) ~= "table" then
                        aimbot_settings[index] = value
                        return
                    elseif v.Set then
                        v:Set(value)
                        return
                    end
                end
            end
            rawset(self, index, value)
        end;
    })


    local worldToScreenPoint = camera.WorldToScreenPoint
    local target, _, closestplr = nil, nil, nil;
    local completeStop = false

    local enabled = false
    bindEvent(uis.InputBegan, function(key,gpe)
        if aimbot.enabled == false then return end
        if aimbot.presstoenable then
            aimbot.fovshow = true
        else
            aimbot.fovshow = enabled == true
        end
        
        if gpe then return end
        local keyc = key.KeyCode == Enum.KeyCode.Unknown and key.UserInputType or key.KeyCode
        if keyc.Name == aimbot.keybind then
            if aimbot.presstoenable then
                enabled = true
                aimbot.fovshow = true
            else
                enabled = not enabled
                aimbot.fovshow = enabled == true
            end
        end
    end)
    bindEvent(uis.InputEnded, function(key)
        if aimbot.enabled == false then enabled = false aimbot.fovshow = false end
        if aimbot.presstoenable then
            aimbot.fovshow = true
        else
            aimbot.fovshow = enabled == true
        end

        local keyc = key.KeyCode == Enum.KeyCode.Unknown and key.UserInputType or key.KeyCode
        if keyc.Name == aimbot.keybind then
            if aimbot.presstoenable then
                enabled = false
            end
        end
    end)


    local function calculateTrajectory()
        -- my math is a bit rusty
    end

    local function aimAt(vector)
        if completeStop then return end
        local newpos = worldToScreenPoint(camera, vector)
        mousemoverel((newpos.X - mouse.X) * aimbot.sensitivity, (newpos.Y - mouse.Y) * aimbot.sensitivity)
    end

    function aimbot.step()
        if completeStop or aimbot.enabled == false or enabled == false or mycharacter == nil or mycharacter:IsDescendantOf(game)== false then 
            if target or closestplr then
                target, closestplr, _ = nil, nil, _
            end
            return 
        end
        
        if aimbot.locktotarget == true then
            if target == nil or target:IsDescendantOf(game) == false or closestplr == nil or closestplr.Parent == nil or closestplr.Character == nil or closestplr.Character:IsDescendantOf(game) == false then
                target, _, closestplr = utility.getClosestMouseTarget({ -- closest to mouse or camera mode later just wait
                    ignoreteam = aimbot.ignoreteam;
                    ignorewalls = aimbot.ignorewalls;
                    maxobscuringparts = aimbot.maxobscuringparts;
                    name = 'Head';
                    fov = aimbot.fovsize;
                    checkifalive = aimbot.checkifalive;
                    -- mode = "mouse";
                })
            else
                --target = target
                local stop = false
                if stop == false and not (aimbot.ignoreteam==true and utility.sameteam(closestplr)==false or aimbot.ignoreteam == false) then
                    stop = true
                end
                local visible = true

                if stop == false and aimbot.ignorewalls == false then
                    local vis = utility.isvisible(target.Parent, target, (aimbot.maxobscuringparts or 0))
                    if not vis then
                        stop = true
                    end
                end

                if stop == false and aimbot.checkifalive then
                    local isalive = utility.isalive(character, part)
                    if not isalive then
                        stop = true
                    end
                end
                


                if stop then
                    target, _, closestplr = utility.getClosestMouseTarget({ -- closest to mouse or camera mode later just wait
                        ignoreteam = aimbot.ignoreteam;
                        ignorewalls = aimbot.ignorewalls;
                        maxobscuringparts = aimbot.maxobscuringparts;
                        name = 'Head';
                        fov = aimbot.fovsize;
                        checkifalive = aimbot.checkifalive;
                        -- mode = "mouse";
                    })
                end
            end
        else
            target = utility.getClosestMouseTarget({ -- closest to mouse or camera mode later just wait
                ignoreteam = aimbot.ignoreteam;
                ignorewalls = aimbot.ignorewalls;
                maxobscuringparts = aimbot.maxobscuringparts;
                name = 'Head';
                fov = aimbot.fovsize;
                checkifalive = aimbot.checkifalive;
                -- mode = "mouse";
            })
        end

        if target then
            aimAt(target:GetRenderCFrame().Position)
        end
    end

    function aimbot:End()
        completeStop = true
        target = nil
    end
end


-- Mostly visuals below here
do
    --/ Drawing extra functions

    local insert = table.insert
    local newd = drawing.new

    local drawn = {}
    function clearDrawn() -- who doesnt love drawing library
        for i,v in pairs(drawn) do
            pcall(function() v:Remove() end)
            drawn[i] = nil
        end
        drawn = {}
    end

    function newdrawing(class, props)
        --if visuals.enabled ~= true then
        --    return
        --end
        local new = newd(class)
        for i,v in pairs(props) do
            new[i] = v
        end
        insert(drawn, new)
        return new
    end
end


do
    --/ Crosshair
    local crosshair_settings = {}
    crosshair_settings.enabled = settings:Get("crosshair.enabled", false)
    crosshair_settings.size = settings:Get("crosshair.size", 40)
    crosshair_settings.thickness = settings:Get("crosshair.thickness", 1)
    crosshair_settings.color = Color3.fromRGB(255,0,0)
    crosshair_settings.transparency = settings:Get("crosshair.transparency", .1)

    setmetatable(crosshair, {
        __index = function(self, index)
            if crosshair_settings[index] ~= nil then
                local Value = crosshair_settings[index]
                if typeof(Value) == "table" then
                    return typeof(Value) == "table" and Value.Value
                else
                    return Value
                end
            end
            warn(("AH8_ERROR : CrosshairSettings : Tried to index %s"):format(tostring(index)))
        end;
        __newindex = function(self, index, value)
            if typeof(value) ~= "function" then
                if crosshair_settings[index] then
                    local v = crosshair_settings[index]
                    if typeof(v) ~= "table" then
                        crosshair_settings[index] = value
                        return
                    elseif v.Set then
                        v:Set(value)
                        return
                    end
                end
            end
            rawset(self, index, value)
        end;
    })

    local crossHor
    local crossVer

    local camera = workspace.CurrentCamera
    local vpSize = camera.ViewportSize

    local completeStop = false
    local function drawCrosshair()
        if completeStop then return crosshair:Remove() end
        if crossHor ~= nil or crossVer ~= nil then
            return
        end

        local self = {
            Visible = true;
            Transparency = (1 - crosshair.transparency);
            Thickness = crosshair.thickness;
            Color = crosshair.color;
        }

        if crosshair.enabled ~= true then
            self.Visible = false
        end
        local h,v = newdrawing("Line", self), newdrawing("Line", self)

        if self.Visible then
            local vpSize = camera.ViewportSize/2
            local size = crosshair.size/2
            local x,y = vpSize.X, vpSize.Y

            h.From = v2new(x - size, y)
            h.To = v2new(x + size, y)
            
            v.From = v2new(x, y - size)
            v.To = v2new(x, y + size)
        end

        crossHor = h
        crossVer = v
    end

    local function updateCrosshair()
        if completeStop then return end

        if crossHor == nil or crossVer == nil then
            return drawCrosshair()
        end

        local visible = crosshair.enabled

        crossHor.Visible = visible
        crossVer.Visible = visible

        if visible then
            local vpSize = camera.ViewportSize / 2
            local size = crosshair.size/2
            local x,y = vpSize.X, vpSize.Y

            local color = crosshair.color
            crossHor.Color = color
            crossVer.Color = color
            
            local trans = (1 - crosshair.transparency)
            crossHor.Transparency = trans
            crossVer.Transparency = trans

            local thick = crosshair.thickness
            crossHor.Thickness = thick
            crossVer.Thickness = thick

            crossHor.From = v2new(x - size, y)
            crossHor.To = v2new(x + size, y)
        
            crossVer.From = v2new(x, y - size)
            crossVer.To = v2new(x, y + size)
        end
    end

    function crosshair:Remove()
        if crossHor ~= nil then
            crossHor:Remove()
            crossHor = nil
        end
        if crossVer ~= nil then
            crossVer:Remove()
            crossVer = nil
        end
    end

    function crosshair:End()
        completeStop = true
        if crossHor ~= nil then
            crossHor:Remove()
            crossHor = nil
        end
        if crossVer ~= nil then
            crossVer:Remove()
            crossVer = nil
        end
        crosshair.enabled = false
    end

    crosshair.step = updateCrosshair
    --function crosshair.step()
    --    updateCrosshair()        
    --end
end


do
    --/ Tracers

    local tracers_settings = {}
    tracers_settings.enabled = settings:Get("tracers.enabled", false)
    tracers_settings.origin = v2new(camera.ViewportSize.X/2, camera.ViewportSize.Y)
    tracers_settings.fromMouse = settings:Get("tracers.frommouse", true)
    tracers_settings.transparency = .6
    tracers_settings.thickness = 1.5
    tracers_settings.showteam = settings:Get("tracers.showteam", false)

    tracers_settings.drawdistance = settings:Get("tracers.drawdistance", 4000)

    tracers_settings.enemycolor = Color3.fromRGB(255,0,0)
    tracers_settings.teamcolor = Color3.fromRGB(0,255,0)

    setmetatable(tracers, {
        __index = function(self, index)
            if tracers_settings[index] ~= nil then
                local Value = tracers_settings[index]
                if typeof(Value) == "table" then
                    return typeof(Value) == "table" and Value.Value
                else
                    return Value
                end
            end
            warn(("AH8_ERROR : TracersSettings : Tried to index %s"):format(tostring(index)))
        end;
        __newindex = function(self, index, value)
            if typeof(value) ~= "function" then
                if tracers_settings[index] then
                    local v = tracers_settings[index]
                    if typeof(v) ~= "table" then
                        tracers_settings[index] = value
                        return
                    elseif v.Set then
                        v:Set(value)
                        return
                    end
                end
            end
            rawset(self, index, value)
        end;
    })

    local worldToViewportPoint = camera.WorldToViewportPoint

    local completeStop = false
    local drawn = {}

    local function drawTemplate(player)
        if completeStop then return end
        if player == nil then return end

        if drawn[player] then
            return drawn[player]
           --tracers:Remove(player)
        end


        local a = newdrawing("Line", {
            Color = tracers.enemycolor;
            Thickness = tracers.thickness;
            Transparency = 1 - tracers.transparency;
            Visible = false;
        })
        drawn[player] = a
        return a
    end

    function tracers:Draw(player, character, root, humanoid, onscreen, isteam, dist)
        if completeStop then return end

        if tracers.enabled ~= true then return tracers:Remove(player) end
        if character == nil then return tracers:Remove(player) end

        if tracers.showteam~=true and isteam then return tracers:Remove(player) end

        if root == nil then return tracers:Remove(player) end

        if dist then
            if dist > tracers.drawdistance then
                return tracers:Remove(player)
            end
        end

        local screenpos = worldToViewportPoint(camera, root.Position)

        local line
        if drawn[player] ~= nil then
            line = drawn[player]
        elseif onscreen then
            line = drawTemplate(player)
        end
        if line then
            if onscreen then
                line.From = tracers.origin
                line.To = v2new(screenpos.X, screenpos.Y)
                line.Color = isteam and tracers.teamcolor or tracers.enemycolor
            end
            line.Visible = onscreen
        end
        --return line
    end

    function tracers:Hide(player)
        if completeStop then return end
        if player == nil then return end

        local line = drawn[player]
        if line then
            line.Visible = false
        end
    end

    function tracers:Remove(player)
        if player == nil then return end

        if drawn[player] ~= nil then
            drawn[player]:Remove()
            drawn[player] = nil
        end
    end

    function tracers:RemoveAll()
        for i,v in pairs(drawn) do
            pcall(function()
                v:Remove()
            end)
            drawn[i] = nil
        end
        drawn = {}
    end
    function tracers:End()
        completeStop = true
        for i,v in pairs(drawn) do
            pcall(function()
                v:Remove()
            end)
            drawn[i] = nil
        end
        drawn = {}
    end
end


do
    --/ ESP
    local esp_settings = {}

    esp_settings.enabled = settings:Get("esp.enabled", false)
    esp_settings.showteam = settings:Get("esp.showteam", false)
    
    esp_settings.teamcolor = Color3.fromRGB(0,255,0)
    esp_settings.enemycolor = Color3.fromRGB(255,0,0)
    
    esp_settings.size = settings:Get("esp.size", 16)
    esp_settings.centertext = settings:Get("esp.centertext", true)
    esp_settings.outline = settings:Get("esp.outline", true)
    esp_settings.transparency = settings:Get("esp.transparency", 0.1)

    esp_settings.drawdistance = settings:Get("esp.drawdistance", 1500)

    esp_settings.yoffset = settings:Get("esp.yoffset", 0)

    esp_settings.showhealth = settings:Get("esp.showhealth", true)
    esp_settings.showdistance = settings:Get("esp.showdistance", true)


    setmetatable(esp, {
        __index = function(self, index)
            if esp_settings[index] ~= nil then
                local Value = esp_settings[index]
                if typeof(Value) == "table" then
                    return typeof(Value) == "table" and Value.Value
                else
                    return Value
                end
            end
            warn(("AH8_ERROR : EspSettings : Tried to index %s"):format(tostring(index)))
        end;
        __newindex = function(self, index, value)
            if typeof(value) ~= "function" then
                if esp_settings[index] then
                    local v = esp_settings[index]
                    if typeof(v) ~= "table" then
                        esp_settings[index] = value
                        return
                    elseif v.Set then
                        v:Set(value)
                        return
                    end
                end
            end
            rawset(self, index, value)
        end;
    })

    local unpack = unpack
    local findFirstChild = Instance.new("Part").FindFirstChild
    local worldToViewportPoint = camera.WorldToViewportPoint
    local getBoundingBox = Instance.new("Model").GetBoundingBox
    local getExtentsSize = Instance.new("Model").GetExtentsSize

    local floor = math.floor
    local insert = table.insert
    local concat = table.concat

    local drawn = {}
    local completeStop = false

    local function drawTemplate(player)
        if completeStop then return end
        if player == nil then return end

        if drawn[player] then return drawn[player] end


        local obj = newdrawing("Text", {
            Text = "n/a",
            Size = esp.size,
            Color = esp.enemycolor,
            Center = esp.centertext,
            Outline = esp.outline,
            Transparency = (1 - esp.transparency),
        })
        return obj
    end

    function esp:Draw(player, character, root, humanoid, onscreen, isteam, dist)
        if completeStop then return end
        if player == nil then return end
        if character == nil then return esp:Remove(player) end
        if root == nil then return esp:Remove(player) end

        if dist then
            if dist > esp.drawdistance then
                return esp:Remove(player)
            end
        end

        local where, isvis = worldToViewportPoint(camera, (root.CFrame * esp.offset).p);
        if not isvis then return esp:Remove(player) end

        if esp.showteam~=true and isteam then return esp:Remove(player) end

        local oesp = drawn[player]
        if oesp == nil then
            oesp = drawTemplate(player)
            drawn[player] = oesp
        end
        
        if oesp then
            oesp.Position = v2new(where.X, where.Y)
            oesp.Color = isteam and boxes.teamcolor or boxes.enemycolor
            oesp.Center = esp.centertext
            oesp.Size = esp.size
            oesp.Outline = esp.outline
            oesp.Transparency = (1 - esp.transparency)

            local texts = {
                player.Name,
            }
            
            local b = humanoid and esp.showhealth and ("%s/%s"):format(floor(humanoid.Health + .5), floor(humanoid.MaxHealth + .5))
            if b then
                insert(texts, b)
            end
            local c = dist and esp.showdistance and ("%s"):format(floor(dist + .5))
            if c then
                insert(texts, c)
            end

            local text = "[  " .. concat(texts, " | ") .. " ]"
            oesp.Text = text

            oesp.Visible = isvis
        end
    end

    function esp:Remove(player)
        if player == nil then return end

        local data = drawn[player]
        if data ~= nil then
            data:Remove()
            drawn[player] = nil
        end
    end

    function esp:RemoveAll()
        for i,v in pairs(drawn) do
            pcall(function() v:Remove() end)
            drawn[i] = nil
        end
    end

    function esp:End()
        completeStop = true
        esp:RemoveAll()
    end
end


do
    --/ Boxes

    local boxes_settings = {}
    boxes_settings.enabled = settings:Get("boxes.enabled", false)
    boxes_settings.transparency = settings:Get("boxes.transparency", .2)
    boxes_settings.thickness = settings:Get("boxes.thickness", 1.5)

    boxes_settings.showteam = settings:Get("boxes.showteam", false)
    boxes_settings.teamcolor = Color3.fromRGB(0,255,0)
    boxes_settings.enemycolor = Color3.fromRGB(255,0,0)

    boxes_settings.thirddimension = settings:Get("boxes.thirddimension", false)


    boxes_settings.dist3d = settings:Get("boxes.dist3d", 1000)
    boxes_settings.drawdistance = settings:Get("boxes.drawdistance", 4000)
    boxes_settings.color = Color3.fromRGB(255, 50, 50)

    setmetatable(boxes, {
        __index = function(self, index)
            if boxes_settings[index] ~= nil then
                local Value = boxes_settings[index]
                if typeof(Value) == "table" then
                    return typeof(Value) == "table" and Value.Value
                else
                    return Value
                end
            end
            warn(("AH8_ERROR : BoxesSettings : Tried to index %s"):format(tostring(index)))
        end;
        __newindex = function(self, index, value)
            if typeof(value) ~= "function" then
                if boxes_settings[index] then
                    local v = boxes_settings[index]
                    if typeof(v) ~= "table" then
                        boxes_settings[index] = value
                        return
                    elseif v.Set then
                        v:Set(value)
                        return
                    end
                end
            end
            rawset(self, index, value)
        end;
    })

    local unpack = unpack
    local findFirstChild = Instance.new("Part").FindFirstChild
    local worldToViewportPoint = camera.WorldToViewportPoint
    local getBoundingBox = Instance.new("Model").GetBoundingBox
    local getExtentsSize = Instance.new("Model").GetExtentsSize

    local completeStop = false
    local drawn = {}
    local function drawTemplate(player, amount)
        if completeStop then return end
        if player == nil then return end

        if drawn[player] then
            if #drawn[player] == amount then
                return drawn[player]
            end
            boxes:Remove(player)
        end

        local props = {
            Visible = true;
            Transparency = 1 - boxes.transparency;
            Thickness = boxes.thickness;
            Color = boxes.color;
        }

        local a = {}
        for i = 1,amount or 4 do
            a[i] = newdrawing("Line", props)
        end

        drawn[player] = {unpack(a)}
        return unpack(a)
    end

    function boxes:Draw(player, character, root, humanoid, onscreen, isteam, dist)
        if completeStop then return end
        if character == nil then return boxes:Remove(player) end
        if root == nil then return boxes:Remove(player) end


        local _3dimension = boxes.thirddimension
        if dist ~= nil then
            if dist > boxes.drawdistance then
                return boxes:Remove(player)
            elseif _3dimension and dist > boxes.dist3d then
                _3dimension = false
            end
        end

        if not onscreen then
           return boxes:Remove(player)
        end

        --[[if boxes.onlyvisible 
            if not utility.isvisible(character, root, 0) then
                return boxes:Remove(player)
            end
        end--]]
        if boxes.showteam~=true and isteam then return boxes:Remove(player) end


        local color = isteam and boxes.teamcolor or boxes.enemycolor
        local function updateLine(line, from, to, vis)
            if line == nil then return end

            if vis then
                line.From = from
                line.To = to
                line.Color = color
            end
            line.Visible = vis
        end

        --size = ... lastsize--, v3new(5,8,0) --getBoundingBox(character)--]] root.CFrame, getExtentsSize(character)--]] -- Might change this later idk + idc
        if _3dimension then

            local tlb, trb, blb, brb, tlf, trf, blf, brf, tlf0, trf0, blf0, brf0
            if drawn[player] == nil or #drawn[player] ~= 12 then
                tlb, trb, blb, brb, tlf, trf ,blf, brf, tlf0, trf0, blf0, brf0 = drawTemplate(player, 12)
            else
                tlb, trb, blb, brb, tlf, trf ,blf, brf, tlf0, trf0, blf0, brf0 = unpack(drawn[player])
            end

            local pos, size = root.CFrame, root.Size--lastsize--, v3new(5,8,0)

            local topleftback, topleftbackvisible = worldToViewportPoint(camera, (pos * cfnew(-size.X, size.Y, size.Z)).p);
            local toprightback, toprightbackvisible = worldToViewportPoint(camera, (pos * cfnew(size.X, size.Y, size.Z)).p);
            local btmleftback, btmleftbackvisible = worldToViewportPoint(camera, (pos * cfnew(-size.X, -size.Y, size.Z)).p);
            local btmrightback, btmrightbackvisible = worldToViewportPoint(camera, (pos * cfnew(size.X, -size.Y, size.Z)).p);

            local topleftfront, topleftfrontvisible = worldToViewportPoint(camera, (pos * cfnew(-size.X, size.Y, -size.Z)).p);
            local toprightfront, toprightfrontvisible = worldToViewportPoint(camera, (pos * cfnew(size.X, size.Y, -size.Z)).p);
            local btmleftfront, btmleftfrontvisible = worldToViewportPoint(camera, (pos * cfnew(-size.X, -size.Y, -size.Z)).p);
            local btmrightfront, btmrightfrontvisible = worldToViewportPoint(camera, (pos * cfnew(size.X, -size.Y, -size.Z)).p);

            local topleftback = v2new(topleftback.X, topleftback.Y)
            local toprightback = v2new(toprightback.X, toprightback.Y)
            local btmleftback = v2new(btmleftback.X, btmleftback.Y)
            local btmrightback = v2new(btmrightback.X, btmrightback.Y)

            local topleftfront = v2new(topleftfront.X, topleftfront.Y)
            local toprightfront = v2new(toprightfront.X, toprightfront.Y)
            local btmleftfront = v2new(btmleftfront.X, btmleftfront.Y)
            local btmrightfront = v2new(btmrightfront.X, btmrightfront.Y)


			updateLine(tlb, topleftback, toprightback, topleftbackvisible)
            updateLine(trb, toprightback, btmrightback, toprightbackvisible)
            updateLine(blb, btmleftback, topleftback, btmleftbackvisible)
            updateLine(brb, btmleftback, btmrightback, btmrightbackvisible)

            --

            updateLine(brf, btmrightfront, btmleftfront, btmrightfrontvisible)
            updateLine(tlf, topleftfront, toprightfront, topleftfrontvisible)
            updateLine(trf, toprightfront, btmrightfront, toprightfrontvisible)
            updateLine(blf, btmleftfront, topleftfront, btmleftfrontvisible)

            --

            updateLine(brf0, btmrightfront, btmrightback, btmrightfrontvisible)
            updateLine(tlf0, topleftfront, topleftback, topleftfrontvisible)
            updateLine(trf0, toprightfront, toprightback, toprightfrontvisible)
            updateLine(blf0, btmleftfront, btmleftback, btmleftfrontvisible)

        else

            local tl, tr, bl, br
            if drawn[player] == nil or #drawn[player] ~= 4 then
                tl, tr, bl, br = drawTemplate(player, 4)
            else
                tl, tr, bl, br = unpack(drawn[player])
            end

            local pos, size = root.CFrame, root.Size

            local topleft, topleftvisible = worldToViewportPoint(camera, (pos * cfnew(-size.X, size.Y, 0)).p);
            local topright, toprightvisible = worldToViewportPoint(camera, (pos * cfnew(size.X, size.Y, 0)).p);
            local btmleft, btmleftvisible = worldToViewportPoint(camera, (pos * cfnew(-size.X, -size.Y, 0)).p);
            local btmright, btmrightvisible = worldToViewportPoint(camera, (pos * cfnew(size.X, -size.Y, 0)).p);

            local topleft = v2new(topleft.X, topleft.Y)
            local topright = v2new(topright.X, topright.Y)
            local btmleft = v2new(btmleft.X, btmleft.Y)
            local btmright = v2new(btmright.X, btmright.Y)

            updateLine(tl, topleft, topright, topleftvisible)
            updateLine(tr, topright, btmright, toprightvisible)
            updateLine(bl, btmleft, topleft, btmleftvisible)
            updateLine(br, btmleft, btmright, btmrightvisible)
        end


        -- I have never been more bored when doing 3d boxes.
    end


    function boxes:Hide(player) -- A bit slow may remove later
        if completeStop then return end
        if player == nil then return end

        local data = drawn[player]
        if data ~= nil then
            for i,v in pairs(data) do
                if v.Visible then v.Visible = false end
            end
        end
    end

    function boxes:Remove(player)
        if player == nil then return end

        local data = drawn[player]
        if data == nil then return end

        if data then
            for i,v in pairs(data) do
                v:Remove()
                data[i] = nil
            end
        end
        drawn[player] = nil
    end

    function boxes:RemoveAll()
        for i,v in pairs(drawn) do
            pcall(function()
                for i2,v2 in pairs(v) do
                    v2:Remove()
                    v[i] = nil
                end
            end)
            drawn[i] = nil
        end
        drawn = {}
    end

    function boxes:End()
        completeStop = true
        for i,v in pairs(drawn) do
            for i2,v2 in pairs(v) do
                pcall(function()
                    v2:Remove()
                    v[i2] = nil
                end)
            end
            drawn[i] = nil
        end
        drawn = {}
    end
end


do
    --/ Visuals

    visuals.enabled = settings:Get("visuals.enabled", true)

    local getPlayers = players.GetPlayers

    local credits
    local circle

    local completeStop = false
    bindEvent(players.PlayerRemoving, function(p)
        if completeStop then return end
        tracers:Remove(p)
        boxes:Remove(p)
        esp:Remove(p)
    end)

    local profilebegin = DEBUG_MODE and debug.profilebegin or function() end
    local profileend = DEBUG_MODE and debug.profileend or function() end


    local unpack = unpack
    local findFirstChild = Instance.new("Part").FindFirstChild
    local worldToViewportPoint = camera.WorldToViewportPoint

    local hashes = {}

    function visuals.step()
        --if visuals.enabled ~= true then return clearDrawn() end
        if completeStop then return end


        local viewportsize = camera.ViewportSize
        if credits == nil then
            credits = newdrawing("Text", {
                Text = "AimHot v8, Herrtt#3868"; -- yes now be happy this is free
                Color = Color3.new(255,255,255);
                Size = 25.0;
                Transparency = .8;
                Position = v2new(viewportsize.X/8, 6);
                Outline = true;
                Visible = true;
            })
        else
            credits.Position = v2new(viewportsize.X/8, 6);
        end

        if aimbot.enabled and aimbot.fovenabled and visuals.enabled then
            profilebegin("fov.step")
            if circle == nil then
                circle = newdrawing("Circle", {
                    Position = v2new(mouse.X, mouse.Y+35),
                    Radius = aimbot.fovsize,
                    Color = Color3.fromRGB(240,240,240),
                    Thickness = aimbot.fovthickness,
                    Filled = false,
                    Transparency = .8,
                    NumSides = aimbot.fovsides,
                    Visible = aimbot.fovshow;
                })
            else
                if aimbot.fovshow then                    
                    circle.Position = v2new(mouse.X, mouse.Y+35)
                    circle.Radius = aimbot.fovsize
                    circle.NumSides = aimbot.fovsides
                    circle.Thickness = aimbot.fovthickness
                end
                circle.Visible = aimbot.fovshow
            end
            profileend("fov.step")
        elseif circle ~= nil then
            circle:Remove()
            circle = nil
        end

        if visuals.enabled and crosshair.enabled then
            profilebegin("crosshair.step")
            crosshair.step()
            profileend("crosshair.step")
        else
            crosshair:Remove()
        end

        if visuals.enabled and (esp.enabled or boxes.enabled or tracers.enabled) then
            profilebegin("tracers.origin")
            if tracers.fromMouse then 
                tracers.origin = v2new(mouse.X, mouse.Y+35) -- thanks roblox
            else
                tracers.origin = v2new(viewportsize.X/2, viewportsize.Y)
            end
            profileend("tracers.origin")

            if esp.enabled then
                esp.offset = cfnew(0, esp.yoffset, 0)
            end

            for i,v in pairs(getPlayers(players)) do
                if (v~=locpl) then
                    local character = v.Character
                    if character then
                        local root = hashes[v] or findFirstChild(character, "HumanoidRootPart") or character.PrimaryPart
                        local humanoid = findFirstChildOfClass(character, "Humanoid")
                        if root then
                            local _, onscreen = worldToViewportPoint(camera, root.Position)
                            local dist = myroot and (myroot.Position - root.Position).Magnitude
                            local isteam = (v.Team~=nil and v.Team==locpl.Team) and not v.Neutral or false

                            if boxes.enabled then
                                profilebegin("boxes.draw")
                                boxes:Draw(v, character, root, humanoid, onscreen, isteam, dist)
                                profileend("boxes.draw")
                            else
                                boxes:Remove(v)
                            end
                            if tracers.enabled then
                                profilebegin("tracers.draw")
                                tracers:Draw(v, character, root, humanoid, onscreen, isteam, dist)
                                profileend("tracers.draw")
                            else
                                tracers:Remove(v)
                            end
        
                            if esp.enabled then
                                profilebegin("esp.draw")
                                esp:Draw(v, character, root, humanoid, onscreen, isteam, dist)
                                profileend("esp.draw")
                            else
                                esp:Remove(v)
                            end
                        end
                    end
                end
            end
        else
            tracers:RemoveAll()
            boxes:RemoveAll()
            esp:RemoveAll()
            crosshair:Remove()
        end
    end

    function visuals:End()
        completeStop = true
        crosshair:End()
        boxes:End()
        tracers:End()
        esp:End()

        clearDrawn()
    end

    spawn(function()
        while ah8 and ah8.enabled do
            for i,v in pairs(hashes) do
                hashes[i] = nil
                wait()
            end
            hashes = {}
            lastsize = nil
            wait(3)
        end
    end)
end



-- Ok yes
do
    --/ Run

    local pcall = pcall;
    local tostring = tostring;
    local warn = warn;
    local debug = debug;
    local profilebegin = DEBUG_MODE and debug.profilebegin or function() end
    local profileend = DEBUG_MODE and debug.profileend or function() end

    local renderstep = runservice.RenderStepped
    local heartbeat = runservice.Heartbeat
    local stepped = runservice.Stepped
    local wait = renderstep.wait

    run.dt = 0
    run.time = tick()

    local engine = {
        {
            name = 'visuals.step',
            func = visuals.step
        };
    }
    local heartengine = {
        {
            name = 'aimbot.step',
            func = aimbot.step
        };
    }
    local whilerender = {
    }

    run.onstep = {}
    run.onthink = {}
    run.onrender = {}
    function run.wait()
        wait(renderstep)
    end

    local fireonstep = event.new(run.onstep)
    local fireonthink = event.new(run.onthink)
    local fireonrender = event.new(run.onrender)

    local rstname = "AH.Renderstep"
    bindEvent(renderstep, function(delta)
        profilebegin(rstname)
        local ntime = tick()
        run.dt = ntime - run.time
        run.time = ntime

        for i,v in pairs(engine) do

            profilebegin(v.name)
            local suc, err = pcall(v.func, run.dt)
            profileend(v.name)
            if not suc then
                warn("AH8_ERROR : Failed to run " .. v.name .. "! " .. tostring(err))
                engine[i] = nil
            end
        end

        profileend(rstname)
    end)

    local hbtname = "AH.Heartbeat"
    bindEvent(heartbeat, function(delta)
        profilebegin(hbtname)

        for i,v in pairs(heartengine) do

            profilebegin(v.name)
            local suc, err = pcall(v.func, delta)
            profileend(v.name)
            if not suc then
                warn("Failed to run " .. v.name .. "! " .. tostring(err))
            end
        end

        profileend(hbtname)
    end)

    local stpname = "AH.Stepped"
    bindEvent(stepped, function(delta)
        
        profilebegin(stpname)

        for i,v in pairs(whilerender) do

            profilebegin(v.name)
            local suc, err = pcall(v.func, delta)
            profileend(v.name)
            if not suc then
                warn("Failed to run " .. v.name .. "! " .. tostring(err))
            end
        end

        profileend(stpname)
    end)
end

do
    --/ Main or something I am not sure what I am writing anymore
    settings:Save()

    ah8.enabled = true
    function ah8:close()
        spawn(function() pcall(visuals.End, visuals) end)
        spawn(function() pcall(aimbot.End, aimbot) end)
        spawn(function() pcall(hud.End, hud) end)

        spawn(function()
            for i,v in pairs(connections) do
                pcall(function() v:Disconnect() end)
            end
        end)
        ah8 = nil
        shared.ah8 = nil

        settings:Save()
    end

    shared.ah8 = ah8

    local players = game:GetService("Players")
    local loc = players.LocalPlayer
    bindEvent(players.PlayerRemoving, function(p)
        if p == loc then
            settings:Save()
        end
    end)

end


local Aiming = hud:AddTab({
	Text = "Aiming",
})


local AimbotToggle = Aiming:AddToggleCategory({
	Text = "Aimbot",
	State = aimbot.enabled,
}, function(state) 
    aimbot.enabled = state
end)


AimbotToggle:AddKeybind({
	Text = "keybind",
	Current = aimbot.keybind,
}, function(new)
    aimbot.keybind = new.Name 
end)

 
AimbotToggle:AddToggle({
	Text = "Press To Enable",
	State = aimbot.presstoenable,
}, function(state) 
    aimbot.presstoenable = state
end)

AimbotToggle:AddToggle({
	Text = "Lock To Target",
	State = aimbot.locktotarget,
}, function(state) 
    aimbot.locktotarget = state
end)


AimbotToggle:AddToggle({
	Text = "Check If Alive",
	State = aimbot.checkifalive,
}, function(state) 
    aimbot.checkifalive = state
end)

-- settings stuff
local AimbotSettings = Aiming:AddCategory({
	Text = "Settings",
})

AimbotSettings:AddSlider({
    Text = "Sensitivity",
    Current = aimbot.sensitivity
}, {0.01, 10, 0.01}, function(new) 
    aimbot.sensitivity = new
end)

AimbotSettings:AddToggle({
    Text = "Ignore Team",
    State = aimbot.ignoreteam
}, function(new)
    aimbot.ignoreteam = new
end)


AimbotSettings:AddToggle({
    Text = "Ignore Walls",
    State = aimbot.ignorewalls
}, function(new)
    aimbot.ignorewalls = new
end)

AimbotSettings:AddSlider({
    Text = "Max Obscuring Parts",
    Current = aimbot.maxobscuringparts,
}, {0, 10, 1}, function(new)
    aimbot.maxobscuringparts = new
end)



local FieldOfView = Aiming:AddToggleCategory({
    Text = "fov",
    State = aimbot.fovenabled,
}, function(state) 
    aimbot.fovenabled = state
end)

FieldOfView:AddSlider({
    Text = "Radius",
    Current = aimbot.fovsize,
}, {1, 1000, 1}, function(new)
    aimbot.fovsize = new
end)

FieldOfView:AddSlider({
    Text = "Sides",
    Current = aimbot.fovsides,
}, {6, 40, 1}, function(new)
    aimbot.fovsides = new
end)


FieldOfView:AddSlider({
    Text = "Thickness",
    Current = aimbot.fovthickness,
}, {0.1, 50, 0.1}, function(new)
    aimbot.fovthickness = new
end)



local Visuals = hud:AddTab({
    Text = "Visuals"
})

Visuals:AddToggle({
    Text = "Enabled",
    State = visuals.enabled,
}, function(new)
    visuals.enabled = new
end)

local Boxes = Visuals:AddToggleCategory({
    Text = "Boxes",
    State = boxes.enabled,
}, function(new)
    boxes.enabled = new
end)

Boxes:AddToggle({
    Text = "Show Team",
    State = boxes.showteam,
}, function(new)
    boxes.showteam = new
end)

Boxes:AddToggle({
    Text = "3d",
    State = boxes.thirddimension,
}, function(new)
    boxes.thirddimension = new
end)

Boxes:AddSlider({
    Text = "Draw Distance",
    Current = boxes.drawdistance,
}, {5,10000,5}, function(new)
    boxes.drawdistance = new
end)

Boxes:AddSlider({
    Text = "3d distance",
    Current = boxes.dist3d,
}, {5,10000,5}, function(new)
    boxes.dist3d = new
end)


local Esp = Visuals:AddToggleCategory({
    Text = "Esp",
    State = esp.enabled,
}, function(new)
    esp.enabled = new
end)

Esp:AddSlider({
    Text = "Size",
    Current = esp.size,
}, {1, 100, 1}, function(new)
    esp.size = new
end)

Esp:AddSlider({
    Text = "Transparency",
    Current = esp.transparency
}, {0, 1, 0.01}, function(new)
    esp.transparency = new
end)

Esp:AddSlider({
    Text = "Draw Distance",
    Current = esp.drawdistance
}, {5,10000,5}, function(new)
    esp.drawdistance = new
end)

Esp:AddSlider({
    Text = "Offset",
    Current = esp.yoffset,
}, {-50, 50, 0.01}, function(new)
    esp.yoffset = new
end)


Esp:AddToggle({
    Text = "Center Text",
    State = esp.centertext
}, function(new)
    esp.centertext = new
end)

Esp:AddToggle({
    Text = "Outline",
    State = esp.outline,
}, function(new)
    esp.outline = new
end)

Esp:AddToggle({
    Text = "Show Team",
    State = esp.showteam
}, function(new)
    esp.showteam = new
end)



local Tracers = Visuals:AddToggleCategory({
    Text = "Tracers",
    State = tracers.enabled,
}, function(new)
    tracers.enabled = new
end)

Tracers:AddToggle({
    Text = "Show Team",
    State = tracers.showteam
}, function(new)
    tracers.showteam = new
end)

Tracers:AddSlider({
    Text = "Draw Distance",
    Current = tracers.drawdistance,
}, {5,10000,5}, function(new)
    tracers.drawdistance = new
end)

local Crosshair = Visuals:AddToggleCategory({
    Text = "Crosshair",
    State = crosshair.enabled,
}, function(new)
    crosshair.enabled = new
end)

Crosshair:AddSlider({
    Text = "Size",
    Current = crosshair.size,
}, {1,2000,1}, function(new)
    crosshair.size = new
end)

Crosshair:AddSlider({
    Text = "Thickness",
    Current = crosshair.thickness
}, {1,50,1}, function(new)
    crosshair.thickness = new
end)

Crosshair:AddSlider({
    Text = "Transparency",
    Current = crosshair.transparency
}, {0,1,0.01}, function(new)
    crosshair.transparency = new
end)


local Hud = hud:AddTab({
    Text = "Hud",
})

hud.Keybind = settings:Get("hud.keybind", "RightAlt").Value
Hud:AddKeybind({
    Text = "Toggle",
    Current = hud.Keybind,
}, function(new)
    settings:Set("hud.keybind", new.Name)
    hud.Keybind = new.Name
end)

Hud:AddLabel({
    Text = "Ugly ui I know shut up"
})

warn("AH8_MAIN : Reached end of script")