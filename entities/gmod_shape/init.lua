AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

--[[
Note to the reader: You will notice that this file is commented. While I'd like to believe that 
I did this out of the kindness of my heart, the truth is that Lua is an ugly, terrible language
and the moment you try to do anything more complex than FizzBuzz, keeping track of what is happening
becomes impossible. Or maybe I'm just stupid. The comments are your North Star, and you are a musketeer. 
In this metaphor, I am baby Jesus and you are trying to bring me gold and blankets. Regardless, the
comments are the only way through this otherwise impassible landscape. Good luck.
-Max

TODO
• Center of Mass
• Duping
• Saving
• Shadows
• Constraints
]]--


util.AddNetworkString( "ReqInitSwitching" )
util.PrecacheModel("models/hunter/blocks/cube05x05x05.mdl")
util.AddNetworkString( "vomit" )

CreateConVar("max_tableActive", "false")

net.Receive("ReqInitSwitching", function(len, ply)
	local entIndex = net.ReadInt(32)
	local netString = "ResInitSwitching" .. entIndex
	util.AddNetworkString( "SendPhysMesh" .. entIndex )
	util.AddNetworkString( "RequestPhysMesh" .. entIndex )
	util.AddNetworkString(netString)
	net.Start(netString)
	net.Broadcast()
end )


function ENT:Initialize()

		if CLIENT then return end
		self.Children = self.Children or {}

		if not self.cloned then self.cloned = false end

		self:SetModel(modelPath)

		-- Verify that network strings are pooled, regardless of load order (client then server or vise-versa)
		if util.AddNetworkString( "SendPhysMesh" .. self:EntIndex()) then print() end
		if util.AddNetworkString( "RequestPhysMesh" .. self:EntIndex()) then print() end

		if not self.cloned then
			self:GenerateMeshFromEntities()
		else
			self:GenerateClonedMeshFromEntities()
		end
		self:PhysicsDestroy()
		self:PhysicsFromMesh(self.Mesh)

		self.totalMass, self.centerOfMass = self:CalculateMassInformation()

		printPoseChildren("Initialize_PreParent", self.Children)
		for _, child in pairs(self.Children) do
			child:SetParent(self)
			-- child:PhysicsDestroy()
		end
		printPoseChildren("Initialize_PostParent", self.Children)

		self:SetSolid(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:EnableCustomCollisions(true)

		local phys = self:GetPhysicsObject()
		if phys:IsValid() then

			net.Receive("RequestPhysMesh" .. self:EntIndex(), function(len, ply)
				local physMesh = phys:GetMesh()
				net.Start("SendPhysMesh" .. self:EntIndex())
				net.WriteTable(physMesh)
				net.Broadcast()
			end )
			phys:SetMass(self.totalMass)
		end

		self:PhysWake()
		printPoseAll("Initialize_End", self.Children, self)
end


function ENT:ConfigureChildren(childrenList, posTable, angTable)
	self.Children = childrenList
	self.posTable = posTable
	self.angTable = angTable
end


--[[
	Name: GenerateMeshFromEntities
	Iterates through objects in self.Children and combines their Physics Meshes into one list of verticies
	
	Requires:
	• self.Children
	• Each child has a valid physics object
]]--
function ENT:GenerateMeshFromEntities()

	local newMesh = {}
	-- print("GENERATING MESH FOR" .. tostring(self))
	-- PrintTable(self.Children)

	if not self.Children then print("NO CHILDREN!") end

	-- For each entity in the selected entities list
	for _, childEnt in pairs(self.Children) do
		local childPhys = childEnt:GetPhysicsObject()
		local delta = childEnt:GetPos() - self:GetPos()
		local angle = self.angTable[_]
		local physMesh = childPhys:GetMesh()

		for i, vert in pairs(physMesh) do
			local vec = vert["pos"]
			vec:Rotate(angle)
			vec = vec + delta

			table.insert(newMesh, vec)
		end
	end
	self.Mesh = newMesh
end


function ENT:GenerateClonedMeshFromEntities()
	local newMesh = {}

	if not self.Children then print("NO CHILDREN!") end

	-- For each entity in the selected entities list
	for _, childEnt in pairs(self.Children) do
		local childPhys = childEnt:GetPhysicsObject()
		local physMesh = childPhys:GetMesh()
		local delta = childEnt:GetLocalPos()
		local angle = childEnt:GetLocalAngles()
		for i, vert in pairs(physMesh) do
			local vec = vert["pos"]
			vec:Rotate(angle)
			vec = vec + delta

			table.insert(newMesh, vec)
		end
	end
	self.Mesh = newMesh
end


--[[
	Name: CalculateMassInformation
	Calculates total mass and center of mass from list of entities
	
	Requires:
	• Object knows what who its children are
	• Object has each child's physics object
	• Objects position

	Returns:
	• Total Mass (number), Center of Mass (vector in local coordinates) 
]]--
function ENT:CalculateMassInformation()
	local massSum = 0
	local childrenCounter = 0
	local COM_Pos_Calc = Vector(0,0,0)
	for id, ent in pairs(self.Children) do
		local mass = ent:GetPhysicsObject():GetMass()
		local COM_Pos = ent:GetPhysicsObject():GetMassCenter() - self:GetPos()
		massSum = massSum + mass
		COM_Pos_Calc = COM_Pos_Calc + COM_Pos * mass
		childrenCounter = childrenCounter + 1
	end
	-- Note: for whatever godforsaken reason, this assigns the mass to ALL children, thus we divide the mass  
	-- by the number of children to arrive at the correct total mass. fucking source engine, man.
	massSum = massSum / childrenCounter

	-- Correct calculated center of mass. Currently unused, todo: implement by creating self:origin as this point.
	COM_Pos_Calc = COM_Pos_Calc * ( 1 / massSum )

	return massSum, COM_Pos_Calc
end
--[[
   Name: Think
]]--
function ENT:Think() if CLIENT then return end end
function ENT:OnRemove() resetTable() end


-- COPY ORDER: PreEntityCopy, PostEntityCopy, OnEntityCopyTableFinish 

--[[
	Name: PostEntityCopy
	Called after the duplicator finished copying the entity. See also ENTITY:PreEntityCopy and ENTITY:PostEntityPaste. 
]]--
function ENT:PostEntityCopy() end
--[[
   Name: OnEntityCopyTableFinish
   Called after duplicator finishes saving the entity, allowing you to modify the save data. 
   This is called after ENTITY:PostEntityCopy. 
]]--
function ENT:OnEntityCopyTableFinish( tableData ) end
--[[
	Name: OnDuplicated
	Called on any entity after it has been created by the duplicator and before any bone/entity modifiers have been applied.
	This hook is called after ENTITY:Initialize and before ENTITY:PostEntityPaste.

	When this state is reached:
]]--
function ENT:OnDuplicated( entTable ) end


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
		child.Pos = ch:GetLocalPos()
		child.Ang = ch:GetLocalAngles()
		child.Mat = ch:GetMaterial()
		child.Skin = ch:GetSkin()

		info.Children[id] = child

	end

	info.Mass = self.Mass

	info.Pos = self:GetPos()
	info.Ang = self:GetAngles()

	info.Frozen = not self:GetPhysicsObject():IsMoveable()

	printPoseAll("PreEntityCopy_End", info.Children, self)

	duplicator.StoreEntityModifier(self, "SuperGlue", info)
end

--[[
	Name: PostEntityPaste
	Called after the duplicator pastes the entity, after the bone/entity modifiers have been applied to the entity. 
	This hook is called after ENTITY:OnDuplicated. 

	When this state is reached:
	
]]--
function ENT:PostEntityPaste(ply, ent, createdEnts)

	self.Children = {}

	if ent.EntityMods and ent.EntityMods.SuperGlue then

		printPoseAll("PostEntityPaste_Start", ent.EntityMods.SuperGlue.Children, self)

		local entList = {}

		for id, v in pairs(ent.EntityMods.SuperGlue.Children) do
			local prop = ents.Create(v.Class)
			-- local prop = ents.Create("gmod_childtest") -- This eventually needs to be v.Class, this is for debugging
			prop:SetModel(v.Model)
			prop:SetParent(ent)

			local pos = Vector(v.Pos.x, v.Pos.y, v.Pos.z)
			-- pos:Rotate(v.Ang)

			prop:SetLocalPos(pos)
			-- prop:SetPos(Vector(0,0,0))

			-- prop:SetAngles(v.Ang + self:GetAngles())
			prop:SetLocalAngles(v.Ang) -- TODO TRYING TO FIGURE OUT HOW TO  MAKE !!ONLY PROPS!! GO TO RIGHT PLACE 

			prop:SetNWAngle( "localAng", v.Ang )
			prop:Spawn()

			net.Start("vomit")
			net.WriteInt(prop:EntIndex(), 32)
			net.Broadcast()

			prop:SetMaterial(v.Mat)
			prop:SetSkin(v.Skin)

			self.Children[id] = prop
		end

		printPoseAll("PostEntityPaste_PreGeneration", self.Children, self)

		-- PrintTable(self.Children)

		self.cloned = true
		self:Spawn()
		for id, child in pairs(self.Children) do
			print(tostring(child) .. " SERANG:  " .. tostring(child:GetAngles()))
		end

		printPoseAll("PostEntityPaste_End", self.Children, self)

		if ent.EntityMods.SuperGlue.Frozen then
			-- ent:GetPhysicsObject():EnableMotion(false)
		end
	end
	printCSV()
end