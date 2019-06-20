# lua标准语法实现的 新语法

* 声明一个命名空间
    ```lua
    require "namespace"

    _ENV=namespace "test"
    
    ```
    1. 声明命名空间之后,所有的定义都会存在于当前命名空间之中
    2. 声明命名空间之后,使用的变量会优先访问当前命名空间中已经定义的对象,然后访问using 过的命名空间中的对象,最后访问_G中的对象
    3. 在一个命名中间中定义的对象,可以通过使用 命名空间.对象名称 的方式引用比如
    ```lua
    --文件 test
    require "namespace"
    _ENV=namespace "test"
    a=123456
    --文件 test2
    require "test"
    --会自动生成在test空间中的test2空间
    _ENV=namespace "test.test2"
    print(test.a) --123456

    ```
* using 命名空间
    ```lua
    --文件test
    require "namespace"
    
    _ENV=namespace "test"
    var=996
    --文件test2
    require "test2"
    _ENV=namespace "test2"
    using_namespace "test"

    print(var) --996

    ```
    1. using 命名空间之后,你可以不加前缀的使用这个空间中的对象
    2. 相同命名空间中的对象不必 using
    3. using_namespace 不是全局变量,只能跟在namespace 声明之后用

* 装饰器
    
    声明一个装饰器
    ```lua
    require "namespace"

    _ENV=namespace "decorator"
    --装饰器也用装饰器来声明
    __decorator__()
    --装饰器的实现和python差不多
    function __TestTime__(params)
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

    ```
    *  说明
    ```lua
    __decorator__ 属于元装饰器，定义于namespace中，使用他来声明其他装饰器。

    ```
    * 使用装饰器
    ```lua
    require "namespace"
    _ENV=namespace "test"
    using_namespace "decorator.TestTime"

    __TestTime__()
    ---@param count number
    function FOR_TEST(count)
        local t={}
        for i=1,count do
            t[i]=i
        end
    end

    FOR_TEST(999999)
    ```
    * 放在 声明于命名空间中的函数的定义之前，函数就被包装了。
* 目前就写到这里