label = "Export PDF Handout"

about = [[Export PDF Handout]]

function run(model)

	dir=dir or "."

	local file=ipeui.fileDialog(nil, "open", "Open PDF/IPE File",
		{"PDF, IPE (*.pdf *.ipe)", "*.pdf;*.ipe"},
		dir, nil)
	if not file then return end
	dir=string.gsub(file, "(.*/)(.*)", "%1")

	local handout=file .. "_handout.pdf"

	local format= ipe.fileFormat(file)
	if format~="xml" then
		-- convert file to IPE
		local ret=0
		ret=_G.os.execute("ipetoipe -pdf -markedview " .. file .. " " .. handout)
		if not ret then
			model:warning ("fail to convert to intermediate IPE")
			return
		end
		file=handout
	end

end
