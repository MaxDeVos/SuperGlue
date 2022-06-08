TOOL.Category		= "Constraints"
TOOL.Name			= "#tool.myshape.name"
TOOL.Command		= nil
TOOL.ConfigName		= nil

include("luaUtilities.lua")
if CLIENT then
	language.Add("tool.myshape.name", "Shape Maker")
	language.Add("tool.myshape.desc", "Make Shape")
end

selectedEnts = {}

function TOOL:LeftClick(trace)
	if CLIENT then return end

	-- Make sure we're trying to join something that makes sense
	if not trace.Entity then return true end
	if not trace.Entity:IsValid() then return true end
	if trace.Entity:IsPlayer() then return true end
	if trace.Entity:GetClass() == "prop_ragdoll" then return true end

	local focusedEntity = trace.Entity

	self.selected = self.selected or {};
	self.originalColors = self.originalColors or {};

	if self.selected[focusedEntity] == nil then
		self.originalColors[focusedEntity] = focusedEntity:GetColor()
		self.selected[focusedEntity] = true
	else
		self.selected[focusedEntity] = not self.selected[focusedEntity]
	end

	for entity,isSelected in pairs(self.selected) do
		if self.selected[entity] then
			entity:SetColor(Color(255,0,255,255))
		else
			entity:SetColor(self.originalColors[entity])
		end
	end

	return true
end


function TOOL:RightClick( trace )
	PrintTable(self.selected)
	local cleanedTable = {}
	local posTable = {}
	local angTable = {}
	local counter = 1
	for entity,isSelected in pairs(self.selected) do
		if self.selected[entity] then
			cleanedTable[counter] = entity
			posTable[counter] = entity:GetPos()
			angTable[counter] = entity:GetAngles()
			counter = counter + 1
			print("ENTPOS: " .. tostring(entity:GetPos()) .. "   | ENTANG: " .. tostring(entity:GetAngles()))
		end
	end

	if cleanedTable and table.Count(cleanedTable) <= 1 then
		print("Nothing to combine idiot head")
		return true
	end

	local ent = ents.Create("gmod_shape")
	ent:SetModel("models/hunter/blocks/cube025x025x025.mdl")

	ent:ConfigureChildren(cleanedTable, posTable, angTable)
	ent:SetPos(trace.HitPos)
	ent:Spawn()

	self:ClearSelection()
	return true
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
	self:ClearSelection()
	return true
end

function TOOL:ClearSelection()
	if SERVER then
		for v,k in pairs(self.selected or {}) do
			if k and IsValid(v) then
				v:SetColor(self.originalColors[v] or Color(255,255,255))
			end
		end
	end
	self.selected = {};
end

function TOOL:Think()
end

function TOOL:DrawHUD()
end

function TOOL.BuildCPanel(CPanel)
end