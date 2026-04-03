// 设置页面
import { AppStorageV2 } from '@kit.ArkUI'
import { UserState } from '../models/user'
import { ThemeState } from '../models/theme'
import common from '@ohos.app.ability.common'
import { TermsParams } from './Terms'

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
        Column({ space: 20 }) {
          this.renderHeader()

          this.renderSection('账号', [
            {
              title: '个人信息',
              icon: $r('app.media.ic_setting_more'),
              onClick: () => {
                this.pathStack.pushPathByName('UserProfile', null, false)
              }
            },
            {
              title: '账号与安全',
              icon: $r('app.media.ic_setting_more'),
              onClick: () => {
                this.pathStack.pushPathByName('AccountSecurity', null, false)
              }
            },
            {
              title: '更换背景',
              icon: $r('app.media.ic_setting_more'),
              onClick: () => {
                this.pathStack.pushPathByName('BackgroundSettings', null, false)
              }
            }
          ])

          this.renderSection('播放与下载', [
            {
              title: '播放设置',
              icon: $r('app.media.ic_setting_more'),
              onClick: () => {
                this.pathStack.pushPathByName('PlaySettings', null, false)
              }
            },
            {
              title: '下载设置',
              icon: $r('app.media.ic_setting_more'),
              onClick: () => {
                this.pathStack.pushPathByName('DownloadSettings', null, false)
              }
            },
            {
              title: '通知设置',
              icon: $r('app.media.ic_setting_more'),
              onClick: () => {
                this.pathStack.pushPathByName('NotificationSettings', null, false)
              }
            }
          ])

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
                const params = AppStorageV2.connect(TermsParams, 'TERMS_PARAMS', () => new TermsParams())!
                params.initialTab = 'terms'
                this.pathStack.pushPathByName('Terms', null, false)
              }
            },
            {
              title: '隐私政策',
              icon: $r('app.media.ic_setting_more'),
              onClick: () => {
                const params = AppStorageV2.connect(TermsParams, 'TERMS_PARAMS', () => new TermsParams())!
                params.initialTab = 'privacy'
                this.pathStack.pushPathByName('Terms', null, false)
              }
            },
            {
              title: '关于我们',
              icon: $r('app.media.ic_setting_more'),
              onClick: () => {
                this.pathStack.pushPathByName('AboutUs', null, false)
              }
            },
            {
              title: '版本信息',
              icon: $r('app.media.ic_setting_more'),
              onClick: () => {
                this.pathStack.pushPathByName('VersionInfo', null, false)
              }
            }
          ])

          Row() {
            Text('退出登录')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#FA5151')
          }
          .width('100%')
          .height(56)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(this.themeState.getCardBackgroundColor())
          .borderRadius(16)
          .margin({ left: 16, right: 16, top: 4, bottom: 24 })
          .onClick(() => {
            this.userState.logout()
            this.pathStack.clear()
            this.pathStack.replacePathByName('Login', null, false)
          })
        }
        .width('100%')
        .padding({ top: 16, bottom: 8 })
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
  renderHeader() {
    Column({ space: 10 }) {
      Image($r('app.media.mylogo'))
        .width(72)
        .height(72)
        .borderRadius(20)

      Text('设置')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeState.getPrimaryTextColor())

      Text('管理你的账号、播放和应用偏好')
        .fontSize(13)
        .fontColor(this.themeState.getSecondaryTextColor())
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 24 })
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  renderSection(title: string, items: SettingsItem[]) {
    Column({ space: 10 }) {
      Text(title)
        .fontSize(13)
        .fontColor(this.themeState.getSecondaryTextColor())
        .width('100%')
        .padding({ left: 20, right: 20 })

      Column({ space: 0 }) {
        ForEach(items, (item: SettingsItem, index: number) => {
          Row({ space: 12 }) {
            Image(item.icon)
              .width(20)
              .height(20)
              .fillColor(this.themeState.getIconColor())

            Text(item.title)
              .fontSize(16)
              .fontColor(this.themeState.getPrimaryTextColor())
              .layoutWeight(1)

            Image($r('sys.media.ohos_ic_public_arrow_right'))
              .width(16)
              .height(16)
              .fillColor(this.themeState.getSecondaryTextColor())
          }
          .width('100%')
          .height(56)
          .padding({ left: 16, right: 16 })
          .onClick(() => {
            item.onClick()
          })

          if (index < items.length - 1) {
            Divider()
              .strokeWidth(0.5)
              .color(this.themeState.getDividerColor())
              .margin({ left: 48, right: 16 })
          }
        }, (item: SettingsItem, index: number) => `${title}-${index}`)
      }
      .backgroundColor(this.themeState.getCardBackgroundColor())
      .borderRadius(18)
      .margin({ left: 16, right: 16 })
    }
    .width('100%')
  }
}

