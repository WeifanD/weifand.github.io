---
title: "How to install Tensorflow-gpu in Centos7"
layout: post
date: 2018-10-18 15:48
image: /assets/images/markdown.jpg
headerImage: false
tag:
- TensorFlow-GPU
- Shell
- Centos
category: blog
author: WeifanD
---
## 系统配置

系统版本： Centos7.6

语言: Python3.5(anaconda3 4.2)

框架: Tensorflow

   
### 安装依赖 

``` bash
sudo yum install openjdk-8-jdk git python-dev python3-dev python-numpy python3-numpy build-essential python-pip python3-pip python-virtualenv swig python-wheel libcurl3-dev curl   
```

### 安装 NVIDIA 驱动 和 CUDA

``` bash
curl -O http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/cuda-repo-ubuntu1604_9.0.176-1_amd64.deb
sudo apt-key adv --fetch-keys http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/7fa2af80.pub
sudo dpkg -i ./cuda-repo-ubuntu1604_9.0.176-1_amd64.deb
sudo apt-get update
sudo apt-get install cuda-9-0   

# 这一步有可能报错，出现
# trying to replace " /usr/lib/x86_64-linux-gnu/libGLX_indirect.so.0 ",which
# belong to the package libglx-mesa0:amd64 18.0.0~rc5-1ubuntu1
# errors have been encountered during the execution of : 
# /var/cuda-repo-9-2-local/./nvidia-396_396.26-0ubuntu1_amd64.deb
# 或者类似，请尝试
# dpkg -i --force-overwrite /var/cache/apt/archives/nvidia-xxx
# 参见 https://askubuntu.com/questions/1037982/nividia-396-installation-blocked-by-libglx-on-18-04

# 重启
sudo reboot

# 检查驱动安装
nvidia-smi   

如下图 (双 GPU)
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 396.44                 Driver Version: 396.44                    |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|===============================+======================+======================|
|   0  Tesla P4            Off  | 00000000:00:07.0 Off |                    0 |
| N/A   37C    P0    22W /  75W |      0MiB /  7611MiB |      0%      Default |
+-------------------------------+----------------------+----------------------+
|   1  Tesla P4            Off  | 00000000:00:08.0 Off |                    0 |
| N/A   37C    P0    23W /  75W |   6722MiB /  7611MiB |      0%      Default |
+-------------------------------+----------------------+----------------------+

```    

### Install cudnn   

``` bash
tar -zxvf cudnn-9.0-linux-x64-v7.1.solitairetheme8
sudo cp cuda/include/cudnn.h /usr/local/cuda/include/
sudo cp cuda/lib64/libcudnn* /usr/local/cuda/lib64/ -d
sudo chmod a+r /usr/local/cuda/include/cudnn.h
sudo chmod a+r /usr/local/cuda/lib64/libcudnn*
```    

### 配置环境变量 ~/.bashrc: 

``` bash
export LD_LIBRARY_PATH=/usr/local/cuda-9.0/lib64:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH
export CUDA_HOME=/usr/local/cuda
export PATH="$PATH:/usr/local/cuda/bin"
# 刷新
source ~/.bashrc
```   

### 安装 Python 环境 (miniconda)

``` bash
wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh   

# press s to skip terms   

# Do you approve the license terms? [yes|no]
# yes

# Miniconda3 will now be installed into this location:
# accept the location

# 如果错误信息：bunzip2: command not found
yum install -y bzip2

# Do you wish the installer to prepend the Miniconda3 install location
# to PATH in your /home/ghost/.bashrc ? [yes|no]
# yes    
source ~/.bashrc
```   

### Create conda env to install tf   

``` bash
conda create -n tensorflow

# press y a few times 
```   

### Activate env   

``` bash
source activate tensorflow   
```

### 安装带 gpu 的 tensorflow 版本

``` bash
pip install tensorflow-gpu -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com
```   

### 测试安装结果  

``` bash
# start python shell   
python

# run test script   
import tensorflow as tf   
hello = tf.constant('Hello, TensorFlow!')
sess = tf.Session()
print(sess.run(hello))

# 正常会在 nvidia-smi 看到(双 gpu)
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 396.44                 Driver Version: 396.44                    |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|===============================+======================+======================|
|   0  Tesla P4            Off  | 00000000:00:07.0 Off |                    0 |
| N/A   38C    P0    23W /  75W |   7241MiB /  7611MiB |      0%      Default |
+-------------------------------+----------------------+----------------------+
|   1  Tesla P4            Off  | 00000000:00:08.0 Off |                    0 |
| N/A   37C    P0    23W /  75W |   7387MiB /  7611MiB |      0%      Default |
+-------------------------------+----------------------+----------------------+
                                                                               
+-----------------------------------------------------------------------------+
| Processes:                                                       GPU Memory |
|  GPU       PID   Type   Process name                             Usage      |
|=============================================================================|
|    0     54501      C   python                                      7231MiB |
```  

