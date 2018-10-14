#!/usr/bin/python
# coding: UTF-8

# code by senninha on 2018-10-13 21:00:00

import os

#夹逼出想要的数据
def squeeze(str, key0, key1):
    index0 = str.find(key0, 0, len(str))
    if index0 == -1:
        return ""
    index1 = str.find(key1, 0, len(str))
    if index1 == -1:
        return ""
    return str[index0 + len(key0):index1]


#按行读取文件并返回每一行的数据
def readFile(filename):
    file = open(fileName, "r")
    lines = file.readlines()
    file.close()
    return lines

# 执行命令并返回结果,直接循环读取结果就行了
def executeCmd(cmd):
    result = os.popen(cmd, "r")
    return result

# 通过svn改动,同步两个项目的代码
def synSvn():
    parentPath = "/tmp/"    # 根路径
    path0 = "test0/"        # 同一个项目的两个拷贝内容，这里是源
    path1 = "test1/"        # 从源复制到这里
    needSynPath = "senninha.senninha/"  # 需要同步的相对于源的路径

    # 执行获取源路径svn改变情况
    svnInfo0 = executeCmd("cd " + parentPath + path0 + "\n svn status " + needSynPath)

    for tmp in svnInfo0:
        if(tmp[0] == 'A' or tmp[0] == '?' or tmp[0] == 'M'):
            changePath = squeeze(tmp, "       ", "\n")
            synCmd = "cp -r " + parentPath + path0 + changePath + " " + parentPath + path1 + changePath
            executeCmd(synCmd)
            print("执行同步:" + path0 + "-->" + path1 + "content:" + changePath)


# 开始执行脚本的地方
