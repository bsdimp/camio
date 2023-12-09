--
-- SPDX-License-Identifier: BSD-2-Clause
--
-- Copyright (c) 2023 Warner Losh <imp@FreeBSD.org>
--

local filter = {}

local df = require("dtrace-filter")
local af = require("ascii-filter")
local nvme = require("nvme")
local scsi = require("scsi")

filter["scsi"] = {
	dtrace = scsi.dtrace_program,
	ascii = scsi.ascii_filter
}

filter["ata"] = {
	dtrace = df["ata"],
	ascii = af["ata"]
}

filter["nvme"] = {
	dtrace = nvme.dtrace_program,
	ascii = nvme.ascii_filter
}

return filter
