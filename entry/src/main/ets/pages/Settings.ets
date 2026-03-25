// 设置页面
import { AppStorageV2 } from '@kit.ArkUI'
import { UserState } from '../models/user'
import { ThemeState } from '../models/theme'
import common from '@ohos.app.ability.common'

interface SettingsItem {
  title: string
  icon: ResourceStr
  onClick: () => void
}

@Builder
export function SettingsBuilder() {
  Settings()
}

@ComponentV2
export struct Settings {
  pathStack: NavPathStack = new NavPathStack()
  userState: UserState = AppStorageV2.connect(UserState, 'USER_STATE', () => new UserState())!
  themeState: ThemeState = AppStorageV2.connect(ThemeState, 'THEME_STATE', () => new ThemeState())!
  
  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 0 }) {
          // 账户设置
          this.renderSection('账户设置', [
            {
              title: '个人信息',
              icon: $r('app.media.ic_setting_more'),
              onClick: () => {
                this.pathStack.pushPathByName('UserProfile', null, false)
              }
            },
            {
              title: '更换背景',
              icon: $r('app.media.ic_setting_more'),
              onClick: () => {
                // 跳转到主题选择（实际应在Mine页处理）
                this.pathStack.pop()
              }
            },
            {
              title: '账号与安全',
              icon: $r('app.media.ic_setting_more'),
              onClick: () => {
                // TODO: 实现账号安全页面
              }
            }
          ])
          
          // 通用设置
          this.renderSection('通用设置', [
            {
              title: '播放设置',
              icon: $r('app.media.ic_setting_more'),
              onClick: () => {
                // TODO: 实现播放设置页面
              }
            },
            {
              title: '下载设置',
              icon: $r('app.media.ic_setting_more'),
              onClick: () => {
                // TODO: 实现下载设置页面
              }
            },
            {
              title: '通知设置',
              icon: $r('app.media.ic_setting_more'),
              onClick: () => {
                // TODO: 实现通知设置页面
              }
            }
          ])
          
          // 关于
          this.renderSection('关于', [
            {
              title: '帮助中心',
              icon: $r('app.media.ic_setting_more'),
              onClick: () => {
                this.pathStack.pushPathByName('Help', null, false)
              }
            },
            {
              title: '用户协议',
              icon: $r('app.media.ic_setting_more'),
              onClick: () => {
                this.pathStack.pushPathByName('Terms', null, false)
              }
            },
            {
              title: '隐私政策',
              icon: $r('app.media.ic_setting_more'),
              onClick: () => {
                this.pathStack.pushPathByName('Terms', null, false)
              }
            },
            {
              title: '关于我们',
              icon: $r('app.media.ic_setting_more'),
              onClick: () => {
                // TODO: 实现关于我们页面
              }
            },
            {
              title: '版本信息',
              icon: $r('app.media.ic_setting_more'),
              onClick: () => {
                // TODO: 显示版本信息
              }
            }
          ])
          
          // 退出登录
          Row({ space: 8 }) {
            Image($r('app.media.ic_log_out'))
              .width(20)
              .height(20)
              .fillColor(this.themeState.getPrimaryTextColor())
            Text('退出登录')
              .fontSize(16)
              .fontColor(this.themeState.getPrimaryTextColor())
          }
          .width('90%')
          .height(48)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(this.themeState.getCardBackgroundColor())
          .borderRadius(12)
          .margin({ top: 24, bottom: 24 })
          .onClick(() => {
            this.userState.logout()
            this.pathStack.clear()
            this.pathStack.replacePathByName('Login', null, false)
          })
        }
        .width('100%')
        .padding({ top: 12, bottom: 20 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeState.getBackgroundColor())
      .expandSafeArea()
    }
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack
      const abilityCtx = getContext(this) as common.UIAbilityContext
      void Promise.all([
        this.userState.initFromContext(abilityCtx),
        this.themeState.initFromContext(abilityCtx)
      ])
    })
    .title('设置')
  }
  
  @Builder
  renderSection(title: string, items: SettingsItem[]) {
    Column({ space: 0 }) {
      Text(title)
        .fontSize(14)
        .fontColor(this.themeState.getSecondaryTextColor())
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 8 })
      
      Column({ space: 0 }) {
        ForEach(items, (item: SettingsItem, index: number) => {
          Row({ space: 12 }) {
            Text(item.title)
              .fontSize(16)
              .fontColor(this.themeState.getPrimaryTextColor())
              .layoutWeight(1)
            
            Image(item.icon)
              .width(20)
              .fillColor(this.themeState.getIconColor())
          }
          .width('100%')
          .height(52)
          .padding({ left: 16, right: 16 })
          .backgroundColor(this.themeState.getCardBackgroundColor())
          .onClick(() => {
            item.onClick()
          })
          
          if (index < items.length - 1) {
            Divider()
              .strokeWidth(0.5)
              .color(this.themeState.getDividerColor())
              .margin({ left: 16 })
          }
        }, (item: SettingsItem, index: number) => `${title}-${index}`)
      }
      .width('100%')
      .margin({ bottom: 16 })
    }
    .width('100%')
  }
}

