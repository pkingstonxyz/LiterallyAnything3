--local fennel = require("fennel")


--table.insert(package.loaders, function(filename)
--   if love.filesystem.getInfo(filename) then
--      return function(...)
--         return fennel.eval(love.filesystem.read(filename), {env=_G, filename=filename}, ...), filename
--      end
--   end
--end)
-- jump into Fennel
---require("main.fnl")

-- bootstrap the compiler (https://fennel-lang.org/setup#embedding-fennel)
_G.fennel = require("lib.fennel")


debug.traceback = fennel.traceback

table.insert(package.loaders, fennel.make_searcher({
	correlate=true -- try to match line numbers for stack trace
}))

-- simple pretty print function
_G.pp = function(x)
	print(fennel.view(x))
end

-- here would be a good place to load more potent standard library
-- _G.lume = require("lib.lume")

require("game")
