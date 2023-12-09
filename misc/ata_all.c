	switch (cmd->command) {
	case 0x00:
		switch (cmd->features) {
		case 0x00: return ("NOP FLUSHQUEUE"); // 28
		case 0x01: return ("NOP AUTOPOLL"); // 28
		}
		return ("NOP"); // 28
	case 0x03: return ("CFA REQUEST EXTENDED ERROR"); // 28
	case 0x06:
		switch (cmd->features) {
		case 0x01: return ("DSM TRIM");
		}
		return "DSM";
	case 0x07:
		switch (cmd->features) {
		case 0x01: return ("DSM XL TRIM");
		}
		return "DSM XL";
	case 0x08: return ("DEVICE RESET"); // 28
	case 0x0b: return ("REQUEST SENSE DATA EXT");
	case 0x12: return ("GET PHYSICAL ELEMENT STATUS");
	case 0x20: return ("READ"); // 28
	case 0x21: return ("READ NO RETRY"); // 28
	case 0x22: return ("READ LONG"); // 28
	case 0x23: return ("READ LONG NO RETRY"); // 28
	case 0x24: return ("READ48");
	case 0x25: return ("READ DMA48");
	case 0x26: return ("READ DMA QUEUED48");
	case 0x27: return ("READ NATIVE MAX ADDRESS48");
	case 0x29: return ("READ MUL48");
	case 0x2a: return ("READ STREAM DMA48");
	case 0x2b: return ("READ STREAM48");
	case 0x2f: return ("READ LOG EXT");
	case 0x30: return ("WRITE"); // 28
	case 0x31: return ("WRITE NO RETRY"); // 28
	case 0x32: return ("WRITE LONG"); // 28
	case 0x33: return ("WRITE LONG NO RETRY"); // 28
	case 0x34: return ("WRITE48");
	case 0x35: return ("WRITE DMA48");
	case 0x36: return ("WRITE DMA QUEUED48");
	case 0x37: return ("SET MAX ADDRESS48");
	case 0x38: return ("CFA WRITE SECTORS WITHOUT ERASE");
	case 0x39: return ("WRITE MUL48");
	case 0x3a: return ("WRITE STREAM DMA48");
	case 0x3b: return ("WRITE STREAM48");
	case 0x3c: return ("WRITE VERIFY"); // 28
	case 0x3d: return ("WRITE DMA FUA48");
	case 0x3e: return ("WRITE DMA QUEUED FUA48");
	case 0x3f: return ("WRITE LOG EXT");
	case 0x40: return ("READ VERIFY"); // 28
	case 0x41: return ("READ VERIFY NO RETRY"); // 28
	case 0x42: return ("READ VERIFY48");
	case 0x44:
		switch (cmd->features) {
		case 0x01: return ("ZERO EXT TRIM");
		}
		return "ZERO EXT";
	case 0x45:
		switch (cmd->features) {
		case 0x55: return ("WRITE UNCORRECTABLE48 PSEUDO");
		case 0xaa: return ("WRITE UNCORRECTABLE48 FLAGGED");
		}
		return "WRITE UNCORRECTABLE48";
	case 0x47: return ("READ LOG DMA EXT");
	case 0x4a: return ("ZAC MANAGEMENT IN");
	case 0x50: return ("FORMAT TRACK"); // 28
	case 0x51: return ("CONFIGURE STREAM");
	case 0x57: return ("WRITE LOG DMA EXT");
	case 0x5b: return ("TRUSTED NON DATA"); // 28
	case 0x5c: return ("TRUSTED RECEIVE"); // 28
	case 0x5d: return ("TRUSTED RECEIVE DMA"); // 28
	case 0x5e: return ("TRUSTED SEND"); // 28
	case 0x5f: return ("TRUSTED SEND DMA"); // 28
	case 0x60: return ("READ FPDMA QUEUED");
	case 0x61: return ("WRITE FPDMA QUEUED");
	case 0x63:
		switch (cmd->features & 0xf) {
		case 0x00: return ("NCQ NON DATA ABORT NCQ QUEUE");
		case 0x01: return ("NCQ NON DATA DEADLINE HANDLING");
		case 0x02: return ("NCQ NON DATA HYBRID DEMOTE BY SIZE");
		case 0x03: return ("NCQ NON DATA HYBRID CHANGE BY LBA RANGE");
		case 0x04: return ("NCQ NON DATA HYBRID CONTROL");
		case 0x05: return ("NCQ NON DATA SET FEATURES");
		case 0x06: return ("NCQ NON DATA ZERO EXT");
		case 0x07: return ("NCQ NON DATA ZAC MANAGEMENT OUT");
		}
		return ("NCQ NON DATA");
	case 0x64:
		switch (cmd->sector count exp & 0xf) {
		case 0x00: return ("SEND FPDMA QUEUED DATA SET MANAGEMENT");
		case 0x01: return ("SEND FPDMA QUEUED HYBRID EVICT");
		case 0x02: return ("SEND FPDMA QUEUED WRITE LOG DMA EXT");
		case 0x03: return ("SEND FPDMA QUEUED ZAC MANAGEMENT OUT");
		case 0x04: return ("SEND FPDMA QUEUED DATA SET MANAGEMENT XL");
		}
		return ("SEND FPDMA QUEUED");
	case 0x65:
		switch (cmd->sector count exp & 0xf) {
		case 0x01: return ("RECEIVE FPDMA QUEUED READ LOG DMA EXT");
		case 0x02: return ("RECEIVE FPDMA QUEUED ZAC MANAGEMENT IN");
		}
		return ("RECEIVE FPDMA QUEUED");
	case 0x67:
		switch (cmd->features == 0xec)
			return ("SEP ATTN IDENTIFY");
		switch (cmd->lba low) {
		case 0x00: return ("SEP ATTN READ BUFFER");
		case 0x02: return ("SEP ATTN RECEIVE DIAGNOSTIC RESULTS");
		case 0x80: return ("SEP ATTN WRITE BUFFER");
		case 0x82: return ("SEP ATTN SEND DIAGNOSTIC");
		}
		return ("SEP ATTN");
	case 0x70: return ("SEEK"); // 28
	case 0x77: return ("SET DATE TIME EXT");
	case 0x78:
		switch (cmd->features) {
		case 0x00: return ("GET NATIVE MAX ADDRESS EXT");
		case 0x01: return ("SET ACCESSIBLE MAX ADDRESS EXT");
		case 0x02: return ("FREEZE ACCESSIBLE MAX ADDRESS EXT");
		}
		return ("ACCESSIBLE MAX ADDRESS CONFIGURATION");
	case 0x7C: return ("REMOVE ELEMENT AND TRUNCATE");
	case 0x87: return ("CFA TRANSLATE SECTOR");
	case 0x90: return ("EXECUTE DEVICE DIAGNOSTIC"); // 28
	case 0x91: return ("INITIALIZE DEVICE PARAMETERS"); // 28
	case 0x92:
		switch (cmd->features) {
		case 0x01: return ("DOWNLOAD MICROCODE TEMPORARY"); // 28
		case 0x03: return ("DOWNLOAD MICROCODE SAVE WITH OFFSET"); // 28
		case 0x07: return ("DOWNLOAD MICROCODE SAVE"); // 28
		case 0x0e: return ("DOWNLOAD MICROCODE SAFE FOR FUTURE USE"); // 28
		case 0x0f: return ("DOWNLOAD MICROCODE ACTIVATE"); // 28
		}
		return ("DOWNLOAD MICROCODE"); // 28
	case 0x93: return ("DOWNLOAD MICROCODE DMA"); // 28
	case 0x94: return ("STANDBY IMMEDIATE");
	case 0x95: return ("IDLE IMMEDIATE");
	case 0x96: return ("STANDBY");
	case 0x97: return ("IDLE");
	case 0x98: return ("CHECK POWER MODE");
	case 0x99: return ("SLEEP");
	case 0x9a: return ("ZAC MANAGEMENT OUT");
	case 0xa0: return ("PACKET"); // 28
	case 0xa1: return ("ATAPI IDENTIFY"); // 28
	case 0xa2: return ("SERVICE"); // 28
	case 0xb0:
		switch(cmd->features) {
		case 0xd0: return ("SMART READ ATTR VALUES");
		case 0xd1: return ("SMART READ ATTR THRESHOLDS");
		case 0xd2: return ("SMART ENABLE/DISABLE ATTRIBUTE AUTOSAVE");
		case 0xd3: return ("SMART SAVE ATTR VALUES");
		case 0xd4: return ("SMART EXECUTE OFFLINE IMMEDIATE");
		case 0xd5: return ("SMART READ LOG");
		case 0xd6: return ("SMART WRITE LOG");
		case 0xd7: return ("SMART ATTRIBUTE THRESHOLDS");
		case 0xd8: return ("SMART ENABLE OPERATION");
		case 0xd9: return ("SMART DISABLE OPERATION");
		case 0xda: return ("SMART RETURN STATUS");
		case 0xdb: return ("SMART ENABLE/DISABLE AUTO OFFLINE");
		}
		return ("SMART");
	case 0xb1:
		switch(cmd->features) {
		case 0xc0: return ("DEVICE CONFIGURATION RESTORE");
		case 0xc1: return ("DEVICE CONFIGURATION FREEZE LOCK");
		case 0xc2: return ("DEVICE CONFIGURATION IDENTIFY");
		case 0xc3: return ("DEVICE CONFIGURATION SET");
		}
		return ("DEVICE CONFIGURATION");
	case 0xb2: return ("SET SECTOR CONFIGURATION EXT"); // 28
	case 0xb4:
		switch(cmd->features) {
		case 0x00: return ("SANITIZE STATUS EXT");
		case 0x11: return ("CRYPTO SCRAMBLE EXT");
		case 0x12: return ("BLOCK ERASE EXT");
		case 0x14: return ("OVERWRITE EXT");
		case 0x20: return ("SANITIZE FREEZE LOCK EXT");
		case 0x40: return ("SANITIZE ANTIFREEZE LOCK EXT");
		}
		return ("SANITIZE DEVICE");
	case 0xb6: return ("NV CACHE"); // 28
	case 0xc0: return ("CFA ERASE");
	case 0xc4: return ("READ MUL"); // 28
	case 0xc5: return ("WRITE MUL"); // 28
	case 0xc6: return ("SET MULTI"); // 28
	case 0xc7: return ("READ DMA QUEUED"); // 28
	case 0xc8: return ("READ DMA"); // 28
	case 0xca: return ("WRITE DMA"); // 28
	case 0xcb: return ("WRITE DMA NO RETRY"); // 28
	case 0xcc: return ("WRITE DMA QUEUED"); // 28
	case 0xcd: return ("CFA WRITE MULTIPLE WITHOUT ERASE"); // 28
	case 0xce: return ("WRITE MUL FUA48");
	case 0xd1: return ("CHECK MEDIA CARD TYPE"); // 28
	case 0xda: return ("GET MEDIA STATUS"); // 28
	case 0xdb: return ("ACKNOWLEDGE MEDIA CHANGE");
	case 0xdc: return ("BOOT POST-BOOT");
	case 0xdd: return ("BOOT PRE-BOOT");
	case 0xde: return ("MEDIA LOCK"); // 28
	case 0xdf: return ("MEDIA UNLOCK"); // 28
	case 0xe0: return ("STANDBY IMMEDIATE"); // 28
	case 0xe1: return ("IDLE IMMEDIATE"); // 28
	case 0xe2: return ("STANDBY"); // 28
	case 0xe3: return ("IDLE"); // 28
	case 0xe4: return ("READ BUFFER/PM"); // 28
	case 0xe5: return ("CHECK POWER MODE"); // 28
	case 0xe6: return ("SLEEP"); // 28
	case 0xe7: return ("FLUSHCACHE"); // 28
	case 0xe8: return ("WRITE BUFFER/PM"); // 28
	case 0xe9: return ("READ BUFFER DMA"); // 28
	case 0xea: return ("FLUSHCACHE48"); // 28
	case 0xeb: return ("WRITE BUFFER DMA"); // 28
	case 0xec: return ("ATA IDENTIFY"); // 28
	case 0xed: return ("MEDIA EJECT"); // 28
	case 0xef:
		switch (cmd->features) {
		case 0x01: return ("SETFEATURES ENABLE 8BIT PIO"); // 28
	        case 0x02: return ("SETFEATURES ENABLE WCACHE"); // 28
	        case 0x03: return ("SETFEATURES SET TRANSFER MODE"); // 28
		case 0x05: return ("SETFEATURES ENABLE APM"); // 28
	        case 0x06: return ("SETFEATURES ENABLE PUIS"); // 28
	        case 0x07: return ("SETFEATURES SPIN-UP"); // 28
		case 0x0a: return ("SETFEATURES ENABLE CFA POWER MODE 1"); // 28
		case 0x0b: return ("SETFEATURES ENABLE WRITE READ VERIFY"); // 28
		case 0x0c: return ("SETFEATURES ENABLE DEVICE LIFE CONTROL"); // 28
	        case 0x10: return ("SETFEATURES ENABLE SATA FEATURE"); // 28
		case 0x20: return ("SETFEATURES SET TIME LIMITED R/W WCT"); // 28
		case 0x21: return ("SETFEATURES SET TIME LIMITED R/W EH"); // 28
		case 0x31: return ("SETFEATURES DISABLE MEDIA STATIS NOTIFICATION"); // 28
		case 0x33: return ("SETFEATURES DISABLE RETRY"); // 28
		case 0x41: return ("SETFEATURES ENABLE FREEFALL CONTROL"); // 28
		case 0x42: return ("SETFEATURES ENABLE AAM"); // 28
		case 0x43: return ("SETFEATURES SET MAX HOST INT SECT TIMES"); // 28
		case 0x44: return ("SETFEATURES LENGTH OF VS DATA"); // 28
		case 0x45: return ("SETFEATURES SET RATE BASIS"); // 28
		case 0x4a: return ("SETFEATURES EXTENDED POWER CONDITIONS"); // 28
		case 0x50: return ("SETFEATURES ADVANCED BACKGROUD OPERATION"); // 28
		case 0x54: return ("SETFEATURES SET CACHE SEGS"); // 28
	        case 0x55: return ("SETFEATURES DISABLE RCACHE"); // 28
		case 0x5d: return ("SETFEATURES ENABLE RELIRQ"); // 28
		case 0x5e: return ("SETFEATURES ENABLE SRVIRQ"); // 28
		case 0x62: return ("SETFEATURES LONG PHYS SECT ALIGN ERC"); // 28
		case 0x63: return ("SETFEATURES DSN"); // 28
		case 0x66: return ("SETFEATURES DISABLE DEFAULTS"); // 28
		case 0x69: return ("SETFEATURES LPS ERROR REPORTING CONTROL"); // 28
		case 0x77: return ("SETFEATURES DISABLE ECC"); // 28
		case 0x81: return ("SETFEATURES DISABLE 8BIT PIO"); // 28
	        case 0x82: return ("SETFEATURES DISABLE WCACHE"); // 28
	        case 0x85: return ("SETFEATURES DISABLE APM"); // 28
	        case 0x86: return ("SETFEATURES DISABLE PUIS"); // 28
		case 0x88: return ("SETFEATURES DISABLE ECC"); // 28
		case 0x8a: return ("SETFEATURES DISABLE CFA POWER MODE 1"); // 28
		case 0x8b: return ("SETFEATURES DISABLE WRITE READ VERIFY"); // 28
		case 0x8c: return ("SETFEATURES DISABLE DEVICE LIFE CONTROL"); // 28
	        case 0x90: return ("SETFEATURES DISABLE SATA FEATURE"); // 28
		case 0x95: return ("SETFEATURES ENABLE MEDIA STATUS NOTIFICATION"); // 28
		case 0x99: return ("SETFEATURES ENABLE RETRIES"); // 28
		case 0x9a: return ("SETFEATURES SET MAX AVERAGE CURR"); // 28
	        case 0xaa: return ("SETFEATURES ENABLE RCACHE"); // 28
		case 0xab: return ("SETFEATURES SET MAX PREFETCH"); // 28
		case 0xbb: return ("SETFEATURES 4 BYTE VS DATA"); // 28
		case 0xC1: return ("SETFEATURES DISABLE FREEFALL CONTROL"); // 28
		case 0xC3: return ("SETFEATURES SENSE DATA REPORTING"); // 28
		case 0xC4: return ("SETFEATURES NCQ SENSE DATA RETURN"); // 28
		case 0xCC: return ("SETFEATURES ENABLE DEFAULTS"); // 28
		case 0xdd: return ("SETFEATURES DISABLE RELIRQ"); // 28
		case 0xde: return ("SETFEATURES DISABLE SRVIRQ"); // 28
		case 0xde: return ("SETFEATURES Vendor Specific"); // 28
	        }
	        return "SETFEATURES"; // 28
	case 0xf1: return ("SECURITY SET PASSWORD"); // 28
	case 0xf2: return ("SECURITY UNLOCK"); // 28
	case 0xf3: return ("SECURITY ERASE PREPARE"); // 28
	case 0xf4: return ("SECURITY ERASE UNIT"); // 28
	case 0xf5: return ("SECURITY FREEZE LOCK"); // 28
	case 0xf6: return ("SECURITY DISABLE PASSWORD"); // 28
	case 0xf8: return ("READ NATIVE MAX ADDRESS"); // 28
	case 0xf9:
		switch (cmd->features) {
		case 0x00: return ("SET MAX ADDRESS"); // 28
		case 0x01: return ("SET MAX SET PASSWORD"); // 28
		case 0x02: return ("SET MAX LOCK"); // 28
		case 0x03: return ("SET MAX UNLOCK"); // 28
		case 0x04: return ("SET MAX FREEZE LOCK"); // 28
		}
		return ("SET MAX"); // 28
	}
