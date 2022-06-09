TOOL.Category		= "Constraints"
TOOL.Name			= "#tool.probe.name"
TOOL.Command		= nil
TOOL.ConfigName		= nil

include("luaUtilities.lua")
if CLIENT then
	language.Add("tool.probe.name", "Prober")
	language.Add("tool.probe.desc", "Probe Something")
end

selectedEnts = {}

function TOOL:LeftClick(trace)
	local ent = trace.Entity
	print(tostring(ent))
	return true
end


function TOOL:RightClick( trace )
end

-- function TOOL:RightClick( trace )
-- 	local ent = ents.Create("gmod_childtest")
-- 	ent:Spawn()
-- end

function TOOL:Reload( trace )
	print("[STATE] Shape Reload");
	return false

end

function TOOL:Holster()
end

function TOOL:Think()
end

function TOOL:DrawHUD()
end

function TOOL.BuildCPanel(CPanel)
end