require "luaSyntax.init"

_ENV=namespace "test"
using_namespace "decorator"


__TestTime__	()
__Deprecated__	(" Please use new function say")
__NamedArgs__	(
	PARAM(1,"text","你谁啊")
)
function speak(text)
	print(text)
end

speak()





