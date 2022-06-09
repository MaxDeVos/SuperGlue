--[[
	Created by Max DeVos
	Inspired by Improved-PolyWeld Tool by Bobblehead and Sir Haza
]]--

ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName		= "CombinedShape"
ENT.Author			= "Max"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""

ENT.Spawnable		= false
ENT.AdminSpawnable	= false

mat_debugwhite = Material( "editor/wireframe" )
mat_wireframe = Material( "models/wireframe" )

modelPath = "models/hunter/blocks/cube025x025x025.mdl"


-- Don't allow children in a superglue group to move independently of their parent
hook.Add("PhysgunPickup", "ChildrenRule", function(ply, ent)
	if ent:GetParent() and ent:GetParent():IsValid() and ent:GetParent():GetClass() == "gmod_shape" then
		return false
	end
end)

-- honestly I stole this directly from somewhere, I'm not really sure why it's here
hook.Add("CanTool","No Toolgun on polys",function( ply, tr, tool )
	if ( IsValid( tr.Entity ) and tr.Entity:GetParent() and tr.Entity:GetParent():IsValid() and tr.Entity:GetParent():GetClass() == "gmod_shape" ) then
		return false
	end
end)


-- Below are misc debugging methods to try to get useful information out of Lua's "data structures".
-- The ones that have a "p" prefix print straight to the console, otherwise they return a string. 

function dump(o)
	if type(o) == 'table' then
		local s = '{ '
		for k,v in pairs(o) do
			if type(k) ~= 'number' then k = '"'..k..'"' end
			s = s .. '['..k..'] = ' .. dump(v) .. ',\n'
		end
		return s .. '}'
	else
		return tostring(o)
	end
end


function dumpTypes(o)
	if type(o) == 'table' then
		local s = '{ '
		for k,v in pairs(o) do
			s = s .. type(k) .. dumpTypes(v) .. ',\n'
		end
		return s .. '}'
	else
		return type(o)
	end
end


function dumpKeys(o)
	if type(o) == 'table' then
		local s = '{ '
		for k,v in pairs(o) do
			s = s .. " " .. tostring(k) .. "\n"
		end
		return s .. '}'
	else
		return tostring(o)
	end
end


function pDump(o)
	print(dump(o))
end


function pDumpKeys(o)
	print(dumpKeys(o))
end
