local QBCore = exports['qb-core']:GetCoreObject()

function IsPlayerNearNPC(playerCoords, npcCoords, maxDistance)
    local distance = #(playerCoords - npcCoords)
    return distance <= maxDistance
end

RegisterServerEvent('npcs:interact')
AddEventHandler('npcs:interact', function(npcId)
    local player = source
    local playerCoords = GetEntityCoords(GetPlayerPed(player))
    local npc = Config.NPCs[npcId]

    if npc and IsPlayerNearNPC(playerCoords, npc.coords, 2.0) then
        TriggerClientEvent('npcs:showClue', player, npc.clue)
    else
        print("Test!") -- If you don't want this just use --print("Test!")
    end
end)
