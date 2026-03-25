// 主题颜色选择器组件
// 用于显示颜色选择界面，允许用户选择不同的背景颜色
import { ThemeState, ThemeColorOption } from '../models/theme'

/**
 * 主题颜色选择器组件
 * 显示一个弹窗，包含多个颜色选项供用户选择
 */
@ComponentV2
export struct ThemeColorPicker {
  // 主题状态实例，用于获取和设置颜色
  // 使用 @Param 装饰器，允许在组件初始化时传入
  @Param @Require themeState: ThemeState
  
  // 是否显示颜色选择器弹窗
  // 使用 @Param 装饰器，允许在组件初始化时传入
  @Param showPicker: boolean = false
  
  // 关闭回调函数，由父组件传入
  // 使用 @Param 装饰器，允许在组件初始化时传入
  // 提供默认空函数，使其成为可选参数
  @Param onClose: () => void = () => {}

  /**
   * 构建颜色选择器界面
   * 只有当 showPicker 为 true 时才渲染
   */
  build() {
    if (this.showPicker) {
      // 重要：把弹框整体提升到最高层级，避免被页面其它元素盖住导致点不到
      Stack() {
        // 半透明遮罩层（先渲染，保证不会盖住弹框内容）
        Column() {}
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0,0,0,0.5)')
          .position({ x: 0, y: 0 })
          .zIndex(0)
          .onClick(() => {
            if (this.onClose) {
              this.onClose()
            }
          })

        // 主内容区域（后渲染，确保在遮罩之上可点击）
        Column() {
          // 标题
          Row() {
            Text('选择背景颜色')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor(Color.White)
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .padding({ top: 16, bottom: 12 })

          // 颜色选项网格
          Grid() {
            ForEach(this.themeState.getColorOptions(), (item: ThemeColorOption, _index: number) => {
              GridItem() {
                Column({ space: 8 }) {
                  Stack() {
                    Image(item.config.backgroundImage)
                      .width(60)
                      .height(60)
                      .objectFit(ImageFit.Cover)
                      .borderRadius(8)

                    Column()
                      .width(60)
                      .height(60)
                      .backgroundColor(item.value)
                      .opacity(item.config.backgroundOverlayOpacity)
                      .borderRadius(8)

                    Column()
                      .width(60)
                      .height(60)
                      .backgroundColor('transparent')
                      .borderRadius(8)
                      .border({
                        width: this.themeState.getBackgroundColor() === item.value ? 3 : 1,
                        color: this.themeState.getBackgroundColor() === item.value ? '#FF6E9E' : '#666666'
                      })

                    if (this.themeState.getBackgroundColor() === item.value) {
                      Image($r('app.media.ic_like'))
                        .width(20)
                        .height(20)
                        .fillColor('#FF6E9E')
                    }
                  }
                  .width(60)
                  .height(60)
                  .alignContent(Alignment.Center)

                  Text(item.name)
                    .fontSize(12)
                    .fontColor(Color.White)
                    .opacity(0.9)
                }
                .width('100%')
                .height('100%')
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
                .onClick(() => {
                  this.themeState.setBackgroundColor(item.value)
                  setTimeout(() => {
                    if (this.onClose) {
                      this.onClose()
                    }
                  }, 200)
                })
              }
            }, (item: ThemeColorOption, index: number) => `color-${item.name}-${index}`)
          }
          .columnsTemplate('1fr 1fr 1fr 1fr')
          .rowsTemplate('1fr 1fr')
          .width('100%')
          .height(180)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })

          Button('关闭')
            .width('100%')
            .height(40)
            .fontSize(14)
            .margin({ top: 8 })
            .onClick(() => {
              if (this.onClose) {
                this.onClose()
              }
            })
        }
        .width('85%')
        .padding({ left: 16, right: 16, top: 16, bottom: 16 })
        .backgroundColor('#2C2C2E')
        .borderRadius(12)
        .shadow({ radius: 16, color: 'rgba(0,0,0,0.35)', offsetX: 0, offsetY: 6 })
        .position({ y: 'center' })
        .alignItems(HorizontalAlign.Center)
        .zIndex(1)
      }
      .width('100%')
      .height('100%')
      .position({ x: 0, y: 0 })
      .zIndex(999)
    }
  }
}

