import { AppStorageV2 } from '@kit.ArkUI'
import common from '@ohos.app.ability.common'
import { UserState } from '../models/user'
import { ThemeState } from '../models/theme'

interface FormData {
  username: string
  password: string
  confirmPassword: string
}

// 跳转页面入口函数
@Builder
export function RegisterBuilder() {
  Register()
}
// --------------注册页面-------------------------
@ComponentV2
export struct Register {
  @Local formData: FormData = {
    username: '',
    password: '',
    confirmPassword: ''
  }
  @Local errorMessage: string = ''
  @Local isRegistering: boolean = false
  
  pathStack: NavPathStack = new NavPathStack()
  userState: UserState = AppStorageV2.connect(UserState, 'USER_STATE', () => new UserState())!
  themeState: ThemeState = AppStorageV2.connect(ThemeState, 'THEME_STATE', () => new ThemeState())!
  
  // 注册
  private handleRegister(): void {
    this.errorMessage = ''
    
    // 验证输入
    if (!this.formData.username || this.formData.username.length < 3) {
      this.errorMessage = '用户名至少需要3个字符'
      return
    }
    
    if (!this.formData.password || this.formData.password.length < 6) {
      this.errorMessage = '密码至少需要6个字符'
      return
    }
    
    if (this.formData.password !== this.formData.confirmPassword) {
      this.errorMessage = '两次输入的密码不一致'
      return
    }
    
    this.isRegistering = true
    
    // 注册用户
    const success = this.userState.register(this.formData.username, this.formData.password)
    
    this.isRegistering = false
    
    if (success) {
      // 注册成功，跳转到登录页面
      this.pathStack.pushPath({ name: 'Login' })
    } else {
      this.errorMessage = '注册失败，请重试'
    }
  }
  
  build() {
    NavDestination() {
      Column() {
        // Logo与标题区域 - 与登录页面保持一致：放大Logo、去掉“万物之声”
        Column({ space: 10 }) {
          Image($r('app.media.mylogo'))
            .width(92)
            .height(92)
            .borderRadius(46)
            .shadow({ radius: 10, color: 'rgba(0, 0, 0, 0.12)', offsetX: 0, offsetY: 6 })

          // 英文标语 - 作为主标题
          Text('Sounds of Nature')
            .fontSize(22)
            .fontStyle(FontStyle.Italic)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeState.getPrimaryTextColor())
            .fontFamily('serif')
            .opacity(0.82)
            .letterSpacing(1.1)
            .margin({ top: 6 })

          // 中文座右铭 - 次级信息
          Text('欢迎聆听音乐盛宴~')
            .fontSize(13)
            .fontWeight(FontWeight.Normal)
            .fontColor(this.themeState.getSecondaryTextColor())
            .opacity(0.7)
            .margin({ top: 2 })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .margin({ top: 72, bottom: 34 })
        
        // 表单区域 - 更简约的设计
        Column({ space: 16 }) {
          // 用户名输入框 - 去掉标签
          TextInput({ placeholder: '用户名（至少3个字符）', text: this.formData.username })
            .width('100%')
            .height(52)
            .backgroundColor(this.themeState.getCardBackgroundColor())
            .borderRadius(12)
            .fontColor(this.themeState.getPrimaryTextColor())
            .placeholderColor(this.themeState.getSecondaryTextColor())
            .caretColor('#34C9C3')
            .padding({ left: 16, right: 16 })
            .onChange((value: string) => {
              this.formData.username = value
              this.errorMessage = ''
            })
          
          // 密码输入框 - 去掉标签
          TextInput({ placeholder: '密码（至少6个字符）', text: this.formData.password })
            .type(InputType.Password)
            .width('100%')
            .height(52)
            .backgroundColor(this.themeState.getCardBackgroundColor())
            .borderRadius(12)
            .fontColor(this.themeState.getPrimaryTextColor())
            .placeholderColor(this.themeState.getSecondaryTextColor())
            .caretColor('#34C9C3')
            .padding({ left: 16, right: 16 })
            .onChange((value: string) => {
              this.formData.password = value
              this.errorMessage = ''
            })
          
          // 确认密码输入框 - 去掉标签
          TextInput({ placeholder: '确认密码', text: this.formData.confirmPassword })
            .type(InputType.Password)
            .width('100%')
            .height(52)
            .backgroundColor(this.themeState.getCardBackgroundColor())
            .borderRadius(12)
            .fontColor(this.themeState.getPrimaryTextColor())
            .placeholderColor(this.themeState.getSecondaryTextColor())
            .caretColor('#34C9C3')
            .padding({ left: 16, right: 16 })
            .onChange((value: string) => {
              this.formData.confirmPassword = value
              this.errorMessage = ''
            })
          
          // 错误提示
          if (this.errorMessage) {
            Text(this.errorMessage)
              .fontSize(12)
              .fontColor(this.themeState.getSecondaryTextColor())
              .width('100%')
              .textAlign(TextAlign.Center)
              .margin({ top: 4 })
          }
          
          // 注册按钮 - 与登录页面保持一致的样式和颜色
          Button('注册')
            .width('100%')
            .height(52)
            .fontSize(17)
            .fontWeight(FontWeight.Medium)
            .backgroundColor(this.themeState.getPrimaryTextColor())
            .fontColor(Color.White)
            .borderRadius(26)
            .enabled(!this.isRegistering)
            .onClick(() => {
              this.handleRegister()
            })
            .margin({ top: 24 })
            .shadow({ radius: 8, color: 'rgba(52, 201, 195, 0.3)', offsetX: 0, offsetY: 4 })
          
          // 已有账号，去登录
          Row({ space: 4 }) {
            Text('已有账号？')
              .fontSize(13)
              .fontColor(this.themeState.getSecondaryTextColor())
            Text('立即登录')
              .fontSize(13)
              .fontColor(this.themeState.getPrimaryTextColor())
              .fontWeight(FontWeight.Medium)
              .onClick(() => {
                this.pathStack.pushPathByName('Login', null, false)
              })
          }
          .margin({ top: 16, bottom: 20 })
        }
        .width('100%')
        .padding({ left: 28, right: 28 })
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Start)
      // 使用主题状态中的背景颜色
      .backgroundColor(this.themeState.getBackgroundColor())
      .expandSafeArea()
    }
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack
      const abilityCtx = getContext(this) as common.UIAbilityContext
      // 初始化用户状态和主题状态
      void Promise.all([
        this.userState.initFromContext(abilityCtx),
        this.themeState.initFromContext(abilityCtx)
      ])
    })
    .hideTitleBar(true)
  }
}

