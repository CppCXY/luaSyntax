

_ENV= namespace "decorator"

__decorator__()
function __Deprecated__(descText)
	return function (luafunction,functionName)
		return function(...)
			print (functionName.." has deprecated ,"..descText)
			return luafunction(...)
		end
	end
end
