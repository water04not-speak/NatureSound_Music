// 导入 ArkUI 框架的 AppStorageV2，用于全局状态管理
import { AppStorageV2 } from '@kit.ArkUI'
// 导入自定义主题状态管理类，用于管理应用的主题样式
import { ThemeState } from '../models/theme'
// 导入应用能力模块，用于获取 UIAbilityContext
import common from '@ohos.app.ability.common'
// 导入用户协议页面的参数类型定义
import { TermsParams } from './Terms'

/**
 * AboutUs 页面的 Builder 构建器函数
 * 提供统一的组件创建入口，便于在路由或其他组件中引用
 */
@Builder
export function AboutUsBuilder() {
  AboutUs()
}

/**
 * AboutUs 组件 - "关于我们"页面
 * 展示应用信息、功能入口和法律相关链接
 */
@ComponentV2
export struct AboutUs {
  // 路由导航栈，用于页面间跳转
  pathStack: NavPathStack = new NavPathStack()
  // 主题状态实例，通过 AppStorageV2 实现全局主题共享
  // 'THEME_STATE' 为全局存储键，确保主题状态在应用内一致
  themeState: ThemeState = AppStorageV2.connect(ThemeState, 'THEME_STATE', () => new ThemeState())!

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 32 }) {
          this.renderHeader()

          // 功能入口卡片
          Column({ space: 0 }) {
            this.renderLinkRow('去应用市场评分', () => {})
            Divider().strokeWidth(0.5).color(this.themeState.getDividerColor()).margin({ left: 16, right: 16 })
            // 跳转到帮助反馈页面
            this.renderLinkRow('给我们提意见', () => {
              this.pathStack.pushPathByName('Help', null, false)
            })
            Divider().strokeWidth(0.5).color(this.themeState.getDividerColor()).margin({ left: 16, right: 16 })
            this.renderLinkRow('官方微博', () => {})
          }
          .backgroundColor(this.themeState.getCardBackgroundColor())
          .borderRadius(16)
          .margin({ left: 16, right: 16 })

          // 法律信息卡片
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

  /**
   * 渲染链接行组件
   * @param label 链接文字
   * @param onClick 点击回调
   */
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

  /**
   * 打开用户协议/隐私政策页面
   * @param tab 'terms' 用户协议 | 'privacy' 隐私政策
   */
  private openTerms(tab: 'terms' | 'privacy') {
    const params = AppStorageV2.connect(TermsParams, 'TERMS_PARAMS', () => new TermsParams())!
    params.initialTab = tab
    this.pathStack.pushPathByName('Terms', null, false)
  }
}