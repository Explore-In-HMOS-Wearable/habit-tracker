import { PeriodService } from '../core/services/PeriodService';
import display from '@ohos.display';

interface RitualDisplay {
  id: number;
  title: string;
  time: string;
  color: string;
}

@Component
export struct Period {
  @Consume('pageStack') pageStack: NavPathStack;
  private controller = PeriodService.instance;
  @State periodId: number = -1;
  @State currentRitual: RitualDisplay | null = null;
  @State showCompletionMessage: boolean = false;
  private screenWidth: number = 0;
  private screenHeight: number = 0;

  async aboutToAppear(): Promise<void> {
    try {
      const defaultDisplay = await display.getDefaultDisplaySync();
      this.screenWidth = defaultDisplay.width;
      this.screenHeight = defaultDisplay.height;
    } catch (err) {
      console.error('Failed to get display info:', err);
    }
  }

  private loadNextRitual(): void {
    const period = this.controller.getPeriodById(this.periodId);
    if (!period) {
      console.error('Period not found');
      this.pageStack.pop()
      return;
    }
    const nextRitual = period.rituals.find(r => !r.completed);
    this.showCompletionMessage = !nextRitual;
    if (nextRitual) {
      this.currentRitual = {
        id: nextRitual.id,
        title: nextRitual.title,
        time: nextRitual.time,
        color: nextRitual.color
      };
    } else {
      this.currentRitual = null;
    }
  }

  private completeCurrentRitual(): void {
    if (!this.currentRitual) {
      return;
    }
    this.controller.toggleRitualCompletion(this.periodId, this.currentRitual.id);
    this.loadNextRitual();
  }

  private baseSize(): number {
    if (this.screenWidth === 0 || this.screenHeight === 0) {
      return 200;
    }
    return Math.min(this.screenWidth, this.screenHeight);
  }

  private fontSmall(): number {
    return this.baseSize() * 0.045;
  }

  private fontMedium(): number {
    return this.baseSize() * 0.06;
  }

  private fontLarge(): number {
    return this.baseSize() * 0.08;
  }

  private buttonHeight(): number {
    return this.baseSize() * 0.12;
  }

  @Builder
  private renderCompletionButton() {
    Button() {
      Text('Complete ✅').fontSize(this.fontSmall());
    }
    .width('100%')
    .height(this.buttonHeight())
    .backgroundColor('#4CAF50')
    .onClick(() => this.completeCurrentRitual());
  }

  @Builder
  private renderBackButton() {
    Button() {
      Text('Back ↩️').fontSize(this.fontSmall());
    }
    .width('100%')
    .height(this.buttonHeight())
    .backgroundColor('#6c757d')
    .onClick(() => this.pageStack.pop());
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          if (this.showCompletionMessage) {
            Text('All rituals completed! 🎉')
              .fontSize(this.fontLarge())
              .fontColor('#28a745')
              .margin({ bottom: 20 });
          } else if (this.currentRitual) {
            Column() {
              Text(this.currentRitual.title)
                .fontSize(this.fontLarge())
                .fontWeight(FontWeight.Bold)
                .fontColor(this.currentRitual.color);
              Text(`Duration: ${this.currentRitual.time}`)
                .fontSize(this.fontSmall())
                .margin({ top: 10 })
                .fontColor('black');
            }
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            .margin({ bottom: 20 });
          } else {
            Text('Loading...')
              .fontSize(this.fontMedium())
              .fontColor('#999');
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center);

        Row() {
          Column() {
            this.renderBackButton();
          }
          .width(this.currentRitual && !this.showCompletionMessage ? '48%' : '100%');

          if (this.currentRitual && !this.showCompletionMessage) {
            Column() {
              this.renderCompletionButton();
            }
            .width('48%');
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween);
      }
      .width('100%')
      .height('100%')
      .padding({
        top: 10,
        bottom: 0,
        left: 20,
        right: 20
      })
      .backgroundColor('#FFF')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center);
    }.onReady((ctx: NavDestinationContext) => {
      this.pageStack = ctx.pathStack;
      const periodId = ctx.pathInfo.param as number;
      if (isNaN(periodId)) {
        console.error('Invalid period ID');
        this.pageStack.pop()
        return;
      }
      this.periodId = periodId;
      this.loadNextRitual();
    })
    .hideBackButton(true)
  }
}