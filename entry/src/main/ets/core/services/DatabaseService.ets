import { relationalStore } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { HabitModel, HabitType } from '../models/HabitModel';

export class DatabaseService {
  private static _instance: DatabaseService;
  private rdbStore: relationalStore.RdbStore | null = null;
  private context: common.Context;

  private constructor(context: common.Context) {
    this.context = context;
  }

  static async init(context: common.Context): Promise<DatabaseService> {
    if (!DatabaseService._instance) {
      DatabaseService._instance = new DatabaseService(context);
      await DatabaseService._instance.getStore();
    }
    return DatabaseService._instance;
  }

  static get instance(): DatabaseService {
    return DatabaseService._instance;
  }

  private async getStore(): Promise<relationalStore.RdbStore> {
    if (this.rdbStore) {
      return this.rdbStore;
    }

    const STORE_CONFIG: relationalStore.StoreConfig = {
      name: 'HabitTracker.db',
      securityLevel: relationalStore.SecurityLevel.S1
    };

    const SQL_CREATE_TABLE = 'CREATE TABLE IF NOT EXISTS habit (' +
      'id INTEGER PRIMARY KEY AUTOINCREMENT, ' +
      'period_id INTEGER NOT NULL, ' +
      'title TEXT NOT NULL, ' +
      'time TEXT, ' +
      'color TEXT, ' +
      'completed INTEGER DEFAULT 0, ' +
      'type TEXT DEFAULT "normal", ' +
      'target_value INTEGER DEFAULT 0)';

    this.rdbStore = await relationalStore.getRdbStore(this.context, STORE_CONFIG);
    await this.rdbStore.executeSql(SQL_CREATE_TABLE);
    return this.rdbStore;
  }

  async saveHabit(periodId: number, habit: HabitModel): Promise<number> {
    const store = await this.getStore();
    const valueBucket: relationalStore.ValuesBucket = {
      'period_id': periodId,
      'title': habit.title,
      'time': habit.time,
      'color': habit.color,
      'completed': habit.completed ? 1 : 0,
      'type': habit.type,
      'target_value': habit.targetValue
    };
    const rowId = await store.insert('habit', valueBucket);
    habit.id = rowId;
    return rowId;
  }

  async updateHabit(habit: HabitModel): Promise<void> {
    const store = await this.getStore();
    const valueBucket: relationalStore.ValuesBucket = {
      'completed': habit.completed ? 1 : 0
    };
    const predicates = new relationalStore.RdbPredicates('habit');
    predicates.equalTo('id', habit.id);
    const rows = await store.update(valueBucket, predicates);
    console.error('TAG', 'updateHabit id=%{public}d completed=%{public}s affectedRows=%{public}d',
      habit.id, habit.completed ? 'true' : 'false', rows);
  }

  async loadHabits(periodId: number): Promise<HabitModel[]> {
    const store = await this.getStore();
    const predicates = new relationalStore.RdbPredicates('habit');
    predicates.equalTo('period_id', periodId);
    const resultSet = await store.query(predicates);
    const habits: HabitModel[] = [];
    while (resultSet.goToNextRow()) {
      habits.push(new HabitModel(
        resultSet.getLong(resultSet.getColumnIndex('id')),
        resultSet.getString(resultSet.getColumnIndex('title')),
        resultSet.getString(resultSet.getColumnIndex('time')),
        resultSet.getString(resultSet.getColumnIndex('color')),
        resultSet.getLong(resultSet.getColumnIndex('completed')) === 1,
        resultSet.getString(resultSet.getColumnIndex('type')) as HabitType,
        resultSet.getLong(resultSet.getColumnIndex('target_value'))
      ));
    }
    resultSet.close();
    return habits;
  }
}