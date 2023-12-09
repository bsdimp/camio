--
-- SPDX-License-Identifier: BSD-2-Clause
--
-- Copyright (c) 2023 Warner Losh <imp@FreeBSD.org>
--

--
-- base class for decoding ASCII representations of SCSI commands (CDB),
-- ATA commands (ADB) and NVME comands (NIDB and NADB).
--

local ascii_filter = {}
local io = require("io")
local decoder = require("decoder")
local nvme_io = require("nvme-io")

ascii_filter["scsi"] = function(file, line, cmd_prefix, res_prefix, echo)
	if echo then
		file:write(line .. "\n")
	end
end

ascii_filter["ata"] = function(file, line, cmd_prefix, res_prefix, echo)
	if echo then
		file:write(line .. "\n")
	end
end

local function nvme_find_command(line, prefix)
	local s, e = line:find(prefix)
	local walker, n, ep
	local res = {}

	if (s == nil) then
		return nil
	end

	walker = e + 1
	ep = line:len()
	n = 0
	-- For the moment just assume we have 8 hex numbers in a row
	-- and don't validate
	-- Same is true for both ADMIN and IO commands
	while walker + 8 <= ep do
		res[n] = tonumber(line:sub(walker, walker + 8), 16)
		walker = walker + 9
		n = n + 1
		-- We skip words 2 through 9 since not in output
		if n == 2 then
			n = 10
		end
	end
	return res
end

-- XXX what to do about nvme I/O vs nvme Admin? Most admin commands
-- are hard to trace so punt for now.
ascii_filter["nvme"] = function(file, line, cmd_prefix, res_prefix, echo)
	if echo then
		file:write(line .. "\n")
	end
	local nvme_sub = nvme_find_command(line, "NIDB: ")
	if nvme_sub == nil then
		return
	end
	decoder.decode(nvme_io, nvme_sub)
end

return ascii_filter
