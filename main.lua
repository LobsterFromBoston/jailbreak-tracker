local function run()
	local success, err = pcall(function()
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
		local join_link = "https://www.fishstrap.app/v1/joingame?placeId="
			.. game.PlaceId
			.. "&gameInstanceId="
			.. job_id

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
		local config_source = string.format(
			[[
            getgenv().config = {
                webhooks = {
                    ["Bank"] = "%s",
                    ["Jewelry Store"] = "%s",
                    ["Museum"] = "%s",
                    ["Power Plant"] = "%s",
                    ["Passenger Train"] = "%s",
                    ["Cargo Train"] = "%s",
                    ["Cargo Ship"] = "%s",
                    ["Cargo Plane"] = "%s",
                    ["Tomb"] = "%s",
                    ["Crown Jewel"] = "%s",
                    ["Mansion"] = "%s",
                    ["Oil Rig"] = "%s",
                    ["Bounty.Small"] = "%s",
                    ["Bounty.Big"] = "%s",
                },
                roles = {
                    ["Bank"] = "%s",
                    ["Jewelry Store"] = "%s",
                    ["Museum"] = "%s",
                    ["Power Plant"] = "%s",
                    ["Passenger Train"] = "%s",
                    ["Cargo Train"] = "%s",
                    ["Cargo Ship"] = "%s",
                    ["Cargo Plane"] = "%s",
                    ["Tomb"] = "%s",
                    ["Crown Jewel"] = "%s",
                    ["Mansion"] = "%s",
                    ["Oil Rig"] = "%s",
                }
            }
        ]],
			config.webhooks["Bank"],
			config.webhooks["Jewelry Store"],
			config.webhooks["Museum"],
			config.webhooks["Power Plant"],
			config.webhooks["Passenger Train"],
			config.webhooks["Cargo Train"],
			config.webhooks["Cargo Ship"],
			config.webhooks["Cargo Plane"],
			config.webhooks["Tomb"],
			config.webhooks["Crown Jewel"],
			config.webhooks["Mansion"],
			config.webhooks["Oil Rig"],
			config.webhooks["Bounty.Small"],
			config.webhooks["Bounty.Big"],
			config.roles["Bank"],
			config.roles["Jewelry Store"],
			config.roles["Museum"],
			config.roles["Power Plant"],
			config.roles["Passenger Train"],
			config.roles["Cargo Train"],
			config.roles["Cargo Ship"],
			config.roles["Cargo Plane"],
			config.roles["Tomb"],
			config.roles["Crown Jewel"],
			config.roles["Mansion"],
			config.roles["Oil Rig"]
		)

		local main_source = request({ Url = REPO .. "main.lua", Method = "GET" }).Body
		queue_on_teleport(config_source .. "\n" .. main_source)
		loadstring(game:HttpGet("https://raw.githubusercontent.com/Vcsk/RobloxScripts/refs/heads/main/ServerHop.lua"))()
	end)

	if not success then
		warn("Error: " .. tostring(err) .. " — retrying in 5 seconds")
		task.wait(5)
		run()
	end
end

run()
