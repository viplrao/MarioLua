-- Vipul Rao
-- 1/25/20
-- Mario Game
-- Usage: `love .` or cmd-L-L in VScode
-- Once love opens, use the arrow keys to move toad!

-- Most Recent Commit Name: 

-- Sizing constants
LEFT_EDGE_OF_SCREEN = 0
RIGHT_EDGE_OF_SCREEN = 1220
TOP_OF_SCREEN = 0
WALK_PATH_HEIGHT = 500

FORCE_TO_APPLY = 400


-- Called once, create sprites here
function love.load()
    -- Set background color
    love.graphics.setBackgroundColor(111/255,121/255,255/255)

    -- initalize "world", "stage", whatever you want to call it
    love.physics.setMeter(64)
    world = love.physics.newWorld(0, 9.81*64, true)
    
    -- Create an empty generic objects table
    objects = {}

    -- Make an Object for the "Bricks"
    objects.walk_path = {
        body = love.physics.newBody(world, RIGHT_EDGE_OF_SCREEN / 2, 700),
        shape = love.physics.newRectangleShape(RIGHT_EDGE_OF_SCREEN, 140)
    }
    objects.walk_path.fixture = love.physics.newFixture(objects.walk_path.body, objects.walk_path.shape)
    
    -- Make a toad
    objects.toad = {
        image = love.graphics.newImage("Assets/tiny toad.png"),
        body = love.physics.newBody(world, LEFT_EDGE_OF_SCREEN, WALK_PATH_HEIGHT, "dynamic"),
        shape = love.physics.newCircleShape(50)
    }
    -- Put it all together w/density of 0.6 (number may need future tweaking, but good enough)
    objects.toad.fixture = love.physics.newFixture(objects.toad.body, objects.toad.shape, 0.6)
    -- And add bouncyness
    objects.toad.fixture:setRestitution(0.8)
end

-- Add sprites to the stage here
function love.draw()
    -- Create background
    love.graphics.draw(love.graphics.newImage("Assets/mario_no_terrain Cropped.jpg"),0,0)
    -- Add walk_path object to world
    love.graphics.polygon("line", objects.walk_path.body:getWorldPoints(objects.walk_path.shape:getPoints()))
    -- Create Obstacles (very much TODO)
        for i=1, love.math.random(1,3) do
            make_new_block(i, false)
        end
    -- Add toad object to world
    love.graphics.draw(objects.toad.image, objects.toad.body:getX(),
                       objects.toad.body:getY(), objects.toad.shape:getRadius())
end

-- Called every $dt seconds, do game logic here
function love.update(dt)
    world:update(dt)
   -- Checks if right, left, up, down keys are pressed, and calls appropriate step (probably should have been named move) function
    local keys = {"right","left", "up", "down"} -- DONT FORGET TO ADD RIGHT BACK
    for i=1,4 do
       if love.keyboard.isDown(keys[i]) then
           step(keys[i], FORCE_TO_APPLY)
         end
    end
end

-- Below this line are functions I have made --

-- Moves $amount pixels towards $"direction"
function step(direction, amount)
    -- up/down don't really work right
    if direction == "up" then
        objects.toad.body:applyForce(0, amount)
    end

    if direction == "down" and (objects.toad.body:getY() + amount) <= WALK_PATH_HEIGHT then
        objects.toad.body:applyForce(0, -amount)
    end

    -- left/right do, but need wrap around
    if direction == "left"  and (objects.toad.body:getX() - amount) >= LEFT_EDGE_OF_SCREEN  then
        objects.toad.body:applyForce(-400, 0)
    end

    if direction == "right" then
        objects.toad.body:applyForce(400, 0)
    end
end

-- Probably will make new obstacles inside this function, could be a seperate func.?
function wrap_around()
    objects.toad.Body:setX(LEFT_EDGE_OF_SCREEN)
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