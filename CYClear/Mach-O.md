
# Mach-O 文件各个段的含义

## Load Commands - 加载命令 存储各个段的信息

## Section（段）：二进制的 “数据单元”

## Dynamic Loader Info - 存储动态加载器（dyld，iOS/macOS 的动态链接器）加载二进制文件所需的全部信息，是 dyld 处理二进制的 “操作手册”。
    Rebase Info
    Binding Info
    Weak Binding Info
    Lazy Binding Info
    Export Info

    
## Function Starts - 存储二进制中所有函数的起始内存地址列表（按地址升序排列）

## Data in Code Entries
    代码段中可能嵌入数据（如跳转表、常量数组），例如：
    C++ 虚函数表（vtable）：存储函数指针的数组，本质是数据，但位于代码段；
    跳转表（jump table）：switch 语句编译后生成的分支地址数组，属于数据。


## Symbol Table
## Dynamic Symbol Table
## String Table
这三者协同工作，负责二进制中 “符号”（函数名、变量名等）的定义、引用和存储，是链接（静态 / 动态）和调试的核心。


## Code Signature


# App 启动流程
dyld 加载二进制时，会按顺序解析 Load Commands：

    通过 LC_SEGMENT_64 映射所有 Segment 到内存，并设置权限；
    通过 LC_LOAD_DYLIB 加载所有依赖的动态库；
    通过 LC_SYMTAB 和 LC_DYSYMTAB 定位符号表和动态链接信息，完成符号绑定；
    通过 LC_MAIN 找到入口点，最终跳转到 main 函数执行。

### iOS 应用的启动流程是一个从用户点击图标到应用完成初始化并进入交互状态的复杂过程，涉及系统内核、动态链接器（dyld）、Objective-C/Swift 运行时（Runtime）以及应用自身代码的协同工作。整个流程可分为 5 大阶段，每个阶段都有明确的职责和关键操作：
### 一、用户触发与系统准备阶段（Pre-main 前的系统层）
当用户点击应用图标时，整个启动流程从系统层开始：
    1.SpringBoard 通知系统
        桌面应用（SpringBoard）是 iOS 的桌面管理器，用户点击图标后，SpringBoard 会通过 IPC（进程间通信）通知系统内核（XNU），请求创建新进程。
    2.内核创建进程（fork）
        内核（XNU）接收到请求后，会执行 fork 系统调用创建一个新的进程（进程 ID 唯一），并为进程分配独立的虚拟内存空间（受 ASLR 保护，地址随机化）。
    3.加载 dyld 到进程
        内核会将应用的可执行文件（Mach-O 格式）映射到进程内存，并找到其依赖的动态链接器 dyld（位于 /usr/lib/dyld），将 dyld 加载到进程的内存空间中，然后把进程的控制权交给 dyld。
### 二、动态链接器（dyld）加载阶段（核心链接过程）
dyld（Dynamic Link Editor）是 iOS 动态链接的核心，负责将应用的可执行文件、依赖的动态库（.dylib/.framework）链接起来，并准备好运行环境。这一阶段是 Pre-main 阶段耗时的主要来源，具体步骤如下：
    1. 加载应用可执行文件与依赖库
        解析 Mach-O 头部：dyld 首先读取应用可执行文件的 Mach-O Header 和 Load Commands（加载命令），确定可执行文件的结构（如段 Segment、段区 Section 的分布）。
        加载依赖库：根据 Load Commands 中的 LC_LOAD_DYLIB 命令，递归加载应用依赖的所有动态库（包括系统库如 UIKit.framework、Foundation.framework，以及第三方库如 Alamofire）。
        优化：系统库通常被打包在 dyld 共享缓存（dyld shared cache）中，这是一个预编译的缓存文件，包含常用系统库，加载时直接映射到内存，避免重复解析，提升速度。
    2. 重定位（Rebase）与绑定（Binding）
        由于 ASLR（地址空间布局随机化），应用和库的实际加载地址与编译时的预期地址不同，需要修正内存中的地址引用：

        Rebase（重定位）：修正内部符号的地址（如应用自身的函数、全局变量）。dyld 根据 Rebase Info 中的记录，遍历所有需要修正的内存位置，将编译时的虚拟地址替换为实际加载后的地址（基于 ASLR 偏移量）。
        Binding（绑定）：修正外部符号的地址（如引用的系统库函数）。dyld 根据 Binding Info 查找外部符号在内存中的实际地址（如 NSLog 在 Foundation 库中的地址），并写入应用中对应的引用位置。
        延迟绑定（Lazy Binding）：非启动必需的符号（如按钮点击事件的处理函数）会推迟到第一次调用时绑定，通过 \_\_stubs 桩函数触发，减少启动耗时。
    3. 执行初始化代码（Initializers）
        所有库加载完成后，dyld 会按 “从低到高” 的依赖顺序（先系统库，后应用库）执行各库的初始化代码：

        C++ 全局构造函数：执行 \_\_cxx_construct 函数，初始化全局 C++ 对象。
        __attribute__((constructor)) 函数：C 语言中标记为构造器的函数，在 main 前执行。
        Objective-C +load 方法：所有类和分类的 +load 方法会被依次调用（按类的加载顺序，先父类后子类，先类后分类）。
        注意：+load 方法在 main 前执行，且不遵循消息转发机制，直接通过函数指针调用，耗时操作会阻塞启动。
### 三、Runtime 初始化阶段（Objective-C/Swift 运行时准备）
dyld 完成链接后，会触发 Objective-C/Swift 运行时（Runtime）的初始化，为面向对象特性（如类、方法、消息发送）提供支撑。
    1. Objective-C Runtime 初始化（libobjc.A.dylib）
        _objc_init 函数：这是 Runtime 的入口函数，由 dyld 在初始化阶段调用，主要工作包括：
        初始化类表（class list）和分类表（category list）。
        注册所有类（_read_images 函数）：解析 __DATA,__objc_classlist 段中的类信息，将类注册到 Runtime，处理类的继承关系、方法列表。
        加载分类（_load_categories）：将分类中的方法、属性合并到主类中（注意：分类方法会覆盖主类同名方法，但不覆盖父类方法）。
        初始化自动释放池（AutoreleasePool）机制、弱引用（weak）管理机制。
        注册 SEL（选择器）和方法缓存（method cache），为消息发送（objc_msgSend）做准备。
    2. Swift Runtime 初始化（libswiftCore.dylib）
        对于 Swift 应用，还会触发 Swift 运行时的初始化：

        解析 \_\_swift5_* 系列段（如 __swift5_types、__swift5_protos），注册 Swift 类型、协议和泛型信息。
        初始化 Swift 特有的内存管理机制（如 ARC 对值类型的处理）和错误处理机制。
### 四、应用入口与主线程启动（main 函数执行）
Runtime 初始化完成后，dyld 会调用应用的 main 函数，进入应用代码的执行阶段：
