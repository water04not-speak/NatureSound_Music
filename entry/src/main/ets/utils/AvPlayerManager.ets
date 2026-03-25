import { media } from '@kit.MediaKit'
import { GlobalMusic } from '../models/globalMusic'
import { SongItemType } from '../models/music'
import { AppStorageV2 } from '@kit.ArkUI'
import { sessionManager } from './AvSessionManager'

class AvPlayManager{
//   属性+方法
//   播放器
  player:media.AVPlayer | null=null

//   共享播放数据
  currentSong:GlobalMusic=AppStorageV2.connect(GlobalMusic,'SONG_KEY',()=>{
    const music = new GlobalMusic()
    // 确保播放列表不为空
    if (music.playList.length === 0) {
      console.info('[AvPlayerManager] 初始化播放列表为空，创建默认播放列表')
    }
    return music
  })!

//   定义方法 创建播放器+监听播放器的状态
  async init(){
    if(!this.player){
      this.player=await media.createAVPlayer()
    }

    this.player.on('stateChange',(state)=>{
      console.info(`[AvPlayerManager] 播放器状态变化: ${state}`)
      if(state==='initialized'){
        this.player?.prepare()
      }else if (state==='prepared'){
        this.player?.play()
        this.currentSong.isPlay=true
      }else if(state==='completed'){
        this.nextPlay(true)//自动下一首
      }else if(state==='released'){
        this.currentSong.reset()
      }else if(state==='error'){
        // 处理播放错误
        console.error(`[AvPlayerManager] 播放器错误，当前URL: ${this.currentSong.url}`)
        this.currentSong.isPlay=false
        sessionManager.setAVPlayBackState()
      }
    })

    // 错误事件监听
    this.player.on('error',(error)=>{
      console.error(`[AvPlayerManager] 播放错误: code=${error.code}, message=${error.message}, url=${this.currentSong.url}`)
      this.currentSong.isPlay=false
      sessionManager.setAVPlayBackState()
    })

    // 时间变化
    this.player.on('durationUpdate',(duration)=>{
      this.currentSong.duration=duration
      sessionManager.setAVMetadata(this.currentSong.playList[this.currentSong.playIndex])
    })
    this.player.on('timeUpdate',(time)=>{
      this.currentSong.time=time
      sessionManager.setAVPlayBackState()
    })

  }
  // 播放歌曲——>设置播放资源
//   singPlay(song:SongItemType){
// this.player!.url=song.url
//     this.currentSong.img=song.img
//   }




  singPlay(song:SongItemType){
    console.info(`[AvPlayerManager] singPlay 被调用，歌曲: ${song.name}`)
    if(!this.player){
      console.error('[AvPlayerManager] 播放器未初始化，无法播放歌曲')
      return
    }
    console.info(`[AvPlayerManager] 播放器已初始化，准备播放歌曲`)
    const urlPreview = song.url.length > 100 ? `${song.url.substring(0, 100)}...` : song.url
    console.info(`[AvPlayerManager] 播放歌曲: ${song.name}, URL: ${urlPreview}`)
    //   申请长时任务
    sessionManager.startBackgroundTask()
    sessionManager.setAVPlayBackState()
    //   是否在列表——>some 检查数组里面是否满足条件——>只要有一个满足some 返回 true
    const inList=this.currentSong.playList.some(item=>item.id===song.id)
    console.info(`[AvPlayerManager] 歌曲是否在列表中: ${inList}`)
    if(inList){
      //   在列表里面——>是否是正在播放的——>currentSong url===song.url
      if(this.currentSong.url===song.url){
        console.info(`[AvPlayerManager] 播放同一首歌曲，直接播放`)
        this.player?.play()
        this.currentSong.isPlay=true
        console.info(`[AvPlayerManager] 播放状态已更新: ${this.currentSong.isPlay}`)
      }else {
        //   设置新的索引——>切歌
        console.info(`[AvPlayerManager] 切换到列表中的其他歌曲`)
        this.currentSong.playIndex=this.currentSong.playList.findIndex(item=>item.id===song.id)
        console.info(`[AvPlayerManager] 新的播放索引: ${this.currentSong.playIndex}`)
        //   切歌
        this.changeSong()
      }
    }else {
      //   不在列表里面——>添加到列表+切换歌曲
      console.info(`[AvPlayerManager] 歌曲不在列表中，添加到列表`)
      this.currentSong.playList.unshift(song)
      this.currentSong.playIndex=0
      console.info(`[AvPlayerManager] 新的播放索引: ${this.currentSong.playIndex}`)
      //   切换歌曲
      this.changeSong()
    }
  }

  /**
   * 从指定列表播放歌曲（用于歌单/非遗地域列表等）
   */
  singPlayFromList(song: SongItemType, playList: SongItemType[]): void {
    if (!this.player) {
      console.error('[AvPlayerManager] 播放器未初始化，无法播放歌曲')
      return
    }
    sessionManager.startBackgroundTask()
    sessionManager.setAVPlayBackState()
    const idx = playList.findIndex((item: SongItemType) => item.id === song.id)
    this.currentSong.playList = [...playList]
    this.currentSong.playIndex = idx >= 0 ? idx : 0
    this.changeSong()
  }


  // 切换歌曲——>重新播放器
  async changeSong(){
    if(!this.player){
      console.error('[AvPlayerManager] 播放器未初始化，无法切换歌曲')
      return
    }
    try {
      console.info('[AvPlayerManager] 开始切换歌曲...')
      await this.player.reset()//重置
      console.info('[AvPlayerManager] 播放器重置完成')
      this.currentSong.duration=0
      this.currentSong.time=0
      const song = this.currentSong.playList[this.currentSong.playIndex]
      this.currentSong.img=song.img
      this.currentSong.name=song.name
      this.currentSong.author=song.author
      this.currentSong.url=song.url
      
      // 记录 URL 信息用于调试
      const url = song.url
      const urlPreview = url.length > 100 ? `${url.substring(0, 100)}...` : url
      console.info(`[AvPlayerManager] 设置播放URL: ${urlPreview}, 歌曲: ${song.name}`)
      
      // 设置 URL
      this.player.url=url
      console.info('[AvPlayerManager] URL已设置，等待播放器初始化...')
      
      // 尝试手动调用 prepare（某些情况下可能需要）
      // 注意：AVPlayer 在设置 URL 后应该自动进入 idle 状态，然后需要调用 prepare
      // 但根据状态监听，应该会自动处理，这里先不手动调用
    } catch (error) {
      console.error(`[AvPlayerManager] 切换歌曲失败:`, error)
      this.currentSong.isPlay=false
      sessionManager.setAVPlayBackState()
    }
  }



  // 跳转进度 seek
  seekPlay(value:number){
    console.info(`[AvPlayerManager] seekPlay 被调用，跳转到: ${value}ms`)
    if(!this.player){
      console.error('[AvPlayerManager] 播放器未初始化，无法跳转进度')
      return
    }
    this.player?.seek(value)
    console.info('[AvPlayerManager] 跳转进度完成')
  }


// 暂停
paused(){
    console.info('[AvPlayerManager] paused 被调用')
    if(!this.player){
      console.error('[AvPlayerManager] 播放器未初始化，无法暂停')
      return
    }
    console.info('[AvPlayerManager] 执行暂停操作')
    this.player?.pause()
    this.currentSong.isPlay=false
    console.info(`[AvPlayerManager] 暂停状态已更新: ${this.currentSong.isPlay}`)
    sessionManager.setAVPlayBackState()
  }

// 上一首
prevPlay(){
  if (this.currentSong.playList.length === 0) {
    console.error('[AvPlayerManager] 播放列表为空，无法切换到上一首')
    return
  }
   if(this.currentSong.playMode==='random'){
   //   随机
     this.currentSong.playIndex=Math.floor(Math.random()*this.currentSong.playList.length)
   }else{
     this.currentSong.playIndex--
     if(this.currentSong.playIndex<0){
       //   去掉最后一首
       this.currentSong.playIndex=this.currentSong.playList.length-1
     }
   }
  this.singPlay(this.currentSong.playList[this.currentSong.playIndex])
}

// 下一首:根据播放模式计算索引 播放——> if
//   真的重复播放——>播放模式为repeat 并且 播放器自动下一首——>completed——>传入一个数据表示是自动的
//   随机——>计算随机索引
//   列表——>++
nextPlay(autoNextPlay?:boolean){
  if (this.currentSong.playList.length === 0) {
    console.error('[AvPlayerManager] 播放列表为空，无法切换到下一首')
    return
  }
  if(this.currentSong.playMode==='repeat' && autoNextPlay){
    //   真的重复——>索引不变
    this.currentSong.playIndex=this.currentSong.playIndex
  }else if(this.currentSong.playMode==='random'){
  //   随机
  //   Math.random()得到的是[0-1)之间的随机小数
    this.currentSong.playIndex=Math.floor(Math.random()*this.currentSong.playList.length)
  }else {
  //   列表
    this.currentSong.playIndex++
    if(this.currentSong.playIndex>this.currentSong.playList.length-1){
      //   去掉第一首歌
      this.currentSong.playIndex=0
    }
  }
  this.singPlay(this.currentSong.playList[this.currentSong.playIndex])
}


// 列表移除歌曲
  removeSong(index:number){
    if(index===this.currentSong.playIndex){
    //   删除的是正在播放的
      if(this.currentSong.playList.length>1){
      //   列表里面有多首歌
        this.currentSong.playList.splice(index,1)
      //   播放索引如果大于等于了长度，回第一首歌播放
        if(this.currentSong.playIndex>=this.currentSong.playList.length){
          this.currentSong.playIndex=0
        }
        this.singPlay(this.currentSong.playList[this.currentSong.playIndex])
      }else {
      //   列表里面只有一首歌
        this.player?.reset()
        this.currentSong.reset()
      }
    }else{
    //  删除的不是正在播放的歌曲
      if(index<this.currentSong.playIndex){
      //   要删除的在播放的前面
        this.currentSong.playIndex--
      }
    //   splice(index,1)移除——>删除的索引，删除的个数
      this.currentSong.playList.splice(index,1)
    }
  }

// 释放播放器 和 播放数据
  async release(){
    await this.player?.release()
  }


}


export const playManager:AvPlayManager=new AvPlayManager()


