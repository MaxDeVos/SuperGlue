AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

util.PrecacheModel("models/hunter/blocks/cube05x05x05.mdl")


function ENT:Initialize()

	self:SetSolid(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:EnableCustomCollisions(true)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end

end

-- COPY ORDER: PreEntityCopy, PostEntityCopy, OnEntityCopyTableFinish 
function ENT:PreEntityCopy()
end

function ENT:PostEntityCopy()
end

function ENT:OnEntityCopyTableFinish( tableData )
end

function ENT:OnDuplicated( entTable )
end

function ENT:GenerateClonedMeshFromEntities()
end

function ENT:PostEntityPaste(ply, ent, createdEnts)
end