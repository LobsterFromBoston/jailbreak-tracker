return function(deps)
	local http = deps.http
	local send_webhook = deps.send_webhook
	local small_webhook = deps.small_webhook
	local big_webhook = deps.big_webhook
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
			value = string.format("💰 $%s", tostring(entry.Bounty)),
			inline = true,
		})
	end

	local is_big = total_bounty >= 50000
	local webhook_url = is_big and big_webhook or small_webhook
	local title = is_big and "💎 Big Bounty Found" or "🎯 Small Bounty Found"
	local color = is_big and 0xe74c3c or 0xe67e22

	send_webhook(webhook_url, nil, {
		title = title,
		description = string.format("Total bounty: **$%d**", total_bounty),
		color = color,
		fields = fields,
		footer = { text = "Bounty Tracker" },
		timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
	})
end
