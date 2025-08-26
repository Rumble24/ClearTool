# __DATA_CONST - 只读数据段

这些都是 **Mach-O二进制文件格式** 中 `__DATA_CONST` 段（只读数据段）下的具体小节（section），主要用于 macOS、iOS 等 Apple 系统的二进制文件中，用于精细化分类不同类型的只读数据。这些小节承载着程序运行所需的特定常量数据，尤其是与 Objective-C 运行时、动态链接、模块初始化等相关的关键信息。


### 逐一解析：

#### 1. `__DATA_CONST,__got`  
- **全称**：Global Offset Table（全局偏移表）的只读部分  
- **作用**：存储全局变量、函数的偏移地址常量。在动态链接中，GOT 用于记录外部符号（如共享库中的函数/变量）的实际地址，但其中**只读部分**存放的是编译期可确定的固定偏移，不会在运行时被修改。  


#### 2. `__DATA_CONST,__mod_init_func`  
- **全称**：Module Initialization Functions（模块初始化函数）  
- **作用**：存放程序加载（动态链接完成后）时需要自动执行的初始化函数指针列表。例如：  
  - C++ 全局对象的构造函数  
  - `__attribute__((constructor))` 修饰的函数  
- 这些函数指针是只读的（初始化逻辑固定），因此放在 `__DATA_CONST` 中。程序启动时，加载器会按顺序执行这些函数。  


#### 3. `__DATA_CONST,__const`  
- **作用**：存放通用的只读常量数据，是最基础的只读数据小节。例如：  
  - 用 `const` 修饰的全局/静态变量（如 `const int MAX = 100;`）  
  - 编译期确定的常量数组、结构体等  
- 这些数据在程序运行中不允许被修改，否则会触发内存访问错误。  


#### 4. `__DATA_CONST,__cfstring`  
- **全称**：Core Foundation Strings（Core Foundation 字符串）  
- **作用**：存放 `CFStringRef` 类型的常量字符串（Core Foundation 框架的字符串类型）。  
  - `CFString` 是 Apple 系统中跨平台的字符串实现，常量 `CFString` 内容固定，因此放在只读段。  
  - 例如 `CFSTR("hello")` 生成的字符串会存放在这里。  


#### 5. `__DATA_CONST,__objc_classlist`  
- **作用**：存放当前二进制中所有 Objective-C 类（`Class` 类型）的指针列表。  
-  Objective-C 运行时启动时，会扫描该列表来注册类信息（如类的方法、属性等）。由于类结构在编译后固定，指针列表只读，因此放在此处。  


#### 6. `__DATA_CONST,__objc_nlclslist`  
- **全称**：Objective-C Non-Lazy Class List（非懒加载类列表）  
- **作用**：存放需要在程序启动时**立即初始化**的 Objective-C 类指针（而非延迟到首次使用时）。  
  - 通常是一些核心类（如框架中的基础类），需要优先完成初始化，确保运行时可用性。  


#### 7. `__DATA_CONST,__objc_catlist`  
- **全称**：Objective-C Category List（分类列表）  
- **作用**：存放当前二进制中所有 Objective-C 分类（Category）的指针列表。  
  - 分类用于给已存在的类添加方法，其信息在运行时需要被合并到原类中，而分类本身的结构是只读的。  


#### 8. `__DATA_CONST,__objc_nlcatlist`  
- **全称**：Objective-C Non-Lazy Category List（非懒加载分类列表）  
- **作用**：存放需要在程序启动时**立即初始化**的 Objective-C 分类指针，类似 `__objc_nlclslist`，确保核心分类的方法优先被合并到原类中。  


#### 9. `__DATA_CONST,__objc_protolist`  
- **全称**：Objective-C Protocol List（协议列表）  
- **作用**：存放当前二进制中所有 Objective-C 协议（Protocol）的指针列表。  
  - 协议定义了类应实现的方法规范，其结构在编译后固定，因此指针列表放在只读段。运行时会扫描该列表注册协议信息。  


#### 10. `__DATA_CONST,__objc_imageinfo`  
- **全称**：Objective-C Image Information（Objective-C 镜像信息）  
- **作用**：存放当前二进制（称为“镜像”，image）的 Objective-C 相关元数据，例如：  
  - 是否启用 ARC（自动引用计数）  
  - 运行时版本信息  
  - 其他 Objective-C 运行时需要的初始化参数  
- 这些信息是编译期确定的常量，因此放在只读段。  


### 总结  
这些小节都是 `__DATA_CONST` 段（只读数据段）的细分，用于在 Mach-O 格式中精确分类不同类型的只读数据，尤其是：  
- 通用常量（`__const`）  
- 动态链接相关信息（`__got`）  
- 模块初始化逻辑（`__mod_init_func`）  
- Objective-C 运行时核心数据（类、分类、协议等，以 `__objc_` 为前缀）  

它们的“只读”特性确保了数据安全性（防止意外修改），同时也便于系统优化（如将这些数据存储在只读内存页，甚至压缩存储）。这些结构是理解 Apple 平台二进制文件（尤其是 Objective-C/Swift 程序）的关键。
