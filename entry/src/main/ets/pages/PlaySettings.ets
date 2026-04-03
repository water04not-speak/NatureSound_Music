import { AppStorageV2 } from '@kit.ArkUI'
import { ThemeState } from '../models/theme'
import common from '@ohos.app.ability.common'

interface PlaybackModeOption {
  label: string
  active: boolean
}

@Builder
export function PlaySettingsBuilder() {
  PlaySettings()
}

@ComponentV2
export struct PlaySettings {
  pathStack: NavPathStack = new NavPathStack()
  themeState: ThemeState = AppStorageV2.connect(ThemeState, 'THEME_STATE', () => new ThemeState())!

  @Local private autoPlayNext: boolean = true
  @Local private rememberProgress: boolean = true
  @Local private highQualityFirst: boolean = false
  @Local private playbackMode: string = '顺序播放'

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 16 }) {
          this.renderHeader()

          this.renderToggleRow('自动播放下一首', '当前歌曲结束后自动继续播放', this.autoPlayNext, () => {
            this.autoPlayNext = !this.autoPlayNext
          })

          this.renderToggleRow('记住播放进度', '退出后重新进入时恢复到上次位置', this.rememberProgress, () => {
            this.rememberProgress = !this.rememberProgress
          })

          this.renderToggleRow('优先高音质', '网络允许时优先选择更高音质', this.highQualityFirst, () => {
            this.highQualityFirst = !this.highQualityFirst
          })

          this.renderChoiceCard('播放模式', this.getPlaybackModeOptions())
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
    .title('播放设置')
  }

  @Builder
  renderHeader() {
    Column({ space: 8 }) {
      Text('播放设置')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeState.getPrimaryTextColor())

      Text('这些选项会影响播放页和通知栏的基础行为。')
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

  @Builder
  renderChoiceCard(title: string, options: PlaybackModeOption[]) {
    Column({ space: 12 }) {
      Text(title)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeState.getPrimaryTextColor())

      Row({ space: 8 }) {
        ForEach(options, (item: PlaybackModeOption) => {
          Button(item.label)
            .layoutWeight(1)
            .height(36)
            .fontSize(12)
            .backgroundColor(item.active ? '#34C9C3' : this.themeState.getBackgroundColor())
            .fontColor(item.active ? Color.White : this.themeState.getPrimaryTextColor())
            .onClick(() => {
              this.playbackMode = item.label
            })
        }, (item: PlaybackModeOption) => item.label)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(this.themeState.getCardBackgroundColor())
    .borderRadius(12)
    .margin({ left: 16, right: 16 })
  }

  private getPlaybackModeOptions(): PlaybackModeOption[] {
    return [
      { label: '顺序播放', active: this.playbackMode === '顺序播放' },
      { label: '单曲循环', active: this.playbackMode === '单曲循环' },
      { label: '列表循环', active: this.playbackMode === '列表循环' }
    ]
  }
}