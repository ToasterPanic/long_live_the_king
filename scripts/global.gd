extends Node


var room_stats = {
	"king": {
		"description": """The king and his riches!""",
		"damage": 0,
		"damage_instant": 0,
		"damage_type": "blunt",
		
		"shop_rarity": 0,
		"shop_cost": 0,
		
		"no_refunds": true
	},
	"spikes": {
		"description": """A basic set of spikes.""",
		"damage": 1,
		"damage_instant": 0,
		"damage_type": "blunt",
		
		"shop_rarity": 10,
		"shop_cost": 4,
		
		"refund_price": 3,
	},
	"scary_magic": {
		"description": """Very scary!!! oOoOoOooOOoo!!!!""",
		"damage": 2,
		"damage_instant": 0,
		"damage_type": "magic",
		
		"shop_rarity": 5,
		"shop_cost": 4,
		
		"refund_price": 3,
	},
	"large_spikes": {
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
		"stat_description": """""",
		
		"shop_rarity": 15,
		"shop_cost": 0,
		
		"refund_price": 0,
	},
	"boring": {
		"stat_description": """No damage-type multipliers""",
		
		"shop_rarity": 3,
		"shop_cost": 0,
		
		"refund_price": 0,
	},
	"grimy": {
		"stat_description": """150% blunt damage""",
		
		"shop_rarity": 2,
		"shop_cost": 1,
		
		"refund_price": 1,
	},
	"firey": {
		"stat_description": """150% burn damage""",
		
		"shop_rarity": 2,
		"shop_cost": 1,
		
		"refund_price": 1,
	},
	"supernatural": {
		"stat_description": """150% magic damage""",
		
		"shop_rarity": 2,
		"shop_cost": 1,
		
		"refund_price": 1,
	}
}

var waves = {
	1: {
		"amount": 32
	}
}
