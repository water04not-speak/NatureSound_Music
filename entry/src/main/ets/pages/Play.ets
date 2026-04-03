import { GlobalMusic } from "../models/globalMusic"
import { SongItemType } from "../models/music"
import { AppStorageV2 } from "@kit.ArkUI"
import { playManager } from "../utils/AvPlayerManager"
import { ThemeState } from "../models/theme"
import { getScreenHeightVp, getScreenWidthVp, resolveByScreenHeight, resolveByScreenWidth } from '../utils/ScreenUtils'
import { Lyric } from './Lyric'
import common from '@ohos.app.ability.common'
import { musicRepository } from '../utils/MusicRepository'
import { downloadManager } from '../utils/DownloadManager'
import { getDefaultSongItems } from '../utils/MusicSeedData'

// 跳转页面入口函数
@Builder
export function PlayBuilder() {
  Play()
}

@ComponentV2
struct Play {
  @Local isShowPlaylist: boolean = false
  @Local swiperIndex: number = 0  // 0=播放页 1=歌词页，左滑进入歌词
  pathStack : NavPathStack = new NavPathStack();

  songs: SongItemType[] = getDefaultSongItems()
  // 当前播放的歌曲
  @Local
  playState:GlobalMusic=playManager.currentSong
  @Local lastSyncedSongId: string = ''
  themeState: ThemeState = AppStorageV2.connect(ThemeState, 'THEME_STATE', () => new ThemeState())!

  private mergeSongItem(base: SongItemType, patch: Partial<SongItemType>): SongItemType {
    const merged: SongItemType = {
      img: base.img,
      name: base.name,
      author: base.author,
      url: base.url,
      id: base.id,
      title: base.title,
      singer: base.singer,
      cover: base.cover,
      lyric: base.lyric,
      isFavorite: base.isFavorite,
      createTime: base.createTime,
      lyrics: base.lyrics,
      lyricLines: base.lyricLines
    }

    if (patch.img !== undefined) merged.img = patch.img
    if (patch.name !== undefined) merged.name = patch.name
    if (patch.author !== undefined) merged.author = patch.author
    if (patch.url !== undefined) merged.url = patch.url
    if (patch.id !== undefined) merged.id = patch.id
    if (patch.title !== undefined) merged.title = patch.title
    if (patch.singer !== undefined) merged.singer = patch.singer
    if (patch.cover !== undefined) merged.cover = patch.cover
    if (patch.lyric !== undefined) merged.lyric = patch.lyric
    if (patch.isFavorite !== undefined) merged.isFavorite = patch.isFavorite
    if (patch.createTime !== undefined) merged.createTime = patch.createTime
    if (patch.lyrics !== undefined) merged.lyrics = patch.lyrics
    if (patch.lyricLines !== undefined) merged.lyricLines = patch.lyricLines

    return merged
  }

  private getCurrentSongItem(): SongItemType | undefined {
    // 【通俗解释】先从“当前播放队列”拿歌；拿不到时再按URL去全量列表兜底。
    if (this.playState.playList.length > 0 && this.playState.playIndex >= 0 && this.playState.playIndex < this.playState.playList.length) {
      return this.playState.playList[this.playState.playIndex]
    }
    return this.songs.find((song: SongItemType) => song.url === this.playState.url)
  }

  private getCurrentSongId(): string {
    if (this.playState.id && this.playState.id.trim().length > 0) {
      return this.playState.id
    }
    return this.getCurrentSongItem()?.id ?? ''
  }

  private updateSongInLists(songId: string, patch: Partial<SongItemType>): void {
    this.songs = this.songs.map((song: SongItemType) => song.id === songId ? this.mergeSongItem(song, patch) : song)
    this.playState.playList = this.playState.playList.map((song: SongItemType) => song.id === songId ? this.mergeSongItem(song, patch) : song)
  }

  private syncPlayStateFromCurrentItem(): void {
    // 【通俗解释】把“当前歌曲对象”同步到全局播放状态，保证封面、歌名、歌词等信息统一刷新。
    const current = this.getCurrentSongItem()
    if (!current) {
      return
    }
    this.playState.id = current.id
    this.playState.img = current.img
    this.playState.name = current.name
    this.playState.author = current.author
    this.playState.url = current.url
    this.playState.isFavorite = current.isFavorite
    this.playState.lyric = current.lyric
    this.playState.lyrics = current.lyrics
    this.playState.lyricLines = current.lyricLines
  }

  private async syncCurrentSongFromRepository(): Promise<void> {
    // 【通俗解释】从数据库读这首歌的最新状态（例如：是否已收藏、是否有补全歌词），再回写到页面和队列。
    const songId = this.getCurrentSongId()
    if (!songId) {
      return
    }
    try {
      const abilityCtx = getContext(this) as common.UIAbilityContext
      const latest = await musicRepository.getSongById(abilityCtx, songId)
      if (!latest) {
        return
      }
      this.playState.id = latest.id
      this.playState.isFavorite = latest.isFavorite
      if (latest.lyric && latest.lyric.trim().length > 0) {
        this.playState.lyric = latest.lyric
      }
      this.updateSongInLists(songId, {
        isFavorite: latest.isFavorite,
        lyric: latest.lyric,
        lyrics: latest.lyrics,
        lyricLines: latest.lyricLines
      })
    } catch (error) {
      console.error('[Play] 同步歌曲状态失败:', JSON.stringify(error))
    }
  }

  private async toggleCurrentFavorite(): Promise<void> {
    // 【通俗解释】先“乐观更新”UI，再落库；如果落库失败就回滚，避免界面和真实数据不一致。
    const songId = this.getCurrentSongId()
    if (!songId) {
      return
    }

    const oldFavorite = this.playState.isFavorite === true
    const optimistic = !oldFavorite
    this.playState.isFavorite = optimistic
    this.updateSongInLists(songId, { isFavorite: optimistic })

    try {
      const abilityCtx = getContext(this) as common.UIAbilityContext
      const updated = await musicRepository.toggleFavorite(abilityCtx, songId)
      if (!updated) {
        this.playState.isFavorite = oldFavorite
        this.updateSongInLists(songId, { isFavorite: oldFavorite })
        return
      }
      const finalFavorite = updated.isFavorite === true
      this.playState.isFavorite = finalFavorite
      this.updateSongInLists(songId, { isFavorite: finalFavorite })
    } catch (error) {
      this.playState.isFavorite = oldFavorite
      this.updateSongInLists(songId, { isFavorite: oldFavorite })
      console.error('[Play] 收藏切换失败:', JSON.stringify(error))
    }
  }

  private async downloadCurrentSong(): Promise<void> {
    // 【通俗解释】下载按钮只做“触发下载任务”，真正下载、进度和缓存记录由 DownloadManager 统一处理。
    const current = this.getCurrentSongItem()
    if (!current || !current.id) {
      return
    }
    try {
      const abilityCtx = getContext(this) as common.UIAbilityContext
      await downloadManager.downloadSong(abilityCtx, current.id, current.url, current.name)
    } catch (error) {
      console.error('[Play] 下载触发失败:', JSON.stringify(error))
    }
  }

  private async initPageData(): Promise<void> {
    // 【通俗解释】页面启动时按“默认种子 -> 数据库”两层加载，确保冷启动有数据、热启动有最新状态。
    const abilityCtx = getContext(this) as common.UIAbilityContext
    this.songs = getDefaultSongItems()
    try {
      await musicRepository.init(abilityCtx)
      const dbSongs = await musicRepository.getAllSongs(abilityCtx)
      if (dbSongs.length > 0) {
        this.songs = dbSongs
      }
    } catch (error) {
      console.error('[Play] 初始化音乐库失败，使用本地默认数据:', JSON.stringify(error))
    }

    if (this.playState.playList.length === 0 && this.songs.length > 0) {
      this.playState.playList = [...this.songs]
      this.playState.playIndex = 0
    } else if (this.playState.playList.length > 0) {
      this.playState.playList = this.playState.playList.map((item: SongItemType) => {
        const matched = this.songs.find((song: SongItemType) => song.id === item.id || song.url === item.url)
        return matched ? this.mergeSongItem(item, matched) : item
      })
    }

    this.syncPlayStateFromCurrentItem()
    this.lastSyncedSongId = this.getCurrentSongId()
    await this.syncCurrentSongFromRepository()
  }

  aboutToAppear() {
    void this.initPageData()
  }

  @Monitor('playState')
  onSongStateChange() {
    const currentSongId = this.getCurrentSongId()
    if (!currentSongId || currentSongId === this.lastSyncedSongId) {
      return
    }
    this.lastSyncedSongId = currentSongId
    void this.syncCurrentSongFromRepository()
  }
  // playState:SongItemType = this.songs[0]


  @Builder
  deleteButton(index: number) {
    Button('删除')
      .backgroundColor(this.themeState.getPlayPageForegroundColor())
      .fontColor(this.themeState.getCardBackgroundColor())
      .width(80)
      .height('100%')
      .type(ButtonType.Normal)
      .onClick(()=>{
        // 按接收到的索引删除歌曲
        playManager.removeSong(index)
        //   回退到前一页
        if(this.playState.playList.length===0){
          this.pathStack.pop()
        }
      })
  }

  number2time(number: number): string {
    // 毫秒 → 秒 → 分+秒; 先判断是否大于1分钟
    if (number > 60 * 1000) {
      const s = Math.floor(number/1000%60)
      const m = Math.floor(number/1000/60)
      const second = s.toString().padStart(2, '0')
      const minute = m.toString().padStart(2, '0')
      return minute + ':' + second
    } else {
      const s = Math.floor(number/1000%60)
      const second = s.toString().padStart(2, '0')
      return '00:' + second
    }
  }

  // 响应式布局配置
  private getScreenWidth(): number {
    return getScreenWidthVp()
  }

  private getScreenHeight(): number {
    return getScreenHeightVp()
  }

  private getRecordSize(): number {
    return resolveByScreenWidth(this.getScreenWidth(), 300, 400, 500)
  }

  private getStylusSize(): number {
    return resolveByScreenWidth(this.getScreenWidth(), 200, 250, 300)
  }

  private getTopMargin(): number {
    return resolveByScreenHeight(this.getScreenHeight(), 50, 80, 120)
  }

  // 滚动相关属性
  @Local scrollPosition: number = 0
  @Local showScrollTopButton: boolean = false
  @Local showScrollBottomButton: boolean = false
  private scrollController: Scroller = new Scroller()
  @Builder
  PlaylistBuilder() {
    Column() {
      // 头部选项卡
      Scroll() {
        Row() {
          Row({ space: 4 }) {
            Text('正在播放')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeState.getPrimaryTextColor())
              .border({ width: { bottom: 2 }, color: this.themeState.getPrimaryTextColor() })
              .padding({ bottom: 4 })
              
            Image(('app.media.ic_link')) 
              .width(14).height(14)
              .fillColor(this.themeState.getSecondaryTextColor())
              .visibility(Visibility.None) 
              
            Text(this.playState.playList.length.toString())
              .fontSize(12)
              .fontColor(this.themeState.getSecondaryTextColor())
          }
          .margin({ right: 24 })
        }
        .width('100%')
        .padding({ top: 20, left: 20, right: 20, bottom: 10 })
        .backgroundColor(this.themeState.getCardBackgroundColor())
        .borderRadius({ topLeft: 24, topRight: 24 })
      }.scrollable(ScrollDirection.Horizontal).scrollBar(BarState.Off)

      // 控制栏设置
      Row() {
        Row({ space: 8 }) {
          Image(('app.media.ic_repeat'))
            .width(20)
            .height(20)
            .fillColor(this.themeState.getSecondaryTextColor())
          Text('顺序播放')
            .fontSize(14)
            .fontColor(this.themeState.getSecondaryTextColor())
        }
        
        Blank()
        
        Row({ space: 16 }) {
          Image(('app.media.ic_download_o'))
            .width(20)
            .height(20)
            .fillColor(this.themeState.getSecondaryTextColor())
            .onClick(() => {
              void this.downloadCurrentSong()
            })
          Image(('app.media.ic_collect'))
            .width(20)
            .height(20)
            .fillColor(this.themeState.getSecondaryTextColor())
            .onClick(() => {
              void this.toggleCurrentFavorite()
            })
          Image(('app.media.ic_close')) 
            .width(20)
            .height(20)
            .fillColor(this.themeState.getSecondaryTextColor())
            .onClick(() => {
              this.isShowPlaylist = false
            })
        }
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 10 })
      .backgroundColor(this.themeState.getCardBackgroundColor())

      List({ scroller: this.scrollController }) {
        ForEach(this.playState.playList, (item: SongItemType, index: number) => {
          ListItem() {
            Row() {
              Row({ space: 6 }) {
                Text(item.name)
                  .fontSize(15)
                  .fontWeight(FontWeight.Regular)
                  .fontColor(this.playState.url === item.url ? '#1ECE6A' : this.themeState.getPrimaryTextColor())
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .layoutWeight(1)
                
                Text(' - ' + item.author)
                  .fontSize(12)
                  .fontColor(this.playState.url === item.url ? '#1ECE6A' : this.themeState.getSecondaryTextColor())
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .layoutWeight(1)
              .alignItems(VerticalAlign.Bottom)

              Row({ space: 16 }) {
                if (this.playState.url === item.url) {
                  Image(('app.media.wave'))
                    .width(16)
                    .height(16)
                    .fillColor('#1ECE6A')
                }
                Image(('app.media.ic_close'))
                  .width(16)
                  .height(16)
                  .fillColor(this.themeState.getSecondaryTextColor())
                  .onClick(() => {
                    playManager.removeSong(index)
                    if(this.playState.playList.length===0){
                      this.pathStack.pop()
                    }
                  })
                Image(('app.media.ic_list'))
                  .width(16)
                  .height(16)
                  .fillColor(this.themeState.getSecondaryTextColor())
              }
            }
            .padding({ left: 20, right: 20, top: 12, bottom: 12 })
            .width('100%')
            .alignItems(VerticalAlign.Center)
            .onClick(()=>{
              playManager.singPlay(item)
            })
          }
          .swipeAction({
            end: this.deleteButton(index)
          })
          .border({
            width: { bottom: 1 },
            color: this.themeState.getDividerColor()
          })
        }, (item: SongItemType) => item.id)
      }
      .width('100%')
      .height('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeState.getCardBackgroundColor())
  }

  build() {
    NavDestination() {
      Swiper() {
        Stack() {
                  // 背景图片
          Image(this.playState.img)
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Cover)
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
            .blur(60)

          // 半透明遮罩层（提升前景文字可读性）
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor(this.themeState.getIsDark() ? 'rgba(0,0,0,0.6)' : 'rgba(255,255,255,0.7)')
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

        // 内容
        Column() {
          //   播放界面
          Column() {
            // 图片
            Stack({ alignContent: Alignment.Top }) {
              Row() {
                Row() {
                  Image(this.playState.img)
                    .width('70%')
                    .borderRadius(400)
                }
                .backgroundImage($r('app.media.ic_cd'))
                .backgroundImageSize(ImageSize.Cover)
                .width('100%')
                .borderRadius(400)
                .clip(true)
                .aspectRatio(1)
              }
              .margin({ top: this.getTopMargin() })
              .width(this.getRecordSize())
              .aspectRatio(1)
              .justifyContent(FlexAlign.Center)
              .padding(24)
              // 唱针
              Image($r('app.media.ic_stylus'))
                .width(this.getStylusSize())
                .aspectRatio(1)
                .rotate({ angle: -55, centerX: this.getStylusSize() / 2, centerY: 30 })
                .animation({ duration: 500 })
            }
            // 歌曲信息（使用主题前景色保证对比度）
            Stack() {
              Column({ space: 8 }) {
                Text(this.playState.name)
                  .fontSize(28)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.themeState.getPlayPageForegroundColor())
                Text(this.playState.author)
                  .fontSize(18)
                  .fontColor(this.themeState.getSecondaryTextColor())
              }
              .layoutWeight(1)
              .justifyContent(FlexAlign.Center)
            }
            .layoutWeight(1)
            // 操作按钮区
            Row() {
              Image(this.playState.isFavorite ? $r('app.media.ic_like') : $r('app.media.ic_favorite'))
                .fillColor(this.playState.isFavorite ? '#ff4d4f' : this.themeState.getPlayPageForegroundColor())
                .width(28)
                .onClick(() => {
                  void this.toggleCurrentFavorite()
                })

              Image($r("app.media.ic_comment_o"))
                .fillColor(this.themeState.getPlayPageForegroundColor())
                .width(26)
                .onClick(() => {
                  // 评论功能暂未接入后端，先保留明确提示，避免乱码和无意义日志。
                  console.info('评论功能暂未开放')
                })

              Image($r("app.media.ic_bells_o"))
                .fillColor(this.themeState.getPlayPageForegroundColor())
                .width(28)
                .onClick(() => {
                  // 消息通知功能预留入口。
                  console.info('通知功能暂未开放')
                })

              Image($r("app.media.ic_download_o"))
                .fillColor(this.themeState.getPlayPageForegroundColor())
                .width(28)
                .onClick(() => {
                  void this.downloadCurrentSong()
                })
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceAround)
            .padding({ top: 12, bottom: 24 })
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
                  .onChange((value)=>{
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
                if(this.playState.playMode==='auto'){
                  Image($r('app.media.ic_auto'))
                    .fillColor(this.themeState.getPlayPageForegroundColor())
                    .width(30)
                    .onClick(()=>{
                      console.info('播放模式切换为随机')
                      this.playState.playMode='random'
                    })
                }else if(this.playState.playMode==='random'){
                  Image($r('app.media.ic_random'))
                    .fillColor(this.themeState.getPlayPageForegroundColor())
                    .width(30)
                    .onClick(()=>{
                      console.info('播放模式切换为重复')
                      this.playState.playMode='repeat'
                    })
                }else if(this.playState.playMode==='repeat'){
                  Image($r('app.media.ic_repeat'))
                    .fillColor(this.themeState.getPlayPageForegroundColor())
                    .width(30)
                    .onClick(()=>{
                      console.info('播放模式切换为顺序')
                      this.playState.playMode='auto'
                    })
                }

                Image($r("app.media.ic_prev"))
                  .fillColor(this.themeState.getPlayPageForegroundColor())
                  .width(30)
                  .onClick(()=>{
                    console.info('上一首按钮被点击')
                    playManager.prevPlay()
                  })

                // 播放按钮
                Image(this.playState.isPlay?$r('app.media.ic_paused'):$r('app.media.ic_play'))
                  .fillColor(this.themeState.getPlayPageForegroundColor())
                  .width(50)
                  .onClick(()=>{
                    console.info('播放按钮被点击，当前播放状态:', this.playState.isPlay)
                    if (this.playState.isPlay) {
                      console.info('调用playManager.paused()')
                      playManager.paused()
                    } else {
                      console.info('调用playManager.singPlay()')
                      if (this.playState.playList.length > 0 && this.playState.playIndex >= 0 && this.playState.playIndex < this.playState.playList.length) {
                        console.info('播放列表有歌曲，播放索引:', this.playState.playIndex)
                        playManager.singPlay(this.playState.playList[this.playState.playIndex])
                      } else {
                        // 播放列表为空或索引无效，初始化播放列表
                        console.info('播放列表为空或索引无效，初始化播放列表')
                        if (this.songs.length > 0) {
                          console.info('初始化播放列表，歌曲数量:', this.songs.length)
                          this.playState.playList = [...this.songs]
                          this.playState.playIndex = 0
                          const firstSong = this.playState.playList[0]
                          this.playState.img = firstSong.img
                          this.playState.name = firstSong.name
                          this.playState.author = firstSong.author
                          this.playState.url = firstSong.url
                          console.info('播放第一首歌曲:', firstSong.name)
                          playManager.singPlay(firstSong)
                        } else {
                          console.info('歌曲列表为空，无法播放')
                        }
                      }
                    }
                  })
                // 下一首
                Image($r('app.media.ic_next'))
                  .fillColor(this.themeState.getPlayPageForegroundColor())
                  .width(30)
                  .onClick(()=>{
                    console.info('下一首按钮被点击')
                    playManager.nextPlay()
                  })
                // 播放列表
                Image($r('app.media.ic_song_list'))
                  .fillColor(this.themeState.getPlayPageForegroundColor())
                  .width(30)
                  .onClick(() => {
                    console.info('播放列表按钮被点击，显示播放列表')
                    this.isShowPlaylist = true
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
          .layoutWeight(1)
          .width('100%')
        }
        .width('100%')
        .height('100%')
      } // Close Stack

      // 歌词页面
      Lyric({
        swiperIndex: this.swiperIndex,
        onBack: () => {
          this.swiperIndex = 0
        }
      })
    } // Close Swiper
    .onChange((i: number) => { this.swiperIndex = i })
    .indicator(false)
    .loop(false)
    .width('100%')
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  } // Close NavDestination
  .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack
    })
  .hideTitleBar(true)
  .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      .bindSheet(this.isShowPlaylist, this.PlaylistBuilder(), { height: SheetSize.MEDIUM, dragBar: true, backgroundColor: this.themeState.getCardBackgroundColor(), showClose: true })
  }
}