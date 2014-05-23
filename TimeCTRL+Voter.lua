PLUGIN.Title = "Time CTRL + Voter"
PLUGIN.Description = "Admin time control, voting system for players to skip night, players can view current time"
PLUGIN.Version = "1.0"
PLUGIN.Author = "Orange Joe"

function PLUGIN:Init()

	print( "Plugin: " .. self.Title .. " Ver. " .. self.Version )

	flags_plugin = plugins.Find("flags")
	if (not flags_plugin) then
		error("FLAGS PLUGIN REQUIRED ! Please visit the Oxide forums to get the Flags Plugin.")
		return
	end
	flags_plugin:AddFlagsChatCommand(self, "dawn", {"kick"}, self.cmdDawn)
	flags_plugin:AddFlagsChatCommand(self, "dusk", {"kick"}, self.cmdDusk)
	flags_plugin:AddFlagsChatCommand(self, "t", {"kick"}, self.cmdT)
	self:AddChatCommand( "time", self.cmdTime)
	self:AddChatCommand( "vtime", self.cmdVoteTimer)
	self:AddChatCommand( "vday", self.cmdVoteDay)
	self:AddChatCommand( "vnight", self.cmdVoteNight)
	self.Voted = {}
	ReqVotes = 10
	DayTally = 0 
end

local ReqVotes = 10
local DayTally = 0

function PLUGIN:cmdVoteDay(netuser, cmd)	-- vote for day
	local UID = rust.GetUserID(netuser)
	if self:CheckVote(UID) then
		rust.SendChatToUser( netuser, "=TIMEVOTER=", "YOU HAVE ALREADY VOTED !")	-- msg if you already voted
	else
		local tme = Rust.EnvironmentControlCenter.Singleton:GetTime()
		if tme >= tonumber(20.00) then
			local Tally = DayTally
			Tally = Tally + 1
			DayTally = Tally
			table.insert(self.Voted, UID)
			rust.BroadcastChat("=TIMEVOTER=", "A VOTE HAS BEEN CASTED FOR DAY !")
			rust.BroadcastChat("=TIMEVOTER=", "VOTE(S) FOR DAY: " ..DayTally.. " [ " ..ReqVotes.. " ] VOTES TO PASS !")
			if DayTally >= ReqVotes then
			rust.RunServerCommand("env.time 6")
			rust.BroadcastChat("=TIMEVOTER=", "VOTE PASSED, NIGHT WILL BE SKIPPED !")
			DayTally = 0 		-- clears tallies
			self.Voted = {}		-- clears voted UID table	
			end
		else
			rust.SendChatToUser( netuser, "=TIMEVOTER=", "POLLS CURRENTLY CLOSED ! POLLS OPEN FROM 20.00 - 0.00 Hrs !")	-- msg if you try and vote when votinf not actuve
		end
	end
end

function PLUGIN:cmdVoteNight(netuser, cmd)	-- vote for night
	local UID = rust.GetUserID(netuser)
	if self:CheckVote(UID) then
		rust.SendChatToUser( netuser, "=TIMEVOTER=", "YOU HAVE ALREADY VOTED !")	-- msg if you already voted
	else
		local tme = Rust.EnvironmentControlCenter.Singleton:GetTime()
		if tme >= tonumber(20.00) then
			local Tally = DayTally
			Tally = Tally - 1
			DayTally = Tally
			table.insert(self.Voted, UID)
			rust.BroadcastChat("=TIMEVOTER=", "A VOTE HAS BEEN CASTED FOR NIGHT !")
			rust.BroadcastChat("=TIMEVOTER=", "VOTE(S) FOR DAY: " ..DayTally.. " [ " ..ReqVotes.. " ] VOTES TO PASS !")
		else
			rust.SendChatToUser( netuser, "=TIMEVOTER=", "POLLS CURRENTLY CLOSED ! POLLS OPEN FROM 20.00 - 0.00 Hrs !")	-- msg if you try and vote when votinf not actuve
		end
	end
end

local i = 1

function PLUGIN:CheckVote(UID)
	for i = 1, #self.Voted do
		if self.Voted[i] == UID then return true end
	end
	return false
end

function PLUGIN:cmdVoteTimer(netuser, cmd)
	rust.SendChatToUser( netuser, "=TIMEVOTER=", "======== VOTING BEGINS AT 20.00 Hrs ========")
	rust.SendChatToUser( netuser, "=TIMEVOTER=", "/vday   | To cast a day tally.")
	rust.SendChatToUser( netuser, "=TIMEVOTER=", "/vnight | To void a day tally.")
	rust.SendChatToUser( netuser, "=TIMEVOTER=", "ONE VOTE PER PLAYER | " ..ReqVotes.. " REQUIRED VOTES TO PASS")
	local tme = Rust.EnvironmentControlCenter.Singleton:GetTime()
	if tme < tonumber(20.00) then
		self.Voted = {}
		DayTally = 0 
	end
end

function PLUGIN:cmdDawn()
	rust.RunServerCommand("env.time 6")
    rust.BroadcastChat("=TIME=", "Hour: 6")
end

function PLUGIN:cmdDusk()
	rust.RunServerCommand("env.time 19")
    rust.BroadcastChat("=TIME=", "Hour: 19")
end

function PLUGIN:cmdT(netuser, cmd, args)
	rust.RunServerCommand("env.time "..args[1])
	rust.BroadcastChat("=TIME=", "Hour: " ..args[1])
	local tme = Rust.EnvironmentControlCenter.Singleton:GetTime()
	if tme < tonumber(20.00) then
		self.Voted = {}
		DayTally = 0 
	end
end

function PLUGIN:cmdTime(netuser)
	local tme = Rust.EnvironmentControlCenter.Singleton:GetTime()
	rust.InventoryNotice( netuser, string.format("%.2f", tme))
end	

function PLUGIN:SendHelpText(netuser)
	rust.SendChatToUser( netuser, "/time | Displays wrist watch.")
	rust.SendChatToUser( netuser, "/vtime | Displays info about day/night voting.")
	local tme = Rust.EnvironmentControlCenter.Singleton:GetTime()
	if tme < tonumber(20.00) then
		self.Voted = {}
		DayTally = 0 
	end
end
