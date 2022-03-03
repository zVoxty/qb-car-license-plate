-- Variables
local QBCore = exports['qb-core']:GetCoreObject()
local usedLicensePlateType = ''

RegisterNetEvent('clp:server:buyItem', function(location)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    Player.Functions.AddItem("empty_license_plate", 1)
    TriggerClientEvent('inventory:client:ItemBox', src, "empty_license_plate", 'add')
    Player.Functions.RemoveMoney("cash", location.price)
end)

RegisterNetEvent('clp:server:registerPlate', function(location)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    local emptyLicencePlate = Player.Functions.GetItemByName('empty_license_plate')
    if not emptyLicencePlate then
        TriggerClientEvent('QBCore:Notify', source, Config.Locales.ErrorPlateNeeded)
        return 
    end

    Player.Functions.RemoveItem('empty_license_plate', 1)
    Player.Functions.AddItem("registered_license_plate", 1)
    TriggerClientEvent('inventory:client:ItemBox', src, "registered_license_plate", 'add')
    Player.Functions.RemoveMoney("cash", location.price)
    TriggerClientEvent('QBCore:Notify', source, Config.Locales.SuccessRegisterCarPlate)
end)

RegisterNetEvent('clp:server:convertToFakePlate', function(location)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    local emptyLicencePlate = Player.Functions.GetItemByName('empty_license_plate')
    if not emptyLicencePlate then
        TriggerClientEvent('QBCore:Notify', source, Config.Locales.ErrorPlateNeeded)
        return 
    end

    Player.Functions.RemoveItem('empty_license_plate', 1)
    Player.Functions.AddItem("fake_license_plate", 1)
    TriggerClientEvent('inventory:client:ItemBox', src, "fake_license_plate", 'add')
    Player.Functions.RemoveMoney("cash", location.price)
    TriggerClientEvent('QBCore:Notify', source, Config.Locales.SuccessFakeCarPlate)
end)

QBCore.Functions.CreateCallback('clp:server:GetPlateStatus', function(source, cb, plate)

    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)

    local result = MySQL.Sync.fetchSingle(
        'SELECT * FROM player_vehicles WHERE plate = ? AND citizenid = ?'
        , {plate, xPlayer.PlayerData.citizenid} )

    if result == nil then
        TriggerClientEvent('QBCore:Notify', source, Config.Locales.ErrorPlateNotRegistered)
    elseif result.fakeplate == '1' then
        cb(true)
    else
        cb(false)
    end
end)

RegisterNetEvent('clp:server:getPlate', function(plate, currentPlate)
    local vehicle = GetVehiclePedIsIn(GetPlayerPed(source), true)
    if vehicle == 0 then
        TriggerClientEvent('QBCore:Notify', source, Config.Locales.ErrorEngineShouldBeStarted)
        return
    end


    local source <const> = source
    local xPlayer = QBCore.Functions.GetPlayer(source)

    if xPlayer then
        if vehicle == 0 or not currentPlate then
            return TriggerClientEvent('QBCore:Notify', source, Config.Locales.ErrorVehicle)
        elseif plate:len() > Config.MaxChars then
            return TriggerClientEvent('QBCore:Notify', source, Config.Locales.ErrorCharsMax)
        end

        local result = MySQL.Sync.fetchSingle('SELECT plate FROM player_vehicles WHERE plate = ? AND citizenid = ?', {currentPlate, xPlayer.PlayerData.citizenid} )

        if result then
            local exist = MySQL.Sync.fetchAll('SELECT * FROM player_vehicles WHERE plate = ?', {plate} )
            
            if not exist[1] then

                local currentVehicle = MySQL.Sync.fetchAll('SELECT plate, mods FROM player_vehicles WHERE plate = ?', {currentPlate} )
 
                if currentVehicle[1] then
                    local vehicleC = json.decode(currentVehicle[1].mods)
                    vehicleC.plate = plate

                    MySQL.Async.execute('UPDATE player_vehicles SET plate = ?, mods = ?, fakeplate = ? WHERE plate = ?',{plate, json.encode(vehicleC), usedLicensePlateType == 'fake_license_plate', currentPlate})

                    SetVehicleNumberPlateText(vehicle, plate)

                    TriggerEvent('vehiclekeys:server:SetVehicleOwner', plate, source)
                    
                    xPlayer.Functions.RemoveItem(usedLicensePlateType, 1)
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

QBCore.Functions.CreateCallback("clp:server::checkVehicleOwner", function(source, cb, plate)
    local src = source
    local pData = QBCore.Functions.GetPlayer(src)
    MySQL.Async.fetchAll('SELECT * FROM player_vehicles WHERE plate = ? AND citizenid = ?',{plate, pData.PlayerData.citizenid}, function(result)
        if result[1] then
            cb(true)
        else
            cb(false)
        end
    end)
end)

QBCore.Functions.CreateUseableItem('empty_license_plate', function(source)
    local source <const> = source
    TriggerClientEvent('QBCore:Notify', source, Config.Locales.InvalidLicensePlate)
end)

QBCore.Functions.CreateUseableItem('registered_license_plate', function(source)
    local source <const> = source
    TriggerClientEvent('clp:getPlateNui', source)
    usedLicensePlateType = 'registered_license_plate'
end)

QBCore.Functions.CreateUseableItem('fake_license_plate', function(source)
    local source <const> = source
    TriggerClientEvent('clp:getPlateNui', source)
    usedLicensePlateType = 'fake_license_plate'
end)
