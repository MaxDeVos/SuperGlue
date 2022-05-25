ENT.RenderGroup = RENDERGROUP_BOTH
AddCSLuaFile("shared.lua")
include("shared.lua")

local noTableFlag = false

function ENT:Initialize()

	if SERVER then return end

	-- print("CLIENT INIT")
	-- print("EntIndex" .. tostring(self:EntIndex()))

	net.Start("ReqInitSwitching")
	net.WriteInt(self:EntIndex(), 32)
	net.SendToServer()

	net.Receive("ResInitSwitching" .. self:EntIndex(), function(len, ply)
		local netString = "RequestPhysMesh" .. self:EntIndex()
		net.Start(netString)
		net.SendToServer()
	end )

	local recieveString = "SendPhysMesh" .. self:EntIndex()
	net.Receive(recieveString, function(len, ply)
		self.meshTable = net.ReadTable()
		self:BuildMeshFromTable()
	end )

	local phys = self:GetPhysicsObject()
	if phys and phys:IsValid() then
		print("CLIENT HAS VALID PHYSICS (THIS IS WEIRD)")
		phys:EnableCollisions(false)
	end

end


function ENT:Draw()
	self:DrawMesh() -- Uncomment to draw debug wireframes
end


--[[
	Name: DrawMesh
	Superimposes "theoretical" mesh from the server onto the clientside. 
	In practice, it draws wireframe hitboxes, which you can't do in vanilla 
	GMOD for whatever reason.
	
	Requires:
	• self.meshTable
]]--
function ENT:DrawMesh()
	if not self.meshTable then
		if not noTableFlag then
			-- print("[ERROR] CLIENT HAS NO MESHTABLE")
			noTableFlag = true
		end return end
	noTableFlag = false

	cam.Start3D()

	mat_wireframe:SetVector( "$color", Vector( 1, 1, 1 ) )
	render.SetMaterial( mat_debugwhite )

	for i, mesha in pairs( self.meshTable ) do
		local matrix = Matrix()
		matrix:SetAngles( ( self:GetSolid() == SOLID_BBOX and self:GetMoveType() ~= MOVETYPE_VPHYSICS ) and angle_zero or self:GetAngles() )
		matrix:SetTranslation( self:GetPos() )

		cam.PushModelMatrix( matrix )
		mesha:Draw()

		cam.PopModelMatrix()
	end
	cam.End3D()
end

--[[
	Name: BuildMeshFromTable
	Takes massive list of Vectors generated at the output of PhysicsFromMesh() at end of 
	server-side Initialize() and turns it into a client-compadible Mesh object for wireframe
	rendering 
	
	Requires:
	• self.MeshTable, which requires the networked process described above to have completed.
]]--
function ENT:BuildMeshFromTable()
	local i = 0
	self.triangleMeshTable = {}
	for id, vector in pairs(self.meshTable) do
		local subTableCursor = ((id-1) % 3) + 1
		if subTableCursor == 1 then
			i = i + 1
			self.triangleMeshTable[i] = {}
		end
		self.triangleMeshTable[i][subTableCursor] = vector
	end

	self.meshTable = {}
	for index, tri in pairs(self.triangleMeshTable) do
		self.meshTable[index] = Mesh()
		self.meshTable[index]:BuildFromTriangles(tri)
	end
end