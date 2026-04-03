import { UserState } from '../models/user'
import { ThemeState } from '../models/theme'
import common from '@ohos.app.ability.common'

interface SecurityDeviceItem {
  name: string
  detail: string
}

@Builder
export function AccountSecurityBuilder() {
  AccountSecurity()
}

@ComponentV2
export struct AccountSecurity {
  pathStack: NavPathStack = new NavPathStack()
  userState: UserState = new UserState()
  themeState: ThemeState = new ThemeState()

  @Local private feedback: string = ''
  @Local private panelMode: 'none' | 'password' | 'phone' | 'devices' = 'none'
  @Local private oldPassword: string = ''
  @Local private newPassword: string = ''
  @Local private confirmPassword: string = ''
  @Local private phoneNumber: string = ''
  @Local private deviceList: SecurityDeviceItem[] = []

  aboutToAppear() {
    this.syncSecurityState()
  }

  build() {
    NavDestination() {
      Stack() {
        Scroll() {
          Column({ space: 16 }) {
            this.renderHeader()

            this.renderInfoCard('当前账号', this.userState.username || '未登录')
            this.renderInfoCard('昵称', this.userState.nickname || '未设置')
            this.renderInfoCard('绑定手机', this.userState.phone ? this.maskPhone(this.userState.phone) : '未绑定')

            Column({ space: 0 }) {
              this.renderActionRow('修改密码', '更新当前登录密码', () => {
                this.openPasswordPanel()
              })
              Divider().strokeWidth(0.5).color(this.themeState.getDividerColor()).margin({ left: 16, right: 16 })
              this.renderActionRow('绑定手机', '用于找回与安全验证', () => {
                this.openPhonePanel()
              })
              Divider().strokeWidth(0.5).color(this.themeState.getDividerColor()).margin({ left: 16, right: 16 })
              this.renderActionRow('登录设备管理', '清理其他登录设备', () => {
                this.openDevicesPanel()
              })
            }
            .width('100%')
            .backgroundColor(this.themeState.getCardBackgroundColor())
            .borderRadius(18)
            .margin({ left: 16, right: 16 })

            if (this.feedback) {
              Text(this.feedback)
                .fontSize(13)
                .fontColor(this.themeState.getSecondaryTextColor())
                .width('100%')
                .padding({ left: 16, right: 16 })
            }
          }
          .width('100%')
          .padding({ top: 16, bottom: 24 })
        }
        .width('100%')
        .height('100%')
        .backgroundColor(this.themeState.getBackgroundColor())
        .expandSafeArea()

        if (this.panelMode !== 'none') {
          this.renderOverlay()
        }
      }
    }
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack
      const abilityCtx = getContext(this) as common.UIAbilityContext
      void Promise.all([
        this.userState.initFromContext(abilityCtx),
        this.themeState.initFromContext(abilityCtx)
      ]).then(() => {
        this.syncSecurityState()
      })
    })
    .title('账号与安全')
  }

  private syncSecurityState() {
    this.phoneNumber = this.userState.phone || ''
    this.deviceList = this.buildDeviceList()
  }

  @Builder
  renderHeader() {
    Column({ space: 8 }) {
      Text('账号与安全')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeState.getPrimaryTextColor())
        .width('100%')

      Text('管理密码、手机号与登录设备')
        .fontSize(13)
        .fontColor(this.themeState.getSecondaryTextColor())
        .width('100%')
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 24, bottom: 8 })
  }

  @Builder
  renderInfoCard(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(16)
        .fontColor(this.themeState.getPrimaryTextColor())
        .layoutWeight(1)

      Text(value)
        .fontSize(15)
        .fontColor(this.themeState.getSecondaryTextColor())
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor(this.themeState.getCardBackgroundColor())
    .borderRadius(18)
    .margin({ left: 16, right: 16 })
  }

  @Builder
  renderActionRow(label: string, hint: string, onClick: () => void) {
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

  @Builder
  renderOverlay() {
    Stack() {
      Column() {}
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.45)')
        .onClick(() => {
          this.panelMode = 'none'
        })

      Column() {
        if (this.panelMode === 'password') {
          this.renderPasswordPanel()
        } else if (this.panelMode === 'phone') {
          this.renderPhonePanel()
        } else if (this.panelMode === 'devices') {
          this.renderDevicesPanel()
        }
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  renderPasswordPanel() {
    Column({ space: 16 }) {
      Text('修改密码')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeState.getPrimaryTextColor())
        .width('100%')
        .textAlign(TextAlign.Center)

      TextInput({ placeholder: '当前密码（如无则留空）', text: this.oldPassword })
        .height(48)
        .fontColor(this.themeState.getPrimaryTextColor())
        .backgroundColor(this.themeState.getBackgroundColor())
        .borderRadius(12)
        .padding({ left: 16, right: 16 })
        .type(InputType.Password)
        .onChange((value: string) => {
          this.oldPassword = value
        })

      TextInput({ placeholder: '新密码（6位以上）', text: this.newPassword })
        .height(48)
        .fontColor(this.themeState.getPrimaryTextColor())
        .backgroundColor(this.themeState.getBackgroundColor())
        .borderRadius(12)
        .padding({ left: 16, right: 16 })
        .type(InputType.Password)
        .onChange((value: string) => {
          this.newPassword = value
        })

      TextInput({ placeholder: '确认新密码', text: this.confirmPassword })
        .height(48)
        .fontColor(this.themeState.getPrimaryTextColor())
        .backgroundColor(this.themeState.getBackgroundColor())
        .borderRadius(12)
        .padding({ left: 16, right: 16 })
        .type(InputType.Password)
        .onChange((value: string) => {
          this.confirmPassword = value
        })

      Row({ space: 16 }) {
        Button('取消')
          .layoutWeight(1)
          .height(44)
          .backgroundColor('transparent')
          .fontColor(this.themeState.getSecondaryTextColor())
          .onClick(() => {
            this.closePanel()
          })

        Button('保存')
          .layoutWeight(1)
          .height(44)
          .backgroundColor(this.themeState.getBrandColor())
          .fontColor(Color.White)
          .onClick(() => {
            void this.submitPasswordChange()
          })
      }
    }
    .width('85%')
    .padding(24)
    .backgroundColor(this.themeState.getCardBackgroundColor())
    .borderRadius(24)
  }

  @Builder
  renderPhonePanel() {
    Column({ space: 16 }) {
      Text('绑定手机')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeState.getPrimaryTextColor())
        .width('100%')
        .textAlign(TextAlign.Center)

      TextInput({ placeholder: '请输入手机号', text: this.phoneNumber })
        .height(48)
        .fontColor(this.themeState.getPrimaryTextColor())
        .backgroundColor(this.themeState.getBackgroundColor())
        .borderRadius(12)
        .padding({ left: 16, right: 16 })
        .type(InputType.PhoneNumber)
        .maxLength(11)
        .onChange((value: string) => {
          this.phoneNumber = value
        })

      Row({ space: 16 }) {
        Button('取消')
          .layoutWeight(1)
          .height(44)
          .backgroundColor('transparent')
          .fontColor(this.themeState.getSecondaryTextColor())
          .onClick(() => {
            this.closePanel()
          })

        Button('绑定')
          .layoutWeight(1)
          .height(44)
          .backgroundColor(this.themeState.getBrandColor())
          .fontColor(Color.White)
          .onClick(() => {
            void this.submitBindPhone()
          })
      }
    }
    .width('85%')
    .padding(24)
    .backgroundColor(this.themeState.getCardBackgroundColor())
    .borderRadius(24)
  }

  @Builder
  renderDevicesPanel() {
    Column({ space: 16 }) {
      Text('登录设备管理')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeState.getPrimaryTextColor())
        .width('100%')
        .textAlign(TextAlign.Center)

      ForEach(this.deviceList, (item: SecurityDeviceItem) => {
        Column({ space: 4 }) {
          Text(item.name)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeState.getPrimaryTextColor())
          Text(item.detail)
            .fontSize(13)
            .fontColor(this.themeState.getSecondaryTextColor())
        }
        .width('100%')
        .padding(16)
        .backgroundColor(this.themeState.getBackgroundColor())
        .borderRadius(12)
        .alignItems(HorizontalAlign.Start)
      }, (item: SecurityDeviceItem) => item.name)

      Row({ space: 16 }) {
        Button('关闭')
          .layoutWeight(1)
          .height(44)
          .backgroundColor('transparent')
          .fontColor(this.themeState.getSecondaryTextColor())
          .onClick(() => {
            this.closePanel()
          })

        Button('退出其他')
          .layoutWeight(1)
          .height(44)
          .backgroundColor('#FF5151')
          .fontColor(Color.White)
          .onClick(() => {
            this.deviceList = this.buildDeviceList(true)
            this.closePanel('已退出其他设备')
          })
      }
    }
    .width('85%')
    .padding(24)
    .backgroundColor(this.themeState.getCardBackgroundColor())
    .borderRadius(24)
  }

  private openPasswordPanel() {
    if (!this.userState.isLoggedIn) {
      this.showToast('请先登录后再修改密码')
      return
    }
    this.oldPassword = ''
    this.newPassword = ''
    this.confirmPassword = ''
    this.panelMode = 'password'
  }

  private openPhonePanel() {
    if (!this.userState.isLoggedIn) {
      this.showToast('请先登录后再绑定手机号')
      return
    }
    this.phoneNumber = this.userState.phone || ''
    this.panelMode = 'phone'
  }

  private openDevicesPanel() {
    if (!this.userState.isLoggedIn) {
      this.showToast('请先登录后再查看设备')
      return
    }
    this.deviceList = this.buildDeviceList()
    this.panelMode = 'devices'
  }

  private closePanel(message: string = '') {
    this.panelMode = 'none'
    if (message) {
      this.showToast(message)
    }
  }

  private async submitPasswordChange() {
    if (!this.newPassword || this.newPassword.length < 6) {
      this.showToast('新密码至少 6 位')
      return
    }

    if (this.newPassword !== this.confirmPassword) {
      this.showToast('两次输入的新密码不一致')
      return
    }

    const success = await this.userState.changePassword(this.oldPassword, this.newPassword)
    if (success) {
      this.closePanel('密码已更新')
      this.feedback = '密码修改成功'
    } else {
      this.showToast('密码修改失败，请检查原密码')
    }
  }

  private async submitBindPhone() {
    const success = await this.userState.bindPhone(this.phoneNumber)
    if (success) {
      this.closePanel('手机号已绑定')
      this.feedback = '手机号绑定成功'
      this.syncSecurityState()
    } else {
      this.showToast('手机号格式不正确或绑定失败')
    }
  }

  private buildDeviceList(keepOnlyCurrent: boolean = false): SecurityDeviceItem[] {
    const currentDevice: SecurityDeviceItem = {
      name: '当前设备',
      detail: 'HarmonyOS Phone · 在线'
    }

    if (keepOnlyCurrent) {
      return [currentDevice]
    }

    return [
      currentDevice,
      { name: '平板端', detail: '最近活跃：今天 09:20' },
      { name: '浏览器端', detail: '最近活跃：昨天 18:40' }
    ]
  }

  private maskPhone(phone: string): string {
    if (phone.length !== 11) {
      return phone
    }
    return `${phone.slice(0, 3)}****${phone.slice(7)}`
  }

  private showToast(message: string) {
    this.feedback = message
  }
}