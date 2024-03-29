# Event 4 Me 项目
  
[English](https://github.com/HtmlIsTheBestProgrammingLanaguage/CS354Project/blob/main/README.md) | 简体中文

## 项目简介
  
这个项目是本人本科毕业的毕业项目，使用Flutter框架搭建，基于Google Map为用户提供基于用户定位的周围事件的App。
本项目完成于2023年4月26日，并且本人使用了此App参加了学校举行的毕业展，以及就本项目写了一篇学术报告，最终取得了不错的成绩。
**警告：请勿将本项目用于您的个人项目或用于商用，项目所有权归本人和英国斯旺西大学所有。**   
  
此项目还有与之配套的后端服务器，后端服务器也为自己本人开发，使用Jetty作为REST API接口供应。服务端的代码可以在[这里](https://github.com/HtmlIsTheBestProgrammingLanaguage/CS345Peoject-Server)找到
  
### 立项原因
  
初到英国的时候，经常会遇到巴士莫名其妙消失的原因。特别是在11月份的雨夜中等车，寒风呼啸，我发型很乱，心情也很乱。之后我才了解到，巴士取消的原因一般是由于施工原因导致线路调整，巴士半路抛锚等非人为因素导致的。这个时候我就在想，要是我早点知道就好了。因为，我可以提前规划我的出行计划，如果巴士迟迟不来，我或许可以选择乘坐其他线路的巴士，也可以搭乘出租车前往目的地，完全没有必要浪费无意义的时间在永远不会到来的巴士上。然后，我找到巴士运营公司的Twitter号，但是他们除了发一些优惠信息之外，丝毫没有提及线路临时变更或者巴士情况的任何问题。
  
这个时候，我就在想，或许有这么一款app，能够让用户基于自己的定位，发布一些自己周围的Event。比如，有用户看到了半路抛锚的巴士，然后将其作为一个Event上传到了app上。这个时候或许就正好有用户在等待这个巴士，如果他/她能够看到这个消息，或许就可以做出更加明智的决定。
  
如果将视角后退一步，app不会局限在这么一个小的场景之上，这个应用的场景有很多很多。比如，就个人来说，当我初到英国的时候，我的信用卡出现了问题，导致没办法在线支付。不幸的是，几乎所有的在线订餐App都只支持线上支付，没办法到付。然后，因为当时英国防疫政策的原因，初到英国的外国人必须居家隔离14天，才可以出门。我当时没有吃的，我感到很无助。我希望有人能够帮我去购买一些吃的，哪怕让我多给一些小费，我也十分愿意，可惜没有这个平台。所以，这个app也可以做到类似的事情，比如帮助无助的初到英国的国际留学生的第一顿晚餐。
  
我一直认为，人是生活在一个圈子里的。无论是交友圈还是舒适圈，当我们跳出这个圈子的时候，都很难去融入一个新的圈子。比如，如果我在英国有朋友的话，我或许会寻求他的帮助。又比如，如果当时我的英文足够好的话，我或许会用于敲开对面宿舍的人的门，寻求帮助。但是，这个并不是这么容易的事情。我认为我的app能够实现这个功能，让不是这个圈子的人，也有一个渠道寻求圈子内的人的帮忙。
所以，我决定创建这个app。
  
### 项目介绍
  
当用户打开App，会请求获取用户的定位。当用户允许后，将显示用户周围的Events。  

每一个Events会使用与其分类对应的图标来表示，用户点击Event后会弹出二级菜单，显示Event的信息，如标题，开始和结束时间，地点，描述等。  

使用不同颜色的文本区分Event是否已经过期，当Event过期，会显示红色。如果Event尚未开始，会显示黄色。如果Event已经开始并且尚未结束，会显示绿色。  
同时，用户可以给Event点赞，也能看到当前Event的点赞的数量。

在设置页面，会有一个Event List，这个会显示出用户自己发布的所有Event，包含所有已过期的和尚未过期的event，用户可以点击编辑Event，所有的数据会直接从之前的Event继承，并且可供修改。同时，使用不同颜色的时间来表示event是否已经过期。
  
## 项目功能
  
- 多平台：因为Flutter的特性，本项目可以部署在大部分的终端上。包括安卓，苹果，Web应用，Windows客户端
- 于服务器进行后台交互：服务器后台采用了 Jetty 作为 REST Web API 的提供，客户端会与服务端使用JSON进行交互
- 登录系统：使用 Google Firebase 的 Authentication 作为后台验证服务器，同时服务端也会对用户登录情况进行检测
- 基于定位的服务：基于用户的定位，调用Google Map获取用户定位，在服务器中使用算法返回用户周围的Events
- Event的分类：使用预设的5个分类将Event分为不同的类型。同时，可以很方便地添加新的分类
- 多语言：App支持多语言，并且语言文件是独立的，可以很方便地添加一门新的语言
- 自动刷新功能：用户可以设定 Event自动刷新
- 添加Event： 基于用户的定位添加Event，用户可以自定义编辑所有信息，也可以自由选择定位
- 定位转换：不会显示经纬度（数字），会将其替换为可阅读的文本，比如 1xx Park Street, Sketty, Uplands, Swansea。
- Event列表：用户可以在设置页面中找到自己发布的Event列表，列表会显示Event的标题和发布时间。并且会通过不同颜色的时间来提示用户Event的状态，比如未开始，已开始和已结束。
- 编辑Event：用户可以点击列表中的Event来编辑现有Event，原有Event的数据都会添加到编辑页面中，用户可以对其进行修改
- 订阅功能：用户可以选择Tags和输入当前城市来订阅Tags，当其他位于同一城市的用户发布Events的时候，就会给用订阅用户发送通知。
- 通知功能：当用户发布的Event被其他用户点击的时候，用户会收到通知。以及，当用户发布的Event过期的时候，用户也能收到通知。另外，用户可以按照tags订阅Event，当用户订阅了的tag中有其他用户发布的Event，并且发布Event的用户和当前用户处于同一个城市中，用户就会收到通知。
  
## 项目难点
  
- 零基础开发，从Flutter的学习开始：本人以前从未接触过Flutter框架，也没有接触过Drat语言。为了本项目是从头开始学习Drat和Flutter语言的
- 自主开发：开发过程中，Flutter相关问题完全自主解决。论文导师精通Jetty但是对Flutter不了解，所以在Flutter这一块我是完全自主学习自主开发的
- 数据交互：客户端和服务端之间使用JSON格式的文件进行数据交互，但是两个的编程语言是不一样的，Jetty用的是Java，Flutter用的是Drat，所以让服务端和客户端数据互通是十分有挑战性的问题
- 服务器：自主编写了后端服务器的代码，设计了服务器的框架
- 数据库：设计并使用了MySQL数据库，数据库关系满足2NF
- 后端服务器：后端服务器使用Jetty，使用不同的URL访问特定的接口以实现数据的交互，接口满足层级关系，并且服务端可以调用数据库里面的数据，读取后将其包装为恰当格式的JSON文件返回给客户端
- 双端登录检测：客户端会对用户进行登录检测，服务端也会通过用户的Token检测用户的登录状态
- 数据储存：在服务端使用MySQL储存用户数据，客户端没办法直接读取和调用数据，确保了数据的独立和安全
- 独立语言文件：项目所有的显示文本都是可以替换的，会根据不同的语言设置调用不同的语言配置文件以读取文本
- 版本控制：当完成一个大的功能的时候，会对其Commit。在主分支的Commit历史中可以看到版本控制的细节
   
## 项目使用的第三方库
- firebase相关 firebase_core: ^2.9.0
- 选择图片 image_picker: ^0.8.7
- 自定义icons material_design_icons_flutter: ^6.0.7096
- 全局变量 shared_preferences: ^2.0.13
- 照片管理 photo_manager: ^2.5.2
- 多语言支持 easy_localization: ^3.0.0
- 获取用户定位 geolocator: ^9.0.2
- 手机震动 vibration: ^1.7.5
- 将经纬度转换为地址 geocoding: ^2.1.0
- 在EventDetail中的翻译用到的 html: ^0.15.0
- 用于处理权限请求 permission_handler: ^10.2.0
- 用于发送消息，以及获取用户deviceToken firebase_messaging: ^14.4.0
- 显示通知相关 flutter_local_notifications: ^9.9.1
- 生成一个变量并且持续监听 rxdart: ^0.27.7
- 地图markers聚类相关 google_maps_cluster_manager: ^3.0.0+1
- cupertino_icons: ^1.0.2
- firebase_auth: ^4.1.3
- google_maps_flutter: ^2.0.1
- flutter_easyloading: ^3.0.3
- http: ^0.13.5
  
## 项目Demo
  
### 截图
  
![](https://github.com/HtmlIsTheBestProgrammingLanaguage/CS354Project/blob/main/demo/img/ScreenCapture%202.png)  
![](https://github.com/HtmlIsTheBestProgrammingLanaguage/CS354Project/blob/main/demo/img/ScreenCapture%203.png)  
![](https://github.com/HtmlIsTheBestProgrammingLanaguage/CS354Project/blob/main/demo/img/ScreenCapture%206.jpg)  
