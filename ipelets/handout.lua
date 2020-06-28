label = "Export PDF Handout"

about = [[
Export PDF Handout
]]

function run(model)

    dir = dir or "."

    local file = ipeui.fileDialog(nil, "open", "Open PDF/IPE File",
        {"PDF, IPE (*.pdf *.ipe)", "*.pdf;*.ipe"},
        dir, nil)
    if not file then return end
    dir = string.gsub(file, "(.*/)(.*)", "%1")

    local idx = string.find(file,'%.')
    local name = string.sub(file,0,idx-1)
    local handout = name .. "_handout.pdf"

    local ret = 0
    if config.platform == "apple" then
        ret = _G.os.execute("/Applications/Ipe.app/Contents/MacOS/ipetoipe -pdf -markedview " .. file .. " " .. handout)
    else
        ret = _G.os.execute("ipetoipe -pdf -markedview " .. file .. " " .. handout)
    end
    if not ret then
        model:warning ("fail to convert to PDF handout")
    return
    end

end
