@ObservedV2
export class RitualModel {
  @Trace id: number;
  @Trace title: string;
  @Trace time: string;
  @Trace color: string;
  @Trace completed: boolean;

  constructor(
    id: number,
    title: string,
    time: string,
    color: string,
    completed: boolean = false
  ) {
    this.id = id;
    this.title = title;
    this.time = time;
    this.color = color;
    this.completed = completed;
  }
}

