import { PeriodService } from '../core/services/PeriodService';
import { HabitType } from '../core/models/HabitModel';
import { vibrator } from '@kit.SensorServiceKit';
import { SensorTrackingService } from '../core/services/SensorTrackingService';

interface HabitDisplay {
  id: number;
  title: string;
  time: string;
  color: string;
  type: HabitType;
  targetValue: number;
}

@Component
export struct Period {
  @Consume('pageStack') pageStack: NavPathStack;
  private controller = PeriodService.instance;
  private sensorService: SensorTrackingService = SensorTrackingService.instance;
  @State periodId: number = -1;
  @State currentHabit: HabitDisplay | null = null;
  @State isFinished: boolean = false;
  private screenWidth: number = 0;
  private screenHeight: number = 0;
  @State isBreathing: boolean = false;
  @State breathTimer: number = 0;
  private breathIntervalId: number = -1;

  async aboutToAppear(): Promise<void> {
    try {
    } catch (err) {
      console.error('Failed to get display info:', err);
    }
  }

  aboutToDisappear() {
    this.stopBreathing();
  }

  private loadNextHabit(): void {
    const period = this.controller.getPeriodById(this.periodId);
    if (!period) {
      this.pageStack.pop();
      return;
    }
    const nextHabit = period.habits.find(h => !h.completed);
    if (nextHabit) {
      this.isFinished = false;
      this.currentHabit = {
        id: nextHabit.id,
        title: nextHabit.title,
        time: nextHabit.time,
        color: nextHabit.color,
        type: nextHabit.type,
        targetValue: nextHabit.targetValue
      };
      if (this.currentHabit.type === HabitType.BREATHING) {
        this.breathTimer = this.currentHabit.targetValue;
      }
    } else {
      this.currentHabit = null;
      this.isFinished = true;
    }
  }

  private skipCurrentHabit(): void {
    if (!this.currentHabit) {
      return;
    }
    this.stopBreathing();
    const period = this.controller.getPeriodById(this.periodId);
    if (!period) {
      this.pageStack.pop();
      return;
    }
    const currentIndex = period.habits.findIndex(h => h.id === this.currentHabit?.id);
    const nextHabit = period.habits.find((h, index) => index > currentIndex && !h.completed);
    if (nextHabit) {
      this.currentHabit = {
        id: nextHabit.id,
        title: nextHabit.title,
        time: nextHabit.time,
        color: nextHabit.color,
        type: nextHabit.type,
        targetValue: nextHabit.targetValue
      };
      if (this.currentHabit.type === HabitType.BREATHING) {
        this.breathTimer = this.currentHabit.targetValue;
      }
    } else {
      this.pageStack.pop();
    }
  }

  private completeCurrentHabit(): void {
    if (!this.currentHabit) {
      return;
    }
    this.stopBreathing();
    this.triggerHaptic();
    this.controller.toggleHabitCompletion(this.periodId, this.currentHabit.id);
    this.loadNextHabit();
  }

  private startBreathing() {
    if (!this.currentHabit || this.isBreathing) {
      return;
    }
    this.isBreathing = true;
    this.breathIntervalId = setInterval(() => {
      if (this.breathTimer > 0) {
        this.breathTimer--;
        if (this.breathTimer % 4 === 0) {
          this.triggerHaptic();
        }
      } else {
        this.completeCurrentHabit();
      }
    }, 1000);
  }

  private stopBreathing() {
    this.isBreathing = false;
    if (this.breathIntervalId !== -1) {
      clearInterval(this.breathIntervalId);
      this.breathIntervalId = -1;
    }
  }

  private triggerHaptic() {
    try {
      vibrator.startVibration({
        type: 'preset',
        effectId: 'haptic.clock.timer',
        count: 2
      }, { usage: 'alarm' });
    } catch (err) {
      console.error('Haptic failed:', err);
    }
  }

  private baseSize(): number {
    return Math.min(this.screenWidth || 200, this.screenHeight || 200);
  }

  @Builder
  private renderBreathingUI() {
    Column() {
      Stack() {
        Progress({ value: this.breathTimer, total: this.currentHabit?.targetValue || 100, type: ProgressType.Ring })
          .width(this.baseSize() * 0.55)
          .height(this.baseSize() * 0.55)
          .style({ strokeWidth: 8 })
          .color(this.currentHabit?.color || Color.Blue)
          .backgroundColor($r('app.color.progress_bg'))

        Column() {
          Text(`${this.breathTimer}s`)
            .fontSize(this.baseSize() * 0.12)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
          Text(this.isBreathing ? $r('app.string.breathing_active') : $r('app.string.breathing_ready'))
            .fontSize(this.baseSize() * 0.04)
            .fontColor($r('app.color.text_tertiary'))
        }
      }
      .margin({ top: 10, bottom: 20 })

      Button(this.isBreathing ? $r('app.string.btn_pause') : $r('app.string.btn_start'))
        .onClick(() => this.isBreathing ? this.stopBreathing() : this.startBreathing())
        .width('55%')
        .height(this.baseSize() * 0.15)
        .borderRadius(this.baseSize() * 0.08)
        .backgroundColor(this.isBreathing ? $r('app.color.btn_disabled') : Color.Green)
    }
  }

  build() {
    NavDestination() {
      Column() {
        if (this.isFinished) {
          Column() {
            Text($r('app.string.rituals_complete'))
              .fontSize(this.baseSize() * 0.08)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.Green)
              .textAlign(TextAlign.Center)

            Text($r('app.string.excellent_progress'))
              .fontSize(this.baseSize() * 0.04)
              .fontColor($r('app.color.text_tertiary'))
              .margin({ top: 8, bottom: 30 })

            Button($r('app.string.btn_finish'))
              .onClick(() => this.pageStack.pop())
              .backgroundColor($r('app.color.dark_bg'))
              .width('50%')
              .borderRadius(20)
          }
          .padding(20)
        } else if (this.currentHabit) {
          Text(this.currentHabit.title)
            .fontSize(this.baseSize() * 0.07)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .margin({ top: 10 })

          if (this.currentHabit.type === HabitType.BREATHING) {
            this.renderBreathingUI();
          } else if (this.currentHabit.type === HabitType.STEPS) {
            Column() {
              Stack() {
                Progress({
                  value: Math.min(this.sensorService.currentSteps, this.currentHabit.targetValue),
                  total: this.currentHabit.targetValue,
                  type: ProgressType.Ring
                })
                  .width(this.baseSize() * 0.55)
                  .height(this.baseSize() * 0.55)
                  .style({ strokeWidth: 8 })
                  .color(this.currentHabit.color)
                  .backgroundColor($r('app.color.progress_bg'))

                Column() {
                  Text(`${this.sensorService.currentSteps}`)
                    .fontSize(this.baseSize() * 0.10)
                    .fontColor(Color.White)
                    .fontWeight(FontWeight.Bold)
                  Text(`/ ${this.currentHabit.targetValue}`)
                    .fontSize(this.baseSize() * 0.04)
                    .fontColor($r('app.color.text_secondary'))
                }
              }
              .margin({ top: 10, bottom: 10 })

              Text($r('app.string.label_steps'))
                .fontSize(this.baseSize() * 0.04)
                .fontColor($r('app.color.text_tertiary'))
                .margin({ bottom: 20 })

              Row() {
                Button($r('app.string.btn_skip'))
                  .onClick(() => {
                    this.skipCurrentHabit();
                  })
                  .backgroundColor($r('app.color.dark_bg'))
                  .width('42%')
              }
              .width('95%')
              .justifyContent(FlexAlign.Center)
            }
          } else {
            Column() {
              Text(this.currentHabit.time)
                .fontSize(this.baseSize() * 0.06)
                .fontColor(this.currentHabit.color)
                .fontWeight(FontWeight.Medium)
                .margin({ top: 40, bottom: 40 })

              Row() {
                Button($r('app.string.btn_skip'))
                  .onClick(() => {
                    this.skipCurrentHabit();
                  })
                  .backgroundColor($r('app.color.dark_bg'))
                  .width('42%')

                Button($r('app.string.btn_done'))
                  .onClick(() => {
                    this.completeCurrentHabit();
                  })
                  .backgroundColor(Color.Green)
                  .width('42%')
              }
              .margin({ bottom: 8 })
              .width('95%')
              .justifyContent(FlexAlign.SpaceEvenly)
            }
          }
        }
      }
      .width('95%')
      .height('95%')
      .justifyContent(FlexAlign.Center)
    }
    .onReady((ctx: NavDestinationContext) => {
      this.pageStack = ctx.pathStack;
      this.periodId = ctx.pathInfo.param as number;
      this.loadNextHabit();
    })
    .hideBackButton(true)
  }
}