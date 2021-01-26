function love.conf(t)
    if DEBUG then
        t.window.width = 1440
        t.window.height = 900
        t.window.title = "Mario- DEBUG ON"
    else 
        t.window.width = 1334
        t.window.height = 750
        t.window.title = "Mario"
    end

end