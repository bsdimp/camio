--
-- SPDX-License-Identifier: BSD-2-Clause
--
-- Copyright (c) 2023 Warner Losh <imp@FreeBSD.org>
--

local decoder = require("decoder")
local nvme_io = require("nvme-io")

local nvme = {}

nvme.dtrace_program = {
	script = function(script)
		return script ..
[[
/****
 **** XPT_NVME_IO section
 ****/
fbt::xpt_action:entry
/this->func == XPT_NVME_IO || this->func == XPT_NVME_ADMIN/
{
	this->nvmeio = &this->ccb->nvmeio;
}

fbt::xpt_action:entry
/this->func == XPT_NVME_IO || this->func == XPT_NVME_ADMIN/
{
	this->trace = 1;
}

fbt::xpt_action:entry
/(this->func == XPT_NVME_IO || this->func == XPT_NVME_ADMIN) && this->trace/
{
	this->ndb = (uint32_t *)&this->nvmeio->cmd;

	/* Note: We omit the half of the command the driver / sim fills in to do the I/O */
	/* Not 100% this is cool, but it's what we're doing :) */
	/* dtrace makes it hard to toss in a letoh32() here, so we don't */
	printf("%s%d: N%sDB: %08x %08x %08x %08x %08x %08x %08x %08x\n",
	    stringof(this->periph->periph_name), this->periph->unit_number,
	    this->func == XPT_NVME_IO ? "I" : "A",
	    this->ndb[ 0], this->ndb[ 1], this->ndb[10], this->ndb[11], this->ndb[12],
	    this->ndb[13], this->ndb[14], this->ndb[15]);
}
]]
	end
}

local function find_command(line, prefix)
	local s, e = line:find(prefix)
	local walker, n, ep
	local cmd = {}

	if (s == nil) then
		return nil
	end

	walker = e + 1
	ep = line:len() + 1
	n = 0
	-- For the moment just assume we have 8 hex numbers in a row
	-- and don't validate
	-- Same is true for both ADMIN and IO commands
	while walker + 8 <= ep do
		cmd[n] = tonumber(line:sub(walker, walker + 8), 16)
		walker = walker + 9
		n = n + 1
		-- We skip words 2 through 9 since not in output -- see above
		if n == 2 then
			n = 10
		end
	end
	return cmd
end

-- XXX what to do about nvme I/O vs nvme Admin? Most admin commands
-- are hard to trace so punt for now.
nvme.ascii_filter = function(file, line, cmd_prefix, res_prefix, echo)
	if echo then
		file:write(line .. "\n")
	end
	local nvme_cmd = find_command(line, "NIDB: ")
	if nvme_cmd == nil then
		return
	end
	decoder.decode(nvme_io, nvme_cmd)
end

return nvme
