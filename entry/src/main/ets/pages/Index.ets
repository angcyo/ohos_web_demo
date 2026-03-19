import JSBridge, { SupportTypes } from '../components/ArkWebJSBridge';
import WebComponent from '../components/WebComponent';
import { promptAction } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';

/**
 * Email:angcyo@126.com
 * @author angcyo
 * @date 2026-03-19
 */

class TestClass {
  controller: webview.WebviewController;
  uiContext: UIContext;

  constructor(controller: webview.WebviewController, uiContext: UIContext) {
    this.controller = controller;
    this.uiContext = uiContext;
  }

  testJSCall(message: string): void {
    console.info("message->" + message);
    try {
      this.uiContext.getPromptAction().showToast({
        message: `原生收到:${message}`,
        duration: 2000,
        showMode: promptAction.ToastShowMode.DEFAULT,
        bottom: 80
      });
    } catch (error) {
      console.error(error);
    }
    this.controller.runJavaScript(`testNativeCall("native [${message}] >> ${Date.now()}")`);
  }
}

@Entry
@Component
struct Index {
  @State userAgent: string = '';
  //延迟初始化
  jsbridge: JSBridge | undefined = undefined;

  build() {
    /*RelativeContainer() {
      Text(this.message)
        .id('HelloWorld')
        .fontSize($r('app.float.page_text_font_size'))
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .onClick(() => {
          this.message = 'Welcome';
        })
    }*/
    RelativeContainer() {
      WebComponent({
        src: $rawfile("local.html") /*'https://www.baidu.com'*/,
        currentUserAgent: this.userAgent!!,
        onInitJSBridge: (controller, jsbridge) => {
          this.jsbridge = jsbridge;
          jsbridge.register({ 'testJSCall': this.testJSCall });
          try {
            controller.registerJavaScriptProxy(new TestClass(controller, this.getUIContext()), "jsbObj",
              ["testJSCall"]);
          } catch (error) {
            console.error(error);
          }
        }
      })
        .height('100%')
        .width('100%')
      Text(this.userAgent)
        .alignRules({
          bottom: { anchor: "__container__", align: VerticalAlign.Bottom },
          right: { anchor: "__container__", align: HorizontalAlign.End }
        })
    }
    .height('100%').width('100%')
    .borderWidth(1).borderColor(Color.Red)
  }

  /**
   * 一个本地 ArkTS 函数
   * */
  testJSCall = (message: SupportTypes): SupportTypes => {
    try {
      this.getUIContext().getPromptAction().showToast({
        message: `JSBridge:${message}`,
        duration: 2000,
        showMode: promptAction.ToastShowMode.DEFAULT,
        bottom: 80
      });
    } catch (error) {
      console.error(error);
    }
    this.jsbridge?.postJS(`testNativeCall("jsbridge [${message}] >> ${Date.now()}");`);
    return true;
  }
}