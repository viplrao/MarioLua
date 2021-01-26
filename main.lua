-- Vipul Rao
-- 1/25/20
-- Mario Game
-- Usage: `love .` or cmd-L-L in VScode
-- Once love opens, use the arrow keys to move toad!

-- Most Recent Commit Name:"Added Left, Right Wall"

-- Global, non-UI variables
-- Before adding, check if they really need to be global...
DEBUG = false
LEFT_EDGE_OF_SCREEN = 0
RIGHT_EDGE_OF_SCREEN = 1334
TOP_OF_SCREEN = 0
BOTTOM_OF_SCREEN  = 750
WALK_PATH_HEIGHT = 500


-- Called once, create sprites here
function love.load()

    -- Initalize "world", "stage", whatever you want to call it
    love.physics.setMeter(64)
    world = love.physics.newWorld(0, 9.81*64, true)

    -- Create an empty generic objects table
    objects = {}

    -- NOTE: love.physics.newBody uses center point, love.physics.newShape sets dimensions

    -- Make an Object for the "Bricks"
    objects.floor = {
        body = love.physics.newBody(world, RIGHT_EDGE_OF_SCREEN / 2, 650),
        shape = love.physics.newRectangleShape(RIGHT_EDGE_OF_SCREEN, 50)
    }
    -- Attach body to shape
    objects.floor.fixture = love.physics.newFixture(objects.floor.body, objects.floor.shape)

    -- Make toad
    objects.toad = {
        image = love.graphics.newImage("Assets/tiny toad.png"),
        body = love.physics.newBody(world, LEFT_EDGE_OF_SCREEN, WALK_PATH_HEIGHT, "dynamic"),
        shape = love.physics.newCircleShape(50)
    }
    -- Give toad density of 0.6 (number may need future tweaking, but good enough)
    objects.toad.fixture = love.physics.newFixture(objects.toad.body, objects.toad.shape, 0.6)
    -- Add bouncyness, the higher the bouncier
    objects.toad.fixture:setRestitution(0.8)

    -- Make left edge, right edge objects
    local wall_width = 10
    local wall_height = 2 * BOTTOM_OF_SCREEN
    objects.left_wall = {
        body = love.physics.newBody(world, LEFT_EDGE_OF_SCREEN , WALK_PATH_HEIGHT),
        shape = love.physics.newRectangleShape(wall_width, wall_height),
    }
    objects.left_wall.fixture = love.physics.newFixture(objects.left_wall.body, objects.left_wall.shape)

    objects.right_wall = {
        body = love.physics.newBody(world, RIGHT_EDGE_OF_SCREEN, WALK_PATH_HEIGHT),
        shape = love.physics.newRectangleShape(wall_width, wall_height),
    }
    objects.right_wall.fixture = love.physics.newFixture(objects.right_wall.body, objects.right_wall.shape)
end

-- Add sprites to the world here, re-called everytime love.update() is triggered
function love.draw()
    -- Add background
    love.graphics.draw(love.graphics.newImage("Assets/mario_no_terrain Cropped.jpg"),0,0)
    -- Add boundaries to world, hide if not debugging
    if DEBUG then
    love.graphics.polygon("fill", objects.floor.body:getWorldPoints(objects.floor.shape:getPoints()))
    love.graphics.polygon("fill", objects.left_wall.body:getWorldPoints(objects.left_wall.shape:getPoints()))
    love.graphics.polygon("fill", objects.right_wall.body:getWorldPoints(objects.right_wall.shape:getPoints()))
    else
        love.graphics.polygon("line", objects.floor.body:getWorldPoints(objects.floor.shape:getPoints()))
        love.graphics.polygon("line", objects.left_wall.body:getWorldPoints(objects.left_wall.shape:getPoints()))
        love.graphics.polygon("line", objects.right_wall.body:getWorldPoints(objects.right_wall.shape:getPoints()))
    end

    -- Add toad to world
    love.graphics.draw(objects.toad.image, objects.toad.body:getX(), objects.toad.body:getY(), objects.toad.shape:getRadius())
end

-- Called every $dt seconds, do game logic here
function love.update(dt)
    world:update(dt)

    -- Checks if right, left, up, down keys are pressed, and calls appropriate step function -- up is a special case
    local force = 500 -- used with force_keys / physics.applyForce
    local pixels = 20 -- used with step("up") / body.setY()

    local force_keys = {"right","left", "down" }

    for i=1,#force_keys do
       if love.keyboard.isDown(force_keys[i]) then
           step(force_keys[i], force)
         end
    end

    if  love.keyboard.isDown("space") or love.keyboard.isDown("up") then
        step("up", pixels)
    end
    
    -- esc restart functionality -- WILL NOT REFLECT MODIFIED CODE
    if love.keyboard.isDown("lctrl", "c") or love.keyboard.isDown("escape") then
        love.load()
    end

end

-------- Below this line are functions that I have made --------

-- Apply $amount force towards $"direction"
function step(direction, amount)
    -- up/down don't really work right
    if direction == "up" then
        objects.toad.body:setY(objects.toad.body:getY() - amount)
    end

    if direction == "down" then
        objects.toad.body:setY(objects.toad.body:getY() + amount)
    end

    -- left/right work, but need wrap around
    if direction == "left" then
        objects.toad.body:applyForce(-amount, 0)
    end

    if direction == "right" then
        objects.toad.body:applyForce(amount, 0)
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