---- Minecraft Bridge
---- Common (Client)

if game.SinglePlayer()--[[ or not string.StartWith(game.GetMap(), "mb_")--]] then

	return
end

hook.Add("OnPlayerChat", "MinecraftClientChatEvent", function(InPlayer, InText, bInTeamChat, bInIsDead)

	if string.StartWith(InText, "/") then

		local CommandData = string.Split(InText, " ")

		--PrintTable(CommandData)

		if CommandData[1] == "/bridge" or CommandData[1] == "/mb" then
			if CommandData[2] ~= "toggle" or CommandData[1] ~= "ip" or CommandData[1] ~= "port" then
				chat.AddText("/bridge toggle <roomcode> <tickrate> - enable/disable brigde,\n/bridge ip <ip> - set ip,\n/bridge port <port> - set port.\nYou can type /mb intead of /bridge.")
				return ""
			end
		end
	end
end)
