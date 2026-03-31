import { AppStorageV2 } from '@kit.ArkUI'
import { ThemeState } from '../models/theme'
import { SongItemType } from '../models/music'
import { playManager } from '../utils/AvPlayerManager'
import { musicRepository } from '../utils/MusicRepository'
import { defaultMusicSeeds } from '../utils/MusicSeedData'
import { buildSearchHintPool, pickRandomSearchHint } from '../utils/SearchHintUtils'
import { GlobalMusic } from '../models/globalMusic'
import common from '@ohos.app.ability.common'

@Builder
export function SearchBuilder() {
  SearchPage()
}

@ComponentV2
export struct SearchPage {
  @Local searchText: string = ''
  @Local searchResults: SongItemType[] = []
  @Local isSearching: boolean = false
  @Local searchHistory: string[] = []
  @Local isLoading: boolean = true
  @Local searchHint: string = '搜索歌曲、歌手'
  @Local hotSearches: string[] = [
    '毛不易',
    'Unit 731',
    'YOUTH',
    '吹梦到西洲',
    '杜宣达',
    '李荣浩',
    '青丝'
  ]

  pathStack: NavPathStack = AppStorageV2.connect(NavPathStack, 'navStack', () => new NavPathStack())!
  themeState: ThemeState = AppStorageV2.connect(ThemeState, 'THEME_STATE', () => new ThemeState())!
  playState: GlobalMusic = playManager.currentSong
  private searchHintPool: string[] = []
  private searchHintTimer?: number

  private vipSongIdSet: Set<string> = new Set<string>([
    '0001', '0003', '0006', '0007', '0013', '0029', '0030', '0032', '0046'
  ])

  private isVipSong(songId: string): boolean {
    return this.vipSongIdSet.has(songId)
  }

  private shouldUseSpecialLatinStyle(text: string): boolean {
    return /[A-Za-z]/.test(text)
  }

  private withAlpha(color: string, alphaHex: string): string {
    const normalized = color.trim()
    if (/^#[0-9a-fA-F]{6}$/.test(normalized)) {
      return `#${alphaHex}${normalized.slice(1)}`
    }
    if (/^#[0-9a-fA-F]{8}$/.test(normalized)) {
      return `#${alphaHex}${normalized.slice(3)}`
    }
    return color
  }

  private getActiveAccentColor(): string {
    return this.themeState.getIconColor()
  }

  private getPlayingMaskColor(): string {
    const alpha = this.themeState.getIsDark() ? '1F' : '24'
    return this.withAlpha(this.themeState.getPlayPageForegroundColor(), alpha)
  }

  private getPlayingBadgeColor(): string {
    const alpha = this.themeState.getIsDark() ? '42' : '2A'
    return this.withAlpha(this.getActiveAccentColor(), alpha)
  }

  private getActiveRowColor(): string {
    const alpha = this.themeState.getIsDark() ? '2B' : '18'
    return this.withAlpha(this.getActiveAccentColor(), alpha)
  }

  private checkFavorite(songId: string, fallback: boolean | undefined): boolean {
    const song = this.searchResults.find((s: SongItemType) => s.id === songId)
    return song ? (song.isFavorite === true) : (fallback === true)
  }

  private updateFavoriteState(itemId: string, isFavorite: boolean): void {
    this.searchResults = this.searchResults.map((song: SongItemType) => {
      if (song.id !== itemId) {
        return song
      }
      return {
        id: song.id,
        name: song.name,
        author: song.author,
        url: song.url,
        img: song.img,
        title: song.title,
        singer: song.singer,
        cover: song.cover,
        lyric: song.lyric,
        isFavorite: isFavorite,
        createTime: song.createTime,
        lyrics: song.lyrics,
        lyricLines: song.lyricLines
      }
    })
  }

  private async initSongs(): Promise<void> {
    const abilityCtx = getContext(this) as common.UIAbilityContext
    this.isLoading = true
    try {
      await musicRepository.init(abilityCtx)
    } catch (error) {
      console.error('[Search] Failed to load songs:', JSON.stringify(error))
    } finally {
      this.isLoading = false
    }
  }

  private initSearchHintRotation(): void {
    this.searchHintPool = buildSearchHintPool(defaultMusicSeeds)
    this.searchHint = pickRandomSearchHint(this.searchHintPool, '搜索歌曲、歌手')

    if (this.searchHintTimer !== undefined) {
      clearInterval(this.searchHintTimer)
    }

    this.searchHintTimer = setInterval(() => {
      this.searchHint = pickRandomSearchHint(this.searchHintPool, '搜索歌曲、歌手')
    }, 2600)
  }

  private stopSearchHintRotation(): void {
    if (this.searchHintTimer !== undefined) {
      clearInterval(this.searchHintTimer)
      this.searchHintTimer = undefined
    }
  }

  aboutToAppear() {
    const abilityCtx = getContext(this) as common.UIAbilityContext
    void this.themeState.initFromContext(abilityCtx)
    void this.initSongs()
    this.initSearchHintRotation()
  }

  aboutToDisappear() {
    this.stopSearchHintRotation()
  }

  private performSearch(keyword: string): void {
    const normalized = keyword.trim()
    if (!normalized) {
      this.searchResults = []
      this.isSearching = false
      return
    }

    this.isSearching = true
    this.searchText = normalized

    setTimeout(async () => {
      try {
        const abilityCtx = getContext(this) as common.UIAbilityContext
        this.searchResults = await musicRepository.searchSongs(abilityCtx, normalized, 50, 0)

        if (!this.searchHistory.includes(normalized)) {
          this.searchHistory.unshift(normalized)
          if (this.searchHistory.length > 10) {
            this.searchHistory.pop()
          }
        }
      } catch (error) {
        console.error('[Search] Failed to search songs:', JSON.stringify(error))
        this.searchResults = []
      } finally {
        this.isSearching = false
      }
    }, 120)
  }

  private clearHistory(): void {
    this.searchHistory = []
  }

  private openSong(item: SongItemType): void {
    this.pathStack.pushPathByName('Play', null, false)
    playManager.singPlayFromList(item, this.searchResults.length > 0 ? this.searchResults : [])
  }

  private async toggleFavorite(item: SongItemType): Promise<void> {
    const abilityCtx = getContext(this) as common.UIAbilityContext
    const currentItem = this.searchResults.find((s: SongItemType) => s.id === item.id) ?? item
    const nextState = !currentItem.isFavorite
    this.updateFavoriteState(item.id, nextState)

    try {
      const updatedItem = await musicRepository.toggleFavorite(abilityCtx, item.id)
      if (updatedItem) {
        this.updateFavoriteState(item.id, updatedItem.isFavorite ?? nextState)
      }
    } catch (error) {
      this.updateFavoriteState(item.id, currentItem.isFavorite ?? false)
      console.error('[Search] Failed to toggle favorite:', JSON.stringify(error))
    }
  }

  build() {
    NavDestination() {
      Column() {
        Row({ space: 12 }) {
          Image($r('app.media.ic_search'))
            .width(20)
            .fillColor(this.themeState.getSecondaryTextColor())

          TextInput({ placeholder: this.searchHint, text: this.searchText })
            .layoutWeight(1)
            .fontColor(this.themeState.getPrimaryTextColor())
            .placeholderColor(this.themeState.getSecondaryTextColor())
            .caretColor('#34C9C3')
            .fontSize(15)
            .onSubmit(() => {
              if (this.searchText && this.searchText.trim()) {
                this.performSearch(this.searchText.trim())
              }
            })
            .onChange((value: string) => {
              this.searchText = value
            })

          if (this.searchText) {
            Image($r('app.media.ic_close'))
              .width(18)
              .fillColor(this.themeState.getSecondaryTextColor())
              .onClick(() => {
                this.searchText = ''
                this.searchResults = []
              })
          }
        }
        .width('100%')
        .height(46)
        .backgroundColor(this.themeState.getSearchBarColor())
        .borderRadius(23)
        .padding({ left: 16, right: 16 })
        .margin({ left: 16, right: 16, top: 12, bottom: 12 })
        .shadow({ radius: 8, color: 'rgba(0,0,0,0.08)', offsetX: 0, offsetY: 2 })

        if (this.isLoading) {
          Column() {
            LoadingProgress()
            Text('正在加载本地音乐库...')
              .fontSize(14)
              .fontColor(this.themeState.getSecondaryTextColor())
              .margin({ top: 12 })
          }
          .layoutWeight(1)
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        } else if (this.searchResults.length > 0) {
          List() {
            ForEach(this.searchResults, (item: SongItemType) => {
              ListItem() {
                Row({ space: 10 }) {
                  Stack({ alignContent: Alignment.BottomEnd }) {
                    Image(item.cover ?? item.img)
                      .width(56)
                      .height(56)
                      .borderRadius(10)
                      .objectFit(ImageFit.Cover)

                    if (this.playState.url === item.url) {
                      Column()
                        .width(56)
                        .height(56)
                        .backgroundColor(this.getPlayingMaskColor())
                        .borderRadius(10)

                      Stack({ alignContent: Alignment.Center }) {
                        Column()
                          .width(22)
                          .height(22)
                          .borderRadius(11)
                          .backgroundColor(this.getPlayingBadgeColor())

                        Image($r('app.media.ic_playing'))
                          .width(14)
                          .height(14)
                          .borderRadius(7)
                      }
                      .margin({ right: 6, bottom: 6 })
                    }
                  }
                  .width(56)
                  .height(56)

                  Column({ space: 4 }) {
                    Row({ space: 8 }) {
                      if (this.shouldUseSpecialLatinStyle(item.name)) {
                        Text(item.name)
                          .fontSize(16)
                          .fontWeight(FontWeight.Medium)
                          .fontStyle(FontStyle.Italic)
                          .fontFamily('serif')
                          .fontColor(this.playState.url === item.url ? this.getActiveAccentColor() : this.themeState.getPrimaryTextColor())
                          .maxLines(1)
                          .textOverflow({ overflow: TextOverflow.Ellipsis })
                          .layoutWeight(1)
                      } else {
                        Text(item.name)
                          .fontSize(16)
                          .fontWeight(FontWeight.Medium)
                          .fontColor(this.playState.url === item.url ? this.getActiveAccentColor() : this.themeState.getPrimaryTextColor())
                          .maxLines(1)
                          .textOverflow({ overflow: TextOverflow.Ellipsis })
                          .layoutWeight(1)
                      }

                      if (this.isVipSong(item.id)) {
                        Text('VIP')
                          .fontSize(10)
                          .fontColor('#D2A04B')
                          .backgroundColor(this.withAlpha('#D2A04B', '1A'))
                          .padding({ left: 4, right: 4, top: 2, bottom: 2 })
                          .borderRadius(4)
                      }
                    }
                    .width('100%')

                    Text(item.author)
                      .fontSize(12)
                      .fontColor(this.playState.url === item.url ? this.themeState.getPrimaryTextColor() : this.themeState.getSecondaryTextColor())
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .opacity(0.86)
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                  .justifyContent(FlexAlign.Center)
                  .onClick(() => {
                    this.openSong(item)
                  })

                  Row({ space: 16 }) {
                    Row({ space: 4 }) {
                      Image(this.checkFavorite(item.id, item.isFavorite) ? $r('app.media.ic_like') : $r('app.media.ic_favorite'))
                        .width(18)
                        .height(18)
                        .fillColor(this.checkFavorite(item.id, item.isFavorite) ? '#ff4040' : this.themeState.getSecondaryTextColor())

                      Text(this.checkFavorite(item.id, item.isFavorite) ? '18.6w' : '18.5w')
                        .fontSize(12)
                        .fontColor(this.checkFavorite(item.id, item.isFavorite) ? '#ff4040' : this.themeState.getSecondaryTextColor())
                    }
                    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                    .borderRadius(14)
                    .backgroundColor(this.checkFavorite(item.id, item.isFavorite) ? 'rgba(255, 64, 64, 0.10)' : 'transparent')
                    .zIndex(1)
                    .onClick(() => {
                      void this.toggleFavorite(item)
                    })

                    Image($r('app.media.ic_more'))
                      .width(22)
                      .height(22)
                      .fillColor(this.themeState.getIconColor())
                  }
                  .alignItems(VerticalAlign.Center)
                }
                .width('100%')
                .height(78)
                .padding({ left: 16, right: 16 })
                .backgroundColor(this.playState.url === item.url ? this.getActiveRowColor() : 'transparent')
                .borderRadius(this.playState.url === item.url ? 12 : 0)
                .border({ width: { bottom: 0.5 }, color: this.themeState.getDividerColor() })
              }
            }, (item: SongItemType) => item.id)
          }
          .layoutWeight(1)
          .width('100%')
          .height('100%')
        } else if (this.isSearching) {
          Column() {
            LoadingProgress()
            Text('搜索中...')
              .fontSize(14)
              .fontColor(this.themeState.getSecondaryTextColor())
              .margin({ top: 12 })
          }
          .layoutWeight(1)
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        } else {
          Scroll() {
            Column({ space: 20 }) {
              if (this.searchHistory.length > 0) {
                Column({ space: 12 }) {
                  Row() {
                    Text('搜索历史')
                      .fontSize(16)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.themeState.getPrimaryTextColor())
                      .layoutWeight(1)

                    Text('清除')
                      .fontSize(13)
                      .fontColor(this.themeState.getSecondaryTextColor())
                      .onClick(() => {
                        this.clearHistory()
                      })
                  }
                  .width('100%')

                  Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Start }) {
                    ForEach(this.searchHistory, (keyword: string) => {
                      Text(keyword)
                        .fontSize(13)
                        .fontColor(this.themeState.getPrimaryTextColor())
                        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                        .backgroundColor(this.themeState.getCardBackgroundColor())
                        .borderRadius(16)
                        .margin({ right: 12, bottom: 12 })
                        .onClick(() => {
                          this.performSearch(keyword)
                        })
                    }, (keyword: string) => keyword)
                  }
                  .width('100%')
                }
                .width('100%')
                .padding({ left: 16, right: 16 })
              }

              Column({ space: 12 }) {
                Text('热门搜索')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeState.getPrimaryTextColor())
                  .width('100%')

                Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Start }) {
                  ForEach(this.hotSearches, (keyword: string, index: number) => {
                    Row({ space: 6 }) {
                      if (index < 3) {
                        Text(`${index + 1}`)
                          .fontSize(12)
                          .fontColor('#FF6E9E')
                          .fontWeight(FontWeight.Bold)
                      }
                      Text(keyword)
                        .fontSize(13)
                        .fontColor(this.themeState.getPrimaryTextColor())
                    }
                    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                    .backgroundColor(this.themeState.getCardBackgroundColor())
                    .borderRadius(16)
                    .margin({ right: 12, bottom: 12 })
                    .onClick(() => {
                      this.performSearch(keyword)
                    })
                  }, (keyword: string) => keyword)
                }
                .width('100%')
              }
              .width('100%')
              .padding({ left: 16, right: 16 })
            }
            .width('100%')
            .padding({ top: 8, bottom: 20 })
          }
          .layoutWeight(1)
          .width('100%')
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeState.getBackgroundColor())
      .expandSafeArea()
    }
    .title('搜索')
    .hideTitleBar(false)
  }
}
