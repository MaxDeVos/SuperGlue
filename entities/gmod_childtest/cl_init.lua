ENT.RenderGroup = RENDERGROUP_BOTH
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	if SERVER then return end
end