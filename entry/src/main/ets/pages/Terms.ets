// 用户协议和隐私政策页面
import { AppStorageV2 } from '@kit.ArkUI'
import { ThemeState } from '../models/theme'
import common from '@ohos.app.ability.common'

// 协议页共享参数，避免路由时直接传对象字面量
export class TermsParams {
  initialTab: 'terms' | 'privacy' = 'terms'
}

@Builder
export function TermsBuilder() {
  Terms()
}

@ComponentV2
export struct Terms {
  @Local currentTab: 'terms' | 'privacy' = 'terms'
  
  pathStack: NavPathStack = new NavPathStack()
  themeState: ThemeState = AppStorageV2.connect(ThemeState, 'THEME_STATE', () => new ThemeState())!
  paramsState: TermsParams = AppStorageV2.connect(TermsParams, 'TERMS_PARAMS', () => new TermsParams())!
  
  build() {
    NavDestination() {
      Column() {
        // 顶部标签切换
        Row({ space: 0 }) {
          Text('用户协议')
            .fontSize(16)
            .fontWeight(this.currentTab === 'terms' ? FontWeight.Bold : FontWeight.Medium)
            .fontColor(this.currentTab === 'terms' ? this.themeState.getBrandColor() : this.themeState.getSecondaryTextColor())
            .padding({ left: 32, right: 32, top: 16, bottom: 16 })
            .onClick(() => {
              this.currentTab = 'terms'
            })
          
          Text('隐私政策')
            .fontSize(16)
            .fontWeight(this.currentTab === 'privacy' ? FontWeight.Bold : FontWeight.Medium)
            .fontColor(this.currentTab === 'privacy' ? this.themeState.getBrandColor() : this.themeState.getSecondaryTextColor())
            .padding({ left: 32, right: 32, top: 16, bottom: 16 })
            .onClick(() => {
              this.currentTab = 'privacy'
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor(this.themeState.getCardBackgroundColor())
        
        // 分割线
        Divider()
          .strokeWidth(1)
          .color(this.themeState.getDividerColor())
        
        // 内容区域
        Scroll() {
          Column({ space: 16 }) {
            if (this.currentTab === 'terms') {
              this.renderTermsContent()
            } else {
              this.renderPrivacyContent()
            }
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 20, bottom: 20 })
        }
        .layoutWeight(1)
        .width('100%')
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
    .title('用户协议与隐私政策')
  }

  aboutToAppear() {
    // 每次进入页面时同步外部设定的默认标签
    this.currentTab = this.paramsState.initialTab
  }
  
  @Builder
  renderTermsContent() {
    Column({ space: 12 }) {
      Text('万物之声用户协议')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeState.getPrimaryTextColor())
        .width('100%')
      
      Text('生效日期：2024年1月1日')
        .fontSize(12)
        .fontColor(this.themeState.getSecondaryTextColor())
        .width('100%')
        .margin({ bottom: 8 })
      
      Text('欢迎使用万物之声音乐应用！在使用本应用前，请您仔细阅读以下用户协议。')
        .fontSize(14)
        .fontColor(this.themeState.getPrimaryTextColor())
        .width('100%')
        .lineHeight(22)
      
      Text('一、服务条款的接受')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeState.getPrimaryTextColor())
        .width('100%')
        .margin({ top: 8 })
      
      Text('1.1 当您注册、登录、使用（以下统称"使用"）万物之声服务时，即表示您已阅读、理解并同意接受本协议的全部内容。\n\n1.2 如果您不同意本协议的任何内容，或者无法准确理解相关条款的含义，请不要进行后续操作。')
        .fontSize(14)
        .fontColor(this.themeState.getPrimaryTextColor())
        .width('100%')
        .lineHeight(22)
      
      Text('二、账户注册与使用')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeState.getPrimaryTextColor())
        .width('100%')
        .margin({ top: 8 })
      
      Text('2.1 您可以使用手机号、微信、QQ、微博等方式注册账户。\n\n2.2 您应当妥善保管账户信息，对账户下的所有行为负责。\n\n2.3 禁止以任何形式转让、出售或授权他人使用您的账户。')
        .fontSize(14)
        .fontColor(this.themeState.getPrimaryTextColor())
        .width('100%')
        .lineHeight(22)
      
      Text('三、服务内容')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeState.getPrimaryTextColor())
        .width('100%')
        .margin({ top: 8 })
      
      Text('3.1 万物之声为您提供音乐播放、歌单管理、社交互动等服务。\n\n3.2 我们保留随时修改、中断或终止服务的权利，无需事先通知。')
        .fontSize(14)
        .fontColor(this.themeState.getPrimaryTextColor())
        .width('100%')
        .lineHeight(22)
      
      Text('四、用户行为规范')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeState.getPrimaryTextColor())
        .width('100%')
        .margin({ top: 8 })
      
      Text('4.1 禁止发布违法违规、色情、暴力、侵权等内容。\n\n4.2 禁止恶意刷屏、广告推广等干扰其他用户的行为。\n\n4.3 违反上述规定的，我们有权暂停或终止您的账户。')
        .fontSize(14)
        .fontColor(this.themeState.getPrimaryTextColor())
        .width('100%')
        .lineHeight(22)
      
      Text('五、知识产权')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeState.getPrimaryTextColor())
        .width('100%')
        .margin({ top: 8 })
      
      Text('5.1 万物之声的所有内容（包括但不限于文字、图片、音频、视频、软件等）均受知识产权法保护。\n\n5.2 未经授权，不得复制、传播、修改或用于商业用途。')
        .fontSize(14)
        .fontColor(this.themeState.getPrimaryTextColor())
        .width('100%')
        .lineHeight(22)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
  
  @Builder
  renderPrivacyContent() {
    Column({ space: 12 }) {
      Text('万物之声隐私政策')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeState.getPrimaryTextColor())
        .width('100%')
      
      Text('生效日期：2024年1月1日')
        .fontSize(12)
        .fontColor(this.themeState.getSecondaryTextColor())
        .width('100%')
        .margin({ bottom: 8 })
      
      Text('万物之声（以下简称"我们"）非常重视您的隐私保护。本隐私政策说明了我们如何收集、使用、存储和保护您的个人信息。')
        .fontSize(14)
        .fontColor(this.themeState.getPrimaryTextColor())
        .width('100%')
        .lineHeight(22)
      
      Text('一、信息收集')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeState.getPrimaryTextColor())
        .width('100%')
        .margin({ top: 8 })
      
      Text('1.1 账户信息：手机号、用户名、密码（加密存储）等。\n\n1.2 设备信息：设备型号、操作系统版本、设备标识符等。\n\n1.3 使用信息：播放记录、收藏列表、搜索记录等。\n\n1.4 位置信息：仅在您授权的情况下收集，用于提供本地化服务。')
        .fontSize(14)
        .fontColor(this.themeState.getPrimaryTextColor())
        .width('100%')
        .lineHeight(22)
      
      Text('二、信息使用')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeState.getPrimaryTextColor())
        .width('100%')
        .margin({ top: 8 })
      
      Text('2.1 提供、维护和改进我们的服务。\n\n2.2 个性化推荐音乐内容。\n\n2.3 发送服务通知和重要更新。\n\n2.4 进行数据分析和统计，优化用户体验。')
        .fontSize(14)
        .fontColor(this.themeState.getPrimaryTextColor())
        .width('100%')
        .lineHeight(22)
      
      Text('三、信息共享')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeState.getPrimaryTextColor())
        .width('100%')
        .margin({ top: 8 })
      
      Text('3.1 我们不会向第三方出售、交易或出租您的个人信息。\n\n3.2 仅在以下情况下，我们可能会共享您的信息：\n- 获得您的明确同意\n- 法律法规要求\n- 保护我们的合法权益')
        .fontSize(14)
        .fontColor(this.themeState.getPrimaryTextColor())
        .width('100%')
        .lineHeight(22)
      
      Text('四、信息安全')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeState.getPrimaryTextColor())
        .width('100%')
        .margin({ top: 8 })
      
      Text('4.1 我们采用行业标准的安全措施保护您的个人信息。\n\n4.2 密码采用加密存储，不会以明文形式保存。\n\n4.3 定期进行安全审计和漏洞修复。')
        .fontSize(14)
        .fontColor(this.themeState.getPrimaryTextColor())
        .width('100%')
        .lineHeight(22)
      
      Text('五、您的权利')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeState.getPrimaryTextColor())
        .width('100%')
        .margin({ top: 8 })
      
      Text('5.1 访问权：您可以随时查看您的个人信息。\n\n5.2 更正权：您可以修改不准确的信息。\n\n5.3 删除权：您可以要求删除您的账户和个人信息。\n\n5.4 撤回同意：您可以随时撤回对信息处理的同意。')
        .fontSize(14)
        .fontColor(this.themeState.getPrimaryTextColor())
        .width('100%')
        .lineHeight(22)
      
      Text('六、联系我们')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeState.getPrimaryTextColor())
        .width('100%')
        .margin({ top: 8 })
      
      Text('如您对本隐私政策有任何疑问，请通过以下方式联系我们：\n邮箱：privacy@naturesound.com\n客服热线：400-xxx-xxxx')
        .fontSize(14)
        .fontColor(this.themeState.getPrimaryTextColor())
        .width('100%')
        .lineHeight(22)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}

