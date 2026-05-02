import { HomePage } from './HomePage';
import { Period } from './Period';
import { AddHabitPage } from './AddHabitPage';
import window from '@ohos.window';
import GlobalContext from '../core/utils/GlobalContext';

@Entry
@Component
struct Index {
  @Provide('pageStack') pageStack: NavPathStack = new NavPathStack();
  context = GlobalContext.getInstance().getCntx();

  async aboutToAppear() {
    const context = GlobalContext.getInstance().getCntx();
    if (context) {
      let win = await window.getLastWindow(context);
      win.setWindowKeepScreenOn(true);
    }
  }

  async aboutToDisappear() {
    const context = GlobalContext.getInstance().getCntx();
    if (context) {
      let win = await window.getLastWindow(context);
      win.setWindowKeepScreenOn(false);
    }
  }

  @Builder
  Pages(name: string) {
    if (name === 'HomePage') {
      HomePage();
    } else if (name === 'Period') {
      Period();
    } else if (name === 'AddHabit') {
      AddHabitPage();
    }
  }

  build() {
    Navigation(this.pageStack)
      .mode(NavigationMode.Stack)
      .navDestination(this.Pages)
      .hideNavBar(true)
      .onAppear(() => {
        if (this.pageStack.getAllPathName().length === 0) {
          this.pageStack.pushPathByName('HomePage', null);
        }
      })
  }
}