---@diagnostic disable

MOD.Name = "Smoke Stack"

local validClasses = {
	prop_smokestack = true,
}

function MOD:IsSmokeStack(entity)
	local theclass = entity:GetClass()

	return validClasses[theclass] or false
end

function MOD:Save(entity)
	if not self:IsSmokeStack(entity) then
		return nil
	end

	local data = entity:GetNetworkVars()

	return data
end

function MOD:Load(entity, data)
	if not self:IsSmokeStack(entity) then
		return
	end -- can never be too sure?

	for key, value in pairs(data) do
		entity["Set" .. key](entity, value)
	end
end

function MOD:LoadBetween(entity, data1, data2, percentage)
	if not self:IsSmokeStack(entity) then
		return
	end -- can never be too sure?
	for key, value in pairs(data1) do
		if IsColor(value) then
			entity["Set" .. key](entity, SMH.LerpLinearVector(value, data2[key], percentage))
		elseif isstring(value) or isbool(value) then
			entity["Set" .. key](entity, value)
		else
			entity["Set" .. key](entity, SMH.LerpLinear(value, data2[key], percentage))
		end
	end
end
