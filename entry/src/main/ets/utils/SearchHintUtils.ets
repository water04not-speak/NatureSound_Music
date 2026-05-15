// 音乐种子类型
import { MusicSongSeed } from '../models/musicDb'

/**
 * 从音乐种子构建搜索提示池（去重）
 * @param seeds 音乐种子列表
 * @returns 去重后的歌曲标题列表
 */
export function buildSearchHintPool(seeds: MusicSongSeed[]): string[] {
  const pool = seeds
    .map((seed: MusicSongSeed) => seed.title.trim())
    .filter((title: string) => title.length > 0)

  return Array.from(new Set(pool))
}

/**
 * 随机选取搜索提示词
 * @param hints 提示词列表
 * @param fallback 兜底提示词
 * @returns 随机选中的提示词
 */
export function pickRandomSearchHint(hints: string[], fallback: string): string {
  if (hints.length === 0) {
    return fallback
  }

  const randomIndex = Math.floor(Math.random() * hints.length)
  return hints[randomIndex]
}