-- Module implementing pathfinding abilities for the cases on the grid

new = function(walkable)
    local case = {}

    case.g = 0 -- Distance from source
    case.h = 0 -- Heuristic function result(usually pythagorian distance between current and goal)
    case.f = 0 -- will be set to g + h
    case.previous = nil

    -- position of the grid which will be set after creation
    case.x = nil
    case.y = nil

    case.walkable = walkable

    function case:neighbours(grid)
        -- Returns table of neighbors
        local n = {}
        if self.y > 1 and grid[self.y-1][self.x].walkable then -- upper neighbour
            table.insert(n, grid[self.y-1][self.x]) 
        end
        if self.y < #grid and grid[self.y+1][self.x].walkable then -- lower neighbour
            table.insert(n, grid[self.y+1][self.x])
        end
        if self.x > 1 and grid[self.y][self.x-1].walkable then -- left neighbour
            table.insert(n, grid[self.y][self.x-1])
        end
        if self.x < #grid[1] and grid[self.y][self.x+1].walkable then -- right neighbour
            table.insert(n, grid[self.y][self.x+1]) 
        end 
        return n
    end

    function case:draw(cw, ch, c, debug)
        local tx = (case.x-1) * (cw) 
        local ty = (case.y-1) * (ch) 

        love.graphics.setColor(c)
        love.graphics.rectangle("fill", tx, ty, cw, ch)
        if debug then
            love.graphics.setColor(0, 0, 0)
            love.graphics.draw(
                love.graphics.newText(
                    g.font, self:debug_str()),
                tx, ty)
        end
    end

    function case:debug_str()
        return "["..tostring(self.x)..";"..tostring(self.y).."] | f: "..tostring(round(self.f,3)).."\ng: "..tostring(round(self.g,3)).."\nh: "..tostring(round(self.f,3))
    end

    function case:dist_between(other)
        return math.sqrt(
            (self.x-other.x) * (self.x-other.x) + 
            (self.y-other.y) * (self.y-other.y)
        )
    end

    function case:make_f() 
        case.f = case.g + case.h
        return case.f
    end

    function case:build_path(source) -- Retraces the path using case.previous until it finds the source
        local current = self
        local path = {}
        while true do
            table.insert(path, current)
            if current == source then
                goto done
            else
                current = current.previous
            end
        end
        ::done::
        return path
    end

    return case
end

return {
    new = new
}