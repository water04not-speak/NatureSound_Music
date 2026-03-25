// 个人信息编辑页面
import { AppStorageV2 } from '@kit.ArkUI'
import { UserState, Gender } from '../models/user'
import { ThemeState } from '../models/theme'
import common from '@ohos.app.ability.common'
import picker from '@ohos.file.picker'

// 性别选项接口（必须在文件顶层定义）
interface GenderOption {
  label: string
  value: Gender
}

@Builder
export function UserProfileBuilder() {
  UserProfile()
}

@ComponentV2
export struct UserProfile {
  pathStack: NavPathStack = new NavPathStack()
  userState: UserState = AppStorageV2.connect(UserState, 'USER_STATE', () => new UserState())!
  themeState: ThemeState = AppStorageV2.connect(ThemeState, 'THEME_STATE', () => new ThemeState())!

  @Local private nickname: string = ''
  @Local private gender: Gender = Gender.UNKNOWN
  @Local private age: number = 0
  @Local private avatarPath: string = ''
  @Local private bio: string = ''
  @Local private isSaving: boolean = false
  @Local private saveMessage: string = ''

  // 性别选项
  private readonly genderOptions: GenderOption[] = [
    { label: '男', value: Gender.MALE },
    { label: '女', value: Gender.FEMALE },
    { label: '其他', value: Gender.OTHER },
    { label: '未知', value: Gender.UNKNOWN }
  ]

  aboutToAppear() {
    // 初始化表单数据
    this.nickname = this.userState.nickname || this.userState.username
    this.gender = this.userState.gender
    this.age = this.userState.age
    this.avatarPath = this.userState.getAvatarPath()
    this.bio = this.userState.bio || ''
  }

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 24 }) {
          // 头像区域
          Column({ space: 12 }) {
            Stack() {
              if (this.avatarPath) {
                Image(this.avatarPath)
                  .width(120)
                  .height(120)
                  .borderRadius(60)
                  .border({ width: 3, color: Color.White })
              } else {
                Image($r('app.media.mylogo'))
                  .width(120)
                  .height(120)
                  .borderRadius(60)
                  .border({ width: 3, color: Color.White })
              }

              // 编辑图标
              Column() {
                Image($r('app.media.ic_setting'))
                  .width(24)
                  .height(24)
                  .fillColor(Color.White)
              }
              .width(36)
              .height(36)
              .backgroundColor('#000000')
              .opacity(0.6)
              .borderRadius(18)
              .justifyContent(FlexAlign.Center)
              .position({ x: 90, y: 90 })
            }
            .width(120)
            .height(120)

            Text('点击更换头像')
              .fontSize(14)
              .fontColor(this.themeState.getSecondaryTextColor())
          }
          .width('100%')
          .padding({ top: 24, bottom: 12 })
          .alignItems(HorizontalAlign.Center)
          .onClick(() => {
            this.selectAvatar()
          })

          // 昵称输入
          Column({ space: 8 }) {
            Text('昵称')
              .fontSize(14)
              .fontColor(this.themeState.getSecondaryTextColor())
              .width('100%')
              .textAlign(TextAlign.Start)

            TextInput({ placeholder: '请输入昵称', text: this.nickname })
              .width('100%')
              .height(48)
              .backgroundColor(this.themeState.getCardBackgroundColor())
              .borderRadius(8)
              .fontSize(16)
              .fontColor(this.themeState.getPrimaryTextColor())
              .onChange((value: string) => {
                this.nickname = value
              })
          }
          .width('100%')
          .padding({ left: 16, right: 16 })

          // 性别选择
          Column({ space: 8 }) {
            Text('性别')
              .fontSize(14)
              .fontColor(this.themeState.getSecondaryTextColor())
              .width('100%')
              .textAlign(TextAlign.Start)

            Row({ space: 12 }) {
              ForEach(this.genderOptions, (option: GenderOption) => {
                Button(option.label)
                  .layoutWeight(1)
                  .height(44)
                  .fontSize(14)
                  .type(this.gender === option.value ? ButtonType.Capsule : ButtonType.Normal)
                  .backgroundColor(
                    this.gender === option.value
                      ? '#007AFF'
                      : this.themeState.getCardBackgroundColor()
                  )
                  .fontColor(
                    this.gender === option.value
                      ? Color.White
                      : this.themeState.getPrimaryTextColor()
                  )
                  .onClick(() => {
                    this.gender = option.value
                  })
              }, (option: GenderOption) => option.value)
            }
            .width('100%')
          }
          .width('100%')
          .padding({ left: 16, right: 16 })

          // 年龄输入
          Column({ space: 8 }) {
            Text('年龄')
              .fontSize(14)
              .fontColor(this.themeState.getSecondaryTextColor())
              .width('100%')
              .textAlign(TextAlign.Start)

            TextInput({
              placeholder: '请输入年龄',
              text: this.age > 0 ? this.age.toString() : ''
            })
              .width('100%')
              .height(48)
              .backgroundColor(this.themeState.getCardBackgroundColor())
              .borderRadius(8)
              .fontSize(16)
              .fontColor(this.themeState.getPrimaryTextColor())
              .type(InputType.Number)
              .onChange((value: string) => {
                const ageNum = parseInt(value)
                if (!isNaN(ageNum) && ageNum >= 0) {
                  this.age = ageNum
                } else if (value === '') {
                  this.age = 0
                }
              })
          }
          .width('100%')
          .padding({ left: 16, right: 16 })

          // 个性签名输入
          Column({ space: 8 }) {
            Text('个性签名')
              .fontSize(14)
              .fontColor(this.themeState.getSecondaryTextColor())
              .width('100%')
              .textAlign(TextAlign.Start)

            TextInput({
              placeholder: '请输入个性签名（最多40字）',
              text: this.bio
            })
              .width('100%')
              .height(48)
              .backgroundColor(this.themeState.getCardBackgroundColor())
              .borderRadius(8)
              .fontSize(16)
              .fontColor(this.themeState.getPrimaryTextColor())
              .onChange((value: string) => {
                // 限制字数为40字
                if (value.length > 40) {
                  this.bio = value.substring(0, 40)
                } else {
                  this.bio = value
                }
              })
          }
          .width('100%')
          .padding({ left: 16, right: 16 })

          // 保存按钮
          Button('保存')
            .width('90%')
            .height(48)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .enabled(!this.isSaving)
            .onClick(() => {
              this.saveProfile()
            })
            .margin({ top: 24, bottom: 24 })

          // 保存提示信息
          if (this.saveMessage) {
            Text(this.saveMessage)
              .fontSize(14)
              .fontColor(this.saveMessage.includes('成功') ? '#4CAF50' : '#FF5722')
              .width('90%')
              .textAlign(TextAlign.Center)
              .margin({ bottom: 12 })
          }
        }
        .width('100%')
        .padding({ top: 12, bottom: 20 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeState.getBackgroundColor())
      .expandSafeArea()
    }
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack
      const abilityCtx = getContext(this) as common.UIAbilityContext
      void Promise.all([
        this.userState.initFromContext(abilityCtx),
        this.themeState.initFromContext(abilityCtx)
      ]).then(() => {
        // 重新加载用户信息
        this.nickname = this.userState.nickname || this.userState.username
        this.gender = this.userState.gender
        this.age = this.userState.age
        this.avatarPath = this.userState.getAvatarPath()
        this.bio = this.userState.bio || ''
      })
    })
    .title('个人信息')
  }

  /**
   * 选择头像
   */
  private async selectAvatar() {
    try {
      const photoSelectOptions = new picker.PhotoSelectOptions()
      photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE
      photoSelectOptions.maxSelectNumber = 1

      const photoPicker = new picker.PhotoViewPicker()
      const photoSelectResult = await photoPicker.select(photoSelectOptions)

      if (photoSelectResult && photoSelectResult.photoUris && photoSelectResult.photoUris.length > 0) {
        const imageUri = photoSelectResult.photoUris[0]

        // 更新头像
        this.isSaving = true
        this.saveMessage = '正在保存头像...'
        const success = await this.userState.updateAvatar(imageUri)
        this.isSaving = false

        if (success) {
          this.avatarPath = this.userState.getAvatarPath()
          this.saveMessage = '头像更新成功'
          setTimeout(() => {
            this.saveMessage = ''
          }, 2000)
        } else {
          this.saveMessage = '头像更新失败，请重试'
          setTimeout(() => {
            this.saveMessage = ''
          }, 2000)
        }
      }
    } catch (err) {
      console.error('Failed to select avatar:', err)
      this.isSaving = false
      this.saveMessage = '选择图片失败，请重试'
      setTimeout(() => {
        this.saveMessage = ''
      }, 2000)
    }
  }

  /**
   * 保存个人信息
   */
  private async saveProfile() {
    if (!this.nickname || this.nickname.trim().length === 0) {
      this.saveMessage = '请输入昵称'
      setTimeout(() => {
        this.saveMessage = ''
      }, 2000)
      return
    }

    if (this.age < 0 || this.age > 150) {
      this.saveMessage = '请输入有效的年龄（0-150）'
      setTimeout(() => {
        this.saveMessage = ''
      }, 2000)
      return
    }

    this.isSaving = true
    this.saveMessage = ''

    const success = await this.userState.updateUserProfile(
      this.nickname.trim(),
      this.gender,
      this.age,
      this.bio
    )

    this.isSaving = false

    if (success) {
      this.saveMessage = '保存成功'
      setTimeout(() => {
        this.saveMessage = ''
        // 返回上一页
        this.pathStack.pop()
      }, 1000)
    } else {
      this.saveMessage = '保存失败，请重试'
      setTimeout(() => {
        this.saveMessage = ''
      }, 2000)
    }
  }
}

