--
-- SPDX-License-Identifier: BSD-2-Clause
--
-- Copyright (c) 2023 Warner Losh <imp@FreeBSD.org>
--

local decoder = {}

local function extract(v, array)
	if v.len >= 32 then
		-- handle larger len than 32
		return array[v.word]
	end
	return (array[v.word] >> v.bit) & ((1 << v.len) - 1)
end

local function print_me(ent, array)
	io.write(string.format("\t%s:", ent.name))
	for k, v in pairs(ent) do
		if v.name then
			if v.id or v.protection then goto next end
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
