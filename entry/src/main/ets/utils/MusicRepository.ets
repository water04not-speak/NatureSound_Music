import common from '@ohos.app.ability.common'
import relationalStore from '@ohos.data.relationalStore'
import { SongItemType } from '../models/music'
import { MusicSongEntity, MusicSongSeed } from '../models/musicDb'
import { MusicDatabase } from './MusicDatabase'
import { musicDatabase } from './MusicDatabase'

export class MusicRepository {
  private seedPromise?: Promise<void>

  async init(context: common.UIAbilityContext): Promise<void> {
    await musicDatabase.getStore(context)
  }

  async seedIfNeeded(context: common.UIAbilityContext, seeds: MusicSongSeed[]): Promise<void> {
    if (this.seedPromise) {
      return this.seedPromise
    }

    this.seedPromise = (async () => {
      try {
        const store = await musicDatabase.getStore(context)
        const count = await this.getCount(store)
        if (count > 0 || seeds.length === 0) {
          return
        }

        const baseTime = Date.now() - seeds.length
        for (let index = 0; index < seeds.length; index++) {
          const seed = seeds[index]
          await this.insertSongInternal(store, {
            id: seed.id,
            title: seed.title,
            singer: seed.singer,
            url: seed.url,
            cover: seed.cover,
            lyric: seed.lyric ?? '',
            isFavorite: 0,
            createTime: baseTime + index
          })
        }
      } catch (error) {
        console.error('[MusicRepository] seedIfNeeded failed:', String(error))
        throw new Error(String(error))
      }
    })().finally(() => {
      this.seedPromise = undefined
    })

    return this.seedPromise
  }

  async getAllSongs(context: common.UIAbilityContext): Promise<SongItemType[]> {
    try {
      const store = await musicDatabase.getStore(context)
      return this.mapEntitiesToSongItems(await this.queryAll(store))
    } catch (error) {
      console.error('[MusicRepository] getAllSongs failed:', String(error))
      return []
    }
  }

  async getFavoriteSongs(context: common.UIAbilityContext): Promise<SongItemType[]> {
    try {
      const store = await musicDatabase.getStore(context)
      return this.mapEntitiesToSongItems(await this.queryByFavorite(store, 1))
    } catch (error) {
      console.error('[MusicRepository] getFavoriteSongs failed:', String(error))
      return []
    }
  }

  async getSongById(context: common.UIAbilityContext, id: string): Promise<SongItemType | undefined> {
    try {
      const store = await musicDatabase.getStore(context)
      const entity = await this.queryOne(store, id)
      return entity ? this.mapEntityToSongItem(entity) : undefined
    } catch (error) {
      console.error('[MusicRepository] getSongById failed:', String(error))
      return undefined
    }
  }

  async searchSongs(context: common.UIAbilityContext, keyword: string, limit: number = 50, offset: number = 0): Promise<SongItemType[]> {
    const normalized = keyword.trim()
    if (!normalized) {
      return []
    }

    try {
      const store = await musicDatabase.getStore(context)
      const likeKeyword = `%${normalized}%`
      const rs = await store.querySql(
        `SELECT id, title, singer, url, cover, lyric, isFavorite, createTime FROM ${MusicDatabase.TABLE_NAME} WHERE title LIKE ? OR singer LIKE ? ORDER BY createTime ASC LIMIT ${limit} OFFSET ${offset}`,
        [likeKeyword, likeKeyword]
      )
      return this.mapEntitiesToSongItems(this.readResultSet(rs))
    } catch (error) {
      console.error('[MusicRepository] searchSongs failed:', String(error))
      return []
    }
  }

  async insertSong(context: common.UIAbilityContext, song: MusicSongEntity): Promise<number> {
    const store = await musicDatabase.getStore(context)
    return await this.insertSongInternal(store, song)
  }

  async updateSong(context: common.UIAbilityContext, song: MusicSongEntity): Promise<number> {
    const store = await musicDatabase.getStore(context)
    return await this.updateSongInternal(store, song)
  }

  async deleteSong(context: common.UIAbilityContext, id: string): Promise<number> {
    try {
      const store = await musicDatabase.getStore(context)
      const predicates = new relationalStore.RdbPredicates(MusicDatabase.TABLE_NAME)
      predicates.equalTo('id', id)
      return await store.delete(predicates)
    } catch (error) {
      console.error('[MusicRepository] deleteSong failed:', String(error))
      throw new Error(String(error))
    }
  }

  async toggleFavorite(context: common.UIAbilityContext, id: string): Promise<SongItemType | undefined> {
    try {
      const store = await musicDatabase.getStore(context)
      const current = await this.queryOne(store, id)
      if (!current) {
        return undefined
      }

      const next: MusicSongEntity = {
        id: current.id,
        title: current.title,
        singer: current.singer,
        url: current.url,
        cover: current.cover,
        lyric: current.lyric,
        isFavorite: current.isFavorite === 1 ? 0 : 1,
        createTime: current.createTime
      }
      await this.updateSongInternal(store, next)
      return this.mapEntityToSongItem(next)
    } catch (error) {
      console.error('[MusicRepository] toggleFavorite failed:', String(error))
      return undefined
    }
  }

  async replaceAll(context: common.UIAbilityContext, songs: MusicSongSeed[]): Promise<void> {
    try {
      const store = await musicDatabase.getStore(context)
      const baseTime = Date.now() - songs.length
      let index = 0
      for (const song of songs) {
        await this.insertOrReplace(store, {
          id: song.id,
          title: song.title,
          singer: song.singer,
          url: song.url,
          cover: song.cover,
          lyric: song.lyric ?? '',
          isFavorite: 0,
          createTime: baseTime + index
        })
        index++
      }
    } catch (error) {
      console.error('[MusicRepository] replaceAll failed:', String(error))
      throw new Error(String(error))
    }
  }

  private async getCount(store: relationalStore.RdbStore): Promise<number> {
    try {
      const rs = await store.querySql(`SELECT COUNT(*) AS count FROM ${MusicDatabase.TABLE_NAME}`)
      try {
        if (rs.goToFirstRow()) {
          return rs.getLong(rs.getColumnIndex('count'))
        }
        return 0
      } finally {
        rs.close()
      }
    } catch (error) {
      console.error('[MusicRepository] getCount failed:', String(error))
      return 0
    }
  }

  private async queryAll(store: relationalStore.RdbStore): Promise<MusicSongEntity[]> {
    try {
      const rs = await store.querySql(
        `SELECT id, title, singer, url, cover, lyric, isFavorite, createTime FROM ${MusicDatabase.TABLE_NAME} ORDER BY createTime ASC`
      )
      return this.readResultSet(rs)
    } catch (error) {
      console.error('[MusicRepository] queryAll failed:', String(error))
      return []
    }
  }

  private async queryByFavorite(store: relationalStore.RdbStore, favorite: number): Promise<MusicSongEntity[]> {
    try {
      const rs = await store.querySql(
        `SELECT id, title, singer, url, cover, lyric, isFavorite, createTime FROM ${MusicDatabase.TABLE_NAME} WHERE isFavorite = ? ORDER BY createTime ASC`,
        [String(favorite)]
      )
      return this.readResultSet(rs)
    } catch (error) {
      console.error('[MusicRepository] queryByFavorite failed:', String(error))
      return []
    }
  }

  private async queryOne(store: relationalStore.RdbStore, id: string): Promise<MusicSongEntity | undefined> {
    try {
      const rs = await store.querySql(
        `SELECT id, title, singer, url, cover, lyric, isFavorite, createTime FROM ${MusicDatabase.TABLE_NAME} WHERE id = ? LIMIT 1`,
        [id]
      )
      const list = this.readResultSet(rs)
      return list.length > 0 ? list[0] : undefined
    } catch (error) {
      console.error('[MusicRepository] queryOne failed:', String(error))
      return undefined
    }
  }

  private async insertSongInternal(store: relationalStore.RdbStore, song: MusicSongEntity): Promise<number> {
    try {
      const values: relationalStore.ValuesBucket = {
        id: song.id,
        title: song.title,
        singer: song.singer,
        url: song.url,
        cover: song.cover,
        lyric: song.lyric,
        isFavorite: song.isFavorite,
        createTime: song.createTime
      }
      return await store.insert(MusicDatabase.TABLE_NAME, values)
    } catch (error) {
      console.error('[MusicRepository] insertSongInternal failed:', String(error))
      throw new Error(String(error))
    }
  }

  private async updateSongInternal(store: relationalStore.RdbStore, song: MusicSongEntity): Promise<number> {
    try {
      const values: relationalStore.ValuesBucket = {
        title: song.title,
        singer: song.singer,
        url: song.url,
        cover: song.cover,
        lyric: song.lyric,
        isFavorite: song.isFavorite,
        createTime: song.createTime
      }
      const predicates = new relationalStore.RdbPredicates(MusicDatabase.TABLE_NAME)
      predicates.equalTo('id', song.id)
      return await store.update(values, predicates)
    } catch (error) {
      console.error('[MusicRepository] updateSongInternal failed:', String(error))
      throw new Error(String(error))
    }
  }

  private async insertOrReplace(store: relationalStore.RdbStore, song: MusicSongEntity): Promise<number> {
    const existing = await this.queryOne(store, song.id)
    if (existing) {
      return await this.updateSongInternal(store, song)
    }
    return await this.insertSongInternal(store, song)
  }

  private readResultSet(resultSet: relationalStore.ResultSet): MusicSongEntity[] {
    const songs: MusicSongEntity[] = []
    try {
      if (!resultSet.goToFirstRow()) {
        return songs
      }

      do {
        songs.push({
          id: resultSet.getString(resultSet.getColumnIndex('id')),
          title: resultSet.getString(resultSet.getColumnIndex('title')),
          singer: resultSet.getString(resultSet.getColumnIndex('singer')),
          url: resultSet.getString(resultSet.getColumnIndex('url')),
          cover: resultSet.getString(resultSet.getColumnIndex('cover')),
          lyric: resultSet.getString(resultSet.getColumnIndex('lyric')),
          isFavorite: resultSet.getLong(resultSet.getColumnIndex('isFavorite')),
          createTime: resultSet.getLong(resultSet.getColumnIndex('createTime'))
        })
      } while (resultSet.goToNextRow())
    } finally {
      resultSet.close()
    }

    return songs
  }

  private mapEntityToSongItem(entity: MusicSongEntity): SongItemType {
    return {
      id: entity.id,
      name: entity.title,
      author: entity.singer,
      url: entity.url,
      img: entity.cover,
      lyric: entity.lyric,
      isFavorite: entity.isFavorite === 1,
      createTime: entity.createTime,
      title: entity.title,
      singer: entity.singer,
      cover: entity.cover
    }
  }

  private mapEntitiesToSongItems(entities: MusicSongEntity[]): SongItemType[] {
    return entities.map((entity: MusicSongEntity) => this.mapEntityToSongItem(entity))
  }
}

export const musicRepository = new MusicRepository()
