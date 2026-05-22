NatureSound Music

NatureSound Music 是一款基于 HarmonyOS ArkTS 开发的音乐播放应用。项目以“万物之声”和非遗音乐内容为核心，提供音乐推荐、曲库浏览、播放控制、歌词展示、收藏、下载、社区与个人中心等功能，适合作为 HarmonyOS 音乐类应用开发实践或课程项目参考。

项目特性

- 音乐播放：基于 AVPlayer 实现在线播放、暂停、上一首、下一首、进度跳转与播放模式切换。
- 后台播放：接入 AVSession，支持音频后台播放状态同步。
- 本地数据：使用 HarmonyOS RDB 存储歌曲数据、收藏状态和种子曲库。
- 歌词展示：支持 LRC 歌词解析与播放页歌词同步展示。
- 非遗音乐：内置非遗音乐数据与地域详情页面，突出传统音乐文化内容。
- 搜索与推荐：提供歌曲搜索、首页推荐、发现页和声宴页等内容入口。
- 离线能力：包含下载管理逻辑，优先播放本地文件，失败时回退远程音频流。
- 个性化设置：支持背景、播放、下载、通知、账号安全、版本信息等设置页面。
- 响应式适配：面向 phone、tablet、2in1 设备做了基础屏幕宽度适配。

技术栈

- HarmonyOS
- ArkTS / ArkUI
- Stage 模型
- MediaKit AVPlayer
- AVSession
- RDB 关系型数据库
- Hvigor 构建系统
- Hypium 单元测试框架

项目结构

    NatureSound_Music/
    ├── AppScope/                         # 应用级配置与图标资源
    ├── entry/                            # 主业务模块
    │   ├── src/main/ets/
    │   │   ├── components/               # 通用组件
    │   │   ├── entryability/             # 应用入口 Ability
    │   │   ├── entrybackupability/       # 备份扩展 Ability
    │   │   ├── models/                   # 页面与业务数据模型
    │   │   ├── pages/                    # 页面实现
    │   │   └── utils/                    # 播放器、数据库、歌词、下载等工具
    │   └── src/main/resources/           # 图片、图标、颜色、路由等资源
    ├── 歌词/                             # 歌词资料
    ├── lyrics_dict.json                  # 歌词字典数据
    ├── update_play.py                    # 歌单/歌曲数据辅助脚本
    ├── build-profile.json5               # 工程构建配置
    └── oh-package.json5                  # 工程依赖配置

主要页面

- Start：启动/广告页
- Layout：主 Tab 容器
- Recommend：首页推荐
- Find：发现
- MusicFeast：声宴
- Community：论坛/动态
- Mine：我的
- Play：音乐播放页
- Lyric：歌词页
- Search：搜索页
- PlaylistDetail：歌单详情
- HeritageRegionDetail：非遗地域详情
- Settings 及相关子设置页面

环境要求

- DevEco Studio
- HarmonyOS SDK 5.0.5 或兼容版本
- Node.js 与 Hvigor 环境由 DevEco Studio 管理
- 支持 HarmonyOS 的模拟器或真机设备

当前工程配置：

- Bundle Name：com.xxfn.NatureSound_Music
- Version：5.0.0
- Target SDK：5.0.5(17)
- Compatible SDK：5.0.5(17)
- 设备类型：phone、tablet、2in1

快速开始

1. 克隆项目：

    git clone <your-repository-url>
    cd NatureSound_Music

1. 使用 DevEco Studio 打开项目根目录。
2. 等待工程同步并安装依赖。
3. 配置签名：
   在 DevEco Studio 中打开 File > Project Structure > Signing Configs，根据自己的开发者账号或本地调试证书重新配置签名信息。
4. 选择模拟器或真机设备，点击 Run 运行 entry 模块。

构建

可以在 DevEco Studio 中直接执行 Build，也可以使用 Hvigor 命令构建：

    hvigor assembleHap

如果使用 DevEco Studio 内置终端，请确保当前目录为项目根目录。

测试

项目包含基础测试文件：

    entry/src/test/
    entry/src/ohosTest/

可在 DevEco Studio 中运行对应测试，或根据本地 HarmonyOS 工具链使用 Hvigor 测试任务。

权限说明

应用在 entry/src/main/module.json5 中声明了以下权限：

- ohos.permission.INTERNET：访问在线歌曲、封面等网络资源。
- ohos.permission.KEEP_BACKGROUND_RUNNING：支持音频后台播放。
- ohos.permission.MICROPHONE：为相关音频能力预留。
- ohos.permission.READ_MEDIA：读取本地媒体文件。
- ohos.permission.WRITE_MEDIA：写入或缓存媒体文件。

数据说明

歌曲数据主要由以下文件和模块维护：

- entry/src/main/ets/utils/MusicSeedData.ets：默认歌曲种子数据。
- entry/src/main/ets/utils/HeritageMusicData.ets：非遗音乐种子数据。
- entry/src/main/ets/utils/MusicRepository.ets：歌曲数据仓库。
- entry/src/main/ets/utils/MusicDatabase.ets：RDB 数据库初始化与表结构。
- entry/src/main/ets/utils/LyricDictionary.ets：歌词字典读取。
- lyrics_dict.json：歌词字典源数据。

数据库名称为 nature_sound_music.rdb，歌曲表为 music_songs。

开发提示

- 新增页面后，需要在 entry/src/main/resources/base/profile/route_map.json 中补充路由映射。
- 新增主入口页面时，需要同步检查 entry/src/main/resources/base/profile/main_pages.json。
- 新增歌曲数据时，优先维护 MusicSeedData.ets 或 HeritageMusicData.ets。
- 涉及播放逻辑时，重点关注 AvPlayerBridge.ets、AvSessionManager.ets 和 PlaybackState.ets。
- 涉及收藏、搜索和曲库同步时，重点关注 MusicRepository.ets 与 MusicDatabase.ets。

注意事项

- 在线音乐与封面资源依赖外部链接，运行时需要保持网络可用。
- 公开仓库前建议移除或替换本地签名文件、个人证书、构建缓存、压缩包等非源码文件。
- 部分音频外链可能因网络、版权或服务策略无法播放，项目中已对部分 HTTP 链接做 HTTPS 规范化与回退处理。

许可证

本项目暂未声明开源许可证。若计划公开发布，请在仓库中补充 LICENSE 文件，并明确资源、图片、歌词和音频链接的使用授权。
