local function log(filename)
	local file, err = io.open(filename, "w")

	if not file then
		print(("Cannot open file \"%s\" (%s)"):format(file, err))
	end

	local obj = {
		file = file
	}

	function obj:valid()
		return self.file ~= nil
	end

	function obj:write(text)
		if self:valid() then
			self.file:write(("[%s] %s\n"):format(os.date("%X"), text))
		end
	end

	function obj:rawwrite(text)
		if self:valid() then
			self.file:write(text)
		end
	end

	obj:write(("Log started. Date: %s"):format(os.date("%b %d %Y")))

	return obj
end

return {
	new = log
}
