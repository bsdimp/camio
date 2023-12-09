/*  cc -o cvt cvt.c -lucl -L/usr/local/lib -I/usr/local/include -g */

#include <assert.h>
#include <ctype.h>
#include <err.h>
#include <stdint.h>
#include <ucl.h>

void
display(const ucl_object_t *name, const ucl_object_t *fields)
{
	ucl_object_iter_t it = NULL, it2;
	const ucl_object_t *obj, *obj2;

	printf("    {\n\tname=\"%s\",\n", ucl_object_tostring_forced(name));
	while ((obj = ucl_iterate_object(fields, &it, true)) != NULL) {
		bool res;
		int len;
		const char *nm;

		len = 0;
		res = false;
		nm = NULL;
		printf("\t{");
		it2 = NULL;
		while ((obj2 = ucl_iterate_object(obj, &it2, true)) != NULL) {
			const char *s, *k;
			k = ucl_object_key(obj2);
			if (strcmp(k, "length") == 0) {
				k = "len";
				len = (int)ucl_object_toint(obj2);
			}
			if (strcmp(k, "reserved") == 0 || strcmp(k, "obsolete") == 0)
				res = true;
			printf(" %s=", k);
			switch (ucl_object_type(obj2)) {
			case UCL_STRING:
				s = ucl_object_tostring(obj2);
				if (strcmp(k, "name") == 0)
					nm = s;
				printf("\"%s\",", s);
				break;
			case UCL_INT:
				if (strcmp(k, "value") == 0)
					printf("0x%x,", (int)ucl_object_toint(obj2));
				else
					printf("%d,", (int)ucl_object_toint(obj2));
				break;
			case UCL_BOOLEAN:
				printf("%s,", ucl_object_toboolean(obj2) ? "true" : "false");
				break;
			default:
				break;
			}
		}
		if (len < 8 && !res && strcmp(nm, "SERVICE ACTION") != 0)
			printf(" nonzero=true,");
		printf(" },\n");
	}
	printf("    },\n");
}

void
xlate(const ucl_object_t *top)
{
	ucl_object_iter_t it = NULL;
	const ucl_object_t *obj, *name, *fields, *identifiers;

	while ((obj = ucl_iterate_object(top, &it, true))) {
		name = ucl_object_lookup(obj, "name");
		fields = ucl_object_lookup(obj, "fields");
		identifiers = ucl_object_lookup(obj, "identifiers");
		display(name, fields);
	}
}

int
main(int argc, char **argv)
{
	struct ucl_parser *parser = ucl_parser_new(UCL_PARSER_KEY_LOWERCASE);
	//const char *filename = "cdb-descriptors.js";
	const char *filename = "cdb-sat-5.json";
	const char *errmsg;

	if (parser == NULL)
		err(1, "Could not allocate parser");

	if (!ucl_parser_add_file(parser, filename)) {
		errmsg = ucl_parser_get_error(parser);
		if (errmsg != NULL)
			errx(1, "Could not parse '%s': %s", filename, errmsg);
		else
			errx(1, "WTF? error but no error message?");
	}

	const ucl_object_t *top = ucl_parser_get_object(parser);
	xlate(top);
}
