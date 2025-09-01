import { PeriodModel } from '../models/PeriodModel';
import { RitualModel } from '../models/RitualModel';

export interface RitualInput {
  title: string;
  time: string;
  color: string;
}

@ObservedV2
export class PeriodService {
  @Trace periods: PeriodModel[] = [];
  private static _instance: PeriodService;

  private constructor() {
    this.initializeSampleData();
  }

  static get instance(): PeriodService {
    if (!PeriodService._instance) {
      PeriodService._instance = new PeriodService();
    }
    return PeriodService._instance;
  }

  private initializeSampleData(): void {
    this.periods = [
      new PeriodModel(
        1,
        'Morning Ritual',
        '10:00 AM',
        '#4ea5d7',
        [
          new RitualModel(1, 'Drink water', '00:15', '#4ea5d7', true),
          new RitualModel(2, 'Stretching', '00:10', '#4ea5d7')
        ]
      ),
      new PeriodModel(
        2,
        'Afternoon Ritual',
        '1:00 PM',
        '#c8b049',
        [
          new RitualModel(3, 'Short walk', '00:20', '#c8b049'),
          new RitualModel(4, 'Healthy lunch', '00:30', '#c8b049', true)
        ]
      ),
      new PeriodModel(
        3,
        'Evening Ritual',
        '8:00 PM',
        '#1a365c',
        [
          new RitualModel(5, 'Read a book', '00:20', '#1a365c', true),
          new RitualModel(6, 'Meditate', '00:10', '#1a365c')
        ]
      )
    ];
  }

  getPeriods(): PeriodModel[] {
    return this.periods; // Returns the reactive array
  }

  // Ritual Management
  addRitual(periodId: number, ritual: RitualInput): void {
    const period = this.periods.find(p => p.id === periodId);
    if (period) {
      const newId = Math.max(0, ...period.rituals.map(r => r.id)) + 1;
      period.rituals = [
        ...period.rituals,
        new RitualModel(newId, ritual.title, ritual.time, ritual.color)
      ];
    }
  }

  toggleRitualCompletion(periodId: number, ritualId: number): void {
    const periodIndex = this.periods.findIndex(p => p.id === periodId);
    if (periodIndex === -1) { return };

    const ritualIndex = this.periods[periodIndex].rituals.findIndex(r => r.id === ritualId);
    if (ritualIndex === -1) { return };

    // Create new array with updated ritual
    const updatedRituals = [...this.periods[periodIndex].rituals];
    updatedRituals[ritualIndex] = new RitualModel(
      updatedRituals[ritualIndex].id,
      updatedRituals[ritualIndex].title,
      updatedRituals[ritualIndex].time,
      updatedRituals[ritualIndex].color,
      !updatedRituals[ritualIndex].completed // Toggle completion status
    );

    // Create new periods array with updated period
    const updatedPeriods = [...this.periods];
    updatedPeriods[periodIndex] = new PeriodModel(
      updatedPeriods[periodIndex].id,
      updatedPeriods[periodIndex].title,
      updatedPeriods[periodIndex].time,
      updatedPeriods[periodIndex].color,
      updatedRituals
    );

    this.periods = updatedPeriods; // Triggers reactive update
  }

  getPeriodById(id: number): PeriodModel | undefined {
    return this.periods.find(period => period.id === id);
  }

}