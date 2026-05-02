import GlobalContext from '../utils/GlobalContext';

function getString(resource: Resource): string {
  const context = GlobalContext.getInstance().getCntx();
  if (context) {
    try {
      return context.resourceManager.getStringSync(resource.id);
    } catch (e) {
      return '';
    }
  }
  return '';
}

export interface Habit {
  id: number;
  title: string;
  time: string;
  color: string;
  completed: boolean;
}

export interface Period {
  title: string;
  time: string;
  color: string;
  progress: number;
  habits: Habit[];
  completed?: boolean;
}

@Observed
class PeriodStore {
  periods: Period[] = [];

  initialize(): void {
    this.periods = [
      {
        title: getString($r('app.string.morning_ritual')),
        time: getString($r('app.string.morning_time')),
        color: '#4ea5d7',
        progress: 0,
        habits: [
          {
            id: 1,
            title: getString($r('app.string.default_drink_water')),
            time: getString($r('app.string.default_drink_water_time')),
            color: '#4ea5d7',
            completed: false
          },
          {
            id: 2,
            title: 'Stretching',
            time: '00:10',
            color: '#4ea5d7',
            completed: false
          }
        ]
      },
      {
        title: getString($r('app.string.afternoon_ritual')),
        time: getString($r('app.string.afternoon_time')),
        color: '#c8b049',
        progress: 0,
        habits: [
          {
            id: 3,
            title: getString($r('app.string.default_short_walk')),
            time: getString($r('app.string.default_short_walk_time')),
            color: '#c8b049',
            completed: false
          },
          {
            id: 4,
            title: getString($r('app.string.default_healthy_lunch')),
            time: getString($r('app.string.default_healthy_lunch_time')),
            color: '#c8b049',
            completed: false
          }
        ]
      },
      {
        title: getString($r('app.string.evening_ritual')),
        time: getString($r('app.string.evening_time')),
        color: '#1a365c',
        progress: 0,
        habits: [
          {
            id: 5,
            title: getString($r('app.string.default_read_book')),
            time: getString($r('app.string.default_read_book_time')),
            color: '#1a365c',
            completed: false
          },
          {
            id: 6,
            title: getString($r('app.string.default_evening_meditate')),
            time: getString($r('app.string.default_evening_meditate_time')),
            color: '#1a365c',
            completed: false
          }
        ]
      }
    ];
  }

  updatePeriod(index: number, updated: Period): void {
    this.periods[index] = updated;
  }

  getPeriod(index: number): Period {
    return this.periods[index];
  }
}

const periodStore = new PeriodStore();

export default periodStore;