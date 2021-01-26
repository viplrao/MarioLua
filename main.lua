-- Vipul Rao
-- 1/25/20
-- Mario Game
-- usage: love . or cmd-L-L in VScode

-- Sizing help
LEFT_EDGE_OF_SCREEN = 0
RIGHT_EDGE_OF_SCREEN = 1220
TOP_OF_SCREEN = 0
WALK_PATH_HEIGHT = 500
 -- How much should toad move with each keypress?
STEP_INCREMENT = 15

-- Spawn toad at the leftmost part of the walk
-- Not actually drawn untill later but I think it looks better up here
toad_x_pos = LEFT_EDGE_OF_SCREEN
toad_y_pos = WALK_PATH_HEIGHT

-- Called once, create sprites here
function love.load()
    background = love.graphics.newImage("Assets/mario_no_terrain Cropped.jpg")
    toad = love.graphics.newImage("Assets/tiny toad.png")
end

-- Add sprites to the stage here
function love.draw()
    -- Create background
    love.graphics.setBackgroundColor(111/255,121/255,255/255)
    love.graphics.draw(background,0,0)
    -- Create Obstacles (very much TODO)
    love.graphics.rectangle("fill", 500,530,100,100)
    -- Create Toad
    love.graphics.draw(toad, toad_x_pos, toad_y_pos)
end

-- Called every $dt seconds, do game logic here
function love.update(dt)
    local keys = {"right", "left", "up", "down"}
    for i=1,4 do
        if love.keyboard.isDown(keys[i]) then
            step(keys[i], STEP_INCREMENT)
        end
    end
end

function step(direction, amount)
     -- No wrap_around for these ones, it just won't let you go farther than the edge - maybe add a bounce??
    if direction == "up" and (toad_y_pos - amount) >= TOP_OF_SCREEN then
        toad_y_pos = toad_y_pos - amount
    end

    if direction == "down" and (toad_y_pos + amount) <= WALK_PATH_HEIGHT then
        toad_y_pos = toad_y_pos + amount
    end

    if direction == "left"  and (toad_x_pos - amount) >= LEFT_EDGE_OF_SCREEN  then
        toad_x_pos = toad_x_pos - amount
    end

    if direction == "right" then
         -- If toad is going to go off screen, slide it to the left edge
        if toad_x_pos + amount >= RIGHT_EDGE_OF_SCREEN then
            wrap_around()
        end
        -- Once toad wraps around (or doesn't) it can keep moving like normal
        toad_x_pos = toad_x_pos + amount
    end
end

-- Probably will make new obstacles inside this function, could be a seperate func.?
function wrap_around()
    toad_x_pos = LEFT_EDGE_OF_SCREEN
end