--
-- SPDX-License-Identifier: BSD-2-Clause
--
-- Copyright (c) 2023 Warner Losh <imp@FreeBSD.org>
--

local dtrace_filter = {}

dtrace_filter["scsi"] = {
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

dtrace_filter["ata"] = {
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

	printf("%s%d: ADB: %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x\n",
	    stringof(this->periph->periph_name), this->periph->unit_number,
	    this->adb[ 0], this->adb[ 1], this->adb[ 2], this->adb[ 3], this->adb[ 4], this->adb[ 5], this->adb[ 6], this->adb[ 7],
	    this->adb[ 8], this->adb[ 9], this->adb[10], this->adb[11], this->adb[12], this->adb[13]);
}

/* Dump ata command with icc register */
fbt::xpt_action:entry
/this->func == XPT_ATA_IO && this->trace && (this->ataio->ata_flags & 3) == 1/
{
	this->adb = (char *)&this->ataio->cmd;

	printf("%s%d: ADB: %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x 0x%02x\n",
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

	printf("%s%d: ADB: %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x 0x%02x %02x %02x 0x%02x\n",
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

	printf("%s%d: ADB: %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x 0x%02x %02x %02x 0x%02x 0x%02x\n",
	    stringof(this->periph->periph_name), this->periph->unit_number,
	    this->adb[ 0], this->adb[ 1], this->adb[ 2], this->adb[ 3], this->adb[ 4], this->adb[ 5], this->adb[ 6], this->adb[ 7],
	    this->adb[ 8], this->adb[ 9], this->adb[10], this->adb[11], this->adb[12], this->adb[13],
	    this->ataio->icc,
	    this->aux[ 0], this->aux[ 1], this->aux[ 2], this->aux[ 3]);
}
]]
	end
}

return dtrace_filter
