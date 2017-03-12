---
title: Github开源项目贡献指南-创建一个开源项目[译文]
date: 2017-02-17 22:44:02
tags: github open source guide
---

## 什么是开源，为什么要开源

 那么你正准备拥抱开源吗？恭喜你，开源世界欣赏你的贡献。接下来让我们聊聊什么是开源，我们为什么要开源。

### “开源”意味着什么？


当一个项目开源后，意味着 **不论什么目的，所有人都可以浏览，使用，修改和分发你的项目。** 这些权限都是来自于[开源协议](https://opensource.org/licenses).

开源非常的强大。因为它降低了使用的门槛，使新奇的思想得到快速的传播。

来理解它如何工作，想象下你的朋友正在吃便当，这时你带来了樱桃派。

* 每个人都会想要樱桃派（使用）
* 这个派引起了一场轰动！周围的人会想知道你的烹饪方法（浏览）
* 有一位朋友Alex是一名糕点师，他会建议少放一点糖（修改）
* 另外一位朋友Lisa要求使用它作为下个星期的晚餐（分发）



同样的，闭源就像是你去餐厅必须付钱才能吃樱桃派。但是，餐厅不会告诉你樱桃派的烹饪方法。如果你恰好抄袭了他们的派，并以你自己的名义出售，那么餐厅将会采取行动抵制你。

### 人们为什么要将他们的工作开源？

<aside markdown="1" class="pquote">
  <img src="https://avatars1.githubusercontent.com/u/1500684?v=3&s=460" class="pquote-avatar" alt="avatar">
  我从开源使用和协作中获得的最有价值的经验之一来自我与其他面临许多相同问题的开发者建立的关系。


  <p markdown="1" class="pquote-credit">
— @kentcdodds, [ "How getting into Open Source has been awesome for me"](https://medium.com/@kentcdodds/how-getting-into-open-source-has-been-awesome-for-me-8480cd756a80#.pjt9oqp4w)
  </p>
</aside>

[这里列举了很多理由](http://ben.balter.com/2015/11/23/why-open-source/) 来解释为什么个人或者组织想要开源自己的项目。下面列举了部分：

* **协作:** 开源项目欢迎所有人参与。例如， [Exercism](https://github.com/exercism/)是一个有超过350人协作开发的练习编程的平台。

* **采用和重新混合:**
任何人可以出于几乎任何目的使用开源项目。人们甚至可以将开源项目用于构建其他的项目。例如， [WordPress](https://github.com/WordPress)是基于开源项目 [b2](https://github.com/WordPress/book/blob/master/Content/Part%201/2-b2-cafelog.md)构建的。

* **透明度:** 所有人都可以检查开源项目中存在的问题。透明度对于政府（如 [保加利亚](https://medium.com/@bozhobg/bulgaria-got-a-law-requiring-open-source-98bf626cf70a) 或者 [美国](https://sourcecode.cio.gov/)）, 产业调整（如银行业或者医疗健康行业）, 和软件安全（如 [Let's Encrypt](https://github.com/letsencrypt)）。

 不仅仅是可以开源软件，你可以开源一切，从数据集到书籍。通过浏览 [GitHub Explore](https://github.com/explore) 你可以知道什么东西可以被开源。

### 开源是否意味着免费?

开源最吸引之处就是它不用花钱。然而免费只是开源的价值的一个副产品。

因为 [开源协议要求](https://opensource.org/osd-annotated)开源项目可以被任何人出于几乎任何目的使用，修改和分享，这些项目一般都是免费的。如果有些开源项目需要付费使用，任何人都可以合法地使用其免费版。

结果是大多数开源项目都是免费的。但免费并不属于开源定义的一部分。开源项目可以通过双重许可协议或者其它的方法进行间接收费，同时不违背开源的官方定义。

## 我应该发起属于自己的开源项目吗?

答案是肯定的，因为不论结果是什么，发起一个属于自己的开源项目是学习开源最好的方法。

如果你还没有开源过一个项目，你可能会因为没有人关注或者别人的说辞而紧张。如果真是这样的话，你并不孤独！

开源与其他有创意的活动是一样的，无论是写作还是画画。你可能会害怕向世界分享你的工作，但练习是唯一让你变得更好的方法，即使你没有一位听众。

如果你不确信，那么请花一点时间想想你的目标可能是什么。

### 设定你的目标

目标可以帮助你知道该做什么，不因该说什么和需要从他人那里获得哪些帮助。请开始问自己，_我为什么要开源这个项目？_

这个问题没有一个正确的答案。你可能为一个简单的项目设定了多个目标，或者不同的项目有不同的目标。

如果你唯一的目的是炫耀你的工作，你可能甚至不想将它贡献出去，甚至不会在README中说明。另一方面，如果你想贡献自己的项目，你将会花更多的时间在书写简洁明了的文档上，使新来的参与者感到欢迎。

<aside markdown="1" class="pquote">
  <img src="https://avatars2.githubusercontent.com/u/3520168?v=3&s=460" class="pquote-avatar" alt="avatar">
  在某一时刻，我创建了一个自定义的UIAlertView，并且决定开源。因此我对进行了一些修改使其更加动态灵活，同时上传到GitHub。我编写了一份技术文档以便其他开发者将UIAlertView用于他们的项目中。或许没有人使用这个项目，因为这是一个简单的项目。但是我为自己的贡献感到开心。

  <p markdown="1" class="pquote-credit">
— @mavris, ["Self-taught Software Developers: Why Open Source is important to us"](https://medium.com/rocknnull/self-taught-software-engineers-why-open-source-is-important-to-us-fe2a3473a576#.zhwo5krlq)
  </p>
</aside>

随着你的项目的发展，你的社区可能不仅需要你提供的代码。回复issues，审查代码和传播你的项目在一个开源项目中都是非常重要的任务。

虽然你花费在非编码上的时间取决于项目的规模和范围，但你应准备好作为维护者来自己解决问题或者向他人寻求帮助。


**如果你参与了公司的开源项目，** 确保你的项目拥有它所需要的内部资源。当项目启动后，你会想知道由谁负责维护和在你的社区如何分享这些任务。

如果你需要为项目的宣传，操作和维护准备一笔专用预算或者人员配置，那么尽早开始讨论。

<aside markdown="1" class="pquote">
  <img src="https://avatars2.githubusercontent.com/u/1857993?v=3&s=460" class="pquote-avatar" alt="avatar">  
  一旦你开源项目后，最重要的是你要考虑到项目周围社区的贡献和能力。你不必担心一些不是你公司的贡献者参与到项目的关键部分。
  <p markdown="1" class="pquote-credit">
— @captainsafia, [ "So you wanna open source a project, eh?"](https://writing.safia.rocks/2016/12/06/so-you-wanna-open-source-a-project-eh/)
  </p>
</aside>

### 为其他的项目做贡

如果你的目标是想学习如何与他人一起协作或者了解开源是如何工作的，那么你可以考虑为一个已存在的项目做贡献。开始参与你曾经使用过和喜爱的项目。为项目做贡献就像修改错别字或者更新文档一样简单。

如果你不知道如何开始做一个贡献者，那么可以阅读我们的[Github开源项目贡献指南](https://liadbiz.github.io/)。

## 发起属于你的开源项目

如果没有充足的时间来开源你的工作，你可以开发一个想法，一个正在进行的工作或者多年后将被关闭的资源。

一般来说，当你发现有人对你的工作反馈了一些有建设性的观点后，你应该开源你的项目。

无论你决定开源你项目的哪个阶段，每个项目都应该包含这些文档：

* [opensource license](https://help.github.com/articles/open-source-licensing/#where-does-the-license-live-on-my-repository)
* [README](https://help.github.com/articles/create-a-repo/#commit-your-first-change)
* [opensource guidelines](https://help.github.com/articles/setting-guidelines-for-repository-contributors/)
* [code of conduct](https://github.com/cnbo/open-source-guide/blob/gh-pages/CODE_OF_CONDUCT.md)

作为一名维护者，这些组合将会有助于你表达想法，管理贡献和保护每个人的合法权益（包括你自己的）。他们大大增加了你获得积极经验的机会。

如果你的项目在GitHub上，将这些文件按上面推荐的命名方式放在你的根目录，这样对你的读者会一目了然。

### 选择协议

 开源协议可以保障他人对你的项目进行使用，复制，修改和贡献时不会产生影响。它还保护你免受法律的困扰。**当你发起一个开源项目时必须选择一个协议。**

法律工作很乏味。好消息是你可以在你的仓库中使用一个已经存在的开源协议。这样你只花了很少的时间，但很好的保护了你的工作。

[MIT](https://choosealicense.com/licenses/mit/), [Apache 2.0](https://choosealicense.com/licenses/apache-2.0/), and [GPLv3](https://choosealicense.com/licenses/gpl-3.0/) 都是非常流行的开源协议，但是 还有[其它的开源协议](https://choosealicense.com) 可供你选择。

当你GitHub上创建了一个新项目，你可以选择许可协议。包括可以使你的GitHub项目开源的协议。

![pick a license](https://github.com/cnbo/open-source-guide/blob/gh-pages/assets/images/starting-a-project/repository-license-picker.png)

如果你还有其它的疑问或者与开源项目相关的法律问题，[请来这里](../legal/)。

### 编写README

READMEs不仅解释了如何使用你的项目，他们还解释了你的项目为什么重要，以及用户可以用它做什么。

在你的README中尽量要回答以下的问题：

* 这个项目是做什么的？
* 为什么这个项目有用？
* 我该如何开始?
* 如果我需要使用它，我能从哪里获得更多帮助。

你可以用README去回答其它的问题，像你如何处理贡献，项目的目标是什么，开源协议的相关信息。如果你的项目不想接受贡献，或者你的项目不能用于产品，你就可以将这些写在README中。

<aside markdown="1" class="pquote">
  <img src="https://avatars0.githubusercontent.com/u/168572?v=3&s=460" class="pquote-avatar" alt="avatar">  
  一份好的文档意味着会吸引更多的用户，收到更少的支持请求，得到更多的贡献。（···）请记住你的读者们不是你。参与同一个项目的开发者们有着完全不同的经历。
  <p markdown="1" class="pquote-credit">
— @limedaring, ["Writing So Your Words Are Read (video)"](https://www.youtube.com/watch?v=8LiV759Bje0&list=PLmV2D6sIiX3U03qc-FPXgLFGFkccCEtfv&index=10)
  </p>
</aside>

有时候，人们不会去编写README。因为他们觉得项目还没有完成或者他们不想要贡献。这些都是非常好的为什么要编写README的理由。

为了获得更多的灵感，可以尝试使用 @18F's ["编写可阅读的READMEs"](https://pages.18f.gov/open-source-guide/making-readmes-readable/) 或者 @PurpleBooth's [README 模板](https://gist.github.com/PurpleBooth/109311bb0361f32d87a2)去编写一份README。

当你的根目录中包含README文件后，README就会显示在GitHub仓库的首页上。

### 编写你的贡献指南

一份CONTRIBUTING文件能否告诉你的粉丝如何参与你的项目。例如，文件中可能会包含如下信息：

* 如何报告bug (尽量使用 [issue 和 pull request 目标](https://github.com/blog/2111-issue-and-pull-request-templates))
* 如何提议一个新特性
* 如何建立你的开发环境和运行测试

另外技术清单和一份CONTRIBUTING文件是一个你向贡献者传达你的期望的机会。如：

* 你渴望得到什么类型的贡献
* 项目的发展路线或者期望
* 贡献者应该如何联系你

使用温暖，友好的语气，并提供具体的建议（如写作文档或做一个网站）可以很大程度上让新来者感到欢迎和兴奋参与。


例如，[Active Admin](https://github.com/activeadmin/activeadmin/) starts [its contributing guide](https://github.com/activeadmin/activeadmin/blob/master/CONTRIBUTING.md) with:

> 首先，感谢你考虑为Active Admin做贡献。就是因为有了像您这样的人让Active Admin成为了一个伟大的工具。

在项目的早期，你的CONTRIBUTING文件会比较简单。为了做出贡献，你应该总是解释如何报告bugs或者文件issues和一些技术要求（像测试）。

过了一段时间，你肯会把频繁出现的提问添加到CONTRIBUTING文件中。写下这些信息意味着会有更少的人再重复向你提相同的问题。

想获得更多书写CONTRIBUTING文件的帮助，请查阅 @nayafia's [贡献指南模板](https://github.com/nayafia/contributing-template/blob/master/CONTRIBUTING-template.md) or @mozilla's ["如何创建 CONTRIBUTING.md"](http://mozillascience.github.io/working-open-workshop/contributing/).

 在README中附上CONTRIBUTING文件的链接，这样会让跟多的人看到。如果你 [将CONTRIBUTING文件放在项目的仓库中](https://help.github.com/articles/setting-guidelines-for-repository-contributors/),GitHub会自动链接你的文件当贡献者创建一条issue或者打开一个pull request。

 ![contributing guidelines](https://github.com/cnbo/open-source-guide/blob/gh-pages/assets/images/starting-a-project/Contributing-guidelines.jpg)

### 制定行为规则

<aside markdown="1" class="pquote">
  <img src="https://avatars3.githubusercontent.com/u/11214?v=3&s=460" class="pquote-avatar" alt="avatar">  
  我们有过这样的经历，我们面临什么是滥用，或者作为一名维护者试图解释为什么有些事必须按一定的方式，或者作为一名用户提出简单的问题。(...)
  一份行为规则会变成一份简单的参考和可链接的表示你的团队提出的建设性的话语非常认真的文档。
  <p markdown="1" class="pquote-credit">
— @mlynch, ["Making Open Source a Happier Place"](https://medium.com/ionic-and-the-mobile-web/making-open-source-a-happier-place-3b90d254f5f#.v4qhl7t7v)
  </p>
</aside>

最后，一份行为规则帮助你为你项目的参与者建立了行为准则。如果你为一个社区或者一家公司发起一个开源项目，它是非常有价值的。一份行为规则授权你促成健康，有建设性的社区行为，这回减轻你作为一名维护者的压力。

想获得更多信息，请查阅我们的 [行为规则指南](https://github.com/cnbo/open-source-guide/blob/gh-pages/CODE_OF_CONDUCT.md).

除了沟通如何期望参与者行为之外，行为准则还倾向于描述这些期望适用于谁，何时应用，以及如果违规发生时该做什么。

许多开源协议一般也会为行为规则制定标准，所以你可以不用再编写。这份[贡献者盟约](http://contributor-covenant.org/)  是一份被[超过40,000个开源项目](http://contributor-covenant.org/adopters/)所使用的行为规则，包括 Kubernetes, Rails和Swift。无论你使用哪个文本，在必要的时候你都应该执行你的行为规则。

将文本直接粘贴到你仓库中的CODE_OF_CONDUCT文件中。将文件放在项目的根目录中方便查找，同时在README中添加相应的链接。

## 命名和品牌化你的项目

品牌不仅是一个华丽的logo或者易记的项目名。它还关于你如何谈论你的项目，以及你想把信息传递给谁。

### 选择正确的名字

选择一个容易记住，有创意，能表达项目用意的名字。例如：

* [Sentry](https://github.com/getsentry/sentry) 监控应用程序的崩溃报告
* [Thin](https://github.com/macournoyer/thin) 是一个简单快速的Ruby web服务器。

如果你的项目是基于一个已存在的项目创建，那么使用他们的名字作为你项目名的前缀会帮助你阐述你项目的用途。 (例如 [node-fetch](https://github.com/bitinn/node-fetch)将`window.fetch` 添加到了 Node.js)。

考虑阐明所有。押韵虽然有趣，但是记住玩笑不可能转变成其它的文化，或者他人与你有不同的经历。你的一些潜在用户可能是公司员工，你不能让他们在工作中很难解释你的项目！

### 避免命名冲突

[查看是否有同名的开源项目](http://ivantomic.com/projects/ospnc/)，尤其是你分享的是同样的语言或者生态系统。如果你的名字与一个已存在的知名的项目有冲突，你会让你的粉丝感到困惑。

如果你想要一个网站，Twitter账号或者其他特性来展示你的项目，先确保你能得到你想要的名字。理想情况下，为了美好的未来[现在保留这些名字](https://instantdomainsearch.com/)，即使你现在不想用他们。

确保你的项目名没有侵权。如果有侵权，可能会有公司要求你的项目下架，或者对你采取法律措施。这样得不偿失。

 你可以查阅[WIPO全球品牌数据库](http://www.wipo.int/branddb/en/)避免商标冲突。如果你是在公司工作，[法律团队会帮你做这件事](../legal/)。

最后，去谷歌搜索你的项目名。大家会很容易地找到你的项目吗？在搜索结果礼是否有你不想让大家看到的东西？

### 你的写作（和代码）如何影响你的品牌

在项目的整个生命周期中，你需要做很多文字工作：READMEs，教程，社区文档，回复issues，甚至肯能要处理很多来信和邮件。

是否是官方文档或者一封普通的邮件，你的书写风格都是你项目品牌的一部分。考虑你可能会拥有粉丝，以及这是你想传达的声音。

<aside markdown="1" class="pquote">
  <img src="https://avatars0.githubusercontent.com/u/11321?v=3&s=460" class="pquote-avatar" alt="avatar">
  我尝试处理每一个细节，包括：处理邮件，展示示例，友好待人，认真处理大家的issues以及试图帮助到大家。经过一段时间后，大家可能不再是只问问题，还会帮助我解决其他人的疑问以及给我喜悦，他们模仿我的风格。
  <p markdown="1" class="pquote-credit">
— @janl on [CouchDB](https://github.com/apache/couchdb), ["Sustainable Open Source"](http://writing.jan.io/2015/11/20/sustainable-open-source.html)
  </p>
</aside>

使用热情，通俗易懂的语言（如“他们”，即使是指一个人）能够让新来的贡献者感觉项目非常欢迎他们。使用简单的语言，因为你的读者可能英语不是很好。

除了书写风格外，你的编码风格也是你项目品牌的一部分。 [Angular](https://github.com/johnpapa/angular-styleguide) 和 [jQuery](http://contribute.jquery.org/style-guide/js/)是两个项目代码风格严谨的示例和指南。

当你的项目才开始时，没有必要为项目编写一份风格指南。你可能会发现你喜欢将不同的编码风格融入到项目。但是你应该想到你的书写和编码风格会吸引或者拒绝不同类型的人。项目的早期是你建立你希望看见的先例的机会。

## 你的预发布清单

准备好开源你的项目了吗？有一份帮助检查清单。检查所有内容？你准备开始吧！ [点击 "publish"](https://help.github.com/articles/making-a-private-repository-public/) 以及拍下自己的后背。

**文档**
- 需要为项目指定一个开源协议

- 项目要有基础文档 (README, CONTRIBUTING, CODE_OF_CONDUCT)

- 易记的项目名，指出项目是做什么的，不能和已存在的项目冲突或者商标侵权

- 最新的issue队列，组织和标记清除的issues

**代码**

- 项目使用一致的代码风格和明确的功能/方法/可用的名字

- 注释清晰的代码，记录意图和边缘案例

- 在修改历史，issues或者 pull requests 中没有敏感的信息 (例如 密码或者其他不能公开的信息)


**人**

如果你是代表个人：
-  你已经告诉了你的法律部门，以及/或者理解了你公司（如果你是某一家公司的员工）的开源政策和IP

如果你有一家公司或者组织：

- 你已经告诉了你的法律部门

- 你有一个宣布和促进项目的营销计划

- 一些人被允许管理社区互动（回复issues，检查和合并pull requests）

- 至少有两人管理访问项目



## 你做到了！

恭喜你开源了你的首个项目。不论结果如何，对开源社区都是一份礼物。随着每次commit,comment和pull request，你正在为自己或者他人创造学习和成长的机会。
