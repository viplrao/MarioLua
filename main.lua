-- Vipul Rao
-- 1/25/20
-- Mario Game
-- Usage: `love .` or cmd-L-L in VScode
-- Once love opens, use the arrow keys to move toad!

-- Sizing constants
LEFT_EDGE_OF_SCREEN = 0
RIGHT_EDGE_OF_SCREEN = 1220
TOP_OF_SCREEN = 0
WALK_PATH_HEIGHT = 500
-- How much should toad move with each keypress?
STEP_INCREMENT = 15

-- ALL BELOW BLOCKS MOVED INTO OBJECTS OR PAUSED

-- Replaced with objects.toad.{x,y}_pos
-- Old:
-- Spawn toad at the leftmost part of the walk-- Not actually drawn untill later but I think it looks better up here
--toad_x_pos = LEFT_EDGE_OF_SCREEN
--toad_y_pos = WALK_PATH_HEIGHT

-- Same thing for obstacles, changes from make_new_block(), might need more than one??
--block_x_pos = rand_on_axis("x")
--block_y_pos = rand_on_axis("y")


-- Called once, create sprites here
function love.load()
    
    love.physics.setMeter(20)
    world = love.physics.newWorld(0, 9.81*64, true)
    -- Create an empty generic objects table
    objects = {}
    -- Add the background to it
    objects.background = {
        image = love.graphics.newImage("Assets/mario_no_terrain Cropped.jpg")
    }
    -- This one's a little clunkier so you can declare props line by ine
    objects.toad = {
        x_pos = LEFT_EDGE_OF_SCREEN,
        y_pos = WALK_PATH_HEIGHT,
        image = love.graphics.newImage("Assets/tiny toad.png")

    }
    --objects.toad.x_pos = LEFT_EDGE_OF_SCREEN
    --objects.toad.y_pos = WALK_PATH_HEIGHT
    objects.toad.body = love.physics.newBody(world, objects.toad.x_pos, objects.toad.y_pos, "dynamic")

    -- The following lines have been c+v'd. Do not expect them to work yet.
    objects.toad.shape = love.physics.newCircleShape( 20)--the ball's shape has a radius of 20
    objects.toad.fixture = love.physics.newFixture(objects.toad.body, objects.toad.shape, 1) -- Attach fixture to body and give it a density of 1.
    objects.toad.fixture:setRestitution(0.9) --let the ball bounce

end

-- Add sprites to the stage here
function love.draw()
    -- Create background
    love.graphics.setBackgroundColor(111/255,121/255,255/255)
    love.graphics.draw(objects.background.image,0,0)
    -- Create Obstacles (very much TODO)
        for i=1, love.math.random(1,3) do
            make_new_block(i, false)
        end
    -- Create Toad
    love.graphics.draw(objects.toad.image, objects.toad.x_pos, objects.toad.y_pos)
end

-- Called every $dt seconds, do game logic here
function love.update(dt)
    -- Checks if right, left, up, down keys are pressed, and calls appropriate step (probably should have been named move) function
    local keys = {"right", "left", "up", "down"}
    for i=1,4 do
        if love.keyboard.isDown(keys[i]) then
            step(keys[i], STEP_INCREMENT)
        end
    end
end

-- Below this line are functions I have made --

-- Moves $amount pixels towards $"direction"
function step(direction, amount)
     -- No wrap_around for these ones, it just won't let you go farther than the edge - maybe add a bounce??
    if direction == "up" and (objects.toad.y_pos - amount) >= TOP_OF_SCREEN then
        objects.toad.y_pos = objects.toad.y_pos - amount
    end

    if direction == "down" and (objects.toad.y_pos + amount) <= WALK_PATH_HEIGHT then
        objects.toad.y_pos = objects.toad.y_pos + amount
    end

    if direction == "left"  and (objects.toad.x_pos - amount) >= LEFT_EDGE_OF_SCREEN  then
        objects.toad.x_pos = objects.toad.x_pos - amount
    end

    if direction == "right" then
         -- If toad is going to go off screen, slide it to the left edge
        if objects.toad.x_pos + amount >= RIGHT_EDGE_OF_SCREEN then
            wrap_around()
        end
        -- Once toad wraps around (or doesn't) it can keep moving like normal
        objects.toad.x_pos = objects.toad.x_pos + amount
    end
end

-- Probably will make new obstacles inside this function, could be a seperate func.?
function wrap_around()
    objects.toad.x_pos = LEFT_EDGE_OF_SCREEN
end

-- putting this aside to try out physics
function rand_on_axis(axis)
    if axis == "x" then
        return love.math.random(LEFT_EDGE_OF_SCREEN, RIGHT_EDGE_OF_SCREEN)
    end
    if axis == "y" then
      return love.math.random(TOP_OF_SCREEN, WALK_PATH_HEIGHT)
    end    
end

--  this too
function make_new_block(update)
    if update == false then
      --  love.graphics.rectangle("fill", block_x_pos,block_y_pos,100,100)
    else do 
       -- love.graphics.rectangle("fill", rand_on_axis("x"), rand_on_axis("y"), 100, 100)
    end
end
end