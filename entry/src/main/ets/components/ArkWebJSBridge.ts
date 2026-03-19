import { webview } from '@kit.ArkWeb';
import { AsyncCallback } from '@kit.BasicServicesKit';

/**
 * Email:angcyo@126.com
 * @author angcyo
 * @date 2026/03/19
 *
 * https://ohpm.openharmony.cn/#/cn/detail/@ncc%2Fjsbridge
 * https://gitee.com/qing-lkyi/ohos_jsbridge
 */


export type SupportTypes = string | number | boolean;

export type SupportMethod = (...params: SupportTypes[]) => void | SupportTypes;

export interface BridgeObject {
  call: (name: string, ...params: SupportTypes[]) => void | SupportTypes;
}

export type NotFoundHandler = (funcName: string) => void | SupportTypes;

export default class JSBridge {
  jsbridgeName: string = "jsbridge";
  jsbridgeObj: BridgeObject = {
    call: (funcName: string, ...params: SupportTypes[]) => {
      const func = this.methods[funcName];
      if (func) {
        return func(...params);
      } else {
        return this.notFoundHandler(funcName);
      }
    }
  };
  controller: webview.WebviewController;
  methods: { [key: string]: SupportMethod } = {};
  notFoundHandler: NotFoundHandler = (funcName: string) => {
    console.log(funcName + ' not found');
  }

  constructor(controller?: webview.WebviewController) {
    if (controller) {
      this.controller = controller;
    }
  }

  /**
   * 关联一个 WebviewController
   */
  attachController(controller: webview.WebviewController) {
    this.controller = controller;
  }

  /**
   * 初始化 JSBridge，名称为 Web 侧调用时使用的名称
   * 需要在 controller 与 Web 组件关联后调用
   * @param jsbridgeName
   */
  initBridge(jsbridgeName?: string) {
    if (jsbridgeName) {
      this.jsbridgeName = jsbridgeName;
    }
    this.controller.registerJavaScriptProxy(
      this.jsbridgeObj, this.jsbridgeName, ['call']
    );
    this.controller.refresh();
  }

  /**
   * 取消 jsbridge 的注册
   */
  removeBridge() {
    this.controller.deleteJavaScriptRegister(this.jsbridgeName);
  }

  /**
   * 设置 jsbridge.call 找不到目标函数时的回调函数
   * 要求传入参数：funcName: string
   * 支持返回类型：void | string | number | boolean
   */
  setNotFoundHandler(notFoundHandler: NotFoundHandler) {
    this.notFoundHandler = notFoundHandler;
  }

  /**
   * 添加支持的函数
   */
  register(methods: Record<string, SupportMethod>) {
    // 后注册的名称会覆盖前面的
    Object.keys(methods).forEach((key: string) => {
      this.methods[key] = methods[key];
    });
  }

  /**
   * 移除支持的函数
   */
  unregister(methods: string[] | string) {
    if (typeof methods == 'string') {
      methods = [methods];
    }
    methods.forEach((key: string) => {
      if (this.methods[key]) {
        delete this.methods[key];
      }
    });
  }

  /**
   * 异步执行 js 脚本
   * 可以通过 callback 回调返回执行结果
   * 也可以通过 Promise<string> 实例返回执行结果
   * 参考: https://docs.openharmony.cn/pages/v4.0/zh-cn/application-dev/reference/apis/js-apis-webview.md/#runjavascript
   */
  postJS(jsCommand: string, callback?: AsyncCallback<string>) {
    if (callback) {
      this.postJS1(jsCommand, callback);
    } else {
      return this.postJS2(jsCommand);
    }
  }

  postJS1(jsCommand: string, callback: AsyncCallback<string>) {
    this.controller.runJavaScript(jsCommand, callback);
  }

  postJS2(jsCommand: string) {
    return this.controller.runJavaScript(jsCommand);
  }

  /**
   * 异步调用 js 函数
   * 仅支持以 Promise<string> 实例返回执行结果
   * 所有的参数都会被 JSON.stringify 序列化
   */
  post(funcName: string, ...params: any) {
    let serializedParams = params.map(param => JSON.stringify(param)).join(',');
    let jsCommand = funcName + '(' + serializedParams + ');';
    return this.controller.runJavaScript(jsCommand);
  }
}