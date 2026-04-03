import { AppStorageV2 } from '@kit.ArkUI'
import { getDefaultSongItems } from '../utils/MusicSeedData'
import { SongItemType } from '../models/music'
import { playManager } from '../utils/AvPlayerManager'

// 跳转页面入口函数
@Builder
export function PlaylistDetailBuilder() {
  PlaylistDetail()
}

// 定义坐标点接口
export interface Position {
  x: number;
  y: number;
}

// 定义歌单参数类
export class PlaylistParams {
  playlistId: string = '';
  playlistName: string = '歌单详情';
  playlistDesc: string = '';
  playlistCover: ResourceStr = $r('app.media.ic_cd');
  playlistCount: number = 0;
}

@ComponentV2
struct PlaylistDetail {
  pathStack: NavPathStack = new NavPathStack()
  // 使用AppStorageV2.connect获取歌单参数
  playlistParams: PlaylistParams = AppStorageV2.connect(PlaylistParams, 'playlistParams', () => new PlaylistParams())!

  // 弹窗状态管理
  @Local showMenu: boolean = false
  @Local selectedSongIndex: number = -1
  @Local menuPosition: Position = { x: 0, y: 0 }

  // 创建不同歌单对应的歌曲列表映射
  private playlistSongsMap: Record<string, SongItemType[]> = {
    'pl-1': getDefaultSongItems(),
    'default': getDefaultSongItems()
  }

  // 获取当前歌单对应的歌曲列表
  get currentSongs(): SongItemType[] {
    return this.playlistSongsMap[this.playlistParams.playlistId] || this.playlistSongsMap['default'];
  }

  build() {
    // 使用Stack作为根组件，确保只有一个根节点
    Stack() {
      NavDestination() {
        Column() {
          // 歌单头部信息
          Stack() {
            Image(this.playlistParams.playlistCover)
              .width('100%')
              .height(300)
              .objectFit(ImageFit.Cover)
              .blur(50)

            Column() {
              Image(this.playlistParams.playlistCover)
                .width(200)
                .height(200)
                .borderRadius(12)
                .margin({ top: 50 })

              Text(this.playlistParams.playlistName)
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
                .margin({ top: 16 })

              Text(this.playlistParams.playlistDesc)
                .fontSize(14)
                .fontColor(Color.White)
                .opacity(0.8)
                .margin({ top: 8 })

              Text(`${this.playlistParams.playlistCount}首歌曲`)
                .fontSize(12)
                .fontColor(Color.White)
                .opacity(0.6)
                .margin({ top: 4 })
            }
            .alignItems(HorizontalAlign.Center)
          }
          .width('100%')
          .height(300)

          // 歌曲列表
          Column() {
            Text('歌曲列表')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .margin({ top: 16, left: 16, right: 16, bottom: 8 })

            List() {
              ForEach(this.currentSongs, (song: SongItemType, index: number) => {
                ListItem() {
                  Row() {
                    // 可点击的歌曲信息区域
                    Row({ space: 12 }) {
                      Text((index + 1).toString())
                        .fontSize(16)
                        .fontColor('#999999')
                        .width(30)
                        .textAlign(TextAlign.Center)

                      Image(song.img)
                        .width(44)
                        .height(44)
                        .borderRadius(4)

                      Column({ space: 4 }) {
                        Text(song.name)
                          .fontSize(16)
                          .fontWeight(FontWeight.Medium)
                          .fontColor('#333333')
                          .maxLines(1)
                          .textOverflow({ overflow: TextOverflow.Ellipsis })

                        Text(song.author)
                          .fontSize(14)
                          .fontColor('#999999')
                          .maxLines(1)
                          .textOverflow({ overflow: TextOverflow.Ellipsis })
                      }
                      .layoutWeight(1)
                      .alignItems(HorizontalAlign.Start)
                    }
                    .layoutWeight(1)
                    .onClick(() => {
                      // 跳转到播放页面
                      this.pathStack.pushPathByName('Play', null, false);
                      // 播放歌曲
                      playManager.singPlay(song);
                    })

                    // 独立的更多按钮，不触发歌曲点击事件
                    Image($r('app.media.ic_more'))
                      .width(24)
                      .height(24)
                      .fillColor('#999999')
                      .padding(12)
                      .onClick(() => {
                        // 记录选中的歌曲索引
                        this.selectedSongIndex = index;
                        // 显示弹窗（使用固定位置）
                        this.showMenu = true;
                      })
                  }
                  .width('100%')
                  .padding({ left: 16, right: 16, top: 12, bottom: 12 })
                }
                .margin({ left: 8, right: 8, top: 4, bottom: 4 })
              }, (song: SongItemType) => song.id)
            }
            .width('100%')
            .layoutWeight(1)
          }
          .width('100%')
        }
        .width('100%')
        .height('100%')
        .backgroundColor(Color.White)
      }
      .title(this.playlistParams.playlistName)
      .onReady((context: NavDestinationContext) => {
        this.pathStack = context.pathStack
      })

      // 歌曲操作弹窗
      if (this.showMenu) {
        Stack() {
          // 半透明遮罩，点击关闭弹窗
          Column() {}
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0,0,0,0.1)')
          .onClick(() => {
            this.showMenu = false
          })

          .padding({ left: 12, right: 12, top: 12, bottom: 12 })
          .backgroundColor('#2C2C2E')
          .borderRadius(12)
          .shadow({ radius: 8, color: 'rgba(0,0,0,0.35)', offsetX: 0, offsetY: 4 })
          // 使用固定位置，显示在屏幕右侧中间
          .position({ x: '80%', y: '50%' })
        }
      }
    }
    .width('100%')
    .height('100%')
  }
}