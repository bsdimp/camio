--
-- SPDX-License-Identifier: BSD-2-Clause
--
-- Copyright (c) 2023 Warner Losh <imp@FreeBSD.org>
--

local dtrace_filter = {}

dtrace_filter["scsi"] = {
	script = function(script)
		return script:gsub([[/%* SCSI_FILTER %*/
]],[[
fbt::xpt_action:entry
/this->func == XPT_SCSI_IO/
{
	this->trace = 1;
}
]])
	end
}

dtrace_filter["ata"] = {
	script = function(script)
		return script:gsub([[/%* SCSI_FILTER %*/
]],[[
fbt::xpt_action:entry
/this->func == XPT_ATA_IO/
{
	this->trace = 1;
}
]])
	end
}

dtrace_filter["nvme"] = {
	script = function(script)
		return script:gsub([[/%* NVME_FILTER %*/
]],[[
fbt::xpt_action:entry
/this->func == XPT_NVME_IO || this->func == XPT_NVME_ADMIN/
{
	this->trace = 1;
}
]])
	end
}

return dtrace_filter
