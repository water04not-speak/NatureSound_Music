// ----------------------------------------首页界面----------------------------------------------------

import { it } from "@ohos/hypium"
import { AppStorageV2 } from '@kit.ArkUI'
import { ThemeState } from '../models/theme'
import { getScreenWidthVp, resolveByScreenWidth } from '../utils/ScreenUtils'
import common from '@ohos.app.ability.common'

interface recommendDailyType {
  img: string  // 图片
  title: string  // 简介文字
  type:string  // 标题文字
  top:string  // 标题背景色
  bottom: string  // 简介背景色
}
interface recommendListType {
  img: string
  title: string
  count:string
}

@Component
// export 导出，别的组件才可以导入去使用
export struct Recommend {
  // 主题状态管理实例，用于管理背景颜色
  themeState: ThemeState = AppStorageV2.connect(ThemeState, 'THEME_STATE', () => new ThemeState())!
  pathStack: NavPathStack = AppStorageV2.connect(NavPathStack, 'navStack', () => new NavPathStack())!
  // 轮播图数据
  swiperList:string[]=[
    "app.media.lb_01",
    "app.media.lb_02",
    "app.media.lb_03",
    "app.media.lb_04",
    "app.media.lb_05",
    "app.media.csj02",
    "app.media.csj03",
    "app.media.cy02",
    "app.media.gf02",
    "app.media.gf03",
    "app.media.wx02",
    "app.media.wx03",
    "app.media.xd02",
    "app.media.xd03",
  ]
  // 每日推荐数据----------------------------------需替换图片数据---------------------------------------------------
  dailyRecommend: recommendDailyType[] = [
    {
      img: "app.media.DayRecom1",
      title: '屏蔽干扰，营造深度思考的音符结界。',
      type: '专注学习',
      top: '#660000',
      bottom: '#382e2f'
    },
    {
      img: "app.media.DayRecom2",
      title: '飙升肾上腺素，每一步都踩在强力鼓点上。',
      type: '运动充电',
      top: '#382e2f',
      bottom: '#a37862'
    },
    {
      img: "app.media.DayRecom3",
      title: '容纳所有情绪的深夜海浪与孤独星辰。',
      type: '深夜emo',
      top: '#a37862',
      bottom: '#174847'
    },
    {
      img: "app.media.DayRecom4",
      title: '温柔包裹每一处情绪裂痕的声波绷带。',
      type: '治愈疗伤',
      top: '#174847',
      bottom: '#174847'
    }
  ]

  // 推荐歌单数据
  recommendList: recommendListType[] = [
    {
      img: "app.media.RecomMusic01",
      title: '如清晨薄雾，抚慰心灵的纯净琴音',
      count: '345.6万'
    },
    {
      img: "app.media.RecomMusic02",
      title: '旋律入耳即走红，属于此刻的潮流节拍',
      count: '243.9万'
    },
    {
      img: "app.media.RecomMusic03",
      title: '穿越时空的宏伟乐章，大师的永恒对话',
      count: '666万'
    },
    {
      img: "app.media.RecomMusic04",
      title: '水墨律动，将千年风雅谱入现代旋律',
      count: '487.6万'
    },
    {
      img: "app.media.RecomMusic05",
      title: '怀抱吉他，唱述远方故事与质朴深情',
      count: '397.9万'
    }
  ]

  // 响应式布局配置
  private getScreenWidth(): number {
    return getScreenWidthVp()
  }

  private getSwiperAspectRatio(): number {
    return resolveByScreenWidth(this.getScreenWidth(), 2.2, 2.5, 3.0)
  }

  private getDailyRecommendWidth(): string {
    return resolveByScreenWidth(this.getScreenWidth(), '40%', '28%', '22%')
  }

  private getRecommendListWidth(): string {
    return resolveByScreenWidth(this.getScreenWidth(), '30%', '23%', '18%')
  }

  @Builder
  titleBuilder (title: string) {
    Row() {
      Text(title)
        // 使用主题的主要文字颜色
        .fontColor(this.themeState.getPrimaryTextColor())
        .fontWeight(700)
        .layoutWeight(1)
      Image($r('app.media.ic_more'))
        .width(22)
        // 使用主题的图标颜色
        .fillColor(this.themeState.getIconColor())

    }
    .width('100%')
    .height(40)
  }

  build() {
    Scroll() {
      Column({space:10}){
      //   搜索区域
        Row({ space: 12 }){
          Image($r('app.media.ic_search'))
            .width(20)
            // 使用主题的次要文字颜色
            .fillColor(this.themeState.getSecondaryTextColor())
          TextInput({placeholder:'Black Veil Bride Rosy赵露思🔥🔥🔥'})
          // 使用主题的次要文字颜色
            .placeholderColor(this.themeState.getSecondaryTextColor())
            .fontSize(15)
            // 使用主题的主要文字颜色
            .fontColor(this.themeState.getPrimaryTextColor())
            .layoutWeight(1)//抛去其他的空间，剩下的空间部分都给它
            .enabled(false)
          Image($r('app.media.ic_code'))
            .width(20)
            // 使用主题的次要文字颜色
            .fillColor(this.themeState.getSecondaryTextColor())
        }
        .width('100%')
        .height(44)
        // 使用主题的搜索框背景颜色
        .backgroundColor(this.themeState.getSearchBarColor())
        .border({radius:22})
        .padding({right:16,left:16})
        .shadow({ radius: 4, color: 'rgba(0,0,0,0.1)', offsetX: 0, offsetY: 2 })
        .onClick(() => {
          // 点击搜索框跳转到搜索页面
          this.pathStack.pushPathByName('Search', null, false)
        })
      //   轮播图区域
        Swiper(){//实现轮播图功能
          ForEach(this.swiperList,(item:string)=>{
            Image($r(item))
              .width('100%')
              .height('100%')
              .objectFit(ImageFit.Cover)
          })
        }
        .border({radius:10})
        .aspectRatio(this.getSwiperAspectRatio())//设置和图片一致的宽高比，保证图片正常适配
        .width("100%")
        .interval(2000)//控制播放的时间间隔
        .autoPlay(true)//实现自动播放
        .indicator(
          Indicator.dot()
            .itemWidth(10)
            .selectedItemWidth(25)
            .selectedColor(Color.White)
        )
      //   每日推荐区域
        this.titleBuilder('每日推荐')
        List(){
          ForEach(this.dailyRecommend,(item:recommendDailyType)=>{
            ListItem(){
              Column(){
                Text(item.type)
                  .width('100%')
                  .height(40)
                  .backgroundColor(item.top)
                  .padding({left:5})
                  .fontSize(14)
                  .fontColor('#fff')
                // ---------------------------------------需替换的图片数据位置-------------------------------------
                Image($r(item.img))
                  .width('100%')
                  .height('100%')
                  .objectFit(ImageFit.Cover)
                Text(item.title)
                  .width('100%')
                  .backgroundColor(item.bottom)
                  .padding(5)
                  .fontSize(14)
                  .fontColor('#fff')
                  .maxLines(2)// 文本显示最大的行数
                  .textOverflow({overflow:TextOverflow.Ellipsis}) // 文本溢出的显示方式——> 省略号
              }
              .width(this.getDailyRecommendWidth())
              // .height(200)
              // .backgroundColor(Color.Pink)
              .border({radius:10})
              .margin({right:10})
              .clip(true)//裁剪
            }
          })
        }
        .listDirection(Axis.Horizontal)//改布局方向,List布局方向
        .height(230)
        .scrollBar(BarState.Off)
      //   推荐歌单
        this.titleBuilder('推荐歌单')
        List(){
          ForEach(this.recommendList,(item:recommendListType)=>{
            ListItem(){
              Column(){
                Stack({alignContent:Alignment.TopStart}){
                  Image($r(item.img))
                    .width('100%')
                    .height(100)
                    .objectFit(ImageFit.Cover)
                    .border({radius:8})
                  Text(item.count)
                    .fontSize(12)
                    .fontColor('#fff')
                    .fontWeight(700)
                    .margin(5)
                }
                Text(item.title)
                  // 使用主题的主要文字颜色
                  .fontColor(this.themeState.getPrimaryTextColor())
                  .fontSize(14)
                  .width('100%')
                  .padding(5)
                  .maxLines(2)
                  .textOverflow({overflow:TextOverflow.Ellipsis})
              }
              .width(this.getRecommendListWidth())
              // .height(200)
              // .backgroundColor(Color.Pink)
              .margin({right:10})

            }
          })
        }
        .listDirection(Axis.Horizontal)//把list布局方向强制指定为水平排列
      }
        .width('100%')
        .padding({left:10,right:10,top:5,bottom:5})
        // 使用主题状态中的背景颜色
        .backgroundColor(this.themeState.getBackgroundColor())
        .onAppear(() => {
          // 初始化主题状态（确保应用恢复时主题正确）
          const abilityCtx = getContext(this) as common.UIAbilityContext
          // 确保主题状态已初始化，这样UI才能正确显示
          // 如果还未加载，先加载主题状态
          if (!this.themeState.isThemeLoaded()) {
            this.themeState.initFromContext(abilityCtx).then(() => {
              console.info('Recommend: Theme state initialized')
            }).catch((error: Error) => {
              console.error('Recommend: Failed to initialize theme state:', error)
            })
          }
        })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Auto)
    .edgeEffect(EdgeEffect.Spring)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}