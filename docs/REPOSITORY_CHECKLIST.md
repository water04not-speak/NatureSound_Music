# Repository Checklist

发布到 GitHub 前，建议按下面清单检查。

## 必须保留

- `README.md`
- `docs/screenshots/*.png`
- `docs/ARCHITECTURE.md`
- `docs/INTERVIEW_GUIDE.md`
- `entry/src/main/ets/**`
- `entry/src/main/resources/**`
- `AppScope/**`
- `build-profile.json5`
- `oh-package.json5`
- `oh-package-lock.json5`
- `hvigorfile.ts`
- `hvigor/**`
- `entry/obfuscation-rules.txt`

## 不建议提交

- `.hvigor/`
- `oh_modules/`
- `.idea/`
- `.vscode/`
- `local.properties`
- `*.p12`
- `*.csr`
- `*.key`
- `*.keystore`
- `material/`
- `*.zip`
- `*.rar`
- 临时截图总览图，如 `docs/screenshots/_contact_sheet.png`

## 公开前建议确认

- 仓库中不要出现个人证书密码、绝对路径和本机用户名。
- README 中的图片路径全部可访问。
- 可以运行项目，或至少说明签名配置方式。
- 如果删除文档、压缩包或素材文件，确认代码不会依赖它们。
- 给 GitHub 仓库添加 Topics，例如：`harmonyos`、`arkts`、`arkui`、`music-player`、`avplayer`、`rdb`。

## 如果文件已经被 Git 跟踪

`.gitignore` 只能阻止新文件进入 Git，不能自动取消已经被跟踪的文件。若 `git status` 或 `git ls-files` 仍显示本机配置和签名材料，可执行：

```bash
git rm --cached -r -- .vscode material
```

这条命令只会把文件从 Git 索引中移除，不会删除本地文件。
