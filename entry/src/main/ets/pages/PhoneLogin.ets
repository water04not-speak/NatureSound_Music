// 手机号登录页面
import { AppStorageV2 } from '@kit.ArkUI'
import common from '@ohos.app.ability.common'
import { UserState } from '../models/user'
import { ThemeState } from '../models/theme'

interface PhoneLoginFormData {
  phone: string
  code: string
}

@Builder
export function PhoneLoginBuilder() {
  PhoneLogin()
}

@ComponentV2
export struct PhoneLogin {
  @Local formData: PhoneLoginFormData = {
    phone: '',
    code: ''
  }
  @Local errorMessage: string = ''
  @Local isLogging: boolean = false
  @Local countdown: number = 0
  @Local codeSent: boolean = false
  
  pathStack: NavPathStack = new NavPathStack()
  userState: UserState = AppStorageV2.connect(UserState, 'USER_STATE', () => new UserState())!
  themeState: ThemeState = AppStorageV2.connect(ThemeState, 'THEME_STATE', () => new ThemeState())!
  
  private timerId: number | undefined = undefined
  
  aboutToDisappear(): void {
    if (this.timerId !== undefined) {
      clearInterval(this.timerId)
    }
  }
  
  // 验证手机号格式
  private isValidPhone(phone: string): boolean {
    return /^1[3-9]\d{9}$/.test(phone)
  }
  
  // 发送验证码（模拟）
  private sendCode(): void {
    if (!this.formData.phone) {
      this.errorMessage = '请输入手机号'
      return
    }
    
    if (!this.isValidPhone(this.formData.phone)) {
      this.errorMessage = '请输入正确的手机号'
      return
    }
    
    // 模拟发送验证码（实际应调用短信服务）
    this.codeSent = true
    this.countdown = 60
    this.errorMessage = ''
    
    // 模拟倒计时
    const intervalId = setInterval(() => {
      if (this.countdown > 0) {
        this.countdown--
      } else {
        clearInterval(intervalId)
        this.timerId = undefined
        this.codeSent = false
      }
    }, 1000)
    this.timerId = intervalId as number
    
    // 模拟验证码（实际应从服务器获取）
    // 这里为了演示，可以提示用户验证码
    console.info('[PhoneLogin] 模拟验证码：123456（实际应从服务器获取）')
  }
  
  // 手机号登录
  private handlePhoneLogin(): void {
    this.errorMessage = ''
    
    if (!this.formData.phone) {
      this.errorMessage = '请输入手机号'
      return
    }
    
    if (!this.isValidPhone(this.formData.phone)) {
      this.errorMessage = '请输入正确的手机号'
      return
    }
    
    if (!this.formData.code) {
      this.errorMessage = '请输入验证码'
      return
    }
    
    if (this.formData.code.length !== 6) {
      this.errorMessage = '验证码为6位数字'
      return
    }
    
    // 模拟验证（实际应调用服务器验证）
    // 这里为了演示，接受任意6位数字
    this.isLogging = true
    
    // 模拟登录请求
    setTimeout(() => {
      this.isLogging = false
      // 模拟登录成功
      const success = this.userState.loginWithPhone(this.formData.phone)
      
      if (success) {
        // 登录成功，返回Layout
        this.pathStack.clear()
        this.pathStack.replacePathByName('Layout', null, false)
      } else {
        this.errorMessage = '验证码错误或已过期'
      }
    }, 1000)
  }
  
  build() {
    NavDestination() {
      Column() {
        // Logo和标题
        Column({ space: 10 }) {
          Image($r('app.media.mylogo'))
            .width(92)
            .height(92)
            .borderRadius(46)
            .shadow({ radius: 10, color: 'rgba(0, 0, 0, 0.12)', offsetX: 0, offsetY: 6 })
          
          Text('手机号登录')
            .fontSize(22)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeState.getPrimaryTextColor())
            .margin({ top: 6 })
          
          Text('使用手机号快速登录')
            .fontSize(13)
            .fontColor(this.themeState.getSecondaryTextColor())
            .opacity(0.7)
            .margin({ top: 2 })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .margin({ top: 72, bottom: 34 })
        
        // 表单区域
        Column({ space: 16 }) {
          // 手机号输入框
          TextInput({ placeholder: '请输入手机号', text: this.formData.phone })
            .width('100%')
            .height(52)
            .backgroundColor(this.themeState.getCardBackgroundColor())
            .borderRadius(12)
            .fontColor(this.themeState.getPrimaryTextColor())
            .placeholderColor(this.themeState.getSecondaryTextColor())
            .caretColor('#34C9C3')
            .type(InputType.PhoneNumber)
            .maxLength(11)
            .padding({ left: 16, right: 16 })
            .onChange((value: string) => {
              this.formData.phone = value
              this.errorMessage = ''
            })
          
          // 验证码输入框和发送按钮
          Row({ space: 12 }) {
            TextInput({ placeholder: '请输入验证码', text: this.formData.code })
              .layoutWeight(1)
              .height(52)
              .backgroundColor(this.themeState.getCardBackgroundColor())
              .borderRadius(12)
              .fontColor(this.themeState.getPrimaryTextColor())
              .placeholderColor(this.themeState.getSecondaryTextColor())
              .caretColor('#34C9C3')
              .type(InputType.Number)
              .maxLength(6)
              .padding({ left: 16, right: 16 })
              .onChange((value: string) => {
                this.formData.code = value
                this.errorMessage = ''
              })
            
            Button(this.countdown > 0 ? `${this.countdown}秒` : '获取验证码')
              .height(52)
              .padding({ left: 16, right: 16 })
              .fontSize(14)
              .borderRadius(12)
              .backgroundColor(this.countdown > 0 ? this.themeState.getDividerColor() : '#34C9C3')
              .fontColor(Color.White)
              .enabled(this.countdown === 0 && !!this.formData.phone)
              .onClick(() => {
                this.sendCode()
              })
          }
          .width('100%')
          
          // 错误提示
          if (this.errorMessage) {
            Text(this.errorMessage)
              .fontSize(12)
              .fontColor('#FF6E9E')
              .width('100%')
              .textAlign(TextAlign.Center)
              .margin({ top: 4 })
          }
          
          // 登录按钮
          Button('登录')
            .width('100%')
            .height(52)
            .fontSize(17)
            .fontWeight(FontWeight.Medium)
            .backgroundColor('#34C9C3')
            .fontColor(Color.White)
            .borderRadius(26)
            .enabled(!this.isLogging)
            .onClick(() => {
              this.handlePhoneLogin()
            })
            .margin({ top: 24 })
            .shadow({ radius: 8, color: 'rgba(52, 201, 195, 0.3)', offsetX: 0, offsetY: 4 })
          
          // 返回账号密码登录
          Row({ space: 4 }) {
            Text('使用账号密码登录')
              .fontSize(13)
              .fontColor(this.themeState.getSecondaryTextColor())
              .onClick(() => {
                this.pathStack.pop()
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .margin({ top: 16 })
        }
        .width('100%')
        .padding({ left: 28, right: 28 })
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Start)
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
    .hideTitleBar(true)
  }
}

