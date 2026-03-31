const fs = require('fs');
const content = fs.readFileSync('entry/src/main/ets/pages/Play.ets', 'utf-8');

const regex = /  @Builder\r?\n  PlaylistBuilder\(\) \{[\s\S]*?(?=\r?\n  build\(\) \{)/;
const newBuilder =   @Builder
  PlaylistBuilder() {
    Column() {
      // 头部选项卡
      Scroll() {
        Row() {
          Row({ space: 4 }) {
            Text("正在播放")
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeState.getPrimaryTextColor())
              .border({ width: { bottom: 2 }, color: this.themeState.getPrimaryTextColor() })
              .padding({ bottom: 4 })
              
            Image(update_play.pyr('app.media.ic_link')) 
              .width(14).height(14)
              .fillColor(this.themeState.getSecondaryTextColor())
              .visibility(Visibility.None) 
              
            Text(this.playState.playList.length.toString())
              .fontSize(12)
              .fontColor(this.themeState.getSecondaryTextColor())
          }
          .margin({ right: 24 })
          
          Text("已播歌曲 999+")
            .fontSize(14)
            .fontColor(this.themeState.getSecondaryTextColor())
            .margin({ right: 24 })
            
          Text("已播歌单 5")
            .fontSize(14)
            .fontColor(this.themeState.getSecondaryTextColor())
        }
        .width('100%')
        .padding({ top: 20, left: 20, right: 20, bottom: 10 })
        .backgroundColor(this.themeState.getCardBackgroundColor())
        .borderRadius({ topLeft: 24, topRight: 24 })
      }.scrollable(ScrollDirection.Horizontal).scrollBar(BarState.Off)

      // 控制栏设置
      Row() {
        Row({ space: 8 }) {
          Image(update_play.pyr('app.media.ic_repeat'))
            .width(20)
            .height(20)
            .fillColor(this.themeState.getSecondaryTextColor())
          Text("顺序播放")
            .fontSize(14)
            .fontColor(this.themeState.getSecondaryTextColor())
        }
        
        Blank()
        
        Row({ space: 16 }) {
          Image(update_play.pyr('app.media.ic_download_o'))
            .width(20)
            .height(20)
            .fillColor(this.themeState.getSecondaryTextColor())
          Image(update_play.pyr('app.media.ic_collect'))
            .width(20)
            .height(20)
            .fillColor(this.themeState.getSecondaryTextColor())
          Image(update_play.pyr('app.media.ic_close')) 
            .width(20)
            .height(20)
            .fillColor(this.themeState.getSecondaryTextColor())
            .onClick(() => {
              this.isShowPlaylist = false
            })
        }
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 10, bottom: 10 })
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
                  Image(update_play.pyr('app.media.wave'))
                    .width(16)
                    .height(16)
                    .fillColor('#1ECE6A')
                }
                Image(update_play.pyr('app.media.ic_close'))
                  .width(16)
                  .height(16)
                  .fillColor(this.themeState.getSecondaryTextColor())
                  .onClick(() => {
                    playManager.removeSong(index)
                    if(this.playState.playList.length===0){
                      this.pathStack.pop()
                    }
                  })
                Image(update_play.pyr('app.media.ic_list'))
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
        })
      }
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeState.getCardBackgroundColor())
  };

const newContent = content.replace(regex, newBuilder);
fs.writeFileSync('entry/src/main/ets/pages/Play.ets', newContent, 'utf-8');
console.log('Update complete');