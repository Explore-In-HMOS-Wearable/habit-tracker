import { PeriodModel } from '../models/PeriodModel';
import { HabitModel, HabitType } from '../models/HabitModel';
import { DatabaseService } from './DatabaseService';
import { hilog } from '@kit.PerformanceAnalysisKit';
import GlobalContext from '../utils/GlobalContext';

const TAG = 'PeriodService';
const DOMAIN = 0x0001;

export interface HabitInput {
  title: string;
  time: string;
  color: string;
  type?: HabitType;
  targetValue?: number;
}

@ObservedV2
export class PeriodService {
  @Trace periods: PeriodModel[] = [];
  @Trace isLoaded: boolean = false;
  private static _instance: PeriodService;
  private initializationPromise: Promise<void> | null = null;

  private constructor() {
  }

  static get instance(): PeriodService {
    if (!PeriodService._instance) {
      PeriodService._instance = new PeriodService();
    }
    return PeriodService._instance;
  }

  private getString(resource: Resource): string {
    const context = GlobalContext.getInstance().getCntx();
    if (context) {
      try {
        return context.resourceManager.getStringSync(resource.id);
      } catch (e) {
        hilog.error(DOMAIN, TAG, 'Failed to get string resource');
      }
    }
    return '';
  }

  async initializeData(): Promise<void> {
    if (this.isLoaded) {
      return;
    }
    if (this.initializationPromise) {
      await this.initializationPromise;
      return;
    }
    this.initializationPromise = this._doInitialize();
    await this.initializationPromise;
  }

  private async _doInitialize(): Promise<void> {
    try {
      hilog.info(DOMAIN, TAG, 'Initializing data...');
      const db = DatabaseService.instance;
      if (!db) {
        hilog.error(DOMAIN, TAG, 'DatabaseService instance is null');
        this._loadFallbackData();
        return;
      }

      let p1 = await db.loadHabits(1);
      let p2 = await db.loadHabits(2);
      let p3 = await db.loadHabits(3);

      if (p1.length === 0 && p2.length === 0 && p3.length === 0) {
        hilog.info(DOMAIN, TAG, 'DB is empty, loading default data');
        const defaultPeriods = this._getDefaultData();
        for (const p of defaultPeriods) {
          for (const h of p.habits) {
            const dbId = await db.saveHabit(p.id, h);
            h.id = dbId;
          }
        }
        this.periods = defaultPeriods;
      } else {
        hilog.info(DOMAIN, TAG, 'Data loaded from DB');
        this.periods = [
          new PeriodModel(1,
            this.getString($r('app.string.morning_ritual')),
            this.getString($r('app.string.morning_time')),
            '#4ea5d7', p1),
          new PeriodModel(2,
            this.getString($r('app.string.afternoon_ritual')),
            this.getString($r('app.string.afternoon_time')),
            '#c8b049', p2),
          new PeriodModel(3,
            this.getString($r('app.string.evening_ritual')),
            this.getString($r('app.string.evening_time')),
            '#1a365c', p3)
        ];
      }
      this.isLoaded = true;
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'Failed to initialize: %{public}s', JSON.stringify(err));
      this._loadFallbackData();
    }
  }

  private _loadFallbackData(): void {
    this.periods = this._getDefaultData();
    this.isLoaded = true;
  }

  private _getDefaultData(): PeriodModel[] {
    return [
      new PeriodModel(1,
        this.getString($r('app.string.morning_ritual')),
        this.getString($r('app.string.morning_time')),
        '#4ea5d7', [
          new HabitModel(1,
            this.getString($r('app.string.default_drink_water')),
            this.getString($r('app.string.default_drink_water_time')),
            '#4ea5d7', false),
          new HabitModel(2,
            this.getString($r('app.string.default_morning_breath')),
            this.getString($r('app.string.default_morning_breath_time')),
            '#4ea5d7', false, HabitType.BREATHING, 180),
          new HabitModel(3,
            this.getString($r('app.string.default_quick_walk')),
            this.getString($r('app.string.default_quick_walk_time')),
            '#4ea5d7', false, HabitType.STEPS, 500)
        ]),
      new PeriodModel(2,
        this.getString($r('app.string.afternoon_ritual')),
        this.getString($r('app.string.afternoon_time')),
        '#c8b049', [
          new HabitModel(4,
            this.getString($r('app.string.default_short_walk')),
            this.getString($r('app.string.default_short_walk_time')),
            '#c8b049', false, HabitType.STEPS, 1000),
          new HabitModel(5,
            this.getString($r('app.string.default_healthy_lunch')),
            this.getString($r('app.string.default_healthy_lunch_time')),
            '#c8b049', false)
        ]),
      new PeriodModel(3,
        this.getString($r('app.string.evening_ritual')),
        this.getString($r('app.string.evening_time')),
        '#1a365c', [
          new HabitModel(6,
            this.getString($r('app.string.default_read_book')),
            this.getString($r('app.string.default_read_book_time')),
            '#1a365c', false),
          new HabitModel(7,
            this.getString($r('app.string.default_evening_meditate')),
            this.getString($r('app.string.default_evening_meditate_time')),
            '#1a365c', false, HabitType.BREATHING, 600)
        ])
    ];
  }

  async toggleHabitCompletion(periodId: number, habitId: number): Promise<void> {
    const period = this.periods.find(p => p.id === periodId);
    if (!period) {
      return;
    }
    const habit = period.habits.find(h => h.id === habitId);
    if (!habit) {
      return;
    }
    habit.completed = !habit.completed;
    try {
      await DatabaseService.instance.updateHabit(habit);
    } catch (e) {
      hilog.error(DOMAIN, TAG, 'DB Update failed: %{public}s', JSON.stringify(e));
    }
    this.periods = [...this.periods];
  }

  getPeriodById(id: number): PeriodModel | undefined {
    return this.periods.find(period => period.id === id);
  }

  async addHabit(periodId: number, input: HabitInput): Promise<void> {
    const period = this.periods.find(p => p.id === periodId);
    if (!period) {
      return;
    }
    const tempHabit = new HabitModel(
      0,
      input.title,
      input.time,
      input.color,
      false,
      input.type ?? HabitType.NORMAL,
      input.targetValue ?? 0
    );
    try {
      const newId = await DatabaseService.instance.saveHabit(periodId, tempHabit);
      tempHabit.id = newId;
    } catch (e) {
      hilog.error(DOMAIN, TAG, 'Failed to save new habit: %{public}s', JSON.stringify(e));
      const maxId = period.habits.reduce((max: number, h: HabitModel) => Math.max(max, h.id), 0);
      tempHabit.id = maxId + 1;
    }
    period.habits.push(tempHabit);
    this.periods = [...this.periods];
  }
}