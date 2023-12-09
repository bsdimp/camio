--
-- SPDX-License-Identifier: BSD-2-Clause
--
-- Copyright (c) 2023 Warner Losh <imp@FreeBSD.org>
--

local decoder = require("decoder")
local scsi_io = require("scsi-io")

local scsi = {}

scsi.dtrace_program = {
		script = function(script)
			return script ..
[[
/****
 **** XPT_SCSI_IO section
 ****/

fbt::xpt_action:entry
/this->func == XPT_SCSI_IO/
{
	this->hdr = &this->ccb->ccb_h;
	this->csio = &this->ccb->csio;
	this->cdb = this->hdr->flags & CAM_CDB_POINTER ?
		this->csio->cdb_io.cdb_ptr :
		&this->csio->cdb_io.cdb_bytes[0];
	this->cdb_len = this->csio->cdb_len ? this->csio->cdb_len :
		scsi_cdb_len[this->cdb[0] >> 5];
}

fbt::xpt_action:entry
/this->func == XPT_SCSI_IO/
{
	this->trace = 1;
}

fbt::xpt_action:entry
/this->func == XPT_SCSI_IO && this->trace && this->cdb_len == 1/
{
	printf("%s%d: CDB: %02x\n",
	    stringof(this->periph->periph_name), this->periph->unit_number,
	    this->cdb[0]);
}

fbt::xpt_action:entry
/this->func == XPT_SCSI_IO && this->trace && this->cdb_len == 6/
{
	printf("%s%d: CDB: %02x %02x %02x %02x %02x %02x\n",
	    stringof(this->periph->periph_name), this->periph->unit_number,
	    this->cdb[0], this->cdb[1], this->cdb[2],
	    this->cdb[3], this->cdb[4], this->cdb[5]);
}

fbt::xpt_action:entry
/this->func == XPT_SCSI_IO && this->trace && this->cdb_len == 10/
{
	printf("%s%d: CDB: %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x\n",
	    stringof(this->periph->periph_name), this->periph->unit_number,
	    this->cdb[0], this->cdb[1], this->cdb[2],
	    this->cdb[3], this->cdb[4], this->cdb[5],
	    this->cdb[6], this->cdb[7], this->cdb[8],
	    this->cdb[9]);
}

fbt::xpt_action:entry
/this->func == XPT_SCSI_IO && this->trace && this->cdb_len == 12/
{
	printf("%s%d: CDB: %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x\n",
	    stringof(this->periph->periph_name), this->periph->unit_number,
	    this->cdb[0], this->cdb[1], this->cdb[2],
	    this->cdb[3], this->cdb[4], this->cdb[5],
	    this->cdb[6], this->cdb[7], this->cdb[8],
	    this->cdb[9], this->cdb[10], this->cdb[11]);
}

fbt::xpt_action:entry
/this->func == XPT_SCSI_IO && this->trace && this->cdb_len == 16/
{
	printf("%s%d: CDB: %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x\n",
	    stringof(this->periph->periph_name), this->periph->unit_number,
	    this->cdb[0], this->cdb[1], this->cdb[2],
	    this->cdb[3], this->cdb[4], this->cdb[5],
	    this->cdb[6], this->cdb[7], this->cdb[8],
	    this->cdb[9], this->cdb[10],this->cdb[11],
	    this->cdb[12],this->cdb[13],this->cdb[14],
	    this->cdb[15]);
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
	ep = line:len()
	n = 0
	-- For the moment just assume we have 2-digit hex numbers
	-- and don't validate
	while walker + 2 <= ep do
		cmd[n] = tonumber(line:sub(walker, walker + 2), 16)
		walker = walker + 3
		n = n + 1
	end
	return cmd
end

scsi.ascii_filter = function(file, line, cmd_prefix, res_prefix, echo)
	if echo then
		file:write(line .. "\n")
	end
	local cdb = find_command(line, "CDB: ")
	if cdb == nil then
		return
	end
	decoder.decode(scsi_io, cdb)
end

return scsi
