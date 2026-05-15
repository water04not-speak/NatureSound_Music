// 默认屏幕尺寸常量（像素）
const DEFAULT_SCREEN_WIDTH_PX: number = 360
const DEFAULT_SCREEN_HEIGHT_PX: number = 640

// 屏幕尺寸断点（虚拟像素）
const TABLET_SCREEN_WIDTH_VP: number = 800
const LARGE_SCREEN_WIDTH_VP: number = 1200
const TABLET_SCREEN_HEIGHT_VP: number = 800
const LARGE_SCREEN_HEIGHT_VP: number = 1000

/**
 * 像素转虚拟像素（带降级）
 */
function toVp(px: number, fallbackPx: number): number {
  return px > 0 ? px2vp(px) : px2vp(fallbackPx)
}

/**
 * 获取屏幕宽度（虚拟像素）
 */
export function getScreenWidthVp(fallbackPx: number = DEFAULT_SCREEN_WIDTH_PX): number {
  const widthPx = Number(globalThis.displayInfo?.width)
  return toVp(widthPx, fallbackPx)
}

/**
 * 获取屏幕高度（虚拟像素）
 */
export function getScreenHeightVp(fallbackPx: number = DEFAULT_SCREEN_HEIGHT_PX): number {
  const heightPx = Number(globalThis.displayInfo?.height)
  return toVp(heightPx, fallbackPx)
}

/**
 * 根据屏幕宽度自适应选择值
 * @param screenWidthVp 屏幕宽度（虚拟像素）
 * @param mobileValue 移动端值
 * @param tabletValue 平板值
 * @param desktopValue 桌面端值
 */
export function resolveByScreenWidth<T>(screenWidthVp: number, mobileValue: T, tabletValue: T, desktopValue: T): T {
  if (screenWidthVp >= LARGE_SCREEN_WIDTH_VP) {
    return desktopValue
  }
  if (screenWidthVp >= TABLET_SCREEN_WIDTH_VP) {
    return tabletValue
  }
  return mobileValue
}

/**
 * 根据屏幕高度自适应选择值
 * @param screenHeightVp 屏幕高度（虚拟像素）
 * @param mobileValue 移动端值
 * @param tabletValue 平板值
 * @param desktopValue 桌面端值
 */
export function resolveByScreenHeight<T>(screenHeightVp: number, mobileValue: T, tabletValue: T, desktopValue: T): T {
  if (screenHeightVp >= LARGE_SCREEN_HEIGHT_VP) {
    return desktopValue
  }
  if (screenHeightVp >= TABLET_SCREEN_HEIGHT_VP) {
    return tabletValue
  }
  return mobileValue
}
