edit = {setup_menu = 0,
    neon = require("/neon.neon"),
    keys = {
        left =263,
        right=262,
        up   =265,
        down =264,
        f8   =297,
        f7   =296,
        enter=257,
        space=32
    },
    exit = false,
    ccstr = require("cc.strings"),
    bmselected = 1,
    bmselect = false,
    bmelement = nil
}

function edit.input()
    while true do
        local event, key, is_held = os.pullEvent("key")
        -- Left == 263
        -- Right == 262
        -- Up == 265
        -- Down == 264
        -- F8 == 297
        -- F7 == 296
        -- Enter == 257
        -- Space == 32
        if key == edit.keys.space or key == edit.keys.f8 then
            edit.exit = true
            break
        elseif key == edit.keys.left then
            edit.setup_menu = edit.setup_menu-1
            if edit.setup_menu <= -1 then
                edit.setup_menu = 2
            end
            break
        elseif key == edit.keys.right then
            edit.setup_menu = edit.setup_menu+1
            if edit.setup_menu > 2 then
                edit.setup_menu = 0
            end
            break
        end
    end
end

function edit.write_info(label, text)
    term.setTextColor(colors.white)
    term.write(label.." ")
    term.setTextColor(colors.black)
    term.write(text)
end

function edit._setup_bars(colForeInfo, colBackInfo, colForeSetup, colBackSetup, colForeExit, colBackExit, back)
    -- Draw Background
    local w, h = term.getSize()
    for i=1, w, 1 do
        term.setCursorPos(i,2)
        term.setBackgroundColor(back)
        term.write(" ")

        term.setCursorPos(i,1)
        term.setBackgroundColor(colors.cyan)
        term.write(" ")
        term.setCursorPos(i,h-1)
        term.write(" ")
        term.setCursorPos(i,h)
        term.write(" ")
    end
    -- Write title centered
    term.setTextColor(colors.white)
    local text = "N-EON Setup Utility"
    term.setCursorPos(math.floor(w/2)-math.floor(#text/2),1)
    term.write(text)

    term.setCursorPos(3,h-1)
    edit.write_info("\24\25", "Select Item  ")
    edit.write_info("\27\26", "Select Menu  ")
    edit.write_info("Enter", "Selection")

    term.setCursorPos(3,h)
    edit.write_info("F8", "Save + Exit  ")
    edit.write_info("F9", "Restore Defaults  ")
    edit.write_info("Space", "Exit")

    term.setCursorPos(3,2)
    term.setTextColor(colForeInfo)
    term.setBackgroundColor(colBackInfo)
    term.write("Info")
    
    term.setCursorPos(8,2)
    term.setTextColor(colForeSetup)
    term.setBackgroundColor(colBackSetup)
    term.write("Setup")

    term.setCursorPos(14,2)
    term.setTextColor(colForeExit)
    term.setBackgroundColor(colBackExit)
    term.write("Exit")
end


function edit.setup_draw_titlebar()
    
    if edit.setup_menu == 0 then
        edit._setup_bars(colors.blue, colors.lightGray,
                            colors.lightGray, colors.blue,
                            colors.lightGray, colors.blue, colors.blue)
    elseif edit.setup_menu == 1 then
        edit._setup_bars(colors.lightGray, colors.blue,
                            colors.blue, colors.lightGray,
                            colors.lightGray, colors.blue, colors.blue)
    elseif edit.setup_menu == 2 then
        edit._setup_bars(colors.lightGray, colors.blue,
                            colors.lightGray, colors.blue,
                            colors.blue, colors.lightGray, colors.blue)
    end
end

function edit.write_at(x,y,text)
    term.setCursorPos(x+2,y+3)
    term.write(text)
end

function edit.setup_draw_info()
    local w, h = term.getSize()
    local pclabel = os.getComputerLabel()
    if pclabel == nil then
        pclabel="computer"
        os.setComputerLabel("computer")
    end
    local pcid = os.getComputerID()
    local date = os.date("%a, %d/%b/%Y")
    local time = os.date("%H:%M:%S")
    local version = os.version()

    term.setTextColor(colors.blue)
    term.setBackgroundColor(colors.lightGray)

    edit.write_at(1,1, "System Date      ["..date.."]")
    edit.write_at(1,2, "System Time      ["..time.."]")

    edit.write_at(1,4, "NEON Version     "..edit.neon.version)
    edit.write_at(1,6, "Computer         "..pclabel.." @ "..pcid)
    edit.write_at(1,7, "Kernel Version   "..version:gsub("OS", "Knl")) -- Make it look more "official", as it's still CraftOS
end

function edit.setup_draw_setup()
    term.setBackgroundColor(colors.lightGray)
    term.setTextColor(colors.black)
    edit.write_at(1,1, "Boot Entries")
    local w, h = term.getSize()
    term.setTextColor(colors.gray)
    for i=1, w, 1 do
        term.setCursorPos(i,5)
        term.write("\168")
    end
    
    term.setTextColor(colors.blue)

    -- Get all boot entries
    bootfiles = {}
    for i, v in pairs(fs.list("/neon/boot")) do
        -- Read file
        local f = fs.open("/neon/boot/"..v, "r")
        local dat=f.readAll()
        f.close()
        --Values = 0
        bootfile = {label=v, boot="/", index=-1, file="/neon/boot"..v}
        for i,line in pairs(edit.ccstr.split(dat, "\n")) do
            local data = edit.ccstr.split(line, "=")
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
        table.insert(bootfiles, bootfile)
    end

    for i, v in pairs(bootfiles) do
        edit.write_at(1, 3+v.index, v.label)
    end
end

function edit.setup_draw_exit()
    edit.write_at(1, 1, "Press Space to exit without saving.")
    edit.write_at(1, 2, "Press F8 to save and exit.")
    edit.write_at(1, 3, "Press F9 to restore defaults (W.I.P.)")
end


function edit.setup_render()
    -- Draw current menu
    term.clear()
    edit.setup_draw_titlebar()
    if edit.setup_menu == 0 then
        edit.setup_draw_info()
    elseif edit.setup_menu == 1 then
        edit.setup_draw_setup()
    elseif edit.setup_menu == 2 then
        edit.setup_draw_exit()
    end
    sleep(0.5)
end

function edit.setup()
    term.setBackgroundColor(colors.lightGray)
    term.clear()
    while true do
        if edit.exit then
            break
        end
        parallel.waitForAny(edit.setup_render, edit.input)
    end
    os.reboot()
end





function edit.bootmenu_render()
    term.setBackgroundColor(colors.black)
    term.clear()
    bootfiles = {}
    for i, v in pairs(fs.list("/neon/boot")) do
        -- Read file
        local f = fs.open("/neon/boot/"..v, "r")
        local dat=f.readAll()
        f.close()
        --Values = 0
        bootfile = {label=v, boot="/", index=-1, file="/neon/boot/"..v}
        for i,line in pairs(edit.ccstr.split(dat, "\n")) do
            local data = edit.ccstr.split(line, "=")
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
        table.insert(bootfiles, bootfile)
    end

    local w, h = term.getSize()

    if edit.bmselected <=0 then
        edit.bmselected = #bootfiles
    elseif edit.bmselected > #bootfiles then
        edit.bmselected = 1
    end

    for i, v in pairs(bootfiles) do
        term.setCursorPos(math.floor(w/2)-math.floor((#v.label+2)/2),math.floor(h/2)-math.floor(#bootfiles/2)+i)
        if i == edit.bmselected then
            term.setBackgroundColor(colors.white)
            term.setTextColor(colors.black)
            if edit.bmselect then
                edit.bmelement = v
            end
        else
            term.setBackgroundColor(colors.black)
            term.setTextColor(colors.white)
        end
        term.write(" "..v.label.." ")
    end
    sleep(0.5)
end

function edit.bootmenu_input()
    while true do
        local event, key, is_held = os.pullEvent("key")
        -- Left == 263
        -- Right == 262
        -- Up == 265
        -- Down == 264
        -- F8 == 297
        -- F7 == 296
        -- Enter == 257
        -- Space == 32
        if key == edit.keys.up then
            edit.bmselected = edit.bmselected-1
            break
        elseif key == edit.keys.down then
            edit.bmselected = edit.bmselected+1
            break
        elseif key == edit.keys.enter then
            edit.bmselect = true
            break
        end
    end
end

function edit.bootmenu()
    while true do
        parallel.waitForAny(edit.bootmenu_render, edit.bootmenu_input)

        if edit.bmelement then
            term.setBackgroundColor(colors.black)
            term.setTextColor(colors.white)
            term.clear()
            term.setCursorPos(1,1)
            if edit.bmelement.file == "/neon/boot/terminal.eon" then
                require("/neon/shell_aliases")
                print("NEON Shell Loaded!")
                shell.run("shell")
            else
                require(edit.bmelement.boot)
            end

            -- No matter what, system shuts down after thing has finished unless thing did reboot or something
            os.shutdown()
        end
    end
end

return edit