import { sensor } from '@kit.SensorServiceKit';
import { PeriodService } from './PeriodService';
import { HabitType } from '../models/HabitModel';

@ObservedV2
export class SensorTrackingService {
  private static _instance: SensorTrackingService;
  private periodService = PeriodService.instance;
  private isTracking: boolean = false;
  @Trace currentSteps: number = 0;

  private constructor() {
  }

  static get instance(): SensorTrackingService {
    if (!SensorTrackingService._instance) {
      SensorTrackingService._instance = new SensorTrackingService();
    }
    return SensorTrackingService._instance;
  }

  startTracking() {
    if (this.isTracking) {
      return;
    }
    this.isTracking = true;

    try {
      sensor.on(sensor.SensorId.PEDOMETER, (data) => {
        this.currentSteps = data.steps;
        this.checkHabitCompletion();
      }, { interval: 1000000000 });

      console.info('Pedometer tracking started');
    } catch (err) {
      console.error('Failed to start pedometer:', err);
    }
  }

  stopTracking() {
    if (!this.isTracking) {
      return;
    }
    this.isTracking = false;
    try {
      sensor.off(sensor.SensorId.PEDOMETER);
    } catch (err) {
      console.error('Failed to stop pedometer:', err);
    }
  }

  private checkHabitCompletion() {
    this.periodService.periods.forEach(period => {
      period.habits.forEach(habit => {
        if (!habit.completed && habit.type === HabitType.STEPS) {
          if (this.currentSteps >= habit.targetValue) {
            this.periodService.toggleHabitCompletion(period.id, habit.id);
            console.info(`Auto-completed: ${habit.title} at ${this.currentSteps} steps`);
          }
        }
      });
    });
  }
}