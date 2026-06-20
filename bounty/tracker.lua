return function(deps)
	local http = deps.http
	local send_webhook = deps.send_webhook
	local small_webhook = deps.small_webhook
	local big_webhook = deps.big_webhook
	local join_link = deps.join_link
	local player_count = deps.player_count
	local max_players = deps.max_players
	local job_id = deps.job_id

	local police_count = 0
	local criminal_count = 0
	for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
		local team = player.Team
		if team then
			if team.Name == "Police" then
				police_count += 1
			elseif team.Name == "Criminals" then
				criminal_count += 1
			end
		end
	end

	local replicated_storage = game:GetService("ReplicatedStorage")
	local bounty_data_obj = replicated_storage:WaitForChild("BountyData")
	local success, bounty_data = pcall(function()
		return http:JSONDecode(bounty_data_obj.Value)
	end)

	if not success or not bounty_data then
		warn("failed to decode bounty data")
		return
	end

	local fields = {}
	local total_bounty = 0

	for i, entry in ipairs(bounty_data) do
		total_bounty += entry.Bounty
		table.insert(fields, {
			name = string.format("#%d %s", i, entry.Name),
			value = string.format("💰 $%d", entry.Bounty),
			inline = true,
		})
	end

	table.insert(fields, { name = "\u{200B}", value = "\u{200B}", inline = false })

	table.insert(
		fields,
		{ name = "👥 Players", value = string.format("%d/%d", player_count, max_players), inline = true }
	)
	table.insert(fields, { name = "🚔 Police", value = tostring(police_count), inline = true })
	table.insert(fields, { name = "💰 Criminals", value = tostring(criminal_count), inline = true })
	table.insert(fields, { name = "🔑 Job ID", value = string.format("`%s`", job_id), inline = false })

	local is_big = total_bounty >= 25000
	local webhook_url = is_big and big_webhook or small_webhook
	local title = is_big and "💎 Big Bounty Found" or "🎯 Small Bounty Found"
	local color = is_big and 0xe74c3c or 0xe67e22

	send_webhook(webhook_url, nil, {
		title = title,
		description = string.format("Total bounty: **$%d**\n\n[🔗 Click to Join](%s)", total_bounty, join_link),
		color = color,
		fields = fields,
		footer = { text = "Bounty Tracker" },
		timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
	})
end
