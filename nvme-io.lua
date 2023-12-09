-- NVME 1.4 NVM command set (Chapter 6)
-- Note: common fields omitted -- what to do?
-- Also: All command opcodes are in table, but only some are fully fleshed out

local nvme_io = {
    {
	name = "Flush",
	{ name="OPC",	len=8, word=0, bit=0,		id=true, value=0x00 },
	{ name="NSID",	len=32,	word=1, bit=0 },
    },
    {
	name = "Read",
	{ name="OPC",	len=8, word=0, bit=0,		id=true, value=0x02 },
	{ name="NSID",	len=32,	word=1, bit=0 },
	{ name="SLBA",	len=64, word=10, bit=0 },
	{ name="NLB",	len=16, word=12, bit=0 },
	{ name="PRINFO",len=4, word=12, bit=26,		nonzero=true },
	{ name="FUA",	len=4, word=12, bit=30,		nonzero=true },
	{ name="LR",	len=4, word=12, bit=31,		nonzero=true },
	{ name="DSM",	len=8, word=13, bit=0,		nonzero=true },
	{ name="EILBRT",len=32, word=14, bit=0,		protection=true },
	{ name="ELBATM",len=32, word=15, bit=0,		protection=true },
    },
    {
	name = "Write",
	{ name="OPC",	len=8, word=0, bit=0,		id=true, value=0x01 },
	{ name="NSID",	len=32,	word=1, bit=0 },
	{ name="SLBA",	len=64, word=10, bit=0 },
	{ name="NLB",	len=16, word=12, bit=0 },
	{ name="DTYPE",	len=4, word=12, bit=20,		nonzero=true },
	{ name="PRINFO",len=4, word=12, bit=26,		nonzero=true },
	{ name="FUA",	len=4, word=12, bit=30,		nonzero=true },
	{ name="LR",	len=4, word=12, bit=31,		nonzero=true },
	{ name="DSM",	len=8, word=13, bit=0,		nonzero=true },
	{ name="DSPEC",	len=16, word=13, bit=16,	nonzero=true },
	{ name="ILBRT",	len=32, word=14, bit=0,		protection=true },
	{ name="LBATM",	len=16, word=15, bit=16,	protection=true },
	{ name="LBAT",	len=16, word=15, bit=0,		protection=true },
    },
    {
	name = "Write Uncorrectable",
	{ name="OPC",	len=8, word=0, bit=0,		id=true, value=0x04 },
	{ name="NSID",	len=32,	word=1, bit=0 },
    },
    {
	name = "Compare",
	{ name="OPC",	len=8, word=0, bit=0,		id=true, value=0x05 },
	{ name="NSID",	len=32,	word=1, bit=0 },
    },
    {
	name = "Write Zeros",
	{ name="OPC",	len=8, word=0, bit=0,		id=true, value=0x08 },
	{ name="NSID",	len=32,	word=1, bit=0 },
    },
    {
	name = "Dataset Management",
	{ name="OPC",	len=8, word=0, bit=0,		id=true, value=0x09 },
	{ name="NSID",	len=32,	word=1, bit=0 },
    },
    {
	name = "Verify",
	{ name="OPC",	len=8, word=0, bit=0,		id=true, value=0x0c },
	{ name="NSID",	len=32,	word=1, bit=0 },
    },
    {
	name = "Reservation Register",
	{ name="OPC",	len=8, word=0, bit=0,		id=true, value=0x0d },
	{ name="NSID",	len=32,	word=1, bit=0 },
    },
    {
	name = "Reservation Report",
	{ name="OPC",	len=8, word=0, bit=0,		id=true, value=0x0e },
	{ name="NSID",	len=32,	word=1, bit=0 },
    },
    {
	name = "Reservation Acquire",
	{ name="OPC",	len=8, word=0, bit=0,		id=true, value=0x11 },
	{ name="NSID",	len=32,	word=1, bit=0 },
    },
    {
	name = "Reservation Release",
	{ name="OPC",	len=8, word=0, bit=0,		id=true, value=0x15 },
	{ name="NSID",	len=32,	word=1, bit=0 },
    },
}

return nvme_io
