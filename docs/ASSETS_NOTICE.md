# Assets Notice

本仓库不包含受版权保护的完整音频、歌词、专辑封面、歌手图片或第三方商业素材。

保留相关目录和字段仅用于展示 HarmonyOS ArkTS 音乐播放器的工程结构、播放链路、歌词解析、RDB 数据管理和 UI 交互能力。

如需本地运行完整效果，请开发者自行准备合法授权的测试资源，并按照项目中的数据结构进行替换。

## 本地私有资源配置

公开仓库只提交 `entry/src/main/resources/rawfile/local_music.private.example.json` 示例模板。

如需在本地保留完整播放效果，可以复制该文件为：

```text
entry/src/main/resources/rawfile/local_music.private.json
```

然后把其中的 `songs` 替换为你已获得合法授权的音频、歌词和封面数据。`local_music.private.json` 已加入 `.gitignore`，不会被提交到 GitHub。

启动时 App 会优先读取这个本地私有配置；如果文件不存在，则使用公开仓库中的 demo 占位数据。
