// 全局音乐状态管理
import { GlobalMusic } from "../models/globalMusic"
// 音乐数据类型定义
import { SongItemType, LyricLine } from "../models/music"
// 全局状态管理模块
import { AppStorageV2 } from "@kit.ArkUI"
// 主题状态管理模块
import { ThemeState } from "../models/theme"
// 播放管理器
import { playManager } from "../utils/AvPlayerManager"

/**
 * Lyric 页面构建器
 */
@Builder
export function LyricBuilder() {
  Lyric()
}

/**
 * 歌词页面组件
 * 展示歌曲歌词和播放控制
 */
@ComponentV2
export struct Lyric {
  @Param swiperIndex: number = 1
  @Event onBack: () => void = () => {}

  @Local playState: GlobalMusic = playManager.currentSong
  themeState: ThemeState = AppStorageV2.connect(ThemeState, 'THEME_STATE', () => new ThemeState())!

  private listScroller: ListScroller = new ListScroller()
  @Local currentIndex: number = -1

  /**
   * 监听播放时间变化，同步歌词滚动
   */
  @Monitor("playState.time")
  onTimeChange() {
    const newIdx = this.calcCurrentLyricIndex()
    if (newIdx !== -1 && newIdx !== this.currentIndex) {
       this.currentIndex = newIdx
       // 保持歌词居中，列表第一项是歌曲信息，所以滚动到 newIdx + 1
       this.listScroller.scrollToIndex(this.currentIndex + 1, true, ScrollAlign.CENTER)
    }
  }

  /**
   * 计算当前播放时间对应的歌词索引
   */
  calcCurrentLyricIndex(): number {
    const lines = this.getLyricLines()
    if (!lines || lines.length === 0) return -1
    const t = this.playState.time
    for (let i = lines.length - 1; i >= 0; i--) {
      if (lines[i].time <= t) return i
    }
    return 0
  }

  /**
   * 获取当前歌曲的歌词行列表
   */
  getLyricLines(): LyricLine[] {
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
      for (let i = 0; i < total; i++) {
        const ratio = total > 0 ? i / total : 0
        out.push({ time: this.playState.duration * ratio, text: song.lyrics[i] })
      }
      return out
    }
    return []
  }

  /**
   * 格式化时间为 'mm:ss' 格式
   */
  formatTime(timeMs: number): string {
    if (!timeMs || isNaN(timeMs)) {
      return "00:00"
    }
    const totalSeconds = Math.floor(timeMs / 1000)
    const m = Math.floor(totalSeconds / 60)
    const s = totalSeconds % 60
    return `${m.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}`
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      // Main theme background using global theme color
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(this.themeState.getBackgroundColor())
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

      Column() {
        // --- Top Nav Bar ---
        Row() {
          // Left Back Button (down arrow simulation using back icon rotated)
          Image($r('app.media.ic_back'))
            .width(28)
            .height(28)
            .fillColor(this.themeState.getPrimaryTextColor())
            .rotate({ angle: -90 })
            .onClick(() => {
              this.onBack()
            })

          Blank()

          // Right cast/broadcast icon simulation using a circle and dot
          Stack() {
            Circle().width(24).height(24)
              .stroke(this.themeState.getPrimaryTextColor())
              .strokeWidth(2)
              .fill('transparent')
            Circle().width(10).height(10)
              .fill(this.themeState.getPrimaryTextColor())
            Text('^').fontColor(this.themeState.getPrimaryTextColor()).fontSize(12).offset({ y: -12 })
          }
        }
        .width('100%')
        .height(56)
        .padding({ left: 24, right: 24 })
        .margin({ top: 12 })

        // --- Lyric List Area ---
        List({ scroller: this.listScroller, space: 32 }) {
          // 1. Song Info Metadata acts as Top Header in scroll
          ListItem() {
            Column({ space: 16 }) {
              Text(this.playState.name || 'δ֪����')
                .fontSize(24)
                .fontWeight(FontWeight.Bolder)
                .fontColor(this.themeState.getPrimaryTextColor())
                .margin({ top: 40 })

              Text(this.playState.name || 'δ֪����')
                .fontSize(16)
                .fontColor(this.themeState.getSecondaryTextColor())

              Text('���֣�δ֪')
                .fontSize(14)
                .fontColor(this.themeState.getSecondaryTextColor())

              Text('���ʣ�δ֪')
                .fontSize(14)
                .fontColor(this.themeState.getSecondaryTextColor())

              Text('������δ֪')
                .fontSize(14)
                .fontColor(this.themeState.getSecondaryTextColor())

              Text('������δ֪')
                .fontSize(14)
                .fontColor(this.themeState.getSecondaryTextColor())
            }
            .alignItems(HorizontalAlign.Center)
            .width('100%')
            .padding({ bottom: 20 })
          }

          if (this.getLyricLines().length === 0) {
            ListItem() {
              Text('���޸��')
                .fontSize(16)
                .fontColor(this.themeState.getSecondaryTextColor())
                .margin({ top: 40 })
                .textAlign(TextAlign.Center)
                .width('100%')
            }
          } else {
            ForEach(this.getLyricLines(), (line: LyricLine, index: number) => {
              ListItem() {
                Text(line.text || ' ')
                  .fontSize(this.currentIndex === index ? 18 : 16)
                  .fontColor(this.currentIndex === index 
                    ? this.themeState.getPrimaryTextColor() 
                    : this.themeState.getSecondaryTextColor())
                  .fontWeight(this.currentIndex === index ? FontWeight.Bold : FontWeight.Normal)
                  .textAlign(TextAlign.Center)
                  .width('100%')
                  .animation({ duration: 300, curve: Curve.EaseInOut })
              }
            })
          }

          // Empty Space at Bottom
          ListItem() {
            Row().height(120)
          }
        }
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .layoutWeight(1)
        .width('100%')

        // --- Bottom Interaction & Control Area ---
        Column() {
          // Additional tools row (List, Download, Bell, Settings)
          Row() {
            Image($r('app.media.ic_song_list'))
              .width(26).height(26)
              .fillColor(this.themeState.getIconColor())
            Image($r('app.media.ic_download_o'))
              .width(26).height(26)
              .fillColor(this.themeState.getIconColor())
            Image($r('app.media.ic_bells_o'))
              .width(26).height(26)
              .fillColor(this.themeState.getIconColor())
            Image($r('app.media.ic_comment_o')) // Alternatively use as "dots" menu placeholder
              .width(26).height(26)
              .fillColor(this.themeState.getIconColor())
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceAround)
          .padding({ left: 30, right: 30, bottom: 24, top: 12 })

          // Progress Bar View
          Row({ space: 14 }) {
            Text(this.formatTime(this.playState.time))
              .fontSize(12)
              .fontColor(this.themeState.getSecondaryTextColor())
              .width(42)
              .textAlign(TextAlign.End)

            Slider({
              value: this.playState.time,
              min: 0,
              max: this.playState.duration,
              step: 1000,
              style: SliderStyle.OutSet
            })
              .trackColor(this.themeState.getDividerColor())
              .selectedColor(this.themeState.getPrimaryTextColor())
              .blockColor(this.themeState.getPrimaryTextColor())
              .layoutWeight(1)
              .onChange((value: number, mode: SliderChangeMode) => {
                if (mode === SliderChangeMode.End || mode === SliderChangeMode.Click) {
                  playManager.seekPlay(value)
                }
              })

            Text(this.formatTime(this.playState.duration))
              .fontSize(12)
              .fontColor(this.themeState.getSecondaryTextColor())
              .width(42)
              .textAlign(TextAlign.Start)
          }
          .width('100%')
          .padding({ left: 20, right: 20, bottom: 20 })

          // Play Controls
          Row() {
            // Random or Repeat Mode toggle
            Image(this.playState.playMode === 'random' ? $r('app.media.ic_random') : $r('app.media.ic_auto'))
              .width(28).height(28)
              .fillColor(this.themeState.getIconColor())

            Image($r('app.media.ic_prev'))
              .width(36).height(36)
              .fillColor(this.themeState.getPrimaryTextColor())
              .onClick(() => playManager.prevPlay())

            // Play/Pause circular big button (inverted colors)
            Row() {
              Image(this.playState.isPlay ? $r('app.media.ic_paused') : $r('app.media.ic_play'))
                .width(36).height(36)
                .fillColor(this.themeState.getBackgroundColor()) // Inverted color for contrast
            }
            .width(76).height(76)
            .backgroundColor(this.themeState.getPrimaryTextColor())
            .borderRadius(38) // Perfect circle
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)
            .onClick(() => {
              if (this.playState.isPlay) {
                playManager.paused()
              } else {
                if (this.playState.playList.length > 0 && this.playState.playIndex >= 0) {
                  playManager.singPlay(this.playState.playList[this.playState.playIndex])
                }
              }
            })

            Image($r('app.media.ic_next'))
              .width(36).height(36)
              .fillColor(this.themeState.getPrimaryTextColor())
              .onClick(() => playManager.nextPlay())

            Image($r('app.media.ic_song_list'))
              .width(28).height(28)
              .fillColor(this.themeState.getIconColor())
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceEvenly)
          .alignItems(VerticalAlign.Center)
          .padding({ left: 16, right: 16, bottom: 48 })
        }
        .width('100%')
        // Applying slight thematic backdrop to ensure bottom controls are clearly readable
        .backgroundColor(this.themeState.getBackgroundColor())
      }
      .width('100%')
      .height('100%')
    }
  }
}
