-- Variables

local QBCore = exports['qb-core']:GetCoreObject()
blips = {}
blipsLoaded = false
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
        blips[k] = AddBlipForCoord(tonumber(location.coords.x), tonumber(location.coords.y), tonumber(location.coords.z))
        SetBlipSprite(blips[k], Config.Blip.blipType)
        SetBlipDisplay(blips[k], 4)
        SetBlipScale  (blips[k], Config.Blip.blipScale)
        SetBlipColour (blips[k], Config.Blip.blipColor)
        SetBlipAsShortRange(blips[k], true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(tostring(Config.Blip.blipName))
        EndTextCommandSetBlipName(blips[k])
    end
end

local function RemoveBlips()
    for k, v in pairs(Config.LicencePlateLocations) do
        RemoveBlip(blips[k])
    end
    blips = {}
end

-- Events

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
        if IsPedInAnyVehicle(ped, false) then
            if GetPedInVehicleSeat(GetVehiclePedIsIn(ped, false), -1) == ped then
                if data then
                    if data:len() > 0 then
                        SendNUIMessage({action = 'hide'})
                        SetNuiFocus(0, 0)
                        TriggerServerEvent('ev:getPlate', data, GetVehicleNumberPlateText(GetVehiclePedIsIn(ped, false)):match( "^%s*(.-)%s*$" ))
                        isOpen = false
                    else
                        QBCore.Functions.Notify(Config.Locales.ErrorCharsMin)
                    end
                else
                    QBCore.Functions.Notify(Config.Locales.Error)
                end
            else
                QBCore.Functions.Notify(Config.Locales.ErrorDriver) 
            end
        else
            QBCore.Functions.Notify(Config.Locales.ErrorVehicle)
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


-- Events
RegisterNetEvent('ev:getPlateNui', function()
    if not isOpen then
        local ped = PlayerPedId()
        if IsPedInAnyVehicle(ped, false) then
            if GetPedInVehicleSeat(GetVehiclePedIsIn(ped, false), -1) == ped then
                isOpen = true
                SendNUIMessage({action = 'show'})
                SetNuiFocus(1, 1)
            else
                showNoti(Config.Locales.ErrorDriver)
            end
        else
            showNoti(Config.Locales.ErrorWalking)
        end
    end
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
                    DrawText3Ds(location.coords, '~g~E~w~ - Buy licence plate $' .. Config.LicencePlatePrice)
                    if IsControlJustPressed(0, 38) then
                        TriggerServerEvent('ev:buyItem')
                    end
                end
            end
        end

        if not inRange then
            Wait(1000)
        end

        Wait(4)
    end
end)