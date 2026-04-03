import { GlobalMusic } from "../models/globalMusic"
import { SongItemType, LyricLine } from "../models/music"
import { AppStorageV2 } from "@kit.ArkUI"
import { ThemeState } from "../models/theme"
import { playManager } from "../utils/AvPlayerManager"
import { parseLRC } from "../utils/lyricsParser"

/**
 * 歌词页面的构造函数
 */
@Builder
export function LyricBuilder() {
  Lyric()
}

/**
 * 歌词显示主组件
 */
@ComponentV2
export struct Lyric {
  // Swiper 的索引，用于配合外部滑动翻页
  @Param swiperIndex: number = 1
  // 返回原页面的事件回调
  @Event onBack: () => void = () => {}

  // 全局播放状态和主题状态双向绑定
  @Local playState: GlobalMusic = playManager.currentSong
  themeState: ThemeState = AppStorageV2.connect(ThemeState, 'THEME_STATE', () => new ThemeState())!

  // 列表滚动控制器，用于歌词滚动同步
  private listScroller: ListScroller = new ListScroller()
  // 当前正在播放的歌词高亮索引
  @Local currentIndex: number = -1
  @Local lineHighlightProgress: number = 0
  @Local lastObservedTime: number = -1
  private cachedLyricKey: string = ''
  private cachedLyricLines: LyricLine[] = []
  private lyricTickId: number = -1

  /**
   * 【通俗解释】用轻量定时器轮询播放时间，确保歌词滚动在所有机型都稳定触发。
   */
  private syncLyricByTime(): void {
    if (this.playState.time === this.lastObservedTime) {
      return
    }
    this.lastObservedTime = this.playState.time

    const newIdx = this.calcCurrentLyricIndex()
    if (newIdx === -1) {
      return
    }

    if (newIdx !== this.currentIndex) {
      this.currentIndex = newIdx
      const lines = this.getLyricLines()
      let duration = 1500
      if (newIdx >= 0 && newIdx < lines.length - 1) {
        const delta = lines[newIdx + 1].time - lines[newIdx].time
        if (delta > 300 && delta < 12000) {
          duration = delta
        }
      }
      this.startCurrentLineHighlight(duration)

      // 歌词滚动至屏幕中间对齐
      this.listScroller.scrollToIndex(this.currentIndex + 1, true, ScrollAlign.CENTER)
    }
  }

  private startLyricTicker(): void {
    if (this.lyricTickId >= 0) {
      clearInterval(this.lyricTickId)
      this.lyricTickId = -1
    }
    this.lyricTickId = setInterval(() => {
      this.syncLyricByTime()
    }, 120)
  }

  private stopLyricTicker(): void {
    if (this.lyricTickId >= 0) {
      clearInterval(this.lyricTickId)
      this.lyricTickId = -1
    }
  }

  private startCurrentLineHighlight(duration: number): void {
    const safeDuration = duration > 300 ? duration : 300
    this.lineHighlightProgress = 0
    this.getUIContext().animateTo({
      duration: safeDuration,
      curve: Curve.Linear,
      iterations: 1
    }, () => {
      this.lineHighlightProgress = 1
    })
  }

  /**
   * 计算当前时间匹配的歌词行索引
   */
  calcCurrentLyricIndex(): number {
    const lines = this.getLyricLines()
    if (!lines || lines.length === 0) return -1
    const t = this.playState.time
    for (let i = lines.length - 1; i >= 0; i--) {
      // 找到第一句时间小于等于当前播放时间的歌词
      if (lines[i].time <= t) return i
    }
    return 0
  }

  private stripLrcTags(text: string): string {
    return text.replace(/\[\d{1,2}:\d{2}(?:\.\d{1,3})?\]/g, '').trim()
  }

  private buildEvenLines(rawLines: string[], duration: number): LyricLine[] {
    const out: LyricLine[] = []
    const safeDuration = duration > 0 ? duration : rawLines.length * 3000
    for (let i = 0; i < rawLines.length; i++) {
      const ratio = rawLines.length > 0 ? i / rawLines.length : 0
      out.push({ time: safeDuration * ratio, text: rawLines[i] })
    }
    return out
  }

  private getDisplayLines(lines: LyricLine[]): LyricLine[] {
    const out: LyricLine[] = []
    for (const line of lines) {
      const cleaned = this.stripLrcTags(line.text)
      if (cleaned.length === 0) {
        continue
      }
      const entry: LyricLine = {
        time: line.time,
        text: cleaned
      }
      out.push(entry)
    }
    return out
  }

  private getChars(text: string): string[] {
    return Array.from(text)
  }

  private getHighlightedCharCount(text: string, index: number): number {
    if (index !== this.currentIndex) {
      return 0
    }
    const chars = this.getChars(text)
    if (chars.length === 0) {
      return 0
    }
    const count = Math.floor(chars.length * this.lineHighlightProgress)
    return count > chars.length ? chars.length : count
  }

  private getLineFontSize(index: number): number {
    const distance = Math.abs(index - this.currentIndex)
    if (this.currentIndex < 0) {
      return 18
    }
    if (distance === 0) {
      return 30
    }
    if (distance === 1) {
      return 23
    }
    if (distance === 2) {
      return 19
    }
    return 16
  }

  private getLineOpacity(index: number): number {
    const distance = Math.abs(index - this.currentIndex)
    if (this.currentIndex < 0) {
      return 0.55
    }
    if (distance === 0) {
      return 1
    }
    if (distance === 1) {
      return 0.72
    }
    if (distance === 2) {
      return 0.52
    }
    return 0.32
  }

  /**
   * 获取格式化后的歌词数组
   * 支持直接按时间戳的 LyricLine，或者是均分时间的模拟 lyrics 数组
   */
  getLyricLines(): LyricLine[] {
    const list = this.playState.playList
    const idx = this.playState.playIndex
    if (!list.length || idx < 0 || idx >= list.length) {
      return []
    }
    const song: SongItemType = list[idx]
    const sourceLyric = (song.lyric ?? this.playState.lyric ?? '').trim()
    const sourceDuration = this.playState.duration > 0 ? this.playState.duration : 0
    const sourcePlainArrayLen = song.lyrics ? song.lyrics.length : 0
    const cacheKey = `${song.id}|${sourceDuration}|${sourceLyric.length}|${sourcePlainArrayLen}`

    if (cacheKey === this.cachedLyricKey && this.cachedLyricLines.length > 0) {
      return this.cachedLyricLines
    }

    if (song.lyricLines && song.lyricLines.length > 0) {
      this.cachedLyricKey = cacheKey
      this.cachedLyricLines = this.getDisplayLines(song.lyricLines)
      return this.cachedLyricLines
    }

    if (this.playState.lyricLines && this.playState.lyricLines.length > 0) {
      this.cachedLyricKey = cacheKey
      this.cachedLyricLines = this.getDisplayLines(this.playState.lyricLines)
      return this.cachedLyricLines
    }

    if (sourceLyric.length > 0) {
      const parsed = parseLRC(sourceLyric)
      const parsedDisplay = this.getDisplayLines(parsed)
      if (parsedDisplay.length > 0) {
        this.cachedLyricKey = cacheKey
        this.cachedLyricLines = parsedDisplay
        return this.cachedLyricLines
      }

      const rawLines = sourceLyric
        .split(/\r?\n/)
        .map((line: string) => this.stripLrcTags(line.trim()))
        .filter((line: string) => line.length > 0)
      if (rawLines.length > 0) {
        this.cachedLyricKey = cacheKey
        this.cachedLyricLines = this.buildEvenLines(rawLines, sourceDuration)
        return this.cachedLyricLines
      }
    }

    // 如果只有纯文本数组，通过总时长平均估算时间打点（降级兼容方案）
    if (song.lyrics && song.lyrics.length > 0) {
      const rawLines = song.lyrics.map((line: string) => this.stripLrcTags(line)).filter((line: string) => line.length > 0)
      this.cachedLyricKey = cacheKey
      this.cachedLyricLines = this.buildEvenLines(rawLines, sourceDuration)
      return this.cachedLyricLines
    }
    this.cachedLyricKey = cacheKey
    this.cachedLyricLines = []
    return []
  }

  /**
   * 时间格式化转换毫秒工具函数
   * 返回格式如: "04:20"
   */
  formatTime(timeMs: number): string {
    if (!timeMs || isNaN(timeMs)) {
      return "00:00"
    }
    const totalSeconds = Math.floor(timeMs / 1000)
    const m = Math.floor(totalSeconds / 60)
    const s = totalSeconds % 60
    return m.toString().padStart(2, "0") + ":" + s.toString().padStart(2, "0")
  }

  aboutToAppear(): void {
    this.startLyricTicker()
  }

  aboutToDisappear(): void {
    this.stopLyricTicker()
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Image(this.playState.img)
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
        .blur(42)

      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 180,
          colors: [
            ['rgba(8, 18, 38, 0.74)', 0],
            ['rgba(8, 18, 38, 0.62)', 0.45],
            ['rgba(4, 8, 16, 0.88)', 1]
          ]
        })

      Column() {
        // 核心歌词滚动展示区
        List({ scroller: this.listScroller, space: 36 }) {
          // 在歌词列表首项显示歌曲详情（随滑动隐藏）
          ListItem() {
            Column({ space: 16 }) {
              Text(this.playState.name || "未知歌曲")
                .fontSize(28)
                .fontWeight(FontWeight.Bolder)
                .fontColor('#F4F8FF')
                .margin({ top: 40 })

              Text(this.playState.author || "未知歌手")
                .fontSize(16)
                .fontColor('rgba(226,236,255,0.86)')

              Text("作词：未知")
                .fontSize(14)
                .fontColor('rgba(198,214,245,0.74)')

              Text("作曲：未知")
                .fontSize(14)
                .fontColor('rgba(198,214,245,0.74)')
            }
            .alignItems(HorizontalAlign.Center)
            .width('100%')
            .padding({ top: 60, bottom: 40 })
          }

          // 渲染全部歌词状态
          if (this.getLyricLines().length === 0) {
            ListItem() {
              Text("暂无歌词")
                .fontSize(16)
                .fontColor('rgba(226,236,255,0.72)')
                .margin({ top: 120 })
                .textAlign(TextAlign.Center)
                .width('100%')
            }
          } else {
            ForEach(this.getLyricLines(), (line: LyricLine, index: number) => { 
              ListItem() {
                // 当前行做“逐字点亮”，其它行保持柔和过渡。
                Row() {
                  Text() {
                    ForEach(this.getChars(line.text || " "), (ch: string, charIndex: number) => {
                      Span(ch)
                        .fontColor(charIndex < this.getHighlightedCharCount(line.text || " ", index)
                          ? '#EAF3FF'
                          : 'rgba(214,229,255,0.62)')
                        .fontWeight(index === this.currentIndex ? FontWeight.Bolder : FontWeight.Medium)
                    })
                  }
                  .fontSize(this.getLineFontSize(index))
                  .opacity(this.getLineOpacity(index))
                  .textAlign(TextAlign.Center)
                  .width('100%')
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .padding({ left: 24, right: 24 })
                  .animation({ duration: 260, curve: Curve.FastOutSlowIn })
                }
                .width('100%')
                .justifyContent(FlexAlign.Center)
              }
            })
          }

          // 占位块：保证最后一句话能滚动到屏幕中间
          ListItem() {
            Row().height(120)
          }
        }
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .layoutWeight(1)
        .width('100%')
        .height('100%')

        // 底部播放控制总区域
        Column() {
          // 进度条与当前外播时间控制
          Row({ space: 14 }) {
            Text(this.formatTime(this.playState.time))
              .fontSize(12)
              .fontColor('rgba(226,236,255,0.86)')
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
              .trackThickness(4)
              .layoutWeight(1)
              .onChange((value: number, mode: SliderChangeMode) => {
                // 等待用户拖拽完成或点击才触发播放位置修改
                if (mode === SliderChangeMode.End || mode === SliderChangeMode.Click) {
                  playManager.seekPlay(value)
                }
              })

            Text(this.formatTime(this.playState.duration))
              .fontSize(12)
              .fontColor('rgba(226,236,255,0.86)')
              .width(42)
              .textAlign(TextAlign.Start)
          }
          .width('100%')
          .padding({ left: 20, right: 20, bottom: 20 })

          // 控制按钮核心区域 (只保留上一首 / 播放(暂停) / 下一首，移除列表和循环模式)
          Row({ space: 32 }) {
            // 上一首歌
            Image($r('app.media.ic_prev'))
              .width(36).height(36)
              .fillColor('#EAF3FF')
              .onClick(() => playManager.prevPlay())

            // 播放/暂停控制按钮(大圆背景)
            Row() {
              Image(this.playState.isPlay ? $r('app.media.ic_paused') : $r('app.media.ic_play'))
                .width(36).height(36)
                .fillColor('#12315A')
            }
            .width(76).height(76)
            .backgroundColor('#EAF3FF')
            .borderRadius(38)
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

            // 下一首歌
            Image($r('app.media.ic_next'))
              .width(36).height(36)
              .fillColor('#EAF3FF')
              .onClick(() => playManager.nextPlay())
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
        }
        .padding({ bottom: 48, top: 20 })
        .width('100%')
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#0A1325')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}
