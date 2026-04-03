// 顶部先定义 interface
import { AppStorageV2 } from '@kit.ArkUI'
import { ThemeState } from '../models/theme'
import { UserState } from '../models/user'
import { CommunityState } from '../models/community'
import common from '@ohos.app.ability.common'
import { getDefaultSongItems } from '../utils/MusicSeedData'

/**
 * 歌曲项类型
 */
export interface SongItemType {
  img: string
  name: string
  author: string
  url: string
  id: string
}

/**
 * 评论项类型
 */
export interface CommentItemType {
  id: string
  author: string
  avatar: string | Resource
  content: string
  createdAt: number
  like: number
  liked: boolean
}

/**
 * 动态列表项类型
 */
export interface MomentListType {
  id: string
  author: string
  avatar: string | Resource
  content: string
  comment: number
  like: number
  liked: boolean
  createdAt: number
  song: SongItemType
  comments: CommentItemType[]
}

/**
 * 排序模式类型
 */
type SortMode = 'latest' | 'hot'

/**
 * 边框配置接口
 */
interface BorderConfig {
  width: number
  color: string | ResourceColor
}

// ---------------------论坛页面--------------------------
/**
 * 跳转页面入口函数
 */
@Builder
export function MomentBuilder(): void {
  Moment()
}

/**
 * 论坛/社区页面组件
 */
@ComponentV2
export struct Moment {
  // 主题状态管理实例，用于管理背景颜色
  themeState: ThemeState = AppStorageV2.connect(ThemeState, 'THEME_STATE', () => new ThemeState())!
  // 用户状态（用于评论昵称）
  userState: UserState = AppStorageV2.connect(UserState, 'USER_STATE', () => new UserState())!
  // 社区数据持久化状态
  communityState: CommunityState = AppStorageV2.connect(CommunityState, 'COMMUNITY_STATE', () => new CommunityState())!
  
  // 歌曲数据列表
  private readonly songs: SongItemType[] = getDefaultSongItems()
  @Local private momentList: MomentListType[] = []
  // 全量数据源
  private allMoments: MomentListType[] = []
  private pageIndex: number = 0
  private readonly pageSize: number = 5
  @Local private hasMore: boolean = true

  // 评论面板状态
  @Local private isCommentPanelVisible: boolean = false
  @Local private activeMomentId: string = ''
  @Local private commentSortMode: SortMode = 'latest'
  @Local private newCommentText: string = ''
  // 动态排序（主页面）
  @Local private momentSortMode: SortMode = 'latest'
  // 点赞动画状态
  @Local private likeAnimationStates: Map<string, boolean> = new Map()  // 帖子点赞动画
  @Local private commentLikeAnimationStates: Map<string, boolean> = new Map()  // 评论点赞动画
  
  // 加载和错误状态
  @Local private isLoading: boolean = false
  @Local private errorMessage: string = ''
  @Local private isRefreshing: boolean = false

  private static readonly LIKE_ACTIVE_COLOR: string = '#2F80FF' // 点赞后的蓝色
  private static readonly LIKE_INACTIVE_LIGHT: string = '#B0B0B0'
  private static readonly LIKE_INACTIVE_DARK: string = '#8A8A8A'

  private getLikeInactiveColor(): string {
    return this.themeState.isDarkTheme() ? Moment.LIKE_INACTIVE_DARK : Moment.LIKE_INACTIVE_LIGHT
  }

  private createSeedComments(seed: number): CommentItemType[] {
    const now = Date.now()
    const avatars: (string | Resource)[] = [
      $r('app.media.moment_01'),
      $r('app.media.moment_03'),
      $r('app.media.moment_05'),
      $r('app.media.moment_09')
    ]
    const names: string[] = ['我', '空城忆夢', 'AAA市场批发零售王姐', '淘宝客服', '我草莓招了', '深藏blue']
    const texts: string[] = [
      '豪庭',
      '如听仙乐耳暂明',
      '歌好听到要用DeepSeek写发疯文案',
      '死了都要听着这首歌下葬',
      '这首歌只有没听过和无数遍'
    ]
    const pick = <T>(arr: T[], i: number): T => arr[i % arr.length]
    const make = (idx: number): CommentItemType => {
      const createdAt = now - (seed * 3 + idx) * 60 * 60 * 1000 - idx * 7 * 60 * 1000
      return {
        id: `${seed}-${idx}-${createdAt}`,
        author: pick(names, seed + idx),
        avatar: pick(avatars, seed + idx),
        content: pick(texts, seed + idx),
        createdAt,
        like: (seed * 5 + idx * 3) % 58,
        liked: false
      }
    }
    return [make(0), make(1), make(2)]
  }

  private createMoment(author: string, avatar: string | Resource, content: string, like: number, song: SongItemType, seed: number): MomentListType {
    const comments = this.createSeedComments(seed)
    return {
      id: song.id,
      author,
      avatar,
      content,
      comment: comments.length,
      like,
      liked: false,
      createdAt: Date.now() - seed * 2 * 60 * 60 * 1000,
      song,
      comments
    }
  }

  private cloneMoment(m: MomentListType): MomentListType {
    return {
      id: m.id,
      author: m.author,
      avatar: m.avatar,
      content: m.content,
      comment: m.comment,
      like: m.like,
      liked: m.liked,
      createdAt: m.createdAt,
      song: m.song,
      comments: m.comments
    }
  }

  private cloneComment(c: CommentItemType): CommentItemType {
    return {
      id: c.id,
      author: c.author,
      avatar: c.avatar,
      content: c.content,
      createdAt: c.createdAt,
      like: c.like,
      liked: c.liked
    }
  }

  private updateMomentById(id: string, updater: (m: MomentListType) => MomentListType): void {
    // 创建新数组以确保触发响应式更新
    const updatedAllMoments = this.allMoments.map((m: MomentListType) => (m.id === id ? updater(m) : m))
    const updatedMomentList = this.momentList.map((m: MomentListType) => (m.id === id ? updater(m) : m))
    
    // 获取更新后的动态数据
    const updatedMoment = updatedAllMoments.find((m: MomentListType) => m.id === id)
    
    // 更新全量数据
    this.allMoments = updatedAllMoments
    // 更新显示列表 - 创建新数组引用以触发UI更新
    this.momentList = [...updatedMomentList]
    
    // 保存到持久化存储
    if (updatedMoment) {
      void this.communityState.updateMomentState(id, {
        id: updatedMoment.id,
        like: updatedMoment.like,
        liked: updatedMoment.liked,
        comment: updatedMoment.comment,
        comments: updatedMoment.comments
      })
    }
    
    // 如果当前是"最热"排序，点赞/取消点赞后需要刷新展示顺序
    if (this.momentSortMode === 'hot') {
      this.refreshDisplayedMoments()
    }
  }

  private toggleMomentLike(id: string): void {
    try {
      console.info('[Moment] toggleMomentLike:', id)
      // 触发动画
      this.likeAnimationStates.set(id, true)
      setTimeout(() => {
        this.likeAnimationStates.set(id, false)
      }, 300)
      
      this.updateMomentById(id, (m: MomentListType) => {
        const liked = !m.liked
        const nextLike = Math.max(0, m.like + (liked ? 1 : -1))
        const next = this.cloneMoment(m)
        next.liked = liked
        next.like = nextLike
        return next
      })
    } catch (error) {
      console.error('[Moment] Failed to toggle like:', error)
      this.errorMessage = '操作失败，请稍后重试'
    }
  }

  private openComments(id: string): void {
    this.activeMomentId = id
    this.commentSortMode = 'latest'
    this.newCommentText = ''
    this.isCommentPanelVisible = true
  }

  private closeComments(): void {
    this.isCommentPanelVisible = false
  }

  private formatRelativeTime(ts: number): string {
    const diff = Math.max(0, Date.now() - ts)
    const minute = 60 * 1000
    const hour = 60 * minute
    const day = 24 * hour
    const month = 30 * day
    if (diff < minute) return '刚刚'
    if (diff < hour) return `${Math.floor(diff / minute)}分钟前`
    if (diff < day) return `${Math.floor(diff / hour)}小时前`
    if (diff < month) return `${Math.floor(diff / day)}天前`
    return `${Math.floor(diff / month)}个月前`
  }

  private getActiveMoment(): MomentListType | undefined {
    if (!this.activeMomentId) {
      return undefined
    }
    return this.allMoments.find((m: MomentListType) => m.id === this.activeMomentId)
  }

  private getSortedComments(m: MomentListType): CommentItemType[] {
    const list = (m.comments ?? []).slice()
    if (this.commentSortMode === 'hot') {
      return list.sort((a: CommentItemType, b: CommentItemType) => {
        if (b.like !== a.like) return b.like - a.like
        return b.createdAt - a.createdAt
      })
    }
    return list.sort((a: CommentItemType, b: CommentItemType) => b.createdAt - a.createdAt)
  }

  private toggleCommentLike(momentId: string, commentId: string): void {
    try {
      console.info('[Moment] toggleCommentLike:', momentId, commentId)
      // 触发动画
      const animationKey = `${momentId}-${commentId}`
      this.commentLikeAnimationStates.set(animationKey, true)
      setTimeout(() => {
        this.commentLikeAnimationStates.set(animationKey, false)
      }, 300)
      
      // 直接更新状态以确保UI刷新
      this.updateMomentById(momentId, (m: MomentListType) => {
        const nextComments = (m.comments ?? []).map((c: CommentItemType) => {
          if (c.id !== commentId) return c
          const liked = !c.liked
          const nextLike = Math.max(0, c.like + (liked ? 1 : -1))
          const nextC = this.cloneComment(c)
          nextC.liked = liked
          nextC.like = nextLike
          return nextC
        })
        const nextM = this.cloneMoment(m)
        nextM.comments = [...nextComments]  // 创建新数组引用
        return nextM
      })
    } catch (error) {
      console.error('[Moment] Failed to toggle comment like:', error)
      this.errorMessage = '操作失败，请稍后重试'
    }
  }

  private addComment(): void {
    const content = (this.newCommentText ?? '').trim()
    if (!content || !this.activeMomentId) {
      return
    }

    try {
      const username = (this.userState.isLoggedIn && this.userState.username) ? this.userState.username : '游客'
      const now = Date.now()
      const newComment: CommentItemType = {
        id: `u-${now}`,
        author: username,
        avatar: 'http://yjy-teach-oss.oss-cn-beijing.aliyuncs.com/HeimaCloudMusic/h1.jpg',
        content,
        createdAt: now,
        like: 0,
        liked: false
      }

      const momentId = this.activeMomentId
      this.updateMomentById(momentId, (m: MomentListType) => {
        const existing: CommentItemType[] = (m.comments ?? [])
        const nextComments: CommentItemType[] = [newComment].concat(existing)
        const nextM = this.cloneMoment(m)
        nextM.comments = nextComments
        nextM.comment = (m.comment ?? 0) + 1
        return nextM
      })
      this.newCommentText = ''
    } catch (error) {
      console.error('[Moment] Failed to add comment:', error)
      this.errorMessage = '评论发布失败，请稍后重试'
    }
  }

  private getSortedAllMoments(): MomentListType[] {
    const list = this.allMoments.slice()
    if (this.momentSortMode === 'hot') {
      return list.sort((a: MomentListType, b: MomentListType) => {
        if (b.like !== a.like) return b.like - a.like
        return b.createdAt - a.createdAt
      })
    }
    return list.sort((a: MomentListType, b: MomentListType) => b.createdAt - a.createdAt)
  }

  private refreshDisplayedMoments(): void {
    const displayedCount = this.momentList.length
    const sorted = this.getSortedAllMoments()
    this.momentList = sorted.slice(0, displayedCount)
    this.hasMore = displayedCount < sorted.length
  }

  private resetAndLoad(): void {
    this.pageIndex = 0
    this.momentList = []
    this.hasMore = true
    this.loadMore()
  }

  private setMomentSortMode(mode: SortMode): void {
    if (this.momentSortMode === mode) {
      return
    }
    this.momentSortMode = mode
    this.resetAndLoad()
  }

  private hasActiveMoment(): boolean {
    return this.getActiveMoment() !== undefined
  }

  private getActiveSortedComments(): CommentItemType[] {
    const m = this.getActiveMoment()
    if (!m) {
      return []
    }
    return this.getSortedComments(m)
  }

  aboutToAppear() {
    // 初始化社区状态（数据持久化）
    const abilityCtx = getContext(this) as common.UIAbilityContext
    void this.communityState.initFromContext(abilityCtx).then(() => {
      // 初始化完成后，应用保存的状态数据
      this.loadInitialData()
    }).catch((error: Error) => {
      console.error('[Moment] Failed to initialize community state:', error)
      // 即使初始化失败，也加载数据
      this.loadInitialData()
    })
  }

  private loadInitialData(): void {
    // 使用 this.songs 组装全量数据
    this.allMoments = [
      this.createMoment('空城忆夢', $r("app.media.moment_01"), '所幸南风知我意，吹梦渡我到西洲。', 23382, this.songs[0], 0),
      this.createMoment('AAA市场批发零售王姐', $r("app.media.moment_02"), '当你压力大快要崩溃时，别和别人去讲，也别觉得自己委屈，在夜深人静的时候，把心掏出来，缝缝补补，然后睡一觉，醒来又信心百倍。', 5482, this.songs[1], 1),
      this.createMoment('淘宝客服', $r("app.media.moment_03"), '我爱你 心就特别软 平淡也温暖 无语也浪漫。', 4234, this.songs[2], 2),
      this.createMoment('我草莓招了', $r("app.media.moment_04"), '炽烈的爱和稳定的情绪无法共存,此为两难。', 11545, this.songs[3], 3),
      this.createMoment('深藏blue', $r("app.media.moment_05"), '以前觉得沟通很重要 后来发现共鸣才是绝杀 因为如果对方听不懂 你说的一切都是废话。', 2234, this.songs[4], 4),
      this.createMoment('-骑老奶奶过马路-', $r("app.media.moment_06"), '回声 你在的地方太黑了 我带着灯笼来找你了。', 36297, this.songs[5], 5),
      this.createMoment('Saber', $r("app.media.moment_07"), '其实，这世界本没有什么同性恋、异性恋、双性恋、姐弟恋、师生恋、神马恋等等。只是一个人爱上了另一个人，就这么简单。', 5482, this.songs[6], 6),
      this.createMoment('185清纯男高', $r("app.media.moment_08"), '希望我们冰释前嫌 再也不相见。', 36448, this.songs[7], 7),
      this.createMoment('我水饺了', $r("app.media.moment_09"), '“你凭什么用你那烂大街的爱情来写我们在外漂泊156年的紫荆花”', 5482, this.songs[8], 8),
      this.createMoment('我是彭鱼晏', $r("app.media.moment_10"), '世界不让狗狗说话 是因为爱和忠诚要用行动表达。', 11482, this.songs[9], 9),
      this.createMoment('斯卡哈の枪焰', $r("app.media.moment_11"), '我本以为柚子的锉刀就够惨了，没想到还有转笔刀。', 8526, this.songs[10], 10),
      this.createMoment('WiFi信号暗杀者', $r("app.media.moment_12"), '很好听很有感染力的歌 我旁边跟我一起来的朋友瞬间就哭着跑出去了。', 5482, this.songs[11], 11),
      this.createMoment('⁺ʚ王者重度依赖ɞ₊', $r("app.media.moment_13"), '昨晚好像又梦到了你 在烛火中 雾气湿漉漉的 氤氲好看。', 5482, this.songs[12], 12),
      this.createMoment('源来凯始玺欢你', $r("app.media.moment_14"), '人间荒唐市侩，不如山中做怪。', 5482, this.songs[13], 13),
      this.createMoment('史到淋头还想搅便', $r("app.media.moment_15"), '拜托 不随便谈恋爱的人真的很酷。', 5482, this.songs[14], 14),
      this.createMoment('Echo', $r("app.media.moment_16"), '以前很讨厌妈妈拿手机拍我 讨厌她拿手机对准我 每次都让她不要拍我 她每次都尴尬一笑 说不拍不拍 最后发现 只有妈妈会举手机记录我。', 5482, this.songs[15], 15)
    ]

    // 应用保存的状态数据（点赞、评论等）
    this.allMoments = this.communityState.applySavedStates(this.allMoments)

    // 首次加载一页
    this.loadMore()
  }

  private loadMore(): void {
    if (this.isLoading) {
      return
    }
    
    try {
      this.isLoading = true
      this.errorMessage = ''
      
      const start = this.pageIndex * this.pageSize
      const end = start + this.pageSize
      const source = this.getSortedAllMoments()
      const newData = source.slice(start, end)

      if (newData.length > 0) {
        this.momentList = this.momentList.concat(newData)
        this.pageIndex++
        this.hasMore = end < source.length
      } else {
        this.hasMore = false
      }
    } catch (error) {
      console.error('[Moment] Failed to load more:', error)
      this.errorMessage = '加载失败，请稍后重试'
    } finally {
      this.isLoading = false
    }
  }

  private handleRefresh(): void {
    if (this.isRefreshing) {
      return
    }
    
    try {
      this.isRefreshing = true
      this.errorMessage = ''
      this.resetAndLoad()
    } catch (error) {
      console.error('[Moment] Failed to refresh:', error)
      this.errorMessage = '刷新失败，请稍后重试'
    } finally {
      setTimeout(() => {
        this.isRefreshing = false
      }, 500)
    }
  }

  @Builder
  renderImageWithPlaceholder(src: string | Resource, width: number, height: number, borderRadius: number, borderConfig?: BorderConfig): void {
    if (borderConfig) {
      Image(src)
        .width(width)
        .height(height)
        .borderRadius(borderRadius)
        .alt($r('app.media.ic_play')) // 占位符
        .objectFit(ImageFit.Cover)
        .onError(() => {
          // 图片加载失败时的处理
          console.warn('[Moment] Image load failed:', src)
        })
        .border({ width: borderConfig.width, color: borderConfig.color })
    } else {
      Image(src)
        .width(width)
        .height(height)
        .borderRadius(borderRadius)
        .alt($r('app.media.ic_play')) // 占位符
        .objectFit(ImageFit.Cover)
        .onError(() => {
          // 图片加载失败时的处理
          console.warn('[Moment] Image load failed:', src)
        })
    }
  }

  @Builder
  renderSkeletonItem(): void {
    Column({ space: 14 }) {
      Row({ space: 14 }) {
        // 头像骨架
        Column()
          .width(46)
          .height(46)
          .borderRadius(23)
          .backgroundColor(this.themeState.getCardBackgroundColor())
          .opacity(0.3)
        
        Column({ space: 6 }) {
          // 用户名骨架
          Row()
            .width('60%')
            .height(16)
            .backgroundColor(this.themeState.getCardBackgroundColor())
            .opacity(0.3)
            .borderRadius(4)
          
          // 内容骨架
          Row()
            .width('100%')
            .height(40)
            .backgroundColor(this.themeState.getCardBackgroundColor())
            .opacity(0.3)
            .borderRadius(4)
        }
        .layoutWeight(1)
      }
      
      // 歌曲卡片骨架
      Row({ space: 12 }) {
        Column()
          .width(54)
          .height(54)
          .borderRadius(6)
          .backgroundColor(this.themeState.getCardBackgroundColor())
          .opacity(0.3)
        
        Column({ space: 8 }) {
          Row()
            .width('70%')
            .height(16)
            .backgroundColor(this.themeState.getCardBackgroundColor())
            .opacity(0.3)
            .borderRadius(4)
          Row()
            .width('50%')
            .height(12)
            .backgroundColor(this.themeState.getCardBackgroundColor())
            .opacity(0.3)
            .borderRadius(4)
        }
        .layoutWeight(1)
      }
      .padding({ left: 12, right: 12, top: 10, bottom: 10 })
      .backgroundColor(this.themeState.getCardBackgroundColor())
      .borderRadius(12)
    }
    .padding({ left: 16, right: 16, top: 18, bottom: 18 })
  }

  @Builder
  renderEmptyState(): void {
    Column({ space: 16 }) {
      Image($r('app.media.ic_play'))
        .width(80)
        .height(80)
        .fillColor(this.themeState.getIconColor())
        .opacity(0.3)
      
      Text('暂无动态')
        .fontSize(16)
        .fontColor(this.themeState.getSecondaryTextColor())
        .opacity(0.6)
      
      Text('快来发布第一条动态吧～')
        .fontSize(14)
        .fontColor(this.themeState.getSecondaryTextColor())
        .opacity(0.5)
    }
    .width('100%')
    .padding({ top: 100, bottom: 100 })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .layoutWeight(1)
  }

  @Builder
  renderErrorState(): void {
    Column({ space: 16 }) {
      Image($r('app.media.ic_play'))
        .width(80)
        .height(80)
        .fillColor('#FF5722')
        .opacity(0.3)
      
      Text('加载失败')
        .fontSize(16)
        .fontColor(this.themeState.getPrimaryTextColor())
      
      Text(this.errorMessage || '网络异常，请检查网络连接')
        .fontSize(14)
        .fontColor(this.themeState.getSecondaryTextColor())
        .opacity(0.7)
        .textAlign(TextAlign.Center)
        .padding({ left: 32, right: 32 })
      
      Button('重试')
        .margin({ top: 16 })
        .backgroundColor('#34C9C3')
        .fontColor(Color.White)
        .onClick(() => {
          this.errorMessage = ''
          this.handleRefresh()
        })
    }
    .width('100%')
    .padding({ top: 100, bottom: 100 })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .layoutWeight(1)
  }

  @Builder
  renderSongCard(item: SongItemType): void {
    Row({ space: 12 }) {
      this.renderImageWithPlaceholder(item.img, 54, 54, 6)
      Column({ space: 8 }) {
        Text(item.name)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          // 使用主题的主要文字颜色
          .fontColor(this.themeState.getPrimaryTextColor())
        Text(item.author)
          .fontSize(12)
          // 使用主题的次要文字颜色
          .fontColor(this.themeState.getSecondaryTextColor())
          .width('100%')
          .textAlign(TextAlign.Start)
      }
      .layoutWeight(1)

      Image($r('app.media.ic_play'))
        .width(20)
        .height(20)
        // 使用主题的图标颜色
        .fillColor(this.themeState.getIconColor())
        .opacity(0.95)
    }
    .padding({ left: 12, right: 12, top: 10, bottom: 10 })
    // 使用主题的卡片背景颜色
    .backgroundColor(this.themeState.getCardBackgroundColor())
    .borderRadius(12)
  }

  @Builder
  renderMomentItem(item: MomentListType): void {
    Column({ space: 14 }) {
      Row({ space: 14 }) {
        // 头像顶对齐 + 水平布局
        this.renderImageWithPlaceholder(item.avatar, 46, 46, 23, {
          width: 1,
          color: this.themeState.getDividerColor()
        } as BorderConfig)
        Column({ space: 6 }) {
          Row({ space: 8 }) {
            Text(item.author)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              // 使用主题的主要文字颜色
              .fontColor(this.themeState.getPrimaryTextColor())
            Text(this.formatRelativeTime(item.createdAt))
              .fontSize(12)
              .fontColor(this.themeState.getSecondaryTextColor())
              .opacity(0.7)
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)
          Text(item.content)
            .fontSize(14)
            .lineHeight(20)
            // 使用主题的次要文字颜色
            .fontColor(this.themeState.getSecondaryTextColor())
            .width('100%')
            .textAlign(TextAlign.Start)
            .maxLines(3)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .layoutWeight(1)
      }
      .alignItems(VerticalAlign.Top)

      // 歌曲卡片
      this.renderSongCard(item.song)

      // 操作栏 - 改进样式
      Row({ space: 0 }) {
        // 分享按钮
        Row({ space: 6 }) {
          Image($r('app.media.ic_share'))
            .width(18)
            .height(18)
            .fillColor(this.themeState.getIconColor())
            .opacity(0.8)
          Text('分享')
            .fontSize(13)
            .fontColor(this.themeState.getSecondaryTextColor())
        }
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .borderRadius(20)
        .onClick(() => {
          // TODO: 实现分享功能
        })
        
        // 评论按钮
        Row({ space: 6 }) {
          Image($r('app.media.ic_comment'))
            .width(18)
            .height(18)
            .fillColor(this.themeState.getIconColor())
            .opacity(0.8)
          Text(`${item.comment}`)
            .fontSize(13)
            .fontColor(this.themeState.getSecondaryTextColor())
        }
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .borderRadius(20)
        .onClick(() => this.openComments(item.id))

        Blank()
        
        // 点赞按钮 - 带动画效果
        Row({ space: 6 }) {
          Image($r('app.media.ic_dz'))
            .width(18)
            .height(18)
            .fillColor(item.liked ? Moment.LIKE_ACTIVE_COLOR : this.getLikeInactiveColor())
            .scale({
              x: (this.likeAnimationStates.get(item.id) ?? false) ? 1.3 : 1.0,
              y: (this.likeAnimationStates.get(item.id) ?? false) ? 1.3 : 1.0
            })
            .animation({
              duration: 200,
              curve: Curve.EaseOut
            })
          Text(`${item.like}`)
            .fontSize(13)
            .fontColor(item.liked ? Moment.LIKE_ACTIVE_COLOR : this.getLikeInactiveColor())
            .opacity((this.likeAnimationStates.get(item.id) ?? false) ? 0.7 : 1.0)
            .animation({
              duration: 200,
              curve: Curve.EaseOut
            })
        }
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .borderRadius(20)
        .backgroundColor(item.liked ? 'rgba(47, 128, 255, 0.1)' : 'transparent')
        .opacity((this.likeAnimationStates.get(item.id) ?? false) ? 0.8 : 1.0)
        .animation({
          duration: 150,
          curve: Curve.EaseInOut
        })
        .onClick(() => this.toggleMomentLike(item.id))
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      // 使用主题的分割线颜色
      Divider().strokeWidth(1).color(this.themeState.getDividerColor())
    }
    .padding({ left: 16, right: 16, top: 18, bottom: 18 })
  }

  @Builder
  renderCommentItem(momentId: string, c: CommentItemType): void {
    // 参考InfoItem布局：头像、昵称、内容、时间点赞都在左侧对齐
    Column() {
      // 1. 头像和昵称行
      Row() {
        this.renderImageWithPlaceholder(c.avatar, 30, 30, 15, {
          width: 0,
          color: Color.Transparent
        } as BorderConfig)
        Text(c.author)
          .fontSize(13)
          .fontColor(this.themeState.getSecondaryTextColor())
          .margin({ left: 8 })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .margin({ top: 10 })

      // 2. 评论内容
      Text(c.content)
        .fontSize(13)
        .fontColor(this.themeState.getPrimaryTextColor())
        .margin({ left: 38, top: 0, bottom: 8 })
        .width('100%')
        .textAlign(TextAlign.Start)
        .maxLines(10)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      // 3. 评论日期和点赞互动 - 带动画效果
      Row() {
        Text(this.formatRelativeTime(c.createdAt))
          .fontSize(11)
          .fontColor(this.themeState.getSecondaryTextColor())
        Row({ space: 4 }) {
          Image($r('app.media.ic_dz'))
            .width(15)
            .height(15)
            .fillColor(c.liked ? Moment.LIKE_ACTIVE_COLOR : this.getLikeInactiveColor())
            .scale({
              x: (this.commentLikeAnimationStates.get(`${momentId}-${c.id}`) ?? false) ? 1.4 : 1.0,
              y: (this.commentLikeAnimationStates.get(`${momentId}-${c.id}`) ?? false) ? 1.4 : 1.0
            })
            .animation({
              duration: 200,
              curve: Curve.EaseOut
            })
          if (c.like > 0) {
            Text(c.like.toString())
              .fontSize(11)
              .fontColor(c.liked ? Moment.LIKE_ACTIVE_COLOR : this.getLikeInactiveColor())
              .opacity((this.commentLikeAnimationStates.get(`${momentId}-${c.id}`) ?? false) ? 0.7 : 1.0)
              .animation({
                duration: 200,
                curve: Curve.EaseOut
              })
          }
        }
        .opacity((this.commentLikeAnimationStates.get(`${momentId}-${c.id}`) ?? false) ? 0.8 : 1.0)
        .animation({
          duration: 150,
          curve: Curve.EaseInOut
        })
        .onClick(() => this.toggleCommentLike(momentId, c.id))
      }
      .padding({ left: 38, top: 5 })
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
    }
    .padding({ left: 15, right: 15 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  renderCommentPanel(): void {
    Column() {
      // 顶部栏：标题 + 排序切换（最新/最热）- 参考InfoTop样式
      Row() {
        Text('全部评论')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeState.getPrimaryTextColor())

        Row() {
          Button('最新', { stateEffect: false })
            .width(46)
            .height(32)
            .fontSize(12)
            .padding({ left: 5, right: 5 })
            .backgroundColor(this.commentSortMode === 'latest' ? Color.White : this.themeState.getSearchBarColor())
            .fontColor(this.commentSortMode === 'latest' ? this.themeState.getPrimaryTextColor() : this.themeState.getSecondaryTextColor())
            .border({ width: 1, color: this.commentSortMode === 'latest' ? this.themeState.getDividerColor() : this.themeState.getSearchBarColor() })
            .onClick(() => this.commentSortMode = 'latest')
          Button('最热', { stateEffect: false })
            .width(46)
            .height(32)
            .fontSize(12)
            .padding({ left: 5, right: 5 })
            .backgroundColor(this.commentSortMode === 'hot' ? Color.White : this.themeState.getSearchBarColor())
            .fontColor(this.commentSortMode === 'hot' ? this.themeState.getPrimaryTextColor() : this.themeState.getSecondaryTextColor())
            .border({ width: 1, color: this.commentSortMode === 'hot' ? this.themeState.getDividerColor() : this.themeState.getSearchBarColor() })
            .onClick(() => this.commentSortMode = 'hot')
        }
        .backgroundColor(this.themeState.getSearchBarColor())
        .borderRadius(20)
      }
      .width('100%')
      .padding(16)
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)

      Divider().strokeWidth(1).color(this.themeState.getDividerColor())

      // 评论列表
      if (!this.hasActiveMoment()) {
        Column() {
          Text('暂无评论')
            .fontSize(13)
            .fontColor(this.themeState.getSecondaryTextColor())
            .opacity(0.8)
        }
        .layoutWeight(1)
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        List({ space: 0 }) {
          ForEach(this.getActiveSortedComments(), (c: CommentItemType, index: number) => {
            ListItem() {
              this.renderCommentItem(this.activeMomentId, c)
              Divider().strokeWidth(1).color(this.themeState.getDividerColor()).opacity(0.6)
            }
          }, (c: CommentItemType, index: number) => `${c.id}-${c.like}-${c.liked}`)
        }
        .edgeEffect(EdgeEffect.None)
        .layoutWeight(1)
        .width('100%')
        .height('100%')
      }

      // 底部输入栏 - 参考InfoBottom样式
      Row() {
        Row() {
          TextInput({
            placeholder: '写评论...',
            text: this.newCommentText
          })
            .backgroundColor(Color.Transparent)
            .fontSize(14)
            .fontColor(this.themeState.getPrimaryTextColor())
            .placeholderColor(this.themeState.getSecondaryTextColor())
            .padding({ left: 20 })
            .onChange((v: string) => {
              this.newCommentText = v
            })
            .onSubmit(() => {
              if ((this.newCommentText ?? '').trim()) {
                this.addComment()
              }
            })
        }
        .height(40)
        .backgroundColor(this.themeState.getSearchBarColor())
        .borderRadius(20)
        .margin({ left: 15, right: 20, top: 10, bottom: 10 })
        .layoutWeight(1)

        Button('发送', { stateEffect: false })
          .height(40)
          .padding({ left: 20, right: 20 })
          .borderRadius(20)
          .backgroundColor('#34C9C3')
          .fontColor(Color.White)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .enabled(!!(this.newCommentText ?? '').trim())
          .opacity(!!(this.newCommentText ?? '').trim() ? 1 : 0.5)
          .margin({ right: 15 })
          .onClick(() => {
            if ((this.newCommentText ?? '').trim()) {
              this.addComment()
            }
          })
      }
      .height(60)
      .width('100%')
    }
    .width('100%')
    .height('78%')
    .backgroundColor(this.themeState.getCardBackgroundColor())
    .borderRadius({ topLeft: 18, topRight: 18 })
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        // 标题 + 动态排序（更直观）
        Row() {
          Text('互动广场')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeState.getPrimaryTextColor())

          Row({ space: 8 }) {
            Text('最新')
              .fontSize(13)
              .fontWeight(this.momentSortMode === 'latest' ? FontWeight.Medium : FontWeight.Normal)
              .fontColor(this.momentSortMode === 'latest' ? '#34C9C3' : this.themeState.getSecondaryTextColor())
              .padding({ left: 14, right: 14, top: 6, bottom: 6 })
              .backgroundColor(this.momentSortMode === 'latest' ? 'rgba(52, 201, 195, 0.15)' : 'transparent')
              .borderRadius(18)
              .onClick(() => this.setMomentSortMode('latest'))
            Text('最热')
              .fontSize(13)
              .fontWeight(this.momentSortMode === 'hot' ? FontWeight.Medium : FontWeight.Normal)
              .fontColor(this.momentSortMode === 'hot' ? '#34C9C3' : this.themeState.getSecondaryTextColor())
              .padding({ left: 14, right: 14, top: 6, bottom: 6 })
              .backgroundColor(this.momentSortMode === 'hot' ? 'rgba(52, 201, 195, 0.15)' : 'transparent')
              .borderRadius(18)
              .onClick(() => this.setMomentSortMode('hot'))
          }
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)

        // 错误状态
        if (this.errorMessage && this.momentList.length === 0) {
          this.renderErrorState()
        } else if (this.isLoading && this.momentList.length === 0) {
          // 首次加载骨架屏
          List({ space: 0 }) {
            ForEach([1, 2, 3, 4, 5], (_index: number) => {
              ListItem() {
                this.renderSkeletonItem()
              }
            }, (_index: number) => _index.toString())
          }
          .edgeEffect(EdgeEffect.None)
          .layoutWeight(1)
          .width('100%')
          .height('100%')
        } else if (this.momentList.length === 0) {
          // 空状态
          this.renderEmptyState()
        } else {
          // 列表（动态加载）
          List({ space: 0 }) {
            ForEach(this.momentList, (item: MomentListType, _index: number) => {
              ListItem() {
                this.renderMomentItem(item)
              }
            }, (item: MomentListType, _idx: number): string => `${item.id}-${item.like}-${item.liked}`)

            ListItem() {
              if (this.hasMore) {
                Row() {
                  LoadingProgress()
                }
                .width('100%')
                .justifyContent(FlexAlign.Center)
                .padding({ top: 14, bottom: 24 })
                .onAppear(() => this.loadMore())
              } else if (this.momentList.length > 0) {
                Text('已经到底了～')
                  // 使用主题的次要文字颜色
                  .fontColor(this.themeState.getSecondaryTextColor())
                  .width('100%')
                  .textAlign(TextAlign.Center)
                  .padding({ top: 14, bottom: 24 })
              }
            }
          }
          .edgeEffect(EdgeEffect.None)
          .onScrollIndex((_start: number, end: number) => {
            if (end >= this.momentList.length - 2 && this.hasMore && !this.isLoading) {
              this.loadMore()
            }
          })
          .onReachStart(() => {
            // 下拉刷新
            if (!this.isRefreshing && !this.isLoading) {
              this.handleRefresh()
            }
          })
          .layoutWeight(1)
          .width('100%')
          .height('100%')
        }
        
        // 顶部刷新指示器
        if (this.isRefreshing) {
          Row() {
            LoadingProgress()
              .width(20)
              .height(20)
            Text('正在刷新...')
              .fontSize(12)
              .fontColor(this.themeState.getSecondaryTextColor())
              .margin({ left: 8 })
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .padding({ top: 8, bottom: 8 })
        }
      }
      .width('100%')
      .height('100%')

      // 评论面板（遮罩 + 底部sheet）
      if (this.isCommentPanelVisible) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0, 0, 0, 0.4)')
          .transition(TransitionEffect.OPACITY.animation({ duration: 200 }))
          .onClick(() => this.closeComments())

        Column() {
          this.renderCommentPanel()
        }
        .width('100%')
        .height('78%')
        .animation({ duration: 300, curve: Curve.EaseOut })
      }
      
    }
    .width('100%')
    .height('100%')
    // 使用主题状态中的背景颜色
    .backgroundColor(this.themeState.getBackgroundColor())
    .expandSafeArea()
    .onAppear(() => {
      // 初始化主题状态与用户状态
      const abilityCtx = getContext(this) as common.UIAbilityContext
      void Promise.all([
        this.themeState.initFromContext(abilityCtx),
        this.userState.initFromContext(abilityCtx)
      ]).catch((error: Error) => {
        console.error('[Moment] Failed to initialize context:', error)
      })
    })
  }
}