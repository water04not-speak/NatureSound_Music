import { GlobalMusic } from "../models/globalMusic"
import { SongItemType, LyricLine } from "../models/music"
import { AppStorageV2 } from "@kit.ArkUI"
import { ThemeState } from "../models/theme"
import { playManager } from "../utils/AvPlayerManager"
// 跳转页面入口函数
@Builder
export function LyricBuilder() {
  Lyric()
}

@ComponentV2
struct Lyric {
  @Local swiperIndex: number = 1  // 1=歌词页
  pathStack = AppStorageV2.connect(NavPathStack, 'navStack', () => new NavPathStack())!

  // 当前播放的歌曲
  @Local
  playState: GlobalMusic = AppStorageV2.connect(GlobalMusic, 'SONG_KEY', () => {
    const music = new GlobalMusic()
    return music
  })!

  themeState: ThemeState = AppStorageV2.connect(ThemeState, 'THEME_STATE', () => new ThemeState())!

  /** 当前歌曲的歌词行（带时间或纯文本） */
  private getLyricLines(): LyricLine[] {
    const list = this.playState.playList
    const idx = this.playState.playIndex
    if (!list.length || idx < 0 || idx >= list.length) {
      return []
    }
    const song: SongItemType = list[idx]
    if (song.lyricLines && song.lyricLines.length > 0) {
      return song.lyricLines
    }
    if (song.lyrics && song.lyrics.length > 0) {
      const total = song.lyrics.length
      const out: LyricLine[] = []
      for (let i = 0; i < song.lyrics.length; i++) {
        const ratio = total > 0 ? i / total : 0
        const line: LyricLine = { time: this.playState.duration * ratio, text: song.lyrics![i] }
        out.push(line)
      }
      return out
    }
    return []
  }

  /** 根据当前播放时间计算高亮行索引 */
  private getCurrentLyricIndex(): number {
    const lines = this.getLyricLines()
    if (lines.length === 0) return -1
    const t = this.playState.time
    for (let i = lines.length - 1; i >= 0; i--) {
      if (lines[i].time <= t) return i
    }
    return 0
  }

  build() {
    NavDestination() {
      Stack() {
        // 主题背景
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor(this.themeState.getBackgroundColor())
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

        // 内容
        Column() {
          // 页面指示点：播放 · 歌词
          Row({ space: 8 }) {
            Circle()
              .width(8)
              .height(8)
              .fill(this.themeState.getSecondaryTextColor())
              .opacity(0.5)
              .onClick(() => {
                // 使用正确的返回方法
                this.pathStack.pop()
              })
            Circle()
              .width(8)
              .height(8)
              .fill(this.themeState.getPlayPageForegroundColor())
              .opacity(1)
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .padding({ top: 8, bottom: 4 })

          // 歌词界面
          Column() {
            if (this.getLyricLines().length === 0) {
              Text('暂无歌词')
                .fontSize(18)
                .fontColor(this.themeState.getSecondaryTextColor())
                .margin({ top: 40 })
            } else {
              Scroll() {
                Column({ space: 16 }) {
                  ForEach(this.getLyricLines(), (line: LyricLine, index: number) => {
                    Text(line.text || ' ')
                      .fontSize(this.getCurrentLyricIndex() === index ? 20 : 16)
                      .fontColor(this.getCurrentLyricIndex() === index ?
                        this.themeState.getPlayPageForegroundColor() :
                        this.themeState.getSecondaryTextColor())
                      .fontWeight(this.getCurrentLyricIndex() === index ? FontWeight.Medium : FontWeight.Normal)
                      .textAlign(TextAlign.Center)
                      .width('100%')
                  })
                }
                .width('100%')
                .padding({ left: 24, right: 24, top: 16, bottom: 24 })
              }
              .scrollBar(BarState.Off)
              .edgeEffect(EdgeEffect.Spring)
              .layoutWeight(1)
              .width('100%')
            }
          }
          .width('100%')
          .height('100%')

          // 操作
          Row() {
            Badge({ value: '99+', style: { badgeSize: 12, badgeColor: '#45CCCCCC' } }) {
              Image($r("app.media.ic_like"))
                .fillColor(this.themeState.getPlayPageForegroundColor())
                .width(24)
            }

            Badge({ value: '10W', style: { badgeSize: 12, badgeColor: '#45cccccc' } }) {
              Image($r("app.media.ic_comment_o"))
                .fillColor(this.themeState.getPlayPageForegroundColor())
                .width(18)
            }

            Badge({ value: 'hot', style: { badgeSize: 12, badgeColor: '#a8ff3131' } }) {
              Image($r("app.media.ic_bells_o"))
                .fillColor(this.themeState.getPlayPageForegroundColor())
                .width(24)
            }

            Badge({ value: 'vip', style: { badgeSize: 12, badgeColor: '#b7efd371' } }) {
              Image($r("app.media.ic_download_o"))
                .fillColor(this.themeState.getPlayPageForegroundColor())
                .width(24)
            }
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceAround)
          // 播放
          Column() {
            // 进度条
            Row({ space: 4 }) {
              Text(this.number2time(this.playState.time))
                .fontSize(12)
                .fontColor(this.themeState.getPlayPageForegroundColor())
              Slider({
                value: this.playState.time,
                min: 0,
                max: this.playState.duration > 0 ? this.playState.duration : 10000
              })
                .layoutWeight(1)
                .blockColor(this.themeState.getPlayPageForegroundColor())
                .selectedColor(this.themeState.getPlayPageForegroundColor())
                .trackColor(this.themeState.getIsDark() ? '#66FFFFFF' : '#66000000')
                .trackThickness(3)
                .onChange((value) => {
                  console.info('进度条被拖动，值为:', value)
                  playManager.seekPlay(value)
                })
              Text(this.number2time(this.playState.duration))
                .fontSize(12)
                .fontColor(this.themeState.getPlayPageForegroundColor())
            }
            .width('100%')
            .padding(24)
            // 切换
            Row() {
              if (this.playState.playMode === 'auto') {
                Image($r('app.media.ic_auto'))
                  .fillColor(this.themeState.getPlayPageForegroundColor())
                  .width(30)
                  .onClick(() => {
                    this.playState.playMode = 'random'
                  })
              } else if (this.playState.playMode === 'random') {
                Image($r('app.media.ic_random'))
                  .fillColor(this.themeState.getPlayPageForegroundColor())
                  .width(30)
                  .onClick(() => {
                    this.playState.playMode = 'repeat'
                  })
              } else if (this.playState.playMode === 'repeat') {
                Image($r('app.media.ic_repeat'))
                  .fillColor(this.themeState.getPlayPageForegroundColor())
                  .width(30)
                  .onClick(() => {
                    this.playState.playMode = 'auto'
                  })
              }

              Image($r("app.media.ic_prev"))
                .fillColor(this.themeState.getPlayPageForegroundColor())
                .width(30)
                .onClick(() => {
                  console.info('上一首按钮被点击')
                  if (this.playState.playList.length > 0) {
                    console.info('播放列表有歌曲，调用playManager.prevPlay()')
                    playManager.prevPlay()
                  }
                })

              // 播放按钮
              Image(this.playState.isPlay ? $r('app.media.ic_paused') : $r('app.media.ic_play'))
                .fillColor(this.themeState.getPlayPageForegroundColor())
                .width(50)
                .onClick(() => {
                  console.info('播放按钮被点击，当前播放状态:', this.playState.isPlay)
                  if (this.playState.isPlay) {
                    console.info('调用playManager.paused()')
                    playManager.paused()
                  } else {
                    console.info('调用playManager.singPlay()')
                    if (this.playState.playList.length > 0 && this.playState.playIndex >= 0 && this.playState.playIndex < this.playState.playList.length) {
                      console.info('播放列表有歌曲，播放索引:', this.playState.playIndex)
                      playManager.singPlay(this.playState.playList[this.playState.playIndex])
                    }
                  }
                })
              // 下一首
              Image($r('app.media.ic_next'))
                .fillColor(this.themeState.getPlayPageForegroundColor())
                .width(30)
                .onClick(() => {
                  console.info('下一首按钮被点击')
                  if (this.playState.playList.length > 0) {
                    console.info('播放列表有歌曲，调用playManager.nextPlay()')
                    playManager.nextPlay()
                  }
                })
              // 播放列表
              Image($r('app.media.ic_song_list'))
                .fillColor(this.themeState.getPlayPageForegroundColor())
                .width(30)
                .onClick(() => {
                  console.info('播放列表按钮被点击，显示播放列表')
                  this.panelOpacity = 1
                })
            }
            .width('100%')
            .padding({
              bottom: 24
            })
            .justifyContent(FlexAlign.SpaceAround)
          }
          .width('100%')
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Color.Transparent)

    }
    .onReady((context) => {
      this.pathStack = context.pathStack
    })
    .hideTitleBar(true)  // 隐藏标题栏
  }

  number2time(number: number) {
    // 毫秒 → 秒 → 分+秒; 先判断是否大于1分钟
    if (number > 60 * 1000) {
      const s = Math.floor(number / 1000 % 60)
      const m = Math.floor(number / 1000 / 60)
      const second = s.toString().padStart(2, '0')
      const minute = m.toString().padStart(2, '0')
      return minute + ':' + second
    } else {
      const s = Math.floor(number / 1000 % 60)
      const second = s.toString().padStart(2, '0')
      return '00:' + second
    }
  }



  // 播放列表相关
  @Local panelOpacity: number = 0

  @Builder
  deleteButton(index: number) {
    Button('删除')
      .backgroundColor('#ec5c87')
      .fontColor('#fff')
      .width(80)
      .height('100%')
      .type(ButtonType.Normal)
      .onClick(() => {
        // 按接收到的索引删除歌曲
        playManager.removeSong(index)
        //   回退到前一页
        if (this.playState.playList.length === 0) {
          this.pathStack.pop()
        }
      })
  }
}
