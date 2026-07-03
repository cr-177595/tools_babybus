#!/usr/bin/env python

#导入需要的库
import sys
if sys.version > '3':
    import queue
else:
    import Queue as queue
import threading
import contextlib
import time
import os
import re
import math
import PIL
from PIL import Image



################
#说明：
#缩小待处理目录下的png格式图片，并保存到默认导出目录(1.3.0更新：默认导出目录下存在多余文件，自动执行删除，保证x2x4一致性)，然后压缩图片(2.0.0更新)
#待处理目录必须包含"x4"文件夹(1.3.0更新：可直接写项目根目录)，默认导出目录为x4同级下的x2，不支持另外指定修改
#只支持MacOS，使用方式为terminal输入：python 本文件 指定目录

#ver 1.0.0
#created by hachman @2020.02.19
#init code

#ver 1.1.0
#modified by hachman @2020.02.19
#filter folder name that include "bone" or "g"

#ver 1.2.1
#modified by hachman @2020.02.21
#add work progress, and optimized code; fix i18n folder bug

#ver 1.3.0
#modified by hachman @2020.02.24
#add check redundant files, and can be worked with project root path now

#ver 2.0.0
#modified by hachman @2020.03.02
#add compress png files(require "pngquant", see https://pngquant.org/)
################

#ver 2.0.1
#modified by Neighbour Mr.Wang @2020.05.06
#add multithreading

#ver 2.0.2
#modified by Neighbour Linsheng @2020.05.29
#perfect multithreading

#ver 2.0.3
#modified by Neighbour Mr.Wang @2020.06.18
#add threadPool
################



StopEvent = object()  # 终止线程信号
#处理过的文件路径存储
handled = list()
pool = 0



class ThreadPool(object):
    def __init__(self, max_num, max_task_num = None):
        if max_task_num:
            self.q = queue.Queue(max_task_num)  # 指定任务最大数,默认为None,不限定
        else:
            self.q = queue.Queue()
        self.max_num       = max_num  # 最多多少线程
        self.cancel        = False  # 执行完所有任务，终止线程信号
        self.terminal      = False  # 终止所有线程标识
        self.generate_list = []  # 已创建线程集合
        self.free_list     = []  # 空闲线程集合

    def run(self, func, args, callback=None):
        if self.cancel:
            return
        # 没有空闲线程 并且已创建线程小于最大线程数才创建线程，
        if len(self.free_list) == 0 and len(self.generate_list) < self.max_num:
            self.generate_thread()
        w = (func, args, callback,)
        self.q.put(w)

    def isOver(self):
        if len(self.free_list) == len(self.generate_list):
            return True
        return False

    def generate_thread(self):
        t = threading.Thread(target=self.call)  # 线程执行call方法
        t.start()

    def call(self):
        current_thread = threading.currentThread()
        self.generate_list.append(current_thread)  # 每创建一个线程，将当前线程名加进已创建的线程列表

        event = self.q.get() 
        while event != StopEvent:  # 是否满足终止线程

            func, arguments, callback = event  # 取出队列中一个任务
            try:
                result = func(*arguments)  # 执行函数
                success = True
            except Exception as e:
                print("error!!!!")
                success = False
                result = None

            if callback is not None:
                try:
                    callback(success, result)
                except Exception as e:
                    pass

            with self.worker_state(self.free_list, current_thread):  # 当前线程执行完任务，将当前线程置于空闲状态，
                #这个线程等待队列中下一个任务到来
                if self.terminal:
                    event = StopEvent
                else:
                    event = self.q.get() 
        else:
            self.generate_list.remove(current_thread)

    # 杀掉所有线程
    def close(self):
        self.cancel = True   # 标志设置为True
        full_size = len(self.generate_list) + 1  # 已生成线程个数+1 针对python2.7以上
        while full_size:
            self.q.put(StopEvent)
            full_size -= 1

    # 无论是否还有任务，终止线程
    def terminate(self):
        self.terminal = True

        while self.generate_list:
            self.q.put(StopEvent)

        self.q.queue.clear()

    @contextlib.contextmanager
    def worker_state(self, state_list, worker_thread):
        # 用于记录线程中正在等待的线程数
        state_list.append(worker_thread)
        try:
            yield
        finally:
            state_list.remove(worker_thread)

 
#进度条
def progress_bar(current, total, starttime, isclock):
    #进度
    progress = current * 100.0 / total
    #花费时间
    if isclock:
        elapse = time.clock() - starttime
    else:
        elapse = time.time() - starttime
    #预估剩余时间
    if progress == 0.0:
        estimate = 0.0
    else:
        estimate = elapse * 100.0 / progress - elapse
    #替换式刷屏
    sys.stdout.write('\r')
    #定长：字符串的长度不足，在右侧填补空格（2588是黑方块的unicode编码）
    sys.stdout.write("|%-10s|" % (u'\u2588' * int((progress / 10))))
    #文字描述
    sys.stdout.write("进度: {:.2f}%,  已用时: {:.2f}s,  预计还需用时: {:.2f}s".format(progress, elapse, estimate))
    sys.stdout.flush()



# 遍历x4所有的文件夹及其子文件夹，并在x2创建对应目录
def check_make_dir(path):
    # sub = re.sub(r'/x4', '/x2', path)
    # if not os.path.exists(sub):
    #     os.mkdir(sub)
    for root, dirs, files in os.walk(path):
        for d in dirs:
            newdir = os.path.join(root, d)
            #过滤bone和g文件夹（g有可能匹配到gameplay，这里分开判断）
            if re.match(r'.*(/res)+.*', newdir) and not re.match(r'.*(/x4/bone|/x4/g)+$', newdir) and not re.match(r'.*(/x4/bone/|/x4/g/)+.*', newdir):
                #正则替换路径名到x2
                sub = re.sub(r'/x4/', '/x2/', newdir)
                if not os.path.exists(sub):
                    os.mkdir(sub)



# 遍历文件夹及其子文件夹中的文件
def get_all_file(path, filelist):
    if os.path.isfile(path):
        filelist.append(path)
    elif os.path.isdir(path):
        if not re.match(r'.*(/.git)+.*', path):
            #遇到目录，递归本方法
            for s in os.listdir(path):
                get_all_file(os.path.join(path, s), filelist)
    return filelist



# 遍历x4文件夹及其子文件夹中的文件
def get_all_x4_file(path, filelist):
    if os.path.isfile(path):
        if re.match(r'^.+\.(png)$', path) and re.match(r'.*(/x4)+.*', path) and not re.match(r'.*(/x4/bone/|/x4/g/)+.*', path):
            filelist.append(path)
    elif os.path.isdir(path):
        if not re.match(r'.*(/.git)+.*', path):
            #遇到目录，递归本方法
            for s in os.listdir(path):
                get_all_x4_file(os.path.join(path, s), filelist)
    return filelist



# 遍历x2文件夹及其子文件夹中的文件
def get_all_x2_file(path, filelist):
    if os.path.isfile(path):
        if re.match(r'^.+\.(png)$', path) and re.match(r'.*(/x2)+.*', path) and not re.match(r'.*(/x2/bone/|/x2/g/)+.*', path):
            filelist.append(path)
    elif os.path.isdir(path):
        if not re.match(r'.*(/.git)+.*', path):
            #遇到目录，递归本方法
            for s in os.listdir(path):
                get_all_x2_file(os.path.join(path, s), filelist)
    return filelist



#图片缩小主方法
def resize_img(path):
    #只处理x4，并过滤bone和g文件夹内的所有文件
    if re.match(r'.*(/x4)+.*', path) and not re.match(r'.*(/x4/bone/|/x4/g/)+.*', path):
        #pillow库打开图片
        img = Image.open(path)
        #获取宽，高
        width, height = img.size
        #路径分割：路径，文件名
        dirname, filename = os.path.split(path)
        #正则替换路径名到x2
        sub = re.sub(r'/x4', '/x2', dirname)
        #以向下取整的运算方式，按整数缩小一半，采样使用精度最高的LANCZOS算法
        img = img.resize(size = (width//2, height//2), resample = PIL.Image.LANCZOS)
        #保存缩小过的图片
        newPath = os.path.join(sub, filename)
        img.save(newPath)
        img.close()
        #保存作对比
        handled.append(newPath)



#对路径下的所有图片裁剪
def cut_images(path):
    #获取文件集合
    filelist = get_all_file(path, [])
    total = len(filelist)
    print("********************************")
    print("all files count: " + str(total))
    print("cutting images...")
    #进度条相关
    current = 0
    starttime = time.time()
    progress_bar(current, total, starttime, False)
    sumThread = math.ceil(math.sqrt(total))
    global pool
    pool = ThreadPool(sumThread)  # 创建pool对象，最多创建5个线程
    #处理开始：正则过滤出png后缀的图片文件，并处理
    for f in filelist:
        match = re.match(r'^.+\.(png)$', f)
        if match:            
            if current % sumThread == 0:
                resize_img(match.group())
            else:
                ret = pool.run(resize_img, (match.group(),), callback=None)
        #进度条展示
        current = current + 1
        if current % 25 == 0 or current == total:
            progress_bar(current, total, starttime, False)



#检查文件统一性
def check_handled_files(path):
    print("\n" + "********************************")
    if re.match(r'.*(/x4)+.*', path):
        newpath = re.sub(r'/x4', '/x2', path)
        x2_filelist = get_all_x2_file(newpath, [])
    else:
        x2_filelist = get_all_x2_file(path, [])
    #两数组差集（handled是处理过的x2，以此为准寻找原x2中需要被删除的）
    diff = list(set(x2_filelist).difference(set(handled)))
    print("check redundant files...")
    print("cutted images count: " + str(len(handled)) )
    print("all x2 images count: " + str(len(x2_filelist)) )
    if len(diff) != 0:
        print("find different, now delete redundant files..." + "\n")
    else:
        print("nothing different, done!")
        print("********************************")
        return
    #移除所有多余文件
    for f in diff:
        print("delete: " + f)
        os.remove(f)
    print("********************************")



# 
def compress_img(f):
    code = os.system("pngquant --force --output " + f + " " + f + " &")
    if code != 0:
        print("\n" + "using pngquant error, please check!")
        print("********************************")



#压图
def compress_handled_files(filelist):
    print("using pngquant compress png files...")
    #进度条相关
    total     = len(filelist)
    current   = 0
    starttime = time.time()
    progress_bar(current, total, starttime, False)
    sumThread = math.ceil(math.sqrt(total))
    for f in filelist:
        if current % sumThread > sumThread - 2:
            compress_img(f)
        else:
            ret = pool.run(compress_img, (f, ), callback=None)
        #进度条展示
        current = current + 1
        if current % 10 == 0 or current == total:
            progress_bar(current, total, starttime, False)
    print("\n" + "********************************")



#主入口
if len(sys.argv) == 2:
    path = sys.argv[1]
    if os.path.isdir(path) or os.path.isfile(path):
        check_make_dir(path)
        cut_images(path)
        for i in range(100):
            time.sleep(0.2)
            if pool.isOver() == True:
                print("\n" + "Cut All!")
                break
        check_handled_files(path)
        compress_handled_files(handled)
        for i in range(100):
            time.sleep(0.2)
            if pool.isOver() == True:
                print("Compress x2 All!" + "\n")
                break
        #确认是否需要处理x4
        command = input("press \"y\" to compress x4 imgs, others to skip: ")
        if command == "y" or command == "Y":
            x4_filelist = get_all_x4_file(path, [])
            compress_handled_files(x4_filelist)
            for i in range(100):
                time.sleep(0.2)
                if pool.isOver() == True:
                    print("Compress x4 All!" + "\n")
                    pool.close()
                    break
        else:
            pool.close()
    else:
        print("please enter a path!!!")
else:
    print("args count error!!!")