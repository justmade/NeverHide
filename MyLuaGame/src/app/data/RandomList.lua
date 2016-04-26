RandomList = {}

RandomList.EMPTY = "-"

RandomList.DOOR =  "D"
--Ξ♠♥Ψ▒°☣
RandomList.WALL = "▒"

RandomList.CHEST_BOX = "▫"

RandomList.BOSS = "♠"

RandomList.HEART = "♥"

RandomList.ATTACK = "Ψ"

RandomList.WATER = "Ξ" 

RandomList.ROOM = " "

RandomList.PLAYER = "@"

RandomList.list = {
		{element = RandomList.ROOM, probability = 400},
		{element = RandomList.CHEST_BOX, probability = 100},
		{element = RandomList.BOSS, probability = 200},	
		{element = RandomList.HEART, probability = 50},
		{element = RandomList.ATTACK, probability = 50},
		{element = RandomList.WATER, probability = 100},		
}

return RandomList