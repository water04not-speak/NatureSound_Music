// 我的界面

import { AppStorageV2 } from '@kit.ArkUI'
import common from '@ohos.app.ability.common'
import { UserState, Gender } from '../models/user'
import { ThemeState } from '../models/theme'
import { ThemeColorPicker } from '../components/ThemeColorPicker'
// 导入歌单参数类
import {PlaylistParams} from './PlaylistDetail'

interface accountStatItem {
  label: string
  value: string
}

// 歌单项类型（避免使用对象字面量直接做类型声明）
interface PlaylistItem {
  id: string
  name: string
  desc: string
  cover: ResourceStr
  count: number
}
// interface MineBgItem{
//   id: string
//   picture: ResourceStr
// }

@ComponentV2
  // export 导出，别的组件才可以导入去使用
export struct Mine {
  pathStack: NavPathStack = AppStorageV2.connect(NavPathStack, 'navStack', () => new NavPathStack())!
  userState: UserState = AppStorageV2.connect(UserState, 'USER_STATE', () => new UserState())!
  themeState: ThemeState = AppStorageV2.connect(ThemeState, 'THEME_STATE', () => new ThemeState())!
  @Local private showMenu: boolean = false
  @Local private showAbout: boolean = false
  @Local private showColorPicker: boolean = false  // 控制颜色选择器显示状态
  @Local private scrollY: number = 0
  @Local private headerHeight: number = 320
  @Local private headerOpacity: number = 1
  private readonly HEADER_MAX: number = 320
  private readonly HEADER_MIN: number = 56
  private readonly SCROLL_THROTTLE: number = 16 // 约60fps
  // private readonly ABOUT_URL: string = 'https://wwzs.example.com/about' // 可替换为官网介绍页
  // 使用常量定义歌单数据，避免每次渲染时重新创建
  private static readonly playlists: PlaylistItem[] = [
    { id: 'pl-1', name: '我喜欢的音乐', desc: '循环不止的心头好', cover: $r('app.media.my_playlist1'), count: 34 },
    { id: 'pl-2', name: '通勤·清醒', desc: '通勤路上提神醒脑', cover: $r('app.media.my_playlist2'), count: 10 },
    { id: 'pl-3', name: '深夜·助眠', desc: '低保真与白噪音', cover: $r('app.media.my_playlist3'), count: 8 },
    { id: 'pl-4', name: '运动·燃脂', desc: 'BPM 140+动起来', cover: $r('app.media.my_playlist4'), count: 12 },
    { id: 'pl-5', name: '民谣·故事', desc: '听得见风的味道', cover: $r('app.media.my_playlist5'), count: 7 },
    { id: 'pl-6', name: '轻音乐·放空', desc: '纯音乐助放松', cover: $r('app.media.my_playlist6'), count: 6 },
    { id: 'pl-7', name: '翻唱·精选', desc: '熟悉的旋律新唱法', cover: $r('app.media.my_playlist7'), count: 21 },
    { id: 'pl-8', name: '摇滚·经典', desc: '失真与热血', cover: $r('app.media.my_playlist8'), count: 13 },
    { id: 'pl-9', name: '电子·氛围', desc: '氛围与步伐', cover: $r('app.media.my_playlist9'), count: 3},
    { id: 'pl-10', name: '华语·流行', desc: '最新中文热歌', cover: $r('app.media.my_playlist10'), count: 24 },
    { id: 'pl-11', name: '古典·入门', desc: '从巴洛克开始', cover: $r('app.media.my_playlist11'), count: 11 },
    { id: 'pl-12', name: '爵士·夜色', desc: '即兴与蓝调', cover: $r('app.media.my_playlist12'), count: 8 },
  ]
  // 旧版 header 网格背景已替换为“全屏背景图 + 颜色遮罩”的整页换肤




  private readonly stats: accountStatItem[] = [
    { label: '关注', value: '1' },
    { label: '粉丝', value: '10万' },
    { label: '赞', value: '1.67亿' }
  ]

  private lastScrollTime: number = 0

  aboutToAppear() {
    const abilityCtx = getContext(this) as common.UIAbilityContext
    // 防止任何遮罩层在页面再次出现时残留，影响输入焦点
    this.showMenu = false
    this.showAbout = false
    this.showColorPicker = false
    // 初始化用户状态和主题状态
    Promise.all([
      this.userState.initFromContext(abilityCtx),
      this.themeState.initFromContext(abilityCtx)
    ]).then(() => {
      if (!this.userState.isLoggedIn) {
        setTimeout(() => {
          this.pathStack.pushPathByName('Register', null, false)
        }, 100)
      }
    })
  }

  /**
   * 节流函数，用于优化滚动事件处理
   */
  private throttleScroll(x: number, y: number): void {
    const now = Date.now()
    if (now - this.lastScrollTime > this.SCROLL_THROTTLE) {
      this.scrollY = y
      this.updateHeaderState()
      this.lastScrollTime = now
    }
  }

  /**
   * 更新头部状态
   */
  private updateHeaderState(): void {
    const delta: number = this.HEADER_MAX - this.HEADER_MIN
    const used: number = Math.min(Math.max(this.scrollY, 0), delta)
    this.headerHeight = this.HEADER_MAX - used
    this.headerOpacity = Math.max(0, Math.min(1, 1 - used / delta))
  }

  build() {
    Stack(){
      // 全屏背景：背景图 + 颜色遮罩（和“更换背景”联动）
      // 参考效果：更换背景时整体换肤，背景图保持一定透明度，文字可读
      Image(this.themeState.getBackgroundImage())
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
        .opacity(this.themeState.getBackgroundImageOpacity())
        .zIndex(0)

      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(this.themeState.getBackgroundColor())
        .opacity(this.themeState.getBackgroundOverlayOpacity())
        .zIndex(1)

      Scroll() {
        Column() {
          // 顶部背景区域：网格布局显示专辑封面
          Stack() {
            // 顶部额外柔和遮罩，让头像/昵称更清晰（背景图仍来自全局）
            Column()
              .width('100%')
              .height('100%')
              .backgroundColor('#000000')
              .opacity(0.18)
              .zIndex(1)

            // 顶部用户信息区域（覆盖在背景上）
            Column({ space: 12 }) {
              // 头像（可点击跳转到个人信息编辑）
              if (this.userState.getAvatarPath()) {
                Image(this.userState.getAvatarPath())
                  .width(88)
                  .height(88)
                  .borderRadius(44)
                  .border({ width: 4, color: Color.White })
                  .margin({ top: 40 })
                  .onClick(() => {
                    this.pathStack.pushPathByName('UserProfile', null, false)
                  })
              } else {
                Image($r('app.media.mylogo'))
                  .width(88)
                  .height(88)
                  .borderRadius(44)
                  .border({ width: 4, color: Color.White })
                  .margin({ top: 40 })
                  .onClick(() => {
                    this.pathStack.pushPathByName('UserProfile', null, false)
                  })
              }

              // 用户昵称（如果没有昵称则显示用户名）
              Text(this.userState.nickname || this.userState.username || '万物之声')
                .fontSize(20)
                .fontWeight(FontWeight.Medium)
                .fontColor(Color.White)

              // 用户详情（显示年龄、性别等信息）
              Text(this.getUserDetailText())
                .fontSize(13)
                .fontColor('#FFFFFF')
                .opacity(0.9)

              // 个性签名
              if (this.userState.bio) {
                Text(this.userState.bio)
                  .fontSize(13)
                  .fontColor(Color.White)
                  .opacity(0.9)
                  .textAlign(TextAlign.Center)
                  .width('80%')
                  .margin({ top: 8 })
              } else {
                Text('未设置个性签名')
                  .fontSize(13)
                  .fontColor(Color.White)
                  .opacity(0.6)
                  .textAlign(TextAlign.Center)
                  .width('80%')
                  .margin({ top: 8 })
              }
            }
            .alignItems(HorizontalAlign.Center)
            .width('100%')
            .zIndex(10)
          }
          .width('100%')
          .height(this.headerHeight)
          .opacity(this.headerOpacity)

          // 歌单列表区域
          Column() {
            // 我的歌单标题
            Row() {
              Text('我的歌单')
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                // 使用主题的主要文字颜色
                .fontColor(this.themeState.getPrimaryTextColor())
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 16, bottom: 8 })

            // 歌单列表
            List() {
              ForEach(Mine.playlists, (it: PlaylistItem, _i: number) => {
                ListItem() {
                  Row({ space: 12 }) {
                    Image(it.cover)
                      .width(44)
                      .height(44)
                      .borderRadius(8)

                    Column({ space: 6 }) {
                      Text(it.name)
                        .fontSize(16)
                        .fontWeight(FontWeight.Medium)
                        // 使用主题的主要文字颜色
                        .fontColor(this.themeState.getPrimaryTextColor())
                      Text(`${it.desc} · ${it.count}首`)
                        .fontSize(12)
                        // 使用主题的次要文字颜色
                        .fontColor(this.themeState.getSecondaryTextColor())
                    }
                    .alignItems(HorizontalAlign.Start)
                  }
                  .width('100%')
                  .padding({ left: 16, right: 16, top: 12, bottom: 12 })
                  // 使用主题的卡片背景颜色
                  .backgroundColor(this.themeState.getCardBackgroundColor())
                  .borderRadius(12)
                }
                .margin({ left: 16, right: 16, top: 8, bottom: 8 })
                .onClick(() => {
                  // 使用AppStorageV2传递歌单参数
                  // 先获取现有的playlistParams实例，然后更新其属性
                  const params = AppStorageV2.connect(PlaylistParams, 'playlistParams', () => new PlaylistParams())!;
                  params.playlistId = it.id;
                  params.playlistName = it.name;
                  params.playlistDesc = it.desc;
                  params.playlistCover = it.cover;
                  params.playlistCount = it.count;
                  // 跳转到歌单详情页
                  this.pathStack.pushPathByName("PlaylistDetail", null, false);
                })
              }, (it: PlaylistItem, i: number) => it.id)
            }
            .width('100%')
            .layoutWeight(1)
          }
        }
      }
      .scrollBar(BarState.Off)
      .onScroll((x: number, y: number) => { this.throttleScroll(x, y) })
      .width('100%')
      .height('100%')
      .zIndex(10)

      // 右上角设置按钮
      Row() {
        Row() {
          Image($r('app.media.ic_more'))
            .width(24)
            .height(24)
            .fillColor('#FFFFFF')
            .onClick(() => {
              this.showMenu = !this.showMenu
            })
        }
        .padding({ top: 4, bottom: 4, left: 4, right: 4 })
        .backgroundColor('rgba(0,0,0,0.25)')
        .borderRadius(16)
      }
      .width('100%')
      .position({ y: 12 })
      .justifyContent(FlexAlign.End)
      .padding({ right: 12 })
      .zIndex(20)

      // 顶部右侧弹出小页面
      if (this.showMenu) {
        Row({space:2}) {
          Column({ space: 10 }) {
            // 更换背景按钮
            Row({ space: 8 }) {
              Image($r('app.media.ic_change_bacc'))
                .width(18)
                .height(18)
                .fillColor(this.themeState.getPrimaryTextColor())
              Text('换肤')
                .fontColor(this.themeState.getPrimaryTextColor())
                .fontSize(14)
                .fontWeight(700)
            }
            .width(140)
            .height(40)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(this.themeState.getBackgroundColor())
            .borderRadius(20)
            .onClick(() => {
              this.showMenu = false
              this.showColorPicker = true
            })

            // 设置按钮
            Row({ space: 8 }) {
              Image($r('app.media.ic_setting'))
                .width(18)
                .height(18)
                .fillColor(this.themeState.getPrimaryTextColor())
              Text('设置')
                .fontColor(this.themeState.getPrimaryTextColor())
                .fontSize(14)
                .fontWeight(700)
            }
            .width(140)
            .height(40)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(this.themeState.getBackgroundColor())
            .borderRadius(20)
            .onClick(() => {
              this.showMenu = false
              this.pathStack.pushPathByName('Settings', null, false)
            })

            // 关于我们按钮
            Row({ space: 8 }) {
              Image($r('app.media.ic_about_our'))
                .width(18)
                .height(18)
                .fillColor(this.themeState.getPrimaryTextColor())
              Text('关于我们')
                .fontColor(this.themeState.getPrimaryTextColor())
                .fontSize(14)
                .fontWeight(700)
            }
            .width(140)
            .height(40)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(this.themeState.getBackgroundColor())
            .borderRadius(20)
            .onClick(() => {
              this.showMenu = false
              this.showAbout = true
            })

            // 退出登录按钮
            Row({ space: 8 }) {
              Image($r('app.media.ic_log_out'))
                .width(18)
                .height(18)
                .fillColor(this.themeState.getPrimaryTextColor())
              Text('退出登录')
                .fontColor(this.themeState.getPrimaryTextColor())
                .fontSize(14)
                .fontWeight(700)
            }
            .width(140)
            .height(40)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(this.themeState.getBackgroundColor())
            .borderRadius(20)
            .onClick(() => {
              this.userState.logout()
              this.showMenu = false
              // 清除路由栈并跳转到登录页面
              setTimeout(() => {
                this.pathStack.clear()
                this.pathStack.replacePathByName('Login', null, false)
              }, 100)
            })
          }
          .padding({ left: 16, right: 16, top: 16, bottom: 16 })
          .backgroundColor('#2C2C2E')
          .borderRadius(16)
          .shadow({ radius: 12, color: 'rgba(0,0,0,0.35)', offsetX: 0, offsetY: 4 })
        }
        .width('100%')
        .position({ y: 48 })
        .justifyContent(FlexAlign.End)
        .padding({ right: 12 })
        .zIndex(30)
      }

      // 主题颜色选择器组件
      // 当 showColorPicker 为 true 时显示颜色选择弹窗
      if (this.showColorPicker) {
        ThemeColorPicker({
          themeState: this.themeState,
          showPicker: this.showColorPicker,
          onClose: () => {
            this.showColorPicker = false
          }
        })
      }

      // 关于我们弹层（带二维码）
      if (this.showAbout) {
        // 半透明遮罩
        Column() {}
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.5)')
        .position({ y: 0 })
        .zIndex(40)
        .onClick(() => { this.showAbout = false })

        // 内容卡片
        Column({ space: 16 }) {
          // 顶部标题区：左侧 logo + 右侧名称
          Row({ space: 8 }) {
            Image($r('app.media.mylogo'))
              .width(28)
              .height(28)
              .borderRadius(6)
            Text('万物之声')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor(Color.White)
          }
          .alignItems(VerticalAlign.Center)
          .width('100%')

          // 二维码图片（在线生成，内容为介绍文本）
          Image(this.getAboutQrUrl())
            .width(220)
            .height(220)
            .borderRadius(8)
            .backgroundColor(Color.White)

          // 提示语
          Text('扫一扫上面的二维码图案，了解更多万物之声的详细内容')
            .fontSize(13)
            .fontColor('#B0B0B0')
            .textAlign(TextAlign.Center)

          // 关闭按钮
          Button('关闭')
            .width('100%')
            .height(40)
            .fontSize(14)
            .onClick(() => { this.showAbout = false })
        }
        .width('82%')
        .padding({ left: 16, right: 16, top: 16, bottom: 16 })
        .backgroundColor('#2C2C2E')
        .borderRadius(12)
        .shadow({ radius: 16, color: 'rgba(0,0,0,0.35)', offsetX: 0, offsetY: 6 })
        .position({ y: 'center' })
        .alignItems(HorizontalAlign.Center)
        .zIndex(50)
      }
    }
    .width('100%')
    .height('100%')
    // 使用主题状态中的背景颜色，实现动态背景切换
    .backgroundColor(this.themeState.getBackgroundColor())
    .expandSafeArea()

  }


  // 生成“关于我们”弹层中的二维码内容与地址
  private getAboutQrText(): string {
    const intro: string = '万物之声：一款专注沉浸式聆听体验的音乐应用。' +
      '主要功能包含：高品质音乐播放、个性化推荐、歌单收藏与管理、动态分享互动、跨设备播放控制等。' +
      '鸿蒙连接山河，数字传承古韵。一站式聆听各地非遗音乐，让传统声生不息。'
    return intro
  }

  private getAboutQrUrl(): string {
    // 使用在线二维码服务生成"纯文本"二维码（微信/支付宝可直接显示文本）
    const base: string = 'https://api.qrserver.com/v1/create-qr-code/?size=220x220&margin=10&data='
    const encoded: string = encodeURI(this.getAboutQrText())
    return `${base}${encoded}`
  }

  /**
   * 获取用户详情文本
   */
  private getUserDetailText(): string {
    const parts: string[] = []

    // 年龄
    if (this.userState.age > 0) {
      const birthYear = new Date().getFullYear() - this.userState.age
      if (birthYear >= 2000) {
        parts.push('00后')
      } else if (birthYear >= 1990) {
        parts.push('90后')
      } else if (birthYear >= 1980) {
        parts.push('80后')
      } else {
        parts.push(`${birthYear}后`)
      }
    }

    // 性别
    if (this.userState.gender !== Gender.UNKNOWN) {
      const genderText = this.userState.gender === Gender.MALE ? '男'
        : this.userState.gender === Gender.FEMALE ? '女'
          : '其他'
      parts.push(genderText)
    }

    // 默认信息
    if (parts.length === 0) {
      parts.push('双子座', '苏州', '歌龄·21年')
    } else {
      parts.push('歌龄·10年')
    }

    return parts.join('  ')
  }
}