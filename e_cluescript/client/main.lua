local QBCore = exports['qb-core']:GetCoreObject()

function IsPlayerNearNPC(playerCoords, npcCoords, maxDistance)
    return #(playerCoords - npcCoords) <= maxDistance
end

RegisterNetEvent('npcs:showClue')
AddEventHandler('npcs:showClue', function(clue)
    QBCore.Functions.Notify(clue, "success")
end)

RegisterNetEvent('npcs:interact')
AddEventHandler('npcs:interact', function(npcId)
    local playerCoords = GetEntityCoords(PlayerPedId())
    local npc = Config.NPCs[npcId]
    if npc and IsPlayerNearNPC(playerCoords, npc.coords, 2.0) then
        TriggerEvent('npcs:showClue', npc.clue)
     end
end)

Citizen.CreateThread(function()
    for _, npc in ipairs(Config.NPCs) do
        local modelHash = GetHashKey(npc.model)
        RequestModel(modelHash)
        while not HasModelLoaded(modelHash) do
            Citizen.Wait(0)
        end

        local npcPed = CreatePed(4, modelHash, npc.coords.x, npc.coords.y, npc.coords.z, npc.heading, false, true)
        SetEntityAsMissionEntity(npcPed, true, true)
        SetEntityInvincible(npcPed, true)
        SetBlockingOfNonTemporaryEvents(npcPed, true)
        FreezeEntityPosition(npcPed, true)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        for i, npc in ipairs(Config.NPCs) do
            if IsPlayerNearNPC(playerCoords, npc.coords, 5.0) then
                local text = "Press ~r~[E]~s~ to Talk to ~g~" .. npc.name .. "~s~ "
                if #(playerCoords - npc.coords) < 2.0 then
                    DrawText3D(npc.coords.x, npc.coords.y, npc.coords.z + 0.5, text, 4)
                end
            end
        end
    end
end)

function DrawText3D(x, y, z, text, font)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    local scale = (1 / GetDistanceBetweenCoords(px, py, pz, x, y, z, 1)) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    local scale = scale * fov
    if onScreen then
        SetTextScale(0.0 * scale, 0.35 * scale)
        SetTextFont(font)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustReleased(0, 38) then -- Kan bytas
            local playerPed = GetPlayerPed(-1)
            if DoesEntityExist(playerPed) and not IsEntityDead(playerPed) then
                local playerCoords = GetEntityCoords(playerPed)
                for i, npc in ipairs(Config.NPCs) do
                    if IsPlayerNearNPC(playerCoords, npc.coords, 2.0) then
                        TriggerServerEvent('npcs:interact', i)
                    end
                end
            end
        end
    end
end)
