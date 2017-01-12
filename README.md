![header](https://raw.githubusercontent.com/gupuru/StreetPassBLE-iOS/assets/icon.png)

# StreetPassBLE すれ違い通信

**iOS's StreetPass Communication library**

## What is StreetPass Communication?

StreetPass is a Nintendo 3DS functionality which allows passive communication between Nintendo 3DS systems held by users in close proximity, an example being the sharing of Mii avatars in the StreetPass Mii Plaza application, and other game data. New data received from StreetPass is indicated via a green status light on the system.

[Wiki](https://en.wikipedia.org/wiki/SpotPass_and_StreetPass)

## About this library

When the terminal with each other has become close to, it is capable of transmitting and receiving data of about 100 bytes.

8.1 is available in more than.

Questions and requests is [here](https://github.com/gupuru/StreetPassBLE-iOS/issues/8).

![Animation](https://raw.githubusercontent.com/gupuru/StreetPassBLE-iOS/assets/demo.gif)

## CocoaPods

``` ruby
pod 'StreetPass'
```

## Usage

Please add the following to the `info.plist`.

``` xml
<key>Required background modes</key>
  <array>
       <string>App communicates using CoreBluetooth</string>
       <string>App shares data using CoreBluetooth</string>
  </array>
```

### Start StreetPass

```swift
let street: StreetPass = StreetPass()
street.start()
```

### Settings

- UUID
- Transmitted data

```swift
let street: StreetPass = StreetPass()

let streetPassSettings: StreetPassSettings = StreetPassSettings()
                .sendData(sendData)
                .allowDuplicates(false)
                .isConnect(true)
      
street.start(streetPassSettings)
```

### Stop StreetPass

Please stop sure.

```swift
let street: StreetPass = StreetPass()
street.stop()
```

### Delegate

Received data.

```swift
func receivedData(receivedData: ReceivedData) {
  //received data
}
```

Error

```swift
func streetPassError(error: NSError) {
  //error
}
```

### Sample

``` swift
class ViewController: UIViewController, StreetPassDelegate {

let street: StreetPass = StreetPass()

override func viewDidLoad() {
  super.viewDidLoad()

  street.delegate = self
  //start
  street.start()
}

override func viewDidDisappear(animated: Bool) {
     super.viewDidDisappear(animated)

     //stop
     street.stop()
}

func streetPassError(error: NSError) {
  //error
}

func receivedData(receivedData: ReceivedData) {
  //received data
}
```

# License

```
The MIT License (MIT)

Copyright (c) 2017 Kohei Niimi

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
