# 🌟 跨平台BLE通信神器：Apple Watch & iPhone ↔️ Android

![平台](https://img.shields.io/badge/平台-Apple%20Watch%20%7C%20iPhone%20%7C%20Android-brightgreen)
![蓝牙](https://img.shields.io/badge/技术-BLE%205.0-blue)
![语言](https://img.shields.io/badge/语言-Swift%20%7C%20Java-orange)
![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-red)
![Android](https://img.shields.io/badge/Android-Native-green)

## 🚀 项目简介

这是一个突破性的项目，实现了Apple生态系统（包括Apple Watch和iPhone）与Android设备之间的**实时双向通信**！通过蓝牙低功耗(BLE)技术，打破了iOS和Android生态的壁垒，让跨平台通信变得简单而优雅。

### 📱 支持的设备
- Apple Watch：所有支持watchOS的Apple Watch设备
- iPhone：运行iOS的iPhone设备
- Android：支持BLE的Android 6.0及以上设备

## ✨ 核心特性

### 🔄 多端协同
- **Watch App**: 
  - 实时扫描并显示周边BLE设备
  - 详细的设备信息展示（信号强度、服务UUID等）
  - 便捷的消息发送界面
  - 实时接收Android设备的计数器更新
  - 支持自定义消息发送
  - 稳定的连接状态管理

- **iPhone App**:
  - 与Watch App共享相同的功能
  - 更大屏幕优化的UI布局
  - 更详细的设备信息显示
  - 支持后台运行保持连接

- **Android App**:
  - 作为BLE外围设备运行
  - 实时计数器（每100ms更新一次）
  - 消息历史记录（带时间戳）
  - 优雅的MaterialDesign界面
  - 完整的权限管理系统
  - 支持多设备同时连接

### 🛠 技术特性
- **BLE通信**:
  - 自定义Service UUID: 0x180D
  - 通知特性UUID: 0x2A37（用于发送计数器数据）
  - 写入特性UUID: 0x2A38（用于接收消息）
  - 支持带响应和无响应的写入操作
  - 自动重连机制

- **数据传输**:
  - 毫秒级延迟
  - 稳定的数据流
  - 自动的连接状态管理
  - 完善的错误处理

## 📱 应用架构

### Apple端（Watch & iPhone）
- **UI层**:
  - 使用SwiftUI构建
  - MVVM架构设计
  - 响应式状态管理
  - 优雅的列表和详情视图

- **蓝牙层**:
  - 基于CoreBluetooth框架
  - 单例BluetoothManager设计
  - 完整的生命周期管理
  - 异步操作处理

### Android端
- **UI层**:
  - 原生Android视图系统
  - RecyclerView展示消息历史
  - 实时状态更新
  - Material Design风格

- **服务层**:
  - 后台Service运行BLE外围设备
  - 广播者模式
  - 完整的权限检查
  - 电源管理优化

## 📲 快速开始

### 环境要求
- Xcode 14.0+
- iOS 15.0+
- watchOS 8.0+
- Android Studio Electric Eel+
- Android SDK 31+
- Java 11+

### Watch App配置
1. 克隆项目后打开`BTEDemo.xcodeproj`
2. 选择Watch App target
3. 配置开发者账号和证书
4. 部署到Apple Watch
5. 点击扫描按钮开始搜索设备
6. 选择目标Android设备连接
7. 在文本框中输入消息并发送

### iPhone App配置
1. 在同一个`BTEDemo.xcodeproj`中
2. 选择iOS App target
3. 配置开发者账号和证书
4. 部署到iPhone设备
5. 操作方式与Watch App相同

### Android配置
1. 打开`android_as_ble`文件夹
2. 使用Android Studio打开项目
3. 配置开发环境
4. 在Android设备上安装运行
5. 授予必要权限：
   - 蓝牙权限
   - 位置权限
   - 后台运行权限
6. 应用会自动开启BLE广播
7. 等待Apple设备连接

## 💡 关键代码示例

### Watch/iPhone端蓝牙管理
```swift
class BluetoothManager: NSObject, ObservableObject {
    // 设备发现
    func startScanning() {
        // 扫描特定UUID的设备
        let serviceUUID = CBUUID(string: targetServiceUUID)
        centralManager.scanForPeripherals(withServices: [serviceUUID])
    }
    
    // 发送消息
    func sendData(_ message: String) {
        guard let characteristic = writeCharacteristic,
              let data = message.data(using: .utf8) else { return }
        peripheral.writeValue(data, for: characteristic)
    }
}
```

### Android端服务实现
```java
public class BlePeripheralService {
    // 启动广播
    public void startAdvertising() {
        AdvertiseSettings settings = new AdvertiseSettings.Builder()
                .setAdvertiseMode(AdvertiseSettings.ADVERTISE_MODE_LOW_LATENCY)
                .setConnectable(true)
                .build();
        advertiser.startAdvertising(settings, data, advertiseCallback);
    }
    
    // 处理接收到的消息
    public void onCharacteristicWriteRequest(...) {
        String receivedData = new String(value);
        if (callback != null) {
            callback.onMessageReceived(receivedData);
        }
    }
}
```

## 🌈 应用场景

- **智能家居控制**
  - 通过手表控制Android设备作为智能家居网关
  - 实时获取设备状态更新

- **运动数据同步**
  - 将手表采集的运动数据实时同步到Android设备
  - 支持自定义数据格式

- **远程设备监控**
  - 监控Android设备的各种状态
  - 实时接收告警信息

- **跨平台通知系统**
  - Android消息推送到Apple Watch
  - 支持双向确认机制

- **IoT设备交互**
  - 将Android设备作为IoT网关
  - Apple Watch作为便携控制器

## 🎯 未来规划

- [ ] 数据传输加密
  - 实现AES-256加密
  - 添加安全握手机制

- [ ] 多设备组网
  - 支持一对多连接
  - 实现设备间消息转发

- [ ] 数据格式扩展
  - 支持二进制数据传输
  - 添加文件传输功能

- [ ] 电池优化
  - 实现智能扫描间隔
  - 优化广播功率

- [ ] UI增强
  - 添加数据可视化
  - 支持自定义主题

## 🤝 贡献指南

1. Fork 项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 提交Pull Request

## 📝 许可证

MIT License - 查看 [LICENSE](LICENSE) 文件了解更多详情。

## 📚 参考资料

- [Core Bluetooth Programming Guide](https://developer.apple.com/documentation/corebluetooth)
- [Android BLE Guide](https://developer.android.com/guide/topics/connectivity/bluetooth-le)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)

---

⭐️ 如果这个项目对你有帮助，别忘了给它一个star！

📧 问题反馈：欢迎提交Issue或发送邮件到[your-email@example.com] 