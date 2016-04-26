local RandomHander = {}

local RandomListData = require("app.data.RandomList")

function RandomHander:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function RandomHander:init()
	math.randomseed(os.time())
	self.elements = {}
	self.probabilitys = {}
	self.totalCount = 0
	for i,v in ipairs(RandomListData.list) do
		table.insert(self.elements , v.element)
		table.insert(self.probabilitys , v.probability)
		self.totalCount = self.totalCount + v.probability
		print("self.totalCount",self.totalCount)
	end
end

function RandomHander:getRandomElement()
	local r = math.random(0,self.totalCount)
	local total = r
	for i,v in ipairs(self.probabilitys) do
		total = total - v
		if total <= 0 then 
			return self.elements[i]
		end
	end
end


return RandomHander