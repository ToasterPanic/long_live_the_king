extends Node


var room_stats = {
	"king": {
		"name": "King",
		"description": """The king and his riches!""",
		"damage": 0,
		"damage_instant": 0,
		"damage_type": "blunt",
		
		"shop_rarity": 0,
		"shop_cost": 0,
		
		"no_refunds": true
	},
	"spikes": {
		"name": "Spikes",
		"description": """A basic set of spikes.""",
		"damage": 1,
		"damage_instant": 0,
		"damage_type": "blunt",
		
		"shop_rarity": 10,
		"shop_cost": 4,
		
		"refund_price": 3,
	},
	"scary_magic": {
		"name": "Scary Magic",
		"description": """Very scary!!! oOoOoOooOOoo!!!!""",
		"damage": 2,
		"damage_instant": 0,
		"damage_type": "magic",
		
		"shop_rarity": 5,
		"shop_cost": 4,
		
		"refund_price": 3,
	},
	"large_spikes": {
		"name": "Large Spikes",
		"description": """A basic set of spikes, but larger""",
		"damage": 2,
		"damage_instant": 0,
		"damage_type": "blunt",
		
		"shop_rarity": 5,
		"shop_cost": 7,
		
		"refund_price": 5,
		
		"starting_wave": 2,
	},
	"fire": {
		"name": "Fire",
		"description": """A perpetual fire. Don't ask what the logistics are on that.""",
		"damage": 2,
		"damage_instant": 0,
		"damage_type": "burn",
		
		"shop_rarity": 5,
		"shop_cost": 7,
		
		"refund_price": 5,
		
		"starting_wave": 2,
	},
}

var wallpaper_stats = {
	"plain": {
		"name": "",
		"stat_description": """""",
		
		"shop_rarity": 14,
		"shop_cost": 0,
		
		"refund_price": 0,
	},
	"boring": {
		"name": "Boring",
		"stat_description": """No damage-type multipliers""",
		
		"shop_rarity": 4,
		"shop_cost": 0,
		
		"refund_price": 0,
	},
	"grimy": {
		"name": "Grimy",
		"stat_description": """150% damage
This room now deals blunt damage""",
		
		"shop_rarity": 3,
		"shop_cost": 1,
		
		"refund_price": 1,
	},
	"firey": {
		"name": "Firey",
		"stat_description": """150% damage
This room now deals fire damage""",
		
		"shop_rarity": 3,
		"shop_cost": 1,
		
		"refund_price": 1,
	},
	"supernatural": {
		"name": "Supernatural",
		"stat_description": """150% damage
This room now deals magic damage""",
		
		"shop_rarity": 3,
		"shop_cost": 1,
		
		"refund_price": 1,
	}
}

var charm_stats = {
	"gold": {
		"name": """Gold""",
		"stat_description": """+2 gold at the end of each wave""",
		
		"shop_rarity": 3,
		"shop_cost": 6,
		
		"refund_price": 3,
	},
	"carpentry": {
		"name": """Carpentry""",
		"stat_description": """Replaces charms in shop with more rooms""",
		
		"shop_rarity": 5,
		"shop_cost": 5,
		
		"refund_price": 3,
	}
}

var waves = {
	1: {
		"amount": 32
	}
}
