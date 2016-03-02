# StreetPassBLE すれ違い通信

** すれ違い通信のiOSライブラリ **

すれ違い通信については、[こちら](https://ja.wikipedia.org/wiki/%E3%81%99%E3%82%8C%E3%81%A1%E3%81%8C%E3%81%84%E9%80%9A%E4%BF%A1)を参照してください。

端末同士がすれ違った時にデータ交換します。
１００バイト程度の送受信が可能です。
8.0以上での動作を確認しています。

** ※現在、開発中ですので、正常に動作しないことがあります。 **

# 導入方法

```
pod 'StreetPass', :git => 'https://github.com/gupuru/StreetPassBLE-iOS.git'
```

# 使い方

info.plistに以下を追加してください。

```
<key>Required background modes</key>
  <array>
       <string>App communicates using CoreBluetooth</string>
       <string>App shares data using CoreBluetooth</string>
  </array>
```

「start」で通信を開始します。

終了する際は、必ず「stop」を読んで下さい。


```
class ViewController: UIViewController, StreetPassDelegate {

let street: StreetPass = StreetPass()

override func viewDidLoad() {
  super.viewDidLoad()

  street.delegate = self
  //開始
  street.start()
}

override func viewDidDisappear(animated: Bool) {
     super.viewDidDisappear(animated)

     //停止
     street.stop()
}

func streetPassError(error: NSError) {
  //エラー
}

func nearByDevices(deveiceInfo: DeveiceInfo) {
  //受信端末
}

func receivedData(receivedData: ReceivedData) {
  //受信データ
}
```

# License

```
The MIT License (MIT)

Copyright (c) 2016 Kohei Niimi

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
