import WebComponent from '../components/WebComponent';


@Entry
@Component
struct Index {
  @State userAgent: string = '';

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
      WebComponent({ url: 'https://www.baidu.com', currentUserAgent: this.userAgent!! })
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
}