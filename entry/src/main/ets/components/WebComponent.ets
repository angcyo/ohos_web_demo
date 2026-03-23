import { webview } from '@kit.ArkWeb';
import JSBridge from './ArkWebJSBridge';

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
 *     ]
 *   }
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
 * # 组件状态
 * @see Component
 * @see State 组件内状态 https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-state
 * @see Prop 父子单向同步 https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-prop
 * @see Link 父子双向同步 https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-link
 * @see Track class对象属性级更新 https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-track
 *
 * @see ComponentV2
 * @see Local 组件内部状态 https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-new-local
 * @see Param 组件外部输入 https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-new-param
 * @see Once 初始化同步一次 https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-new-once
 * @see Event 规范组件输出 https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-new-event
 *
 * # !!语法：双向绑定
 *
 * https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-new-binding
 */
@ComponentV2
struct WebComponent {
  /**
   * 需要加载的网页,或者资源 `$rawfile("local.html")`
   * */
  @Param src: string | Resource | undefined = 'about:blank';
  /**
   * @see webview.WebviewController.getUserAgent
   * @see webview.WebviewController.setAppCustomUserAgent
   * @see webview.WebviewController.setCustomUserAgent
   * @see webview.WebviewController.setRenderProcessMode
   * */
  @Param controller: webview.WebviewController = new webview.WebviewController();
  /**
   * 三方应用相关信息标识
   * */
  @Param customUserAgent: string = ' angcyo';
  /**
   * 当前的`UserAgent`, 支持双向绑定.
   * */
  @Param currentUserAgent: string = '';
  @Event $currentUserAgent: (val: string) => void = (val: string) => {
  };
  /**
   * 调试标签
   * */
  @Param debugLabel: string = "[WebComponent]";
  //MARK: - JSBridge

  isReady: boolean = false;
  // 创建 JSBridge 实例
  jsbridge: JSBridge = new JSBridge(this.controller)
  /**外部注册`JSBridge`的回调方法*/
  @Param onInitJSBridge: (controller: webview.WebviewController, jsbridge: JSBridge) => void =
    (controller, jsbridge: JSBridge) => {
    };

  /**初始化JSBridge*/
  initJSBridge(): void {
    if (!this.isReady) {
      // 在 controller 与 web 关联后才能进行 bridge 的初始化
      this.jsbridge.initBridge();
      // 添加支持的方法
      this.onInitJSBridge(this.controller, this.jsbridge);
      //this.jsbridge.register({ 'changeNativeMessage': this.changeNativeMessage });
      this.isReady = true;
    }
  }

  /**销毁JSBridge*/
  removeJSBridge(): void {
    try {
      this.jsbridge.removeBridge();
    } catch (error) {
      console.log(error.message);
    }
  }

  /*// 一个本地 ArkTS 函数
  changeNativeMessage = (message: string) => {
    //this.message = message;
  }*/

  //MARK: - Component组件生命周期开始

  //1.
  aboutToAppear(): void {
    //当该组件即将显示时调用。
    console.info(this.debugLabel + 'aboutToAppear');
  }

  //2.
  build() {
    Web({ src: this.src, controller: this.controller })
      .javaScriptAccess(true)
      .fileAccess(true)
      .domStorageAccess(true)
      .mixedMode(MixedMode.All)
      //MARK: - Web生命周期开始
      //1.
      .onControllerAttached(() => {
        try {
          let userAgent = this.controller.getUserAgent() + this.customUserAgent;
          this.$currentUserAgent(userAgent);
          // Mozilla/5.0 (PC; OpenHarmony 6.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/132.0.0.0 Safari/537.36  ArkWeb/6.0.0.130 angcyo
          console.info(this.debugLabel + "onControllerAttached:" + userAgent);
          this.controller.setCustomUserAgent(userAgent);
        } catch (error) {
          console.error(this.debugLabel +
            `ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
        }
        this.initJSBridge();
      })
      //2.
      .onLoadIntercept((event) => {
        if (event) {
          console.info(this.debugLabel + 'onLoadIntercept url->' + event.data.getRequestUrl())
          console.debug(this.debugLabel + ' url->' + event.data.getRequestUrl())
          console.debug(this.debugLabel + ' isMainFrame:' + event.data.isMainFrame())
          console.debug(this.debugLabel + ' isRedirect:' + event.data.isRedirect())
          console.debug(this.debugLabel + ' isRequestGesture:' + event.data.isRequestGesture())
        }
        // 返回true表示阻止此次加载，否则允许此次加载
        return false;
      })
      //3.
      /**
       * @see this.responseWeb.setResponseData
       * @see this.responseWeb.setResponseCode
       * @see this.responseWeb.setReasonMessage
       * */
      .onInterceptRequest((event) => {
        if (!event) {
          return null;
        }
        const url = event.request.getRequestUrl();
        console.info(this.debugLabel + 'onInterceptRequest url->' + url);

        //resource://rawfile/local.html
        //resource://rawfile/pkg/rust_hello_wasm.js
        const rawfileFlag = 'resource://rawfile/';
        if (url.startsWith(rawfileFlag)) {
          const fileName = url.replace(rawfileFlag, '');

          // 1. 从 rawfile 读取二进制数据
          try {
            const rawFileData = this.getUIContext().getHostContext()?.resourceManager.getRawFileContentSync(fileName);
            // 2. 根据后缀名手动设置 MIME 类型（解决 Wasm/Module 关键点）
            let mimeType = 'text/html';
            if (url.endsWith('.js')) {
              mimeType = 'application/javascript';
            } else if (url.endsWith('.wasm')) {
              mimeType = 'application/wasm';
            }

            // 3. 构造响应，手动注入允许跨域的 Header
            let response = new WebResourceResponse();
            response.setResponseData(rawFileData?.buffer);
            response.setResponseEncoding('utf-8');
            response.setResponseMimeType(mimeType);
            response.setResponseCode(200);
            response.setReasonMessage('OK');
            response.setResponseHeader([
              { headerKey: 'Access-Control-Allow-Origin', headerValue: '*' }
            ]);
            return response;
          } catch (error) {
            console.error(this.debugLabel +
              `ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
          }
        }
        // 不拦截
        return null;
      })
      //4.
      .onPageBegin((event) => {
        if (event) {
          console.info(this.debugLabel + 'onPageBegin url->' + event.url);
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
        // 页面加载完成, 整体进度100%. 推荐在此事件中执行JavaScript脚本
        if (event) {
          try {
            console.info(this.debugLabel + 'onPageEnd url->' + event.url
              + " pageHeight:" + this.controller.getPageHeight()
              + " pageOffset:" + this.controller.getPageOffset());
          } catch (error) {
            console.error(this.debugLabel +
              `ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
          }
        }
      })
      //MARK: - Web生命周期结束
      .onPageVisible((event) => {
        // 页面可见, 此时进度不一定100%
        console.info(this.debugLabel + 'onPageVisible url->' + event.url);
      })
      .onOverrideUrlLoading((webResourceRequest: WebResourceRequest) => {
        //当用户点击<a>标签,  window.location.href = '...' 或 window.open()。 时触发.
        console.info(this.debugLabel + 'onOverrideUrlLoading');
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
        this.removeJSBridge();
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