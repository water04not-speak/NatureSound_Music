import { avSession } from '@kit.AVSessionKit'
import { Context, wantAgent } from '@kit.AbilityKit'
import backgroundTaskManager from '@ohos.resourceschedule.backgroundTaskManager'
import { SongItemType } from '../models/music'
import { GlobalMusic } from '../models/globalMusic'
import { currentSong as sharedCurrentSong } from './PlaybackState'
import { playerBridge } from './AvPlayerBridge'

class AvSessionManager{
  session:avSession.AVSession | null =null
  playState:GlobalMusic=sharedCurrentSong//不为空时等号赋值

  async init(content:Context){
     this.session =await avSession.createAVSession(content,'bgPlay','audio')
    this.registerEvent()
  }


//   申请长时任务
  async startBackgroundTask(){
    let wantAgentInfo: wantAgent.WantAgentInfo = {
      // 点击通知后，将要执行的动作列表
      // 添加需要被拉起应用的bundleName和abilityName
      wants: [
        {
          // 改包名
          bundleName: "com.example.hm_music",
          abilityName: "EntryAbility"
        }
      ],
      // 指定点击通知栏消息后的动作是拉起ability
      actionType: wantAgent.OperationType.START_ABILITY,
      // 使用者自定义的一个私有值
      requestCode: 0,
      // 点击通知后，动作执行属性
      actionFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG],
      // 车钥匙长时任务子类型，从API version 16开始支持。只有申请bluetoothInteraction类型的长时任务，车钥匙子类型才能生效。
      // 确保extraInfo参数中的Key值为backgroundTaskManager.BackgroundModeType.SUB_MODE，否则子类型不生效。
      // extraInfo: { [backgroundTaskManager.BackgroundModeType.SUB_MODE] : backgroundTaskManager.BackgroundSubMode.CAR_KEY }
    };
    const want=await wantAgent.getWantAgent(wantAgentInfo)
    await backgroundTaskManager.startBackgroundRunning(getContext(),backgroundTaskManager.BackgroundMode.AUDIO_PLAYBACK,want)
  }

//   设置元数据
  setAVMetadata(song:SongItemType){
    this.session?.setAVMetadata({
      assetId:song.id,
      title:song.name,
      mediaImage:song.img,
      artist:song.author,
      duration:this.playState.duration

    })
  }



//   设置播放状态
  setAVPlayBackState(){
    this.session?.setAVPlaybackState({
      state:this.playState.isPlay?avSession.PlaybackState.PLAYBACK_STATE_PLAY:avSession.PlaybackState.PLAYBACK_STATE_PAUSE,
      speed:1,
      position:{
        elapsedTime:this.playState.time,   //歌曲播放的时间
        updateTime:new Date().getTime()  //系统时间
      },
      duration:this.playState.duration
    })
  }

// 注册事件
  registerEvent(){
    this.session?.on('play',()=>{
      playerBridge.singPlay(this.playState.playList[this.playState.playIndex])
    })
    this.session?.on('pause',()=>{
      playerBridge.paused()
    })
    this.session?.on('playPrevious',()=>{
      playerBridge.prevPlay()
    })
    this.session?.on('playNext',()=>{
      playerBridge.nextPlay()
    })
    this.session?.on('seek',(value:number)=>{
      playerBridge.seekPlay(value)
    })
    // 激活
    this.session?.activate()
  }

//注销会话
  async destroy(){
    await this.session?.destroy()
  }

}


export const sessionManager:AvSessionManager=new AvSessionManager()


