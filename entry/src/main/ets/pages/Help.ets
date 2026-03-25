// 帮助中心页面
import { AppStorageV2 } from '@kit.ArkUI'
import { ThemeState } from '../models/theme'
import common from '@ohos.app.ability.common'

interface FAQItem {
  question: string
  answer: string
}

@Builder
export function HelpBuilder() {
  Help()
}

@ComponentV2
export struct Help {
  @Local expandedIndex: number = -1
  
  pathStack: NavPathStack = new NavPathStack()
  themeState: ThemeState = AppStorageV2.connect(ThemeState, 'THEME_STATE', () => new ThemeState())!
  
  private faqList: FAQItem[] = [
    {
      question: '如何注册账号？',
      answer: '您可以通过以下方式注册：\n1. 点击登录页面的"立即注册"按钮\n2. 输入用户名（至少3个字符）和密码（至少6个字符）\n3. 点击注册按钮完成注册\n\n您也可以使用手机号、微信、QQ、微博等第三方账号快速登录。'
    },
    {
      question: '忘记密码怎么办？',
      answer: '如果您忘记了密码，可以：\n1. 尝试使用手机号登录（验证码登录）\n2. 使用第三方账号（微信/QQ/微博）登录\n3. 联系客服重置密码\n\n注意：目前暂不支持密码找回功能，建议使用手机号或第三方账号登录。'
    },
    {
      question: '如何搜索歌曲？',
      answer: '您可以通过以下方式搜索：\n1. 在首页点击搜索框\n2. 输入歌曲名、歌手名或关键词\n3. 点击搜索结果中的歌曲即可播放\n\n您也可以使用热门搜索快速找到热门歌曲。'
    },
    {
      question: '如何创建歌单？',
      answer: '创建歌单的步骤：\n1. 进入"我的"页面\n2. 点击"我的歌单"区域\n3. 点击"创建新歌单"按钮\n4. 输入歌单名称和描述\n5. 添加歌曲到歌单\n\n您也可以从歌曲详情页直接添加到歌单。'
    },
    {
      question: '如何下载歌曲？',
      answer: '下载歌曲的方法：\n1. 找到想要下载的歌曲\n2. 点击歌曲右侧的更多按钮（三个点）\n3. 选择"下载"选项\n4. 歌曲将保存到本地，可在"我的-本地"中查看\n\n注意：下载需要网络连接，部分VIP歌曲可能需要会员权限。'
    },
    {
      question: '如何更换主题背景？',
      answer: '更换主题的步骤：\n1. 进入"我的"页面\n2. 点击右上角的设置按钮（三个点）\n3. 选择"更换背景"\n4. 在弹窗中选择您喜欢的主题颜色和背景图\n5. 点击确认即可应用新主题\n\n主题设置会自动保存，下次打开应用时会保持您的选择。'
    },
    {
      question: '如何分享歌曲？',
      answer: '分享歌曲的方法：\n1. 在动态页面找到想要分享的歌曲\n2. 点击歌曲下方的"分享"按钮\n3. 选择分享方式（微信、QQ、微博等）\n4. 完成分享\n\n您也可以分享整个歌单或动态。'
    },
    {
      question: '播放时如何切换歌曲？',
      answer: '切换歌曲的方式：\n1. 在播放页面点击上一首/下一首按钮\n2. 在播放列表中选择歌曲\n3. 使用通知栏的播放控制\n4. 在锁屏界面使用播放控制\n\n您也可以在设置中开启自动播放下一首。'
    },
    {
      question: '如何清除缓存？',
      answer: '清除缓存的方法：\n1. 进入"我的"页面\n2. 点击"设置"\n3. 选择"通用设置"\n4. 点击"清除缓存"\n5. 确认清除\n\n清除缓存会删除临时文件，但不会删除下载的歌曲。'
    },
    {
      question: '如何联系客服？',
      answer: '您可以通过以下方式联系我们：\n1. 在"设置-帮助中心"页面找到联系方式\n2. 发送邮件至：support@naturesound.com\n3. 客服热线：400-xxx-xxxx（工作日 9:00-18:00）\n4. 在应用内提交反馈\n\n我们会尽快回复您的问题。'
    }
  ]
  
  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 0 }) {
          // 常见问题
          Text('常见问题')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeState.getPrimaryTextColor())
            .width('100%')
            .padding({ left: 16, right: 16, top: 16, bottom: 12 })
          
          Column({ space: 0 }) {
            ForEach(this.faqList, (item: FAQItem, index: number) => {
              Column({ space: 0 }) {
                Row({ space: 12 }) {
                  Text(item.question)
                    .fontSize(15)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeState.getPrimaryTextColor())
                    .layoutWeight(1)
                  
                  Image($r('app.media.ic_more'))
                    .width(20)
                    .fillColor(this.themeState.getIconColor())
                    .rotate({ angle: this.expandedIndex === index ? 90 : 0 })
                }
                .width('100%')
                .height(56)
                .padding({ left: 16, right: 16 })
                .backgroundColor(this.themeState.getCardBackgroundColor())
                .onClick(() => {
                  this.expandedIndex = this.expandedIndex === index ? -1 : index
                })
                
                if (this.expandedIndex === index) {
                  Text(item.answer)
                    .fontSize(14)
                    .fontColor(this.themeState.getSecondaryTextColor())
                    .width('100%')
                    .padding({ left: 16, right: 16, top: 12, bottom: 16 })
                    .backgroundColor(this.themeState.getCardBackgroundColor())
                    .lineHeight(22)
                }
                
                Divider()
                  .strokeWidth(0.5)
                  .color(this.themeState.getDividerColor())
                  .margin({ left: 16 })
              }
              .width('100%')
            }, (item: FAQItem, index: number) => `faq-${index}`)
          }
          .width('100%')
          .margin({ bottom: 24 })
          
          // 联系方式
          Column({ space: 12 }) {
            Text('联系我们')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeState.getPrimaryTextColor())
              .width('100%')
              .padding({ left: 16, right: 16, bottom: 8 })
            
            Column({ space: 12 }) {
              this.renderContactItem('客服邮箱', 'support@naturesound.com')
              this.renderContactItem('客服热线', '400-xxx-xxxx')
              this.renderContactItem('工作时间', '工作日 9:00-18:00')
            }
            .width('100%')
            .padding({ left: 16, right: 16 })
          }
          .width('100%')
        }
        .width('100%')
        .padding({ bottom: 20 })
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
    .title('帮助中心')
  }
  
  @Builder
  renderContactItem(label: string, value: string) {
    Row({ space: 12 }) {
      Text(label)
        .fontSize(14)
        .fontColor(this.themeState.getSecondaryTextColor())
        .width(80)
      
      Text(value)
        .fontSize(14)
        .fontColor(this.themeState.getPrimaryTextColor())
        .layoutWeight(1)
    }
    .width('100%')
    .height(44)
    .padding({ left: 16, right: 16 })
    .backgroundColor(this.themeState.getCardBackgroundColor())
    .borderRadius(8)
  }
}

