import { HttpRequest, HttpResponse, httpServer } from '@webabcd/harmony-httpserver'
import { http } from '@kit.NetworkKit';
import { buffer, util } from '@kit.ArkTS';
import resmgr from '@ohos.resourceManager';

/**
 * Email:angcyo@126.com
 * @author angcyo
 * @date 2026/03/23
 */

function stringToArrayBuffer(str: string): ArrayBuffer {
  const encoder = new util.TextEncoder();
  const uint8Array = encoder.encodeInto(str);
  return uint8Array.buffer;
}

function arrayBufferToString(arrayBuffer: ArrayBuffer): string {
  return buffer.from(arrayBuffer).toString('utf-8')
}

function getMimeType(filename: string): string {
  if (filename.endsWith('.html')) {
    return 'text/html';
  }
  if (filename.endsWith('.js')) {
    return 'application/javascript';
  }
  if (filename.endsWith('.png')) {
    return 'image/png';
  }
  if (filename.endsWith(".wasm")) {
    return 'application/wasm';
  }
  return 'application/octet-stream';
}

export default class RawfileServer {
  // 本地的 http server 的端口号（要求要大于等于 1024）
  port: number = 6088
  isStart: boolean = false
  resourceManager: resmgr.ResourceManager

  constructor(resourceManager: resmgr.ResourceManager) {
    this.resourceManager = resourceManager;

    // 是否启用日志记录（默认开启）
    httpServer.enableLog(true)

    // 处理本地 http 请求
    httpServer.handleHttpRequest((httpRequest: HttpRequest) => {
      let httpResponse = {} as HttpResponse
      const url = httpRequest.url
      /*let responseString = `我是自定义响应数据\n` +
        `request url: ${httpRequest.url}\n` +
        `request protocol: ${httpRequest.protocol}\n` +
        `request method: ${httpRequest.method}\n` +
        `request headers: ${Object.entries(httpRequest.headers).map(p => `${p[0]}:${p[1]}`).join(', ')}\n` +
        `request body: ${httpRequest.body}\n`*/

      if (httpRequest.method == 'GET') {
        // 如果是 get 请求，则响应自定义的 string 数据
        let fileName = url.substring(1)
        if (url === '/') {
          fileName = "local.html"
        }
        try {
          const rawFileData = resourceManager.getRawFileContentSync(fileName);
          httpResponse.result = rawFileData?.buffer
          httpResponse.statusCode = 200
          httpResponse.headers = {
            'Content-Type': getMimeType(fileName)
          }
        } catch (error) {
          console.error(
            `ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
          httpResponse.result = ''
          httpResponse.statusCode = 404
        }
      } else if (httpRequest.method == 'POST') {
        // 如果是 post 请求，则响应自定义的 ArrayBuffer 数据
        //httpResponse.result = stringToArrayBuffer(responseString)
        //不支持的请求
        httpResponse.statusCode = 405
        httpResponse.headers = {}
        httpResponse.headers['Allow'] = 'GET'
        httpResponse.result = 'Not Allowed'
      } else {
        httpResponse.result = ''
        httpResponse.statusCode = 404
      }

      return httpResponse
    });
  }

  startHttpServer() {
    if (!this.isStart) {
      // 指定端口号，并启动本地 http server
      // 返回值为真实监听的端口号
      httpServer.start(this.port, (err: BusinessError, port: number) => {
        this.isStart = !err
        this.port = port
      }).then(() => {
        console.log('启动本地 http server-> http://localhost:' + this.port + '/')
      })
    }
  }

  stopHttpServer() {
    // 停止本地 http server
    httpServer.stop()
    this.port = -1
  }
}