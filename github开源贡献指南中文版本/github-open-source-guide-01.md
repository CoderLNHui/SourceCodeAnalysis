---
title: Github开源项目贡献指南-怎么给开源项目做贡献[译文]
date: 2017-02-17 22:44:02
tags: github open source guide
---

## 为何要给开源项目做贡献？

> 给[freenode]做贡献帮助我学到了很多后来在大学和实际工作中用到的技能，我觉得给开源项目工作对我的帮助和对项目本身的帮助相差无几。

----[@errietta](https://github.com/errietta) [“Why I love contributing to open source software”] 

给开源项目做贡献可以说是在你能想象的领域上学习，传授，累计经验的最有效的方式！为什么人们要给开源项目做贡献，原因太多了！

### 提高现有技能

不管是写代码，用户界面的设计，图形设计，写作，或者是组织，如果你想找点练习做一做，在开源项目上你总能找到能胜任的任务。

### 认识和你有同样爱好的人

气氛融洽开放的开源项目会让人数年之后仍然不忘回来看看（项目进展）。许多人在参与开源项目的过程中结识了一生挚友，友谊在开会的互相照面
和深夜的线上闲聊中渐渐形成。

### 寻找导师或者教导别人

和他人一起合作一个项目意味着你得解释你是怎么做事情的，同时寻求他人的帮助。学习和传授知识的体验对每个参与其中的人来说都是令人愉快的体验。

### 做一个公开的产品帮你赢得声誉（和职业机会）

从开源项目的定义可以知道，你所有的工作成果都应该公开，这意味着你免费获得了一个想众人展示你能力的机会。

### 学习他人的技能

开源项目给参与其中的人们提供了锻炼领导力和管理能力的机会，比如解决冲突，组织团队的成员，辨别工作的轻重缓急。

### 你有权做出改动，就算是很小的

你不需要成为那种一直在给开源做贡献的人。你有在网站上看见手误吗，而且希望有人能修正它。在一个开源项目中，你自己就可以做到。开源帮助人们在生活和
对世界的体验上感觉到更有力量，这本身确实是意见可喜的事情。


## 贡献是什么意思

> 如果你是一个刚刚开始的开源贡献者，这个过程可能会让你觉得很吓人。如何找到正确的项目？你不知道怎么贡献代码怎么办？如果改错了怎么办？

不必担心！有很多参与开源项目的方法，和一些让你走出困境的小技巧。

## 你不需要贡献代码

对开源贡献的一个普遍的误解就是你得贡献代码。实际上，通常和代码无关的部分才是[最容易忽视的](https://github.com/blog/2195-the-shape-of-open-source)。通过参与非代码部分的贡献会给项目带来巨大的帮助。

> 我因为对 [CocoaPods](https://cocoapods.org/)的贡献而著名，但是大部分人都不知道我在这个工具本身的开发上并没有做实质性的工作。我花在这个项目上的主要时间都用来整理文档和宣传品牌。

-----[@orta](https://github.com/orta)

即使你是一个开发者，非代码部分的贡献是一个很好的方式让你参与一个项目和认识社区的成员。建立这种关系会给你从事项目其他部分工作的机会。

> 我第一次接触 Python 开发团队（又叫做 python-dev）是在2002年6月17号我给邮件列表发邮件让他们接受我的补丁的时候。我迅速的发现的这个项目的缺陷，并决定负责组织团队的邮件摘要。这给了我一个很好的机会去询问他们对一个话题的解释，但是实际上更关键的是当有人指出什么的时候我能意识到那是不是需要修复的 bug 。

-----[@brettcannon](https://github.com/brettcannon) 

### 你喜欢策划活动吗?

+ 组织关于项目的研讨会或者线下聚会，就像 [@fzamperin](https://github.com/nodeschool/organizers/issues/406) 
+ 组织项目会议（如果他们有的话）
+ 帮助社区成员找到合适的会议主题并提交一份发言建议。

### 你喜欢设计吗？

+ 重构项目的布局以增加其易用性
+ 组织用户使用调查来重构项目的导航或者菜单
+ 把样式指南放在一起以此来帮助项目有一致的视觉设计
+ 设计 t-shirt 或者 新的logo，就像是[hapijs](https://github.com/hapijs/contrib/issues/68)的贡献者们做的一样

### 你喜欢写作吗？

+ 编写或者改善项目的文档
+ 创建一个文件夹展示项目怎样使用的例子
+ 给项目编写教程，就像[pypa](https://github.com/pypa/python-packaging-user-guide/issues/194)的贡献者们做的一样
+ 为项目的文档做翻译

> 认真的说，[文档]真的是重要得一逼。目前Babel的文档已经很棒了，这也是其杀手锏的特性之一。当然，还有一些章节需要大家的完善，即使是随便在哪儿增加一个段落都很感激。

### 你喜欢组织吗？

+ 连接重复的 issue，或者为某个iuuse添加新的标签来让事情变得井然有序
+ 检查打开的 issue，就像[@nzakas](https://github.com/nzakas)给[eslint做的那样](https://github.com/eslint/eslint/issues/6765)
+ 在最近打开的 issue 中问一些解释性（原文是 [clarifying questions](http://www.chacocanyon.com/pointlookout/090114.shtml)的问题使讨论向前推进

### 你喜欢写代码吗？

+ 找一个 issue 去解决。就像[@dianjin](https://github.com/dianjin)给[Leaflet做的那样](https://github.com/Leaflet/Leaflet/issues/4528#issuecomment-216520560)
+ 询问项目所有者你是否可以帮忙写一个新的功能
+ 使配置项目的过程自动化
+ 改善工具链和测试

### 你喜欢帮助别人吗?

+ 在诸如 [Stack Overflow](http://stackoverflow.com/)（这里有一个关于Postgres[例子](http://stackoverflow.com/questions/18664074/getting-error-peer-authentication-failed-for-user-postgres-when-trying-to-ge), 或者[reddit](https://www.reddit.com/)上回答关于项目的问题
+ 在打开的 issue 中回答人们的问题
+ Help moderate the discussion boards or conversation channels(待翻译)

### 你喜欢帮助改善别人的代码吗?

+ 审查别人提交的代码
+ 写一个关于项目如何使用的教程
+ 帮助其他的贡献者，就像在Rust项目上[@ereichert为@bronzdoc做的那样](https://github.com/rust-lang/book/issues/123#issuecomment-238049666)

### 你不一定只能给软件项目做贡献！

虽然开源一般指的是软件项目，实际上你可以在任何项目上进行协作。有很多书籍，经验贴，列表，课程都是开源项目。
比如：
+ [@sindresorhus](https://github.com/sindresorhus)策划了 [awesome](https://github.com/sindresorhus/awesome) 系列的列表
+ [@h5bp](https://github.com/h5bp)持有一份关于[前端常见面试问题](https://github.com/h5bp/Front-end-Developer-Interview-Questions)的列表
+ [@stuartlynn](https://github.com/stuartlynn) 和 [@nicole-a-tesla](https://github.com/nicole-a-tesla)制作了一份关于[海雀的有趣现象集锦]

即使你不是你个软件工程师，给一个文档性质的项目做贡献也会让你迈进开源世界的大门。在没有代码的项目上做事通常没那么吓人（相比与有代码的项目来说）,而且这个写作的过程会让你积累更多自信和经验。

## 投身于一个新项目

> 如果你打开一个项目的 issue tracker 。里面的东西可能让你觉得不解，不只是你有这样的感觉。这些工具需要很多的隐性知识，但是人们会帮助你搞清楚，你也可以问他们问题。

----[@shaunagm](https://github.com/shaunagm) [“How to Contribute to Open Source”](http://readwrite.com/2014/10/10/open-source-diversity-how-to-contribute/)

对于那种不仅仅是修复一个手误的工作，给开源项目做贡献就像是在一个聚会上走近一群陌生人一样。当他们正在热火朝天的讨论金鱼的时候，你插进去开始讲骆驼,他们会像你投来异样的眼光。
在你带着你的见解盲目的加入讨论之前，首先研究一下他们到底在讨论什么。这样会增加你的观点被注意到和听取的机会。

### 分析一个开源项目

每一个开源社区都不一样。

在一个项目上花费数年的事件会让你对这个项目了如指掌。但是当你迁移到另外一个项目中时，你会发现他们的词汇，规范和讨论的风格完全不一样。

话虽如此，很多开源项目还是遵循一个相似的组织结构。理解不同社区的角色和总体的进程会帮助你很快的融入一个新的项目。

一个经典的开源项目会有这样几类人：
+ 作者： 创建该项目的人或者组织
+ 所有者： 对该组织或者仓库有行政权的人（通常和原始的作者不是一个人）
+ 维护者： 那些负责宣传项目，管理项目组织的贡献者（ 他们也可能是作者或者所有者）
+ 贡献者： 每个给项目做出或多或少贡献的人
+ 社区成员： 使用项目的人。他们可能在关于项目方向上的讨论中积极发表自己的观点

更大型的项目可能有针对不同工作的子社区或者工作组，比如工具链，工作分配，打造社区的舒适度和事件管理。查看项目网站上的“团队”页面，或者存放管理文档的仓库寻找这些信息。

一个项目也会有他自己的文档，这些文件放在项仓库目的一级目录。

+ LISENCE：由于开源项目的定义，每个开源项目都要有一个开源协议。如果一个项目没有一个开源协议，那么他就不是开源项目。
+ README：README文件是给社区的新成员的使用手册。它解释了为什么这个项目是有用的和怎么开始使用这个项目。
+ CONTRIBUTING：READMEj文件是帮助人们使用项目的，而CONTRIBUTING文档是帮助人们对项目做贡献。但是不是每个项目都有CONTRIBUTING文件，那么有这个文件就标志着这是一个开放的项目。
+ CODE_OF_CONDUCT：行动守则制定了参与者行为的基本规则，帮组促进了社区的友好，开放的氛围。但是不是所有项目都有 CODE_OF_CONDUCT 文件，如果有的话那就标志着这是一个开放的项目。
+ Other documentation：还可能有其他的文档，比如教程，预览，或者管理政策，尤其是在大型项目中会出现。

最后，开源项目使用下面这些工具来管理讨论。在你阅读本文的过程中，你会对开源社区思考和工作的方式有一个总体的映像。

+ Issue tracker：人们用来讨论和项目相关的问题的地方
+ Pull requests: 人们用来讨论和审查正在进行中的修改。
+ Discussion forums or mailing lists（论坛或者邮件列表）： 有些项目会用不同的频道对应不同的讨论主题（比如说，“我怎样才能...” 或者 “你们对于...的看法是”，而不是 bug 报告或者功能请求。另外一些项目
直接用 Issue tracker 进行所有话题的讨论。
+ Synchronous chat channel（匿名的聊天频道）：有些项目用聊天频道（比如Slack或者IRC)来进行随意的讨论，合作，或者快速的修改。


## 找一个项目来做贡献

> 现在你一ing知道开源项目是怎么工作的了，是时候找个项目然后开始贡献了！

如果你从来没有给开源项目做过贡献，那么从美国前总统约翰·肯尼迪的名言之中吸取一点建议吧：
> 不要问你的国家能为你做什么，先问问自己你能为自己的国家做什么。

给开源项目做贡献可以发生在任何级别的任何项目。你不需要过分在意你的第一次贡献会是什么，或是以什么形式。

相反，从你已经在用的项目或者你想用的项目开始。你贡献最积极的项目正好是那些你发现你会是不是来看一下的项目。

在那些项目中，尽管释放你的本能，去发现那些你觉得可以做的更好或者做的不同的东西。

开源世界不是一个排他性的俱乐部，它正是有那些像你一样的人创造的。“开源组织”是一个把世界上所有问题看成可以解决的梦幻之地（此处待重译）

你可以浏览一下项目的 README 文档，找找有没有挂掉的链接或者手误。或者你是一个新用户，而且你发现什么了东西不对，或者一个你觉得应该放在文档中的 Issue ，与其直接忽视或者找别人修复它，还不如自己动手把他改过来。这就是开源的含义啦！

> 28%的不固定的贡献者所做的都是在文档上，比如更正手误，重新排版或者提供一种语言的翻译版本。

你还可以用以下的资源来帮助你寻找项目。

+ [GitHub Explore](https://github.com/explore/)
+ [First Timers Only](http://www.firsttimersonly.com/)
+ [Your First PR](https://yourfirstpr.github.io/)
+ [CodeTriage](https://www.codetriage.com/)
+ [24 Pull Requests](https://24pullrequests.com/)
+ [Up For Grabs](http://up-for-grabs.net/#/)

### 一个在你贡献之前的清单

当你发现了一个你想要贡献的项目的时候，对项目做一快速的浏览来保证这个项目适合接受你的贡献，否则你的工作得不到应有的回应。

这里提供了一份评估一个项目是否适合新的贡献者的清单

**检查开源的定义**

<div class="clearfix mb-2">
  <input type="checkbox" id="cbox1" value="checkbox">
  <label for="cbox1" class="overflow-hidden d-block text-normal">他有一份开源协议吗？通常情况下是一个在项目根目录下的叫 LISENCE 的文件。</label>
</div>

**项目接受贡献者的活跃程度**

查看 master 分支上的提交活动。在github上，你可以在仓库的主页上看到这个信息
<div class="clearfix mb-2">
  <input type="checkbox" id="cbox2" class="d-block float-left mt-1 mr-2" value="checkbox">
  <label for="cbox2" class="overflow-hidden d-block text-normal">最近一次提交是什么时候</label>
</div>

<div class="clearfix mb-2">
  <input type="checkbox" id="cbox3" class="d-block float-left mt-1 mr-2" value="checkbox">
  <label for="cbox3" class="overflow-hidden d-block text-normal">
  项目目前有多少贡献者
  </label>
</div>

<div class="clearfix mb-4">
  <input type="checkbox" id="cbox4" class="d-block float-left mt-1 mr-2" value="checkbox">
  <label for="cbox4" class="overflow-hidden d-block text-normal">
  人们提交的频率是怎样的？（在 Github ，你可以通过点击顶部的 "commit" 来找到。 
  </label>
</div>

接下来，查看项目的 issue 。

<div class="clearfix mb-2">
  <input type="checkbox" id="cbox5" class="d-block float-left mt-1 mr-2" value="checkbox">
  <label for="cbox5" class="overflow-hidden d-block text-normal">
    目前有多少 issue 。
  </label>
</div>

<div class="clearfix mb-2">
  <input type="checkbox" id="cbox6" class="d-block float-left mt-1 mr-2" value="checkbox">
  <label for="cbox6" class="overflow-hidden d-block text-normal">
    Do maintainers respond quickly to issues when they are opened?
    项目维护者对打开的 issue 回复的速度如何？
  </label>
</div>

<div class="clearfix mb-2">
  <input type="checkbox" id="cbox7" class="d-block float-left mt-1 mr-2" value="checkbox">
  <label for="cbox7" class="overflow-hidden d-block text-normal">
    在 issue 中的讨论是否热烈。
  </label>
</div>

<div class="clearfix mb-2">
  <input type="checkbox" id="cbox8" class="d-block float-left mt-1 mr-2" value="checkbox">
  <label for="cbox8" class="overflow-hidden d-block text-normal">
    issue 都是在最近的吗？
  </label>
</div>

<div class="clearfix mb-4">
  <input type="checkbox" id="cbox9" class="d-block float-left mt-1 mr-2" value="checkbox">
  <label for="cbox9" class="overflow-hidden d-block text-normal">
    issue 被关闭了吗（在 Github ，在 issue 页面点击 "closed" 标签查看关闭的 issue 。
  </label>
</div>

对项目的 pull request 做同样的检查。

<div class="clearfix mb-2">
  <input type="checkbox" id="cbox10" class="d-block float-left mt-1 mr-2" value="checkbox">
  <label for="cbox8" class="overflow-hidden d-block text-normal">
    目前有多少 pull request？ 
  </label>
</div>

<div class="clearfix mb-2">
  <input type="checkbox" id="cbox20" class="d-block float-left mt-1 mr-2" value="checkbox">
  <label for="cbox20" class="overflow-hidden d-block text-normal">
    项目维护者对打开的 pull request 回复的速度如何？
  </label>
</div>

<div class="clearfix mb-2">
  <input type="checkbox" id="cbox11" class="d-block float-left mt-1 mr-2" value="checkbox">
  <label for="cbox11" class="overflow-hidden d-block text-normal">
    在 pull request 中的讨论是否热烈？
  </label>
</div>

<div class="clearfix mb-2">
  <input type="checkbox" id="cbox12" class="d-block float-left mt-1 mr-2" value="checkbox">
  <label for="cbox12" class="overflow-hidden d-block text-normal">
    pull request 都是最近的吗？
  </label>
</div>

<div class="clearfix mb-4">
  <input type="checkbox" id="cbox13" class="d-block float-left mt-1 mr-2" value="checkbox">
  <label for="cbox13" class="overflow-hidden d-block text-normal">
    最近一次的 pull request 被合并是什么时候？（在 Github ，在 pull request 页面点击 "closed" 标签查看被关闭的 pull request。
  </label>
</div>

**项目是否足够开放**

如果一个项目是友好和开放的那么意味着他们很乐意接受新的贡献者。

<div class="clearfix mb-2">
  <input type="checkbox" id="cbox14" class="d-block float-left mt-1 mr-2" value="checkbox">
  <label for="cbox14" class="overflow-hidden d-block text-normal">
    项目维护者对 issue 中的问题的回复时候有帮助？
  </label>
</div>

<div class="clearfix mb-2">
  <input type="checkbox" id="cbox15" class="d-block float-left mt-1 mr-2" value="checkbox">
  <label for="cbox15" class="overflow-hidden d-block text-normal">
    在 issue ，论坛，聊天室（比如 IRC 或者 Slack）中的人们是不是乐于助人。
  </label>
</div>

<div class="clearfix mb-2">
  <input type="checkbox" id="cbox16" class="d-block float-left mt-1 mr-2" value="checkbox">
  <label for="cbox16" class="overflow-hidden d-block text-normal">
    pull request会被审查吗？
  </label>
</div>

<div class="clearfix mb-4">
  <input type="checkbox" id="cbox17" class="d-block float-left mt-1 mr-2" value="checkbox">
  <label for="cbox17" class="overflow-hidden d-block text-normal">
    项目维护者对贡献者的 pull request 表示感谢了吗？
  </label>
</div>

<aside markdown="1" class="pquote">
  不管何时当你看到核心开发者做出的长篇大论式的，总结性的发言。不放思考他们总结是建设性的吗？而且在保持礼貌的同事一步一步把讨论引向一个结论。如果你看到了讨论过程中出现摩擦，那么让人叹息的是他们把精力浪费在了争吵而不是开发上面。
  <p markdown="1" class="pquote-credit">
— @kfogel, [_Producing OSS_](http://producingoss.com/en/evaluating-oss-projects.html)
  </p>
</aside>

## 如何提交贡献？

假如你已经找到了一个你喜欢的项目，而且你已经准备好做一次贡献。终于！是时候谈谈怎么正确做出贡献啦！

### 高效率的沟通

不管你是一个一次性的贡献者还是想要加入社区，和他人合作是你在参与开源项目过程中会培养的一项重要技能。

<aside markdown="1" class="pquote">
  <img src="https://avatars2.githubusercontent.com/u/7693422?v=3&s=460" class="pquote-avatar" alt="avatar">
  \[作为一个新的贡献者\]，我很快意识到如果我想关掉 issue 的话我得问一些问题。我浏览了一下代码架构，当我对项目有了基本的把握之后，我便询问我下一步该做什么。最后，当我了解了我所需要的所有细节之后，我能够解决那个 issue 了。
  <p markdown="1" class="pquote-credit">
— [@shubheksha](https://github.com/shubheksha), [A Beginner's Very Bumpy Journey Through The World of Open Source](https://medium.freecodecamp.com/a-beginners-very-bumpy-journey-through-the-world-of-open-source-4d108d540b39#.pcswr2e78)
  </p>
</aside>

在你打开一个 issue 或者 发起一个 pull request 或者在聊天室问一个问题之前，把下面这些要点记清楚以此来更好的表达你的想法。

**给出上下文**帮助人们快速了解你提出的东西。如果你遇到了一个问题，解释你想做什么和怎样重重现该问题，如果你是在表达一个新的想法，解释一下为什么你觉得对项目来说这个想法是有用的（而不仅仅是对你而言）

> 😇 _"当我做甲的时候，乙为什么不出现"_
>
> 😢 _"这个啥啥啥出问题了，麻烦修复它"_

**提前做好功课** 无知是没问题的，但是告诉别人你已经尽力了。在寻求帮助之前，一定要先看看 README 文件，文档，issue（开着的关着的都要看），邮件列表，在网上也找一找。当你展示除了一种想要学习的态度的时候别人会很乐意帮助你。

> 😇 _"我不确定怎么实现这个，我查看了帮助文档但是没有找到相关的内容"_
>
> 😢 _"我怎样做才能啥啥啥"_

**保持你的请求简短清晰。**就像是发邮件一样，每一次贡献，不管是多么简单或者多么有帮助，都需要有人审查。很多项目提问的数量远远多于提供帮助的人。保持简洁，你会增加别人帮助你的概率。

> 😇 _"我想写一个 API 使用教程"_
>
> 😢 _"当我有一天下高速加气的时候突然想到了关于我们正在做的事情的一个牛逼的点子，在我解释之前，让我先展示..."_

**保持所有交流都是公开的** 就算私戳项目的维护者是很诱人的，但是除非你要分享一些敏感信息（比如一个有关安全的 issue 或者是严重违反守则的行为，否则就不要这么做。当你让对话保持公开，更多人可以从你们的对话中学到更多。讨论本身也是一种对项目的贡献。

> 😇 _(对于评论)"@-maintainer 你好！我们应该怎么处理这个 PR?"_
>
> 😢 _(对于邮件) "你好, 不好意思通过邮件打扰你，但是我想问一下你是否有时间审查一下我的PR"_

**可以问问题（但是一定要耐心！）** 从某种程度上来说，每个人都是某个项目的新人，即使是对于有经验的贡献者，当他们刚开始接触一个项目的时候也要费点力气。同样，即使是长时间维护项目的人也不是对项目的所有细节都了如指掌。如果你想让他们对你有耐心的话你首先得对他们有耐心。

> 😇 _"麻烦你看一下这个错误。我采取了你的建议！这是输出。"_
>
> 😢 _"为什么你没解决我的问题，这不是你的项目吗？"_

**尊重社区的决定** 你的想法可能和社区优先考虑的事情或者说看问题的视角不一样。他们可能会给你反馈或者拒绝你的想法。然而你应该和他们讨论然后寻求妥协，维护者会比你在决定方向上话费更多时间，如果你不同意他们的方向，你可以一直在你 fork 的仓库上工作，或者自己创建一个新项目。

> 😇 _"你没能支持我想要的特性我很失望，但是就像你解释的那样，它只会对一部分的用户游泳，我知道为什么。感谢你聆听我的建议"_
>
> 😢 _"为啥那么你不支持我的需求呢？这简直没法儿接受！"_

**总之，保持优雅的状态** 开源项目是由来自全世界的协作者一起创造的。这意味着开源协作的背景是多语言，多文化，跨地理位置，跨时间区的。除此之外，用键盘敲出来的文字无法传达音调和情感。所以在交谈中要呈现出善意的一面。礼貌的在一个想法上表达不同看法，或者询问更多细节，表明自己的立场，都是可以的。努力让网络空间变得更美好。

### 收集背景信息

在你做任何事之前，快速检查一下你的想法还没在别处被讨论过。浏览项目的 README 文件，issues（开着的关闭的），邮件列表， Stack Overflow。你不需要话费数小时去浏览所有的信息，但是对一两个关键词的快速搜索也会大有帮助。

如果你在别的地方找不到你的问题，你就可以搞事情了。如果项目是在 Github 上的，以可以通过开 issue 或者发 pull request 和别人交流。

+ **Issues** 就是发起一次交谈或者对话。
+ **Pull requests** 验证某一种解决方案
+ **For lightweight communication**，比如一个 clarifying or how-to question(待翻译)，在 Stack Overflow 上提问， IRC， Slack，或者其他的聊天频道，如果你所在项目有的话。

在你开 issue 或者 pull request 之前，查看项目的贡献文档（通常是一个叫 CONTRIBUTING 的文件，或者就在 README 里面），看看里面有没有你要的信息。举个例子，他们可能会让你遵照一个模板，或者要求你包含一个测试。

如果你想要做做一次比较大的贡献，先开一个 issue 问一下。最好是 watch 这个项目（在 Github 上，[你可以点击 "watch" ](https://help.github.com/articles/watching-repositories/) 这样你可以接受所有对话的通知），然后认识一下社区的成员，因为你的工作并不会被他们接受。
<aside markdown="1" class="pquote">
  <img src="https://avatars2.githubusercontent.com/u/810438?v=3&s=400" class="pquote-avatar" alt="avatar">
  You'll learn <em>a lot</em> from taking a single project you actively use, "watching" it on GitHub and reading every issue and PR.
<p markdown="1" class="pquote-credit">
— @gaearon [on joining projects](https://twitter.com/dan_abramov/status/819555257055322112)
  </p>
</aside>

### 开一个 Issue

在以下的情况你就应该开一个 issue 

* 报告一个你自己解决不了的错误
* 讨论一个高级别的话题或者想法（比如社区，vision（这个自己体会。。），政策）
* 提出一个新功能或者其他的关于项目的想法

在 issue 中交流的小贴士：

+ ** 如果你看到了一个开着的 issue ，而且你想解决他** 在 issue 中评论让人们知道你在尝试解决他，这样别人就不会重复你的工作了。
+ **如果一个 issue 才打开片刻，**有可能这个 issue 别人已经在解决了，或者早就已经搞定了，所以在你开始动手之前在相应 issue 的评论里面问一下比较好。
+ **如果你打开了一个 issue ，但是最后自己解决了，** 在 issue 的评论里面告诉别人，然后关掉这个 issue 。甚至以文档的形式把你的成果展示出来也是对项目的一种贡献。

### 发一个 pull request

在以下的情况下你就可以发一个 PR 了。

+ 提交一个小问题的修复（比如手误，挂掉的链接，或者明显的错误)
+ 准备实现一个早就有人提过的需求，或者是解决在某个 issue 中讨论的问题

一个 pull request 不需要是现在已经搞定了的工作。通常最好是在这之前就发起开一个 pull request ，这样别人可以查看你的工作情况，或者对你现在的进度给予反馈。只要在标题行打上 WIP （正在进行中）的标签就行了。你可以稍后添加更多的信息。

如果项目是在 Github上的话，这里展示了如果提交了个 pull request：

+ **[复刻仓库](https://guides.github.com/activities/forking/)** 然后克隆到本地。通过把它添加到 remote 就把你的本地仓库和远程的“上游”仓库链接起来了。要经常从你的“上游仓库”拉取代码以此来保证同步从而当你提交你的 pull request 的时候，合并冲突就变得更容易了。（从[这里](https://help.github.com/articles/syncing-a-fork/)查看更多教程
+ **[创建分支](https://guides.github.com/introduction/flow/)** 用来编辑代码。
+ **引用任何相关的 issue ** 或者在你的 PR 顺便附上相关信息（比如 "关掉 issue #37"）
+ **包括修改之前和之后的截图** 如果你的改动包含 HTML/CSS 文件。拖放图片到 pull request 的正文。
+ **测试你的改动!** 在你的改动上运行已经存在的测试，有必要的话创建新的测试。不管之前有没有测试，都要保证你的改动不会破坏项目已有的功能。
+ **按照项目的风格改动** 将你的能力发挥到最好。这意味着会使用和你自己仓库不一样的缩进，分好和注释风格。但是这会方便维护者合并，其他人在以后也好理解。

## 当你提交一次贡献的时候发生了什么

你做到了！恭喜成为一个开源贡献者。而我们希望这仅仅是开始！

当你提交你的 PR 之后，可能会发生以下几种情况。

### 😭 你并没有得到回应

在你做贡献之前你还满怀希望的检查了标志项目活跃的[要求](#a-checklist-before-you-contribute)。即使是一个活跃的项目，然后还是有可能你的贡献得不到回应。

如果你在一周之内都没有得到回应，你可以有礼貌的找别人帮你审查。如果你知道帮你审查贡献的合适人选的名字，你可以@他们。

**不要**私戳那个人；要时刻记住公开交流对开源项目来说是必要的。

如果这样还没人理你，那么就可能不会有人理你了，永远。这让人感到不爽，但是别因为这打击到你。每个人都可能会遇到这种情况！你没得到回复的原因有很多，包括你不能控制的私人原因。尝试着找另外一个项目做贡献。总之，在社区其他人还没参与和相应进来的时候你就不要话太多的事情在某个问题上面。

### 🚧  有人想改动你的PR

被要求改动你的贡献是很常见的，要么是对你的想法，要么是对你的代码。

当有人想改动你的PR的时候，务必回复！因为他们花时间审查了你的代码。你开个PR就跑路是不好的！如果你不知道怎么改，好好研究一下问题所在，如果需要的话可以寻求帮助

如果你没时间再搞某个 issue 了（举个例子，如果对话已经过去数月了，而且你的情况也有所改变），让维护者知道从而他们就不会等着你的反馈了。可能另外某个人会开心的接手你的工作。

### 👎 你的贡献被拒绝了

到最后你的贡献不一定会被接受。如果你也没在这上面花太多功夫那是最好，如果你不确定为什么没有接受，你有完美的理由去询问维护者给你反馈和解释。不要争吵或者怀恨在心。如果你不认同它的看法你大可 fork 一份搞自己的版本。

### 🎉 你的贡献被接受了！

万岁！你已经完成了一个开源贡献！

## 你做到了！

不管你是已经完成了你的第一个开源贡献还是在寻找贡献的新途径，我们都希望你可以立即行动起来。即使你的贡献可能不会被接受，但是不要忘记当维护者花时间帮助你的时候要说声谢谢。开源世界就是由无数像你这样的人创造的：一个 issue ，pull request，评论和每一次的庆祝。



