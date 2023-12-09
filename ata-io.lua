
local ata_io = {
    {
	name = "NOP FLUSHQUEUE",
	{ name="COMMAND", len=8, byte=0, bit=0,		id=true, value=0x00 },
	{ name="FEATURE", len=8, byte=1, bit=0,		id=true, value=0x00 },
    },
    {
	name = "NOP AUTOPOLL",
	{ name="COMMAND", len=8, byte=0, bit=0,		id=true, value=0x00 },
	{ name="FEATURE", len=8, byte=1, bit=0,		id=true, value=0x01 },
    },
    {
	name = "NOP",
	{ name="COMMAND", len=8, byte=0, bit=0,		id=true, value=0x00 },
    },
}

return nvme_io
