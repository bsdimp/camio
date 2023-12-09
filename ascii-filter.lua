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

return ascii_filter
