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
    love.window.setMode(1280, 720, {resizable=true, minwidth=200, minheight=200, msaa=8})

    -- Setting up the grid
    cf = function() return case.new() end
    g = grid.new(10, 10, cf)

    source = g[1][1]
    goal = g[10][10]

    openset = {source}
    closeset = {}

    pathfinder_delay = 60 -- Delay in frames for one iteration of the Dijkstra algo
    frame_counter = 0
    
    done = false
end

function love.update(dt)
    frame_counter = frame_counter + 1
    if frame_counter == pathfinder_delay and not done then
        frame_counter = 0

        -- Finding case in openset with the smallest f
        local current = openset[1]
        for i, c in ipairs(openset) do
            if c.make_f() < current.make_f() then
                current = c
            end
        end

        neighbours = current:neighbours(g)

        -- Moving current to closeset
        remove_from(current, openset)
        table.insert(closeset, current)

        --print("[*] Found "..tostring(#neighbours).." neighbours for "..tostring(current.x)..";"..tostring(current.y))
        for i, n in ipairs(neighbours) do
            local inos = in_set(n, openset)
            local incs = in_set(n, closeset)
            if (not inos) and (not incs)then 
                print("Inserting to openset")
                table.insert(openset, n)
            elseif inos and not incs then
                print("Ok, we're in")
                n.g = current.g + 1
                n.h = current:dist_between(goal)
                print(n.h)
            end
        end

        print(#closeset, #openset)
    end
end

function love.draw() 
    love.graphics.clear(255, 255, 255)

    g:draw_grid(openset, closeset, true)
end