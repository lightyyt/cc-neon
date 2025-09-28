local argv = {...}
local ccstr = require("cc.strings")

if #argv > 0 then
    print("Launching: \""..argv[1].."\"...")
    local fn = "/neon/boot/"..argv[1]..".eon"
    if argv[1] == "-disk" then
        fn = "/disk/boot.eon"
    end
    if #fs.find(fn) == 0 then
        print("EON ERROR! .eon file not found! (File must be in /neon/boot/ and you must run it without extension, e.g. \"eon terminal\")")
    else
        local f = fs.open(fn, "r")
        local dat=f.readAll()
        f.close()
        --Values = 0
        bootfile = {label=v, boot="/", index=-1, file=fn}
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
    end
else
    print("EON ERROR! No .eon file provided! (File must be in /neon/boot or /disk/boot.eon)")
    print("Example Usage: \"eon terminal\" or \"eon -disk\"")
end