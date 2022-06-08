AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

util.PrecacheModel("models/hunter/blocks/cube05x05x05.mdl")


function ENT:Initialize()

	if CLIENT then return end
	self:SetModel("models/hunter/blocks/cube025x05x025.mdl")
	self:SetPos(Vector(200,200,100))

	local prop = ents.Create("prop_physics")
	prop:SetModel("models/hunter/blocks/cube05x05x05.mdl")
	prop:SetParent(self)
	prop:SetPos(Vector(0,0,0))
	prop:SetColor(Color(255,0,255))
	prop:Spawn()

	self:PhysWake()

end



-- COPY ORDER: PreEntityCopy, PostEntityCopy, OnEntityCopyTableFinish 

--[[
	Name: PreEntityCopy
	Called before the duplicator copies the entity. If you are looking for a way to make the duplicator spawn 
	another entity when duplicated. ( For example, you duplicate a "prop_physics", but you want the duplicator 
	to spawn "prop_physics_my" ), you should add prop_physics.ClassOverride = "prop_physics_my". The 
	duplication table should be also stored on that prop_physics, not on prop_physics_my. 
]]--
function ENT:PreEntityCopy()
	-- print("[STATE] INIT PreEntityCopy on" .. tostring(self));
	if CLIENT then return end
	local info = {}

	info.Children = {}

	printPoseAll("PreEntityCopy_Start", self.Children, self)

	for id, ch in pairs(self.Children) do

		local child = {}
		child.Class = ch:GetClass()
		child.Model = ch:GetModel()
		child.Pos = self.posTable[id]
		child.Ang = self.angTable[id]
		print(tostring(ch) .. "@PreEntityCopy  |  POS: " .. tostring(child.Pos) .. "  |  ANG: " .. tostring(child.Ang))
		child.Mat = ch:GetMaterial()
		child.Skin = ch:GetSkin()

		info.Children[id] = child

	end

	info.Mass = self.Mass

	info.Frozen = not self:GetPhysicsObject():IsMoveable()

	printPoseAll("PreEntityCopy_End", info.Children, self)

	duplicator.StoreEntityModifier(self, "SuperGlue", info)
end


--[[
	Name: PostEntityCopy
	Called after the duplicator finished copying the entity. See also ENTITY:PreEntityCopy and ENTITY:PostEntityPaste. 
]]--
function ENT:PostEntityCopy()
end


--[[
   Name: OnEntityCopyTableFinish
   Called after duplicator finishes saving the entity, allowing you to modify the save data. 
   This is called after ENTITY:PostEntityCopy. 
]]--
function ENT:OnEntityCopyTableFinish( tableData )
end




-- DUPLICATION (PASTE) ORDER: Initialize, OnDuplicated, PostEntityPaste

--[[
	Name: OnDuplicated
	Called on any entity after it has been created by the duplicator and before any bone/entity modifiers have been applied.
	This hook is called after ENTITY:Initialize and before ENTITY:PostEntityPaste.

	When this state is reached:
]]--
function ENT:OnDuplicated( entTable )
end



function ENT:GenerateClonedMeshFromEntities()
	local newMesh = {}
	-- print("GENERATING MESH FOR" .. tostring(self))
	-- PrintTable(self.Children)

	if not self.Children then print("NO CHILDREN!") end

	-- For each entity in the selected entities list
	for _, childEnt in pairs(self.Children) do
		local childPhys = childEnt:GetPhysicsObject()
		local delta = childEnt:GetPos()
		local angle = childEnt:GetAngles()
		local physMesh = childPhys:GetMesh()
		print(tostring(ch) .. "@GenPhysMesh  |  POS: " .. tostring(childEnt:GetPos()) .. "  |  ANG: " .. tostring(childEnt:GetAngles()))
		for i, vert in pairs(physMesh) do
			local vec = vert["pos"]
			vec = vec
			-- vec:Rotate(angle)

			table.insert(newMesh, vec)
		end
	end
	self.Mesh = newMesh
end


--[[
	Name: PostEntityPaste
	Called after the duplicator pastes the entity, after the bone/entity modifiers have been applied to the entity. 
	This hook is called after ENTITY:OnDuplicated. 

	When this state is reached:
	
]]--
function ENT:PostEntityPaste(ply, ent, createdEnts)

	self.Children = {}

	-- print("[STATE] INIT PostEntityPaste on" .. tostring(self));
	if CLIENT then return end
	if ent.EntityMods and ent.EntityMods.SuperGlue then

		printPoseAll("PostEntityPaste_Start", ent.EntityMods.SuperGlue.Children, self)

		local entList = {}

		for id, v in pairs(ent.EntityMods.SuperGlue.Children) do
			local prop = ents.Create(v.Class)
			print(tostring(ch) .. "@PostEntityPaste Start |  POS: " .. tostring(v.Pos) .. "  |  ANG: " .. tostring(v.Ang))
			prop:SetModel(v.Model)

			local pos = Vector(v.Pos.x, v.Pos.y, v.Pos.z)
			-- pos:Rotate(self:GetAngles())
			pos = pos

			prop:SetPos(pos)
			-- prop:SetAngles(v.Ang + self:GetAngles())
			prop:SetAngles(v.Ang)

			prop:SetParent(ent)

			prop:Spawn()

			prop:SetMaterial(v.Mat)
			prop:SetSkin(v.Skin)


			print(tostring(ch) .. "@PostEntityPaste End |  POS: " .. tostring(prop:GetPos()) .. "  |  ANG: " .. tostring(prop:GetAngles()))
			self.Children[id] = prop
		end

		printPoseAll("PostEntityPaste_PreGeneration", self.Children, self)

		-- PrintTable(self.Children)

		self:GenerateClonedMeshFromEntities(true) --Define self.Mesh physics Mesh
		self:Spawn()

		printPoseAll("PostEntityPaste_End", self.Children, self)

		if ent.EntityMods.SuperGlue.Frozen then
			ent:GetPhysicsObject():EnableMotion(false)
		end
	end
	printCSV()
end