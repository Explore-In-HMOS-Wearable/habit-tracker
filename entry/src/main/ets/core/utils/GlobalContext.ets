export default class GlobalContext {
  private static instance: GlobalContext;
  private uiContext?: Context;

  static getInstance() {
    if (!GlobalContext.instance) {
      GlobalContext.instance = new GlobalContext();
    }
    return GlobalContext.instance;
  }

  public saveContext(context: Context) {
    this.uiContext = context;
  }

  public getCntx() {
    return this.uiContext;
  }
}