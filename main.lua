local http = game:GetService("HttpService")
local players = game:GetService("Players")
local replicated_storage = game:GetService("ReplicatedStorage")

local REPO = "https://raw.githubusercontent.com/LobsterFromBoston/jailbreak-tracker/master/"

local function load(path)
	local response = request({
		Url = REPO .. path,
		Method = "GET",
	})

	local fn, err = loadstring(response.Body)
	if not fn then
		error("Failed to load " .. path .. ": " .. tostring(err))
	end

	return fn()
end

local webhook_map = load("discord/webhooks.lua")
local role_map = load("discord/roles.lua")
local send_webhook = load("discord/send.lua")(http)
local status_map = load("robbery/status_map.lua")
print(type(status_map), status_map)
local tracker = load("robbery/tracker.lua")

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
