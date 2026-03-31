// 导入
import { Find } from "./Find";
import { Mine } from "./Mine";
import { Moment } from "./Community";
import { Recommend } from "./Recommend";
import { Register } from "./Register";
import { Login } from "./Login";
import { AppStorageV2 } from '@kit.ArkUI';
import { UserState } from '../models/user';
import { ThemeState } from '../models/theme';
import { getScreenWidthVp, resolveByScreenWidth } from '../utils/ScreenUtils';
import common from '@ohos.app.ability.common';
import {MusicFeast} from "./MusicFeast"
interface TabClass{
  text:string
  icon:ResourceStr
}
// 跳转页面入口函数
// 布局页
@Builder
export function LayoutBuilder() {
  Layout()
}

@ComponentV2
struct Layout {
  @Local currentIndex:number=0
  // 控制跳转的对象 - 使用共享的 NavPathStack
  pathStack: NavPathStack = AppStorageV2.connect(NavPathStack, 'navStack', () => new NavPathStack())!
  // 用户状态
  userState: UserState = AppStorageV2.connect(UserState, 'USER_STATE', () => new UserState())!
  // 主题状态管理实例，用于管理背景颜色
  themeState: ThemeState = AppStorageV2.connect(ThemeState, 'THEME_STATE', () => new ThemeState())!
  
  tabData:TabClass[]=[
    {text:'首页',icon:$r('app.media.ic_homepage')},
    {text:'发现',icon:$r('app.media.ic_find_songlist')},
    {text:'声宴',icon:$r('app.media.ic_music_feast')},
    {text:'论坛',icon:$r('app.media.ic_community')},
    {text:'我的',icon:$r('app.media.ic_mine')}
  ]
  
  // 检查登录状态并处理跳转
  private checkLoginAndNavigate(index: number): void {
    // 如果点击的是"我的"tab且未登录，跳转到注册页面
    if (index === 4 && !this.userState.isLoggedIn) {
      this.pathStack.pushPathByName('Register', null, false)
      // 保持当前tab不变，因为跳转后会离开当前页面
      return
    }
    this.currentIndex = index
  }

  // 响应式布局配置
  private getScreenWidth(): number {
    return getScreenWidthVp()
  }

  private getTabIconSize(): number {
    return resolveByScreenWidth(this.getScreenWidth(), 24, 28, 32)
  }

  private getTabFontSize(): number {
    return resolveByScreenWidth(this.getScreenWidth(), 14, 15, 16)
  }

  private getTabSpace(): number {
    return resolveByScreenWidth(this.getScreenWidth(), 5, 6, 8)
  }

  @Builder
  tabBuilder(item:TabClass,index:number){
    Column({space:this.getTabSpace()}){
      Image(item.icon)
        .width(this.getTabIconSize())
        .height(this.getTabIconSize())
        .fillColor(this.currentIndex===index? this.themeState.getPrimaryTextColor() :'#63AAAA')
      Text(item.text)
        .fontSize(this.getTabFontSize())
        .fontColor(this.currentIndex===index? this.themeState.getPrimaryTextColor() :'#63AAAA')
    }
  }

  aboutToAppear(): void {
    // 在页面出现时初始化状态，确保应用恢复时状态正确
    const abilityCtx = getContext(this) as common.UIAbilityContext
    // 初始化用户状态和主题状态（如果还未初始化）
    // 使用 Promise.all 确保状态完全加载
    const initPromises: Promise<void>[] = []
    
    // 只有在未初始化时才初始化
    if (!this.themeState.isThemeLoaded()) {
      initPromises.push(this.themeState.initFromContext(abilityCtx))
    }
    
    // 用户状态的初始化检查在 initFromContext 内部处理
    initPromises.push(this.userState.initFromContext(abilityCtx))
    
    if (initPromises.length > 0) {
      Promise.all(initPromises).then(() => {
        // 状态初始化完成，UI会自动更新（因为使用了@Trace装饰器）
        console.info('Layout: State initialized successfully')
      }).catch((error: Error) => {
        console.error('Layout: Failed to initialize state:', error)
      })
    }
  }

  build() {
    NavDestination() {
      Tabs({barPosition:BarPosition.End}){
        ForEach(this.tabData,(item:TabClass,index:number)=>{
          TabContent(){
            if(this.currentIndex===0){
              Recommend()
            }else if(this.currentIndex===1){
              Find()
            }else if(this.currentIndex===2){
              MusicFeast()
            }else if(this.currentIndex===3){
              Moment()
            }else if(this.currentIndex===4){
              Mine()
            }
          }
          .tabBar(this.tabBuilder(item,index)) //自定义导航栏 @builder
          // 使用主题状态中的背景颜色
          .backgroundColor(this.themeState.getBackgroundColor())
          .expandSafeArea([SafeAreaType.SYSTEM],[SafeAreaEdge.TOP,SafeAreaEdge.BOTTOM])
        })
      }
      // 使用主题状态中的背景颜色
      .backgroundColor(this.themeState.getBackgroundColor())
      .onChange((index:number)=>{
        this.checkLoginAndNavigate(index)
      })
      .expandSafeArea([SafeAreaType.SYSTEM],[SafeAreaEdge.TOP,SafeAreaEdge.BOTTOM])
    }
    // .title('布局页')
    .onReady((context: NavDestinationContext) => {
      // 使用共享的 NavPathStack，无需从 context 重新赋值
      // context.pathStack 应该就是共享的 navStack 实例
      // 初始化主题状态（作为备用，主要初始化在aboutToAppear中）
      const abilityCtx = getContext(this) as common.UIAbilityContext
      void this.themeState.initFromContext(abilityCtx)
    })
    // .expandSafeArea([SafeAreaType.SYSTEM],[SafeAreaEdge.TOP,SafeAreaEdge.BOTTOM])
  }
}