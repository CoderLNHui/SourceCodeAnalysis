//
//  other.h
//  MJExtensionExample
//
//  Created by MJ Lee on 15/1/22.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#ifndef MJExtensionExample_other_h
#define MJExtensionExample_other_h


/** 函数的声明（只用于此示例程序，仅仅是为了演示框架的使用） */
void keyValues2object(void);
void keyValues2object1(void);
void keyValues2object2(void);
void keyValues2object3(void);
void keyValues2object4(void);
void keyValuesArray2objectArray(void);
void object2keyValues(void);
void objectArray2keyValuesArray(void);
void coreData(void);
void coding(void);
void replacedKeyFromPropertyName121(void);
void newValueFromOldValue(void);
void logAllProperties(void);
void execute(void (*fn)(void), NSString *comment);

#endif

 

/**

10:37:46.793352+0800 MJExtensionExample[8319:103189] [******************简单的字典 -> 模型******************开始]
10:37:46.810547+0800 MJExtensionExample[8319:103189] name=Jack, icon=lufy.png, age=20, height=1.55, money=100.9, sex=1, gay=1
10:37:46.810751+0800 MJExtensionExample[8319:103189] [******************简单的字典 -> 模型******************结尾]

10:37:46.810868+0800 MJExtensionExample[8319:103189] [******************JSON字符串 -> 模型******************开始]
10:37:46.811514+0800 MJExtensionExample[8319:103189] name=Jack, icon=lufy.png, age=20, height=333333.7
10:37:46.811658+0800 MJExtensionExample[8319:103189] [******************JSON字符串 -> 模型******************结尾]

10:37:46.811810+0800 MJExtensionExample[8319:103189] [******************复杂的字典 -> 模型 (模型里面包含了模型)******************开始]
10:37:46.812705+0800 MJExtensionExample[8319:103189] text=是啊，今天天气确实不错！, name=Jack, icon=lufy.png
10:37:46.812868+0800 MJExtensionExample[8319:103189] text2=今天天气真不错！, name2=Rose, icon2=nami.png
10:37:46.813003+0800 MJExtensionExample[8319:103189] [******************复杂的字典 -> 模型 (模型里面包含了模型)******************结尾]

10:37:46.813169+0800 MJExtensionExample[8319:103189] [******************复杂的字典 -> 模型 (模型的数组属性里面又装着模型)******************开始]
10:37:46.814295+0800 MJExtensionExample[8319:103189] totalNumber=2014, previousCursor=13476589, nextCursor=13476599
10:37:46.814470+0800 MJExtensionExample[8319:103189] text=今天天气真不错！, name=Rose, icon=nami.png
10:37:46.814850+0800 MJExtensionExample[8319:103189] text=明天去旅游了, name=Jack, icon=lufy.png
10:37:46.815104+0800 MJExtensionExample[8319:103189] image=ad01.png, url=http://www.%E5%B0%8F%E7%A0%81%E5%93%A5ad01.com
10:37:46.815277+0800 MJExtensionExample[8319:103189] image=ad02.png, url=http://www.%E5%B0%8F%E7%A0%81%E5%93%A5ad02.com
10:37:46.815539+0800 MJExtensionExample[8319:103189] [******************复杂的字典 -> 模型 (模型的数组属性里面又装着模型)******************结尾]

10:37:46.815705+0800 MJExtensionExample[8319:103189] [******************简单的字典 -> 模型（key替换，比如ID和id，支持多级映射）******************开始]
10:37:46.817504+0800 MJExtensionExample[8319:103189] ID=20, desc=好孩子, otherName=lufy, oldName=kitty, nowName=lufy, nameChangedTime=2013-08-07
10:37:46.817670+0800 MJExtensionExample[8319:103189] bagName=小书包, bagPrice=100.700000
10:37:46.817845+0800 MJExtensionExample[8319:103189] [******************简单的字典 -> 模型（key替换，比如ID和id，支持多级映射）******************结尾]

10:37:46.818092+0800 MJExtensionExample[8319:103189] [******************字典数组 -> 模型数组******************开始]
10:37:46.818365+0800 MJExtensionExample[8319:103189] name=Jack, icon=lufy.png
10:37:46.818505+0800 MJExtensionExample[8319:103189] name=Rose, icon=nami.png
10:37:46.818649+0800 MJExtensionExample[8319:103189] [******************字典数组 -> 模型数组******************结尾]

10:37:46.818822+0800 MJExtensionExample[8319:103189] [******************模型转字典******************开始]
10:37:46.819710+0800 MJExtensionExample[8319:103189] {
    text = "\U4eca\U5929\U7684\U5fc3\U60c5\U4e0d\U9519\Uff01";
    user =     {
        age = 0;
        gay = 0;
        icon = "lufy.png";
        name = Jack;
        sex = 0;
    };
}
10:37:46.819929+0800 MJExtensionExample[8319:103189] {
    text = "\U4eca\U5929\U7684\U5fc3\U60c5\U4e0d\U9519\Uff01";
}
10:37:46.820574+0800 MJExtensionExample[8319:103189] {
    books =     (
                 "Good book",
                 "Red book"
                 );
    desciption = handsome;
    id = 123;
    name =     {
        info =         (
                        "<null>",
                        {
                            nameChangedTime = "2018-09-08";
                        }
                        );
        newName = jack;
        oldName = rose;
    };
    other =     {
        bag =         {
            name = "\U5c0f\U4e66\U5305";
            price = 205;
        };
    };
}
10:37:46.820878+0800 MJExtensionExample[8319:103189] {
    books =     (
                 "Good book",
                 "Red book"
                 );
    desciption = handsome;
    id = 123;
    name =     {
        info =         (
                        "<null>",
                        {
                            nameChangedTime = "2018-09-08";
                        }
                        );
    };
}
10:37:46.821454+0800 MJExtensionExample[8319:103189] {"id":"123","other":{"bag":{"name":"小书包","price":205}},"books":["Good book","Red book"],"name":{"newName":"jack","oldName":"rose","info":[null,{"nameChangedTime":"2018-09-08"}]},"desciption":"handsome"}
10:37:46.821841+0800 MJExtensionExample[8319:103189]
模型转字典时，字典的key参考replacedKeyFromPropertyName等方法:
{
    ID = 123;
    bag =     {
        name = "\U5c0f\U4e66\U5305";
        price = 205;
    };
    books =     (
                 "Good book",
                 "Red book"
                 );
    desc = handsome;
    nameChangedTime = "2018-09-08";
    nowName = jack;
    oldName = rose;
}
10:37:46.821998+0800 MJExtensionExample[8319:103189] [******************模型转字典******************结尾]

10:37:46.822140+0800 MJExtensionExample[8319:103189] [******************模型数组 -> 字典数组******************开始]
10:37:46.822807+0800 MJExtensionExample[8319:103189] (
                                                                 {
                                                                     age = 0;
                                                                     gay = 0;
                                                                     icon = "lufy.png";
                                                                     name = Jack;
                                                                     sex = 0;
                                                                 },
                                                                 {
                                                                     age = 0;
                                                                     gay = 0;
                                                                     icon = "nami.png";
                                                                     name = Rose;
                                                                     sex = 0;
                                                                 }
                                                                 )
10:37:46.823033+0800 MJExtensionExample[8319:103189] [******************模型数组 -> 字典数组******************结尾]

10:37:46.823381+0800 MJExtensionExample[8319:103189] [******************CoreData示例******************开始]
10:37:46.823937+0800 MJExtensionExample[8319:103189] name=Jack, icon=lufy.png, age=20, height=1.55, money=100.9, sex=1, gay=1
10:37:46.824124+0800 MJExtensionExample[8319:103189] [******************CoreData示例******************结尾]

10:37:46.824681+0800 MJExtensionExample[8319:103189] [******************NSCoding示例******************开始]
10:37:46.826849+0800 MJExtensionExample[8319:103189] name=(null), price=200.800000
10:37:46.827046+0800 MJExtensionExample[8319:103189] [******************NSCoding示例******************结尾]

10:37:46.827982+0800 MJExtensionExample[8319:103189] [******************统一转换属性名（比如驼峰转下划线）******************开始]
10:37:46.828863+0800 MJExtensionExample[8319:103189] nickName=旺财, scalePrice=10.500000 runSpeed=100.900000
10:37:46.829026+0800 MJExtensionExample[8319:103189] [******************统一转换属性名（比如驼峰转下划线）******************结尾]

10:37:46.829150+0800 MJExtensionExample[8319:103189] [******************过滤字典的值（比如字符串日期处理为NSDate、字符串nil处理为@）******************开始]
10:37:46.832763+0800 MJExtensionExample[8319:103189] name=5分钟突破iOS开发, publisher=, publishedTime=Sat Sep 10 00:00:00 2011
10:37:46.832929+0800 MJExtensionExample[8319:103189] [******************过滤字典的值（比如字符串日期处理为NSDate、字符串nil处理为@）******************结尾]

10:37:46.833046+0800 MJExtensionExample[8319:103189] [******************使用MJExtensionLog打印模型的所有属性******************开始]
10:37:46.833850+0800 MJExtensionExample[8319:103189] {
    age = 10;
    gay = 0;
    icon = "test.png";
    name = MJ;
    sex = 0;
}
10:37:46.834022+0800 MJExtensionExample[8319:103189] [******************使用MJExtensionLog打印模型的所有属性******************结尾]

 */








