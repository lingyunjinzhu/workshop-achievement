function add_achievement_point(player_index, point)
    AllPlayers[player_index].components.achievementability.coinamount = AllPlayers[player_index].components.achievementability.coinamount + points
end

function add_kill_point(player_index, point)
    AllPlayers[player_index].components.achievementability.currentkillamount = AllPlayers[player_index].components.achievementability.currentkillamount + points
end

function add_player_exp(player_index, point)
    AllPlayers[player_index].components.achievementmanager.currenta_a2amount = AllPlayers[player_index].components.achievementmanager.currenta_a2amount + points
end

function add_player_level(player_index, point)
    AllPlayers[player_index].components.achievementmanager.currenta_a4amount = AllPlayers[player_index].components.achievementmanager.currenta_a4amount + points
end

