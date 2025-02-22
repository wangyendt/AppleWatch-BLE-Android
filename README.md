# 🌐 BLE Communication Bridge: Apple Watch/iPhone ↔️ Android

![Platforms](https://img.shields.io/badge/Platforms-Apple%20Watch%20%7C%20iPhone%20%7C%20Android-brightgreen)
![Technology](https://img.shields.io/badge/Technology-BLE%205.0-blue)
![Languages](https://img.shields.io/badge/Languages-Swift%20%7C%20Java-orange)

## 🎯 Core Innovation

This project demonstrates how to enable bidirectional BLE communication between Apple Watch/iPhone (as BLE Central) and Android devices (simulated as BLE Peripheral). The key innovation is implementing a complete BLE communication stack that allows Apple Watch to directly communicate with Android devices.

### Key Implementation

1. **BLE Role Definition**
   - Apple Watch/iPhone: BLE Central (Scanner & Controller)
   - Android: BLE Peripheral (Advertiser & Service Provider)

2. **Core Architecture**
   ```swift
   // Apple Watch/iPhone as BLE Central
   class BluetoothManager: NSObject, ObservableObject {
       private var centralManager: CBCentralManager!
       private var peripheral: CBPeripheral?
       
       // Start scanning for BLE peripherals
       func startScanning() {
           centralManager.scanForPeripherals(withServices: nil)
       }
       
       // Handle discovered peripheral
       func centralManager(_ central: CBCentralManager, 
                         didDiscover peripheral: CBPeripheral,
                         advertisementData: [String: Any],
                         rssi RSSI: NSNumber) {
           // Connect to the peripheral
           centralManager.connect(peripheral, options: nil)
       }
   }
   ```

   ```java
   // Android as BLE Peripheral
   public class BlePeripheralService {
       private BluetoothGattServer gattServer;
       private BluetoothLeAdvertiser advertiser;
       
       // Start advertising as a BLE peripheral
       public void startAdvertising() {
           AdvertiseSettings settings = new AdvertiseSettings.Builder()
               .setAdvertiseMode(AdvertiseSettings.ADVERTISE_MODE_LOW_LATENCY)
               .setConnectable(true)
               .build();
           advertiser.startAdvertising(settings, data, advertiseCallback);
       }
       
       // Handle incoming connections and data
       private BluetoothGattServerCallback gattServerCallback = 
           new BluetoothGattServerCallback() {
           @Override
           public void onConnectionStateChange(BluetoothDevice device, 
                                             int status, 
                                             int newState) {
               // Handle connection state changes
           }
       };
   }
   ```

## ⚡️ Supported Scenarios

1. **Apple Watch as BLE Central**
   - Connect to standard BLE peripherals
   - Connect to Android simulated BLE peripheral
   - Send and receive data

2. **iPhone as BLE Central**
   - Connect to standard BLE peripherals
   - Connect to Android simulated BLE peripheral
   - Send and receive data

3. **Android as BLE Peripheral**
   - Advertise as a BLE peripheral
   - Accept connections from Apple Watch/iPhone
   - Handle data communication

## 🛠 Technical Details

### BLE Communication Flow

1. **Discovery Phase**
   - Android advertises as a BLE peripheral
   - Apple Watch/iPhone scans for BLE peripherals

2. **Connection Phase**
   - Apple Watch/iPhone initiates connection
   - Android accepts connection

3. **Data Exchange Phase**
   - Bidirectional communication through characteristics
   - Real-time data updates

### Key Components

1. **Apple Side**
   - CoreBluetooth framework
   - Custom BluetoothManager
   - SwiftUI interface

2. **Android Side**
   - Android BLE API
   - Custom BlePeripheralService
   - Material Design interface

## 📱 Requirements

- Apple Watch: watchOS 8.0+
- iPhone: iOS 15.0+
- Android: 6.0+ (with BLE support)

## 🚀 Quick Start

### Apple Side
1. Open `BTEDemo.xcodeproj`
2. Select target device
3. Build and run

### Android Side
1. Open `android_as_ble` in Android Studio
2. Configure BLE permissions
3. Build and run

## 📖 Documentation

- [Core Bluetooth Framework](https://developer.apple.com/documentation/corebluetooth)
- [Android BLE Guide](https://developer.android.com/guide/topics/connectivity/bluetooth-le)

## 📄 License

MIT License

## 💡 Notes

- This project demonstrates the possibility of direct BLE communication between Apple Watch and Android devices
- The implementation can be extended to support various BLE peripherals
- The communication protocol can be customized based on specific needs

---

# 🌐 BLE通信桥接：Apple Watch/iPhone ↔️ Android

## 🎯 核心创新

本项目展示了如何实现Apple Watch/iPhone（作为BLE中心设备）与Android设备（模拟BLE外围设备）之间的双向BLE通信。核心创新点在于实现了完整的BLE通信栈，使Apple Watch能够直接与Android设备进行通信。

### 关键实现

1. **BLE角色定义**
   - Apple Watch/iPhone：BLE中心设备（扫描者和控制者）
   - Android：BLE外围设备（广播者和服务提供者）

2. **核心架构**
   - Apple端：实现BLE中心设备功能，负责扫描、连接和数据交换
   - Android端：模拟BLE外围设备，提供服务和特征值

## ⚡️ 支持场景

1. **Apple Watch作为BLE中心设备**
   - 连接标准BLE外围设备
   - 连接Android模拟的BLE外围设备
   - 收发数据

2. **iPhone作为BLE中心设备**
   - 连接标准BLE外围设备
   - 连接Android模拟的BLE外围设备
   - 收发数据

3. **Android作为BLE外围设备**
   - 广播为BLE外围设备
   - 接受来自Apple Watch/iPhone的连接
   - 处理数据通信

## 🛠 技术细节

### BLE通信流程

1. **发现阶段**
   - Android广播为BLE外围设备
   - Apple Watch/iPhone扫描BLE外围设备

2. **连接阶段**
   - Apple Watch/iPhone发起连接
   - Android接受连接

3. **数据交换阶段**
   - 通过特征值进行双向通信
   - 实时数据更新

### 核心组件

1. **苹果端**
   - CoreBluetooth框架
   - 自定义蓝牙管理器
   - SwiftUI界面

2. **安卓端**
   - Android BLE API
   - 自定义BLE外围设备服务
   - Material Design界面

## 📱 系统要求

- Apple Watch：watchOS 8.0+
- iPhone：iOS 15.0+
- Android：6.0+（需要支持BLE）

## 🚀 快速开始

### 苹果端
1. 打开`BTEDemo.xcodeproj`
2. 选择目标设备
3. 构建并运行

### 安卓端
1. 在Android Studio中打开`android_as_ble`
2. 配置BLE权限
3. 构建并运行

## 📖 文档

- [Core Bluetooth框架](https://developer.apple.com/documentation/corebluetooth)
- [Android BLE指南](https://developer.android.com/guide/topics/connectivity/bluetooth-le)

## 📄 许可证

MIT License

## 💡 注意事项

- 本项目展示了Apple Watch与Android设备之间直接BLE通信的可能性
- 该实现可以扩展以支持各种BLE外围设备
- 通信协议可以根据具体需求进行自定义 