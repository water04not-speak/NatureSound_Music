import relationalStore from '@ohos.data.relationalStore';
import common from '@ohos.app.ability.common';

const DB_NAME = 'MusicDatabase.db';
const TABLE_NAME = 'Music';

const CREATE_TABLE_SQL = `CREATE TABLE IF NOT EXISTS ${TABLE_NAME} (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  singer TEXT NOT NULL,
  url TEXT NOT NULL,
  cover TEXT,
  lyric TEXT,
  isFavorite INTEGER DEFAULT 0,
  createTime INTEGER DEFAULT (strftime('%s', 'now'))
)`;

export interface MusicRecord {
  id: number;
  title: string;
  singer: string;
  url: string;
  cover: string;
  lyric: string;
  isFavorite: number;
  createTime: number;
}

export interface InsertMusicData {
  title: string;
  singer: string;
  url: string;
  cover?: string;
  lyric?: string;
  isFavorite?: number;
}

export class RelationalStoreHelper {
  private static instance: RelationalStoreHelper;
  private rdbStore: relationalStore.RdbStore | null = null;

  private constructor() {}

  static getInstance(): RelationalStoreHelper {
    if (!RelationalStoreHelper.instance) {
      RelationalStoreHelper.instance = new RelationalStoreHelper();
    }
    return RelationalStoreHelper.instance;
  }

  async initDatabase(context: common.Context): Promise<void> {
    if (this.rdbStore) {
      return;
    }
    const config: relationalStore.StoreConfig = {
      name: DB_NAME,
      securityLevel: relationalStore.SecurityLevel.S1,
    };
    this.rdbStore = await relationalStore.getRdbStore(context, config);
    await this.rdbStore.executeSql(CREATE_TABLE_SQL);
  }

  async insertMusic(data: InsertMusicData): Promise<number> {
    if (!this.rdbStore) {
      throw new Error('Database not initialized');
    }
    const values: relationalStore.ValuesBucket = {
      title: data.title,
      singer: data.singer,
      url: data.url,
      cover: data.cover ?? null,
      lyric: data.lyric ?? null,
      isFavorite: data.isFavorite ?? 0,
    };
    return await this.rdbStore.insert(TABLE_NAME, values);
  }

  async queryAllMusic(): Promise<Array<MusicRecord>> {
    if (!this.rdbStore) {
      throw new Error('Database not initialized');
    }
    const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    const resultSet = await this.rdbStore.query(predicates);
    const results: Array<MusicRecord> = [];
    while (resultSet.goToNextRow()) {
      results.push({
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        title: resultSet.getString(resultSet.getColumnIndex('title')),
        singer: resultSet.getString(resultSet.getColumnIndex('singer')),
        url: resultSet.getString(resultSet.getColumnIndex('url')),
        cover: resultSet.getString(resultSet.getColumnIndex('cover')),
        lyric: resultSet.getString(resultSet.getColumnIndex('lyric')),
        isFavorite: resultSet.getLong(resultSet.getColumnIndex('isFavorite')),
        createTime: resultSet.getLong(resultSet.getColumnIndex('createTime')),
      });
    }
    resultSet.close();
    return results;
  }

  async updateFavoriteStatus(id: number, isFavorite: number): Promise<void> {
    if (!this.rdbStore) {
      throw new Error('Database not initialized');
    }
    const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo('id', id);
    const values: relationalStore.ValuesBucket = { isFavorite };
    await this.rdbStore.update(values, predicates);
  }

  async deleteMusic(id: number): Promise<void> {
    if (!this.rdbStore) {
      throw new Error('Database not initialized');
    }
    const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo('id', id);
    await this.rdbStore.delete(predicates);
  }
}