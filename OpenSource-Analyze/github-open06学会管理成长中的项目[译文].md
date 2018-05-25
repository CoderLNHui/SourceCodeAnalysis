

## 学会管理成长中的项目

你们的项目正在成长，也有人参与进来，你们承诺保持这样的状态。在这个阶段，你们可能想知道如何将常规项目贡献者纳入你们的工作流程，无论是否给他们提交权限或者解决社区辩论。如果你们有疑问，我们给出了答案。

## 在开源项目中使用正式角色的示例有哪些？

许多项目遵循类似的贡献者角色和认可结构。

这些角色实际上意味着什么，完全取决于你。这里有一些你可能认识的角色类型：

* **Maintainer（维护者）**
* **Contributor（贡献者）**
* **Committer（提交者）**

**对于一些项目来说，"maintainers"**是在项目中有提交权限的人。在其他项目中，他们是作为维护者被名字被列在README中的人。

维护者不一定要是为项目编码的人。他可能是为你们项目的宣传做了很多工作的人，或者是为项目编写文档以方便其他人使用的人。无论他们每天做了什么，维护者是对项目的方向有责任感以及致力于改善项目的人。

**一名"contributor"可以是任何*评论过issue或者pull request的人，给项目带来价值（无论是对issues进行分类，编码，或者组织活动）的人，或者任何合并过pull request的人（可能是贡献者最狭隘的定义）。

<aside markdown="1" class="pquote">
  <img src="https://avatars1.githubusercontent.com/u/579?v=3&s=460" class="pquote-avatar" alt="avatar">
  \[对于Node.js来说，\]项目社区中的每个人都参与评论issue或者提交代码。这意味着他们从用户过度到了贡献者。
  <p markdown="1" class="pquote-credit">
— @mikeal, ["Healthy Open Source"](https://medium.com/the-javascript-collection/healthy-open-source-967fa8be7951)
  </p>
</aside>

**术语"提交者"**可能是用于区分提交权限，它是一个有着明确责任的角色类型，来自其它形式的贡献。

虽然你们可以以任何你们想要的方式定义项目角色，但
[请考虑使用更广泛的定义](https://github.com/liadbiz/opensource-contribute-guide-chinise/blob/master/github-open-source-guide-01.md#贡献是什么意思)来鼓励更多来自其他形式的贡献。你们可以利用管理者的身份认识为项目做出特别贡献的人，不论他们的技能是什么。
<aside markdown="1" class="pquote">
  <img src="https://avatars3.githubusercontent.com/u/21148?v=3&s=460" class="pquote-avatar" alt="avatar">
  你们可能认为我是Django的“发明者”...但事实是当她诞生一年后我才参与这份工作。（...）人们怀疑我成功了，因为我的编程技能...但我最多只是个普通的程序员。
  <p markdown="1" class="pquote-credit">
— @jacobian, ["PyCon 2015 Keynote" (video)](https://www.youtube.com/watch?v=hIJdFxYlEKE#t=5m0s)
  </p>
</aside>

## 我如何正式化这些领导者角色？

正式化你们的领导者角色能够帮助人们有归属感并告诉社区中的其他成员他们可以向谁寻求帮助。

对于小项目来说，指派领导者可以和将他们的名字添加到你们的README或者CONTRIBUTORS的文本文件中一样简单。

对与比较大的项目来说，如果你们有网站，可以创建一个团队网页或者将你们项目的领导者们排列在上面。例如[PostgreSQL](https://github.com/postgres/postgres/)有一个[详细的团队页面](https://www.postgresql.org/community/contributors/)并有每个贡献者的简单信息。

如果你们的项目有个非常活跃的社区，你们可能形成一个维护者的“核心团队”，甚至拥有来自不同issue领域（例如：安全，issue分类或者社区准则）的人组成的小组委员会。让大家自己组织并志愿选择他们喜欢的角色，而不是分配给他们。

<aside markdown="1" class="pquote">
  \[我们\]补充了核心团队和几个“子团队”。每个子团队专注于一个特定领域（如：语言设计或者库）。（。。。）为了整个项目的协作和强大，每个团队的愿景要与整个项目愿景保持一致，每个子团队由一名来自核心团队的成员领导。
  <p markdown="1" class="pquote-credit">
— ["Rust Governance RFC"](https://github.com/rust-lang/rfcs/blob/master/text/1068-rust-governance.md)
  </p>
</aside>

领导者团队可能想要创建一个指定的通道（像IRC）或者定期会面来讨论项目（像Gitter或者Google Hangout）。你们甚至可以组织这样的公开会议以便其他人参与。例如，[Cucumber-ruby](https://github.com/cucumber/cucumber-ruby)的[每周办公时间](https://github.com/cucumber/cucumber-ruby/blob/master/CONTRIBUTING.md#talking-with-other-devs)。

一旦你们建立了领导者角色，请记得以文档的形式记录告诉大家如何联系他们！给大家如何成为你们项目的一名维护者或者仅仅是加入一个子委员会建立一个清晰的流程，并将之写进你们的GOVERNANCE.md中。

有些工具像[Vossibility](https://github.com/icecrime/vossibility-stack)可以帮助你公开跟踪谁给项目了贡献（或者没有）。记录这些信息可以避免社区认为维护者是一个团体，可以私下作出决定。

最后，如果你们的项目在GitHub上，请考虑将你们的项目从个人账号转移到一个组织并添加至少一个备份管理员。[GitHub组织](https://help.github.com/articles/creating-a-new-organization-account/)

## 我什么时候应该给一些人提交权限？

一些人认为你们应该给所有参与贡献的人提交权限。这么做能够让更多的人对项目有归属感。

一方面，特别是对于比较大，很复杂的项目，你们可能只想把提交权给那些已经表示了忠心的人。这种事没什么对错，你们开心就好！

如果你们的项目在GitHub上，你们可以利用[受保护的branches](https://help.github.com/articles/about-protected-branches/)管理谁可以在什么情况下像某个特定的branch进行push。

<aside markdown="1" class="pquote">
  <img src="https://avatars2.githubusercontent.com/u/15000?v=3&s=460" class="pquote-avatar" alt="avatar">
  无论什么时候有人向你们发送一个pull request，请给他们你们项目的提交权限。虽然这听上去非常愚蠢，但是使用这样的策略能够让你们充分利用GitHub的优势。（。。。）一旦大家有了提交权限，他们就 不用再担心他们的补丁没有合并了...造成他们浪费了大量的时间。
  <p markdown="1" class="pquote-credit">
— @felixge, ["The Pull Request Hack"](http://felixge.de/2013/03/11/the-pull-request-hack.html)
  </p>
</aside>

## 开源项目的一些常见治理结构有哪些？

这里有三个与开源项目有关的常见治理结构。

* **BDFL:**SDFL表示”Benevolent Dictator for Life（仁慈的独裁者的生活）”。在这个模式下，只有一个人（通常是项目的作者）对项目的主要决议有最终得决定权。[Python](https://github.com/python)就是一个经典的示例。小项目一般默认是BDFL，因为他们只有一两个维护者。如果是公司的项目可能也会使用这中策略。

* **Meritocracy（精英）:** **(注意：这个术语"meritocracy（精英）"对一些社区来说带有消极的意味，同时用有一个[复杂的社会以及政治历史](http://geekfeminism.wikia.com/wiki/Meritocracy)。)**在精英模式下，活跃的贡献者（展示"价值"的人）被赋予了一个正式的决策者角色。决议通常是通过纯投票的形式抉择。这个权威的概念是由[Apache Foundation](http://www.apache.org/)首创；[所有Apache的项目](http://www.apache.org/index.html#projects-list)都是精英。贡献仅由他们个人提供，而不是公司。

* **Liberal contribution（自由贡献）:**在自由贡献模式下，做最多工作的人被认为是最有影响力的，但是是以现在的当前工作为基准而不是过去的贡献。项目的主要决议都是通过寻求共识的方式得到的，而不是以纯投票的形式，并努力考虑社区中更多的观点。使用自由贡献模式非常流行的示例包括：[Node.js](https://nodejs.org/en/foundation/)和[Rust](https://www.rust-lang.org/en-US/)。

你们应该选择哪种？这取决于你们！每种模式都有有点以及需要权衡之处。虽然咋一看他们有着很大的不同，但是他们的共同点要比看上去的多。如果你们有兴趣采用其中的一种模式，可以浏览这些模板：

* [BDFL model template](http://oss-watch.ac.uk/resources/benevolentdictatorgovernancemodel)
* [Meritocracy model template](http://oss-watch.ac.uk/resources/meritocraticgovernancemodel)
* [Node.js's liberal contribution policy](https://medium.com/the-javascript-collection/healthy-open-source-967fa8be7951#.m9ht26e79)

## 当我的项目启动时我需要编写管理文档吗？

虽然没有合适的时间写下你们项目的管理文档，
但一旦你们看到你门的社区动态表现，它就容易定义了。开源管理的最好（最难的）部分是它是由社区塑造的！

一些早期文档不可避免的是用于你们项目的管理。所以，开始写下你们可以写的。例如，在你们项目启动的时候你们可以清晰地说明期待什么样的行为，或者你们的贡献者如何处理工作。

如果你们是参与公司开源项目启动的成员，在项目发布之前，你们有必要进行内部讨论，了解你们的公司如何保持并决定项目的进展。你们也可以公开解释贵公司将如何（或不会）参与该项目的任何事情。

<aside markdown="1" class="pquote">
  <img src="https://avatars1.githubusercontent.com/u/691109?v=3&s=460" class="pquote-avatar" alt="avatar">  
  我们分配小团队来管理GitHub上的项目，他们实际上在Facebook工作。例如，React是由一位React工程师管理。
  <p markdown="1" class="pquote-credit">
— @caabernathy, ["An inside look at open source at Facebook"](https://opensource.com/life/15/10/ato-interview-christine-abernathy-facebook)
  </p>
</aside>

## 如果公司的员工开始提交贡献会发生什么？

成功大开源项目会被很多人和公司使用，以及甚至有些公司的收入会与这些项目有关。例如，公司可能使用开源项目中大代码作为他们商业服务的一部分。

随着项目被广泛地使用，会需要更多具有专业知识的人，你们可能就是他们中的一个！同时，有时大家在为项目工作时会得到报酬。

重要的是平常心对待商业活动，并且将之视作其他资源发展的动力。当然，不应该区别对待有报酬的开发者和其他无薪酬的；每个贡献都应该根据其技术特点进行评估。然而，大家应该开心地参加商业轰动；同时当争论对项目有利时，大方地陈述他们的用例。

“商业”和“开源”是兼容的。“商业”仅仅是意味着有金钱的参与，软件被用于商业，这有利于项目的发展和推广。（虽然非开源产权中使用了开源软件，但整个产品依然是“专利”软件。开源可以用于商业或者非商业目的。）

和任何人一样，具有商业动机的开发者也是通过他们贡献的质量和数量提高影响力的。很明显，得到报酬的开发者可能会比没有报酬的做的更多，但这是被允许的；金钱只是影响一些人做少事情的很多因素中的一个。让你们的项目讨论侧重于贡献，而不是关注使人们能够做出贡献的外部因素。


## 我需要一个法律顾问来支持我的项目吗？

你们不需要法律顾问来支持你们的开源项目，除非涉及到金钱。

例如，如果你们想创建商业业务，你们将要建立C Crop或者LLC（如果你们位于美国）。如果你们只是做与你们的开源项目相关的合同工作，你可以作为独资经营者接受金钱，或设立一个LLC（如果你在美国）。

如果你们的开源项目想要接受捐赠，你们可以设置一个捐赠按钮（例如使用PayPal或者Stripe,还有中国的支付宝和微信支付），除非您是符合条件的非营利机构（如果您在美国），否则这笔钱不会免税。

很多项目为了省去建立非盈利机构的麻烦而去找一家非营利机构赞助他们。非营利机构代替你们接受捐赠，但你们需要给他一定比例的捐款。[自由软件保护](https://sfconservancy.org/), [Apache基金会](http://www.apache.org/), [Eclipse基金会](https://eclipse.org/org/foundation/), [Linux基金会](https://www.linuxfoundation.org/projects)和[Open Collective](https://opencollective.com/opensource)都是为开源项目提供赞助的组织。


<aside markdown="1" class="pquote">
  <img src="https://avatars2.githubusercontent.com/u/3671070?v=3&s=460" class="pquote-avatar" alt="avatar">
  我们的目的是提供可被商业持续使用的基础设施，因此创造一个每个人（包括贡献者，支持者，赞助者）都能受益的环境。
  <p markdown="1" class="pquote-credit">
— @piamancini, ["Moving beyond the charity framework"](https://medium.com/open-collective/moving-beyond-the-charity-framework-b1191c33141#.vgsbj9um9)
  </p>
</aside>

如果你们的项目与某种特定的语言或者生态系统联系紧密，那么你们可以和与之相关的基金会合作。例如，[Python软件基金会](https://www.python.org/psf/)帮助支持用于管理Python包的[PyPI](https://pypi.python.org/pypi)，[Node.js基金会](https://nodejs.org/en/foundation/)帮助支持一个Node基础框架项目[Express.js](http://expressjs.com/)。
