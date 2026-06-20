return function(http)
	return function(url, content, embed)
		request({
			Url = url,
			Method = "POST",
			Headers = { ["Content-Type"] = "application/json" },
			Body = http:JSONEncode({
				content = content or nil,
				embeds = { embed },
			}),
		})
	end
end
