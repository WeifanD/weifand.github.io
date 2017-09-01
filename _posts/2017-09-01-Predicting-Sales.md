---
title: "Kaggle - 沃尔玛销售预测1"
layout: post
date: 2017-08-21 16:00
image: /assets/images/markdown.jpg
headerImage: false
tags: 
- kaggle
- Predicting
category: blog
author: WeifanD
---

最近小小参与了一下Kaggle2002年的一场比赛，出题方是沃尔玛，题目是对其下45家零售店的销售进行预测。所提供的数据分为两部分，一部分是by store by department by week的销售数据，可以看作是时间序列数据，另一部分是markdown数据，这里可以把它看作影响销售量的特征。最后的评价标准是常用的criteria之一，WMAE，加权均化误差，也就是最后预测值与实际值之间的误差越小越好，WMAE值越小排位越高。

### 数据处理

原始的数据集是一个标准的 tidy dataset，即以行为 observation 列为 variable， 这里由于涉及到时间，结构相对特殊，是 time-store-department-sales 的 variable-value 结构。

![Alt text](/assets/images/1504235354688.png)

为了使时间成为一个unique key，我们需要对数据结构进行初步调整，其基本的概念是循环每一个部门，构造一个门店*时间的矩阵，相当于形成一系列门店的时间序列。
 
已知数据以周为单位，一年总共52周，沃尔玛是以周五为一周的最后一天。对于某些固定周几的假期来说，模型无需做调整。而圣诞节比较特殊，他只有固定日期，而周几却不同，这一点会很大的影响销量落在那一周。比如说2015年圣诞节是在第47周的周五，因而大量的盈利都发生在上个周六到这个周四之间，如预期第47周的销量非常高。那如果落在周六或周日，那他主要销量就会落在前一周。所以为了让销量更合理话，需要进行一个后延操作。如果48-51周的销量超过前后两周的10%，就后延一周；如果模型以去年为基准，后延2/7；由于测试集第一年后延两天，而第二年后延3天，所以如果以前两年为基准，后延2.5/7。


### 模型构建
> 基于R包forcast的现有时间序列模型以及几个原理简单的模型，分别对预测出的结果再进行postprocess操作。

时间序列模型总体基于不同的时间影响因素以及计算方式形成8种不同的模型，如下图。其中time factor包括trend和seasonality，calculation logic包括A（add）以及M（multiply）。
![Alt text](/assets/images/1504152542610.png)

对每个模型做简单的模型函数调用，然后合并。上部分代码：

```{r}
stlf.svd <- function(train, test, model.type, n.comp){
  horizon <- nrow(test)
  train <- preprocess.svd(train, n.comp) 
  for(j in 2:ncol(train)){
    s <- ts(train[, j], frequency=52)
    if(model.type == 'ets'){
      fc <- stlf(s, 
                 h=horizon, 
                 s.window=3, 
                 method='ets',
                 ic='bic', 
                 opt.crit='mae')
    }else if(model.type == 'arima'){
      fc <- stlf(s, 
                 h=horizon, 
                 s.window=3, 
                 method='arima',
                 ic='bic')
    }else{
      stop('Model type must be one of ets or arima.')
    }
    pred <- as.numeric(fc$mean)
    test[, j] <- pred
  }
  test
}

stlf.nn <- function(train, test, method='ets', k, level1, level2){
  horizon <- nrow(test)
  tr <- train[, 2:ncol(train)]
  tr[is.na(tr)] <- 0
  crl <- cor(tr)
  tr.scale <- scale(tr)
  tr.scale[is.na(tr.scale)] <- 0
  raw.pred <- test[, 2:ncol(test)]
  for(j in 1:ncol(tr)){
    s <- ts(tr.scale[, j], frequency=52)
    if(method == 'ets'){
      fc <- stlf(s, 
                 h=horizon, 
                 s.window=3, 
                 method='ets',
                 ic='bic', 
                 opt.crit='mae')
    }else if(method == 'arima'){
      fc <- stlf(s, 
                 h=horizon, 
                 s.window=3, 
                 method='arima',
                 ic='bic')
    }
    raw.pred[, j] <- fc$mean
  }
  for(j in 1:ncol(tr)){
    o <- order(crl[j, ], decreasing=TRUE)
    score <- sort(crl[j, ], decreasing=TRUE)
    if(length(o[score >= level1]) > k){
      top.idx <- o[score >= level1]
    }else{
      top.idx <- o[score >= level2]
      top.idx <- top.idx[1:min(length(top.idx),k)]
    }
    top <- raw.pred[, top.idx]
    if (length(top.idx) > 1){
      pred <- rowMeans(top)
    }else{
      pred <- as.numeric(top)
    }
    pred <- pred * attr(tr.scale, 'scaled:scale')[j]
    pred <- pred + attr(tr.scale, 'scaled:center')[j]
    test[, j + 1] <- pred
  }
  test
}

fourier.arima <- function(train, test, k){
  horizon <- nrow(test)
  for(j in 2:ncol(train)){
    if(sum(is.na(train[, j])) > nrow(train)/3){
      test[, j] <- fallback(train[,j], horizon)
      print(paste('Fallback on store:', names(train)[j]))
    }else{
      # fit arima model
      s <- ts(train[, j], frequency=365/7)
      model <- auto.arima(s, xreg=fourier(s, k), ic='bic', seasonal=FALSE)
      fc <- forecast(model, h=horizon, xreg=fourierf(s, k, horizon))
      test[, j] <- as.numeric(fc$mean)
    }
  }
  test
}
```

