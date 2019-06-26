

_ENV= namespace "decorator"

__decorator__()
function __TestTime__()
	return function (luafunction,functionName)
		return function(...)
			local startTime=os.clock()
			local result={luafunction(...)}
			local endTime=os.clock()
			print("function "..functionName.." cost time "..(endTime-startTime).." s")
			return table.unpack(result)
		end
	end
end


