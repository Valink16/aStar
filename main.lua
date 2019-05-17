case = require "case"
grid = require "grid"

function in_set(v, set) 
    for k, x in pairs(set) do
        if x == v then
            return true
        end 
    end
    return false
end

function remove_from(v, set)
    for k, x in pairs(set) do
        if x == v then
            table.remove(set, k)
        end 
    end
end

function init_grid()
    -- Sets up the grid with random walls and returns it
    math.randomseed(os.time())
    cf = function()
        local r = math.random()
        if r >= 0.3 then w = true else w = false end
        return case.new(w)
    end
    return grid.new(200, 200, cf)
end

function init_astar(gx, gy, sx, sy) -- Sets up for aStar pathfindings, arguments are coordinates in grid of goal(gx, gy) and source(sx, sy) 
    -- Optional args
    if not gx then gx = #g[1] / 2 end
    if not gy then gy = #g / 2 end
    if not sx then sx = 1 end
    if not sy then sy = 1 end

    source = g[sy][sx]
    goal = g[gy][gx]

    source.walkable = true -- source and goal must be walkable
    goal.walkable = true

    openset = {source} -- Initial insert into openset
    closeset = {}

    pathfinder_delay = 1 -- Delay in frames for one iteration of the aStar algo
    frame_counter = 0
    
    done = false

    g.grid_image = g:generate_grid() -- get a premade image of the grid for MOAR PERFORMACE
end


function love.load()
    love.window.setMode(1000, 1000, {resizable=true, minwidth=200, minheight=200, msaa=8})
    g = init_grid()
    init_astar()
end

function love.update(dt)
    frame_counter = frame_counter + 1
    if (not done) and frame_counter == pathfinder_delay then
        frame_counter = 0

        -- Finding case in openset with the smallest f
        current = openset[1]
        for i, c in ipairs(openset) do
            if c.make_f() < current.make_f() then
                current = c
            end
        end

        -- Moving current to closeset
        table.insert(closeset, current)
        remove_from(current, openset)

        if current == goal then -- Checking if we found a path
            done = true
            print("Done !")
            path = {}
            path = current:build_path(source)
            goto found_path
        elseif current == nil then -- if current is nil it means that openset[1] does not exist(openset is empty, so there's nothing to evaluate. /!\ Look for assignment of current at start of love.update)
            done = true
            print("Sorry, could not find a path..., resetting")
            g = init_grid()
            g.grid_image = g:generate_grid()
            goto found_path
        end
        
        for i, n in ipairs(current:neighbours(g)) do
            local inos = in_set(n, openset)
            local incs = in_set(n, closeset)
            
            if incs then goto ignore_neighbour end -- Ignore the neighbour if it's in closeset

            local future_g = current.g + 1

            if not inos then -- Discovered new case
                table.insert(openset, n)
            elseif future_g >= n.g then -- Ignore this neighbour because it's not the shortest path
                goto ignore_neighbour
            end

            n.g = future_g
            local d = n:dist_between(goal)
            n.h = d*d 
            n.make_f()
            n.previous = current

            ::ignore_neighbour::
        end
    end
    ::found_path::
end

function love.draw() 
    love.window.setTitle("Open: "..tostring(#openset)..", Close: "..tostring(#closeset))

    love.graphics.clear(255, 255, 255)

    g:draw_grid(openset, closeset, false)

    if done and not(path == nil) then
        -- Drawing path
        local ww, wh = love.window.getMode()
        local cw = ww / #g[1] * g.sx-- Case width
        local ch = wh / #g * g.sy-- Case height
        for i, c in ipairs(path) do
            c:draw(cw, ch, {0, 0, 255})
        end
    end
end

function love.mousereleased(x, y, b)
    local ww, wh = love.window.getMode()
    local tx = math.floor(x / (ww / #g[1])+.5) 
    local ty = math.floor(y / (wh / #g)+.5)  
    print(tx, ty)
    if b == 1 then
        init_astar(tx, ty)
    end
end