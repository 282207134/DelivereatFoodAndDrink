# DeliverEat · Flutter 外卖与餐饮 App

根据 Pixso「DeliverEat - UI Kits」开发的 Flutter 应用。覆盖设计中的 **47 个手机画板**：包含三套引导方案、账号流程、点餐结算、订单配送、餐厅与个人设置。采用真实 Flutter 控件、独立页面及共享组件实现，设计图仅用于参考与对照。

## 主要界面

下方图片由 Android 模拟器运行 Flutter 应用后截取。完整截图见 [界面截图](docs/界面截图.md)，画板、路由和参考图对应关系见 [页面清单](docs/页面清单.md)。首页及个人页另附滚动到底部的截图。

| 首页 | 食品详情 | 结算 |
| --- | --- | --- |
| <img src="docs/screenshots/101-1708.png" width="220" alt="DeliverEat 首页"> | <img src="docs/screenshots/58-174.png" width="220" alt="食品详情"> | <img src="docs/screenshots/76-116.png" width="220" alt="结算"> |

| 配送跟踪 | 餐厅详情 | 个人中心 |
| --- | --- | --- |
| <img src="docs/screenshots/61-163.png" width="220" alt="配送跟踪"> | <img src="docs/screenshots/95-488.png" width="220" alt="餐厅详情"> | <img src="docs/screenshots/128-170.png" width="220" alt="个人中心"> |

## 已实现的流程

- 启动 → 三步引导 → 登录、注册或游客浏览；三套引导方案均可在页面库中访问。
- 注册资料与条款校验、密码显示隐藏、重置密码、四位验证码、设置及确认 PIN。
- 首页分类 → 搜索、分类/距离/评分筛选 → 食品详情 → 数量选择 → 加入购物车。
- 收藏切换、收藏列表、优惠券领取、优惠码应用、购物车数量调整及移除。
- 地址选择、新增地址、结算方式选择 → 演示支付 → 成功反馈 → 配送跟踪。
- 订单分为进行中、历史记录；支持取消、再次购买、确认收货、评分及评论保存。
- 配送员聊天输入及发送、餐厅发现/详情/位置展示、通知列表。
- 编辑资料、通知偏好、语言偏好、退出登录及本地状态恢复。

金额随实际商品数量计算。`DELIVER10` 提供 10% 演示折扣，折扣和总额统一保留到分。原稿中的示例金额互有差异，应用以一致的价格模型为准。

## 使用与运行

开发验证环境：Flutter **3.47.7**、Dart **3.13.5**，Android 模拟器。项目保留 Android、iOS 和 Web 平台目录；iOS 尚未在 macOS 上编译或验证。

```bash
flutter pub get
flutter run
```

指定 Android 模拟器：

```bash
flutter emulators
flutter emulators --launch <emulator-id>
flutter run -d <device-id>
```

构建 Android 安装包：

```bash
flutter build apk --debug
flutter build apk --release --target-platform android-arm64
```

安装包整理在 `deliverables/`。当前 release 构建沿用开发签名，用于本地安装体验；正式分发应配置自己的发布签名。安装包启动后可通过 **Explore as guest** 浏览；个人中心 **About Us → Explore all screens** 可打开 47 页索引。

演示验证码：`1234`。登录时姓名不能为空，密码至少六位；首次运行可使用任意满足格式的演示密码。注册、重置密码和 PIN 只模拟本地流程。

## 项目结构与架构

```text
lib/
├── main.dart                         # 初始化、本地状态加载、系统栏样式
├── app.dart                          # 应用入口、路由与手机内容宽度约束
├── data/
│   ├── catalog.dart                  # 食品/餐厅模型、演示数据、47 个画板映射
│   └── app_state.dart                # 共享状态、本地持久化、金额和订单操作
├── ui/
│   ├── theme.dart                    # Pixso 色彩、Poppins 字体、表单/按钮主题
│   └── components.dart               # 页面骨架、卡片、列表、步进器、导航等
└── features/
    ├── auth/auth_pages.dart          # 启动、三套引导、认证、验证码、PIN
    ├── discover/discover_pages.dart  # 首页、搜索/筛选、餐厅、优惠及收藏
    ├── ordering/ordering_pages.dart  # 商品、购物车、结算、地址
    ├── delivery/delivery_pages.dart  # 订单、地图、配送、聊天、评分
    └── account/account_pages.dart    # 资料、偏好、说明、退出及页面库

assets/
├── fonts/                            # Poppins 本地字体及 OFL 授权文件
└── images/                           # 从 Pixso 导出的食品/餐厅/人物等素材
test/                                 # 状态计算、持久化、页面和流程测试
integration_test/                     # Android 运行测试与全页面截图
test_driver/                          # 截图保存驱动
tool/                                 # 交付文档索引生成工具
docs/
├── design/                           # 47 张 Pixso 原始参考图及画板元数据
├── screenshots/                      # 47 页实拍及 2 张长页底部截图
├── 页面清单.md
├── 界面截图.md
└── 测试报告.md
deliverables/                         # Android 可安装包
```

采用按业务功能分组的轻量架构：

```text
页面与共享组件
      ↓ 用户操作 / 订阅状态
AppScope（InheritedNotifier）
      ↓
AppState（ChangeNotifier）
      ├── 商品、餐厅、购物车、地址、订单与评论
      └── SharedPreferences → 本机 JSON 快照
```

`AppState` 集中维护购物车计算和订单状态，组件通过 `AppScope.of(context)` 订阅变化。临时输入与页面状态（搜索文字、表单、步进数量、星级、聊天输入等）留在各页面中。路由由 `app.dart` 管理，食品和餐厅详情通过类型化参数传入。

共享 `PageFrame`、`PrimaryButton`、`Surface`、`FoodCard`、`FoodRow`、`QuantityControl` 等组件，避免逐画板复制布局。三套引导由同一个参数化页面渲染，认证和验证码流程也复用同一套页面。运行依赖仅 Flutter SDK 和 `shared_preferences`。

## 设计对应与适配

参考文件有「Thumbnail」「Component & Styles」「UI Design」三个分类。实现读取了组件字体、颜色以及 UI Design 下的 47 个手机画板；标题分组、缩略图和组件展示板不作为 App 页面。

- 主色 `#FB9400`；正文 `#171725`；次要文字 `#99999F`；成功色 `#2ECC71`。
- 使用本地 Poppins 字体，Regular / Medium / SemiBold / Bold 四种字重。
- 主要内容边距 24，卡片圆角 12，主按钮胶囊形，高度 60。
- 保留原设计英文 UI；语言页保存偏好，尚未实现全量翻译。
- 长页面可以滚动；底部操作与导航保持可达；宽屏上内容最大宽度 480。
- 原图中的重复占位食品替换为可区分的四种商品；文案、帮助和条款用可理解的演示说明替换部分占位文本。

## 数据和外部服务边界

这是可交互、可本地保存状态的前端演示。当前没有商户后端、真实账户认证、短信/邮件服务、支付接口、实时定位、远程聊天或推送服务。

个人资料、地址、购物车、收藏、优惠、订单、评论及通知/语言偏好保存在设备本地。密码和 PIN 只存在于运行内存，退出或重启后失效。聊天仅在当前页面会话中模拟发送；添加评论照片使用附带的食品演示图；头像使用参考人物图。

地图使用 Pixso 地图素材和 Flutter 绘制的示意路线，距离、配送时间和状态由演示数据提供。Visa/Mastercard 为演示选项，点击 Pay 只创建本地订单，不会产生扣款。若继续接入正式服务，可在 `data/` 中拆分仓库和远程 API，让页面保持现有组件结构。

## 测试与截图复现

```bash
flutter analyze
flutter test test/app_state_test.dart
flutter test integration_test/app_test.dart -d <device-id> --reporter expanded
flutter drive --driver=test_driver/screenshots.dart --target=integration_test/screenshots_test.dart -d <device-id>
python tool/build_docs.py
```

截图驱动使用预置数据覆盖购物车、收藏和订单等非空状态，并等待本地图片完成解码与绘制。截图按 Pixso 节点编号命名，便于逐个对照。运行结果与环境限制记录于 [测试报告](docs/测试报告.md)。

设计图片来自用户提供的 Pixso 文件，项目不额外声明这些素材的再分发授权。Poppins 授权见 `assets/fonts/OFL.txt`。
