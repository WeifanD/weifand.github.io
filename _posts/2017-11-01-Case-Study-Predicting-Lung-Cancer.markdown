---
title: "Case Study - Predicting Lung Cancer"
layout: post
date: 2017-11-01 12:44
image: /assets/images/markdown.jpg
headerImage: false
tag:
- Cancer
- CNN
category: blog
author: WeifanD
---
### Problem
> 根据研究调查，肺癌是发病率和死亡率增长最快，对人群健康和生命威胁最大的恶性肿瘤之一。近50年来许多国家都报道肺癌的发病率和死亡率均明显增高，男性肺癌发病率和死亡率均占所有恶性肿瘤的第一位，女性发病率占第二位，死亡率占第二位。

![Alt text](/assets/images/1509366050391.png)

在美国，每年有超过22万的人死于肺癌，国家健康医疗成本投入巨大。2017年，[Data Science Bowel](https://www.kaggle.com/c/data-science-bowl-2017) 为了响应一项名为 [Cancer Moonshot](https://wallstreetcn.com/articles/228544) 2020的国家级创新项目发起了一场通过人工智能进行高效性肺癌预测的竞赛。

### Data
**Available Data**

所提供的数据集由1000张高风险患者的低剂量胸部CT图构成，这种CT是根据收集到的投影数据所形成的，一种辐射X-ray电流小、剂量小的计算机断层图像。每张图包含来源于不同的胸腔多轴线二维切片。图的存储格式为放射医疗中常用于数据交换的医学图像格式DICOM files，每个病人有一个单独的ParentID，每个ParentID对应一个单独的DICOM文件路径。
**Notes:** 可用于处理DICOM标准图片的资源如下：
- pydicom: A package for working with images in python.
- oro.dicom: A package for working with images in R.
- Mango: A useful DICOM viewer for Windows users.

![Alt text](/assets/images/1509366949216.png)

**External Data**

想象一下假使你想培养一名学生在短时间通过繁复操练过往习题来提高赢得某数学竞赛的几率。首要任务就是划重点，告诉他重点题型是什么样。因而，除了CT scans的信息数据外，我们还需要肿瘤本身的数据，包括在胸腔的方位、尺寸（nodule diameter）、形状（i.e. nodule spiculation/lobulation）、性质（nodule malignancy）等形态。这部分数据可直接从LUNA16 challenge中的[LUNA16 dataset](https://luna16.grand-challenge.org/data/)中获得。如果想了解其他更多的外部数据请点击[这里](https://www.kaggle.com/c/data-science-bowl-2017/discussion/27666)。

可以说恶性肿瘤的标签数据某种程度上决定了最终预测结果的分数高低。

### Preprocessing
> load DICOM data -> downsampling -> resize -> SD numpy arrays

在正式将images喂给算法前需给数据集进行一系列预处理，以方便算法进行训练。首先，给定的CT scans的各切片（slice）其实就是一张张由不同像素构成的图片，为了让计算机更好的识别图片的每个部分（哪里是空气哪里是组织（tissue）），要先进行HU单位转化。[Hounsfield scale](https://en.wikipedia.org/wiki/Hounsfield_scale)又称亨氏单位，简称HU，用来表示CT图像上组织结构的相对密度。比如水的CT值是0亨氏单位，CT值的范围是2000 HU，每个值用一个灰度表示，1000是白色，-1000是黑色。组织的CT值并不是恒定不变的，不同的CT扫描机在扫描同一个病人时会有CT值的偏差，同一CT扫描机在不同时间系列扫描同一病人的同一结构时CT值也会出现偏差。

![Alt text](/assets/images/1509429503979.png)

然后，scan之间的差异性以及slice间距离的差异性会影响CNN算法的performance，为此进行预处理是必要的。最常用处理这种不规则的方式称为重抽样（resampling），将各slice各异的像素间距（pixel spacing）统一到[1mm 1mm 1mm] 1x1x1 mm 的小立方体。接下来就是做区域划分，简单来说就是聚焦整个scan图上的除空气外的肺部区域。最后就是做相应的标准化中心化处理。

### Model
CNN卷积神经网络是一种图像识别领域中常用的深度学习算法之一，其根本应用范围就是**取特征**，将图片通过卷积神经网络的卷积层、激活层、池化层、批量归一化层和全互联层（Fully Connected Layer）产生一个包含分类结果概率的N维数组。
![Alt text](/assets/images/1509431602416.png)

基本流程如下：
1. 将图片进行方框式划分

![Alt text](/assets/images/1509436078023.png)

2. 取出具有象征意义的卷积核filter（特征），一般是3*3、5*5
3. 将每块窗口与特征进行点积求均值得到新的feature map的一个新像素值（**卷积层**）[动态图](http://cdn.infoqstatic.com/statics_s1_20171024-0600/resource/articles/resnet-azure-gpu/zh/resources/11.gif)
4. 通过激活函数将小于0的像素值设定为0（非线性激活层，又称**ReLU层**）
5. 以更小的步长重复步骤3通过Max pooling或Average pooling的池化方法得到一个空间内存更小的特整地图，在空间上缩减样本，在厚度方向保持不变（pooling**池化层**）
6. 将第五步输出的“特征”输入另一个全互联神经网络层和SoftMax函数，即可获得一组输出值：比如每种分类标签的概率。（**全互联层**）

![Alt text](/assets/images/1509436048183.png)
![Alt text](/assets/images/1509524907289.png)

### Conclusion
用模型对scan进行全方位的模拟检测形成[动态图](https://dhammack.github.io/images/global_importance_db8e5fe2c0c7e92db6cac98df51c3802.gif)，红色即为恶性肿瘤。

### Reference
http://blog.kaggle.com/2017/06/29/2017-data-science-bowl-predicting-lung-cancer-2nd-place-solution-write-up-daniel-hammack-and-julian-de-wit/
https://baike.baidu.com/item/%E8%82%BA%E7%99%8C/428115?fr=aladdin
https://github.com/WeifanD/kaggle_ndsb2017
https://zhidao.baidu.com/question/808814252251882052.html
http://www.infoq.com/cn/articles/resnet-azure-gpu


