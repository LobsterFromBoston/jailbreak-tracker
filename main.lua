local http = game:GetService("HttpService")
local players = game:GetService("Players")
local replicated_storage = game:GetService("ReplicatedStorage")

local REPO = "https://raw.githubusercontent.com/LobsterFromBoston/jailbreak-tracker/refs/heads/master/"

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
local tracker = load("robbery/tracker.lua")
local bounty_tracker = load("bounty/tracker.lua")

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
	join_link = "https://www.fishstrap.app/v1/joingame?placeId=" .. game.PlaceId .. "&gameInstanceId=" .. job_id,
})

bounty_tracker({
	http = http,
	send_webhook = send_webhook,
	small_webhook = webhook_map["Bounty.Small"],
	big_webhook = webhook_map["Bounty.Big"],
	join_link = "https://www.fishstrap.app/v1/joingame?placeId=" .. game.PlaceId .. "&gameInstanceId=" .. job_id,
	player_count = player_count,
	max_players = max_players,
	job_id = job_id,
})
