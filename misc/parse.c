/*  cc -o parse parse.c -lucl -L/usr/local/lib -I/usr/local/include -g */
/* Experimental proof of concept for decoding CDBs */

#include <assert.h>
#include <ctype.h>
#include <err.h>
#include <stdint.h>
#include <ucl.h>

static uint64_t
tou64(const ucl_object_t *obj, const char *name)
{
	const ucl_object_t *v;

	v = ucl_object_lookup(obj, name);
	return (uint64_t)ucl_object_toint(v);
}

static int
toint(const ucl_object_t *obj, const char *name)
{
	const ucl_object_t *v;

	v = ucl_object_lookup(obj, name);
	return (int)ucl_object_toint(v);
}

static bool
tobool(const ucl_object_t *obj, const char *name)
{
	const ucl_object_t *v;

	v = ucl_object_lookup(obj, name);
	return (int)ucl_object_toboolean(v);
}

uint64_t
extract_field(const ucl_object_t *field, const uint8_t *cdb, size_t cdblen)
{
	int length = toint(field, "length");	// in bits
	int byte = toint(field, "byte");	// Byte where it starts
	int bit = toint(field, "bit");		// bit offset in byte
	uint64_t rv = 0;

	// SCSI is big endian
	while (length > 0) {
		uint8_t v = cdb[byte] >> bit;
		int tot = 8 - bit;
		
		if (tot <= length) {
			rv = (rv << 8) | (v & ((1 << tot) - 1));
			length -= tot;
		} else {
			rv = (rv << 8) | (v & ((1 << length) - 1));
			length = 0;
		}
		bit = 0;
		byte++;
	}
	return rv;
}

bool verbose = false;

void
display(const ucl_object_t *name, const ucl_object_t *fields, const uint8_t *cdb, size_t cdblen)
{
	ucl_object_iter_t it = NULL;
	const ucl_object_t *obj, *nm;
	uint64_t val;

	printf("%s:", ucl_object_tostring_forced(name));
	while ((obj = ucl_iterate_object(fields, &it, true)) != NULL) {
		if (tobool(obj, "reserved") || tobool(obj, "id") || tobool(obj, "obsolete"))
			continue;
		val = extract_field(obj, cdb, cdblen);
		// Skip byte-sized or smaller fields that are 0.
		// This eliminates the rarely-used 'decorations' that appear in many
		// scsi commands while preserving the important ones. Though we should
		// likely strive to get that put into the cdb json file.
		if (!verbose && toint(obj, "length") <= 8 && val == 0)
			continue;
		nm = ucl_object_lookup(obj, "name");
		printf(" %s:%lx", ucl_object_tostring_forced(nm), val);
	}
	printf("\n");
}

bool
matches(const ucl_object_t *fields, uint8_t *cdb, size_t cdblen)
{
	ucl_object_iter_t it = NULL;
	const ucl_object_t *obj, *id;
	uint64_t value;
	bool first = true;

	while ((obj = ucl_iterate_object(fields, &it, true)) != NULL) {
		if (!tobool(obj, "id"))
			continue;
		first = false;
		value = tou64(obj, "value");
		if (extract_field(obj, cdb, cdblen) != value)
			return false;
	}
	return true;
}

void
decode(const ucl_object_t *top, uint8_t *cdb, size_t cdblen)
{
	ucl_object_iter_t it = NULL;
	const ucl_object_t *obj, *name, *fields, *identifiers;

	while ((obj = ucl_iterate_object(top, &it, true))) {
		name = ucl_object_lookup(obj, "name");
		fields = ucl_object_lookup(obj, "fields");
		identifiers = ucl_object_lookup(obj, "identifiers");
		if (matches(fields, cdb, sizeof(cdb))) {
			display(name, fields, cdb, sizeof(cdb));
			break;
		}
	}
	if (obj == NULL) {
		printf("UNKNOWN OPCODE %02Xh\n", cdb[0]);
	}
}

uint8_t
hex1(char ch)
{
	assert(isxdigit(ch));

	ch = tolower(ch);
	return (ch <= '9' ? ch - '0' : 10 + ch - 'a');
}

uint8_t
hex2(const char *p)
{
	return ((hex1(p[0]) << 4) | hex1(p[1]));
}

int
main(int argc, char **argv)
{
	struct ucl_parser *parser = ucl_parser_new(UCL_PARSER_KEY_LOWERCASE);
	const char *filename = "cdb-descriptors.js";
	const char *filename2 = "cdb-sat-5.json";
	const char *errmsg;
#if 0
	uint8_t cdb1[] = {0x35, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00}; // synchronize cache
	uint8_t cdb2[] = {0x46, 0x02, 0x00, 0x01, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00}; // get config
	uint8_t cdb3[] = {0x12, 0x00, 0x00, 0x00, 0x60, 0x00};	// inquiry
	uint8_t cdb4[] = {0x00, 0x00, 0x00, 0x00, 0x00, 0x00};	// Test Unit Ready
	uint8_t cdb5[] = {0x4d, 0x00, 0x07, 0x00, 0x00, 0x00, 0x00, 0x03, 0xc4, 0x00}; // Log Sense
	uint8_t cdb6[] = {0x9e, 0x15, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, // background control
			  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04};
	uint8_t cdb7[] = {0x9e, 0x12, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, // get lba status
			  0x06, 0x07, 0x00, 0x00, 0x80, 0x00, 0x00, 0x04};
	uint8_t cdb8[] = {0x08, 0x1f, 0xff, 0x00, 0x80, 0x04};	// READ6
	uint8_t cdb9[] = {0x28, 0x00, 0x00, 0x23, 0x45, 0x66, 0x00, 0x02, 0x80, 0x04}; // READ10
	uint8_t cdb10[]= {0xa8, 0x00, 0x00, 0x01, 0x02, 0x03, 0x00, 0x01, // READ12
			  0x02, 0x03, 0x00, 0x00};
	uint8_t cdb11[]= {0x88, 0x00, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, // READ16
			  0x06, 0x07, 0x00, 0x01, 0x02, 0x03, 0x00, 0x04};
	uint8_t cdb12[]= {0x85, 0x08, 0x0e, 0x00, 0xd5, 0x00, 0x00, 0x00,
			  0xa0, 0x00, 0x4f, 0x00, 0xc2, 0x00, 0xb0, 0x00};
	uint8_t cdb13[]= {0xa1, 0x08, 0x0e, 0xd5, 0x00, 0xa0, 0x4f, 0xc2,
			  0x00, 0xb0, 0x00, 0x00};
	uint8_t cdb14[]= {0x1a, 0x00, 0x01, 0x00, 0xc0, 0x00};
	uint8_t cdb15[]= {0x9e, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00};
#endif

	if (parser == NULL)
		err(1, "Could not allocate parser");

	if (!ucl_parser_add_file(parser, filename)) {
		errmsg = ucl_parser_get_error(parser);
		if (errmsg != NULL)
			errx(1, "Could not parse '%s': %s", filename, errmsg);
		else
			errx(1, "WTF? error but no error message?");
	}
	/* XXX this doesn't seem to work to append -- known limitation of parse.c. What to do? */
	if (!ucl_parser_add_file(parser, filename2)) {
		errmsg = ucl_parser_get_error(parser);
		if (errmsg != NULL)
			errx(1, "Could not parse '%s': %s", filename, errmsg);
		else
			errx(1, "WTF? error but no error message?");
	}

	const ucl_object_t *top = ucl_parser_get_object(parser);
#if 0
	decode(top, cdb1, sizeof(cdb1));
//	decode(top, cdb2, sizeof(cdb2)); // XXX doesn't work
	decode(top, cdb3, sizeof(cdb3));
	decode(top, cdb4, sizeof(cdb4));
	decode(top, cdb5, sizeof(cdb5));
	decode(top, cdb6, sizeof(cdb6));
	decode(top, cdb7, sizeof(cdb7));
//	decode(top, cdb8, sizeof(cdb8)); // XXX doesn't work
	decode(top, cdb9, sizeof(cdb9));
	decode(top, cdb10, sizeof(cdb10));
	decode(top, cdb11, sizeof(cdb11));
	decode(top, cdb12, sizeof(cdb12));
	decode(top, cdb13, sizeof(cdb13));
	decode(top, cdb14, sizeof(cdb14));
	decode(top, cdb15, sizeof(cdb15));
#endif
	{
		char *line = NULL;
		size_t linecap = 0;
		ssize_t linelen;
		char *cp;		/* ascii version of cdb */
		uint8_t cdb[256];	/* Type 0x7e violate this, but dtrace script outputs at most 16 */
		int cdblen;
		char *ep;		/* Don't parse past here */

		while ((linelen = getline(&line, &linecap, stdin)) > 0) {
			/* echo the input */
			fwrite(line, linelen, 1, stdout);
			cp = strstr(line, "CDB: ");
			if (cp == NULL)
				continue;
			cp += 4;			/* skip cdb: */
			while (isspace(*cp))		/* ... and whitespace */
				cp++;
			ep = cp + strlen(cp);
			cdblen = 0;
			while (cp + 2 < ep && isxdigit(cp[0]) && isxdigit(cp[1])) {
				cdb[cdblen++] = hex2(cp);
				cp += 2;
				while (isspace(*cp))
					cp++;
			}
			if (cdblen > 0) {
				printf("\t");
				decode(top, cdb, cdblen);
			}
		}
	}
}
