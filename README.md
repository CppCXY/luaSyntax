# lua标准语法实现的新语法

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

    * 说明

    ```lua
    __decorator__ 属于元装饰器，定义于namespace中，使用他来声明其他装饰器。

    ```

    * 使用装饰器

    ```lua
    require "namespace"
    require "decorator.TestTime"
    _ENV=namespace "test"
    using_namespace "decorator"

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

    * 放在声明于命名空间中的函数的定义之前，函数就被包装了。
    * 其他装饰器介绍

    ```lua
    __deprecated__(info) 
    --这个装饰器用于当函数被弃用，并且被使用的时候，打印出弃用信息
    ```

    ```lua
    __NamedArgs__(...)
    --这个装饰器修饰函数后函数可以使用具名参数的方式
    --另外在装饰器参数中可以声明默认参数 bool 变量也可以
    --例如
    __NamedArgs__(
        PARAM(1,"people","mayun"),
        PARAM(2,"text","996 is your reward")
    )
    function speak(people,text)
        print(people,text)
    end
    --会得到参数 "mayun" ,"996 is your reward"
    speak()
    --普通调用方式
    speak("laozi","xixixixxixixixi")
    --text会被传入参数 "不行啊"，people使用默认参数"mayun"
    speak(ARG.text("不行啊"))
    --people使用第一个参数，text被传入具名参数
    speak("laozi",ARG.text("hahahaha"))
    ```
    
    PARAM 这是一个函数，第一个参数是对应的参数位置，第二个参数是具名时候的名字，第三个参数是默认值。只能1对1，不能1对多想要1对多自己实现去。

* 目前就写到这里