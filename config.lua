Config = Config or {}

Config.Blip = {
    blipName = "Car Place Register",
    blipType = 525,
    blipColor = 2,
    blipScale = 0.55
}

Config.Locales = {
    Error = 'Something weird occured',
    ErrorVehicle = 'You somehow left your vehicle!',
    ErrorDriver = 'You need to be the driver',
    ErrorWalking = 'You are not in a vehicle',
    ErrorOwner = 'This is not your vehicle',
    ErrorPlate = 'Plate already exists',
    ErrorPlateReal = 'Your vehicle appears to be missing a real plate',
    ErrorCharsMin = 'Plate needs at least 1 character',
    ErrorCharsMax = 'Somehow you passed more than 6 chars',
    ErrorPlateNeeded = 'You need an empty license plate',
    ErrorEngineShouldBeStarted = 'You should start engine of the vehicle before',
    ErrorPlateNotRegistered = 'Vehicle plate is not registered',
    NewPlate = 'Your new plate has been set!',
    BuyPlateLabel = 'Buy empty license plate',
    RegisterPlateLabel = 'Register empty plate',
    GetFakePlate = 'Fake the empty car license plate',
    NotBehindVehicle = 'You must be behind your vehicle to do that.',
    InvalidLicensePlate = 'Cannot use empty license plates. Something needs to be written on them',
    SuccessRegisterCarPlate = 'You have registered your license plate successfully',
    SuccessFakeCarPlate = 'You have received the fake license plate',
}

Config.LicencePlateLocations = {
    ["buy_empty_place_spot"] = { coords = vector3(-33.83, -1112.33, 26.42), label = Config.Locales.BuyPlateLabel, price = 175, eventToTrigger = 'clp:server:buyItem', showOnMap = true, blipName = "Empty car plates" },
    ["convert_to_register_plate"] = { coords = vector3(440.26, -981.13, 30.69), label = Config.Locales.RegisterPlateLabel, price = 500, eventToTrigger = 'clp:server:registerPlate', showOnMap = true, blipName = "Register car plates"},
    ["convert_to_fake_plate"] = { coords = vector3(1.72, -1024.38, 28.96), label = Config.Locales.GetFakePlate, price = 100, eventToTrigger = 'clp:server:convertToFakePlate', showOnMap = false},
}

Config.JsKey = "Insert"
Config.PlateHeader = "SAN ANDREAS"
Config.EightChars = true
Config.useButtons = true
Config.MaxChars = 8
