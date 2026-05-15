// 主题状态管理模块
import { ThemeState } from '../models/theme'
import common from '@ohos.app.ability.common'

/**
 * VersionInfo 页面构建器
 */
@Builder
export function VersionInfoBuilder() {
  VersionInfo()
}

/**
 * 版本信息页面组件
 * 展示应用版本信息、检查更新和相关设置入口
 */
@ComponentV2
export struct VersionInfo {
  pathStack: NavPathStack = new NavPathStack()
  themeState: ThemeState = new ThemeState()

  @Local private isChecking: boolean = false
  @Local private statusMsg: string = ''

  build() {
    NavDestination() {
      Column() {
        Scroll() {
          Column({ space: 32 }) {
            // 顶部 Logo 与版本区域
            this.renderHeader()

            // 操作列表
            Column({ space: 0 }) {
              this.renderActionRow('检查更新', '当前为最新版', () => {
                this.checkUpdate()
              })
              Divider().strokeWidth(0.5).color(this.themeState.getDividerColor()).margin({ left: 16, right: 16 })
              this.renderActionRow('功能介绍', '', () => {
                // 点击查看特性
              })
              Divider().strokeWidth(0.5).color(this.themeState.getDividerColor()).margin({ left: 16, right: 16 })
              this.renderActionRow('系统权限管理', '', () => {
                // 跳转系统权限
              })
            }
            .width('100%')
            .backgroundColor(this.themeState.getCardBackgroundColor())
            .borderRadius(16)
            .margin({ left: 16, right: 16 })
            
            if (this.statusMsg) {
              Text(this.statusMsg)
                .fontSize(13)
                .fontColor(this.themeState.getBrandColor())
                .width('100%')
                .textAlign(TextAlign.Center)
                .margin({ top: 10 })
            }
          }
          .width('100%')
          .padding({ top: 48, bottom: 24, left: 16, right: 16 })
        }
        .layoutWeight(1)

        // 底部版权信息
        Column({ space: 6 }) {
          Text('《万物之声用户协议》及《隐私政策》')
            .fontSize(12)
            .fontColor(this.themeState.getBrandColor())
            .onClick(() => {
               this.pathStack.pushPathByName('Terms', null, false)
            })
          Text('Copyright © 2024-2026 NatureSound All Rights Reserved.')
            .fontSize(11)
            .fontColor(this.themeState.getSecondaryTextColor())
        }
        .padding({ bottom: 32 })
        .width('100%')
        .alignItems(HorizontalAlign.Center)
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
    .title('版本信息')
  }

  /**
   * 渲染页面头部（Logo和版本信息）
   */
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

        Text('Version 5.0.0')
          .fontSize(14)
          .fontColor(this.themeState.getSecondaryTextColor())
      }
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  /**
   * 渲染操作行组件
   * @param label 操作名称
   * @param value 操作值/状态
   * @param onClick 点击回调
   */
  @Builder
  renderActionRow(label: string, value: string, onClick: () => void) {
    Row() {
      Text(label)
        .fontSize(16)
        .fontColor(this.themeState.getPrimaryTextColor())
        .layoutWeight(1)

      if (this.isChecking && label === '检查更新') {
        LoadingProgress().width(16).height(16).color(this.themeState.getSecondaryTextColor()).margin({ right: 8 })
      } else if (value) {
        Text(value)
          .fontSize(14)
          .fontColor(this.themeState.getSecondaryTextColor())
          .margin({ right: 8 })
      }

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
   * 检查更新（模拟实现）
   */
  private checkUpdate() {
    if (this.isChecking) return
    this.isChecking = true
    this.statusMsg = ''
    setTimeout(() => {
      this.isChecking = false
      this.statusMsg = '当前已是最新版本'
    }, 1500)
  }
}