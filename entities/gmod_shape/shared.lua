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

function AdjustVectorTableToWorldCoords(vecTable, pos, angle)
	local rTable = {}
	for i, vec in pairs(vecTable) do
		rTable[i] = Vector(vec["pos"])
		rTable[i]:Rotate(angle)
		rTable[i]:Add(pos)
	end

	return rTable
end

function ENT:SetupDataTables()

end

-- Don't allow children in a weld to move independently of their parent
hook.Add("PhysgunPickup", "ChildrenRule", function(ply, ent)
	if ent:GetParent() and ent:GetParent():IsValid() and ent:GetParent():GetClass() == "gmod_shape" then
		return false
	end
end)

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

function print_table(node)

	local cache, stack, output = {},{},{}
	local depth = 1
	local output_str = "{\n"

	while true do
		local size = 0
		for k,v in pairs(node) do
			size = size + 1
		end

		local cur_index = 1
		for k,v in pairs(node) do
			if (cache[node] == nil) or (cur_index >= cache[node]) then

				if (string.find(output_str,"}",output_str:len())) then
					output_str = output_str .. ",\n"
				elseif not (string.find(output_str,"\n",output_str:len())) then
					output_str = output_str .. "\n"
				end

				-- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
				table.insert(output,output_str)
				output_str = ""

				local key
				if (type(k) == "number" or type(k) == "boolean") then
					key = "["..tostring(k).."]"
				else
					key = "['"..tostring(k).."']"
				end

				if (type(v) == "number" or type(v) == "boolean") then
					output_str = output_str .. string.rep('\t',depth) .. key .. " = "..tostring(v)
				elseif (type(v) == "table") then
					output_str = output_str .. string.rep('\t',depth) .. key .. " = {\n"
					table.insert(stack,node)
					table.insert(stack,v)
					cache[node] = cur_index+1
					break
				else
					output_str = output_str .. string.rep('\t',depth) .. key .. " = '"..tostring(v).."'"
				end

				if (cur_index == size) then
					output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
				else
					output_str = output_str .. ","
				end
			else
				-- close the table
				if (cur_index == size) then
					output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
				end
			end

			cur_index = cur_index + 1
		end

		if (size == 0) then
			output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
		end

		if (#stack > 0) then
			node = stack[#stack]
			stack[#stack] = nil
			depth = cache[node] == nil and depth + 1 or depth - 1
		else
			break
		end
	end

	-- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
	table.insert(output,output_str)
	output_str = table.concat(output)

	print(output_str)
end

function split (inputstr, sep)
	if sep == nil then
			sep = "%s"
	end
	local t={}
	for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
			table.insert(t, str)
	end
	return t
end

hook.Add("PhysgunPickup","Don't pick up children", function(ply,ent)
	if ent:GetParent() and ent:GetParent():IsValid() and ent:GetParent():GetClass() == "gmod_poly" then
		return false
	end
end)
-- hook.Add("CanTool","No Toolgun on polys",function( ply, tr, tool )
	 -- if ( IsValid( tr.Entity ) and tr.Entity:GetParent() and tr.Entity:GetParent():IsValid() and tr.Entity:GetParent():GetClass() == "gmod_poly" ) then
		 -- return false
	 -- end
-- end)
