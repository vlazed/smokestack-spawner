---@class prop_smokestack: ENT
---@field GetInitialState fun(prop_smokestack): boolean
local ENT = ENT

ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Smoke Stack"
ENT.Author = "vlazed"
ENT.Category = "Smoke Stack"
ENT.Purpose = "Smokin'!!!"
ENT.Instructions = "Right-click on the prop to edit its properties"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Editable = true
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

---@param initial number
---@return fun(): number
local function counter(initial)
	local val = initial or 0
	return function()
		val = val + 1
		return val
	end
end

local BIG = 2 ^ 32

---@param key string
---@param value any
function ENT:SetSmokeKey(key, value)
	if key == "rendercolor" then
		value = value * 255
	end
	if key == "InitialState" then
		value = value and 1 or 0
	end
	self.smokestack:SetKeyValue(key, tostring(value))
end

---Set `env_smokestack` key values from network vars
function ENT:SetSmoke()
	for key, value in pairs(self:GetNetworkVars()) do
		self:SetSmokeKey(key, value)
	end
end

---Setup network vars for `env_smokestack`
function ENT:SetupDataTables()
	local count = counter(-1)

	---INFO: stop complaining linter
	---@diagnostic disable: param-type-mismatch
	self:NetworkVar(
		"Bool",
		"InitialState",
		{ KeyName = "InitialState", Edit = { type = "Bool", order = count(), title = "Enabled" } }
	)
	self:NetworkVar("Int", "SpreadSpeed", {
		KeyName = "SpreadSpeed",
		Edit = { type = "Int", order = count(), title = "Spread Speed", min = 0, max = BIG },
	})
	self:NetworkVar(
		"Int",
		"Speed",
		{ KeyName = "Speed", Edit = { type = "Int", order = count(), title = "Speed", min = 0, max = BIG } }
	)
	self:NetworkVar("Int", "StartSize", {
		KeyName = "StartSize",
		Edit = { type = "Int", order = count(), title = "Particle start size", min = 0, max = BIG },
	})
	self:NetworkVar("Int", "EndSize", {
		KeyName = "EndSize",
		Edit = { type = "Int", order = count(), title = "Particle end size", min = 0, max = BIG },
	})
	self:NetworkVar(
		"Int",
		"Rate",
		{ KeyName = "Rate", Edit = { type = "Int", order = count(), title = "Emission rate", min = 0, max = BIG } }
	)
	self:NetworkVar("Int", "JetLength", {
		KeyName = "JetLength",
		Edit = { type = "Int", order = count(), title = "Length of smoke trail", min = 0, max = BIG },
	})
	self:NetworkVar("Float", "WindAngle", {
		KeyName = "WindAngle",
		Edit = { type = "Float", order = count(), title = "Wind X/Y Angle", min = -180, max = 180 },
	})
	self:NetworkVar(
		"Int",
		"WindSpeed",
		{ KeyName = "WindSpeed", Edit = { type = "Int", order = count(), title = "Wind Speed", min = 0, max = BIG } }
	)
	self:NetworkVar("String", 0, "SmokeMaterial", {
		KeyName = "SmokeMaterial",
		Edit = { type = "Generic", order = count(), title = "Particle material", waitforenter = true },
	})
	self:NetworkVar(
		"Int",
		"Twist",
		{ KeyName = "Twist", Edit = { type = "Int", order = count(), title = "Twist", min = 0, max = BIG } }
	)
	self:NetworkVar(
		"Float",
		"Roll",
		{ KeyName = "Roll", Edit = { type = "Float", order = count(), title = "Roll Speed", min = 0, max = BIG } }
	)
	self:NetworkVar(
		"Vector",
		"rendercolor",
		{ KeyName = "rendercolor", Edit = { type = "VectorColor", order = count(), title = "Base Color (R G B)" } }
	)
	self:NetworkVar(
		"Int",
		"renderamt",
		{ KeyName = "renderamt", Edit = { type = "Int", order = count(), title = "Translucency", min = 0, max = 255 } }
	)
	self:NetworkVar(
		"Vector",
		"Wind",
		{ KeyName = "Wind", Edit = { type = "Generic", order = count(), title = "Wind Vector" } }
	)
	---@diagnostic enable

	if SERVER then
		local function changedCallback(_, key, _, newValue)
			if IsValid(self.smokestack) then
				self:SetSmokeKey(key, newValue)
			end
		end

		self:NetworkVarNotify("EndSize", changedCallback)
		self:NetworkVarNotify("JetLength", changedCallback)
		self:NetworkVarNotify("Rate", changedCallback)
		self:NetworkVarNotify("Roll", changedCallback)
		self:NetworkVarNotify("SmokeMaterial", changedCallback)
		self:NetworkVarNotify("Speed", changedCallback)
		self:NetworkVarNotify("SpreadSpeed", changedCallback)
		self:NetworkVarNotify("StartSize", changedCallback)
		self:NetworkVarNotify("Twist", changedCallback)
		self:NetworkVarNotify("Wind", changedCallback)
		self:NetworkVarNotify("WindAngle", changedCallback)
		self:NetworkVarNotify("WindSpeed", changedCallback)
		self:NetworkVarNotify("renderamt", changedCallback)
		self:NetworkVarNotify("rendercolor", changedCallback)
	end
end

function ENT:Think()
	if SERVER then
		if not IsValid(self.smokestack) and self:GetInitialState() then
			self.smokestack = ents.Create("env_smokestack")
			self.smokestack:SetParent(self)
			self.smokestack:SetPos(self:GetPos())
			self:SetSmoke()
			self:SetWindSpeed(self:GetWindSpeed())
			self.smokestack:Spawn()
			self.smokestack:Activate()
		elseif IsValid(self.smokestack) and not self:GetInitialState() then
			self.smokestack:Remove()
		end

		if IsValid(self.smokestack) then
			self.smokestack:SetPos(self:GetPos())
			self.smokestack:SetAngles(self:GetAngles())
			if self.firstCheck then
				-- During dupes or saves, smokestack isn't the available. Set parameters when it does
				self:SetSmoke()
				self:SetWindSpeed(self:GetWindSpeed())
				self.firstCheck = false
			end
		end
	end

	self:NextThink(CurTime())

	return true
end
