--[[
	Note About This File:
	it turns out that my hoarding habits aren't limited to the real world
	also I hate Lua an unbelievable amount
]]--


--[[
	Name: DrawLines
	Hilariously inefficient method of acomplishing the same task as DrawMesh(). I couldn't figure
	out how to make Meshes work so I did this ridiculousness. Do not do this.
	
	Requires:
	• A supercomputer
	• rotatedTable (???)
]]--
function ENT:DrawLines()
	if not vectorTable then
		if not noTableFlag then
			print("[ERROR]NO VECTORTABLE")
			noTableFlag = true
		end return end

		noTableFlag = false


		for i, startVector in pairs(rotatedTable) do
			for j, endVector in pairs(rotatedTable) do
				if startVector != endVector then
				render.DrawLine(startVector + self:GetPos(), endVector + self:GetPos(), 1, 0, 0, Color(255,255,255))
			end
		end
	end
end


--[[
	Name: DrawTriangles
	A slightly less stupid version of DrawLines(), but still very stupid and inefficient. Just use DrawMesh().
	
	Requires:
	• A supercomputer
	• self.triangleMeshTable, which requires self.meshTable
]]--
function ENT:DrawTriangles()
	if not self.triangleMeshTable then
		if not noTableFlag then
			print("[ERROR]NO TRIANGLETABLE")
			noTableFlag = true
		end return end
	noTableFlag = false
	cam.Start3D()
	for i, triangle in pairs(self.triangleMeshTable) do
		local rTriangle = AdjustVectorTableToWorldCoords(triangle, self:GetPos(), self:GetNetworkAngles())
		-- print(type(rTriangle[1]))
		render.DrawLine(rTriangle[1], rTriangle[2], 1, 0, 0, Color(255,255,255))
		render.DrawLine(rTriangle[2], rTriangle[3], 1, 0, 0, Color(255,255,255))
		render.DrawLine(rTriangle[1], rTriangle[3], 1, 0, 0, Color(255,255,255))
	end
	cam.End3D()
end


--[[
	Name: GetVectorTable
	A misguided attempt to interpret the list of vectors that is correctly handled by BuildMeshFromTable().
	I have no idea why I didn't just delete this.
	
	Requires the same as BuildMeshFromTable()
]]--
function GetVectorTable()
	local filteredTable = {}
	for i, vec in pairs(self.meshTable) do
		if not filteredTable[tostring(vec['pos'])] then
			filteredTable[tostring(vec['pos'])] = vec
		end
	end

	local aggregatedTable = {}
	for vecStr, vec in pairs(filteredTable) do
		table.insert(aggregatedTable, vec)
	end
	filteredMeshTable = aggregatedTable

	local vecTable = {}
	for vecStr, vec in pairs(filteredTable) do
		table.insert(vecTable, vec['pos'])
	end
	vectorTable = vecTable

	return vecTable;
end

--[[
	Name: CreateZombieProp
	Early attempt to understand Meshes and PhysicsObjects. Gave me way too much confidence.
	Creates an entity with the model of one prop but the physics mesh of another
	
	Requires:
	• Two prop paths (standalone, put in server-side Initialize)
]]--
function ENT:CreateZombieProp(visibleProp, physicsModelPath)
	-- Visual Model
	self:SetModel(visibleProp)

	local modelMeshes = util.GetModelMeshes(Model(physicsModelPath), 0, 0)
	modelMass = split(split(util.GetModelInfo(Model(physicsModelPath))["KeyValues"], "\n")[4], "\"")[3]
	-- print(modelMass)

	-- pDump(util.GetModelInfo(self:GetModel())["KeyValues"])

	self:PhysicsDestroy()
	self:PhysicsFromMesh(modelMeshes[1]['verticies'])

	self:SetSolid( SOLID_VPHYSICS ) -- Setting the solidity
	self:SetMoveType( MOVETYPE_VPHYSICS ) -- Setting the movement type

	self:EnableCustomCollisions( true ) -- Enabling the custom collision mesh

	phys = self:GetPhysicsObject()
	if phys:IsValid() then

		print("Setting Mass to " .. modelMass )

		-- TODO THESE VALUES FROM modelMass and stuff
		phys:SetMass(tonumber(modelMass))
		-- phys:SetMaterial("solidmetal")
	end

	self:PhysWake() -- Enabling the physics motion
end

-- ================================
--    The CHAOS ZONE starts here
-- ================================