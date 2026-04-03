import { SongItemType, LyricLine } from "./music"

@ObservedV2  //深度监听类属性的变化
/**
 * 【通俗解释】：这是整个APP的"音乐大脑"，里面存放着当前正在播放的唯一一首歌的全部信息。
 * 不管你在哪个界面（比如首页、音乐详情页），只要显示歌名、封面、进度、或者播放列表，
 * 全都从这个"大脑"里拿数据。一旦这里改变了，所有关联界面的显示都会瞬间自动刷新（依靠@ObservedV2和@Trace魔法）。
 */
export class GlobalMusic {
  @Trace img: string = ""  // 音乐封面
  @Trace name: string = ""  // 音乐名称
  @Trace author: string = ""  // 作者
  @Trace url: string = ""
  @Trace id: string = ""
  @Trace lyric?: string
  @Trace isFavorite?: boolean
  @Trace lyrics?: string[]
  @Trace lyricLines?: LyricLine[]  // 当前播放链接
  @Trace time: number = 0  // 播放时间
  @Trace duration: number = 0  // 歌曲总时长


//   歌曲列表
  @Trace playIndex:number=0//当前播放的索引
  @Trace playList:SongItemType[]=[]//播放列表


// 播放和暂停
  @Trace isPlay:boolean=false  //播放的状态

  // 播放模式
@Trace playMode:'auto' | 'random' | 'repeat'='auto'

//   重置数据
  reset(){
    this.img=''
    this.name=''
    this.author=''
    this.url=''
    this.time=0
    this.duration=0
    this.playIndex=0
    this.playList=[]
    this.isPlay=false
    this.playMode='auto'
  }

}