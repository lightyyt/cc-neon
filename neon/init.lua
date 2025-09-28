local ccstr = require("cc.strings")
local edit = require("/neon.neonedit")
local neon = require("/neon.neon")

-- Setup Screen Info
local screen = {width=0,height=0,h_width=0,h_height=0}
screen.width, screen.height = term.getSize()
screen.h_width = math.floor(screen.width/2)
screen.h_height = math.floor(screen.height/2)

-- Setup Image Info
local image = {width=0,height=0,src="",h_width=0,h_height=0,list={}}
function setup_image(src)
    image.src = src
    local file = fs.open(src, "r")
    local data = file.readAll()
    file.close()
    image.list = ccstr.split(data,"\n")
    image.width = #image.list[1] -- First element should always be longest, and all should always have same length
    image.height = #image.list -- If theres a newline somewhere, that shouldn't affect it much

    image.h_width = math.floor(image.width/2)
    image.h_height = math.floor(image.height/2)
end
function draw_image()
    local x = screen.h_width - image.h_width
    local y = 2
    for i, v in pairs(image.list) do
        term.setCursorPos(x, y+i)
        term.blit(v,v,v) -- Make colors full
    end
end
term.clear()
setup_image("/neon/boot.pix")
draw_image()


local open_menu = ""

-- Loops for boot progress & key input
function loop_keyInput()
    while true do
        local event, key, is_held = os.pullEvent("key")
        if key == 68 then -- D
            open_menu = "boot"
            break
        end
        if key == 81 then -- Q
            open_menu = "setup"
            break
        end
    end
end

local progress = {
    width=10,
    value=0,
    max=10
}

function centered_text(text, y)
    term.setCursorPos(screen.h_width - math.floor(#text/2), y)
    term.write(text)
end

function loop_progress()
    -- Draw info text
    centered_text("Press D to open boot menu", screen.height - 3)
    centered_text("Press Q to launch setup", screen.height - 4)

    local prog_h_width = math.floor(progress.width/2)
    local x = screen.h_width - prog_h_width
    term.setCursorPos(x, screen.height-2)
    term.write("[")
    for i=1,progress.width, 1 do
        term.setCursorPos(x+i, screen.height-2)
        if i <= progress.value then
            term.blit(" ", "0", "0")
        else
            term.blit(" ", "f", "f")
        end
    end
    term.write("]")
    sleep(0.2)
    if progress.value == progress.max then
        -- Startup
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
    end
    progress.value = progress.value+1
end

while true do
    if open_menu == "boot" then
        edit.bootmenu()
    elseif open_menu == "setup" then
        edit.setup()
    else
        parallel.waitForAny(loop_keyInput, loop_progress)
    end
end