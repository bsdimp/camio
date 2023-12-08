--
-- SPDX-License-Identifier: BSD-2-Clause
--
-- Copyright (c) 2023 Warner Losh <imp@FreeBSD.org>
--

--
-- Lua front end to cam.d dtrace script. It takes command line input and writes
-- the proper filter functions to produce the desired subset of the I/O traffic
-- in the system.
--

--
-- Command flags
--

-- Interim Grammar supported:
-- One of the following:
-- scsi		All SCSI traffic
-- ata		All ATA traffic
-- nvme		All NVME traffic
--
local ucl = require("ucl")
local io = require("io")

local filters = { }

filters["scsi"] = function(script)
	return script:gsub([[/%* SCSI_FILTER %*/
]],[[
fbt::xpt_action:entry
/this->func == XPT_SCSI_IO/
{
	this->trace = 1;
}
]])
end

filters["ata"] = function(script)
	return script:gsub([[/%* SCSI_FILTER %*/
]],[[
fbt::xpt_action:entry
/this->func == XPT_ATA_IO/
{
	this->trace = 1;
}
]])
end

filters["nvme"] = function(script)
	return script:gsub([[/%* NVME_FILTER %*/
]],[[
fbt::xpt_action:entry
/this->func == XPT_NVME_IO || this->func == XPT_NVME_ADMIN/
{
	this->trace = 1;
}
]])
end

local function main(f)
	-- Read in the template
	local fin = assert(io.open("cam.d", "r"))
	local d = fin:read("*a")
	fin:close()
	local dd = f(d)
	local dfile = os.tmpname()
	local fout = assert(io.open(dfile, "a"))
	fout:write(dd)
	fout:close()
	local stream = io.popen("sudo dtrace -C -s " .. dfile)
	stream:setvbuf("line")
	for line in stream:lines() do
		local l = line:gsub("^.*:entry ","")
		io.output():write(l .. "\n")
	end

	os.remove(dfile)
end

-- Entry point

if #arg ~= 1 then
	error("usage: " .. arg[0] .. "filter")
end
if filters[arg[1]] == nil then
	error("I don't know about filter " .. arg[1])
end

main(filters[arg[1]])
