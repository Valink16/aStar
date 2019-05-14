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

function love.load()
    love.window.setMode(500, 500, {resizable=true, minwidth=200, minheight=200, msaa=8})

    -- Setting up the grid
    math.randomseed(os.time())
    cf = function()
        local r = math.random()
        if r >= 0.4 then w = true else w = false end
        return case.new(w)
    end
    g = grid.new(20, 20, cf)

    source = g[1][1]
    goal = g[#g][#g[1]]

    openset = {source}
    closeset = {}

    pathfinder_delay = 1 -- Delay in frames for one iteration of the Dijkstra algo
    frame_counter = 0
    
    done = false
    success = false
end

function love.update(dt)
    frame_counter = frame_counter + 1
    if frame_counter == pathfinder_delay and not done then
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

        if current == goal then
            done = true
            success = true
            print("Done !")
            goto found_path
        elseif current == nil then
            done = true
            success = false
            print("Could not find path...")
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
            n.h = n:dist_between(goal) * 1.5
            n.make_f()
            n.previous = current

            ::ignore_neighbour::
        end
    end

    ::found_path::
    path = {}
    if done and success then
        path = current:build_path(source)
    end
end

function love.draw() 
    love.window.setTitle("Open: "..tostring(#openset)..", Close: "..tostring(#closeset))

    love.graphics.clear(255, 255, 255)

    g:draw_grid(openset, closeset, false)

    if done then
        -- Drawing path
        local ww, wh = love.window.getMode()
        local cw = ww / #g[1] * g.sx-- Case width
        local ch = wh / #g * g.sy-- Case height
        for i, c in ipairs(path) do
            c:draw(cw, ch, {0, 0, 255})
        end
    end
end
