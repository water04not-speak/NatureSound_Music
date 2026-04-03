// 主题颜色管理模型（带持久化）
// 用于统一管理应用的完整主题配色方案，支持多页面共享和持久化存储
import dataPreferences from '@ohos.data.preferences'
import common from '@ohos.app.ability.common'

/**
 * 完整的主题配色方案接口
 * 包含背景色、文字色、卡片色等完整配色
 */
export interface ThemeConfig {
  name: string              // 主题名称
  backgroundColor: string   // 页面背景颜色
  primaryTextColor: string  // 主要文字颜色（标题等）
  secondaryTextColor: string // 次要文字颜色（描述等）
  cardBackgroundColor: string // 卡片背景颜色
  dividerColor: string      // 分割线颜色
  iconColor: string         // 图标颜色
  searchBarColor: string    // 搜索框背景颜色
  backgroundImage: ResourceStr // 背景图（用于“更换背景”整页换肤）
  backgroundImageOpacity: number // 背景图透明度（0~1）
  backgroundOverlayOpacity: number // 颜色遮罩透明度（0~1），用于整体氛围统一/保证文字可读性
  isDark: boolean           // 是否为深色主题
}

/**
 * 颜色选项接口（用于颜色选择器显示）
 */
export interface ThemeColorOption {
  name: string              // 颜色名称，用于显示
  value: string             // 背景颜色值
  config: ThemeConfig       // 完整的主题配置
}

/**
 * 主题状态管理类
 * 使用 @ObservedV2 装饰器，支持响应式更新
 * 使用 dataPreferences 实现主题选择的持久化存储
 */
@ObservedV2
export class ThemeState {
  // 当前主题配置
  @Trace private currentTheme: ThemeConfig = ThemeState.THEME_CONFIGS[0]
  // 标记主题是否已从存储中加载完成
  @Trace private isLoaded: boolean = false

  // 预定义的完整主题配置列表
  // 每个主题包含完整的配色方案
  private static readonly THEME_CONFIGS: ThemeConfig[] = [
    // 浅色主题
    {
      name: '米白色',
      backgroundColor: '#E8E4D8',
      primaryTextColor: '#333333',
      secondaryTextColor: '#666666',
      cardBackgroundColor: '#FFFFFF',
      dividerColor: '#E0E0E0',
      iconColor: '#666666',
      searchBarColor: '#F5F5F5',
      // 背景图与遮罩参数：让背景图看得见，同时保证文字可读
      backgroundImage: $r('app.media.all_bg01'),
      backgroundImageOpacity: 0.72,
      backgroundOverlayOpacity: 0.20,
      isDark: false
    },
    {
      name: '浅灰色',
      backgroundColor: '#F5F5F5',
      primaryTextColor: '#2C2C2C',
      secondaryTextColor: '#5C5C5C',
      cardBackgroundColor: '#FFFFFF',
      dividerColor: '#DADADA',
      iconColor: '#5C5C5C',
      searchBarColor: '#EEEEEE',
      backgroundImage: $r('app.media.all_bg02'),
      backgroundImageOpacity: 0.70,
      backgroundOverlayOpacity: 0.18,
      isDark: false
    },
    {
      name: '淡蓝色',
      backgroundColor: '#E3F2FD',
      primaryTextColor: '#1565C0',
      secondaryTextColor: '#1976D2',
      cardBackgroundColor: '#FFFFFF',
      dividerColor: '#BBDEFB',
      iconColor: '#1976D2',
      searchBarColor: '#F5F9FF',
      backgroundImage: $r('app.media.all_bg03'),
      backgroundImageOpacity: 0.70,
      backgroundOverlayOpacity: 0.22,
      isDark: false
    },
    {
      name: '淡粉色',
      backgroundColor: '#FCE4EC',
      primaryTextColor: '#C2185B',
      secondaryTextColor: '#E91E63',
      cardBackgroundColor: '#FFFFFF',
      dividerColor: '#F8BBD0',
      iconColor: '#E91E63',
      searchBarColor: '#FFF5F8',
      backgroundImage: $r('app.media.all_bg04'),
      backgroundImageOpacity: 0.70,
      backgroundOverlayOpacity: 0.22,
      isDark: false
    },
    {
      name: '淡绿色',
      backgroundColor: '#E8F5E9',
      primaryTextColor: '#2E7D32',
      secondaryTextColor: '#388E3C',
      cardBackgroundColor: '#FFFFFF',
      dividerColor: '#C8E6C9',
      iconColor: '#388E3C',
      searchBarColor: '#F5FFF5',
      backgroundImage: $r('app.media.all_bg05'),
      backgroundImageOpacity: 0.70,
      backgroundOverlayOpacity: 0.20,
      isDark: false
    },
    {
      name: '淡紫色',
      backgroundColor: '#F3E5F5',
      primaryTextColor: '#7B1FA2',
      secondaryTextColor: '#8E24AA',
      cardBackgroundColor: '#FFFFFF',
      dividerColor: '#E1BEE7',
      iconColor: '#8E24AA',
      searchBarColor: '#FFF5FF',
      backgroundImage: $r('app.media.all_bg06'),
      backgroundImageOpacity: 0.70,
      backgroundOverlayOpacity: 0.22,
      isDark: false
    },
    {
      name: '淡黄色',
      backgroundColor: '#FFF9C4',
      primaryTextColor: '#F57F17',
      secondaryTextColor: '#F9A825',
      cardBackgroundColor: '#FFFEF7',
      dividerColor: '#FFF59D',
      iconColor: '#F9A825',
      searchBarColor: '#FFFEF0',
      backgroundImage: $r('app.media.all_bg07'),
      backgroundImageOpacity: 0.68,
      backgroundOverlayOpacity: 0.24,
      isDark: false
    },
    // 深色主题
    {
      name: '深灰色',
      backgroundColor: '#424242',
      primaryTextColor: '#FFFFFF',
      secondaryTextColor: '#B0B0B0',
      cardBackgroundColor: '#2C2C2E',
      dividerColor: '#5A5A5A',
      iconColor: '#E0E0E0',
      searchBarColor: '#3A3A3A',
      backgroundImage: $r('app.media.all_bg08'),
      backgroundImageOpacity: 0.58,
      backgroundOverlayOpacity: 0.40,
      isDark: true
    },
    {
      name: '深蓝色',
      backgroundColor: '#1A237E',
      primaryTextColor: '#FFFFFF',
      secondaryTextColor: '#B3C7F7',
      cardBackgroundColor: '#283593',
      dividerColor: '#3949AB',
      iconColor: '#B3C7F7',
      searchBarColor: '#283593',
      backgroundImage: $r('app.media.all_bg09'),
      backgroundImageOpacity: 0.58,
      backgroundOverlayOpacity: 0.42,
      isDark: true
    },
    {
      name: '深绿色',
      backgroundColor: '#1B5E20',
      primaryTextColor: '#FFFFFF',
      secondaryTextColor: '#A5D6A7',
      cardBackgroundColor: '#2E7D32',
      dividerColor: '#388E3C',
      iconColor: '#A5D6A7',
      searchBarColor: '#2E7D32',
      // 背景图数量有限，复用一张并用更强遮罩保证可读性
      backgroundImage: $r('app.media.all_bg05'),
      backgroundImageOpacity: 0.56,
      backgroundOverlayOpacity: 0.45,
      isDark: true
    }
  ]

  // 预定义的颜色选项列表（用于颜色选择器）
  private static readonly COLOR_OPTIONS: ThemeColorOption[] = ThemeState.THEME_CONFIGS.map((config: ThemeConfig): ThemeColorOption => {
    return {
      name: config.name,
      value: config.backgroundColor,
      config: config
    } as ThemeColorOption
  })

  private prefs?: dataPreferences.Preferences
  private initialized: boolean = false

  // 持久化存储的键名
  private static readonly PREF_NAME: string = 'hm_music_theme_prefs'
  private static readonly KEY_BACKGROUND_COLOR: string = 'backgroundColor'

  /**
   * 初始化主题状态
   * 从持久化存储中加载之前保存的背景颜色
   * @param ctx UIAbility上下文，用于获取 Preferences 实例
   */
  async initFromContext(ctx: common.UIAbilityContext): Promise<void> {
    // 如果已经初始化且prefs存在，则跳过（避免重复初始化）
    if (this.initialized && this.prefs && this.isLoaded) {
      return
    }
    try {
      this.isLoaded = false
      this.prefs = await dataPreferences.getPreferences(ctx, ThemeState.PREF_NAME)
      await this.loadFromStorage()
      this.isLoaded = true
      this.initialized = true
    } catch (err) {
      console.error('Failed to initialize theme state:', err)
      // 即使出错也标记为已加载和已初始化，避免无限重试
      this.isLoaded = true
      this.initialized = true
    }
  }

  /**
   * 从持久化存储中加载主题配置
   * 如果存储中没有值，则使用默认主题
   */
  private async loadFromStorage(): Promise<void> {
    if (!this.prefs) {
      return
    }
    try {
      const savedColor: string = (await this.prefs.get(ThemeState.KEY_BACKGROUND_COLOR, '#E8E4D8')) as string
      // 根据保存的背景颜色查找对应的主题配置
      const theme = ThemeState.THEME_CONFIGS.find(t => t.backgroundColor === savedColor)
      if (theme) {
        // 直接赋值会触发 @Trace 的响应式更新
        this.currentTheme = theme
      } else {
        // 如果找不到匹配的主题，使用默认主题
        this.currentTheme = ThemeState.THEME_CONFIGS[0]
      }
    } catch (err) {
      console.error('Failed to load theme from storage:', err)
      // 出错时使用默认主题
      this.currentTheme = ThemeState.THEME_CONFIGS[0]
    }
  }

  /**
   * 保存背景颜色到持久化存储
   * @param color 要保存的颜色值
   */
  private async saveToStorage(color: string): Promise<void> {
    if (!this.prefs) {
      return
    }
    try {
      await this.prefs.put(ThemeState.KEY_BACKGROUND_COLOR, color)
      await this.prefs.flush()
    } catch (err) {
      console.error('Failed to save theme to storage:', err)
    }
  }

  /**
   * 获取所有可用的颜色选项
   * @returns 颜色选项数组
   */
  getColorOptions(): ThemeColorOption[] {
    return ThemeState.COLOR_OPTIONS
  }

  /**
   * 设置主题（通过背景颜色）
   * 更新当前主题并保存到持久化存储
   * @param color 新的背景颜色值
   */
  setBackgroundColor(color: string): void {
    const theme = ThemeState.THEME_CONFIGS.find(t => t.backgroundColor === color)
    if (theme) {
      this.currentTheme = theme
      void this.saveToStorage(color)
    }
  }

  /**
   * 检查主题是否已加载完成
   * @returns 是否已加载
   */
  isThemeLoaded(): boolean {
    return this.isLoaded
  }

  /**
   * 获取当前背景颜色
   * @returns 当前背景颜色值
   */
  getBackgroundColor(): string {
    return this.currentTheme.backgroundColor
  }

  /**
   * 获取当前主要文字颜色
   * @returns 主要文字颜色值
   */
  getPrimaryTextColor(): string {
    return this.currentTheme.primaryTextColor
  }

  /**
   * 获取当前次要文字颜色
   * @returns 次要文字颜色值
   */
  getSecondaryTextColor(): string {
    return this.currentTheme.secondaryTextColor
  }

  /**
   * 获取品牌强调色
   * 兼容部分页面的旧命名
   */
  getBrandColor(): string {
    return this.currentTheme.iconColor
  }

  /**
   * 获取当前卡片背景颜色
   * @returns 卡片背景颜色值
   */
  getCardBackgroundColor(): string {
    return this.currentTheme.cardBackgroundColor
  }

  /**
   * 获取当前分割线颜色
   * @returns 分割线颜色值
   */
  getDividerColor(): string {
    return this.currentTheme.dividerColor
  }

  /**
   * 获取当前图标颜色
   * @returns 图标颜色值
   */
  /**
   * 播放页前景色：在模糊背景上确保对比度
   * 浅色主题时用深色，深色主题时用浅色
   */
  getPlayPageForegroundColor(): string {
    return this.currentTheme.isDark ? '#FFFFFF' : '#1A1A1A'
  }

  getIsDark(): boolean {
    return this.currentTheme.isDark
  }

  getIconColor(): string {
    return this.currentTheme.iconColor
  }

  /**
   * 获取当前搜索框背景颜色
   * @returns 搜索框背景颜色值
   */
  getSearchBarColor(): string {
    return this.currentTheme.searchBarColor
  }

  /**
   * 获取当前背景图资源
   */
  getBackgroundImage(): ResourceStr {
    return this.currentTheme.backgroundImage
  }

  /**
   * 获取当前背景图透明度
   */
  getBackgroundImageOpacity(): number {
    return this.currentTheme.backgroundImageOpacity
  }

  /**
   * 获取当前颜色遮罩透明度
   */
  getBackgroundOverlayOpacity(): number {
    return this.currentTheme.backgroundOverlayOpacity
  }

  /**
   * 判断当前是否为深色主题
   * @returns 是否为深色主题
   */
  isDarkTheme(): boolean {
    return this.currentTheme.isDark
  }

  /**
   * 获取当前完整主题配置
   * @returns 当前主题配置对象
   */
  getCurrentTheme(): ThemeConfig {
    return this.currentTheme
  }

  /**
   * 重置为默认主题
   */
  resetToDefault(): void {
    this.setBackgroundColor('#E8E4D8')
  }
}

