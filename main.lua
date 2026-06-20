local http = game:GetService("HttpService")
local players = game:GetService("Players")
local replicated_storage = game:GetService("ReplicatedStorage")

local function load(path)
	return loadstring(readfile(path))()
end

local webhook_map = load("tracker/discord/webhooks.lua")
local role_map = load("tracker/discord/roles.lua")
local send_webhook = load("tracker/discord/send.lua")(http)
local status_map = load("tracker/robbery/status_map.lua")
local tracker = load("tracker/robbery/tracker.lua")

local job_id = game.JobId
local player_count = #players:GetPlayers()
local max_players = players.MaxPlayers

tracker({
	robbery_consts = require(replicated_storage.Robbery.RobberyConsts),
	robbery_state = replicated_storage:WaitForChild("RobberyState"),
	status_map = status_map,
	webhook_map = webhook_map,
	role_map = role_map,
	send_webhook = send_webhook,
	job_id = job_id,
	player_count = player_count,
	max_players = max_players,
	join_link = "roblox://experiences/start?placeId=" .. game.PlaceId .. "&gameInstanceId=" .. job_id,
})
