--
-- SPDX-License-Identifier: BSD-2-Clause
--
-- Copyright (c) 2023 Warner Losh <imp@FreeBSD.org>
--

local decoder = require("decoder")
local ata_io = require("scsi-io")

local ata = {}

ata.dtrace_program = {
		script = function(script)
			return script ..
[[
/****
 **** XPT_ATA_IO section
 ****/
fbt::xpt_action:entry
/this->func == XPT_ATA_IO/
{
	this->ataio = &this->ccb->ataio;
}

fbt::xpt_action:entry
/this->func == XPT_ATA_IO/
{
	this->trace = 1;
}

/* Dump ata command without icc or aux register */
fbt::xpt_action:entry
/this->func == XPT_ATA_IO && this->trace && (this->ataio->ata_flags & 3) == 0/
{
	this->adb = (char *)&this->ataio->cmd;

	printf("%s%d: ADB: %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x 00 00 00 00 00\n",
	    stringof(this->periph->periph_name), this->periph->unit_number,
	    this->adb[ 0], this->adb[ 1], this->adb[ 2], this->adb[ 3], this->adb[ 4], this->adb[ 5], this->adb[ 6], this->adb[ 7],
	    this->adb[ 8], this->adb[ 9], this->adb[10], this->adb[11], this->adb[12], this->adb[13]);
}

/* Dump ata command with icc register */
fbt::xpt_action:entry
/this->func == XPT_ATA_IO && this->trace && (this->ataio->ata_flags & 3) == 1/
{
	this->adb = (char *)&this->ataio->cmd;

	printf("%s%d: ADB: %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x 0x%02x 00 00 00 00\n",
	    stringof(this->periph->periph_name), this->periph->unit_number,
	    this->adb[ 0], this->adb[ 1], this->adb[ 2], this->adb[ 3], this->adb[ 4], this->adb[ 5], this->adb[ 6], this->adb[ 7],
	    this->adb[ 8], this->adb[ 9], this->adb[10], this->adb[11], this->adb[12], this->adb[13],
	    this->ataio->icc);
}

/* Dump ata command with aux register */
fbt::xpt_action:entry
/this->func == XPT_ATA_IO && this->trace && (this->ataio->ata_flags & 3) == 2/
{
	this->adb = (char *)&this->ataio->cmd;
	this->aux = (char *)&this->ataio->aux;

	printf("%s%d: ADB: %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x 00 %02x %02x %02x %02x\n",
	    stringof(this->periph->periph_name), this->periph->unit_number,
	    this->adb[ 0], this->adb[ 1], this->adb[ 2], this->adb[ 3], this->adb[ 4], this->adb[ 5], this->adb[ 6], this->adb[ 7],
	    this->adb[ 8], this->adb[ 9], this->adb[10], this->adb[11], this->adb[12], this->adb[13],
	    this->aux[ 0], this->aux[ 1], this->aux[ 2], this->aux[ 3]);
}

/* Dump ata command with both icc and aux registers */
fbt::xpt_action:entry
/this->func == XPT_ATA_IO && this->trace && (this->ataio->ata_flags & 3) == 3/
{
	this->adb = (char *)&this->ataio->cmd;
	this->aux = (char *)&this->ataio->aux;

	printf("%s%d: ADB: %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x\n",
	    stringof(this->periph->periph_name), this->periph->unit_number,
	    this->adb[ 0], this->adb[ 1], this->adb[ 2], this->adb[ 3], this->adb[ 4], this->adb[ 5], this->adb[ 6], this->adb[ 7],
	    this->adb[ 8], this->adb[ 9], this->adb[10], this->adb[11], this->adb[12], this->adb[13],
	    this->ataio->icc,
	    this->aux[ 0], this->aux[ 1], this->aux[ 2], this->aux[ 3]);
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
	return res
end

ata.ascii_filter = function(file, line, cmd_prefix, res_prefix, echo)
	if echo then
		file:write(line .. "\n")
	end
	local adb = find_command(line, "ADB: ")
	if adb == nil then
		return
	end
	decoder.decode(ata_io, adb)
end

return ata

