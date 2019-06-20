require "decorator.TestTime"
_ENV=namespace "test"
using_namespace "decorator"
__TestTime__();
---@param count number
function FOR_TEST(count)
	local t={}
	for i=1,count do
		t[i]=i
	end
end

FOR_TEST(999999)