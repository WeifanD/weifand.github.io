---
title: "An analysis and visualization of a holiday classic"
layout: post
date: 2017-01-28 20:20
image: /assets/images/markdown.jpg
headerImage: false
published: true
tag:
- Gary's Anatomy
- Text Mining
category: blog
author: WeifanD
---

大年初一，一个合家团聚的日子。耳边传来了小岳岳的阵阵歌声，手下敲打着键盘，想着花点时间将这个小坑给填了。

数据挖掘中文本挖掘一直觉得是挺有意思的主题，受到David Robinson对于圣诞爱情电影**Love Actually**分析的启发，想要挖掘一下今年最喜欢的医学美剧，**Gary's Anatomy**!《实习医生格蕾》是一部以医学为主题，是美国广播公司（ABC）出品的广播电视剧。由珊达莱姆斯编剧，珊达·莱梅斯， Peter Horton， Rob Corn等执导，艾伦·旁派领衔主演。本剧描写了一群年轻的实习医生之间的情感纠葛和他们在事业上的前进与磨练，在高强度训练医生的同时又掺杂了大量的喜剧和爱情元素，剧情幽默中略带纠结。全剧至2016年5月播完第十二季。

![center](assets/images/2017-01-28/001.jpg)
 
## 数据

我在网上找到的这个剧本就是格雷第二季，在第二季中，梅雷迪斯，伊兹，阿历克斯，乔治和克里斯汀娜昨天还是学生，现在已是医生。

西雅图恩典医院有着最艰苦的外科住院医实习程序，是医务新人最残酷的训练场。如果他们能挺过西雅图医院的七年炼狱考验，他们就能成为合格的外科医生。然而摆在这三人组面前的，不仅是艰苦的实习培训，她们还面对重重难关，只有彼此互相依靠。

此剧本总共2.4M，包含的信息有剧集名、编剧、角色和台词，当然还有最有意思的旁白。

### 数据清洗
元数据中通过冒号分隔开了来源和内容，来源包含了内容，也就是台词所对应的角色名以及集数和集名。为了简洁和数据标准化txt文档所表达的信息，需要通过整合去除脏数据以及增加主列和辅助列来标注清晰角色与台词、编剧与剧本、导演与剧集之间的关系。

![center](assets/images/2017-01-28/002.PNG)


{% highlight r %}
raw <- readLines("gary's anatomy.txt")

text <- data_frame(raw = raw) %>% 
  filter(raw != "", !is.na(raw)) %>% 
  separate(raw, c("form","content"),sep = ": ",fill = "left") %>% 
  mutate(form = ifelse(is.na(form), "others", form)) %>% 
  mutate(form = str_to_lower(form), 
         is_scene = str_detect(form, "2x"),
         scene = cumsum(is_scene)) %>% 
  filter(form != 'others', scene > 0) %>% 
  select(-is_scene)

characters <- text %>% 
  filter(str_detect(form, '^[a-zA-Z]+$')) %>%
  mutate(form=str_to_lower(form)) %>%
  select(form) %>% 
  unique() %>% 
  as.data.frame()

dialogue <- text %>% 
  inner_join(characters) %>% 
  rename(character=form, line=content)

head(dialogue)
{% endhighlight %}



{% highlight text %}
# A tibble: 6 x 3
  character line                                                      scene
  <chr>     <chr>                                                     <int>
1 mvo       "To be a good surgeon, you have to think like a surgeon.~     1
2 joe       You look familiar. You been here before?                      1
3 meredith  "Once. That worked out really well. "                         1
4 joe       I know that look. It'll be one of two things. Either you~     1
5 meredith  "Both. "                                                      1
6 mvo       "But sometimes, you're faced with a cut that won't heal.~     1
{% endhighlight %}

通过正则、大小写归一、词干提取、词形还原、去除不恰当字符以及表示动作的行为等清洗方式，将不合理的1349个角色清洗到167个（其中包含了所有病人和出现过的人物）。其中`MVO`表示旁白，添加表明第几集的辅助列为了之后分析人物出场关系做好准备。

## 编剧和台词
### 编剧
先来看看究竟第二季有哪些主题，都是谁写的？有没有常驻作者？

{% highlight r %}
text %>%
  filter(form == 'written by') %>% 
  rename(writer = content) %>% 
  separate_rows(writer, sep = " & |, ") %>% 
  select(scene, writer) %>% 
  ggplot(., aes(writer, fill = "skyblue")) +
  geom_bar()+
  coord_flip() +
  theme(legend.position = "none")
{% endhighlight %}

![plot of chunk unnamed-chunk-3](/assets/images/2017-01-28/unnamed-chunk-3-1.png)

总共27集的连续剧，Shonda Rhimes就写了四分之一，常驻编剧非她莫属了。Rhimes是一位美國編劇，導演和電視製作人。她最知名的是製作和編寫了醫療劇《實習醫生》和《私人診所》。2007年5月，她入選《時代》的百大最有影響力的人物之一。她還是醫療劇《隱世靈醫》的執行製作人並製作了2012年4月5日播出的ABC電視劇《醜聞》。

![](assets/images/2017-01-28/writer.jfif)

{% highlight r %}
text %>%
  filter(str_detect(form, "2x")) %>% 
  select(form, content) %>% 
  rename(episode_no = form, episode_name = content)
{% endhighlight %}

![](assets/images/2017-01-28/005.PNG)

第二季有没有你印象最深的一集呢？看到第一集的名字，我想第一集的编剧可能没想到多年之后，有一个胖胖的女生唱了一首传唱度极高的歌，她的第一句音起就是“When the rain is blowing in your eyes and the whole world is on your face”～

### 台词
然后看一下台词，有哪些问题呢，比如：角色间高频口头语有没有很大的差异？台词和出场率最高的是不是就是我们印象中的那些主角？作为医学剧小众的医学词汇有哪些？

{% highlight r %}
character_in_form <- dialogue %>% 
  group_by(character) %>% 
  summarise(line_count=n()) %>% 
  arrange(desc(line_count)) %>% 
  filter(line_count>68) %>% 
  mutate(class='form') %>% 
  rename(n=line_count)

library(tidytext)
reg <- "([^A-Za-z\\d#@']|'(?![A-Za-z\\d#@]))"
dialogue_words <- dialogue %>%
  unnest_tokens(word, line, token = "regex", pattern = reg) %>% 
  filter(!word %in% stop_words$word)

character_in_line <- dialogue_words %>%
  count(word, sort = T) %>%
  as.data.frame(.) %>% 
  inner_join(characters, by = c("word" = "form")) %>% 
  filter(n>55) %>% 
  mutate(class='line') %>% 
  rename(character=word)

p1 <- character_in_form %>% 
  ggplot(., aes(reorder(character, n), n)) +
  geom_bar(stat = "identity",fill = 'red')+
  coord_flip() +
  # theme(axis.text.x = element_text(angle = 25), )+
  xlab("speakers")+
  ylab("no. of lines")

p2 <- character_in_line %>% 
  ggplot(., aes(reorder(character, n), n)) +
  geom_bar(stat = "identity", fill = 'blue')+
  coord_flip() +
  # theme(axis.text.x = element_text(angle = 25))+
  xlab("")+
  ylab("no. of being mentioned by others")

p1+p2
{% endhighlight %}

![plot of chunk unnamed-chunk-5](/assets/images/2017-01-28/unnamed-chunk-5-1.png)

通过分别分析所有角色的台词数量以及台词中提到的不同角色的频次，综合起来可以发现Meredith当之无愧是我们的头号主角，主动和被动出现的频率的确是最高的。


![center](assets/images/2017-01-28/wordcloud-1.PNG)
![center](assets/images/2017-01-28/wordcloud-2.PNG)
![center](assets/images/2017-01-28/wordcloud-3.PNG)

再来看看台词的词频~ Meredith的台词里George的出现率反而高于了她的男友Dereck。在Cristina这虽然没超过指导住院医生兼男友的Burke，但也被提到不少，看来作为女孩们的蓝颜知己， George在生活中还是很重要的存在，毕竟大家都是室友和同事。另外，并不意外在这几个实习生的高词频名单里看到了个矮但是霸气，“严厉无情”，被以“纳粹”著称的Miranda Bailey，她以实习生们的指导住院医生身份出场，在Mer这一批实习生的成长发展中，奉献了许多关怀与帮助，是实习生们敬爱的人。而Cristina是业界难遇的奇才，除了手术，对其他基本漠不关心。作为实习医生，紧跟指导住院医生Baileyd的身后，一有什么疑难杂症，百年一遇的疾病手术，第一个冲锋上前，她的个性和亚洲面孔给我留下了极深刻的印象。

除此之外，作为一部典型的美剧，日常常用词还是占多数的，像什么god／ah／guy之类的口头语（当然这些也可以按需过滤掉），chief／Dr的title，当然也有医学题材不可避免的surgery，接下来看看这部剧积极的情绪词频。

![center](assets/images/2017-01-28/wordcloud-4.PNG)

跟想象中差不多，lucky／love／happy占首位

然后是常用医学词，我真的很好奇。

{% highlight text %}
 [1] "ablation"      "abnormal"      "absolute"      "abusing"      
 [5] "acne"          "addition"      "adhered"       "adjustment"   
 [9] "administer"    "administered"  "afebrile"      "affect"       
[13] "agitated"      "agonal"        "allergies"     "allied"       
[17] "alphabet"      "alternative"   "ama"           "ambulatory"   
[21] "amitriptyline" "amnesia"       "amniotic"      "amphetamine"  
[25] "amputation"    "ankle"         "ant"           "anticipate"   
[29] "apneic"        "appendectomy"  "applied"       "approach"     
[33] "approximation" "aries"         "arousal"       "arrested"     
[37] "arrhythmia"    "asbestosis"    "ascites"       "aspirate"     
[41] "aspiration"    "aspirin"       "asystolic"     "atresia"      
[45] "atrophy"       "attic"         "attitude"      "autopsy"      
[49] "auxiliary"     "bainbridge"   
{% endhighlight %}

我们使用TF-IDF算法找到那些关键词，这里用到的医学辞典来源于`LibreOffice/OpenOffice/Android/Word`，除了混入的一些常用词，看看你都认识哪些呢？

## 人物关系
接下来我们挖一下人物关系吧


{% highlight r %}
by_speaker_scene <- dialogue %>%
    count(scene, character) %>% 
    filter(n>15)

speaker_scene_matrix <- by_speaker_scene %>%
    acast(character ~ scene, fun.aggregate = length)

speaker_scene_matrix[1:10,1:10]
{% endhighlight %}



{% highlight text %}
         1 2 3 4 5 6 7 8 9 10
addison  1 0 1 1 0 1 1 1 0  1
adele    0 0 0 0 0 0 0 0 0  0
alex     1 1 1 1 1 1 1 0 0  1
amy      0 0 0 0 0 0 0 0 0  0
andrew   0 0 0 0 0 0 0 0 0  0
bailey   0 1 1 1 1 1 1 1 1  0
beatrice 0 0 0 0 0 0 0 0 0  0
bex      0 0 0 0 0 0 0 0 0  0
bonnie   0 0 0 0 0 1 0 0 0  0
burke    1 1 1 1 1 1 1 1 1  0
{% endhighlight %}

现在每集每个人每句台词形成一行，也就是one scene one line one observation, 将其转变成“speaker-by-scene matrix”，为之后的聚类做准备。

![plot of chunk unnamed-chunk-9](/assets/images/2017-01-28/unnamed-chunk-9-1.png)

我们五大主角果然聚在一起了，谁叫他们工作在一起住还住一起～

![plot of chunk unnamed-chunk-10](/assets/images/2017-01-28/unnamed-chunk-10-1.png)
换个热力图看看他们之间的关系。


{% highlight r %}
scenes <- dialogue %>%
    count(scene, character) %>% 
    filter(n > 25) %>%        # scenes with > 25 character
    ungroup() %>%
    mutate(scene = as.numeric(factor(scene)))
           # character = factor(character, levels = ordering))

ggplot(scenes, aes(scene, character)) +
    geom_point() +
    geom_path(aes(group = scene))
{% endhighlight %}

![plot of chunk unnamed-chunk-11](/assets/images/2017-01-28/unnamed-chunk-11-1.png)

我们可以看到每一集出现人物的关系线，Alex居然第九集没有出场，Mark第18集才出场，看来我得去回顾一下第二季了，先到这里等我review剧之后再来理一下。



