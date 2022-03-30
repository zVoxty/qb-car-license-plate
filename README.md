# qb-car-license-plate
Plugin written on the QB framework to handle car licence plates within FiveM game

# Dependencies
- QB-Core
- QB-Inventory

# Workflows
1. You can customise where to buy the empty license plates using the config file.
2. The empty license plates can be converted to 'registered license plates' for a higher amount of money 
3. The empty license plates can be converted to 'fake license plates' for a lower amount of money
4. If you have within your inventory fake or registered license plates you can go behind your car and change the plates.

# Configuration
1. Add following lines to the qb-core\shared\items
```
  ['empty_license_plate'] 		 = {['name'] = 'empty_license_plate', 			['label'] = 'Empty License Plate', 		['weight'] = 150, 		['type'] = 'item', 		['image'] = 'licenseplate.png', 		['unique'] = true, 		['useable'] = true, 	['shouldClose'] = true,	   ['combinable'] = nil,   ['description'] = 'An empty license plate.'},
	['fake_license_plate'] 		 	 = {['name'] = 'fake_license_plate', 			['label'] = 'Fake License Plate', 		['weight'] = 150, 		['type'] = 'item', 		['image'] = 'licenseplate.png', 		['unique'] = true, 		['useable'] = true, 	['shouldClose'] = true,	   ['combinable'] = nil,   ['description'] = 'A fake license plate.'},
	['registered_license_plate'] 	 = {['name'] = 'registered_license_plate', 		['label'] = 'Registered License Plate', ['weight'] = 150, 		['type'] = 'item', 		['image'] = 'licenseplate.png', 		['unique'] = true, 		['useable'] = true, 	['shouldClose'] = true,	   ['combinable'] = nil,   ['description'] = 'A registered license plate ready to use'}
```

2. Add licenseplate.png to qb-inventory\html\images

