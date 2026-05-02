import { PeriodModel } from '../core/models/PeriodModel';
import { PeriodService } from '../core/services/PeriodService';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Component
export struct HomePage {
  @Consume('pageStack') pageStack: NavPathStack;
  private controller: PeriodService = PeriodService.instance;
  private morningGradientColor: LinearGradient = new LinearGradient([
    { color: $r('app.color.morning_gradient_start'), offset: 0.0 },
    { color: $r('app.color.morning_color'), offset: 1.0 }
  ]);
  private afternoonGradientColor: LinearGradient = new LinearGradient([
    { color: $r('app.color.afternoon_gradient_start'), offset: 0.0 },
    { color: $r('app.color.afternoon_color'), offset: 1.0 }
  ]);
  private eveningGradientColor: LinearGradient = new LinearGradient([
    { color: $r('app.color.evening_gradient_start'), offset: 0.0 },
    { color: $r('app.color.evening_color'), offset: 1.0 }
  ]);

  async aboutToAppear() {
    hilog.info(0x0001, 'HomePage', 'aboutToAppear');
    try {
      setTimeout(() => {
        if (!this.controller.isLoaded) {
          hilog.warn(0x0001, 'HomePage', 'Loading timed out, forcing display');
          this.controller.isLoaded = true;
        }
      }, 3000);
      await this.controller.initializeData();
    } catch (err) {
      hilog.error(0x0001, 'HomePage', 'Error in aboutToAppear: %{public}s', JSON.stringify(err));
    }
  }

  private getPeriod(index: number): PeriodModel | undefined {
    return this.controller.periods[index];
  }

  private getProgress(index: number): number {
    const period = this.controller.periods[index];
    return period ? period.progress : 0;
  }

  @Builder
  private buildProgressRing(index: number, gradient: LinearGradient, label: string) {
    Column() {
      Stack() {
        Progress({ value: this.getProgress(index), total: 100, type: ProgressType.Ring })
          .width(50)
          .height(50)
          .style({ strokeWidth: 6 })
          .color(gradient)
          .backgroundColor($r('app.color.dark_bg'))

        Text(`${this.getProgress(index)}%`)
          .fontSize(14)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
      }
      .onClick(() => {
        const period = this.getPeriod(index);
        if (period) {
          this.pageStack.pushPathByName('Period', period.id);
        }
      })

      Text(label)
        .fontSize(14)
        .margin({ top: 4 })
        .fontColor($r('app.color.text_tertiary'))
    }
  }

  @Builder
  private buildPeriodCard(period: PeriodModel) {
    Row() {
      Column() {
        Text(period.title)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
        Text(period.time)
          .fontSize(13)
          .fontColor($r('app.color.text_dim'))
          .margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Circle({ width: 12, height: 12 })
        .fill(period.completed ? Color.Green : Color.Gray)
    }
    .width('92%')
    .padding(18)
    .margin({ bottom: 12 })
    .borderRadius(24)
    .backgroundColor($r('app.color.card_bg'))
    .onClick(() => {
      this.pageStack.pushPathByName('Period', period.id);
    })
  }

  build() {
    NavDestination() {
      Stack() {
        if (!this.controller.isLoaded) {
          Column() {
            LoadingProgress().width(50).height(50).color(Color.White)
            Text($r('app.string.syncing_habits'))
              .fontColor($r('app.color.text_muted'))
              .margin({ top: 10 })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .backgroundColor(Color.Black)
        } else {
          Scroll() {
            Column() {
              Blank().height(30)

              Column() {
                Text($r('app.string.app_title'))
                  .fontSize(20)
                  .fontColor($r('app.color.text_dim'))
                  .margin({ bottom: 10 })

                Column() {
                  this.buildProgressRing(0, this.morningGradientColor, 'Morning')
                }

                Row() {
                  this.buildProgressRing(1, this.afternoonGradientColor, 'Afternoon')
                  this.buildProgressRing(2, this.eveningGradientColor, 'Evening')
                }
                .width('100%')
                .justifyContent(FlexAlign.SpaceEvenly)
                .margin({ bottom: 25 })
              }

              ForEach(this.controller.periods, (period: PeriodModel) => {
                this.buildPeriodCard(period)
              }, (period: PeriodModel) => period.id.toString())

              Button('+')
                .onClick(() => {
                  this.pageStack.pushPathByName('AddHabit', null);
                })
                .width(50)
                .height(50)
                .borderRadius(25)
                .backgroundColor($r('app.color.btn_dark'))
                .fontColor(Color.White)
                .fontSize(24)
                .margin({ top: 8 })

              Blank().height(60)
            }
            .width('100%')
          }
          .width('100%')
          .height('100%')
          .backgroundColor(Color.Black)
          .scrollBar(BarState.Off)
        }
      }
    }
    .onReady((ctx: NavDestinationContext) => {
      this.pageStack = ctx.pathStack;
    })
    .hideBackButton(true)
  }
}