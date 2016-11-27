# MVCHub
App For GitHub

先介绍一下项目文件里的目录大致情况:

├── MVCHub

│   ├── Models：数据类

│   ├── Views：视图类

│   │   ├── Cells：所有的TableViewCell和CollectionViewCell都在这里

│   │   ├── HeaderView：所有的TableView和CollectionView的Header都在这里

│   │   ├── Button：自定义的Button放在这里

│   │   └── XXX：其他的一些自定义View

│   ├── Controllers：控制器，对应app中的各个页面

│   │   ├── Login：登录页面

│   │   ├── RootControllers：登录后的根页面

│   │   ├── BaseControllers:基本类，几乎所有的Controller都继承自这个文件夹里的

│   │   ├── News：News模块下的所有页面

│   │   ├── Repositories：Repositories模块下的所有页面

│   │   ├── Explore：Explore模块下的所有页面

│   │   └── Profile：Profile模块下的所有页面

│   ├── Images：app中用到的所有的图片都在这里

│   ├── Resources：资源文件，包括JSON、SQL以及bundle文件

│   ├── Util：一些常用控件和Category、Manager之类

│   │   ├── Common

│   │   ├── Manager

│   │   ├── OC_Category

│   │   └── ObjcRuntime

│   └── Vendor：用到的一些第三方类库

│       ├── AutoSlideScrollView

│       ├── SMPageControl

│       ├── RKSwipeBetweenViewControllers

│       ├── YLGIFImage

│       ├── NSDate+Helper

│       ├── JDStatusBarNotification

│       ├── MJPhotoBrowser

│       ├── Vertigo

│       └── RDVTabBarController

└── Pods：项目使用了[CocoaPods]这个类库管理工具
