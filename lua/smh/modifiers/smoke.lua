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

	local data = self:GetNetworkVars()

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
		elseif isstring(value) then
			entity["Set" .. key](entity, value)
		else
			entity["Set" .. key](entity, SMH.LerpLinear(value, data2[key], percentage))
		end
	end

	entity:SetBrightness(SMH.LerpLinear(data1.Brightness, data2.Brightness, percentage))
	entity:SetLightColor(SMH.LerpLinearVector(data1.Color, data2.Color, percentage))

	if self:IsProjectedLight(entity) then
		local theclass = entity:GetClass()
		if theclass ~= "expensive_light" and theclass ~= "expensive_light_new" then
			entity:SetLightFOV(SMH.LerpLinear(data1.FOV, data2.FOV, percentage))
		end
		if theclass == "projected_light_new" then
			entity:SetOrthoBottom(SMH.LerpLinear(data1.OrthoBottom, data2.OrthoBottom, percentage))
			entity:SetOrthoLeft(SMH.LerpLinear(data1.OrthoLeft, data2.OrthoLeft, percentage))
			entity:SetOrthoRight(SMH.LerpLinear(data1.OrthoRight, data2.OrthoRight, percentage))
			entity:SetOrthoTop(SMH.LerpLinear(data1.OrthoTop, data2.OrthoTop, percentage))
		end
		entity:SetNearZ(SMH.LerpLinear(data1.Nearz, data2.Nearz, percentage))
		entity:SetFarZ(SMH.LerpLinear(data1.Farz, data2.Farz, percentage))
	elseif entity:GetClass() == "cheap_light" then
		entity:SetLightSize(SMH.LerpLinear(data1.LightSize, data2.LightSize, percentage))
	else
		entity:SetInnerFOV(SMH.LerpLinear(data1.InFOV, data2.InFOV, percentage))
		entity:SetOuterFOV(SMH.LerpLinear(data1.OutFOV, data2.OutFOV, percentage))
		entity:SetRadius(SMH.LerpLinear(data1.Radius, data2.Radius, percentage))
	end
end
