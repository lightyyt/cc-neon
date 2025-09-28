local f = fs.open("/neon/boot/"..neon.default, "r")
local dat=f.readAll()
f.close()
--Values = 0
bootfile = {label=v, boot="/", index=-1, file="/neon/boot/"..neon.default}
for i,line in pairs(ccstr.split(dat, "\n")) do
    local data = ccstr.split(line, "=")
    if #data==2 then
        if data[1] == "LABEL" then
            bootfile.label = data[2]
        elseif data[1] == "BOOT" then
            bootfile.boot = data[2]
        elseif data[1] == "INDEX" then
            bootfile.index = data[2]
        end
    end
end

term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.clear()
term.setCursorPos(1,1)
if bootfile.file == "/neon/boot/terminal.eon" then
    require("/neon/shell_aliases")
    print("NEON Shell Loaded!")
    shell.run("shell")
else
    require(bootfile.boot)
end

os.shutdown()