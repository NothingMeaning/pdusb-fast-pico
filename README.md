
# Raspberry Pi Pico 资源极速精选

![树莓派Pico](https://gitee.com/pdusb/pdusb-fast-pico/raw/master/img/pdusb-raspberry-pico.jpg)

Pico是很好,不过其很多资源访问起来极其缓慢.
Repo做了自动镜像,每天三次自动镜像源代码到Gitee

## Pico默认开发环境脚本的问题
1. 基于树莓派3B/4B建立,对普通PC不太适配
2. Github及其他区域下载代码,又慢又容易访问不了
3. 执行脚本一旦任何命令出错,直接退出...

## 本Repo功能大全

- 每天三次自动Mirror Pico官网资源到gitee
- 优化过的Pico开发环境建立脚本 pdusb-pico-setup.sh
- 每日自动编译最新example (WIP)

## 基于本Repo的PICO开发环境建立

![树莓派Pico](https://gitee.com/pdusb/pdusb-fast-pico/raw/master/img/pdusb-rpi-dev-env.jpg)

树莓派原生文档是在树莓派3B/4B作为开发平台,在这个开发平台上做开发和调试. 这样虽然对推广他的产品有好处.不过使用起来确实不方便.

脚本pdusb_pico_setup.sh优化为基于Ubuntu/Debian平台做开发,同时使用gitee下载代码,整体顺畅了.

```Bash
./pdusb_pico_setup.sh 
```
默认脚本会自动安装依赖(会提示输入su密码),下载相关代码,编译几个example等等


## Mirror 对应表

| Name  |  Github  |  Gitee  |
 |---|---|---|
| pico-tinyusb   |  [https://github.com/raspberrypi/tinyusb.git](https://github.com/raspberrypi/tinyusb.git)   | [https://gitee.com/pdusb/pdusb-fast-pico-tinyusb.git](https://gitee.com/pdusb/pdusb-fast-pico-tinyusb.git)   |
| pico-sdk   | [https://github.com/raspberrypi/pico-sdk.git](https://github.com/raspberrypi/pico-sdk.git)            |     [https://gitee.com/pdusb/pdusb-fast-pico-sdk.git](https://gitee.com/pdusb/pdusb-fast-pico-sdk.git)  |
| pico-examples   | [https://github.com/raspberrypi/pico-examples.git](https://github.com/raspberrypi/pico-examples.git)            |     [https://gitee.com/pdusb/pdusb-fast-pico-examples.git](https://gitee.com/pdusb/pdusb-fast-pico-examples.git)  |
| pico-extras   | [https://github.com/raspberrypi/pico-extras.git](https://github.com/raspberrypi/pico-extras.git)            |     [https://gitee.com/pdusb/pdusb-fast-pico-extras.git](https://gitee.com/pdusb/pdusb-fast-pico-extras.git)  |
| pico-playground   | [https://github.com/raspberrypi/pico-playground.git](https://github.com/raspberrypi/pico-playground.git)            |     [https://gitee.com/pdusb/pdusb-fast-pico-playground.git](https://gitee.com/pdusb/pdusb-fast-pico-playground.git)  |
| pico-picprobe   | [https://github.com/raspberrypi/picoprobe.git](https://github.com/raspberrypi/picoprobe.git)            |     [https://gitee.com/pdusb/pdusb-fast-picoprobe.git](https://gitee.com/pdusb/pdusb-fast-picoprobe.git)  |
| pico-pictool   | [https://github.com/raspberrypi/picotool.git](https://github.com/raspberrypi/picotool.git)            |     [https://gitee.com/pdusb/pdusb-fast-picotool.git](https://gitee.com/pdusb/pdusb-fast-picotool.git)  |
| pico-openocd   | [https://github.com/raspberrypi/openocd.git](https://github.com/raspberrypi/openocd.git)            |     [https://gitee.com/pdusb/pdusb-fast-openocd.git](https://gitee.com/pdusb/pdusb-fast-openocd.git)  |
| pico-lwip   | [https://git.savannah.gnu.org/git/lwip.git](https://git.savannah.gnu.org/git/lwip.git)            |     [https://gitee.com/pdusb/pdusb-fast-lwip.git](https://gitee.com/pdusb/pdusb-fast-lwip.git)  |

## Pico交流沟通

愉快的加入QQ群聊吧

![树莓派Pico群聊](https://gitee.com/pdusb/pdusb-fast-pico/raw/master/img/pdusb-qq-group.png)

