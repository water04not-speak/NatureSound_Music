const DEFAULT_SCREEN_WIDTH_PX: number = 360
const DEFAULT_SCREEN_HEIGHT_PX: number = 640

const TABLET_SCREEN_WIDTH_VP: number = 800
const LARGE_SCREEN_WIDTH_VP: number = 1200
const TABLET_SCREEN_HEIGHT_VP: number = 800
const LARGE_SCREEN_HEIGHT_VP: number = 1000

function toVp(px: number, fallbackPx: number): number {
  return px > 0 ? px2vp(px) : px2vp(fallbackPx)
}

export function getScreenWidthVp(fallbackPx: number = DEFAULT_SCREEN_WIDTH_PX): number {
  const widthPx = Number(globalThis.displayInfo?.width)
  return toVp(widthPx, fallbackPx)
}

export function getScreenHeightVp(fallbackPx: number = DEFAULT_SCREEN_HEIGHT_PX): number {
  const heightPx = Number(globalThis.displayInfo?.height)
  return toVp(heightPx, fallbackPx)
}

export function resolveByScreenWidth<T>(screenWidthVp: number, mobileValue: T, tabletValue: T, desktopValue: T): T {
  if (screenWidthVp >= LARGE_SCREEN_WIDTH_VP) {
    return desktopValue
  }
  if (screenWidthVp >= TABLET_SCREEN_WIDTH_VP) {
    return tabletValue
  }
  return mobileValue
}

export function resolveByScreenHeight<T>(screenHeightVp: number, mobileValue: T, tabletValue: T, desktopValue: T): T {
  if (screenHeightVp >= LARGE_SCREEN_HEIGHT_VP) {
    return desktopValue
  }
  if (screenHeightVp >= TABLET_SCREEN_HEIGHT_VP) {
    return tabletValue
  }
  return mobileValue
}
