local objects = {
	voteGate = dofile "2D Engine/Objects/Gate"
}

function PTV3_2D:getRefObj(obj)
	return objects[obj.__reference]
end

function PTV3_2D:newObject(name, ...)
	if not objects[name] then return end

	local referenceObj = objects[name]
	local obj = {}

	obj.__reference = name
	referenceObj.spawn(obj, ...)

	table.insert(self.objects, obj)
	return obj
end