import { HabitModel } from './HabitModel';

@ObservedV2
export class PeriodModel {
  @Trace id: number;
  @Trace title: string;
  @Trace time: string;
  @Trace color: string;
  @Trace habits: HabitModel[];

  get progress(): number {
    if (this.habits.length === 0) {
      return 0;
    }
    const completedCount = this.habits.filter(h => h.completed).length;
    return Math.round((completedCount / this.habits.length) * 100);
  }

  get completed(): boolean {
    return this.progress === 100;
  }

  constructor(
    id: number,
    title: string,
    time: string,
    color: string,
    habits: HabitModel[] = []
  ) {
    this.id = id;
    this.title = title;
    this.time = time;
    this.color = color;
    this.habits = habits;
  }
}