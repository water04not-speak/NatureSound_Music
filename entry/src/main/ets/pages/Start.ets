// 跳转页面入口函数
// 进入的广告页
import { AppStorageV2 } from '@kit.ArkUI';

@Builder
export function StartBuilder() {
  Start()
}

@Component
struct Start {
  // 控制跳转的对象 - 使用共享的 NavPathStack
  pathStack: NavPathStack = AppStorageV2.connect(NavPathStack, 'navStack', () => new NavPathStack())!
  // 过三秒自动跳转到 Layout -> Start 页面打开计时 3秒后跳转
  aboutToAppear(): void { //生命周期
    setTimeout(()=>{
      this.pathStack.replacePathByName("Layout", null, false)
    },3000) // 不支持返回的跳转页面， 1000毫秒=1秒

  }

  // 响应式布局配置
  private getScreenWidth(): number {
    return px2vp(globalThis.displayInfo?.width || 360)
  }

  private getButtonWidth(): number {
    let screenWidth = this.getScreenWidth()
    if (screenWidth >= 1200) {
      return 80 // 2in1或大屏幕
    } else if (screenWidth >= 800) {
      return 70 // 平板
    } else {
      return 60 // 手机
    }
  }

  private getButtonHeight(): number {
    let screenWidth = this.getScreenWidth()
    if (screenWidth >= 1200) {
      return 40 // 2in1或大屏幕
    } else if (screenWidth >= 800) {
      return 35 // 平板
    } else {
      return 30 // 手机
    }
  }

  private getButtonMargin(): number {
    let screenWidth = this.getScreenWidth()
    if (screenWidth >= 1200) {
      return 30 // 2in1或大屏幕
    } else if (screenWidth >= 800) {
      return 20 // 平板
    } else {
      return 15 // 手机
    }
  }

  build() {
    NavDestination() {
      // Button('点击跳到布局页')
      //   .onClick(()=>{
      //     this.pathStack.pushPathByName("Layout", null, false);
      //   })
      Stack({alignContent:Alignment.TopEnd}){
        Image($r('app.media.myad'))
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
          .expandSafeArea([SafeAreaType.SYSTEM],[SafeAreaEdge.TOP,SafeAreaEdge.BOTTOM])
        Button('跳过')
          .backgroundColor(Color.Grey)
          .width(this.getButtonWidth())
          .height(this.getButtonHeight())
          .margin(this.getButtonMargin())
          .onClick(()=>{
            // this.pathStack.pushPathByName("Layout", null, false)
            this.pathStack.replacePathByName("Layout", null, false)
          })
      }
    }
    // .title('广告页')
    .onReady((context: NavDestinationContext) => {
      // 使用共享的 navStack，确保导航栈一致性
      // this.pathStack 已经通过 AppStorageV2 连接，无需重新赋值
    })
  }
}