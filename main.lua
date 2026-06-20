local http = game:GetService("HttpService")
local players = game:GetService("Players")
local replicated_storage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

if not game:IsLoaded() then
	game.Loaded:Wait()
end
local local_player = players.LocalPlayer
if not local_player.Character then
	local_player.CharacterAdded:Wait()
end
task.wait(3)

local config = getgenv().config
if not config then
	error("config not set! please set getgenv().config before running.")
end

local REPO = "https://raw.githubusercontent.com/LobsterFromBoston/jailbreak-tracker/refs/heads/master/"

local function load(path)
	local response = request({ Url = REPO .. path, Method = "GET" })
	local fn, err = loadstring(response.Body)
	if not fn then
		error("Failed to load " .. path .. ": " .. tostring(err))
	end
	return fn()
end

local send_webhook = load("discord/send.lua")(http)
local status_map = load("robbery/status_map.lua")
local tracker = load("robbery/tracker.lua")
local bounty_tracker = load("bounty/tracker.lua")

local job_id = game.JobId
local player_count = #players:GetPlayers()
local max_players = players.MaxPlayers
local join_link = "https://www.fishstrap.app/v1/joingame?placeId=" .. game.PlaceId .. "&gameInstanceId=" .. job_id

tracker({
	robbery_consts = require(replicated_storage.Robbery.RobberyConsts),
	robbery_state = replicated_storage:WaitForChild("RobberyState"),
	status_map = status_map,
	webhook_map = config.webhooks,
	role_map = config.roles,
	send_webhook = send_webhook,
	job_id = job_id,
	player_count = player_count,
	max_players = max_players,
	join_link = join_link,
})

bounty_tracker({
	http = http,
	send_webhook = send_webhook,
	small_webhook = config.webhooks["Bounty.Small"],
	big_webhook = config.webhooks["Bounty.Big"],
	join_link = join_link,
	player_count = player_count,
	max_players = max_players,
	job_id = job_id,
})

task.wait(2)
queue_on_teleport(request({ Url = REPO .. "main.lua", Method = "GET" }).Body)
loadstring(game:HttpGet("https://raw.githubusercontent.com/Vcsk/RobloxScripts/refs/heads/main/ServerHop.lua"))()
