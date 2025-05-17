AddCSLuaFile("shared.lua")
include("shared.lua")

local ENT = ENT

function ENT:Initialize()
	self:SetModel("models/hunter/plates/plate.mdl")

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	self.changed = true
end
