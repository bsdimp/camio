--
-- SPDX-License-Identifier: BSD-2-Clause
--
-- Copyright (c) 2023 Warner Losh <imp@FreeBSD.org>
--

local decoder = {}

local function extract(v, array)
	local wlen, off, le

	if v.word ~= nil then
		wlen = 32
		off = v.word
		le = true	-- hack: only nvme is little endian
	else
		wlen = 8
		off = v.byte
		le = false
	end

	local rv = 0
	local len = v.len
	local bit = v.bit
	local shift = 0

	while len > 0 do
		local val = array[off] >> bit, v2
		local tot = wlen - bit

		if tot <= len then
			v2 = val & ((1 << tot) - 1)
			len = len - tot
		else
			v2 = val & ((1 << len) - 1)
			len = 0
		end
		if le then
			rv = (v2 << shift) | rv
			shift = shift + wlen
		else
			rv = (rv << wlen) | v2
		end
		bit = 0
		off = off + 1
	end
	return rv
end

local function print_me(ent, array)
	local verbosity = 0
	io.write(string.format("\t%s:", ent.name))
	for k, v in pairs(ent) do
		if v.name then
			--
			-- Skip uninteresting fields. The fields we use to ID
			-- the block aren't interesting. Nor are the ones that
			-- are obsolete or reserved for future use. The
			-- protection ones are extra fields to support
			-- end-to-end protection of data on otherwise normal
			-- commands so aren't usually worth displaying.
			--
			-- In the future, there should likely be a way to
			-- control these. As well as supporting multiple levels
			-- of 'interesting' fields.
			--
			-- Also, there's many times we might want to look at
			-- fields that are noise, so allow verbosity level to
			-- vary (though we hard code it to 0 above).
			--
			if v.id or v.protection or v.obsolete or v.reserved then goto next end
			if v.level and v.level > verbosity then goto next end
			val = extract(v, array)
			if v.nonzero and val == 0 then goto next end
			io.write(string.format(" %s: %d", v.name, val))
		end
	::next::
	end
	io.write("\n")
end

local function matches(ent, array)
	for k, v in pairs(ent) do
		if v.id then
			if extract(v, array) ~= v.value then
				return false
			end
		end
	end
	return true
end


local function find_cmd(tbl, array)
	for _, v in pairs(tbl) do
		if matches(v, array) then
			print_me(v, array)
			return
		end
	end	
	print("Nothing matched")
end

function decoder.decode(tbl, array)
	find_cmd(tbl, array)
end

return decoder
