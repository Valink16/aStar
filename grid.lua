-- Module for managing the grid, drawing it, managing zoom levels, etc.

function round(num, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function debug_str(c) 
    return "["..tostring(c.x)..";"..tostring(c.y).."] | f: "..tostring(round(c.f,3)).."\ng: "..tostring(round(c.g,3)).."\nh: "..tostring(round(c.f,3))
end

new = function(w, h, create_func) -- Creates a w*h grid and fills in with dv
    -- create_func must be a function with 0 args which creates a default "case"
    local g = {}

    -- Scale multipliers of the grid used for drawing
    g.sx = 1 
    g.sy = 1

    g.font = love.graphics.newFont(12 * g.sx) -- Font for debugging

    for i=1, h do
        local y = {}
        for j=1, w do
            local c = create_func()
            c.x = j
            c.y = i
            table.insert(y, c)
        end
        table.insert(g, y)
    end

    function g:draw_grid(openset, closeset, debug)
        local ww, wh = love.window.getMode()
        local cw = ww / #g[1] * g.sx-- Case width
        local ch = wh / #g * g.sy-- Case height
        --print("Case dimensions are:"..tostring(cw).."; "..tostring(ch))

        -- openset
        for i, c in ipairs(openset) do
            --print(c.g, c.h, c.f)
            local tx = (c.x-1) * cw
            local ty = (c.y-1) * ch
            love.graphics.setColor(255, 255, 0)
            love.graphics.rectangle("fill", tx, ty, cw, ch)
            if debug then 
                love.graphics.setColor(0, 0, 0)
                love.graphics.draw(
                    love.graphics.newText(
                        g.font, debug_str(c)),
                    tx, ty)
            end
        end

        -- closeset
        for i, c in ipairs(closeset) do
            --print(c.g, c.h, c.f)
            local tx = c.x * cw
            local ty = c.y * ch
            love.graphics.setColor(127, 0, 0)
            love.graphics.rectangle("fill", tx, ty, cw, ch)
            if debug then 
                love.graphics.setColor(0, 0, 0)
                love.graphics.draw(
                    love.graphics.newText(
                        g.font, debug_str(c)),
                    tx, ty)
            end
        end

        love.graphics.draw(g.grid_image)
    end

    function g:print_grid()
        for i, y in ipairs(g) do
            for j, x in ipairs(y) do
                io.write("["..tostring(x.x)..","..tostring(x.y).."] ")
            end
            io.write("\n")
        end
    end

    function g:generate_grid()
        -- Used to regenerate the grid image (i.e:when scale changes for), returns an Image
        local ww, wh = love.window.getMode()
        local cw = ww / #g[1] * g.sx-- Case width
        local ch = wh / #g * g.sy-- Case height
        --print("Case dimensions are:"..tostring(cw).."; "..tostring(ch))

        local tmp_canvas = love.graphics.newCanvas(ww, wh)
        love.graphics.setCanvas(tmp_canvas)
            love.graphics.clear(0, 0, 0, 0)
            
            for i, y in ipairs(g) do
                for j, x in ipairs(y) do
                    local tx = (j-1) * cw
                    local ty = (i-1) * ch
                    love.graphics.setColor(0, 0, 0, 1)
                    love.graphics.rectangle("line", tx, ty, cw, ch)
                end
            end
        love.graphics.setCanvas()

        return love.graphics.newImage(tmp_canvas:newImageData())
    end

    g.grid_image = g:generate_grid()

    return g
end
  
return {
    new = new
}