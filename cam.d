#!/usr/sbin/dtrace -s

inline string xpt_action_string[int key] =
	key ==  0 ? "XPT_NOOP" :
	key ==  1 ? "XPT_SCSI_IO" :
	key ==  2 ? "XPT_GDEV_TYPE" :
	key ==  3 ? "XPT_GDEVLIST" :
	key ==  4 ? "XPT_PATH_INQ" :
	key ==  5 ? "XPT_REL_SIMQ" :
	key ==  6 ? "XPT_SASYNC_CB" :
	key ==  7 ? "XPT_SDEV_TYPE" :
	key ==  8 ? "XPT_SCAN_BUS" :
	key ==  9 ? "XPT_DEV_MATCH" :
	key == 10 ? "XPT_DEBUG" :
	key == 11 ? "XPT_PATH_STATS" :
	key == 12 ? "XPT_GDEV_STATS" :
	key == 13 ? "XPT_0X0d" :
	key == 14 ? "XPT_DEV_ADVINFO" :
	key == 15 ? "XPT_ASYNC" :
	key == 16 ? "XPT_ABORT" :
	key == 17 ? "XPT_RESET_BUS" :
	key == 18 ? "XPT_RESET_DEV" :
	key == 19 ? "XPT_TERM_IO" :
	key == 20 ? "XPT_SCAN_LUN" :
	key == 21 ? "XPT_GET_TRAN_SETTINGS" :
	key == 22 ? "XPT_SET_TRAN_SETTINGS" :
	key == 23 ? "XPT_CALC_GEOMETRY" :
	key == 24 ? "XPT_ATA_IO" :
	key == 25 ? "XPT_SET_SIM_KNOB" :
	key == 26 ? "XPT_GET_SIM_KNOB" :
	key == 27 ? "XPT_SMP_IO" :
	key == 28 ? "XPT_NVME_IO" :
	key == 29 ? "XPT_MMC_IO" :
	key == 30 ? "XPT_SCAN_TGT" :
	key == 31 ? "XPT_NVME_ADMIN" :
	"Too big" ;

/*
 * key >> 5 gives the group:
 * Group 0:  six byte commands
 * Group 1:  ten byte commands
 * Group 2:  ten byte commands
 * Group 3:  reserved (7e and 7f are de-facto 32 bytes though)
 * Group 4:  sixteen byte commands
 * Group 5:  twelve byte commands
 * Group 6:  vendor specific
 * Group 7:  vendor specific
 */
inline int scsi_cdb_len[int key] =
	key == 0 ? 6 :
	key == 1 ? 10 :
	key == 2 ? 10 :
	key == 3 ? 1 :		/* reserved */
	key == 4 ? 16 :
	key == 5 ? 12 :
	key == 6 ? 1 :	 	/* reserved */
	/* key == 7 */ 1;	/* reserved */


inline int CAM_CDB_POINTER = 1;
inline int XPT_SCSI_IO = 0x01;
inline int XPT_ATA_IO = 0x18;
inline int XPT_NVME_IO = 0x1c;
inline int XPT_NVME_ADMIN = 0x1f;

dtrace:::BEGIN
{
}

/*
 * There's two choke points in CAM. We can intercept the request on the way down
 * in xpt_action, just before it's sent to the SIM. This can be a good place to
 * see what's going on before it happens. However, most I/O happens quite
 * quickly, this isn't much of an advantage. The other place is on completion
 * when the transaction is finally done. The retry mechanism is built into the
 * periph driver, which is responsible for submitting the request. It handles
 * when / how / if to retry, so doing the intercept in xpt_done or
 * xpt_done_direct will allow reporting of the results as well. There's the
 * CAM status which is set by the SIM to indicate if the command succeeded,
 * timed out, had additional status from the transport layer, etc.
 *
 * For this data collection, we use the completion point and we ignore the
 * submission point. We could use it to add metadata to each submission like
 * arrival time so we can measure the elapsed time of the command. At present,
 * we don't do that.
 *
 * Note, there's a number of probes with different predicates. We have to do
 * this because there's no 'if' or 'loop' constructs in D. In addition, there's
 * no functions, so some reporting of status has to be done with macros (we need
 * a separate predicate for each length of the submitted command, which in SCSI
 * can be diverse). These macros are done by the c preprocessor, for want of
 * something better.... though this may involve cross products and such, so it
 * may be revisited. If cross products are required, then camio.lua can do the
 * substitutions.
 *
 * The 'trace' context local variable controls printing of different types
 * of results. / * XXX_FILTER * / comments are used by camio to write
 * filtering predicates to report only the 'interesting' parts. I've opted
 * to have camio.lua do the replacement rather than having it define
 * a CPP macro on the command line.
 *
 * It may make more sense to move the constants out of this file into an include
 * file. And to move the D snippets into camio.lua so that we only register for
 * the transaction types that we're interested in. It might also make sense to
 * keep this in sync with fragments that move into camio.lua
 *
 * XXX at present, this is vastly simplified by not decoding the error stuff.
 * It might make sense to create real SDTs to allow some basic formatting to
 * be done in the kernel. Also, we're doing submission because done
 * isn't working.
 */

#define PROBE_not fbt::xpt_done:entry, fbt::xpt_done_process:entry
#define PROBE fbt::xpt_action:entry

/*
 * CAM queues a CCB to the SIM in xpt_action
 */
PROBE
{
	this->ccb = ((union ccb *)arg0);
	this->func = this->ccb->ccb_h.func_code & 0xff;
	this->periph = this->ccb->ccb_h.path->periph;
	this->trace = 0;
}

/****
 **** XPT_SCSI_IO section
 ****/

PROBE
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

/* SCSI_FILTER */

PROBE
/this->func == XPT_SCSI_IO && this->trace && this->cdb_len == 1/
{
	printf("%s%d: CDB: %02x",
	    stringof(this->periph->periph_name), this->periph->unit_number,
	    this->cdb[0]);
}

PROBE
/this->func == XPT_SCSI_IO && this->trace && this->cdb_len == 6/
{
	printf("%s%d: CDB: %02x %02x %02x %02x %02x %02x",
	    stringof(this->periph->periph_name), this->periph->unit_number,
	    this->cdb[0], this->cdb[1], this->cdb[2],
	    this->cdb[3], this->cdb[4], this->cdb[5]);
}

PROBE
/this->func == XPT_SCSI_IO && this->trace && this->cdb_len == 10/
{
	printf("%s%d: CDB: %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x",
	    stringof(this->periph->periph_name), this->periph->unit_number,
	    this->cdb[0], this->cdb[1], this->cdb[2],
	    this->cdb[3], this->cdb[4], this->cdb[5],
	    this->cdb[6], this->cdb[7], this->cdb[8],
	    this->cdb[9]);
}

PROBE
/this->func == XPT_SCSI_IO && this->trace && this->cdb_len == 12/
{
	printf("%s%d: CDB: %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x",
	    stringof(this->periph->periph_name), this->periph->unit_number,
	    this->cdb[0], this->cdb[1], this->cdb[2],
	    this->cdb[3], this->cdb[4], this->cdb[5],
	    this->cdb[6], this->cdb[7], this->cdb[8],
	    this->cdb[9], this->cdb[10], this->cdb[11]);
}

PROBE
/this->func == XPT_SCSI_IO && this->trace && this->cdb_len == 16/
{
	printf("%s%d: CDB: %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x",
	    stringof(this->periph->periph_name), this->periph->unit_number,
	    this->cdb[0], this->cdb[1], this->cdb[2],
	    this->cdb[3], this->cdb[4], this->cdb[5],
	    this->cdb[6], this->cdb[7], this->cdb[8],
	    this->cdb[9], this->cdb[10],this->cdb[11],
	    this->cdb[12],this->cdb[13],this->cdb[14],
	    this->cdb[15]);
}

/****
 **** XPT_ATA_IO section
 ****/
PROBE
/this->func == XPT_ATA_IO/
{
	this->ataio = &this->ccb->ataio;
}

/* ATA_FILTER */
PROBE
/this->func == XPT_ATA_IO/
{
}

PROBE
/this->func == XPT_ATA_IO && this->trace && (this->ataio->ata_flags & 3) == 0/
{
	this->adb = (char *)&this->ataio->cmd;

	printf("%s%d: ADB: %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x",
	    stringof(this->periph->periph_name), this->periph->unit_number,
	    this->adb[ 0], this->adb[ 1], this->adb[ 2], this->adb[ 3], this->adb[ 4], this->adb[ 5], this->adb[ 6], this->adb[ 7],
	    this->adb[ 8], this->adb[ 9], this->adb[10], this->adb[11], this->adb[12], this->adb[13]);
}

PROBE
/this->func == XPT_ATA_IO && this->trace && (this->ataio->ata_flags & 3) == 1/
{
	this->adb = (char *)&this->ataio->cmd;

	printf("%s%d: ADB: %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x 0x%02x",
	    stringof(this->periph->periph_name), this->periph->unit_number,
	    this->adb[ 0], this->adb[ 1], this->adb[ 2], this->adb[ 3], this->adb[ 4], this->adb[ 5], this->adb[ 6], this->adb[ 7],
	    this->adb[ 8], this->adb[ 9], this->adb[10], this->adb[11], this->adb[12], this->adb[13],
	    this->ataio->icc);
}

PROBE
/this->func == XPT_ATA_IO && this->trace && (this->ataio->ata_flags & 3) == 2/
{
	this->adb = (char *)&this->ataio->cmd;
	this->aux = (char *)&this->ataio->aux;

	printf("%s%d: ADB: %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x 0x%02x %02x %02x 0x%02x",
	    stringof(this->periph->periph_name), this->periph->unit_number,
	    this->adb[ 0], this->adb[ 1], this->adb[ 2], this->adb[ 3], this->adb[ 4], this->adb[ 5], this->adb[ 6], this->adb[ 7],
	    this->adb[ 8], this->adb[ 9], this->adb[10], this->adb[11], this->adb[12], this->adb[13],
	    this->aux[ 0], this->aux[ 1], this->aux[ 2], this->aux[ 3]);
}

PROBE
/this->func == XPT_ATA_IO && this->trace && (this->ataio->ata_flags & 3) == 3/
{
	this->adb = (char *)&this->ataio->cmd;
	this->aux = (char *)&this->ataio->aux;

	printf("%s%d: ADB: %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x 0x%02x %02x %02x 0x%02x 0x%02x",
	    stringof(this->periph->periph_name), this->periph->unit_number,
	    this->adb[ 0], this->adb[ 1], this->adb[ 2], this->adb[ 3], this->adb[ 4], this->adb[ 5], this->adb[ 6], this->adb[ 7],
	    this->adb[ 8], this->adb[ 9], this->adb[10], this->adb[11], this->adb[12], this->adb[13],
	    this->ataio->icc,
	    this->aux[ 0], this->aux[ 1], this->aux[ 2], this->aux[ 3]);
}

/****
 **** XPT_NVME_IO section
 ****/
PROBE
/this->func == XPT_NVME_IO || this->func == XPT_NVME_ADMIN/
{
	this->nvmeio = &this->ccb->nvmeio;
}

/* NVME_FILTER */

PROBE
/(this->func == XPT_NVME_IO || this->func == XPT_NVME_ADMIN) &&
 this->trace/
{
	this->ndb = (uint32_t *)&this->nvmeio->cmd;

	/* Note: We omit the half of the command the driver / sim fills in to do the I/O */
	/* Not 100% this is cool, but it's what we're doing :) */
	/* dtrace makes it hard to toss in a letoh32() here, so we don't */
	printf("%s%d: N%sDB: %08x %08x %08x %08x %08x %08x %08x %08x",
	    stringof(this->periph->periph_name), this->periph->unit_number,
	    this->func == XPT_NVME_IO ? "I" : "A",
	    this->ndb[ 0], this->ndb[ 1], this->ndb[10], this->ndb[11], this->ndb[12], this->ndb[13], this->ndb[14], this->ndb[15]);
}
