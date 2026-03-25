// 用户数据模型和状态管理（带持久化）
import dataPreferences from '@ohos.data.preferences'
import common from '@ohos.app.ability.common'
import fs from '@ohos.file.fs'

// 性别枚举
export enum Gender {
  MALE = 'male',
  FEMALE = 'female',
  OTHER = 'other',
  UNKNOWN = 'unknown'
}

// 用户账户信息接口
export interface UserAccount {
  username: string
  password: string
  nickname?: string        // 昵称
  gender?: Gender         // 性别
  age?: number            // 年龄
  avatarPath?: string     // 头像路径（本地文件路径）
  bio?: string            // 个性签名
}

@ObservedV2
export class UserState {
  @Trace isLoggedIn: boolean = false
  @Trace username: string = ''
  @Trace password: string = ''
  @Trace nickname: string = ''           // 昵称
  @Trace gender: Gender = Gender.UNKNOWN  // 性别
  @Trace age: number = 0                 // 年龄
  @Trace avatarPath: string = ''         // 头像路径
  @Trace bio: string = ''                // 个性签名

  private prefs?: dataPreferences.Preferences
  private initialized: boolean = false
  private userList: UserAccount[] = [] // 存储所有注册的用户
  private context?: common.UIAbilityContext // 保存上下文用于文件操作

  private static readonly PREF_NAME: string = 'hm_music_user_prefs'
  private static readonly KEY_USER_LIST: string = 'userList' // 用户列表
  private static readonly KEY_CURRENT_USERNAME: string = 'currentUsername' // 当前登录的用户名
  private static readonly KEY_IS_LOGGED_IN: string = 'isLoggedIn'
  // 旧版本使用的键名（用于向后兼容）
  private static readonly KEY_USERNAME_OLD: string = 'username'
  private static readonly KEY_PASSWORD_OLD: string = 'password'

  // 头像存储目录名
  private static readonly AVATAR_DIR: string = 'avatars'

  async initFromContext(ctx: common.UIAbilityContext): Promise<void> {
    // 如果已经初始化且prefs存在，则跳过（避免重复初始化）
    if (this.initialized && this.prefs) {
      return
    }
    this.context = ctx
    try {
      this.prefs = await dataPreferences.getPreferences(ctx, UserState.PREF_NAME)
      await this.loadFromStorage()
      this.initialized = true
    } catch (err) {
      console.error('Failed to initialize user state:', err)
      // 即使出错也标记为已初始化，避免无限重试
      this.initialized = true
    }
  }

  private async loadFromStorage(): Promise<void> {
    if (!this.prefs) {
      return
    }
    // 加载用户列表
    const userListStr: string = (await this.prefs.get(UserState.KEY_USER_LIST, '[]')) as string
    try {
      this.userList = JSON.parse(userListStr) as UserAccount[]
    } catch (e) {
      this.userList = []
    }

    // 向后兼容：如果用户列表为空，尝试从旧格式迁移
    if (this.userList.length === 0) {
      const oldUsername: string = (await this.prefs.get(UserState.KEY_USERNAME_OLD, '')) as string
      const oldPassword: string = (await this.prefs.get(UserState.KEY_PASSWORD_OLD, '')) as string
      if (oldUsername && oldPassword) {
        // 将旧数据迁移到新格式
        this.userList.push({ username: oldUsername, password: oldPassword })
        await this.saveUserList()
      }
    }

    // 加载当前登录状态
    const currentUsername: string = (await this.prefs.get(UserState.KEY_CURRENT_USERNAME, '')) as string
    const isLoggedIn: boolean = (await this.prefs.get(UserState.KEY_IS_LOGGED_IN, false)) as boolean

    // 向后兼容：如果没有当前用户名但有旧的登录状态，使用旧用户名
    let usernameToUse = currentUsername
    if (!usernameToUse && isLoggedIn) {
      const oldUsername: string = (await this.prefs.get(UserState.KEY_USERNAME_OLD, '')) as string
      if (oldUsername) {
        usernameToUse = oldUsername
        // 保存当前用户名
        await this.prefs.put(UserState.KEY_CURRENT_USERNAME, oldUsername)
      }
    }

    if (isLoggedIn && usernameToUse) {
      // 如果已登录，从用户列表中查找对应的用户信息
      const user = this.userList.find(u => u.username === usernameToUse)
      if (user) {
        this.username = user.username
        this.password = user.password
        this.nickname = user.nickname || user.username
        this.gender = user.gender || Gender.UNKNOWN
        this.age = user.age || 0
        this.avatarPath = user.avatarPath || ''
        this.bio = user.bio || ''
        this.isLoggedIn = true
      } else {
        this.isLoggedIn = false
        this.username = ''
        this.password = ''
        this.nickname = ''
        this.gender = Gender.UNKNOWN
        this.age = 0
        this.avatarPath = ''
        this.bio = ''
      }
    } else {
      this.isLoggedIn = false
      this.username = ''
      this.password = ''
      this.nickname = ''
      this.gender = Gender.UNKNOWN
      this.age = 0
      this.avatarPath = ''
    }
  }

  private async saveUserList(): Promise<void> {
    if (!this.prefs) {
      return
    }
    const userListStr = JSON.stringify(this.userList)
    await this.prefs.put(UserState.KEY_USER_LIST, userListStr)
    await this.prefs.flush()
  }

  private async saveLoginState(currentUsername: string, isLoggedIn: boolean): Promise<void> {
    if (!this.prefs) {
      return
    }
    await this.prefs.put(UserState.KEY_CURRENT_USERNAME, currentUsername)
    await this.prefs.put(UserState.KEY_IS_LOGGED_IN, isLoggedIn)
    await this.prefs.flush()
  }

  // 获取所有已注册的用户名列表
  getRegisteredUsers(): string[] {
    return this.userList.map(u => u.username)
  }

  register(username: string, password: string): boolean {
    if (username.length < 3 || password.length < 6) {
      return false
    }

    // 检查用户名是否已存在
    const existingUser = this.userList.find(u => u.username === username)
    if (existingUser) {
      // 如果用户已存在，更新密码
      existingUser.password = password
    } else {
      // 如果用户不存在，添加新用户（初始化默认信息）
      this.userList.push({
        username,
        password,
        nickname: username,  // 默认昵称为用户名
        gender: Gender.UNKNOWN,
        age: 0,
        avatarPath: '',
        bio: ''
      })
    }

    // 保存用户列表
    void this.saveUserList()
    return true
  }

  login(username: string, password: string): boolean {
    // 从用户列表中查找匹配的用户
    const user = this.userList.find(u => u.username === username && u.password === password)
    if (user) {
      this.username = user.username
      this.password = user.password
      this.nickname = user.nickname || user.username
      this.gender = user.gender || Gender.UNKNOWN
      this.age = user.age || 0
      this.avatarPath = user.avatarPath || ''
      this.bio = user.bio || ''
      this.isLoggedIn = true
      void this.saveLoginState(user.username, true)
      return true
    }
    return false
  }

  logout(): void {
    this.isLoggedIn = false
    // 保留所有已注册账号，只清除登录状态
    void this.saveLoginState('', false)
    // 不清空用户名和密码，保留最后登录的用户信息（用于UI显示）
  }

  reset(): void {
    this.isLoggedIn = false
    this.username = ''
    this.password = ''
    this.nickname = ''
    this.gender = Gender.UNKNOWN
    this.age = 0
    this.avatarPath = ''
    this.bio = ''
    this.userList = []
    void this.saveUserList()
    void this.saveLoginState('', false)
  }

  /**
   * 更新当前登录用户的个人信息
   */
  async updateUserProfile(nickname: string, gender: Gender, age: number, bio: string = ''): Promise<boolean> {
    if (!this.isLoggedIn || !this.username) {
      return false
    }

    const user = this.userList.find(u => u.username === this.username)
    if (!user) {
      return false
    }

    // 更新用户信息
    user.nickname = nickname
    user.gender = gender
    user.age = age
    user.bio = bio

    // 同步到当前状态
    this.nickname = nickname
    this.gender = gender
    this.age = age
    this.bio = bio

    // 保存到存储
    await this.saveUserList()
    return true
  }

  /**
   * 更新用户头像
   * @param imageUri 图片URI（来自图片选择器）
   */
  async updateAvatar(imageUri: string): Promise<boolean> {
    if (!this.isLoggedIn || !this.username || !this.context) {
      return false
    }

    try {
      // 获取应用文件目录
      const filesDir = this.context.filesDir
      const avatarDir = `${filesDir}/${UserState.AVATAR_DIR}`

      // 确保头像目录存在
      try {
        if (!fs.accessSync(avatarDir)) {
          fs.mkdirSync(avatarDir)
        }
      } catch (e) {
        fs.mkdirSync(avatarDir)
      }

      // 生成头像文件名（使用用户名）
      const avatarFileName = `avatar_${this.username}_${Date.now()}.jpg`
      const avatarFilePath = `${avatarDir}/${avatarFileName}`

      // 从URI读取图片文件并复制到应用目录
      // 简化方案：直接保存URI，UI层通过Image组件可以直接显示URI
      // 这样可以避免复杂的文件复制操作，同时保持功能完整性
      try {
        // 尝试使用 fs.copyFile 复制文件（如果URI是文件路径）
        try {
          fs.copyFileSync(imageUri, avatarFilePath)
        } catch (copyError) {
          // 如果复制失败（可能是content:// URI），则直接保存URI
          // Image组件可以处理URI格式
          this.avatarPath = imageUri
          const user = this.userList.find(u => u.username === this.username)
          if (user) {
            user.avatarPath = imageUri
          }
          await this.saveUserList()
          return true
        }
      } catch (e) {
        console.error('Failed to copy avatar file:', e)
        // 失败时也保存URI，确保功能可用
        this.avatarPath = imageUri
        const user = this.userList.find(u => u.username === this.username)
        if (user) {
          user.avatarPath = imageUri
        }
        await this.saveUserList()
        return true
      }

      // 删除旧头像（如果存在）
      const user = this.userList.find(u => u.username === this.username)
      if (user && user.avatarPath) {
        try {
          if (fs.accessSync(user.avatarPath)) {
            fs.unlinkSync(user.avatarPath)
          }
        } catch (e) {
          // 忽略删除错误
        }
      }

      // 更新用户信息
      if (user) {
        user.avatarPath = avatarFilePath
      }
      this.avatarPath = avatarFilePath

      // 保存到存储
      await this.saveUserList()
      return true
    } catch (error) {
      console.error('Failed to update avatar:', error)
      return false
    }
  }

  /**
   * 获取当前用户的头像路径（如果不存在则返回空字符串，UI层可以使用默认头像）
   */
  getAvatarPath(): string {
    if (this.avatarPath) {
      try {
        if (fs.accessSync(this.avatarPath)) {
          return this.avatarPath
        }
      } catch (e) {
        // 文件不存在，返回空字符串
      }
    }
    return '' // 返回空字符串，UI层可以使用默认头像
  }

  // 手机号登录（模拟）
  loginWithPhone(phone: string): boolean {
    // 模拟登录成功，自动创建账号
    const phoneUsername = `phone_${phone}`
    const existingUser = this.userList.find(u => u.username === phoneUsername)

    if (!existingUser) {
      // 首次登录，自动注册（初始化默认信息）
      this.userList.push({
        username: phoneUsername,
        password: '',
        nickname: phoneUsername,
        gender: Gender.UNKNOWN,
        age: 0,
        avatarPath: '',
        bio: ''
      })
      void this.saveUserList()
    }

    const user = this.userList.find(u => u.username === phoneUsername)
    if (user) {
      this.username = user.username
      this.password = user.password
      this.nickname = user.nickname || user.username
      this.gender = user.gender || Gender.UNKNOWN
      this.age = user.age || 0
      this.avatarPath = user.avatarPath || ''
      this.bio = user.bio || ''
    }
    this.isLoggedIn = true
    void this.saveLoginState(phoneUsername, true)
    return true
  }

  // 第三方登录（微信/QQ/微博）
  loginWithThirdParty(platform: 'wechat' | 'qq' | 'weibo', openId: string, nickname: string): boolean {
    // 模拟第三方登录
    const thirdPartyUsername = `${platform}_${openId}`
    const existingUser = this.userList.find(u => u.username === thirdPartyUsername)

    if (!existingUser) {
      // 首次登录，自动注册（使用第三方昵称）
      this.userList.push({
        username: thirdPartyUsername,
        password: '',
        nickname: nickname || thirdPartyUsername,
        gender: Gender.UNKNOWN,
        age: 0,
        avatarPath: '',
        bio: ''
      })
      void this.saveUserList()
    }

    const user = this.userList.find(u => u.username === thirdPartyUsername)
    if (user) {
      this.username = user.username
      this.password = user.password
      this.nickname = user.nickname || nickname || thirdPartyUsername
      this.gender = user.gender || Gender.UNKNOWN
      this.age = user.age || 0
      this.avatarPath = user.avatarPath || ''
      this.bio = user.bio || ''
    }
    this.isLoggedIn = true
    void this.saveLoginState(thirdPartyUsername, true)
    return true
  }
}
