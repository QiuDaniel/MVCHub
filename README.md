# MVCHub

MVCHub是GitHub的iOS移动客户端，使用了MVC的架构模式，同时使用了[ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa)、[Mantle](https://github.com/MantleFramework/Mantle)、[octokit.objc](https://github.com/octokit/octokit.objc)、[Masonry](https://github.com/SnapKit/Masonry)等非常优秀的第三方框架.

# Purpose

首先在这里要感谢[MVVMReactiveCocoa](https://github.com/leichunfeng/MVVMReactiveCocoa)这个开源项目，当初是抱着学习MVVM模式及ReactiveCocoa的目的去看了它的源码，到目前为止只领略到MVVM的一点皮毛。由于之前在公司开发一直使用MVC的模式，自己现在又有比较多的空余时间，于是就在MVVMReactiveCocoa这个项目的基础上进行了MVC模式的改造，便诞生了MVCHub这个开源项目。
其次要感谢[Coding-iOS](https://github.com/Coding/Coding-iOS)这个开源项目，我个人认为这是一个比较好的MVC架构的开源项目，适合初、中级iOS开发人员学习，我自己就在这个开源项目里学到了很多知识。同时，这个开源项目里的一些好用的Category类也被使用在了MVCHub这个项目里。当然这个开源项目的最终目的是能够给一些想学习iOS开发的和初级iOS开发人员一些帮助。

# Requirements

- iOS 8.0+
- CocoaPods 1.0+

# Architectural

####对项目的目录结构做大致的介绍:

    .
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

####项目的启动流程：
在AppDelegate的启动方法中，设置了Appearance的样式、FMDB、网络状态以及友盟分享，然后根据用户的登录状态来选择加载登录页面LoginViewController，还是登录后的RootViewController页面。

RootTabViewController继承自第三方库[RDVTabBarController](https://github.com/robbdimitrov/RDVTabBarController)。在RootTabViewController里面依次加载了News_RootViewController、Repositories_RootViewController、Explore_RootViewController、Profile_RootViewController四个RootViewController，后续的页面跳转都是基于这几个RootViewController引过去的。

####其他：
- MVCHubAPIManager：基本上app的所有请求接口都放在了这里。对[octokit.objc](https://github.com/octokit/octokit.objc)提供的接口做了初步的封装，与服务器之间的数据交互格式用的都是json。
- TODO：会根据[octokit.objc](https://github.com/octokit/octokit.objc)提供的接口完善其他的功能。

#License

Coding is available under the MIT license. See the LICENSE file for more info.