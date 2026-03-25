// 录音页面
import { AppStorageV2 } from '@kit.ArkUI'
import { UserState } from '../models/user'
import { ThemeState } from '../models/theme'
import { recorderManager, RecordState, RecordInfo } from '../utils/AvRecorderManager'
import common from '@ohos.app.ability.common'

@Builder
export function RecordBuilder() {
  Record()
}

@ComponentV2
export struct Record {
  pathStack: NavPathStack = new NavPathStack()
  userState: UserState = AppStorageV2.connect(UserState, 'USER_STATE', () => new UserState())!
  themeState: ThemeState = AppStorageV2.connect(ThemeState, 'THEME_STATE', () => new ThemeState())!
  
  @Local private recordState: RecordState = RecordState.IDLE
  @Local private duration: number = 0  // 录音时长（毫秒）
  @Local private isInitialized: boolean = false
  @Local private recordInfo: RecordInfo | null = null
  
  aboutToAppear() {
    const abilityCtx = getContext(this) as common.UIAbilityContext
    void Promise.all([
      this.userState.initFromContext(abilityCtx),
      this.themeState.initFromContext(abilityCtx),
      recorderManager.init(abilityCtx)
    ]).then(() => {
      this.isInitialized = true
      // 设置回调
      recorderManager.setOnStateChangeCallback((state: RecordState) => {
        this.recordState = state
      })
      recorderManager.setOnDurationUpdateCallback((duration: number) => {
        this.duration = duration
      })
    })
  }
  
  aboutToDisappear() {
    // 如果正在录音，停止并取消
    if (this.recordState === RecordState.RECORDING || this.recordState === RecordState.PAUSED) {
      void recorderManager.cancelRecord()
    }
  }
  
  build() {
    NavDestination() {
      Column() {
        // 录音时长显示
        Column({ space: 16 }) {
          Text(this.formatDuration(this.duration))
            .fontSize(48)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeState.getPrimaryTextColor())
          
          // 录音状态提示
          Text(this.getStateText())
            .fontSize(14)
            .fontColor(this.themeState.getSecondaryTextColor())
        }
        .width('100%')
        .padding({ top: 60, bottom: 40 })
        .alignItems(HorizontalAlign.Center)
        
        // 录音波形动画区域（占位）
        Column()
          .width('100%')
          .height(200)
          .backgroundColor(this.themeState.getCardBackgroundColor())
          .borderRadius(16)
          .margin({ left: 16, right: 16, bottom: 40 })
        
        // 录音控制按钮
        Row({ space: 24 }) {
          // 取消按钮
          if (this.recordState === RecordState.RECORDING || this.recordState === RecordState.PAUSED) {
            Button('取消')
              .width(80)
              .height(80)
              .borderRadius(40)
              .fontSize(16)
              .backgroundColor('#FF5722')
              .fontColor(Color.White)
              .onClick(() => {
                this.handleCancel()
              })
          }
          
          // 暂停/继续按钮
          if (this.recordState === RecordState.RECORDING) {
            Button('暂停')
              .width(100)
              .height(100)
              .borderRadius(50)
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .backgroundColor('#FF9800')
              .fontColor(Color.White)
              .onClick(() => {
                this.handlePause()
              })
          } else if (this.recordState === RecordState.PAUSED) {
            Button('继续')
              .width(100)
              .height(100)
              .borderRadius(50)
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .backgroundColor('#4CAF50')
              .fontColor(Color.White)
              .onClick(() => {
                this.handleResume()
              })
          }
          
          // 开始录音按钮
          if (this.recordState === RecordState.IDLE || this.recordState === RecordState.STOPPED) {
            Button('开始录音')
              .width(120)
              .height(120)
              .borderRadius(60)
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .backgroundColor('#2196F3')
              .fontColor(Color.White)
              .onClick(() => {
                this.handleStart()
              })
          }
          
          // 停止并保存按钮
          if (this.recordState === RecordState.RECORDING || this.recordState === RecordState.PAUSED) {
            Button('完成')
              .width(80)
              .height(80)
              .borderRadius(40)
              .fontSize(16)
              .backgroundColor('#4CAF50')
              .fontColor(Color.White)
              .onClick(() => {
                this.handleStop()
              })
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .padding({ bottom: 40 })
        
        // 录音信息显示
        if (this.recordInfo) {
          Column({ space: 12 }) {
            Text('录音完成')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeState.getPrimaryTextColor())
            
            Text(`时长: ${this.formatDuration(this.recordInfo.duration)}`)
              .fontSize(14)
              .fontColor(this.themeState.getSecondaryTextColor())
            
            Text(`大小: ${this.formatFileSize(this.recordInfo.fileSize)}`)
              .fontSize(14)
              .fontColor(this.themeState.getSecondaryTextColor())
            
            Button('发布到论坛')
              .width('80%')
              .height(44)
              .fontSize(16)
              .margin({ top: 16 })
              .onClick(() => {
                this.publishToForum()
              })
          }
          .width('100%')
          .padding({ left: 16, right: 16 })
          .alignItems(HorizontalAlign.Center)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeState.getBackgroundColor())
      .expandSafeArea()
    }
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack
    })
    .title('录音')
  }
  
  /**
   * 开始录音
   */
  private async handleStart(): Promise<void> {
    if (!this.isInitialized) {
      return
    }
    
    try {
      await recorderManager.startRecord()
      this.recordInfo = null
    } catch (error) {
      console.error('Failed to start recording:', error)
    }
  }
  
  /**
   * 暂停录音
   */
  private async handlePause(): Promise<void> {
    await recorderManager.pauseRecord()
  }
  
  /**
   * 继续录音
   */
  private async handleResume(): Promise<void> {
    await recorderManager.resumeRecord()
  }
  
  /**
   * 停止录音
   */
  private async handleStop(): Promise<void> {
    const info = await recorderManager.stopRecord()
    if (info) {
      this.recordInfo = info
      this.duration = info.duration
    }
  }
  
  /**
   * 取消录音
   */
  private async handleCancel(): Promise<void> {
    await recorderManager.cancelRecord()
    this.recordInfo = null
    this.duration = 0
  }
  
  /**
   * 发布到论坛
   */
  private publishToForum(): void {
    if (!this.recordInfo) {
      return
    }
    
    // 跳转到发布页面，传递录音信息
    // TODO: 实现发布页面
    this.pathStack.pop()
    // 可以在这里添加跳转到发布页面的逻辑
  }
  
  /**
   * 格式化时长显示
   */
  private formatDuration(ms: number): string {
    const totalSeconds = Math.floor(ms / 1000)
    const minutes = Math.floor(totalSeconds / 60)
    const seconds = totalSeconds % 60
    return `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`
  }
  
  /**
   * 格式化文件大小
   */
  private formatFileSize(bytes: number): string {
    if (bytes < 1024) {
      return `${bytes} B`
    } else if (bytes < 1024 * 1024) {
      return `${(bytes / 1024).toFixed(2)} KB`
    } else {
      return `${(bytes / (1024 * 1024)).toFixed(2)} MB`
    }
  }
  
  /**
   * 获取状态文本
   */
  private getStateText(): string {
    switch (this.recordState) {
      case RecordState.IDLE:
        return '准备就绪'
      case RecordState.RECORDING:
        return '录音中...'
      case RecordState.PAUSED:
        return '已暂停'
      case RecordState.STOPPED:
        return '已停止'
      default:
        return ''
    }
  }
}

