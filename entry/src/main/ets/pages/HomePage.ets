import { PeriodModel } from '../core/models/PeriodModel';
import { PeriodService } from '../core/services/PeriodService';
import display from '@ohos.display';

class PeriodDataSource implements IDataSource {
  private data: PeriodModel[] = [];
  private listeners: DataChangeListener[] = [];

  constructor(data: PeriodModel[]) {
    this.data = data || [];
  }

  totalCount(): number {
    return this.data.length;
  }

  getData(index: number): PeriodModel {
    return this.data[index];
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      this.listeners.splice(pos, 1);
    }
  }

  notifyDataReload(): void {
    this.listeners.forEach(listener => listener.onDataReloaded());
  }

  notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => listener.onDataAdd(index));
  }

  notifyDataChange(index: number): void {
    this.listeners.forEach(listener => listener.onDataChange(index));
  }

  notifyDataDelete(index: number): void {
    this.listeners.forEach(listener => listener.onDataDelete(index));
  }
}

@Component
export struct HomePage {
  @Consume('pageStack') pageStack: NavPathStack;
  private controller = PeriodService.instance;
  @State periodsProgress: number[] = [0, 0, 0];
  private periodsDataSource: PeriodDataSource = new PeriodDataSource(this.controller.periods);
  @State screenWidth: number = 0;
  @State screenHeight: number = 0;
  private morningGradientColor: LinearGradient = new LinearGradient([
    { color: Color.Yellow, offset: 0.5 },
    { color: Color.Orange, offset: 1.0 }
  ]);
  private afternoonGradientColor: LinearGradient = new LinearGradient([
    { color: Color.Pink, offset: 0.5 },
    { color: Color.Red, offset: 1.0 }
  ]);
  private eveningGradientColor: LinearGradient = new LinearGradient([
    { color: Color.Blue, offset: 0.5 },
    { color: Color.Black, offset: 1.0 }
  ]);

  async aboutToAppear() {
    this.updateDataSource();
    this.updateProgress();
    try {
      const defaultDisplay = await display.getDefaultDisplaySync();
      this.screenWidth = defaultDisplay.width;
      this.screenHeight = defaultDisplay.height;
    } catch (err) {
      console.error('Failed to get display info:', err);
    }
  }

  onPageShow() {
    this.updateDataSource();
    this.updateProgress();
  }

  private updateDataSource() {
    this.periodsDataSource = new PeriodDataSource(this.controller.periods);
  }

  private updateProgress() {
    this.periodsProgress = [
      this.calculateProgress(0),
      this.calculateProgress(1),
      this.calculateProgress(2)
    ];
  }

  private calculateProgress(index: number): number {
    const period = this.controller.periods[index];
    if (!period || period.rituals.length === 0) {
      return 0;
    }
    const completedCount = period.rituals.filter(r => r.completed).length;
    return Math.round((completedCount / period.rituals.length) * 100);
  }

  private baseSize(): number {
    if (this.screenWidth === 0 || this.screenHeight === 0) {
      return 200;
    }
    return Math.min(this.screenWidth, this.screenHeight);
  }

  private progressSize(): number {
    return this.baseSize() * 0.16;
  }

  private progressStroke(): number {
    return this.baseSize() * 0.025;
  }

  private fontSmall(): number {
    return this.baseSize() * 0.04;
  }

  private fontMedium(): number {
    return this.baseSize() * 0.05;
  }

  @Builder
  private buildHeader() {
    Column() {
      if (this.periodsProgress.every(p => p === 100)) {
        Row() {
          Text('✅ All periods completed!')
            .fontSize(this.fontMedium())
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.Green)
            .padding({ top: 20, bottom: 6 });
        }
        .justifyContent(FlexAlign.Center)
        .margin({ bottom: 6 });
      }
    }
    .margin({ bottom: 8 });
  }

  @Builder
  private buildProgressRings() {
    Column() {
      Column() {
        Progress({ value: this.periodsProgress[0], total: 100, type: ProgressType.Ring })
          .width(this.progressSize())
          .height(this.progressSize())
          .style({ strokeWidth: this.progressStroke() })
          .color(this.morningGradientColor)
          .backgroundColor('#F0F0F0')
        Text(`Morning ${this.periodsProgress[0]}%`)
          .fontSize(this.fontSmall())
          .margin({ top: 2 })
          .fontColor('#000')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)

      Row() {
        Column() {
          Progress({ value: this.periodsProgress[1], total: 100, type: ProgressType.Ring })
            .width(this.progressSize())
            .height(this.progressSize())
            .style({ strokeWidth: this.progressStroke() })
            .color(this.afternoonGradientColor)
            .backgroundColor('#F0F0F0')
          Text(`Afternoon ${this.periodsProgress[1]}%`)
            .fontSize(this.fontSmall())
            .margin({ top: 2 })
            .fontColor('#000')
        }
        .width('50%')
        .alignItems(HorizontalAlign.Center)

        Column() {
          Progress({ value: this.periodsProgress[2], total: 100, type: ProgressType.Ring })
            .width(this.progressSize())
            .height(this.progressSize())
            .style({ strokeWidth: this.progressStroke() })
            .color(this.eveningGradientColor)
            .backgroundColor('#F0F0F0')
          Text(`Evening ${this.periodsProgress[2]}%`)
            .fontSize(this.fontSmall())
            .margin({ top: 2 })
            .fontColor('#000')
        }
        .width('50%')
        .alignItems(HorizontalAlign.Center)
      }
      .margin({ bottom: 8 })

      Row() {
        Text('Lets close all the rituals of the day! 💪')
          .fontSize(this.fontMedium())
          .fontColor('#000')
          .fontWeight(FontWeight.Bold)
      }
      .justifyContent(FlexAlign.Center)
    }
    .margin({ bottom: 8 })
  }

  @Builder
  private buildPeriodsList() {
    Column() {
      LazyForEach(
        this.periodsDataSource,
        (period: PeriodModel) => {
          Row() {
            Column() {
              Text(period.title)
                .fontSize(this.fontSmall())
                .fontColor('#FFF');
              Text(period.time)
                .fontSize(this.fontMedium())
                .fontColor('#FFF');
            }
            .height('100%');
          }
          .width('100%')
          .height(this.baseSize() * 0.14)
          .margin(3)
          .padding(6)
          .borderRadius(10)
          .backgroundColor(period.color)
          .onClick(() => {
            this.pageStack.pushPathByName('Period', period.id);
          });
        },
        (period: PeriodModel) => period.id.toString()
      );
    }
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          this.buildHeader();
          this.buildProgressRings();
          this.buildPeriodsList();
        }
      }
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Off)
      .width('100%')
      .height('100%')
      .backgroundColor('#FFF')
      .padding({
        top: 8,
        bottom: 16,
        left: 12,
        right: 12
      });
    }.onReady((ctx: NavDestinationContext) => {
      this.pageStack = ctx.pathStack;
    })
    .hideBackButton(true)
  }
}