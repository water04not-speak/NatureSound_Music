import { RdbStore, RdbOpenCallback, RdbPredicates, RdbStoreConfig } from '@ohos.data.rdb';

const DB_NAME = 'MusicDatabase';
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

export class RelationalStoreHelper {
  private static instance: RelationalStoreHelper;
  private rdbStore: RdbStore | null = null;

  private constructor() {}

  static getInstance(): RelationalStoreHelper {
    if (!RelationalStoreHelper.instance) {
      RelationalStoreHelper.instance = new RelationalStoreHelper();
    }
    return RelationalStoreHelper.instance;
  }

  async initDatabase(): Promise<void> {
    const config: RdbStoreConfig = {
      name: DB_NAME,
    };
    const rdbOpenCallback: RdbOpenCallback = {
      onCreate: (db: RdbStore) => {
        db.executeSql(CREATE_TABLE_SQL, []);
      },
      onUpgrade: (db: RdbStore, oldVersion: number, newVersion: number) => {
        // Handle database upgrade logic if needed
      },
    };
    this.rdbStore = await RdbStore.getRdbStore(globalThis.getContext(), config, 1, rdbOpenCallback);
  }

  async insertMusic(data: { title: string; singer: string; url: string; cover?: string; lyric?: string; isFavorite?: number }): Promise<number> {
    if (!this.rdbStore) {
      throw new Error('Database not initialized');
    }
    const values = {
      title: data.title,
      singer: data.singer,
      url: data.url,
      cover: data.cover || null,
      lyric: data.lyric || null,
      isFavorite: data.isFavorite || 0,
    };
    return await this.rdbStore.insert(TABLE_NAME, values);
  }

  async queryAllMusic(): Promise<Array<any>> {
    if (!this.rdbStore) {
      throw new Error('Database not initialized');
    }
    const predicates = new RdbPredicates(TABLE_NAME);
    const resultSet = await this.rdbStore.query(predicates);
    const results: Array<any> = [];
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
    const predicates = new RdbPredicates(TABLE_NAME);
    predicates.equalTo('id', id);
    const values = { isFavorite };
    await this.rdbStore.update(values, predicates);
  }

  async deleteMusic(id: number): Promise<void> {
    if (!this.rdbStore) {
      throw new Error('Database not initialized');
    }
    const predicates = new RdbPredicates(TABLE_NAME);
    predicates.equalTo('id', id);
    await this.rdbStore.delete(predicates);
  }
}