export enum HabitType {
  NORMAL = 'normal',
  BREATHING = 'breathing',
  STEPS = 'steps'
}

@ObservedV2
export class HabitModel {
  @Trace id: number;
  @Trace title: string;
  @Trace time: string;
  @Trace color: string;
  @Trace completed: boolean;
  @Trace type: HabitType;
  @Trace targetValue: number;

  constructor(
    id: number,
    title: string,
    time: string,
    color: string,
    completed: boolean = false,
    type: HabitType = HabitType.NORMAL,
    targetValue: number = 0
  ) {
    this.id = id;
    this.title = title;
    this.time = time;
    this.color = color;
    this.completed = completed;
    this.type = type;
    this.targetValue = targetValue;
  }
}