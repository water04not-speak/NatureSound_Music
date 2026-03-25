import { AppStorageV2 } from '@kit.ArkUI'
import common from '@ohos.app.ability.common'
import { UserState } from '../models/user'
import { ThemeState } from '../models/theme'

interface LoginFormData {
  username: string
  password: string
}

interface PlatformNames {
  wechat: string
  qq: string
  weibo: string
}

// 跳转页面入口函数
@Builder
export function LoginBuilder() {
  Login()
}
//----------------------------------登录页面-----------------------------------------------------
@ComponentV2
export struct Login {
  @Local formData: LoginFormData = {
    username: '',
    password: ''
  }
  @Local errorMessage: string = ''
  @Local isLogging: boolean = false
  @Local isAgreedToTerms: boolean = false
  
  pathStack: NavPathStack = new NavPathStack()
  userState: UserState = AppStorageV2.connect(UserState, 'USER_STATE', () => new UserState())!
  // 主题状态管理实例，用于管理背景颜色
  themeState: ThemeState = AppStorageV2.connect(ThemeState, 'THEME_STATE', () => new ThemeState())!
  
  // 登录
  private handleLogin(): void {
    this.errorMessage = ''
    
    // 验证输入
    if (!this.formData.username) {
      this.errorMessage = '请输入用户名'
      return
    }
    
    if (!this.formData.password) {
      this.errorMessage = '请输入密码'
      return
    }

    if (!this.isAgreedToTerms) {
      this.errorMessage = '请阅读并同意用户条例'
      return
    }
    
    this.isLogging = true
    
    // 登录
    const success = this.userState.login(this.formData.username, this.formData.password)
    
    this.isLogging = false
    
    if (success) {
      // 登录成功，返回到 Layout 页面（会自动显示"我的"tab，因为已登录）
      // 清除路由栈并回到 Layout
      this.pathStack.clear()
      this.pathStack.replacePathByName('Layout', null, false)
    } else {
      this.errorMessage = '用户名或密码错误'
    }
  }
  
  // 获取平台名称
  private getPlatformName(platform: 'wechat' | 'qq' | 'weibo'): string {
    if (platform === 'wechat') {
      return '微信'
    } else if (platform === 'qq') {
      return 'QQ'
    } else {
      return '微博'
    }
  }
  
  // 第三方登录处理（模拟）
  private handleThirdPartyLogin(platform: 'wechat' | 'qq' | 'weibo'): void {
    if (!this.isAgreedToTerms) {
      this.errorMessage = '请阅读并同意用户条例'
      return
    }
    
    this.isLogging = true
    this.errorMessage = ''
    
    // 模拟第三方登录流程（实际应调用SDK）
    setTimeout(() => {
      // 模拟获取到的用户信息
      const platformName = this.getPlatformName(platform)
      const mockOpenId = `${platform}_${Date.now()}`
      const mockNickname = `${platformName}用户${Math.floor(Math.random() * 10000)}`
      
      const success = this.userState.loginWithThirdParty(platform, mockOpenId, mockNickname)
      
      this.isLogging = false
      
      if (success) {
        // 登录成功
        this.pathStack.clear()
        this.pathStack.replacePathByName('Layout', null, false)
      } else {
        this.errorMessage = `${platformName}登录失败，请重试`
      }
    }, 1500)
  }
  
  build() {
    NavDestination() {
      Column() {
        // Logo与标题区域 - 更舒适的层级：放大Logo、去掉“万物之声”
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

        
        // 表单区域 - 更紧凑的间距
        Column({ space: 16 }) {
          // 用户名输入框 - 去掉标签文字
          TextInput({ placeholder: '用户名', text: this.formData.username })
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
          
          // 密码输入框 - 去掉标签文字
          TextInput({ placeholder: '密码', text: this.formData.password })
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
          
          // 错误提示
          if (this.errorMessage) {
            Text(this.errorMessage)
              .fontSize(12)
              .fontColor(this.themeState.getSecondaryTextColor())
              .width('100%')
              .textAlign(TextAlign.Center)
              .margin({ top: 4 })
          }

          // 用户条例勾选 - 更紧凑的设计
          Row({ space: 8 })
          {
            // 自定义圆形勾选按钮
            Column()
            {
              Text('✓')
                .fontSize(11)
                .fontColor(Color.White)
                .fontWeight(FontWeight.Bold)
                .opacity(this.isAgreedToTerms ? 1 : 0)
            }
            .width(18)
            .height(18)
            .borderRadius(9)
            .borderWidth(1.5)
            .borderColor(this.isAgreedToTerms ? '#34C9C3' : this.themeState.getSecondaryTextColor())
            .backgroundColor(this.isAgreedToTerms ? '#34C9C3' : Color.Transparent)
            .alignItems(HorizontalAlign.Center)
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              this.isAgreedToTerms = !this.isAgreedToTerms
              this.errorMessage = ''
            })

            // 显示文本
            Row({ space: 4 }) {
              Text('我已详细阅读')
                .fontSize(12)
                .fontColor(this.themeState.getSecondaryTextColor())
                .opacity(0.8)
              Text('《用户协议》')
                .fontSize(12)
                .fontColor(this.themeState.getPrimaryTextColor())
                .onClick(() => {
                  this.pathStack.pushPathByName('Terms', null, false)
                })
              Text('与')
                .fontSize(12)
                .fontColor(this.themeState.getSecondaryTextColor())
                .opacity(0.8)
              Text('《隐私政策》')
                .fontSize(12)
                .fontColor(this.themeState.getPrimaryTextColor())
                .onClick(() => {
                  this.pathStack.pushPathByName('Terms', null, false)
                })
            }
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
          .margin({ top: 12 })



          
          // 登录按钮 - 更圆润的设计
          Button('登录')
            .width('100%')
            .height(52)
            .fontSize(17)
            .fontWeight(FontWeight.Medium)
            .backgroundColor(this.themeState.getPrimaryTextColor())
            .fontColor(Color.White)
            .borderRadius(26)
            .enabled(!this.isLogging)
            .onClick(() => {
              this.handleLogin()
            })
            .margin({ top: 24 })
            .shadow({ radius: 8, color: 'rgba(52, 201, 195, 0.3)', offsetX: 0, offsetY: 4 })
          
          // 没有账号，去注册
          Row({ space: 4 }) {
            Text('还没有账号？')
              .fontSize(13)
              .fontColor('807F7D')
            Text('立即注册')
              .fontSize(13)
              .fontColor(this.themeState.getSecondaryTextColor())
              .fontWeight(FontWeight.Medium)
              .onClick(() => {
                this.pathStack.pushPathByName('Register', null, false)
              })
          }
          .margin({ top: 16 })

          // 其他登录方式区域 - 向上移动，间距更合理
          Column({ space: 20 }) {
            // 分割线和标题
            Row({ space: 12 }) {
              Divider()
                .strokeWidth(1)
                .color(this.themeState.getDividerColor())
                .layoutWeight(1)
              
              Text('其他登录方式')
                .fontSize(13)
                .fontColor(this.themeState.getSecondaryTextColor())
                .opacity(0.7)
              
              Divider()
                .strokeWidth(1)
                .color(this.themeState.getDividerColor())
                .layoutWeight(1)
            }
            .width('100%')

            // 四个登录按钮 - 更大更明显
            Row({ space: 36 }) {
              // 手机登录
              Image($r("app.media.button_phone"))
                .width(44)
                .height(44)
                .borderRadius(22)
                .onClick(() => {
                  // 跳转到手机号登录页面
                  this.pathStack.pushPathByName('PhoneLogin', null, false)
                })

              // 微信登录
              Image($r("app.media.button_wx"))
                .width(44)
                .height(44)
                .borderRadius(22)
                .onClick(() => {
                  this.handleThirdPartyLogin('wechat')
                })

              // QQ登录
              Image($r("app.media.button_qq"))
                .width(44)
                .height(44)
                .borderRadius(22)
                .onClick(() => {
                  this.handleThirdPartyLogin('qq')
                })

              // 微博登录
              Image($r("app.media.button_wb"))
                .width(44)
                .height(44)
                .borderRadius(22)
                .onClick(() => {
                  this.handleThirdPartyLogin('weibo')
                })
            }
            .justifyContent(FlexAlign.Center)
            .width('100%')
          }
          .width('100%')
          .margin({ top: 36 })




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
      Promise.all([
        this.userState.initFromContext(abilityCtx),
        this.themeState.initFromContext(abilityCtx)
      ]).then(() => {
        if (!this.formData.username && this.userState.username) {
          this.formData.username = this.userState.username
        }
      })
    })
    .hideTitleBar(true)
  }
}

