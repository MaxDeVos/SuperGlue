--[[
Note to the reader: You will notice that this file is commented. While I'd like to believe that 
I did this out of the kindness of my heart, the truth is that Lua is an ugly, terrible language
and the moment you try to do anything more complex than FizzBuzz, keeping track of what is happening
becomes impossible. Or maybe I'm just stupid. The comments are your North Star, and you are a musketeer. 
In this metaphor, I am baby Jesus and you are trying to bring me gold and blankets (don't think about 
this very hard). Regardless, the comments are the only way through this otherwise impassible landscape.

PS: Anything surrounded with -- DEBUGGER and -- /DEBUGGER is code that exists only for, you guessed it,
debugging. This code is all commented out or removed for production.

Good luck.
-Max

TODO
• Center of Mass (maybe?)
• Shadows
• Constraints

DONE
• Mesh Debugger (client wireframe renderer)
• Mesh Generation
• Entity fitting/updating
• Collision Bounds
• Render Bounds
• Duplication
• Singleplayer saving (I'm sure there's a problem with it)
]]--

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

util.AddNetworkString( "ReqInitSwitching" )
util.PrecacheModel("models/hunter/blocks/cube05x05x05.mdl")


-- DEBUGGER This system exists to guarantee that the network strings are cached before a valid PhysMesh is created, since
--          the client needs to recieve that as quickly as possible. 
net.Receive("ReqInitSwitching", function(len, ply)
	local entIndex = net.ReadInt(32)
	local netString = "ResInitSwitching" .. entIndex
	util.AddNetworkString( "SendPhysMesh" .. entIndex )
	util.AddNetworkString( "RequestPhysMesh" .. entIndex )
	util.AddNetworkString(netString)
	net.Start(netString)
	net.Broadcast()
end )
-- /DEBUGGER


function ENT:Initialize()

		if CLIENT then return end
		self.Children = self.Children or {}
		self.deepChildren = self.deepChildren or {}

		if not self.cloned then self.cloned = false end

		self:SetModel(modelPath)

		-- DEBUGGER: Verify that network strings are pooled, regardless of load order (client then server or vise-versa)
		if util.AddNetworkString( "SendPhysMesh" .. self:EntIndex()) then print() end -- insert print() to shut up the linter
		if util.AddNetworkString( "RequestPhysMesh" .. self:EntIndex()) then print() end -- same deal here
		-- /DEBUGGER

		if not self.cloned then
			self:GenerateMeshFromEntities()
		else
			self:GenerateClonedMeshFromEntities()
		end
		self:PhysicsDestroy()
		self:PhysicsFromMesh(self.Mesh)

		self.totalMass, self.centerOfMass = self:CalculateMassInformation()

		for _, child in pairs(self.Children) do
			child:SetParent(self)
			self:DeleteOnRemove(child)
			self.deepChildren[child:EntIndex()] = child
		end

		self:SetSolid(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:EnableCustomCollisions(true)

		local phys = self:GetPhysicsObject()
		if phys:IsValid() then

			-- DEBUGGER: Writes PhysMesh to table and sends to client for rendering.
			-- print("GOT AUTOGEN CENTER OF MASS: " .. tostring(phys:GetMassCenter()))

			net.Receive("RequestPhysMesh" .. self:EntIndex(), function(len, ply)
				local physMesh = phys:GetMesh()
				net.Start("SendPhysMesh" .. self:EntIndex())
				net.WriteTable(physMesh)
				net.Broadcast()
			end )
			-- /DEBUGGER

			phys:SetMass(self.totalMass)
		end

		self:PhysWake()

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


function ENT:ConfigureChildren(childrenList)
	self.Children = childrenList
end


--[[
	Name: GenerateMeshFromEntities
	Iterates through objects in self.Children and combines their Physics Meshes into one list of verticies, which
	becomes the Physics Mesh of the parent object.
	
	Requires:
	• self.Children
	• Each child has a valid physics object
]]--
function ENT:GenerateMeshFromEntities()

	local newMesh = {}

	if not self.Children then print("NO CHILDREN!") end

	for _, childEnt in pairs(self.Children) do
		local childPhys = childEnt:GetPhysicsObject()
		local delta = childEnt:GetPos() - self:GetPos() -- Get position relative to parent object (LocalPos() had some issue here)
		local angle = childEnt:GetAngles()
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


--[[
	Name: GenerateClonedMeshFromEntities
	Iterates through objects in self.Children and combines their Physics Meshes into one list of verticies using local coordinates,
	which becomes the Physics Mesh of the resultant cloned parent object. The only difference between this and GenerateMeshFromEntities()
	is that we only deal with local (parent-relative) coordinates.
	
	Requires:
	• self.Children
	• Each child has a valid physics object
]]--
function ENT:GenerateClonedMeshFromEntities()
	local newMesh = {}

	if not self.Children then print("NO CHILDREN!") end

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


function ENT:OnRemove() end


-- COPY ORDER: PreEntityCopy, PostEntityCopy, OnEntityCopyTableFinish 

--[[
	Name: PreEntityCopy
	Aggregates relevant information about the object and its children for duplication. 
	Inspired by source code from PolyWeld.
]]--
function ENT:PreEntityCopy()

	-- print("========= DEEP CHILDREN ============")
	-- for a, b in pairs(self.deepChildren) do
	-- 	print(tostring(a) .. "   " .. tostring(b))
	-- end
	-- print("=====================")

	if CLIENT then return end
	local entData = {}

	entData.Children = {}


	for id, ch in pairs(self.deepChildren) do

		entData.Children[id] = duplicator.CopyEntTable(ch)

		-- local child = {}
		-- child.Class = ch:GetClass()
		-- child.Model = ch:GetModel()
		-- child.Pos = ch:GetLocalPos()
		-- child.Ang = ch:GetLocalAngles()
		-- child.Mat = ch:GetMaterial()
		-- child.Skin = ch:GetSkin()

		-- entData.Children[id] = child

	end

	entData.Mass = self.Mass

	-- Since we're using LocalPos and LocalAng, we also need to store the original position of the entity I think
	-- I haven't thought about this very hard.
	entData.Pos = self:GetPos()
	entData.Ang = self:GetAngles()

	local deepChildren = {}
	for id, ch in pairs(self.deepChildren) do
		deepChildren[id] = tostring(ch)
	end
	entData.DeepChildren = deepChildren

	entData.Frozen = not self:GetPhysicsObject():IsMoveable()


	duplicator.StoreEntityModifier(self, "SuperGlue", entData)
end


-- PASTE ORDER: Initialize() -> OnEntityCopyTableFinish() -> PostEntityPaste()

--[[
	Name: PostEntityPaste
	Unpacks data bundled by PreEntityCopy(), creates child entities with their respective properties
	and "respawns" our object with the correct configuration.

	When this state is reached:
	• Initialize() has been run on this currently childless parent object, leaving it in a quasi-null limbo state
	• "ent", the parent object to be duplicated, has run PreEntityCopy().
]]--
function ENT:PostEntityPaste(ply, ent, createdEnts)

	print("=========== createdEnts ===============")
	PrintTable(createdEnts)

	for id, oldEnt in pairs(ent.EntityMods.SuperGlue.DeepChildren) do
		if createdEnts and createdEnts[id] then
			createdEnts[id]:Remove()
		end
	end

	self.Children = {}

	if ent.EntityMods and ent.EntityMods.SuperGlue then

		for id, entData in pairs(ent.EntityMods.SuperGlue.Children) do
			local newChild = duplicator.CreateEntityFromTable(ply, entData)
			newChild:SetParent(ent)
			newChild:Spawn()
			self.Children[id] = newChild
		end
		self.cloned = true
		self:Spawn() -- "Respawn" object now that the children exist.
	end
end

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