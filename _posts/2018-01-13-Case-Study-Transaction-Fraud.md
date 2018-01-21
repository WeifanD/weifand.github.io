---
title: "Case Study - Sales Transaction Fraud"
layout: post
date: 2018-01-13 12:17
image: /assets/images/markdown.jpg
headerImage: false
tag:
- Case Study
- Web
category: blog
author: WeifanD
output:
  html_document:
    number_sections: true
    toc: true
    fig_width: 7
    fig_height: 4.5
    theme: cosmo
    highlight: tango
    #code_folding: hide
---




## Introduction
欺诈行为是各行业都会遇到的风险，直接关系到企业的运营与营收。“欺诈”一词在汉语中，是指用狡猾奸诈的手段骗人。《战国策·燕策二》：“齐田单欺诈骑劫，卒败燕军，复收七十城以复齐。”《汉书·西域传下·车师后国》：“其后莽复欺诈单于，和亲遂绝。”宋苏澈《论衙前及诸役人不便札子》：“盖定差乡户人有家业，欺诈逃亡之弊，比之雇募浮浪，其势必少”。

欺诈的表现形式多样。在民间信贷领域，通过虚假个人信息与社会关系从而骗取贷款的行为称为信贷欺诈；在企业广告渠道合作环节，通过科技手段制造虚假点击行为获得黑色营收称为点击欺诈；在线下销售场景中，为了个人利益汇报不实销售记录的行为称为交易欺诈。无论以何种形式和目的造成被欺诈人或企业的收益损失，都是备受抵制的。因而，反欺诈的策略意义与社会效应毋庸置疑。







## Data

对于销售交易欺诈行为，我们获得的基本数据涉及6千名销售人员销售4千多个商品的交易记录，包含每次交易的单笔销量与金额。数据结构如下：

{% highlight text %}
#> # A tibble: 6 x 5
#>       ID   Prod Quant   Val   Insp
#>   <fctr> <fctr> <int> <dbl> <fctr>
#> 1     v1     p1   182  1665   unkn
#> 2     v2     p1  3072  8780   unkn
#> 3     v3     p1 20393 76990   unkn
#> 4     v4     p1   112  1100   unkn
#> # ... with 2 more rows
{% endhighlight %}



{% highlight text %}
#>        ID              Prod            Quant                Val         
#>  v431   : 10159   p1125  :  3923   Min.   :      100   Min.   :   1005  
#>  v54    :  6017   p3774  :  1824   1st Qu.:      107   1st Qu.:   1345  
#>  v426   :  3902   p1437  :  1720   Median :      168   Median :   2675  
#>  v1679  :  3016   p1917  :  1702   Mean   :     8442   Mean   :  14617  
#>  v1085  :  3001   p4089  :  1598   3rd Qu.:      738   3rd Qu.:   8680  
#>  v1183  :  2642   p2742  :  1519   Max.   :473883883   Max.   :4642955  
#>  (Other):372409   (Other):388860   NA's   :13842       NA's   :1182     
#>     Insp       
#>  ok   : 14462  
#>  unkn :385414  
#>  fraud:  1270  
#>                
#>                
#>                
#> 
{% endhighlight %}

可以看出收集的数据有3个特点：一个是缺失，一个是各别产品交易记录过少，而另一个则是目标结果出现很严重的imbalance问题。

### Missing Data
对于第一个问题，经过查看，不足5%的销量信息以及更少的销售金额缺失，大体看似乎缺失占整体的比例并不大，但是试想我们有上千个目标检测人员，如果有一人他的所有关键信息都缺失或是所有销量或是金额大幅度缺失，那对他个人而言是很严重的缺失问题但放在大样本下自然显得微不足道。因而我们需要将缺失问题by salesperson by product来看，多维度多角度的来做相应预处理。

缺失值我们要么删除要么填充，在这个数据集中有888 (out of 401146)次交易只有交易的attribute信息，没有measure信息，贸然删除之前我们现观测一下删除的操作行为会不会对某些人或产品造成主要信息缺损。查看之后删除行为对相应人员仅有5%~10%左右的记录影响，因而这里删除共同缺失的记录可行。


{% highlight text %}
#>      [,1] [,2]
#> [1,] 6016 4548
{% endhighlight %}



{% highlight text %}
#> [1] 888
{% endhighlight %}



{% highlight text %}
#> [1] 3.5 0.3
{% endhighlight %}



{% highlight text %}
#> 
#>    ok  unkn fraud 
#>   3.6  96.1   0.3
{% endhighlight %}


{% highlight r %}
p1 <- sales %>% 
  group_by(ID) %>% 
  summarise(nnasQs = round(sum(is.na(Quant))/n(), 2)) %>% 
  arrange(desc(nnasQs)) %>% 
  filter(nnasQs>0.5) %>% 
  ggplot(aes(x = reorder(ID, nnasQs), nnasQs))+
  geom_point(aes(colour = ifelse(nnasQs>0.99, '#363636','#ffffff')), show.legend = FALSE)+
  xlab('ID')+
  coord_flip()+
  theme_classic()

p2 <- sales %>% 
  group_by(ID) %>% 
  summarise(nnasQv = round(sum(is.na(Val))/n(), 2)) %>% 
  arrange(desc(nnasQv)) %>% 
  filter(nnasQv>0.1) %>% 
  ggplot(aes(x = reorder(ID, nnasQv), nnasQv))+
  geom_point(colour = '#363636')+
  xlab('ID')+
  coord_flip()+
  theme_classic()

p3 <- sales %>% 
  group_by(Prod) %>% 
  summarise(nnasQs = round(sum(is.na(Quant))/n(), 2)) %>% 
  arrange(desc(nnasQs)) %>% 
  filter(nnasQs>0.5) %>% 
  ggplot(aes(x = reorder(Prod, nnasQs), nnasQs))+
  geom_point(aes(colour = ifelse(nnasQs>0.99, '#363636','#ffffff')), show.legend = FALSE)+
    xlab('Prod')+
  coord_flip()+
  theme_classic()

p4 <- sales %>% 
  group_by(Prod) %>% 
  summarise(nnasQv = round(sum(is.na(Val))/n(), 2)) %>% 
  arrange(desc(nnasQv)) %>% 
  filter(nnasQv>0.1) %>% 
  ggplot(aes(x = reorder(Prod, nnasQv), nnasQv))+
  geom_point()+
    xlab('Prod')+
  coord_flip()+
  theme_classic()

layout <- matrix(c(1,2,3,4),1,4,byrow=TRUE)
multiplot(p1, p2, p3, p4, layout=layout)
{% endhighlight %}

![plot of chunk unnamed-chunk-5](/assets/images/unnamed-chunk-5-1.png)

上图显示的是每个销售人员和每个产品在总记录中销量与金额的相应缺失情况。可以看出有7个人完全没有销量的任何记录，不过由于有金额的数据，我们可以通过其他拥有相似产品单价的商品值对应的量做填充。另外还有两个产品是完全没有来自任何销售人员的销量纪录，可能是提交流程中产生的笔误或人工错误，这不是一个valid的商品，也有可能有其他商业考量，我们目前先不做考量。

### Few Transactions
现在考量另一个问题，我们经过初步预处理的数据中产品分布方差很大，最少记录的产品只有十几条记录，而最多的有上千条。我们通过计算每个产品价格的统计属性，用ks检验比对同质产品间相似度的显著性。



## Reference
[如何界定是否属于欺诈?](https://baike.baidu.com/redirect/13841E4aE3toRT_lxUyiSySyR2hnPHLpqXJOwlJ5-orvynagOhWv5VEbeM2XZLGYmNWk5QZ9xfsM_l7pmU5NoqBSfSLARD7oYAi0uZBXMFFfAA)
