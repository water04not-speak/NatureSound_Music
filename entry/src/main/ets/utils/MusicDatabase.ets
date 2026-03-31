import common from '@ohos.app.ability.common'
import relationalStore from '@ohos.data.relationalStore'

export class MusicDatabase {
  static readonly DB_NAME: string = 'nature_sound_music.rdb'
  static readonly TABLE_NAME: string = 'music_songs'

  private store?: relationalStore.RdbStore
  private initPromise?: Promise<relationalStore.RdbStore>

  async getStore(context: common.UIAbilityContext): Promise<relationalStore.RdbStore> {
    if (this.store) {
      return this.store
    }

    if (!this.initPromise) {
      this.initPromise = new Promise((resolve, reject) => {
        const config: relationalStore.StoreConfig = {
          name: MusicDatabase.DB_NAME,
          securityLevel: relationalStore.SecurityLevel.S1
        }

        relationalStore.getRdbStore(context, config, async (error, store) => {
          if (error) {
            this.initPromise = undefined
            reject(error)
            return
          }

          try {
            await store.executeSql(this.getCreateTableSql())
            await store.executeSql(this.getCreateIndexSql('idx_music_songs_create_time', 'createTime'))
            await store.executeSql(this.getCreateIndexSql('idx_music_songs_favorite_create_time', 'isFavorite, createTime'))
            this.store = store
            resolve(store)
          } catch (sqlError) {
            this.initPromise = undefined
            reject(sqlError)
          }
        })
      })
    }

    return await this.initPromise
  }

  private getCreateTableSql(): string {
    return `CREATE TABLE IF NOT EXISTS ${MusicDatabase.TABLE_NAME} (
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      singer TEXT NOT NULL,
      url TEXT NOT NULL,
      cover TEXT NOT NULL,
      lyric TEXT DEFAULT '',
      isFavorite INTEGER NOT NULL DEFAULT 0,
      createTime INTEGER NOT NULL
    )`
  }

  private getCreateIndexSql(indexName: string, columns: string): string {
    return `CREATE INDEX IF NOT EXISTS ${indexName} ON ${MusicDatabase.TABLE_NAME} (${columns})`
  }
}

export const musicDatabase = new MusicDatabase()
