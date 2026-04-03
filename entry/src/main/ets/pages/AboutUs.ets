import { AppStorageV2 } from '@kit.ArkUI'
import { ThemeState } from '../models/theme'
import common from '@ohos.app.ability.common'
import { TermsParams } from './Terms'

@Builder
export function AboutUsBuilder() {
  AboutUs()
}

@ComponentV2
export struct AboutUs {
  pathStack: NavPathStack = new NavPathStack()
  themeState: ThemeState = AppStorageV2.connect(ThemeState, 'THEME_STATE', () => new ThemeState())!

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 32 }) {
          this.renderHeader()

          Column({ space: 0 }) {
            this.renderLinkRow('去应用市场评分', () => {})
            Divider().strokeWidth(0.5).color(this.themeState.getDividerColor()).margin({ left: 16, right: 16 })
            this.renderLinkRow('给我们提意见', () => {
              this.pathStack.pushPathByName('Help', null, false)
            })
            Divider().strokeWidth(0.5).color(this.themeState.getDividerColor()).margin({ left: 16, right: 16 })
            this.renderLinkRow('官方微博', () => {})
          }
          .backgroundColor(this.themeState.getCardBackgroundColor())
          .borderRadius(16)
          .margin({ left: 16, right: 16 })

          Column({ space: 0 }) {
            this.renderLinkRow('用户协议', () => {
              this.openTerms('terms')
            })
            Divider().strokeWidth(0.5).color(this.themeState.getDividerColor()).margin({ left: 16, right: 16 })
            this.renderLinkRow('隐私政策', () => {
              this.openTerms('privacy')
            })
            Divider().strokeWidth(0.5).color(this.themeState.getDividerColor()).margin({ left: 16, right: 16 })
            this.renderLinkRow('备案信息', () => {})
          }
          .backgroundColor(this.themeState.getCardBackgroundColor())
          .borderRadius(16)
          .margin({ left: 16, right: 16 })
        }
        .width('100%')
        .padding({ top: 32, bottom: 24 })
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
    .title('关于我们')
  }

  @Builder
  renderHeader() {
    Column({ space: 16 }) {
      Image($r('app.media.mylogo'))
        .width(80)
        .height(80)
        .borderRadius(20)
        .shadow({ radius: 8, color: 'rgba(0,0,0,0.1)', offsetY: 4 })

      Column({ space: 8 }) {
        Text('万物之声')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeState.getPrimaryTextColor())

        Text('聆听世界最纯粹的声音')
          .fontSize(14)
          .fontColor(this.themeState.getSecondaryTextColor())
          .textAlign(TextAlign.Center)
      }
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  renderLinkRow(label: string, onClick: () => void) {
    Row() {
      Text(label)
        .fontSize(16)
        .fontColor(this.themeState.getPrimaryTextColor())
        .layoutWeight(1)

      Image($r('sys.media.ohos_ic_public_arrow_right'))
        .width(16)
        .height(16)
        .fillColor(this.themeState.getSecondaryTextColor())
    }
    .width('100%')
    .height(60)
    .padding({ left: 16, right: 16 })
    .onClick(() => {
      onClick()
    })
  }

  private openTerms(tab: 'terms' | 'privacy') {
    const params = AppStorageV2.connect(TermsParams, 'TERMS_PARAMS', () => new TermsParams())!
    params.initialTab = tab
    this.pathStack.pushPathByName('Terms', null, false)
  }
}