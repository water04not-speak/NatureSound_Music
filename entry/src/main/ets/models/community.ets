// 社区数据持久化模型
// 用于保存动态的点赞状态、评论等数据，确保应用重启后数据不丢失
import dataPreferences from '@ohos.data.preferences'
import common from '@ohos.app.ability.common'
import { MomentListType } from '../pages/Community'

@ObservedV2
export class CommunityState {
  // 存储所有动态的完整数据（包括点赞状态、评论等）
  @Trace private momentsData: Map<string, MomentListType> = new Map()
  
  private prefs?: dataPreferences.Preferences
  private initialized: boolean = false
  
  private static readonly PREF_NAME: string = 'hm_music_community_prefs'
  private static readonly KEY_MOMENTS_DATA: string = 'momentsData'
  
  /**
   * 初始化社区状态
   * 从持久化存储中加载之前保存的数据
   */
  async initFromContext(ctx: common.UIAbilityContext): Promise<void> {
    if (this.initialized) {
      return
    }
    try {
      this.prefs = await dataPreferences.getPreferences(ctx, CommunityState.PREF_NAME)
      await this.loadFromStorage()
      this.initialized = true
    } catch (err) {
      console.error('[CommunityState] Failed to initialize:', err)
    }
  }
  
  /**
   * 从持久化存储中加载数据
   */
  private async loadFromStorage(): Promise<void> {
    if (!this.prefs) {
      return
    }
    try {
      const dataStr: string = (await this.prefs.get(CommunityState.KEY_MOMENTS_DATA, '{}')) as string
      const data = JSON.parse(dataStr) as Record<string, ESObject>
      
      // 将 JSON 数据转换为 Map
      this.momentsData = new Map()
      const keys = Object.keys(data)
      for (let i = 0; i < keys.length; i++) {
        const key: string = keys[i]
        const value: ESObject | undefined = data[key]
        // 只保存关键的状态数据（点赞、评论等），不保存完整的动态数据
        // 因为完整的动态数据（如内容、作者等）是固定的，不需要持久化
        if (value && typeof value === 'object') {
          this.momentsData.set(key, value as MomentListType)
        }
      }
    } catch (err) {
      console.error('[CommunityState] Failed to load from storage:', err)
      this.momentsData = new Map()
    }
  }
  
  /**
   * 保存数据到持久化存储
   */
  private async saveToStorage(): Promise<void> {
    if (!this.prefs) {
      return
    }
    try {
      // 将 Map 转换为 JSON 对象
      const data: Record<string, ESObject> = {}
      const entries: Array<[string, MomentListType]> = Array.from(this.momentsData.entries())
      for (let i = 0; i < entries.length; i++) {
        const entry: [string, MomentListType] = entries[i]
        data[entry[0]] = entry[1] as ESObject
      }
      
      const dataStr = JSON.stringify(data)
      await this.prefs.put(CommunityState.KEY_MOMENTS_DATA, dataStr)
      await this.prefs.flush()
    } catch (err) {
      console.error('[CommunityState] Failed to save to storage:', err)
    }
  }
  
  /**
   * 获取动态的状态数据（点赞、评论等）
   */
  getMomentState(momentId: string): Partial<MomentListType> | undefined {
    return this.momentsData.get(momentId)
  }
  
  /**
   * 更新动态的状态数据
   */
  async updateMomentState(momentId: string, updates: Partial<MomentListType>): Promise<void> {
    const existing = this.momentsData.get(momentId)
    if (existing) {
      // 手动合并更新（避免使用 Object.assign）
      if (updates.like !== undefined) {
        existing.like = updates.like
      }
      if (updates.liked !== undefined) {
        existing.liked = updates.liked
      }
      if (updates.comment !== undefined) {
        existing.comment = updates.comment
      }
      if (updates.comments !== undefined) {
        existing.comments = updates.comments
      }
    } else {
      // 创建新条目
      this.momentsData.set(momentId, updates as MomentListType)
    }
    // 异步保存，不阻塞UI
    void this.saveToStorage()
  }
  
  /**
   * 批量更新动态状态（用于初始化时恢复数据）
   */
  async batchUpdateMoments(moments: MomentListType[]): Promise<void> {
    for (let i = 0; i < moments.length; i++) {
      const moment = moments[i]
      // 只保存状态数据，不保存完整数据
      const stateData: Partial<MomentListType> = {
        id: moment.id,
        like: moment.like,
        liked: moment.liked,
        comment: moment.comment,
        comments: moment.comments
      }
      this.momentsData.set(moment.id, stateData as MomentListType)
    }
    void this.saveToStorage()
  }
  
  /**
   * 应用保存的状态到动态列表
   */
  applySavedStates(moments: MomentListType[]): MomentListType[] {
    const result: MomentListType[] = []
    for (let i = 0; i < moments.length; i++) {
      const moment = moments[i]
      const savedState = this.momentsData.get(moment.id)
      if (savedState) {
        // 手动合并保存的状态（避免使用展开运算符）
        const updatedMoment: MomentListType = {
          id: moment.id,
          author: moment.author,
          avatar: moment.avatar,
          content: moment.content,
          comment: savedState.comment ?? moment.comment,
          like: savedState.like ?? moment.like,
          liked: savedState.liked ?? moment.liked,
          createdAt: moment.createdAt,
          song: moment.song,
          comments: savedState.comments ?? moment.comments
        }
        result.push(updatedMoment)
      } else {
        result.push(moment)
      }
    }
    return result
  }
  
  /**
   * 清除所有保存的数据
   */
  async clearAll(): Promise<void> {
    this.momentsData.clear()
    await this.saveToStorage()
  }
}

