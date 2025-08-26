
# __TEXT - 用于存储只读数据（包括代码和常量）- 程序指令（代码）

__TEXT,__text 是真正存放函数机器码的地方。所有编译后的函数实现（如 C 函数、Objective-C 方法、Swift 函数等）都会被汇编成机器码，最终存储在这里。
所有函数的二进制机器指令（如加法、跳转、函数调用等操作的底层编码）。
函数之间的指令是连续存储的（按符号表中函数的地址顺序排列）。

__TEXT,__stubs - 是通用的动态链接桩，主要用于调用外部动态库（如系统框架）中的函数（不限于 Objective-C）。
__TEXT,__stubs_helper - 包含更复杂的动态链接辅助逻辑，是桩代码与动态链接器之间的中间层。
__TEXT,__objc_stubs - 是专门针对 Objective-C 方法调用 的桩，仅用于 Objective-C 动态消息机制。。
    Objective-C 方法调用是动态的（通过 objc_msgSend 实现），编译期无法确定方法的具体实现地址，需要运行时根据类和方法名查找。
    __objc_stubs__ 的作用是为 Objective-C 方法调用提供一个 “临时跳转点”，简化动态消息发送的过程：


__TEXT,__cstring - 专门用于存储以 null 结尾的 C 风格字符串（即 C string）
__TEXT,__ustring - 是一个用于存储Unicode 字符串的段（section），主要存放以 Unicode 编码（通常是 UTF-16 或 UTF-32）表示的常量字符串，常见于需要处理多语言字符的场景。
__TEXT,__const - 专门用于存储编译期确定的常量数据


__TEXT,__objc_methname - 所有方法的名称都集中存储在这里，是运行时识别和调用方法的基础。
__TEXT,__objc_classname - 所有类和类别的名称都存储在这里，是运行时识别类、进行类操作（如 NSClassFromString）的基础
__TEXT,__objc_methtype - 所有方法的参数和返回值类型信息都存储在这里，是运行时实现动态类型处理和安全调用的基础。


__TEXT,__gcc_except_tab - C++ 的异常处理（如 try/catch 语句）需要在编译时生成额外的元数据，用于在运行时定位异常处理代码（即 catch 块）。作用就是存储这些元数据，帮助程序在抛出异常时快速找到对应的处理逻辑，或在异常未被处理时正确终止程序。


__TEXT,__unwind_info - 包含每个函数的栈帧布局信息（如栈大小、寄存器保存位置）、异常处理入口点等。这些信息以结构化数据形式存在，供系统的异常处理机制（如 libunwind 库）解析。 是 mach-O 平台特有的优化格式
__TEXT,__ehframe - 服务于栈展开 但 __ehframe 更偏向于兼容跨平台的 DWARF 标准
__TEXT,__oslogstring - 存储OSLog 日志的格式化字符串常量，是 iOS/macOS 中系统日志框架（OSLog）专用的字符串段。


// 一、核心类型元数据（描述类型本身的定义与结构）
__TEXT,__swift5_types
    - 包含类、结构体、枚举、协议等所有类型的完整描述：
    - 类型名称（如 User、NetworkManager）
    - 继承关系（如类的父类、结构体是否嵌套）
    - 内存布局（如大小、对齐方式）
    - 关联的方法 / 属性列表指针
__TEXT,__swift5_fieldmd
    记录类 / 结构体 / 枚举中成员变量的信息：
    - 字段名称（如 id、username）
    - 字段类型（如 Int、String?）
    - 访问控制级别（public/private）
    - 在类型内存中的偏移量（用于直接访问内存）
__TEXT,__swift5_mpenum
    针对包含关联值（Associated Values）或递归定义的枚举：
    - 枚举 case 名称（如 .success、.failure）
    - 关联值类型（如 Result<T> 中 T 和 Error 的类型）
    - 内存编码方式（如 tag 位用于区分 case）
__TEXT,__swift5_builtin
    描述标准库内置类型（如 Int、String、Bool、Array）的底层信息：
    - 类型的底层实现（如 Int 的位宽、String 的 UTF-8 存储）
    - 基础操作的关联函数（如 + 运算符的实现指针）

// 二、类型关系与引用（描述类型之间的依赖与关联）
__TEXT,__swift5_typeref
    记录一个类型对其他类型的依赖：
    - 引用的目标类型标识（如 User 中 address: Address 对 Address 的引用）
    - 引用类型（如属性类型、参数类型、返回值类型）
    - 所在模块信息（避免跨模块类型冲突）
__TEXT,__constg_swiftt
    描述全局常量的类型信息：
    - 常量的类型签名（如 let maxCount: Int = 100 中的 Int）
    - 所属模块和访问范围

三、协议相关元数据（支撑协议定义与实现）
__TEXT,__swift5_protos
    记录协议的基础信息：
    - 协议名称（如 Codable、Equatable）
    - 要求的成员（方法、属性、初始化器）
    - 继承的父协议（如 Codable: Encodable & Decodable）
__TEXT,__swift5_assocty
    描述协议中关联类型的约束和实现：
    - 关联类型名称（如 Container.Item）
    - 类型约束（如 where Item: Equatable）
    - 具体类型的映射（如 MyContainer 中 Item 对应 String）
__TEXT,__swift5_proto
    记录 “哪个类型实现了哪个协议”：
    - 类型标识（如 MyStruct）
    - 实现的协议标识（如 Codable）
    - 协议方法的实现指针（关联到 __TEXT,__text 中的代码）

四、反射与调试元数据（支撑类型信息的动态获取）
__TEXT,__swift5_reflstr - 反射用的字符串常量
    存储类型、成员、方法的名称字符串：
    - 类型名（如 "User"、"Result<Int>"）
    - 属性名（如 "id"、"name"）
    - 方法名（如 "encode(to:)"、"append(_:)"）
   
五、闭包相关元数据（支撑闭包的变量捕获）
__TEXT,__swift5_capture
    描述闭包对外部变量的捕获规则：
    - 捕获变量的数量和类型（如 Int、String）
    - 捕获方式（值捕获 / 引用捕获）
    - 变量的生命周期关联（如避免闭包持有导致的循环引用）

六、类型转换元数据（支撑 as?/is 等类型转换操作）
__TEXT,__swift5_as_entry - 类型转换的 “入口” 信息
    记录转换的源类型和目标类型：
    - 源类型标识（如 Any、BaseClass）
    - 目标类型标识（如 DerivedClass、String）
    - 转换的合法性预判断规则
__TEXT,__swift5_as_ret - 类型转换的 “结果” 信息
    记录转换的具体结果：
    - 转换是否合法（布尔标识）
    - 转换后的类型布局（如内存偏移、成员映射）
    - 失败时的错误信息（如类型不兼容的原因）
