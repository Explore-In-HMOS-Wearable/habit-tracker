export interface Ritual {
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
  rituals: Ritual[];
  completed?: boolean;
}

@Observed
class PeriodStore {
  periods: Period[] = [
    {
      title: 'Morning Ritual',
      time: '10:00 AM',
      color: '#4ea5d7',
      progress: 0,
      rituals: [
        {
          id: 1,
          title: 'Drink water',
          time: '00:15',
          color: '#4ea5d7',
          completed: false,
        },
        {
          id: 2,
          title: 'Stretching',
          time: '00:10',
          color: '#4ea5d7',
          completed: false,
        },
      ],
    },
    {
      title: 'Afternoon Ritual',
      time: '1:00 PM',
      color: '#c8b049',
      progress: 0,
      rituals: [
        {
          id: 3,
          title: 'Short walk',
          time: '00:20',
          color: '#c8b049',
          completed: false,
        },
        {
          id: 4,
          title: 'Healthy lunch',
          time: '00:30',
          color: '#c8b049',
          completed: false,
        },
      ],
    },
    {
      title: 'Evening Ritual',
      time: '8:00 PM',
      color: '#1a365c',
      progress: 0,
      rituals: [
        {
          id: 5,
          title: 'Read a book',
          time: '00:20',
          color: '#1a365c',
          completed: false,
        },
        {
          id: 6,
          title: 'Meditate',
          time: '00:10',
          color: '#1a365c',
          completed: false,
        },
      ],
    },
  ];

  updatePeriod(index: number, updated: Period): void {
    console.info('index', index);
    console.info('updated', JSON.stringify(updated));
    this.periods[index] = updated;
  }

  getPeriod(index: number): Period {
    return this.periods[index];
  }
}

const periodStore = new PeriodStore();

export default periodStore;
