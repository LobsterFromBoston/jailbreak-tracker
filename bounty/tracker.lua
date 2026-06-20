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
	for _, v in pairs(game:GetService("Players"):GetDescendants()) do
		if v:IsA("StringValue") and v.Name == "TeamValue" then
			if v.Value == "Prisoner" or v.Value == "Criminal" then
				criminal_count += 1
			elseif v.Value == "Police" then
				police_count += 1
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

	local total_bounty = 0
	local bounty_lines = {}
	for i, entry in ipairs(bounty_data) do
		total_bounty += entry.Bounty
		table.insert(bounty_lines, string.format("**#%d** %s — $%d", i, entry.Name, entry.Bounty))
	end

	if total_bounty < 1000 then
		warn("this bounty is absolute shit")
		return
	end

	local is_big = total_bounty >= 25000
	local webhook_url = is_big and big_webhook or small_webhook
	local title = is_big and "💎 Big Bounty Found" or "🎯 Small Bounty Found"
	local color = is_big and 0xe74c3c or 0xe67e22

	send_webhook(webhook_url, nil, {
		title = title,
		description = string.format(
			"Total bounty: **$%d**\n\n%s\n\n[🔗 Click to Join](%s)",
			total_bounty,
			table.concat(bounty_lines, "\n"),
			join_link
		),
		color = color,
		fields = {
			{ name = "👥 Players", value = string.format("%d/%d", player_count, max_players), inline = true },
			{ name = "🚔 Police", value = tostring(police_count), inline = true },
			{ name = "💰 Criminals", value = tostring(criminal_count), inline = true },
			{ name = "🔑 Job ID", value = string.format("`%s`", job_id), inline = false },
		},
		footer = { text = "Bounty Tracker" },
		timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
	})
end
