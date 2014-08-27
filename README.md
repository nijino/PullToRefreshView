HeaderRefreshView
=================

Add a pull-refresh view to a scrollview using just only *one line code*!(using with xib or storyboard)  
只需通过 *一行代码* 给scrollview添加下拉刷新视图。(使用xib或者故事版)  
![refresh-English][refresh-English]
![refresh-Chinese][refresh-Chinese]
##Installation 安装方法
Drop "HeaderRefreshView.h" & "HeaderRefreshView.m" into your project.  
将“HeaderRefreshView.h”和“HeaderRefreshView.m”文件拖拽至工程目录。
##Usage 使用方法
1.through Xib or Storyboard:  
1.通过Xib或故事版:  
Add a UIView Object to your ViewController and change it class name to HeaderRefreshView.  
在你的ViewController中加入一个UIView对象，并且将它的类名改为HeaderRefreshView。  
![Custom class][Custom class]  
Connect a method to HeaderRefreshView object's ValueChanged event.  
连接一个方法到HeaderRefreshView实例的ValueChanged事件。  
![Value Changed Event][Value Changed Event]  
Insert below code in viewDidLoad method of a viewcontroller:  
在viewcontroller的viewDidLoad方法中插入下面代码:  

    [self.tableView addSubview:self.headerRefreshView];

2.through codes:  
2.通过代码:  

    self.headerRefreshView = [HeaderRefreshView new];
    [self.headerRefreshView addTarget:self action:@selector(refreshData:) forControlEvent:UIControlEventValueChanged];
    [self.tableView addSubview:self.headerRefreshView];
##API 提供接口
You can customize normal,release to refresh & refreshing strings with below properies declared in header file:  
你可以通过在头文件里声明的以下属性定制正常、松手立即刷新以及刷新中的字符串：

    @property (nonatomic, copy) NSString * normalString;
    @property (nonatomic, copy) NSString * releaseToRefreshString;
    @property (nonatomic, copy) NSString *loadingString;

Of course you can change these texts color by:  
当然你也可以改变这些文本颜色，通过：
    
    @property (nonatomic) UIColor *textColor;

And as you wish,you can begin & end refresh manually:  
如你所料，可以通过手工开始和结束刷新：
    
    - (void)beginRefreshing;
    - (void)endRefreshing;
##Demo 示例
You can find a demo project in this repository.  
你可以在这个开源库中找到一个示例工程。
##Version History  版本信息
* v1.0.0  
Initial Release.  
初始发布。

##Requirements 系统要求
* iOS >= 6.0
* ARC

## Contact 联系方式
* Tech blog: <http://www.nijino.cn>
* E-mail: nijino_saki@163.com
* Sina Weibo: [@3G杨叫兽][]
* Twitter: [@yangyubin][]
* Facebook: [nijino_saki][]

[refresh-English]:http://ww2.sinaimg.cn/large/540e407ajw1ejovaptjbkg208m0fskaa.gif "refresh-English"
[refresh-Chinese]:http://ww2.sinaimg.cn/large/540e407ajw1ejov8w9j4hg208m0fsnim.gif "refresh-Chinese"
[Custom class]:http://ww2.sinaimg.cn/large/540e407ajw1ejovt10domj2079028a9z.jpg "Change class name to HeaderRefreshView"
[Value Changed Event]:http://ww1.sinaimg.cn/large/540e407ajw1ejow0kuz9aj207506w3yq.jpg "Connect to Value Changed Event"
[@3G杨叫兽]:http://www.weibo.com/nijinosaki "3G杨叫兽"
[@yangyubin]:https://twitter.com/yangyubin "欢迎在twitter上关注我"
[nijino_saki]:http://www.facebook.com/nijinosaki1982 "欢迎在facebook上关注我"
