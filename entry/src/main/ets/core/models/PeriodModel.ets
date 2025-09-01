import { RitualModel } from './RitualModel';

@ObservedV2
export class PeriodModel {
  @Trace id: number;
  @Trace title: string;
  @Trace time: string;
  @Trace color: string;
  @Trace rituals: RitualModel[];

  get progress(): number {
    if (this.rituals.length === 0) { return 0 };
    const completedCount = this.rituals.filter(r => r.completed).length;
    return Math.round((completedCount / this.rituals.length) * 100);
  }

  get completed(): boolean {
    return this.progress === 100;
  }

  constructor(
    id: number,
    title: string,
    time: string,
    color: string,
    rituals: RitualModel[] = []
  ) {
    this.id = id;
    this.title = title;
    this.time = time;
    this.color = color;
    this.rituals = rituals;
  }
}
