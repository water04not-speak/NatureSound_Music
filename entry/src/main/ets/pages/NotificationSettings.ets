import { AppStorageV2 } from '@kit.ArkUI'
import { ThemeState } from '../models/theme'
import common from '@ohos.app.ability.common'

@Builder
export function NotificationSettingsBuilder() {
  NotificationSettings()
}

@ComponentV2
export struct NotificationSettings {
  pathStack: NavPathStack = new NavPathStack()
  themeState: ThemeState = AppStorageV2.connect(ThemeState, 'THEME_STATE', () => new ThemeState())!

  @Local private newSongNotify: boolean = true
  @Local private commentNotify: boolean = true
  @Local private playFinishNotify: boolean = true
  @Local private systemNotify: boolean = true

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 16 }) {
          this.renderHeader()
          this.renderToggleRow('新歌推荐提醒', '向你推送关注艺人的新内容', this.newSongNotify, () => {
            this.newSongNotify = !this.newSongNotify
          })
          this.renderToggleRow('评论和点赞提醒', '收到互动时及时提示', this.commentNotify, () => {
            this.commentNotify = !this.commentNotify
          })
          this.renderToggleRow('播放完成提醒', '歌曲播放结束后显示通知', this.playFinishNotify, () => {
            this.playFinishNotify = !this.playFinishNotify
          })
          this.renderToggleRow('系统通知', '允许应用发送重要系统消息', this.systemNotify, () => {
            this.systemNotify = !this.systemNotify
          })
        }
        .width('100%')
        .padding({ bottom: 24 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeState.getBackgroundColor())
      .expandSafeArea()
    }
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack
      const abilityCtx = getContext(this) as common.UIAbilityContext
      void this.themeState.initFromContext(abilityCtx)
    })
    .title('通知设置')
  }

  @Builder
  renderHeader() {
    Column({ space: 8 }) {
      Text('通知设置')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeState.getPrimaryTextColor())

      Text('控制应用消息、互动提醒和播放相关通知。')
        .fontSize(14)
        .lineHeight(22)
        .fontColor(this.themeState.getSecondaryTextColor())
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16 })
  }

  @Builder
  renderToggleRow(label: string, hint: string, value: boolean, onToggle: () => void) {
    Row() {
      Column({ space: 4 }) {
        Text(label)
          .fontSize(16)
          .fontColor(this.themeState.getPrimaryTextColor())
        Text(hint)
          .fontSize(12)
          .fontColor(this.themeState.getSecondaryTextColor())
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Button(value ? '已开启' : '已关闭')
        .height(32)
        .fontSize(12)
        .backgroundColor(value ? '#34C9C3' : this.themeState.getCardBackgroundColor())
        .fontColor(value ? Color.White : this.themeState.getPrimaryTextColor())
        .onClick(() => {
          onToggle()
        })
    }
    .width('100%')
    .height(72)
    .padding({ left: 16, right: 16 })
    .backgroundColor(this.themeState.getCardBackgroundColor())
    .borderRadius(12)
    .margin({ left: 16, right: 16 })
  }
}