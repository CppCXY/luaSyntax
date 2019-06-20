
local string_gsub=string.gsub
--这种实现是有问题，但是性能较好
local function split(str,sep)
    local rt= {}
    local size=1
    string_gsub(str, '[^'..sep..']+', function(w) rt[size]=w size=size+1 end )
    return rt
end

--加速访问
local accelarateAccess=function(nstable,key,value)
    if  type(value)=="function" or type(value)=="table" then
        rawset(nstable,key,value)
    end
end
local clearAccelarate=function(nstable,key)
    rawset(nstable,key,nil)
end

local __nsIndex=function (self,key )
    local meta=self.__metaTable
    local res=rawget(meta,key)
    if res~=nil then 
        accelarateAccess(self,key,res)
        return res 
    end
    local localNamespace=meta.__nsTable
    local globalNamespace=_G
    --优先保证本地命名空间变量先获取
    local res=rawget(localNamespace,key)
    if res~=nil then 
        accelarateAccess(self,key,res)
        return res 
    end
    --然后保证using过的命名空间获取
    for _,using_table in pairs(meta.__usingtable) do
        local res=rawget(using_table,key)
        if res~=nil then 
            accelarateAccess(self,key,res) 
            return res 
        end
    end

    local res=rawget(globalNamespace,key)
    if res~=nil then 
        accelarateAccess(self,key,res) 
        return res 
    end
    
    return nil
end
--装饰器表
local decorator={value=nil}

local __nsNewIndex=function(self,key,value)
    local meta=self.__metaTable
    local localNamespace=meta.__nsTable
    local mydecorator=decorator.value
    rawset(localNamespace,key,
    mydecorator
    and 
    mydecorator(value,key) 
    or
    value)
    clearAccelarate(self,key)
    decorator.value=nil
end



local namespace_function_table={} 
local using_namespace
local __decorator__impletment
local function namespace(nsName)
    nsName=nsName or "_G"
    local names=split(nsName,".")
    local index=1
    local lastNs=_G
    while(names[index]~=nil) do
        local name=names[index]
        if  rawget(lastNs,name)==nil then
            local ns={}
            rawset(lastNs,name,ns)
            lastNs=ns
        else
            lastNs=rawget(lastNs,name)
        end
        index=index+1
    end

    local newNs={}

    local meta={}
    newNs.__metaTable=meta
    
    meta.__index=__nsIndex
    meta.__newindex=__nsNewIndex
    --新空间使用弱表
    meta.__mode="kv"

    meta.__nsTable=lastNs
    meta.__usingtable={}
    --引用using
    meta.using_namespace=function (nsName)
        using_namespace(newNs,nsName)
    end
    
    meta.__decorator__=function()
        decorator.value=__decorator__impletment
    end

    for key,value in pairs(namespace_function_table) do
        rawset(meta,key,function (...)
            return value(...,newNs,nsName)
        end)
    end

    setmetatable(newNs,meta)
    if  lastNs.__nsName==nil then
        lastNs.__nsName=nsName
    end

    if _VERSION =="Lua 5.1" then
        setfenv(2,newNs)
    end
    
    return  newNs
end

rawset(_G,"namespace",namespace)
rawset(_G,"__nsName","_G")

local function namespace_register(name,luaf)
    namespace_function_table[name]=luaf
end
rawset(_G,"namespace_register",namespace_register)
using_namespace=function(nsTable,nsName)
    local names=split(nsName,".")
    local index=1
    local __lastNs=_G
    while(names[index]~=nil) do
        local name=names[index]
        if rawget(__lastNs,name)==nil then
            local ns={}
            rawset(__lastNs,name,ns)
            __lastNs=ns
        else
            __lastNs=rawget(__lastNs,name)
        end
        index=index+1
    end
    local meta=getmetatable(nsTable)
    local using_table=meta.__usingtable
    using_table[nsName]=__lastNs
end

__decorator__impletment=function(newDecorator)
    return function(...)
        decorator.value=newDecorator(...)
    end
end


