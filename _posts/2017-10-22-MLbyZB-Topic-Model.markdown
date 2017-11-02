---
title: "MLbyZB—Topic Model"
layout: post
date: 2017-10-22 10:44
image: /assets/images/markdown.jpg
headerImage: false
tag:
- topic model
- LDA
star: true
category: blog
author: WeifanD
description: Markdown summary with different options
---

### 词分布和主题分布
梗概：假设有20个主题 k=20，m份文档，训练词料中v=10000，我们能得到每个文档下的主题分布，每个主题下的词分布。

![Alt text](/assets/images/1507551314974.png)

这里用到的是dirichili分布，主要涉及到alpha和beta系数的确定。从公式里可以看出当alpha/beta->0, 第i个词属于第k个主题的可能性=这个词的频率（文档中出现主题的频率）理论上我们希望系数在可解释前提下取越小越好，若太高超参会影响prior。

### LDA
LDA - Latent Dirichlet Allocation
LDA可用来做自然语言中的语义分析或是图像主题分类

![Alt text](/assets/images/1507617311501.png)

- 朴素贝叶斯无法解决一词多义或多词一意的问题，比如大理可以是属于武侠类也可以是旅游类

- 隐变量是无法实际显示的变量，像是扔硬币的分布就是显变量因为结果可见。

- 文本主题和文本聚类？
可以看做是clustering，但是一个无监督的soft clustering

- 主题模型的隐主题和矩阵分解的隐特征？
主题模型可以看做是矩阵分解
![Alt text](/assets/images/1507616621373.png)

![Alt text](/assets/images/1507616650633.png)

- 各种分解简说
QR分解主要用于求特征值，ICA也是个矩阵分解主要用于音频，LDA做推荐会很慢，ICA和LDA的应用场景差不多

### 分布

![Alt text](/assets/images/1507616716008.png)

**Prior分布**
后验概率就是给定样本算的系数theta概率，先验概率就是已知系数概率

![Alt text](/assets/images/1507616818577.png)

进行修正的原因是我们认为参数是符合beta分布的

![Alt text](/assets/images/1507616793650.png)

**联合分布**

![Alt text](/assets/images/1507617371906.png)

**Beta分布**

![Alt text](/assets/images/1507616839091.png)

beta分布可以看做是p的一个函数f(p)，p(1-p)其中极值取0/1，故相当于一个凸函数，alpha和beta系数控制的是曲线的倾向方向，除以B（函数曲线所包含的面积）得到积分为1的概率密度函数。

![Alt text](/assets/images/1507616603775.png)


**Dirichlet分布**
把两元的beta分布通过p1p2 -> p1p2p3p4...推广到多元dirichilet分布

![Alt text](/assets/images/1507617051332.png)

![Alt text](/assets/images/1507617350324.png)

![Alt text](/assets/images/1507616984794.png)

Note: 若我们没有prior info知道diri分布的超参数的分布比例情况，我们可以假使认为他们都相等，则有变量变为标量

![Alt text](/assets/images/1507617021825.png)

**gibbs sampling**
如果你想要了解一个人先去看他的朋友圈。

![Alt text](/assets/images/1507616958239.png)

![Alt text](/assets/images/1507617272240.png)

![Alt text](/assets/images/1507617293810.png)

