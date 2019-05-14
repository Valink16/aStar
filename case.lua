-- Module implementing pathfinding abilities for the cases on the grid

new = function()
    local case = {}

    case.g = 0 -- Distance from source
    case.h = 0 -- Heuristic function result(usually pythagorian distance between current and goal)
    case.f = 0 -- will be set to g + 
    case.previous = nil

    -- position of the grid which will be set after creation
    case.x = nil
    case.y = nil

    function case:neighbours(grid, closeset)
        -- Returns table of neighbors
        local n = {}
        if self.y > 1 then table.insert(n, grid[self.y-1][self.x]) end -- upper neighbour
        if self.y < #grid then table.insert(n, grid[self.y+1][self.x]) end -- lower neighbour
        if self.x > 1 then table.insert(n, grid[self.y][self.x-1]) end -- upper neighbour
        if self.x < #grid[1] then table.insert(n, grid[self.y][self.x+1]) end -- upper neighbour
        return n
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

    return case
end

return {
    new = new
}