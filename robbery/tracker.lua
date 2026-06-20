return function(deps)
	local robbery_consts = deps.robbery_consts
	local robbery_state = deps.robbery_state
	local status_map = deps.status_map
	local webhook_map = deps.webhook_map
	local role_map = deps.role_map
	local send_webhook = deps.send_webhook
	local join_link = deps.join_link
	local player_count = deps.player_count
	local max_players = deps.max_players
	local job_id = deps.job_id

	for _, k in pairs(robbery_consts.LIST_ROBBERY) do
		local enum = robbery_consts.ENUM_ROBBERY[k]
		local name = robbery_consts.PRETTY_NAME[enum]
		local state = robbery_state:FindFirstChild(tostring(enum))

		if state and state:IsA("IntValue") then
			local status = status_map.status[state.Value] or "unknown"
			local url = webhook_map[name]
			local ping = role_map[name] and role_map[name] ~= "" and "<@&" .. role_map[name] .. ">" or nil

			if url and url ~= "" and status == "open" then
				send_webhook(url, ping, {
					title = "🏦 " .. name,
					description = string.format(
						"**%s** is **%s**!\n\n[🔗 Click to Join](%s)",
						name,
						status,
						join_link
					),
					color = status_map.colors[status] or 0x2b2d31,
					fields = {
						{
							name = "👥 Players",
							value = string.format("%d/%d", player_count, max_players),
							inline = true,
						},
						{ name = "🔑 Job ID", value = string.format("`%s`", job_id), inline = true },
					},
					footer = { text = "Robbery Tracker" },
					timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
				})
			elseif url and status ~= "open" then
				warn(name .. " is not open!")
			else
				warn("no webhook configured for: " .. name)
			end
		end
	end
end
