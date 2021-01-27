-- Vipul Rao
-- 1/25/20
-- Mario Game (even though there's no Mario...)
-- Usage: love { path to directory, usually just `.` }
-- Once love opens, use the arrow keys to move Toad!

-- Most Recent Commit Name:"transparent floor, walls"

-- Global, non-UI variables
-- Before adding, check if they really need to be global...
DEBUG = false -- if true, boundaries are more marked
LEFT_EDGE_OF_SCREEN = 0
RIGHT_EDGE_OF_SCREEN = 1334
TOP_OF_SCREEN = 0
BOTTOM_OF_SCREEN  = 750
WALK_PATH_HEIGHT = 500


-- Called once, create sprites here
function love.load()
    -- Initalize "world", "stage", whatever you want to call it
    love.physics.setMeter(64) -- 1 digital meter = 64 pixels, likely too late to change now
    world = love.physics.newWorld(0, 9.81*64, true) -- make a world with 9.81*64 (earths?) gravity

    objects = {}  -- Create an empty table for our objects

    -- NOTE: love.physics.newBody uses center point, love.physics.newShape sets dimensions

    -- Make floor, toad, side walls
    objects.floor = {body = love.physics.newBody(world, RIGHT_EDGE_OF_SCREEN / 2, 600)}
    objects.floor.shape =love.physics.newRectangleShape(RIGHT_EDGE_OF_SCREEN, 20)
    objects.floor.fixture = love.physics.newFixture(objects.floor.body, objects.floor.shape) -- Attach body to shape

    objects.toad = {image = love.graphics.newImage("Assets/tiny toad.png")}
    objects.toad.body = love.physics.newBody(world, LEFT_EDGE_OF_SCREEN, WALK_PATH_HEIGHT, "dynamic")
    objects.toad.shape = love.physics.newCircleShape(50)
    objects.toad.fixture = love.physics.newFixture(objects.toad.body, objects.toad.shape, 0.6) -- Set density of 0.6
    objects.toad.fixture:setRestitution(0.7) -- Add bouncieness to toad, the higher the bouncier

    -- Wall sizing
    local wall_width = 20

    -- Make left edge, right edge objects
    objects.left_wall = {shape = love.physics.newRectangleShape(wall_width, BOTTOM_OF_SCREEN)}
    objects.left_wall.body = love.physics.newBody(world, LEFT_EDGE_OF_SCREEN, BOTTOM_OF_SCREEN / 2)
    objects.left_wall.fixture = love.physics.newFixture(objects.left_wall.body, objects.left_wall.shape)

    objects.right_wall = {shape = love.physics.newRectangleShape(wall_width, BOTTOM_OF_SCREEN)}
    objects.right_wall.body = love.physics.newBody(world, RIGHT_EDGE_OF_SCREEN, BOTTOM_OF_SCREEN / 2)
    objects.right_wall.fixture = love.physics.newFixture(objects.right_wall.body, objects.right_wall.shape)
end

-- Add sprites to the world here, re-called everytime love.update() is triggered
function love.draw()
    local mode = "line"
    -- Draw background, walls (done in a seperate procedure), toad
    love.graphics.draw(love.graphics.newImage("Assets/mario_no_terrain Cropped.jpg"),0,0)
    draw_transparent_walls()
    love.graphics.draw(objects.toad.image, objects.toad.body:getX(), objects.toad.body:getY(), objects.toad.shape:getRadius())
end

-- Called every $dt seconds, do game logic here
function love.update(dt)
    world:update(dt)

    local force = 400

    -- Check if right, left, up, down keys are pressed, and calls appropriate step function -- up is a special case
    local force_keys = {"right","left", "up", "down" }
    for i=1,#force_keys do if love.keyboard.isDown(force_keys[i]) then
           step(force_keys[i], force)
        end
    end
    -- Allow people to use space for up too
    if love.keyboard.isDown("space") then step("up", force) end
    -- Hit escape or ctrl-c to restart -- WILL NOT REFLECT MODIFIED CODE!
    if love.keyboard.isDown("lctrl", "c") or love.keyboard.isDown("escape") then love.load() end

end

-------- Below this line are functions that I have made --------

-- Apply $amount force towards $"direction"
function step(direction, amount)
    local anti_gravity_scale_factor = 2

    if direction == "up" then
        objects.toad.body:applyForce(0, -amount *  anti_gravity_scale_factor)
    end

    if direction == "down" then
        objects.toad.body:applyForce(0, amount * anti_gravity_scale_factor)
    end

    if direction == "left" then
        objects.toad.body:applyForce(-amount, 0)
    end

    if direction == "right" then
         objects.toad.body:applyForce(amount, 0)
    end
end

function draw_transparent_walls()
    local border_transparency = 0
    if  DEBUG then
        mode  = "fill"
        border_transparency = 255
    end

    -- Switch to transparent ink
    love.graphics.setColor(255, 255, 255, border_transparency)

    -- Draw what you need to draw
    love.graphics.polygon(mode, objects.floor.body:getWorldPoints(objects.floor.shape:getPoints()))
    love.graphics.polygon(mode, objects.left_wall.body:getWorldPoints(objects.left_wall.shape:getPoints()))
    love.graphics.polygon(mode, objects.right_wall.body:getWorldPoints(objects.right_wall.shape:getPoints()))

    -- Switch back to normal ink
    love.graphics.setColor(255, 255, 255, 255)
end

------ None of these are used yet -------

-- Finds a random number in range of x or y axis
function rand_on_axis(axis)
    if axis == "x" then
        return love.math.random(LEFT_EDGE_OF_SCREEN, RIGHT_EDGE_OF_SCREEN)
    end
    if axis == "y" then
      return love.math.random(TOP_OF_SCREEN, WALK_PATH_HEIGHT)
    end
end