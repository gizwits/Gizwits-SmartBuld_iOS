机智云智能灯泡（单品）
=============

    使用机智云开源APP之前，需要先在机智云开发平台创建您自己的产品和应用。

    开源App需要使用您申请的AppId、AppSecret以及您自己的产品ProductKey才能正常运行。

    具体申请流程请参见：http://docs.gizwits.com/hc/。

    上述信息申请好之后，在代码中请找到"your_app_id"、"your_app_secret"、"your_product_key"字符串做相应的替换。

Gizwits Power Socket Android Demo App

	▪这是一款使用XPGWifiSDK的开源代码示例APP，可以帮助开发者快速入手，使用XPGWifiSDK开发连接机智云的物联APP。
	▪该APP针对的是智能家电中的灯泡类产品。

功能介绍

    Gizwits Light 主要展示如何使用XPGWifiSDK，开发智能空气净化器。项目中用到了大部分主要SDK接口，供使用XPGWifiSDK的开发者参
    考。主要功能如下：

	1.灯泡电源的开关
	2.灯泡色温模式和色彩模式的切换
	3.灯泡亮度的设置
	4.灯泡色彩的设置
	5.当前模式的获取和显示

	▪如果开发者希望开发的设备与以上功能类似，可参考或直接使用该APP进行修改进行快速开发自己的智能家电App。

	▪以下功能是机智云开源App的几个通用功能，除UI有些许差异外，流程和代码都几乎一致：

	1.机智云账户系统的注册、登陆、修改密码、注销等功能
	2.机智云设备管理系统的AirLink配置入网、SoftAP配置入网，设备与账号绑定、解绑定，修改设备别名等功能
	3.机智云设备的登陆，控制指令发送，状态接收，设备连接断开等功能

	▪另外，因为该项目并没有相对应的实体硬件设备供开发者使用，因此还提供了扫描虚拟设备功能，通过扫描机智云实验室内相对应的虚拟设备，可进行设备的绑定和控制等功能。同时可免费申请gokit进行设备的配置入网和绑定等流程。

项目依赖和安装

	下载代码后可直接编译运行。如果需要更新 XPGWifiSDK，请自行替换官方网站的最新版本。

硬件依赖

    Gizwits Light 项目调试，需要有调试设备的支持，您可以使用虚拟设备或者实体设备搭建调试环境。

	▪	虚拟设备
        机智云官网提供GoKit虚拟设备的支持，链接地址：
        http://site.gizwits.com/zh-cn/developer/product/5086/virtualdevice

	▪	实体设备
        GoKit开发板。您可以在机智云官方网站上免费预约申请（限量10000台），申请地址：
        http://gizwits.com/zh-cn/gokit
        
    GoKit开发板提供MCU开源代码供智能硬件设计者参考，请去此处下载：https://github.com/gizwits/gokit-mcu

问题反馈

	您可以给机智云的技术支持人员发送邮件，反馈您在使用过程中遇到的任何问题。
	邮箱：janel@gizwits.com
