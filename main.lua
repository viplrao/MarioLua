---------------------------------------------------------
-- Vipul Rao                                           --
-- 1/25/20                                             --
-- Mario Game (even though there's no Mario...)        --
-- Usage: love { path to directory, usually just `.` } --
-- Once love opens, use the arrow keys to move Toad!   --
---------------------------------------------------------
-- Global, non-UI variables
-- Before adding, check if they really need to be global...
DEBUG = false -- if true, boundaries are more marked
LEFT_EDGE_OF_SCREEN = 0
RIGHT_EDGE_OF_SCREEN = 1334
TOP_OF_SCREEN = 0
BOTTOM_OF_SCREEN = 750
WALK_PATH_HEIGHT = 500

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
    objects.toad.fixture:setRestitution(0.8) -- Add bouncieness to toad, the higher the bouncier

    -- Wall sizing
    local wall_width = 20

    -- Try to shift left wall farther left - it'll give you more room on stage
    -- Make left edge, right edge objects
    objects.left_wall = {
        body = love.physics.newBody(world, LEFT_EDGE_OF_SCREEN - 75,
                                    BOTTOM_OF_SCREEN / 2, "static"),
        shape = love.physics.newRectangleShape(wall_width, BOTTOM_OF_SCREEN)

    }
    objects.left_wall.fixture = love.physics.newFixture(objects.left_wall.body,
                                                        objects.left_wall.shape)

    objects.right_wall = {
        body = love.physics.newBody(world, RIGHT_EDGE_OF_SCREEN,
                                    BOTTOM_OF_SCREEN / 2, "static"),
        shape = love.physics.newRectangleShape(wall_width, BOTTOM_OF_SCREEN)
    }
    objects.right_wall.fixture = love.physics.newFixture(
                                     objects.right_wall.body,
                                     objects.right_wall.shape)

    -- Make a ceiling
    objects.ceiling = {
        body = love.physics.newBody(world, RIGHT_EDGE_OF_SCREEN / 2,
                                    TOP_OF_SCREEN),
        shape = love.physics.newRectangleShape(RIGHT_EDGE_OF_SCREEN, 20)
    }
    objects.ceiling.fixture = love.physics.newFixture(objects.ceiling.body,
                                                      objects.ceiling.shape)
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
end

-- Called every $dt seconds, do game logic here
function love.update(dt)
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

function draw_transparent_walls()
    -- Override transparency if DEBUGging
    local mode = "fill"
    if DEBUG then
        -- Draw what you need to draw
        love.graphics.polygon(mode, objects.floor.body:getWorldPoints(
                                  objects.floor.shape:getPoints()))

        love.graphics.polygon(mode, objects.left_wall.body:getWorldPoints(
                                  objects.left_wall.shape:getPoints()))

        love.graphics.polygon(mode, objects.right_wall.body:getWorldPoints(
                                  objects.right_wall.shape:getPoints()))

        love.graphics.polygon(mode, objects.ceiling.body:getWorldPoints(
                                  objects.ceiling.shape:getPoints()))
    end
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
