#!/usr/bin/awk -f

function f(n, is28)
{
	printf("    {\n\tname=\"%s\",%s\n", n, is28 ? " is28=true," : "");
	for (i = 1; i <= depth; i++) {
		printf("\t{ name=\"%s\", len=8, byte=%d, bit=0, id=true, value=0x%02x, },\n",
			fields[i], offset[i], stack[i]);
	}
	if (depth == 1) {
		if (is28) {
			printf("\t{ name=\"FEATURE\", len=8, byte=2, bit=0 },\n");
		} else {
			printf("\t{ name=\"FEATURE\", len=16, byte=1, bit=0 },\n");
		}
	}
	if (is28) {
		printf("\t{ name=\"LBA\", len=24, byte=6, bit=0 },\n");
		printf("\t{ name=\"SECTOR COUNT\", len=8, byte=10, bit=0 },\n");
	} else {
		printf("\t{ name=\"LBA\", len=48, byte=3, bit=0 },\n");
		printf("\t{ name=\"SECTOR COUNT\", len=16, byte=9, bit=0 },\n");
	}
	printf("\t{ name=\"DEVICE\", len=8, byte=11, bit=0, level=1 },\n");
	printf("\t{ name=\"CONTROL\", len=8, byte=12, bit=0, level=1 },\n");
	printf("    },\n");
}

BEGIN {
	depth=0
	split("COMMAND FEATURES FEATURES_EXT", fields, " ")
	split("0 2 1", offset, " ")
}

$1 == "}" {
}

$1 == "case" {
	v = $2 + 0;
	stack[depth] = v;
	if (NF > 2) {
		is28 = $NF == 28;
		line=$0
		sub(/^.*return \(?"/, "", line);
		sub(/".*$/, "", line);
		f(line, is28);
	}
}

$1 == "switch" {
	depth++;
}

$1 == "return" {
	depth--;
	is28 = $NF == 28;
	line=$0
	sub(/^.*return \(?"/, "", line);
	sub(/".*$/, "", line);
	v = stack[depth];
	f(line, is28);
}
