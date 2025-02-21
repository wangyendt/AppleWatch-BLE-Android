# Apple Watch/iPhone与Android的BLE通信示例

![平台](https://img.shields.io/badge/平台-Apple%20Watch%20%7C%20iPhone%20%7C%20Android-brightgreen)
![蓝牙](https://img.shields.io/badge/技术-BLE%205.0-blue)
![语言](https://img.shields.io/badge/语言-Swift%20%7C%20Java-orange)
![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-red)
![Android](https://img.shields.io/badge/Android-Native-green)

## 项目简介

这是一个基于蓝牙低功耗(BLE)技术的示例项目，演示了如何实现Apple Watch/iPhone与Android设备之间的双向通信。项目包含完整的iOS端和Android端实现，可用于学习BLE通信的基本原理和实践。

### 支持平台
- Apple Watch：watchOS 8.0+
- iPhone：iOS 15.0+
- Android：Android 6.0+（需支持BLE）

## 功能特性

### iOS端（Watch & iPhone）
- BLE中心设备模式
- 设备扫描与连接
- 服务与特性发现
- 实时数据接收
- 自定义消息发送
- 连接状态管理

### Android端
- BLE外围设备模式
- 自定义服务广播
- 计数器数据推送
- 消息接收与显示
- 多设备连接支持

### 技术规格
- Service UUID: 0x180D
- 通知特性UUID: 0x2A37
- 写入特性UUID: 0x2A38
- 数据更新频率: 100ms
- 支持带响应和无响应写入

## 系统架构

### iOS端
- SwiftUI界面框架
- CoreBluetooth蓝牙框架
- MVVM架构模式
- 响应式状态管理

### Android端
- 原生Android UI
- Android BLE API
- 前台服务模式
- Material Design规范

## 开发环境

### 必要条件
- Xcode 14.0+
- Android Studio Electric Eel+
- iOS开发者账号
- 支持BLE的测试设备

### 依赖版本
- iOS/watchOS SDK
- Android SDK 31+
- Java 11+

## 使用说明

### iOS端配置
1. 打开`BTEDemo.xcodeproj`
2. 选择目标设备（Watch/iPhone）
3. 配置开发者证书
4. 构建并运行

### Android端配置
1. 导入`android_as_ble`项目
2. 同步Gradle依赖
3. 配置必要权限
4. 构建并运行

## 实现细节

### 核心类说明

#### iOS BluetoothManager
```swift
class BluetoothManager: NSObject, ObservableObject {
    // BLE设备扫描
    func startScanning() {
        let serviceUUID = CBUUID(string: targetServiceUUID)
        centralManager.scanForPeripherals(withServices: [serviceUUID])
    }
    
    // 数据发送
    func sendData(_ message: String) {
        guard let characteristic = writeCharacteristic,
              let data = message.data(using: .utf8) else { return }
        peripheral.writeValue(data, for: characteristic)
    }
}
```

#### Android BlePeripheralService
```java
public class BlePeripheralService {
    // 启动BLE广播
    public void startAdvertising() {
        AdvertiseSettings settings = new AdvertiseSettings.Builder()
                .setAdvertiseMode(AdvertiseSettings.ADVERTISE_MODE_LOW_LATENCY)
                .setConnectable(true)
                .build();
        advertiser.startAdvertising(settings, data, advertiseCallback);
    }
}
```

## 待优化项目

- 数据传输安全性增强
- 连接稳定性优化
- 电池使用效率优化
- 数据格式标准化
- 错误处理完善

## 参考文档

- [Core Bluetooth Framework](https://developer.apple.com/documentation/corebluetooth)
- [Android BLE开发指南](https://developer.android.com/guide/topics/connectivity/bluetooth-le)
- [SwiftUI开发文档](https://developer.apple.com/documentation/swiftui)

## 许可证

MIT License

## 问题反馈

如有问题或建议，欢迎提交Issue 