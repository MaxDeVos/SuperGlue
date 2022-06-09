ENT.RenderGroup = RENDERGROUP_BOTH
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	print(tostring(self) .. " ANG:  " .. tostring(self:GetAngles()))
	print("localAng: " .. tostring(self:GetNWAngle("localAng")))
	-- self:SetRenderAngles(self:GetAngles())
end