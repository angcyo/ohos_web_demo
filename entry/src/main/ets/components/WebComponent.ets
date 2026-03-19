import { webview } from '@kit.ArkWeb';

/**
 * Email:angcyo@126.com
 * @author angcyo
 * @date 2026-03-19
 *
 * # 需要`ohos.permission.INTERNET`权限
 *
 * https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/web-component-overview#需要权限
 *
 * 在`module.json5`文件中,添加如下权限声明.
 *
 * ```
 * {
 *   "module": {
 *     "requestPermissions": [
 *       {
 *         "name": "ohos.permission.INTERNET"
 *       }
 *   ]
 * }
 * ```
 *
 * # Web组件的生命周期
 *
 * https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/web-event-sequence
 *
 * # 自定义组件生命周期
 *
 * https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-page-custom-components-lifecycle
 *
 */
@Component
struct WebComponent {
  /**
   * @see webview.WebviewController.getUserAgent
   * @see webview.WebviewController.setAppCustomUserAgent
   * @see webview.WebviewController.setCustomUserAgent
   * @see webview.WebviewController.setRenderProcessMode
   * */
  controller: webview.WebviewController = new webview.WebviewController();
  /**
   * 三方应用相关信息标识
   * */
  @State customUserAgent: string = ' angcyo';
  /**
   * 调试标签
   * */
  debugLabel: string = "[WebComponent]";

  //MARK: - Component组件生命周期开始

  //1.
  aboutToAppear(): void {
    //当该组件即将显示时调用。
    console.info(this.debugLabel + 'aboutToAppear');
  }

  //2.
  build() {
    Web({ src: 'www.baidu.com', controller: this.controller })
    //MARK: - Web生命周期开始
    //1.
      .onControllerAttached(() => {
        try {
          let userAgent = this.controller.getUserAgent() + this.customUserAgent;
          // Mozilla/5.0 (PC; OpenHarmony 6.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/132.0.0.0 Safari/537.36  ArkWeb/6.0.0.130 angcyo
          console.info(this.debugLabel + "onControllerAttached:" + userAgent);
          this.controller.setCustomUserAgent(userAgent);
        } catch (error) {
          console.error(this.debugLabel +
            `ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
        }
      })
      //2.
      .onLoadIntercept((event) => {
        if (event) {
          console.info(this.debugLabel + 'onLoadIntercept url:' + event.data.getRequestUrl())
          console.debug(this.debugLabel + ' url:' + event.data.getRequestUrl())
          console.debug(this.debugLabel + ' isMainFrame:' + event.data.isMainFrame())
          console.debug(this.debugLabel + ' isRedirect:' + event.data.isRedirect())
          console.debug(this.debugLabel + ' isRequestGesture:' + event.data.isRequestGesture())
        }
        // 返回true表示阻止此次加载，否则允许此次加载
        return false;
      })
      //3.
      .onInterceptRequest((event) => {
        console.info(this.debugLabel + 'onInterceptRequest url:' + event.request.getRequestUrl());
        // 不拦截
        return null;
      })
      //4.
      .onPageBegin((event) => {
        if (event) {
          console.info(this.debugLabel + 'onPageBegin url:' + event.url);
        }
      })
      //5.
      .onProgressChange((event) => {
        if (event) {
          console.info(this.debugLabel + 'onProgressChange:' + event.newProgress);
        }
      })
      //6.
      .onPageEnd((event) => {
        // 推荐在此事件中执行JavaScript脚本
        if (event) {
          console.info(this.debugLabel + 'onPageEnd url:' + event.url);
        }
      })
      //MARK: - Web生命周期结束
      .onPageVisible((event) => {
        // 页面可见, 此时进度不一定100%
        console.info(this.debugLabel + 'onPageVisible url:' + event.url);
      })
      .onOverrideUrlLoading((webResourceRequest: WebResourceRequest) => {
        console.info(this.debugLabel + 'onOverrideUrlLoading:' + webResourceRequest.getRequestUrl());
        if (webResourceRequest && webResourceRequest.getRequestUrl() == "about:blank") {
          return true;
        }
        return false;
      })
      .onFirstContentfulPaint(event => {
        // 首屏渲染完成, 通常在`onPageVisible`回调后触发
        console.info(this.debugLabel + 'onFirstContentfulPaint:' + event);
        if (event) {
          console.info(this.debugLabel + "onFirstContentfulPaint:" + "[navigationStartTick]:" +
          event.navigationStartTick + ", [firstContentfulPaintMs]:" +
          event.firstContentfulPaintMs);
        }
      })
      .onRenderExited((event) => {
        if (event) {
          console.info(this.debugLabel + 'onRenderExited reason:' + event.renderExitReason);
        }
      })
      .onDisAppear(() => {
        // 销毁时触发.
        console.info(this.debugLabel + 'onDisAppear');
        /*this.getUIContext().getPromptAction().showToast({
          message: 'The web is hidden',
          duration: 2000
        })*/
      })
  }

  //3.
  onDidBuild(): void {
    //当该组件构建完成时调用。
    console.info(this.debugLabel + 'onDidBuild');
  }

  //4.
  aboutToDisappear(): void {
    //当该组件即将消失时调用。
    console.info(this.debugLabel + 'aboutToDisappear');
  }

  //MARK: - Component组件生命周期结束
}

export default WebComponent;