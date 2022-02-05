local achievement_config = require("Achievement.achievement_config")
--modname的名字不能有中文！！！

AddModRPCHandler("DSTAchievement", "jump", function(player)
	player.components.achievementability:jumpcoin(player)
end)

AddModRPCHandler("DSTAchievement", "level", function(player)
	player.components.achievementability:levelcoin(player)
end)

AddModRPCHandler("DSTAchievement", "fastbuild", function(player)
	player.components.achievementability:fastbuildcoin(player)
end)

AddModRPCHandler("DSTAchievement", "soulhopcopy", function(player)
	player.components.achievementability:soulhopcopycoin(player)
end)


AddModRPCHandler("DSTAchievement", "thornss", function(player)
	player.components.achievementability:thornsscoin(player)
end)

AddModRPCHandler("DSTAchievement", "electric", function(player)
	player.components.achievementability:electriccoin(player)
end)

AddModRPCHandler("DSTAchievement", "firmarmor", function(player)
	player.components.achievementability:firmarmorcoin(player)
end)

AddModRPCHandler("DSTAchievement", "woodieability", function(player)
	player.components.achievementability:woodieabilitycoin(player)
end)

AddModRPCHandler("DSTAchievement", "healthregen", function(player)
	player.components.achievementability:healthregencoin(player)
end)

AddModRPCHandler("DSTAchievement", "plantfriend", function(player)
	player.components.achievementability:plantfriendcoin(player)
end)

AddModRPCHandler("DSTAchievement", "speedup", function(player)
	player.components.achievementability:speedupcoin(player)
end)

AddModRPCHandler("DSTAchievement", "damageup", function(player)
	player.components.achievementability:damageupcoin(player)
end)

AddModRPCHandler("DSTAchievement", "absorbup", function(player)
	player.components.achievementability:absorbupcoin(player)
end)

AddModRPCHandler("DSTAchievement", "crit", function(player)
	player.components.achievementability:critcoin(player)
end)

AddModRPCHandler("DSTAchievement", "fireflylight", function(player)
	player.components.achievementability:fireflylightcoin(player)
end)

AddModRPCHandler("DSTAchievement", "nomoist", function(player)
	player.components.achievementability:nomoistcoin(player)
end)

AddModRPCHandler("DSTAchievement", "doubledrop", function(player)
	player.components.achievementability:doubledropcoin(player)
end)

AddModRPCHandler("DSTAchievement", "goodman", function(player)
	player.components.achievementability:goodmancoin(player)
end)

AddModRPCHandler("DSTAchievement", "fishmaster", function(player)
	player.components.achievementability:fishmastercoin(player)
end)

AddModRPCHandler("DSTAchievement", "pickmaster", function(player)
	player.components.achievementability:pickmastercoin(player)
        if player.components.achievementmanager and player.components.achievementmanager.a_a2 then
            player.components.achievementmanager.a_a2 = true
        end
end)

AddModRPCHandler("DSTAchievement", "chopmaster", function(player)
	player.components.achievementability:chopmastercoin(player)
end)

AddModRPCHandler("DSTAchievement", "cookmaster", function(player)
	player.components.achievementability:cookmastercoin(player)
end)

AddModRPCHandler("DSTAchievement", "buildmaster", function(player)
	player.components.achievementability:buildmastercoin(player)
end)

AddModRPCHandler("DSTAchievement", "refresh", function(player)
	player.components.achievementability:refreshcoin(player)
end)

AddModRPCHandler("DSTAchievement", "icebody", function(player)
	player.components.achievementability:icebodycoin(player)
end)

AddModRPCHandler("DSTAchievement", "firebody", function(player)
	player.components.achievementability:firebodycoin(player)
end)

AddModRPCHandler("DSTAchievement", "supply", function(player)
	player.components.achievementability:supplycoin(player)
end)

AddModRPCHandler("DSTAchievement", "reader", function(player)
	player.components.achievementability:readercoin(player)
end)

AddModRPCHandler("DSTAchievement", "justicerain", function(player)
	player.components.achievementability:justiceraincoin(player)
end)

AddModRPCHandler("DSTAchievement", "removecoin", function(player)
	player.components.achievementability:resetbuff(player)
	player.components.achievementability:removecoin(player)
end)

-- AddModRPCHandler("DSTAchievement", "setdata", function(player)
-- 	player.components.achievementability:setdatafn(player)
-- end)

------------------------------------------------------------------------------
AddModRPCHandler("DSTAchievement", "morestrongstomach", function(player)
	player.components.achievementability:morestrongstomachcoin(player)
end)

AddModRPCHandler("DSTAchievement", "shadowsubmissive", function(player)
	player.components.achievementability:shadowsubmissivecoin(player)
end)

AddModRPCHandler("DSTAchievement", "eventtechnology", function(player)
	player.components.achievementability:eventtechnologycoin(player)
end)

AddModRPCHandler("DSTAchievement", "murlocdisguise", function(player)
	player.components.achievementability:murlocdisguisecoin(player)
end)

AddModRPCHandler("DSTAchievement", "fastcollection", function(player)
	player.components.achievementability:fastcollectioncoin(player)
end)

AddModRPCHandler("DSTAchievement", "ghostly_friend", function(player)
	player.components.achievementability:ghostly_friendcoin(player)
end)

AddModRPCHandler("DSTAchievement", "waxwellfriend", function(player)
	player.components.achievementability:waxwellfriendcoin(player)
end)

AddModRPCHandler("DSTAchievement", "flashy", function(player)
	player.components.achievementability:flashycoin(player)
end)
------------------------------------------------------------------------------
AddModRPCHandler("DSTAchievement", "fearless", function(player)
	player.components.achievementability:fearlesscoin(player)
end)

AddModRPCHandler("DSTAchievement", "autorepair", function(player)
	player.components.achievementability:autorepaircoin(player)
end)

AddModRPCHandler("DSTAchievement", "magicpepair", function(player)
	player.components.achievementability:magicpepaircoin(player)
end)

AddModRPCHandler("DSTAchievement", "ignorestorm", function(player)
	player.components.achievementability:ignorestormcoin(player)
end)

AddModRPCHandler("DSTAchievement", "ancientstation", function(player)
	player.components.achievementability:ancientstationcoin(player)
end)

AddModRPCHandler("DSTAchievement", "moonstone", function(player)
	player.components.achievementability:moonstonecoin(player)
end)

AddModRPCHandler("DSTAchievement", "moonaltar", function(player)
	player.components.achievementability:moonaltarcoin(player)
end)

AddModRPCHandler("DSTAchievement", "timemanager", function(player)
	player.components.achievementability:timemanagercoin(player)
end)
AddModRPCHandler("DSTAchievement", "finishachievement", function(player,id)
	player.components.achievementability:costKillAmountFinishAchievement(player,id)
end)
-- for _,v in pairs(achievement_config.config) do
-- 	if v.catagory == 6 or v.catagory == 7 then
-- 		AddModRPCHandler("DSTAchievement", v.id, function(player)
-- 			player.components.achievementability:costKillAmountFinishAchievement(player,v.id)
-- 		end)
-- 	end
-- end