
_ENV= namespace "decorator"

__decorator__()
function __NamedArgs__(...)
    local args={...}
    local query={}
    for index,value in pairs(args) do
        local ctype=type(value)
        if ctype=="table" then
            query[value.key]={index=value.index or index,default=value.default}
        elseif ctype=="string" then
            query[value]={index=index}
        else
            error ("bad params namedArgs decl must be table or string")
        end

    end

	return function (luafunction,functionName)
        return function(...)
            local params={...}
            local args={}
            local namedArgs={}
            local maxIndex=1
            for index,value in pairs(params) do
                if getmetatable(value)==LARG_IMPLEMENT then
                    local arg=query[value.key]
                    if arg==nil then
                        error("error : undeclare named arg "..value.key)
                    else
                        namedArgs[value.key]=value.value
                    end
    
                else
                    maxIndex=index>maxIndex and index or maxIndex
                    args[index]=value
                end                
            end
            for key,argv in pairs(query) do
                maxIndex=argv.index>maxIndex and argv.index or maxIndex
                local oldValue=args[argv.index]
                local nameValue=namedArgs[key]
                if oldValue==nil and nameValue==nil then
                    args[argv.index]=argv.default
                elseif oldValue==nil and nameValue~=nil then
                    args[argv.index]=nameValue
                end
            end
            return luafunction(table.unpack(args,1,maxIndex))
		end
	end
end

function PARAM(paramIndex,paramName,paramDefaultValue)
    return {index=paramIndex,key=paramName,default=paramDefaultValue}
end

LARG={}
LARG.__index=function (self,key)
    return LARG_IMPLEMENT:new(key)
end

ARG={}
setmetatable(ARG,LARG)

LARG_IMPLEMENT={}
LARG_IMPLEMENT.__index=LARG_IMPLEMENT

function LARG_IMPLEMENT:new(key)
    local obj={key=key}
    setmetatable(obj,self)
    return obj
end

LARG_IMPLEMENT.__call=function(self,value)
    self.value=value
    return self
end

