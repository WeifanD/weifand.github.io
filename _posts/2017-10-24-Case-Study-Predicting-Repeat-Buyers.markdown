---
title: "Case Study - Predicting Repeat Buyers"
layout: post
date: 2017-10-24 11:44
image: /assets/images/markdown.jpg
headerImage: false
tag:
- business
- Vowpal_wabbit
star: true
category: blog
author: WeifanD
description: Markdown summary with different options
---

#### Problem
对于商家来说提前识别回头客是一件集中资源提高新品销售量的头等大事，各大商家为了吸引顾客的二次购买都会实行各种像是促销、优惠券、折扣之类的策略。按理说越了解客户，越知道客户的喜好，越能精准推销，就越能实现券的高使用率，但是在初期预测一个客户的忠诚度其实是一件很困难的事。

本节就是在给定客户历史交易记录的信息预测他是否会再次光顾使用之前提供的券，在机器学习领域里这就是一个很典型的是非二元分类问题。

#### Data
由于原始数据量很大，有500G， 包含上百万条客户的历史交易记录数据transaction，历史商店回顾情况history以及优惠券的各项基本信息offer，为了更方便进行数据处理，需要将研究人数进行减缩。

**Transaction** 
数据结构很简单，就是描述了某个客户某天某次在某家公司的某个商店的购买量以及购买金额。
![Alt text](/assets/images/1508389968931.png)

**Offer** 
数据集显示了此券的商家、使用条件以及折扣力度。

**History** 
数据集包含客户在某个商圈的某家商店购买过几次，是不是一个回头客以及他收到商家的优惠券的时间

#### Preprocessing
在给定的特征基础上，我们extract出了几个会影响the chance of repeat purchace的人工变量：

**Company**
对于某家商场用户历史券使用量、使用额、前30天/60天/90天/180天使用额

**CAT**
对于某个类别用户历史券使用量、使用额、前30天/60天/90天/180天使用额

**Brand**
对于某个品牌用户历史券使用量、使用额、前30天/60天/90天/180天使用额

**Combination**

**Offer**
优惠券的力度与条件

**Shopper**
客户历史总消费

最终特征选取如下：

```
offer_quantity:1 
has_bought_company_a:243.63 
has_bought_brand_180:7.0
has_bought_brand_a_180:23.13 
has_bought_brand_q_180:7.0 
offer_value:2 
has_bought_brand_a_60:14.95 
has_bought_company_q:37.0 
has_bought_brand_q_30:1.0 
has_bought_brand:8.0 
has_bought_company_q_30:6.0 
has_bought_brand_30:1.0 
has_bought_company_q_60:16.0 
has_bought_brand_company:1 
has_bought_brand_90:6.0 
has_bought_company_q_180:19.0 
has_bought_company_30:6.0 
has_bought_brand_a:28.71 
has_bought_company_a_90:106.13 
has_bought_brand_q_90:6.0 
never_bought_category:1 
has_bought_company_180:19.0 
has_bought_brand_q:9.0 
has_bought_company_a_30:46.74 
has_bought_company_q_90:17.0 
has_bought_brand_a_30:4.59 
total_spend:4140.41 
has_bought_company_a_60:100.44 
has_bought_brand_q_60:5.0 
has_bought_company_a_180:113.21 
has_bought_company_60:16.0 
has_bought_brand_60:5.0 
has_bought_company_90:17.0 
has_bought_brand_a_90:20.64 
has_bought_company:36.0
```
#### Model
Vowpal_wabbit 是在单机上速度非常快的机器学习库。

本质原因是vowpal_wabbit采用的是在线学习，也即优化方法采用的是随机梯度下降的方法。相比较batch gradient,online-learnging 的速度快，但是效果可能没有batch-learning好。

在线学习收敛速度慢，在小数据集上表现不佳，但由于不需要将所有的数据集全部加载进来，所以，在单机上也是可以处理海量的数据，一条条数据进行处理在训练的过程中观察收敛情况。但它对样本的顺序敏感，比如在预测点击的数据集中，点击的样本集中在前面，未点击的数据集中在后面，那么学习的效果就会不好。

这里使用的Python版的VW，调参情况如下：

```
-c -k --passes 40 says to use a cache, kill any previous cache and run 40 passes

-l 0.85 sets the learning rate to 0.85

--loss_function quantile says to use quantile regression

--quantile_tau 0.6 is a parameter to tweak when using the quantile loss function.
```

#### Evaluation
由于数据集中有200个客户没有任何使用优惠券的产品交易信息，因而预测结果为0. 总体模型预测结果良好，AUC达到0.69左右。