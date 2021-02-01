---------------------------------------------------------
-- Vipul Rao                                           --
-- 1/25/20                                             --
-- Mario Game (even though there's no Mario...)        --
-- Usage: love { path to directory, usually just `.` } --
-- Once love opens, use the arrow keys to move Toad!   --
---------------------------------------------------------
-- Global, non-UI variables
LEFT_EDGE_OF_SCREEN = 0
RIGHT_EDGE_OF_SCREEN = 1334
TOP_OF_SCREEN = 0
BOTTOM_OF_SCREEN = 750
WALK_PATH_HEIGHT = 500
CENTER_X = RIGHT_EDGE_OF_SCREEN / 2
CENTER_Y = WALK_PATH_HEIGHT / 2
SCORE = 0
FONT = love.graphics.newFont("Assets/Fira Code.ttf", 24)
CENTER_X = CENTER_X
CENTER_Y = WALK_PATH_HEIGHT / 2

-- Command Line Arguments, none of these are used in default behavior
for i = 0, #arg do
    if arg[i] == "--debug" or arg[i] == "-d" then
        DEBUG = true -- if true, boundaries are more marked
    elseif arg[i] == "--no-blocks" or arg[i] == "-nb" then
        NO_BLOCKS = true -- if true, skip drawing obstacles
    end
end

-- Setup the Hump Library for switching screens
Gamestate = require("hump.gamestate")
local menu = {}
local game = {}

-- Called once, create sprites here
function love.load()
    -- Initalize "world", "stage", whatever you want to call it
    love.physics.setMeter(64) -- 1 digital meter = 64 pixels, likely too late to change now
    world = love.physics.newWorld(0, 9.81 * 64, true) -- make a world with 9.81*64 (earths?) gravity

    objects = {} -- Create an empty table for our objects

    fill_objects() -- Moved into a procedure because it's so much stuff

    -- objects.obstacles holds all our obstacle blocks, so we can draw them all at once
    objects.obstacles = {}

    fill_objects_obstacles()

    Gamestate.registerEvents()
    Gamestate.switch(menu)

end

-- Draw the start menu
function menu:draw()
    local message =
        ' Welcome!\n\n Use the arrow keys to move Toad,\n and get points when you reach the end.\n\n If a level seems impossible, it might be! \n These are all randomly generated, so press\n escape to reload. \n \n Press "p" to come back to this screen. \n Your score will be preserved. \n\n Press any other key to go to the game.'
    love.graphics.draw(love.graphics.newImage(
                           "Assets/mario_no_terrain Cropped.jpg"),
                       LEFT_EDGE_OF_SCREEN, TOP_OF_SCREEN)
    love.graphics.print(message, FONT, CENTER_X - 300, CENTER_Y - 100)

    love.graphics.print("Score: " .. SCORE .. "", FONT,
                        RIGHT_EDGE_OF_SCREEN - 200, TOP_OF_SCREEN + 20)

end

function menu:keyreleased(key)
    -- Switch screens when you press (and release) any key (except p, or else you'll never see the screen)
    if key ~= "p" then Gamestate.switch(game) end
end

-- Put anything you want drawn in scene `game` here
function game:draw()
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

    -- Draw obstacles unless told not to
    if not NO_BLOCKS then
        for i = 1, #objects.obstacles do
            local block = objects.obstacles[i]
            love.graphics.polygon("fill", block.body:getWorldPoints(
                                      block.shape:getPoints()))
        end
    end

    -- "Switch back"
    love.graphics.setColor(255, 255, 255)

    -- Draw score label
    love.graphics.print("Score: " .. SCORE .. "", FONT,
                        RIGHT_EDGE_OF_SCREEN - 200, TOP_OF_SCREEN + 20)
end

-- Called every $dt seconds, do game logic here
function game:update(dt)
    -- For the Physics
    world:update(dt)

    -- How hard to push on Toad?
    local force = 500

    -- Check if right, left, up, down keys are pressed, and call appropriate step function
    local force_keys = {"right", "left", "up", "down"}
    for i = 1, #force_keys do
        if love.keyboard.isDown(force_keys[i]) then
            step(force_keys[i], force)
        end
    end

    -- Allow people to use space for up too
    if love.keyboard.isDown("space") then step("up", force) end

    -- If toad is heading past the edge of the screen or escape is pressed, call wrap_around()
    if objects.toad.body:getX() + 20 > RIGHT_EDGE_OF_SCREEN or
        love.keyboard.isDown("escape") then wrap_around() end

    -- Hit p(ause) to see the menu again
    if love.keyboard.isDown("p") then Gamestate.switch(menu) end

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

-- Called whenever Toad gets close to the end of screen (within 20 pixels)
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
end

-- Finds a random number in range of x or y axis
function rand_on_axis(axis)
    if axis == "x" then
        return love.math.random(LEFT_EDGE_OF_SCREEN + 50, RIGHT_EDGE_OF_SCREEN)

    elseif axis == "y" then
        return love.math.random(TOP_OF_SCREEN, WALK_PATH_HEIGHT + 20)
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

function fill_objects()

    -- NOTE: love.physics.newBody uses center point, love.physics.newShape sets dimensions

    -- Make floor
    objects.floor = {
        body = love.physics.newBody(world, CENTER_X, 600),
        shape = love.physics.newRectangleShape(RIGHT_EDGE_OF_SCREEN, 20)
    }
    objects.floor.fixture = love.physics.newFixture(objects.floor.body,
                                                    objects.floor.shape) -- Attach body to shape

    -- Make toad
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

    -- Make left wall, right wall objects
    objects.left_wall = {
        body = love.physics.newBody(world, LEFT_EDGE_OF_SCREEN - 75,
                                    BOTTOM_OF_SCREEN / 2, "static"),
        shape = love.physics.newRectangleShape(wall_width, BOTTOM_OF_SCREEN)

    }
    objects.left_wall.fixture = love.physics.newFixture(objects.left_wall.body,
                                                        objects.left_wall.shape)

    -- Make ceiling
    objects.ceiling = {
        body = love.physics.newBody(world, CENTER_X, TOP_OF_SCREEN),
        shape = love.physics.newRectangleShape(RIGHT_EDGE_OF_SCREEN, 20)
    }
    objects.ceiling.fixture = love.physics.newFixture(objects.ceiling.body,
                                                      objects.ceiling.shape)
end

function fill_objects_obstacles()
    if not NO_BLOCKS then
        -- Make a random (8-12) amount of blocks, store them in objects.obstacles
        for _ = 1, love.math.random(8, 12) do
            -- Call make_a_block(), and place the returned block in the next available spot in objects.obstacles
            table.insert(objects.obstacles, #objects.obstacles + 1,
                         make_a_block())
        end
    end
end
