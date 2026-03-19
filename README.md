# ohos_web_demo

# 需要`ohos.permission.INTERNET`权限

https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/web-component-overview#需要权限

在`module.json5`文件中,添加如下权限声明.

```json5
{
  "module": {
    "requestPermissions": [
      {
        "name": "ohos.permission.INTERNET"
      }
    ]
  }
}
```

# Web组件的生命周期

https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/web-event-sequence

# 自定义组件生命周期

https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-page-custom-components-lifecycle

# 组件状态

## 状态管理（V1）Component

https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-state-management-v1

- @see State 组件内状态 https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-state
- @see Prop 父子单向同步 https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-prop
- @see Link 父子双向同步 https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-link
- @see Track class对象属性级更新 https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-track

## 状态管理（V2） ComponentV2

https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-state-management-v2

- @see Local 组件内部状态 https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-new-local
- @see Param 组件外部输入 https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-new-param
- @see Once 初始化同步一次 https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-new-once
- @see Event 规范组件输出 https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-new-event

# !!语法：双向绑定

https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-new-binding