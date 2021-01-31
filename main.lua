---------------------------------------------------------
-- Vipul Rao                                           --
-- 1/25/20                                             --
-- Mario Game (even though there's no Mario...)        --
-- Usage: love { path to directory, usually just `.` } --
-- Once love opens, use the arrow keys to move Toad!   --
---------------------------------------------------------
-- Global, non-UI variables
-- Before adding, check if they really need to be global...
LEFT_EDGE_OF_SCREEN = 0
RIGHT_EDGE_OF_SCREEN = 1334
TOP_OF_SCREEN = 0
BOTTOM_OF_SCREEN = 750
WALK_PATH_HEIGHT = 500
SCORE = 0
FONT = love.graphics.newFont("Assets/Fira Code.ttf", 24)

-- Command Line Arguments
for i = 0, #arg do
    if arg[i] == "--debug" or arg[i] == "-d" then
        DEBUG = true -- if true, boundaries are more marked
    elseif arg[i] == "--no-blocks" or arg[i] == "-nb" then
        NO_BLOCKS = true -- skip drawing obstacles

    elseif arg[i] == "--smooth-wrap" or arg[i] == "-s" then
        SMOOTH_WRAP = true -- alternate game mode that probably will be the main one
    end
end

-- Called once, create sprites here
function love.load()
    -- Initalize "world", "stage", whatever you want to call it
    love.physics.setMeter(64) -- 1 digital meter = 64 pixels, likely too late to change now
    world = love.physics.newWorld(0, 9.81 * 64, true) -- make a world with 9.81*64 (earths?) gravity

    objects = {} -- Create an empty table for our objects

    -- NOTE: love.physics.newBody uses center point, love.physics.newShape sets dimensions

    -- Make floor, toad, side walls
    objects.floor = {
        body = love.physics.newBody(world, RIGHT_EDGE_OF_SCREEN / 2, 600),
        shape = love.physics.newRectangleShape(RIGHT_EDGE_OF_SCREEN, 20)
    }
    objects.floor.fixture = love.physics.newFixture(objects.floor.body,
                                                    objects.floor.shape) -- Attach body to shape

    objects.toad = {
        image = love.graphics.newImage("Assets/tiny toad.png"),
        body = love.physics.newBody(world, LEFT_EDGE_OF_SCREEN,
                                    WALK_PATH_HEIGHT, "dynamic"),
        shape = love.physics.newCircleShape(50)
    }
    objects.toad.fixture = love.physics.newFixture(objects.toad.body,
                                                   objects.toad.shape, 0.6) -- Set density of Toad to 0.6
    objects.toad.fixture:setRestitution(0.7) -- Add bouncieness to toad, the higher the bouncier

    -- Wall sizing
    local wall_width = 20

    -- Make left edge, right edge objects
    objects.left_wall = {
        body = love.physics.newBody(world, LEFT_EDGE_OF_SCREEN - 75,
                                    BOTTOM_OF_SCREEN / 2, "static"),
        shape = love.physics.newRectangleShape(wall_width, BOTTOM_OF_SCREEN)

    }
    objects.left_wall.fixture = love.physics.newFixture(objects.left_wall.body,
                                                        objects.left_wall.shape)

    -- Make a ceiling
    objects.ceiling = {
        body = love.physics.newBody(world, RIGHT_EDGE_OF_SCREEN / 2,
                                    TOP_OF_SCREEN),
        shape = love.physics.newRectangleShape(RIGHT_EDGE_OF_SCREEN, 20)
    }
    objects.ceiling.fixture = love.physics.newFixture(objects.ceiling.body,
                                                      objects.ceiling.shape)

    if not NO_BLOCKS then
        -- objects.obstacles holds all our obstacle blocks, so we can draw them all at once
        objects.obstacles = {}
        for i = 1, love.math.random(5, 10) do
            table.insert(objects.obstacles, #objects.obstacles + 1,
                         make_a_block())
        end
    end
end

-- Add sprites to the world here, re-called everytime love.update() is triggered
function love.draw()
    -- Draw background, walls
    love.graphics.draw(love.graphics.newImage(
                           "Assets/mario_no_terrain Cropped.jpg"),
                       LEFT_EDGE_OF_SCREEN, TOP_OF_SCREEN)

    -- Draw anything that you want hidden
    draw_transparent_walls()

    -- Draw Toad
    love.graphics.draw(objects.toad.image, objects.toad.body:getX(),
                       objects.toad.body:getY(), objects.toad.shape:getRadius())

    -- "Switch pens" / draw the blocks in yellow
    love.graphics.setColor(255, 255, 0)

    if not NO_BLOCKS then
        -- Draw obstacles
        for i = 1, #objects.obstacles do
            local block = objects.obstacles[i]
            love.graphics.polygon("fill", block.body:getWorldPoints(
                                      block.shape:getPoints()))
        end
    end

    -- "Switch back"
    love.graphics.setColor(255, 255, 255)
    -- Draw a score label
    love.graphics.print("Score: " .. SCORE .. "", FONT,
                        RIGHT_EDGE_OF_SCREEN - 200, TOP_OF_SCREEN + 20)
end

-- Called every $dt seconds, do game logic here
function love.update(dt)
    -- For the Physics
    world:update(dt)

    -- How hard to push on Toad?
    local force = 500

    -- Check if right, left, up, down keys are pressed, and calls appropriate step function -- up is a special case
    local force_keys = {"right", "left", "up", "down"}
    for i = 1, #force_keys do
        if love.keyboard.isDown(force_keys[i]) then
            step(force_keys[i], force)
        end
    end

    -- If toad is heading past the edge of the screen, call wrap_around()
    if objects.toad.body:getX() + 20 > RIGHT_EDGE_OF_SCREEN then
        wrap_around()
    end

    -- Allow people to use space for up too
    if love.keyboard.isDown("space") then step("up", force) end

    -- Hit escape or ctrl-c to restart -- WILL NOT REFLECT MODIFIED CODE!
    if love.keyboard.isDown("lctrl", "c") or love.keyboard.isDown("escape") then
        love.load()
    end
end

-------- Below this line are functions that I have made --------

-- Apply $amount force towards $"direction"
function step(direction, amount)
    local anti_gravity_scale_factor = 2.5

    if direction == "up" then
        objects.toad.body:applyForce(0, -amount * anti_gravity_scale_factor)
    end

    if direction == "down" then
        objects.toad.body:applyForce(0, amount * anti_gravity_scale_factor)
    end

    if direction == "left" then objects.toad.body:applyForce(-amount, 0) end

    if direction == "right" then objects.toad.body:applyForce(amount, 0) end
end

-- Called from love.draw() anything you want to be transparent (unless DEBUGging) should be put in here
function draw_transparent_walls()
    -- Override transparency if DEBUGging
    local mode = "fill"
    if DEBUG then
        -- Draw what you need to draw
        love.graphics.polygon(mode, objects.floor.body:getWorldPoints(
                                  objects.floor.shape:getPoints()))

        love.graphics.polygon(mode, objects.left_wall.body:getWorldPoints(
                                  objects.left_wall.shape:getPoints()))

        love.graphics.polygon(mode, objects.ceiling.body:getWorldPoints(
                                  objects.ceiling.shape:getPoints()))
    end
end

-- Called whenever Toad gets close to the end of screen (within 50 pixels)
function wrap_around()
    -- Move Toad back
    objects.toad.body:setX(LEFT_EDGE_OF_SCREEN)
    SCORE = SCORE + 1

    if not NO_BLOCKS then
        -- Move each of the blocks to a new position
        for i = 1, #objects.obstacles do
            local block = objects.obstacles[i]
            block.body:setX(rand_on_axis("x"))
            block.body:setY(rand_on_axis("y"))
        end
    end

    if not SMOOTH_WRAP then love.load() end

end

-- Finds a random number in range of x or y axis
function rand_on_axis(axis)
    if axis == "x" then
        return love.math.random(LEFT_EDGE_OF_SCREEN + 50, RIGHT_EDGE_OF_SCREEN)
    end
    if axis == "y" then
        return love.math.random(TOP_OF_SCREEN, WALK_PATH_HEIGHT)
    end
end

-- Returns a block with random position, called in love.load()
function make_a_block()
    local block = {
        body = love.physics.newBody(world, rand_on_axis("x"), rand_on_axis("y"),
                                    "static"),
        shape = love.physics.newRectangleShape(50, 50)
    }
    block.fixture = love.physics.newFixture(block.body, block.shape)
    return block
end
