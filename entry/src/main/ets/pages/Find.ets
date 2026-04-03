import { AppStorageV2 } from '@kit.ArkUI'
import { GlobalMusic } from '../models/globalMusic'
import { ThemeState } from '../models/theme'
import { SongItemType } from '../models/music'
import { musicRepository } from '../utils/MusicRepository'
import { playManager } from '../utils/AvPlayerManager'
import { getScreenWidthVp, resolveByScreenWidth } from '../utils/ScreenUtils'
import common from '@ohos.app.ability.common'
import { getDefaultSongItems } from '../utils/MusicSeedData'

@ComponentV2
export struct Find {
  playState: GlobalMusic = playManager.currentSong
  @Local private songs: SongItemType[] = getDefaultSongItems()
  @Local private isLoading: boolean = true
  @Local private favoriteOnly: boolean = false
  @Local private errorText: string = ''

  themeState: ThemeState = AppStorageV2.connect(ThemeState, 'THEME_STATE', () => new ThemeState())!
  pathStack: NavPathStack = AppStorageV2.connect(NavPathStack, 'navStack', () => new NavPathStack())!

  private getScreenWidth(): number {
    return getScreenWidthVp()
  }

  private getImageWidth(): number {
    return resolveByScreenWidth(this.getScreenWidth(), 52, 56, 60)
  }

  private getMoreIconWidth(): number {
    return resolveByScreenWidth(this.getScreenWidth(), 20, 22, 24)
  }

  private getTitleFontSize(): number {
    return resolveByScreenWidth(this.getScreenWidth(), 22, 25, 28)
  }

  private getSubtitleFontSize(): number {
    return resolveByScreenWidth(this.getScreenWidth(), 13, 14, 15)
  }

  private getSongNameFontSize(): number {
    return resolveByScreenWidth(this.getScreenWidth(), 15, 16, 17)
  }

  private getAuthorFontSize(): number {
    return resolveByScreenWidth(this.getScreenWidth(), 12, 12, 13)
  }

  private getListItemHeight(): number {
    return resolveByScreenWidth(this.getScreenWidth(), 74, 78, 82)
  }

  private getListHorizontalPadding(): number {
    return resolveByScreenWidth(this.getScreenWidth(), 12, 14, 16)
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

  private async initSongs(): Promise<void> {
    const abilityCtx = getContext(this) as common.UIAbilityContext
    this.isLoading = true
    this.errorText = ''

    try {
      await musicRepository.init(abilityCtx)
      await this.reloadSongs()
    } catch (error) {
      console.error('[Find] Failed to load songs:', JSON.stringify(error))
      this.errorText = '音乐列表加载失败'
      this.isLoading = false
    }
  }

  private async reloadSongs(): Promise<void> {
    const abilityCtx = getContext(this) as common.UIAbilityContext
    try {
      this.songs = this.favoriteOnly
        ? await musicRepository.getFavoriteSongs(abilityCtx)
        : await musicRepository.getAllSongs(abilityCtx)
    } catch (error) {
      console.error('[Find] Failed to refresh songs:', JSON.stringify(error))
      this.errorText = '音乐列表加载失败'
      this.songs = []
    } finally {
      this.isLoading = false
    }
  }

  private openSong(item: SongItemType): void {
    this.pathStack.pushPathByName('Play', null, false)
    playManager.singPlayFromList(item, this.songs)
  }

  private updateFavoriteState(itemId: string, isFavorite: boolean): void {
    this.songs = this.songs.map((song: SongItemType) => {
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

  private checkFavorite(songId: string, fallback: boolean | undefined): boolean {
    const song = this.songs.find((s: SongItemType) => s.id === songId)
    return song ? (song.isFavorite === true) : (fallback === true)
  }

  private async toggleFavorite(item: SongItemType): Promise<void> {
    const abilityCtx = getContext(this) as common.UIAbilityContext
    const currentItem = this.songs.find((s: SongItemType) => s.id === item.id) ?? item
    const nextState = !currentItem.isFavorite
    this.updateFavoriteState(item.id, nextState)

    try {
      const updatedItem = await musicRepository.toggleFavorite(abilityCtx, item.id)
      if (updatedItem) {
        this.updateFavoriteState(item.id, updatedItem.isFavorite ?? nextState)
      }
    } catch (error) {
      this.updateFavoriteState(item.id, currentItem.isFavorite ?? false)
      console.error('[Find] Failed to toggle favorite:', JSON.stringify(error))
    }
  }

  private vipSongIdSet: Set<string> = new Set<string>([
    '0001', '0003', '0006', '0007', '0013', '0029', '0030', '0032', '0046'
  ])

  private isVipSong(songId: string): boolean {
    return this.vipSongIdSet.has(songId)
  }

  aboutToAppear(): void {
    const abilityCtx = getContext(this) as common.UIAbilityContext
    void this.themeState.initFromContext(abilityCtx)
    void this.initSongs()
  }

  build() {
    Column() {
      Row() {
        Row({ space: 8 }) {
          Text('我的歌单')
            .fontSize(this.getTitleFontSize())
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeState.getPrimaryTextColor())
            .opacity(0.8)

          Text('My playlist~')
            .fontSize(this.getSubtitleFontSize())
            .fontStyle(FontStyle.Italic)
            .fontFamily('serif')
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeState.getSecondaryTextColor())
            .opacity(0.82)
            .margin({ top: 5 })
        }
        .layoutWeight(1)

        Text(this.favoriteOnly ? '收藏中' : '全部')
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeState.getPrimaryTextColor())
          .padding({ left: 10, right: 10, top: 6, bottom: 6 })
          .backgroundColor(this.themeState.getCardBackgroundColor())
          .borderRadius(14)
          .onClick(() => {
            this.favoriteOnly = !this.favoriteOnly
            void this.reloadSongs()
          })
      }
      .width('100%')
      .padding({ left: this.getListHorizontalPadding(), right: this.getListHorizontalPadding(), top: 12, bottom: 6 })

      if (this.isLoading) {
        Column() {
          LoadingProgress()
          Text('正在加载本地音乐库...')
            .fontSize(14)
            .fontColor(this.themeState.getSecondaryTextColor())
            .margin({ top: 12 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else if (this.errorText) {
        Column() {
          Text(this.errorText)
            .fontSize(14)
            .fontColor(this.themeState.getSecondaryTextColor())
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        List() {
          ForEach(this.songs, (item: SongItemType) => {
            ListItem() {
              Row({ space: 10 }) {
                Stack({ alignContent: Alignment.BottomEnd }) {
                  Image(item.cover ?? item.img)
                    .width(this.getImageWidth())
                    .height(this.getImageWidth())
                    .borderRadius(10)
                    .objectFit(ImageFit.Cover)

                  if (this.playState.url === item.url) {
                    Column()
                      .width(this.getImageWidth())
                      .height(this.getImageWidth())
                      .backgroundColor(this.getPlayingMaskColor())
                      .borderRadius(10)
                  }

                  if (this.playState.url === item.url) {
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
                .width(this.getImageWidth())
                .height(this.getImageWidth())

                Column({ space: 4 }) {
                  Row({ space: 8 }) {
                    if (this.shouldUseSpecialLatinStyle(item.name)) {
                      Text(item.name)
                        .fontSize(this.getSongNameFontSize())
                        .fontWeight(FontWeight.Medium)
                        .fontStyle(FontStyle.Italic)
                        .fontFamily('serif')
                        .fontColor(this.playState.url === item.url ? this.getActiveAccentColor() : this.themeState.getPrimaryTextColor())
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .layoutWeight(1)
                    } else {
                      Text(item.name)
                        .fontSize(this.getSongNameFontSize())
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
                    .fontSize(this.getAuthorFontSize())
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
                    .width(this.getMoreIconWidth())
                    .height(this.getMoreIconWidth())
                    .fillColor(this.themeState.getIconColor())
                    .onClick(() => {
                      // 保留现有布局，后续可接更多菜单
                    })
                }
                .alignItems(VerticalAlign.Center)
              }
              .width('100%')
              .height(this.getListItemHeight())
              .padding({ left: this.getListHorizontalPadding(), right: this.getListHorizontalPadding() })
              .backgroundColor(this.playState.url === item.url ? this.getActiveRowColor() : this.themeState.getBackgroundColor())
              .borderRadius(this.playState.url === item.url ? 12 : 0)
              .border({ width: { bottom: 0.5 }, color: this.themeState.getDividerColor() })
            }
          }, (item: SongItemType) => item.id)
        }
        .width('100%')
        .height('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .padding({ bottom: 12 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeState.getBackgroundColor())
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}
