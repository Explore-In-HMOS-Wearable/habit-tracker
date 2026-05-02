import { PeriodService, HabitInput } from '../core/services/PeriodService';
import { PeriodModel } from '../core/models/PeriodModel';
import { HabitType } from '../core/models/HabitModel';
import { hilog } from '@kit.PerformanceAnalysisKit';

interface TypeOption {
  label: Resource;
  value: HabitType;
}

const TAG = 'AddHabitPage';
const DOMAIN = 0x0001;

@Component
export struct AddHabitPage {
  @Consume('pageStack') pageStack: NavPathStack;
  private controller: PeriodService = PeriodService.instance;

  @State selectedPeriodId: number = 1;
  @State selectedColor: string = '#4ea5d7';
  @State habitTitle: string = '';
  @State habitTime: string = '';
  @State habitType: HabitType = HabitType.NORMAL;
  @State targetValueStr: string = '';
  @State isSaving: boolean = false;

  private typeOptions: TypeOption[] = [
    { label: $r('app.string.type_normal'), value: HabitType.NORMAL },
    { label: $r('app.string.type_breath'), value: HabitType.BREATHING },
    { label: $r('app.string.type_steps'), value: HabitType.STEPS }
  ];

  private updateSelectedColor(): void {
    const period = this.controller.getPeriodById(this.selectedPeriodId);
    this.selectedColor = period?.color ?? '#4ea5d7';
  }

  private isFormValid(): boolean {
    return this.habitTitle.trim().length > 0 && this.habitTime.trim().length > 0;
  }

  private async saveHabit(): Promise<void> {
    if (!this.isFormValid()) {
      return;
    }
    this.isSaving = true;

    let parsedTarget: number = 0;
    if (this.habitType !== HabitType.NORMAL) {
      parsedTarget = parseInt(this.targetValueStr) || 0;
    }

    const input: HabitInput = {
      title: this.habitTitle.trim(),
      time: this.habitTime.trim(),
      color: this.selectedColor,
      type: this.habitType,
      targetValue: parsedTarget
    };

    try {
      await this.controller.addHabit(this.selectedPeriodId, input);
      hilog.info(DOMAIN, TAG, 'Habit saved to period %{public}d', this.selectedPeriodId);
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'Save failed: %{public}s', JSON.stringify(err));
    }

    this.isSaving = false;
    this.pageStack.pop();
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Text($r('app.string.add_ritual_title'))
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .margin({ top: 16, bottom: 14 })

          Text($r('app.string.label_period'))
            .fontSize(13)
            .fontColor($r('app.color.text_secondary'))
            .margin({ bottom: 6 })

          Row() {
            ForEach(this.controller.periods, (period: PeriodModel) => {
              Text(period.title.split(' ')[0])
                .fontSize(12)
                .fontColor(this.selectedPeriodId === period.id ? '#FFF' : '#888')
                .backgroundColor(this.selectedPeriodId === period.id ? period.color : '#1A1A1A')
                .borderRadius(16)
                .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                .onClick(() => {
                  this.selectedPeriodId = period.id;
                  this.updateSelectedColor();
                })
            }, (period: PeriodModel) => period.id.toString())
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceEvenly)

          Text($r('app.string.label_title'))
            .fontSize(13)
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 16, bottom: 6 })

          TextInput({ placeholder: 'e.g. Drink water' })
            .onChange((value: string) => {
              this.habitTitle = value;
            })
            .width('92%')
            .height(40)
            .borderRadius(12)
            .backgroundColor($r('app.color.card_bg'))
            .fontColor(Color.White)
            .placeholderColor($r('app.color.placeholder_color'))

          Text($r('app.string.label_duration'))
            .fontSize(13)
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 16, bottom: 6 })

          TextInput({ placeholder: 'e.g. 5 min' })
            .onChange((value: string) => {
              this.habitTime = value;
            })
            .width('92%')
            .height(40)
            .borderRadius(12)
            .backgroundColor($r('app.color.card_bg'))
            .fontColor(Color.White)
            .placeholderColor($r('app.color.placeholder_color'))

          Text($r('app.string.label_type'))
            .fontSize(13)
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 16, bottom: 6 })

          Row() {
            ForEach(this.typeOptions, (item: TypeOption) => {
              Text(item.label)
                .fontSize(12)
                .fontColor(this.habitType === item.value ? '#FFF' : '#888')
                .backgroundColor(this.habitType === item.value ? this.selectedColor : '#1A1A1A')
                .borderRadius(16)
                .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                .onClick(() => {
                  this.habitType = item.value;
                })
            }, (item: TypeOption) => item.value)
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceEvenly)

          if (this.habitType === HabitType.BREATHING) {
            Text($r('app.string.label_seconds'))
              .fontSize(13)
              .fontColor($r('app.color.text_secondary'))
              .margin({ top: 16, bottom: 6 })

            TextInput({ placeholder: 'e.g. 180' })
              .onChange((value: string) => {
                this.targetValueStr = value;
              })
              .type(InputType.Number)
              .width('92%')
              .height(40)
              .borderRadius(12)
              .backgroundColor($r('app.color.card_bg'))
              .fontColor(Color.White)
              .placeholderColor($r('app.color.placeholder_color'))
          } else if (this.habitType === HabitType.STEPS) {
            Text($r('app.string.label_step_count'))
              .fontSize(13)
              .fontColor($r('app.color.text_secondary'))
              .margin({ top: 16, bottom: 6 })

            TextInput({ placeholder: 'e.g. 1000' })
              .onChange((value: string) => {
                this.targetValueStr = value;
              })
              .type(InputType.Number)
              .width('92%')
              .height(40)
              .borderRadius(12)
              .backgroundColor($r('app.color.card_bg'))
              .fontColor(Color.White)
              .placeholderColor($r('app.color.placeholder_color'))
          }

          Button(this.isSaving ? $r('app.string.btn_saving') : $r('app.string.btn_save'))
            .onClick(() => {
              this.saveHabit();
            })
            .enabled(!this.isSaving && this.isFormValid())
            .width('80%')
            .height(44)
            .borderRadius(22)
            .backgroundColor(this.isFormValid() ? this.selectedColor : '#333')
            .fontColor(Color.White)
            .margin({ top: 24 })

          Button($r('app.string.btn_cancel'))
            .onClick(() => {
              this.pageStack.pop();
            })
            .width('80%')
            .height(40)
            .borderRadius(20)
            .backgroundColor($r('app.color.dark_bg'))
            .fontColor($r('app.color.text_tertiary'))
            .margin({ top: 10, bottom: 30 })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Color.Black)
      .scrollBar(BarState.Off)
    }
    .onReady((ctx: NavDestinationContext) => {
      this.pageStack = ctx.pathStack;
      const param = ctx.pathInfo.param as number | undefined;
      if (param !== undefined && param !== null) {
        this.selectedPeriodId = param;
      }
      this.updateSelectedColor();
    })
    .hideBackButton(true)
  }
}