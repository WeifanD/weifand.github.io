---
title: "R-Python速查表"
layout: post
date: 2018-01-18 12:00
image: /assets/images/markdown.jpg
headerImage: false
tag:
- R
- Python
category: blog
author: WeifanD
---

不定期更新。。。

| R |    Python |
| :-------- | :--------|
| `data$v1`  | `data.v1`|
| `data[,v1]`     |  `data[v1]` | 
| `data %>% str_split`| `data.str.split` | 
|`str_detect`| `str_contain`|
|`train_photos$expensive_photos <- train photos %>% filter(business_id %in% expensive_businesses) %>% select(photo_id) %>% as.list()`| `expensive_photos =train_photos[train_photos.business_id.isin(expensive_businesses)].photo_id.tolist()`|
|`seq`|`np.arrange()`|
|`n_sample <- lfw_people.images[1] H <-  lfw_people.images[2] W <-  lfw_people.images[3]`|`n_samples, h, w = lfw_people.images.shape`|
|`cat_dir <- "http:dd" list.files(system.file(package="png")) %>% map_chr(~file.path(cat_dir, .x))`|`[cat_dir + fn for fn in os.listdir(cat_dir)]`|
|`tally`|`value_count`|
|`gather()`, `spread`| `melt`|

  