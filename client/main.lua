-- Variables

local QBCore = exports['qb-core']:GetCoreObject()
local blips = {}
local blipsLoaded = false
local isOpen = false

-- Functions

local function DrawText3Ds(coords, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(coords.x, coords.y, coords.z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

local function CreateBlips()
    for k, location in pairs(Config.LicencePlateLocations) do
        if location.showOnMap then
            blips[k] = AddBlipForCoord(tonumber(location.coords.x), tonumber(location.coords.y), tonumber(location.coords.z))
            SetBlipSprite(blips[k], Config.Blip.blipType)
            SetBlipDisplay(blips[k], 4)
            SetBlipScale  (blips[k], Config.Blip.blipScale)
            SetBlipColour (blips[k], Config.Blip.blipColor)
            SetBlipAsShortRange(blips[k], true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(tostring(location.blipName))
            EndTextCommandSetBlipName(blips[k])
        end

    end
end

local function IsBehindVehicle(vehicle) 
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local trunkpos = GetOffsetFromEntityInWorldCoords(vehicle, 0, -2.5, 0)

    if #(pos - trunkpos) < 2.0 and not IsPedInAnyVehicle(ped) then
        return true
    else
        return false
    end
end

local function RemoveBlips()
    for k, v in pairs(Config.LicencePlateLocations) do
        RemoveBlip(blips[k])
    end
    blips = {}
end

-- Events

RegisterNetEvent('clp:getPlateNui', function()
    local vehicle = QBCore.Functions.GetClosestVehicle()
    local plate = GetVehicleNumberPlateText(vehicle):match( "^%s*(.-)%s*$" )
    QBCore.Functions.TriggerCallback('clp:server::checkVehicleOwner', function(owned)
        if owned then       
            if not IsBehindVehicle(vehicle) then
                QBCore.Functions.Notify(Config.Locales.NotBehindVehicle)
                return
            end 

            if not isOpen then
                local ped = PlayerPedId()
                isOpen = true
                SendNUIMessage({action = 'show'})
                SetNuiFocus(1, 1)
            end
        else
            QBCore.Functions.Notify(Config.Locales.ErrorOwner)
        end
    end, plate)
end)


RegisterNetEvent('clp:client:LicensePlateCheck', function()
    local ped = PlayerPedId()
    local closestVehicle = GetClosestVehicle(GetEntityCoords(ped), 5.0, 0, 70)
    if closestVehicle ~= 0 then
        local plate = GetVehicleNumberPlateText(closestVehicle):match( "^%s*(.-)%s*$" )
        QBCore.Functions.TriggerCallback('clp:server:GetPlateStatus', function(isFake)
            if isFake then
                QBCore.Functions.Notify('Vehicle license plate is fake', 'error')
            else
                QBCore.Functions.Notify('Vehicle license plate is registered', 'success')
            end
        end, plate)
    else
        QBCore.Functions.Notify('No Vehicle Nearby', 'error')
    end
end)



RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    CreateBlips()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    RemoveBlips()
end)

-- NUI Callback

RegisterNUICallback('getPlateText', function(data, cb)
    if isOpen then
        local ped = PlayerPedId()
        if data then
            if data:len() > 0 then
                SendNUIMessage({action = 'hide'})
                SetNuiFocus(0, 0)
                local vehicle = QBCore.Functions.GetClosestVehicle()
                local plate = GetVehicleNumberPlateText(vehicle):match( "^%s*(.-)%s*$" )
                TriggerServerEvent('clp:server:getPlate', data, plate)
                isOpen = false
                TaskPlayAnim(ped, "amb@prop_human_bum_bin@idle_b", "idle_d", 8.0, 8.0, -1, 50, 0, false, false, false)
                Wait(4000)
                TaskPlayAnim(ped, "amb@prop_human_bum_bin@idle_b", "exit", 8.0, 8.0, -1, 50, 0, false, false, false)
            else
                QBCore.Functions.Notify(Config.Locales.ErrorCharsMin)
            end
        else
            QBCore.Functions.Notify(Config.Locales.Error)
        end
    end
    cb({})
end)

RegisterNUICallback('close', function(_, cb)
    if isOpen then
        isOpen = false
        SendNUIMessage({action = 'hide'})
        SetNuiFocus(0, 0)
    end
    cb({})
end)

--Handlers
AddEventHandler('playerSpawned', function()
    Wait(3000)
    SendNUIMessage({
        action = 'key',
        key = Config.JsKey,
        title = Config.PlateHeader,
        chars = Config.EightChars,
        buttons = Config.useButtons
    })
end)

AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        Wait(3000)
        SendNUIMessage({
            action = 'key',
            key = Config.JsKey,
            title = Config.PlateHeader,
            chars = Config.EightChars,
            buttons = Config.useButtons
        })
    end
end)

-- Threads

CreateThread(function()
    if not blipsLoaded then
        CreateBlips()
    end

    while true do
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        inRange = false
        
        for k, location in pairs(Config.LicencePlateLocations) do
            local dist = #(pos - location.coords)
            if dist < 20 then
                inRange = true
                DrawMarker(2, location.coords.x, location.coords.y, location.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.2, 155, 152, 234, 155, false, false, false, true, false, false, false)
                if #(pos - vector3(location.coords.x, location.coords.y, location.coords.z)) < 1.5 then

                    DrawText3Ds(location.coords, '~g~E~w~ - ' .. location.label  .. ' $' .. location.price)
                    if IsControlJustPressed(0, 38) then
                        TriggerServerEvent(location.eventToTrigger, location)
                    end
                end
            end
        end

        if not inRange then
            Wait(1500)
        end

        Wait(4)
    end
end)
