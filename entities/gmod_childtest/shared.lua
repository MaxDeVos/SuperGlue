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


function formatPose(ent)
	local posVal = "null"
	local angVal = "null"

	if not ent.Pos then
		posVal = ent:GetPos()
	else
		posVal = ent.Pos
	end

	if not ent.Ang then
		angVal = ent:GetAngles()
	else
		angVal = ent.Ang
	end

	return tostring(posVal), tostring(angVal)
end

local eventIterator = 1
local masterTbl = {}
local event = {}

--[[
	Each entry of masterTbl is a single objects life-cycle
	Each entry of an entry of masterTbl is the specific datapoint of that object at that event (called entTable here).
	Therefore:
	masterTbl[tostring(selfInstance)] = entTable 		-- shows what entTable represents
	entTable[eventIterator] = 3							-- assigning selfInstance's state at that event to 3.

	The name of the object IS the key, so no title-entry is needed.	They can be appended at print-time.

	events is a table that relates eventIterator values to event names. You could stop here and assume the datapoint entries are final.
	Should your datapoint entries contain more than one piece of information (such as a relationship, position vector, and angle vector),
	you'll want entEventTable as well, which is defined below. If not, printing should be done as follows for debugging in Excel or something.

	nil			masterTbl[a]'s key		masterTbl[b]'s key		..
	event[i]	masterTbl[a][i+1]		masterTbl[a][i+1]		..
	..			..						..						..

	entEventTable is the parts of a specific datapoint (entTable). This is used to store the different pieces of info
	for formatting at print-time.
	Therefore:
	entEventTable = entTable[eventIterator] = masterTbl[tostring(selfInstance)][eventIterator]

	In this use-case, entEventTable is divided up as follows
	entEventTable[1] = note (usually relationship such as child or self)
	entEventTable[2] = Pos vector
	entEventTable[3] = Angle vector

	To print with entEventTable, you'll use the same printing approach as above, except you'll need to format the data at
	print-time, or print multiple seperate tables, one for each type of data.
]]--


function resetTable()
	eventIterator = 1
	masterTbl = {}
	event = {}
end

function printSinglePose(state, note, ent, notEndOfEvent)
	if GetConVar("max_tableActive"):GetInt() ~= 1 then return end
	print("WRITING POSE OF " .. note .. "  " .. tostring(ent))
	local entTable = {}
	if masterTbl[tostring(ent)] then entTable = masterTbl[tostring(ent)] else entTable = {} end

	local entEventTable = {}
	if entTable[eventIterator] then entEventTable = masterTbl[eventIterator] else entEventTable = {} end

	local pos, ang
	pos, ang = formatPose(ent)

	entEventTable[1] = note
	entEventTable[2] = pos
	entEventTable[3] = ang
	print("WRITING   " .. state .. "   TO EVENT @ " .. eventIterator)
	event[eventIterator] = state

	entTable[eventIterator] = entEventTable
	masterTbl[tostring(ent)] = entTable
	if not notEndOfEvent then eventIterator = eventIterator + 1 end
end


function printPoseChildren(state, childrenTable, notEndOfEvent)
	if GetConVar("max_tableActive"):GetInt() ~= 1 then return end
	event[eventIterator] = state -- In case childrenTable is empty, we need a value here anyway
	for id, child in pairs(childrenTable) do
		printSinglePose(state, "child", child, true)
	end
	if not notEndOfEvent then eventIterator = eventIterator + 1 end
end


function printPoseAll(state, childrenTable, selfInstance, notEndOfEvent)
	if GetConVar("max_tableActive"):GetInt() ~= 1 then return end
	printSinglePose(state, "self", selfInstance, true)
	printPoseChildren(state, childrenTable, true)
	if not notEndOfEvent then eventIterator = eventIterator + 1 end
end


function printCSV()
	local eventNum = 0
	while eventNum + 1 <= eventIterator do
		local row = ","
		if eventNum > 0 then
			if event[eventNum] then
				row = event[eventNum] .. ","
			else
				print("row is fucked. eventNum = " .. tostring(eventNum + 1))
			end
		end
		for entName, entTable in pairs(masterTbl) do
			if eventNum == 0 then
				row = row .. entName .. ","
			else
				if not entTable[eventNum] then
					row = row .. ","
				else
					entString = ""
					for _, val in pairs(entTable[eventNum]) do
						entString = entString .. tostring(val) .. "|"
					end
					row = row .. entString .. ","
				end
			end
		end
		-- print(row)
		eventNum = eventNum + 1
	end
end


function AdjustVectorTableToWorldCoords(vecTable, pos, angle)
	local rTable = {}
	for i, vec in pairs(vecTable) do
		rTable[i] = Vector(vec["pos"])
		rTable[i]:Rotate(angle)
		rTable[i]:Add(pos)
	end

	return rTable
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


hook.Add("CanTool","No Toolgun on polys",function( ply, tr, tool )
	 if ( IsValid( tr.Entity ) and tr.Entity:GetParent() and tr.Entity:GetParent():IsValid() and tr.Entity:GetParent():GetClass() == "gmod_shape" ) then
		 return false
	 end
end)
