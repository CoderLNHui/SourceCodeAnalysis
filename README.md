## bootstrap『Apple & GitHub』  


>阅读源码，不仅能使我们了解作者的功能实现方式，方便我们运用其功能，快速的fix使用中遇到的bug，更重要的是在阅读优秀源码时体会作者的设计思想和架构设计，具体的技术很快就会过时，优秀的设计思想却会历久弥新，给我们今后编码以很大的借鉴和启迪。向优秀的开源者致敬！向优秀的分享者致敬！
> 
>不管谁的博客上面写的 (也包括自己)，阅读的你要敢于去验证，停止做无意义的 things ; (共勉)@白开水ln。

 



#### Content


>【Apple译文】 


| 『 Apple 』  | 文档 | 译文 \ 博文 |
| :- | :-: | :- |
| 【从 NSURLConnection 到 NSURLSession】   |  [objc.io](https://www.objc.io/issues/5-ios7/from-nsurlconnection-to-nsurlsession/)  |  [github.io](https://githubidea.github.io/AppleTranslation/ConnectionToSession.html) \  |
|  【UIWebView 网页视图】  | [developer](https://developer.apple.com/reference/uikit/uiwebview)   |  [github.io](https://githubidea.github.io/AppleTranslation/UIWebViewApple.html) \ |
|  【UIBezierPath 贝塞尔曲线】  |  [developer](https://developer.apple.com/reference/uikit/uibezierpath?language=objc)  | [github.io](https://githubidea.github.io/AppleTranslation/UIBezierPathApple.html) \  |
| 【UIView 视图】  |  [developer](https://developer.apple.com/reference/uikit/uiview?language=objc)  |  [github.io](https://githubidea.github.io/AppleTranslation/UIViewApple.html) \ |
| 【Runloop 运行循环】  |  [developer](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/Multithreading/RunLoopManagement/RunLoopManagement.html)  |  [Run Loops_译](https://github.com/CustomPBWaters/Apple-GitHub-NewIdea/blob/master/library%26Apple-SourceAnnotation/Apple译文/Run%20Loops.pdf) 、[CFRunLoop.c (c) 2015_源码 ](https://github.com/CustomPBWaters/Framework-Annotations-Tools/blob/master/Framework-Annotations%20%26%20Tools/MyFoundation-Annotations/RunLoop/CFRunLoop.c)、[NSRunLoop.h_源码](https://github.com/CustomPBWaters/Framework-Annotations-Tools/blob/master/Framework-Annotations%20%26%20Tools/MyFoundation-Annotations/RunLoop/NSRunLoop.h) \ [Runloop_博](https://githubidea.github.io/iOSNET/runloop.html) |
| 【Runtime 运行时】  |  [developer](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40008048)  |  [runtime_译](http://blog.csdn.net/liangliang103377/article/details/39007683)、[runtime.h_源码](https://github.com/CustomPBWaters/Framework-Annotations-Tools/tree/master/Framework-Annotations%20%26%20Tools/OtherFrameworks-Annotations/Runtime) \ [Runtime_博](https://githubidea.github.io/iOSNET/runtime.html) |
|  [『 WechatPublic-Codeidea 』](http://upload-images.jianshu.io/upload_images/2230763-8002637133d35e0a.gif?imageMogr2/auto-orient/strip)  |  [...]()  |  [...]()  |
| 【iOS10 NSAppTransportSecurity】  |  [developer](https://developer.apple.com/library/content/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW34)  |  [NSAppTransportSecurity_译](http://www.jianshu.com/p/1ec3fa1ec00f) \ |
| 【Podfile 语法】  |  [cocoapods](https://guides.cocoapods.org/syntax/podfile.html)  |  [Podfile 语法参考_译](http://www.jianshu.com/p/8af475c4f717) \ |
| 【iOS 9设计规范 中文版】  |  [developer](https://developer.apple.com/design/)  |  \  [iOS 9设计规范 中文版 完整版](http://www.jianshu.com/p/fbdd713eb2ce) |
| 【iOS 10设计规范笔记与整理】  |  [--]()  |  \  [IOS10设计规范笔记与整理](http://www.pmcaff.com/article/index/514586365192320?from=label&pmc_param[label_name]=) |
| 【Swift 4 JSON 解析指南】  |  [--]()  | \   [Swift 4 JSON_解析指南](https://bignerdcoding.com/archives/37.html) |
| 【Stack Overflow 2017 开发者调查报告】  |  [stackoverflow.com](https://insights.stackoverflow.com/survey/2017#technology-most-loved-dreaded-and-wanted-languages)  |  [Stack Overflow 2017 开发者调查报告](https://www.oschina.net/news/83164/stack-overflow-developer-survey-results-2017) \ |
| [『 WechatPublic-Codeidea 』](http://upload-images.jianshu.io/upload_images/2230763-8002637133d35e0a.gif?imageMogr2/auto-orient/strip)     |     [...](http://upload-images.jianshu.io/upload_images/2230763-8002637133d35e0a.gif?imageMogr2/auto-orient/strip)   |  [...](http://upload-images.jianshu.io/upload_images/2230763-8002637133d35e0a.gif?imageMogr2/auto-orient/strip)   |
 
 

 
 






***

>【常用优秀三方框架】 

|『 GitHub_OC_Swift 』  | 库原址：向优秀的开源者致敬 ！ | 源码 \ 博文 ：向优秀的分享者致敬 ！|
| :- | :-: | :- |
| 【AFNetworking-3.1.0  网络请求】  |  [GitHub](https://github.com/AFNetworking/AFNetworking)  |  [AFN_源码(续)](https://github.com/CustomPBWaters/Apple-GitHub-NewIdea/tree/master/library%26Apple-SourceAnnotation/AFNetworking-3.1.0-SourceAnnotation) 、[AFN_Tools(续)](https://github.com/CustomPBWaters/Apple-GitHub-NewIdea/tree/master/library%26Apple-SourceAnnotation/AFNetworking-3.1.0-Tools)    \     [AFN 框架结构&内部逻辑处理过程_博](https://githubidea.github.io/SourceAnnotations/AFNLibraryStructure.html)  、 [AFN 到底做了什么？_博](http://www.jianshu.com/p/856f0e26279d) 、[AFN 批量上传图片3种方法_博](http://www.jianshu.com/p/2cb9136c837a) |
| 【SDWebImage-3.7.5 图片下载】  |  [GitHub](https://github.com/rs/SDWebImage)  |  [SD_源码(续)](https://github.com/CustomPBWaters/Apple-GitHub-NewIdea/tree/master/library%26Apple-SourceAnnotation/SDWebImage-3.7.5-SourceAnnotation) 、[SD_Tools(续)](https://github.com/CustomPBWaters/Apple-GitHub-NewIdea/tree/master/library%26Apple-SourceAnnotation/SDWebImage-3.7.5-Tools) \ [SD 框架结构_博](https://githubidea.github.io/SourceAnnotations/SDLibrary.html) |
| 【MJExtension-3.0.13 字典转模型】  |  [GitHub](https://github.com/CoderMJLee/MJExtension)  |  [MJExtension_源码(续)](https://github.com/CustomPBWaters/Apple-GitHub-NewIdea/tree/master/library%26Apple-SourceAnnotation/MJExtension-3.0.13-SourceAnnotation) 、[MJExtension_Tools(续)](https://github.com/CustomPBWaters/Apple-GitHub-NewIdea/tree/master/library%26Apple-SourceAnnotation/MJExtension-3.0.13-Tools)  \  [MJExtension 框架结构_博](https://githubidea.github.io/SourceAnnotations/MJExtensionLibrary.html) |
| 【MJRefresh-3.1.12 刷新】  |  [GitHub](https://github.com/CoderMJLee/MJRefresh)  |  [MJRefresh_源码(续)](https://github.com/CustomPBWaters/Apple-GitHub-NewIdea/tree/master/library%26Apple-SourceAnnotation/MJRefresh-3.1.12-SourceAnnotation)  、[MJRefresh_Tools(续)](https://github.com/CustomPBWaters/Apple-GitHub-NewIdea/tree/master/library%26Apple-SourceAnnotation/MJRefresh-3.1.12-Tools)  \   [MJRefresh 详细使用_博](http://www.jianshu.com/p/4ea427bab0af) 、[MJRefresh_源码解析](http://www.jianshu.com/p/89ca6437c5e9) |
| 【SVProgressHUD-2.1.2 进度提示】  |  [GitHub](https://github.com/SVProgressHUD/SVProgressHUD)  |  [SVProgressHUD_源码(续)](https://github.com/CustomPBWaters/Apple-GitHub-NewIdea/tree/master/library%26Apple-SourceAnnotation/SVProgressHUD-2.1.2-SourceAnnotation)  、[SVProgressHUD_Tools(续)](https://github.com/CustomPBWaters/Apple-GitHub-NewIdea/tree/master/library%26Apple-SourceAnnotation/SVProgressHUD-2.1.2-Tools)  \   []() |
| 【MBProgressHUD- 进度提示】  |  [GitHub](https://github.com/jdg/MBProgressHUD)  |  [MBProgressHUD_源码(续)](https://github.com/CustomPBWaters/Apple-GitHub-NewIdea/tree/master/library%26Apple-SourceAnnotation/MBProgressHUD-1.0.0-SourceAnnotation)  、 [MBProgressHUD_Tools(续)](https://github.com/CustomPBWaters/Apple-GitHub-NewIdea/tree/master/library%26Apple-SourceAnnotation/MBProgressHUD-1.0.0-Tools)   \   []() |
| 【CocoaAsyncSocket 即时通讯】  |  [GitHub](https://github.com/robbiehanson/CocoaAsyncSocket)  |  [CocoaAsyncSocket_源码解析](http://www.jianshu.com/p/0a11b2d0f4ae)   \   []() |
| 【Masonry 约束适配】  |  [GitHub](https://github.com/SnapKit/Masonry)  |  []()   \   [Masonry_详解](http://www.jianshu.com/p/ea74b230c70d)  、[Masonry_技巧使用](https://githubidea.github.io/iOSNET/Masonry.html)  、|
| 【VVeboTableView 优化流畅度】  |  [GitHub](https://github.com/johnil/VVeboTableViewDemo)  |  [VVeboTableView_源码解析](http://www.jianshu.com/p/78027a3a2c41)   \   []() |
|  [『 WechatPublic-Codeidea 』](http://upload-images.jianshu.io/upload_images/2230763-8002637133d35e0a.gif?imageMogr2/auto-orient/strip)  |  [...]()  |  [...]()  |
| 【SwiftyJSON-3.1.4 JSON解析之王】  |  [GitHub](https://github.com/SwiftyJSON/SwiftyJSON)  |  [SwiftyJSON_源码(续)](https://github.com/CustomPBWaters/Apple-GitHub-NewIdea/tree/master/library%26Apple-SourceAnnotation/SwiftyJSON-3.1.4-SourceAnnotation)   、[SwiftyJSON_Tools(续)](https://github.com/CustomPBWaters/Apple-GitHub-NewIdea/tree/master/library%26Apple-SourceAnnotation/SwiftyJSON-3.1.4-Tools) \   [SwiftyJSON_译文](http://www.jianshu.com/p/1c0e6745921e)  、[SwiftyJSON_源码分析](http://blog.csdn.net/brycegao321/article/details/54427639)|
| 【DZNEmptyDataSet-1.8.1 避免空白UITableView】  |  [GitHub](https://github.com/dzenbot/DZNEmptyDataSet)  |  [DZNEmptyDataSet_源码](https://github.com/CustomPBWaters/Apple-GitHub-NewIdea/tree/master/library%26Apple-SourceAnnotation/DZNEmptyDataSet-1.8.1-swift)  \   [DZNEmptyDataSet_空白数据集显示](http://www.jianshu.com/p/f70dc3e0f436)  、[DZNEmptyDataSet源码细节](http://www.jianshu.com/p/8b2db71db449) |
| [『 WechatPublic-Codeidea 』](http://upload-images.jianshu.io/upload_images/2230763-8002637133d35e0a.gif?imageMogr2/auto-orient/strip)     |     [...](http://upload-images.jianshu.io/upload_images/2230763-8002637133d35e0a.gif?imageMogr2/auto-orient/strip)   |  [...](http://upload-images.jianshu.io/upload_images/2230763-8002637133d35e0a.gif?imageMogr2/auto-orient/strip)   |






 



 

 
 




***

>【三方集成 & 授权】 


|『 三方服务 』  | 文档| 博文 |
| :- | :-: | :- |
| 【JPush 极光推送】  |  [集成文档](http://docs.jiguang.cn/jpush/client/iOS/ios_sdk/)  |  [极光博客](http://blog.jiguang.cn/updates-2017-05/)   \   [Xcode8下快速集成并兼顾iOS10](http://www.jianshu.com/p/53e0244e6081) |
| 【UMAnalytics 友盟统计】  |  [集成文档](http://dev.umeng.com/analytics/ios-doc/integration#1_2)  |  [友盟论坛](http://bbs.umeng.com)   \   [集成友盟分享、登录、统计](http://www.jianshu.com/p/ccfa6bb0d17d) |
| 【Alipay 支付宝支付】  |  [新文档中心2017-05-17](https://docs.open.alipay.com/200)  |  []()  |
| 【WeChat 微信支付/登录】  |  [SDK](https://open.weixin.qq.com/cgi-bin/showdocument?action=dir_list&t=resource/res_list&verify=1&id=open1419319164&token=&lang=zh_CN)  |  [第三方登录微信方式实现](http://blog.csdn.net/zhonggaorong/article/details/51719050)   \   []() |
|【一篇文章，教你学会 Git】  | [博文 star1100+](http://www.jianshu.com/p/072587b47515)  | 理解Git的基本原理，掌握常用的一些命令。
  |  | 
|【 git 快速上手】 | [git 快速上手 star700+](http://www.jianshu.com/p/feb6d2e90acd) |  Git 不等于 github大家注意了！git和github就是球和球场的关系！
| [『 WechatPublic-Codeidea 』](http://upload-images.jianshu.io/upload_images/2230763-8002637133d35e0a.gif?imageMogr2/auto-orient/strip)     |     [...](http://upload-images.jianshu.io/upload_images/2230763-8002637133d35e0a.gif?imageMogr2/auto-orient/strip)     | [...](http://upload-images.jianshu.io/upload_images/2230763-8002637133d35e0a.gif?imageMogr2/auto-orient/strip) 





***

>【开源项目源码】WechatPublic-Codeidea

『 GitHub 』  |  简阅
---- | ----
[iOS-Source-Code-Analyze](https://github.com/Draveness/iOS-Source-Code-Analyze)| 收集了优秀的iOS开源框架源代码解析文章，强烈推荐
[open-source-ios-apps](https://github.com/dkhamsing/open-source-ios-apps)  |  iOS开源App集合，分：swift与Objective-C--国外人整理。star14200+
[Yep](https://github.com/CatchChat/Yep)| 社交IM软件YEP，star5000+
[TeamTalk](https://github.com/mogujie/TeamTalk)| 蘑菇街开源IM，star4500+
[MessageDisplayKit](https://github.com/xhzengAIB/MessageDisplayKit)| 类似微信的IMapp，可发送图片，音频，视频，文字，位置信息等，star3800+
[仿网易新闻](https://github.com/dsxNiubility/SXNews)| star3000+
[高仿城觅](https://github.com/ZhongTaoTian/WNXHuntForCity)| star1800+
[YoCelsius](https://github.com/YouXianMing/YoCelsius)| 天气预报的应用，动画和交互非常丰富，star2300+
[v2ex](https://github.com/singro/v2ex)| v2ex.com客户端，star1700+
[高仿微信](https://github.com/gsdios/GSD_WeiXin)| star2000+
[高仿美团](https://github.com/lookingstars/meituan)|  star1500+
[高仿喵播APP](https://github.com/SunLiner/MiaowShow)|  视频直播项目，star2000+
[高仿最美应用](https://github.com/lyimin/beautifulApp)| swift, star800+
[一个](https://github.com/meilbn/MyOne-iOS)|  《一个》 iOS 客户端, star600+
[CocoaChina+](https://github.com/zixun/CocoaChinaPlus)|  开源的第三方CocoaChina移动端, star600+
[高仿百度糯米](https://github.com/lookingstars/nuomi)|  star500+
[Four](https://github.com/SketchK/FOUR)|  一个上线的任务记录app，star300+
[HackerNews-React-Native]()     |   用 React Native 完成的 HackerNews 客户端，star3000+  
[WeChat](https://github.com/zhengwenming/WeChat)     |    实现类似微信朋友圈或者QQ空间，评论回复，九宫格布局。处理键盘弹出后定位到当前点击的被评论人处。star1000+
[iOSAppTemplate](https://github.com/tbl00c/iOSAppTemplate)     |     高仿微信，iOS应用开发模板，star430+
[Bilibili_Wuxianda](https://github.com/MichaelHuyp/Bilibili_Wuxianda)     |  赞 高仿Bilibili客户端 ，  star2100+
[Coding-iOS](https://github.com/Coding/Coding-iOS)     |  Coding iOS 客户端源代码， star2800+
[Voice2Note](https://github.com/liaojinxing/Voice2Note)     |  懒人笔记iOS客户端，   star730+
[Monkey](https://github.com/coderyi/Monkey)     | GitHub第三方iOS客户端，    star1460+
[ChatSecure-iOS](https://github.com/ChatSecure/ChatSecure-iOS)     | Objective-C写的XMPP聊天应用，   star2450+
[FirebaseChat](https://github.com/relatedcode/Messenger)     |  Objective-C写的完整的聊天应用，   star2800+
[Meizi](https://github.com/Sunnyyoung/Meizi)     |   豆瓣妹子图iOS客户端，  star560+
[wikipedia-ios](https://github.com/wikimedia/wikipedia-ios)     | 维基百科官方App, 已上架，    star3000+
[DSLolita](https://github.com/sam408130/DSLolita)     | 模仿新浪微博做的一款app，有发送博文，评论，点赞，私聊功能。    star500+
[XiMaLaYa-by-HansRove](https://github.com/HansRove/XiMaLaYa-by-HansRove-)     | 仿喜马拉雅FM, 对AVFoundation框架的一次尝试，采用MVVM模式，    star0+    
[百思不得姐4.5.6版本高仿](https://github.com/targetcloud/baisibudejie)     |     star200+
[『 WechatPublic-Codeidea 』](http://upload-images.jianshu.io/upload_images/2230763-8002637133d35e0a.gif?imageMogr2/auto-orient/strip)     |     [...](http://upload-images.jianshu.io/upload_images/2230763-8002637133d35e0a.gif?imageMogr2/auto-orient/strip)    
   




 

***

>【学习资源】 


地址  |  简阅
---- | ----
[他人总结各种开源库、开源资料、开源技术文章](https://github.com/Tim9Liu9/TimLiu-iOS#学习资料)  | OS开发常用三方库、插件、知名博客等等，4000多个star
[objc中国](https://objccn.io/)| 为中国 Objective-C 社区带来最佳实践和先进技术
[NSHipster中文版](http://nshipster.cn)| NSHipster 关注被忽略的 Objective-C、Swift 和 Cocoa 特性。每周更新。
[iOS Dev Weekly](http://iosdevweekly.com)| 如果你是老手精通英文，那么这个周刊是非常值得推荐订阅的，该周刊提供行业新闻、最新开发动态、开发工具、代码分享、UI设计、设计师招聘等丰富的资源。
[Shinobicontrols](https://www.shinobicontrols.com/blog)| The latest technical blog posts
[iOS Developer Tips](http://iosdevelopertips.com)| Code, tips and tricks for iOS developers
[Raywenderlich](https://www.raywenderlich.com)| 国外iOS视频教程网站
[trip-to-iOS](https://github.com/Aufree/trip-to-iOS)| 6000多个star的iOS学习资料整理
[SwiftGuide](https://github.com/ipader/SwiftGuide)| 这份指南汇集了Swift语言主流学习资源，接近1W的star
[skill-map](https://github.com/TeamStuQ/skill-map)|  IT技术领域（云计算，大数据，运维，安全，开发语言，智能硬件等）及互联网产品、运营等领域学习技能图谱
[全球移动技术大会2016](http://pan.baidu.com/s/1o8SvZTK)| 全球移动技术大会2016PPT下载合集
[atswift-2016-resources](https://github.com/atConf/atswift-2016-resources)| 2016中国Swift开发者大会源文件，包括keynote, pdf 和源工程文件
[全球移动技术大会2017](http://ppt.geekbang.org/gmtc)| 全球移动技术大会2017PPT下载合集
[iOS10-day-by-day](https://github.com/shinobicontrols/iOS10-day-by-day)| iOS新技术尝试
[WWDC 2017 Videos]() | 我们很高兴地告知您 [WWDC 2017](https://developer.apple.com/videos/wwdc2017/) 视频和 [Developer Insight](https://developer.apple.com/app-store/insights/) (开发者经验分享视频) ，现在皆已配有简体中文字幕。
[Python 核心编程 第二版](https://www.gitbook.com/book/wizardforcel/core-python-2e/details)  | star360+
 [设计模式包教不包会](https://www.gitbook.com/book/wizardforcel/design-pattern-lessons/details)  | star100+
[编程之法：面试和算法心得](https://www.gitbook.com/book/wizardforcel/the-art-of-programming-by-july/details)  | [The-Art-Of-Programming-By-July](https://github.com/julycoding/The-Art-Of-Programming-By-July)，star1100+
[『 WechatPublic-Codeidea 』](http://upload-images.jianshu.io/upload_images/2230763-8002637133d35e0a.gif?imageMogr2/auto-orient/strip)     |     [...](http://upload-images.jianshu.io/upload_images/2230763-8002637133d35e0a.gif?imageMogr2/auto-orient/strip)    


















***

>【优秀Blog】,"同步于": https://github.com/tangqiaoboy/iOSBlogCN


博客地址 | RSS地址
----- | -----
[Plain boiled water](http://plainboiledwaterln.cn) | <http://plainboiledwaterln.cn/atom.xml>
[OneV's Den](http://onevcat.com) | <http://onevcat.com/atom.xml>
[一只魔法师的工坊](http://blog.ibireme.com/) | <http://blog.ibireme.com/feed/>
[破船之家](http://beyondvincent.com) | <http://beyondvincent.com/atom.xml>
[NSHipster](http://nshipster.cn) | <http://nshipster.cn/feed.xml>
[Limboy 无网不剩](http://limboy.me/) | <http://feeds.feedburner.com/lzyy>
[唐巧的技术博客](http://blog.devtang.com) | <http://blog.devtang.com/atom.xml>
[Ted's Homepage](http://wufawei.com/)| <http://wufawei.com/feed>
[sunnyxx的技术博客](http://blog.sunnyxx.com/) | <http://blog.sunnyxx.com/atom.xml>
[Kevin Blog](http://zhowkev.in) | <http://zhowkev.in/rss>
[阿毛的蛋疼地](http://www.xiangwangfeng.com) | <http://www.xiangwangfeng.com/atom.xml>
[亚庆的 Blog](http://billwang1990.github.io) | <http://billwang1990.github.io/atom.xml>
[Nonomori](http://nonomori.farbox.com) | <http://nonomori.farbox.com/feed>
[Wonderffee's Blog](http://wonderffee.github.io) | <http://wonderffee.github.io/atom.xml>
[I'm TualatriX](http://imtx.me) | <http://imtx.me/feed/latest/>
[Cocoabit](http://blog.cocoabit.com) | <http://blog.cocoabit.com/rss/>
[不会开机的男孩](http://studentdeng.github.io) | <http://studentdeng.github.io/atom.xml>
[Nico](http://blog.inico.me) | <http://blog.inico.me/atom.xml>
[阿峰的技术窝窝](http://hufeng825.github.io) | <http://hufeng825.github.io/atom.xml>
[answer_huang](http://answerhuang.duapp.com) | <http://answerhuang.duapp.com/index.php/feed/>
[webfrogs](http://blog.nswebfrog.com/) | <http://blog.nswebfrog.com/feed/>
[代码手工艺人](http://joeyio.com) | <http://joeyio.com/atom.xml>
[Lancy's Blog](http://gracelancy.com) | <http://gracelancy.com/atom.xml>
[I'm Allen](http://www.imallen.com) | <http://www.imallen.com/atom.xml>
[Travis' Blog](http://imi.im/)| <http://imi.im/feed>
[王中周的技术博客](http://wangzz.github.io/) | <http://wangzz.github.io/atom.xml>
[克伟的博客](http://wangkewei.cnblogs.com/) | <http://feed.cnblogs.com/blog/u/23857/rss>
[摇滚诗人](http://cnblogs.com/biosli) | <http://feed.cnblogs.com/blog/u/35410/rss>
[Luke's Homepage](http://geeklu.com/) | <http://geeklu.com/feed/>
[萧宸宇](http://iiiyu.com/) | <http://iiiyu.com/atom.xml>
[Yuan博客](http://www.heyuan110.com/) | <http://www.heyuan110.com/?feed=rss2>
[KooFrank's Blog](http://koofrank.com/) | <http://koofrank.com/rss>
[hello it works](http://helloitworks.com) | <http://helloitworks.com/feed>
[码农人生](http://msching.github.io/) | <http://msching.github.io/atom.xml>
[玉令天下的Blog](http://yulingtianxia.com) | <http://yulingtianxia.com/atom.xml>
[不掏蜂窝的熊](http://www.hotobear.com/) | <http://www.hotobear.com/?feed=rss2>
[猫·仁波切](https://andelf.github.io/) | <https://andelf.github.io/atom.xml>
[煲仔饭](http://ivoryxiong.org/) | <http://ivoryxiong.org/feed.xml>
[里脊串的开发随笔](http://adad184.com) | <http://adad184.com/atom.xml>
[Why's blog - 汪海的实验室](http://blog.callmewhy.com/) | <http://blog.callmewhy.com/atom.xml>
[土土哥的技术Blog](http://tutuge.me/) | <http://tutuge.me/atom.xml>
[庞海礁的个人空间 ](http://www.olinone.com/) | <http://www.olinone.com/?feed=rss2>
[Casa Taloyum](http://casatwy.com/) | <http://casatwy.com/feeds/all.atom.xml>
[Kenshin Cui's Blog](http://www.cnblogs.com/kenshincui/) | <http://www.cnblogs.com/kenshincui/rss>
[技术哥的博客](http://suenblog.duapp.com/) | <http://suenblog.duapp.com/rss/>
[老谭笔记](http://www.tanhao.me/) | <http://www.tanhao.me/atom.xml>
[coderyi](http://www.coderyi.com/)|<http://www.coderyi.com/feed>
[雷纯锋的技术博客](http://blog.leichunfeng.com) | <http://blog.leichunfeng.com/atom.xml>
[向晨宇的技术博客](http://www.iosxxx.com/) | <http://iosxxx.com/atom.xml>
[『 WechatPublic-Codeidea 』](http://upload-images.jianshu.io/upload_images/2230763-8002637133d35e0a.gif?imageMogr2/auto-orient/strip)     |     [...](http://upload-images.jianshu.io/upload_images/2230763-8002637133d35e0a.gif?imageMogr2/auto-orient/strip)    




>未完、每月末(`争取`)、更新 ~


###### 劳驾你点一下❓ [效率工具类\系统文件常用API注解](https://github.com/CustomPBWaters/Framework-Annotations-Tools)





#### Reading


- 如果在阅读过程中遇到 error || new ideas，希望你能 issue 我，我会及时补充谢谢。

- 喜欢可 [赞赏](http://upload-images.jianshu.io/upload_images/2230763-bf7f4af3c678980b.gif?imageMogr2/auto-orient/strip) ，点击右上角的 star 和 watch 按钮，可以收藏本仓库，并在文档、issue、Demo更新时收到邮件通知。