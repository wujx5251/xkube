### 概述

```
xkube是对kubectl的二次封装，方便日常对k8s的pod访问、维护。减少对繁琐的kubectl命令的依赖，xkube封装了日常常用的kubectl命令，如同访问堡垒机一样通过命令菜单进行pod及其容器的访问。具体使用如下
```

### 安装

![image-20230927105440265](/Users/wujx/Library/Application Support/typora-user-images/image-20230927105440265.png)

* config 为kubectl的配置文件，先已经针对阿里云和通讯云进行合并，也可以根据情况进行自行处理，具体合并方法自行百度
* kubectl为k8s官方管理客户端
* xkube 通过shell实现的kubectl交互管理工具
* install.sh xkube安装工具，主要实现config拷贝到用户目录.kube，kubectl、xkube拷贝到/usr/local/bin目录（方面使用目前不进行环境变量设置）

### 使用

#### xkube 支持的命令

* xkube keyword 关键字模糊搜索

* xkube -n namespace 切换k8s命名空间

* xkube -c context 切换配置上下文，通过此命令可以切换不同的集群

* xkube -l 列举当前管理的集群

* xkube -a 展示全部pod默认过滤statefulset

##### 示例

```
1、查看管理的集群情况
edy@wujx ~ % xkube -l
ali
tx                            activate

2、管理集群上下文切换
edy@wujx ~ % xkube -c ali -n dev passen
 Id    Name                                              Status              Age
  1    agent-passenger-master-55d9ff6999-gdsnt           Running             107d
  2    passenger-master-f657484b7-tvn2z                  Running             145d

Please enter Id entry or keyword search, help enter [h] or exit enter [q]
context：ali，namespace：dev
keyword：passen
xkube>

3、查看test命名空间passen关键字的pod列表
edy@wujx ~ % xkube passen -n test
 Id    Name                                              Status              Age
  1    agent-passenger-59669f696-dzt62                   Running             25d
  2    passenger-5f5f68f65-x5wtl                         Running             4d14h

Please enter Id entry or keyword search, help enter [h] or exit enter [q]
context：tx，namespace：test
keyword：passen
xkube>

4、帮助
edy@wujx ~ % xkube -h
Usage: [KEYWORD] [-n NAMESPACE] [-a ALL] [-c CONTEXT] [-l CLUSTER] [-h|--help]
 where COMMAND is one of: [-n|-c|-l|-h]
         -n    命名空间
         -c    配置切换
         -a    全部Pod
         -l    配置列表
    keyword    pod关键字
  -h|--help    帮助

```

#### xkube运行时支持命令

* h 打开帮助
* q 退出xkube
* r 重置关键字
* -n namespace 切换命名空间
* id -l 容器日志
* id -i  Pod信息
* id -c  指定进入Pod容器名称
* id -r  Pod重
##### 示例

```
1、关键字模糊搜索，存在关键字直接回车会使用当前关键字进行再次搜索（容器重新部署或重启是名称会改变可以直接回车刷新）
xkube> dao
 Id    Name                                              Status              Age
  1    dao-967f99798-8j2zd                               Running             26d

Please enter Id entry or keyword search, help enter [h] or exit enter [q]
context：tx，namespace：dev
keyword：dao

2、关键字重置获取全部pod
xkube> r
 Id    Name                                              Status              Age
  1    account-68c7598dbf-l8bsh                          Running             26d
  2    admin-86cdf84557-kz2qc                            Running             8d

Please enter Id entry or keyword search, help enter [h] or exit enter [q]
context：tx，namespace：dev

3、命名空间切换（同时支持模糊搜索）
xkube> user -n test
 Id    Name                                              Status              Age
  1    agent-user-7979c6b678-q7flf                       Running             28d
  2    jryg-user-797fdfbb6-b7htb                         Running             7d
  3    user-profile-center-7ff56d5d79-9d7tt              Running             28d
  4    user-service-6c6cdf5b4b-tdnvp                     Running             28d

Please enter Id entry or keyword search, help enter [h] or exit enter [q]
context：tx，namespace：test
keyword：user

4、查看crash容器日志
xkube> crash
 Id    Name                                              Status              Age
  1    scheduler-8fb9cb8c6-q6ctf                         CrashLoopBackOff    28d

Please enter Id entry or keyword search, help enter [h] or exit enter [q]
context：tx，namespace：test
keyword：crash


xkube> 1 -l
Defaulted container "scheduler" out of: scheduler, jaeger
ERROR 2023/09/27 03:17:18 get remote config: getting from etcd with key [/scheduler/config/config.yaml], res count 0 not equal to 1
panic: init viper client error: Remote Configurations Error: No Files Found

goroutine 1 [running]:
code.xxxxxx.com/xxxx/server/xx-scheduler/pkg/config.Init.func1()
	/data/jenkins/workspace/k8s_scheduler/pkg/config/root.go:21 +0xa8
sync.(*Once).doSlow(0x1000001102ecc?, 0xc00004600e?)
	/usr/local/go/src/sync/once.go:68 +0xc2
sync.(*Once).Do(...)
	/usr/local/go/src/sync/once.go:59
code.xxxxxx.com/xxxxxx/server/xxxxx-scheduler/pkg/config.Init({{0xc00004600e, 0x12}, {0x11031cc, 0x4}, {0x111ec5e, 0x1d}, 0x11786a8})
	/data/jenkins/workspace/k8s_scheduler/pkg/config/root.go:18 +0xae
code.xxxxxx.com/xxxxxx/server/xxxxxx-scheduler/cmd.initComponent()
	/data/jenkins/workspace/k8s_scheduler/cmd/root.go:39 +0xa5
github.com/spf13/cobra.(*Command).preRun(...)
	/data/jenkins/workspace/k8s_scheduler/vendor/github.com/spf13/cobra/command.go:902
github.com/spf13/cobra.(*Command).execute(0x19f3c00, {0xc00003a050, 0x0, 0x0})
	/data/jenkins/workspace/k8s_scheduler/vendor/github.com/spf13/cobra/command.go:834 +0x44e
github.com/spf13/cobra.(*Command).ExecuteC(0x19f3e80)
	/data/jenkins/workspace/k8s_scheduler/vendor/github.com/spf13/cobra/command.go:990 +0x3b4
github.com/spf13/cobra.(*Command).Execute(...)
	/data/jenkins/workspace/k8s_scheduler/vendor/github.com/spf13/cobra/command.go:918
code.xxxxxx.com/xxxxxx/server/xxxxxx-scheduler/cmd.Execute()
	/data/jenkins/workspace/k8s_scheduler/cmd/root.go:31 +0x25
main.main()
	/data/jenkins/workspace/k8s_scheduler/main.go:8 +0x17

Please enter Id entry or keyword search, help enter [h] or exit enter [q]
context：tx，namespace：test
keyword：crash

5、查看容器信息
xkube> 1 -i
containers:   [jaeger]:true [scheduler]:false 
name:         scheduler-8fb9cb8c6-q6ctf
ip:           172.19.16.13
pod state:    Running
namespace:    test
startTime:    2023-08-29T10:06:03Z

Please enter Id entry or keyword search, help enter [h] or exit enter [q]
context：tx，namespace：test
keyword：crash


6、进入默认/指定容器
xkube> 1
Defaulted container "agent-passenger" out of: agent-passenger, jaeger
/opt/app/agent-passenger-api # 

keyword：crash
xkube> 1 -c jaeger
/ $ 

7、帮助
xkube> h
Usage: INDEX [KEYWORD] [-c CONTAINER] [-l LOGS] [-i INFO] [-r RESTART] [-h HELP]
 where COMMAND is one of: [index -l|-c|-i|-r] [-n namespace] [q|r|h]
  id -l    容器日志
  id -i    Pod信息
  id -c    指定进入Pod容器名称
  id -r    Pod重启
     -n    命名空间
      h    帮助
      r    重置Pod列表
      q    退出
keyword    pod关键字

```

