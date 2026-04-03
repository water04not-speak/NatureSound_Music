import { AppStorageV2 } from '@kit.ArkUI'
import { ThemeState } from '../models/theme'
import common from '@ohos.app.ability.common'

interface DownloadQualityOption {
  label: string
  active: boolean
}

@Builder
export function DownloadSettingsBuilder() {
  DownloadSettings()
}

@ComponentV2
export struct DownloadSettings {
  pathStack: NavPathStack = new NavPathStack()
  themeState: ThemeState = AppStorageV2.connect(ThemeState, 'THEME_STATE', () => new ThemeState())!

  @Local private wifiOnly: boolean = true
  @Local private autoCleanCache: boolean = false
  @Local private downloadQuality: string = '高品质'
  @Local private cacheSize: string = '128 MB'
  @Local private feedback: string = ''

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 16 }) {
          this.renderHeader()

          this.renderToggleRow('仅 Wi-Fi 下载', '移动网络下不自动下载歌曲', this.wifiOnly, () => {
            this.wifiOnly = !this.wifiOnly
          })

          this.renderToggleRow('自动清理缓存', '保留最近使用的文件，减少占用', this.autoCleanCache, () => {
            this.autoCleanCache = !this.autoCleanCache
          })

          this.renderChoiceCard('下载音质', this.getDownloadQualityOptions())

          this.renderInfoCard('缓存占用', this.cacheSize)

          Button('清除下载缓存')
            .width('90%')
            .height(48)
            .fontSize(16)
            .fontColor(Color.White)
            .backgroundColor('#FF6B6B')
            .borderRadius(12)
            .alignSelf(ItemAlign.Center)
            .onClick(() => {
              this.cacheSize = '0 MB'
              this.feedback = '缓存已清空'
            })

          if (this.feedback) {
            Text(this.feedback)
              .fontSize(13)
              .fontColor(this.themeState.getSecondaryTextColor())
              .width('100%')
              .textAlign(TextAlign.Center)
          }
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
    .title('下载设置')
  }

  @Builder
  renderHeader() {
    Column({ space: 8 }) {
      Text('下载设置')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeState.getPrimaryTextColor())

      Text('管理离线歌曲的下载方式、音质和缓存占用。')
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
  renderChoiceCard(title: string, options: DownloadQualityOption[]) {
    Column({ space: 12 }) {
      Text(title)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeState.getPrimaryTextColor())

      Row({ space: 8 }) {
        ForEach(options, (item: DownloadQualityOption) => {
          Button(item.label)
            .layoutWeight(1)
            .height(36)
            .fontSize(12)
            .backgroundColor(item.active ? '#34C9C3' : this.themeState.getBackgroundColor())
            .fontColor(item.active ? Color.White : this.themeState.getPrimaryTextColor())
            .onClick(() => {
              this.downloadQuality = item.label
            })
        }, (item: DownloadQualityOption) => item.label)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(this.themeState.getCardBackgroundColor())
    .borderRadius(12)
    .margin({ left: 16, right: 16 })
  }

  @Builder
  renderInfoCard(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(16)
        .fontColor(this.themeState.getPrimaryTextColor())
        .layoutWeight(1)

      Text(value)
        .fontSize(14)
        .fontColor(this.themeState.getSecondaryTextColor())
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor(this.themeState.getCardBackgroundColor())
    .borderRadius(12)
    .margin({ left: 16, right: 16 })
  }

  private getDownloadQualityOptions(): DownloadQualityOption[] {
    return [
      { label: '标准', active: this.downloadQuality === '标准' },
      { label: '高品质', active: this.downloadQuality === '高品质' },
      { label: '无损', active: this.downloadQuality === '无损' }
    ]
  }
}