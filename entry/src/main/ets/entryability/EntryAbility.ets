import {
  AbilityConstant,
  ConfigurationConstant,
  UIAbility,
  Want,
  abilityAccessCtrl,
  Permissions
} from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { SensorTrackingService } from '../core/services/SensorTrackingService';
import { DatabaseService } from '../core/services/DatabaseService';
import GlobalContext from '../core/utils/GlobalContext';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): Promise<void> {
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    hilog.info(DOMAIN, 'HabitTracker', 'Ability onCreate');
    GlobalContext.getInstance().saveContext(this.context);

    await DatabaseService.init(this.context);
    this.requestPermissions();
  }

  private requestPermissions(): void {
    const atManager = abilityAccessCtrl.createAtManager();
    const permissions: Array<Permissions> = ['ohos.permission.ACTIVITY_MOTION'];

    atManager.requestPermissionsFromUser(this.context, permissions).then((data) => {
      hilog.info(DOMAIN, 'HabitTracker', 'Permission request success: %{public}s', JSON.stringify(data));

      SensorTrackingService.instance.startTracking();
    }).catch((err: Error) => {
      hilog.error(DOMAIN, 'HabitTracker', 'Permission request failed: %{public}s', JSON.stringify(err));
    });
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'HabitTracker', 'Ability onDestroy');
    SensorTrackingService.instance.stopTracking();
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'HabitTracker', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'HabitTracker', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    hilog.info(DOMAIN, 'HabitTracker', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    hilog.info(DOMAIN, 'HabitTracker', 'Ability onForeground');
  }

  onBackground(): void {
    hilog.info(DOMAIN, 'HabitTracker', 'Ability onBackground');
  }
}