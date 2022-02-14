-- Variables
local QBCore = exports['qb-core']:GetCoreObject()


RegisterNetEvent('ev:buyItem', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    Player.Functions.AddItem("license_plate", 1)
    TriggerClientEvent('inventory:client:ItemBox', src, "license_plate", 'add')
    Player.Functions.RemoveMoney("cash", Config.LicencePlatePrice)
end)

RegisterNetEvent('ev:getPlate', function(plate, currentPlate)
    local source <const> = source
    local xPlayer = QBCore.Functions.GetPlayer(source)
    if xPlayer then
        local vehicle = GetVehiclePedIsIn(GetPlayerPed(source))
        if vehicle == 0 or not currentPlate then
            return TriggerClientEvent('QBCore:Notify', source, Config.Locales.ErrorVehicle)
        elseif plate:len() > Config.MaxChars then
            return TriggerClientEvent('QBCore:Notify', source, Config.Locales.ErrorCharsMax)
        end

        local currentPlate = GetVehicleNumberPlateText(vehicle):match( "^%s*(.-)%s*$" )
        local result = MySQL.Sync.fetchSingle('SELECT plate FROM player_vehicles WHERE plate = ? AND citizenid = ?', {currentPlate, xPlayer.PlayerData.citizenid} )

        if result then
            local exist = MySQL.Sync.fetchAll('SELECT * FROM player_vehicles WHERE plate = ?', {plate} )
            
            if not exist[1] then
                local currentVehicle = MySQL.Sync.fetchAll('SELECT plate, mods FROM player_vehicles WHERE plate = ?', {currentPlate} )
 
                if currentVehicle[1] then
                    local vehicle = json.decode(currentVehicle[1].mods)
                    if not vehicle.plate then
                        return TriggerClientEvent('QBCore:Notify', source, Config.Locales.ErrorPlateReal)
                    end
                    vehicle.plate = plate
                    MySQL.Async.execute('UPDATE player_vehicles SET plate = ?, mods = ? WHERE plate = ?',{plate, json.encode(vehicle), currentPlate})

                    SetVehicleNumberPlateText(GetVehiclePedIsIn(GetPlayerPed(source)), plate)

                    TriggerEvent('vehiclekeys:server:SetVehicleOwner', plate, source)
                    
                    xPlayer.Functions.RemoveItem('license_plate', 1)
                    TriggerClientEvent('QBCore:Notify', source, Config.Locales.NewPlate)
                    return
                end
            else
                TriggerClientEvent('QBCore:Notify', source, Config.Locales.ErrorPlate)
            end
        else
            TriggerClientEvent('QBCore:Notify', source, Config.Locales.ErrorOwner)
        end
    end
end)

QBCore.Functions.CreateUseableItem('license_plate', function(source)
    local source <const> = source
    local xPlayer = QBCore.Functions.GetPlayer(source)

    local vehicle = GetVehiclePedIsIn(GetPlayerPed(source))
    if vehicle ~= 0 then
        local result = MySQL.Sync.fetchSingle('SELECT plate FROM player_vehicles WHERE plate = ? AND citizenid = ?', {GetVehicleNumberPlateText(vehicle):match( "^%s*(.-)%s*$" ), xPlayer.PlayerData.citizenid} )
        
        if result then
            TriggerClientEvent('ev:getPlateNui', source)
        else
            TriggerClientEvent('QBCore:Notify', source, Config.Locales.ErrorOwner)
        end
    else
        TriggerClientEvent('QBCore:Notify', source, Config.Locales.ErrorWalking)
    end
end)
