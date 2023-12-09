--
-- SPDX-License-Identifier: BSD-2-Clause
--
-- Copyright (c) 2023 Warner Losh <imp@FreeBSD.org>
--

local filter = {}

local df = require("dtrace-filter")
local af = require("ascii-filter")

filter["scsi"] = {
	dtrace = df["scsi"],
	ascii = af["scsi"]
}

filter["ata"] = {
	dtrace = df["ata"],
	ascii = af["ata"]
}

filter["nvme"] = {
	dtrace = df["nvme"],
	ascii = af["nvme"]
}

return filter