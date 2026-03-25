import { AppStorageV2 } from '@kit.ArkUI';
import { UserState } from '../models/user';
import { ThemeState } from '../models/theme';
import common from '@ohos.app.ability.common';

@Entry
@Component
struct Index {
  // pathStack : NavPathStack = new NavPathStack();
  // !非空断言,确保不返回null
  pathStack : NavPathStack = AppStorageV2.connect(NavPathStack,'navStack',()=>new NavPathStack())!
  // 用户状态管理
  userState: UserState = AppStorageV2.connect(UserState, 'USER_STATE', () => new UserState())!
  // 主题状态管理
  themeState: ThemeState = AppStorageV2.connect(ThemeState, 'THEME_STATE', () => new ThemeState())!
  // 标记是否正在初始化，避免重复初始化
  private isInitializing: boolean = false
  // 标记是否已经完成初始跳转
  private hasNavigated: boolean = false

  aboutToAppear(): void {
    // 在组件首次创建时初始化（aboutToAppear只在组件创建时调用一次）
    this.initAndNavigate()
  }

  build() {
    Navigation(this.pathStack){
    }.hideNavBar(true)
    //不会把自己放到控制跳转的对象里面-> 点返回的时候不会返回到这个导航页
  }

  /**
   * 初始化状态管理并根据登录状态决定跳转
   */
  private initAndNavigate(): void {
    // 如果正在初始化或已经完成跳转，不再重复执行
    if (this.isInitializing || this.hasNavigated) {
      return
    }
    
    this.isInitializing = true
    const abilityCtx = getContext(this) as common.UIAbilityContext
    
    // 初始化用户状态和主题状态
    Promise.all([
      this.userState.initFromContext(abilityCtx),
      this.themeState.initFromContext(abilityCtx)
    ]).then(() => {
      // 如果已经完成跳转，不再重复
      if (this.hasNavigated) {
        this.isInitializing = false
        return
      }
      
      // 标记为已跳转
      this.hasNavigated = true
      this.isInitializing = false
      
      // 根据登录状态决定跳转
      // 如果已登录，直接跳转到Layout；否则跳转到Start（启动页）
      if (this.userState.isLoggedIn) {
        // 已登录，直接进入主界面
        this.pathStack.pushPathByName("Layout", null, false)
      } else {
        // 未登录，显示启动页
        this.pathStack.pushPathByName("Start", null, false)
      }
    }).catch((error: Error) => {
      console.error('Failed to initialize app state:', error)
      this.isInitializing = false
      // 出错时默认跳转到Start页面（只有在未跳转过时才跳转）
      if (!this.hasNavigated) {
        this.hasNavigated = true
        this.pathStack.pushPathByName("Start", null, false)
      }
    })
  }
}