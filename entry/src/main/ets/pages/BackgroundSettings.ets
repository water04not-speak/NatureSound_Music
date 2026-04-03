import { AppStorageV2 } from '@kit.ArkUI'
import { ThemeState } from '../models/theme'
import common from '@ohos.app.ability.common'
import { ThemeColorPicker } from '../components/ThemeColorPicker'

@Builder
export function BackgroundSettingsBuilder() {
  BackgroundSettings()
}

@ComponentV2
export struct BackgroundSettings {
  pathStack: NavPathStack = new NavPathStack()
  themeState: ThemeState = AppStorageV2.connect(ThemeState, 'THEME_STATE', () => new ThemeState())!

  build() {
    NavDestination() {
      Stack() {
        // 复用现有换肤弹窗，避免重复实现颜色与背景选择逻辑
        ThemeColorPicker({
          themeState: this.themeState,
          showPicker: true,
          onClose: () => {
            this.pathStack.pop()
          }
        })
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
    .title('更换背景')
  }
}