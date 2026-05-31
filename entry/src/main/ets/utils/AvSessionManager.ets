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
  private context: Context | null = null
  private isBackgroundTaskStarted: boolean = false
  private initPromise?: Promise<void>
  private eventsRegistered: boolean = false
  private lastMetadataKey: string = ''
  private lastPlaybackStateAt: number = 0

  async init(content:Context){
    if (this.session) {
      this.context = content
      return
    }
    if (this.initPromise) {
      return this.initPromise
    }
    this.context = content
    const startAt = Date.now()
    this.initPromise = (async () => {
      this.session = await avSession.createAVSession(content,'bgPlay','audio')
      console.info(`[PERF][AVSession] init cost=${Date.now() - startAt}ms`)
      this.registerEvent()
    })().finally(() => {
      this.initPromise = undefined
    })
    return this.initPromise
  }


//   申请长时任务
  async startBackgroundTask(){
    if (this.isBackgroundTaskStarted) {
      return
    }
    if (!this.context) {
      return
    }
    let wantAgentInfo: wantAgent.WantAgentInfo = {
      // 点击通知后，将要执行的动作列表
      // 添加需要被拉起应用的bundleName和abilityName
      wants: [
        {
          bundleName: "com.xxfn.NatureSound_Music",
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
    await backgroundTaskManager.startBackgroundRunning(this.context,backgroundTaskManager.BackgroundMode.AUDIO_PLAYBACK,want)
    this.isBackgroundTaskStarted = true
  }

  async stopBackgroundTask(){
    if (!this.isBackgroundTaskStarted || !this.context) {
      return
    }
    try {
      await backgroundTaskManager.stopBackgroundRunning(this.context)
    } catch (_error) {
      // stopBackgroundRunning 可能在任务已失效时抛错，这里忽略并继续释放会话
    } finally {
      this.isBackgroundTaskStarted = false
    }
  }

//   设置元数据
  setAVMetadata(song:SongItemType){
    const session = this.session
    if (!session) {
      return
    }
    const metadataKey = `${song.id}|${this.playState.duration}`
    if (metadataKey === this.lastMetadataKey) {
      return
    }
    this.lastMetadataKey = metadataKey
    const startAt = Date.now()
    void session.setAVMetadata({
      assetId:song.id,
      title:song.name,
      mediaImage:song.img,
      artist:song.author,
      duration:this.playState.duration

    }).then(() => {
      console.info(`[PERF][AVSession] setMetadata cost=${Date.now() - startAt}ms`)
    }).catch((error: Error) => {
      console.error('[AvSessionManager] setAVMetadata failed:', JSON.stringify(error))
    })
  }



//   设置播放状态
  setAVPlayBackState(force: boolean = false){
    const session = this.session
    if (!session) {
      return
    }
    const now = Date.now()
    if (!force && now - this.lastPlaybackStateAt < 800) {
      return
    }
    this.lastPlaybackStateAt = now
    const startAt = Date.now()
    void session.setAVPlaybackState({
      state:this.playState.isPlay?avSession.PlaybackState.PLAYBACK_STATE_PLAY:avSession.PlaybackState.PLAYBACK_STATE_PAUSE,
      speed:1,
      position:{
        elapsedTime:this.playState.time,   //歌曲播放的时间
        updateTime:new Date().getTime()  //系统时间
      },
      duration:this.playState.duration
    }).then(() => {
      console.info(`[PERF][AVSession] setPlaybackState cost=${Date.now() - startAt}ms`)
    }).catch((error: Error) => {
      console.error('[AvSessionManager] setAVPlaybackState failed:', JSON.stringify(error))
    })
  }

// 注册事件
  registerEvent(){
    if (this.eventsRegistered) {
      return
    }
    this.eventsRegistered = true
    this.session?.on('play',()=>{
      const current = this.playState.playList[this.playState.playIndex]
      if (current) {
        playerBridge.singPlay(current)
      }
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
    await this.stopBackgroundTask()
    await this.session?.destroy()
    this.session = null
    this.eventsRegistered = false
    this.lastMetadataKey = ''
    this.lastPlaybackStateAt = 0
  }

}


export const sessionManager:AvSessionManager=new AvSessionManager()


