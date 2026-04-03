// 声宴 - 板块详情页，展示当前板块歌曲列表

import { AppStorageV2 } from '@kit.ArkUI'
import { SongItemType } from '../models/music'
import { playManager } from '../utils/AvPlayerManager'
import { ThemeState } from '../models/theme'
import { getScreenHeightVp, getScreenWidthVp, resolveByScreenHeight, resolveByScreenWidth } from '../utils/ScreenUtils'
import { getHeritageSongsByRegionId } from '../utils/HeritageMusicData'

// 地域参数类
export class HeritageRegionParams {
  regionId: string = ''
  regionName: string = '声宴'
  regionCover: ResourceStr = $r('app.media.ic_cd')
  regionDescription: string = ''
  songs: SongItemType[] = []
}

@Builder
export function HeritageRegionDetailBuilder() {
  HeritageRegionDetail()
}

@ComponentV2
struct HeritageRegionDetail {
  pathStack: NavPathStack = new NavPathStack()
  themeState: ThemeState = AppStorageV2.connect(ThemeState, 'THEME_STATE', () => new ThemeState())!
  regionParams: HeritageRegionParams = AppStorageV2.connect(HeritageRegionParams, 'heritageRegionParams',
    () => new HeritageRegionParams())!
  private readonly heritageRegionIds: Set<string> = new Set([
    'yangtze-delta',
    'guangdong-hk-macao',
    'chengdu-chongqing',
    'yangtze-mid'
  ])

  get currentSongs(): SongItemType[] {
    if (this.regionParams.songs && this.regionParams.songs.length > 0) {
      return this.regionParams.songs
    }
    if (this.heritageRegionIds.has(this.regionParams.regionId)) {
      return getHeritageSongsByRegionId(this.regionParams.regionId)
    }
    return []
  }

  get sectionTitle(): string {
    if (this.heritageRegionIds.has(this.regionParams.regionId)) {
      return '非遗曲目'
    }
    return '音乐曲目'
  }

  // 响应式布局配置
  private getHeaderHeight(): number {
    return resolveByScreenHeight(getScreenHeightVp(), 280, 320, 320)
  }

  private getCoverSize(): number {
    return resolveByScreenWidth(getScreenWidthVp(), 120, 140, 140)
  }

  build() {
    NavDestination() {
      Column() {
        // 头部背景和信息
        Stack() {
          Image(this.regionParams.regionCover)
            .width('100%')
            .height(this.getHeaderHeight())
            .objectFit(ImageFit.Cover)
            .blur(50)

          // 渐变遮罩，确保文字清晰可见
          Column()
            .width('100%')
            .height('100%')
            .linearGradient({
              angle: 180,
              colors: [['rgba(0,0,0,0.3)', 0], ['rgba(0,0,0,0.7)', 1]]
            })

          Column() {
            Image(this.regionParams.regionCover)
              .width(this.getCoverSize())
              .height(this.getCoverSize())
              .borderRadius(12)
              .border({ width: 3, color: this.themeState.getCardBackgroundColor() })
              .margin({ top: 40 })

            Text(this.regionParams.regionName)
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .margin({ top: 16 })

            Text(this.regionParams.regionDescription)
              .fontSize(14)
              .fontColor(Color.White)
              .opacity(0.9)
              .margin({ top: 8, bottom: 20 })
              .padding({ left: 40, right: 40 })
              .textAlign(TextAlign.Center)
          }
          .alignItems(HorizontalAlign.Center)
          .width('100%')
          .height('100%')
        }
        .width('100%')
        .height(this.getHeaderHeight())

        // 歌曲列表区域
        Scroll() {
          Column() {
            Row() {
              Text(this.sectionTitle)
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.themeState.getPrimaryTextColor())
              Text(`${this.currentSongs.length}首`)
                .fontSize(14)
                .fontColor(this.themeState.getSecondaryTextColor())
                .margin({ left: 12 })
                .alignSelf(ItemAlign.End)
                .margin({ bottom: 2 })
            }
            .width('100%')
            .padding({ top: 10, left: 16, right: 16, bottom: 12 })
            .justifyContent(FlexAlign.Start)

            List() {
              ForEach(this.currentSongs, (song: SongItemType, index: number) => {
                ListItem() {
                  Row() {
                    // 排名
                    Text((index + 1).toString())
                      .fontSize(18)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(index < 3 ? '#FF6B6B' : this.themeState.getSecondaryTextColor())
                      .width(32)
                      .textAlign(TextAlign.Center)
                      .margin({ right: 12 })

                    // 歌曲信息
                    Row() {
                      Image(song.img)
                        .width(80)
                        .height(80)
                        .borderRadius(8)
                        .margin({ right: 12 })

                      Column() {
                        Text(song.name)
                          .fontSize(16)
                          .fontWeight(FontWeight.Medium)
                          .fontColor(this.themeState.getPrimaryTextColor())
                          .width('100%')
                          .margin({ bottom: 8 })
                        Text(song.author)
                          .fontSize(14)
                          .fontColor(this.themeState.getSecondaryTextColor())
                      }
                      .layoutWeight(1)
                      .alignItems(HorizontalAlign.Start)

                      // 播放按钮
                      Image($r('app.media.ic_play'))
                        .width(32)
                        .height(32)
                        .fillColor(this.themeState.getPrimaryTextColor())
                    }
                    .layoutWeight(1)
                  }
                  .width('100%')
                  .height(100)
                  .padding({ left: 16, right: 16 })
                  .backgroundColor(this.themeState.getBackgroundColor())
                  .onClick(() => {
                    this.pathStack.pushPathByName('Play', null, false)
                    playManager.singPlayFromList(song, this.currentSongs)
                  })
                }
              }, (song: SongItemType) => song.id)
            }
            .width('100%')
            .scrollBar(BarState.Off)
            .edgeEffect(EdgeEffect.Spring)
            .padding({ bottom: 20 })
          }
          .width('100%')
          .backgroundColor(this.themeState.getBackgroundColor())
        }
        .layoutWeight(1)
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeState.getBackgroundColor())
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .title(this.regionParams.regionName)
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack
    })
  }
}
