import Foundation
import CoreBluetooth
import os.log

class BluetoothManager: NSObject, ObservableObject {
    @Published var discoveredPeripherals: [CBPeripheral] = []
    @Published var isScanning = false
    @Published var connectedPeripheral: CBPeripheral?
    @Published var discoveredServices: [CBService] = []
    @Published var discoveredCharacteristics: [CBCharacteristic] = []
    @Published var imuData: String = "等待数据..."
    @Published var deviceDetails: [String: String] = [:]
    @Published var canSendData: Bool = false
    @Published var characteristicValues: [CBUUID: String] = [:]
    @Published var subscribedCharacteristics: Set<CBUUID> = []
    
    private var centralManager: CBCentralManager!
    private let logger = Logger(subsystem: "com.wayne.iOS-BLE-Android", category: "Bluetooth")
    
    // 目标UUID
    private let targetServiceUUID = "180D"
    private let targetNotifyCharacteristicUUID = "2A37"
    private let targetWriteCharacteristicUUID = "2A38"
    
    private var writeCharacteristic: CBCharacteristic?
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScanning() {
        guard centralManager.state == .poweredOn else { return }
        isScanning = true
        discoveredPeripherals.removeAll()
        deviceDetails.removeAll()
        
        // 修改扫描设置，先不限制服务UUID
        centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
        
        self.logger.info("开始扫描设备")
    }
    
    func stopScanning() {
        centralManager.stopScan()
        isScanning = false
    }
    
    func connect(to peripheral: CBPeripheral) {
        centralManager.connect(peripheral, options: nil)
        peripheral.delegate = self
    }
    
    func disconnect() {
        unsubscribeFromAllCharacteristics()
        if let peripheral = connectedPeripheral {
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }
    
    func sendData(_ message: String) {
        guard let characteristic = writeCharacteristic,
              let peripheral = connectedPeripheral,
              let data = message.data(using: .utf8) else {
            self.logger.error("无法发送数据：特性未找到或设备未连接")
            return
        }
        
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
        self.logger.info("发送数据: \(message)")
    }
    
    func subscribeToCharacteristic(_ characteristic: CBCharacteristic) {
        guard let peripheral = connectedPeripheral else { return }
        peripheral.setNotifyValue(true, for: characteristic)
        subscribedCharacteristics.insert(characteristic.uuid)
        self.logger.info("订阅特性: \(characteristic.uuid.uuidString)")
    }
    
    func unsubscribeFromCharacteristic(_ characteristic: CBCharacteristic) {
        guard let peripheral = connectedPeripheral else { return }
        peripheral.setNotifyValue(false, for: characteristic)
        subscribedCharacteristics.remove(characteristic.uuid)
        characteristicValues.removeValue(forKey: characteristic.uuid)
        self.logger.info("取消订阅特性: \(characteristic.uuid.uuidString)")
    }
    
    func unsubscribeFromAllCharacteristics() {
        guard let peripheral = connectedPeripheral else { return }
        for characteristic in discoveredCharacteristics where subscribedCharacteristics.contains(characteristic.uuid) {
            unsubscribeFromCharacteristic(characteristic)
        }
        self.logger.info("取消所有订阅")
    }
    
    private func isTargetService(_ uuid: CBUUID) -> Bool {
        return uuid.uuidString.hasSuffix(targetServiceUUID)
    }
    
    private func isTargetNotifyCharacteristic(_ uuid: CBUUID) -> Bool {
        return uuid.uuidString.hasSuffix(targetNotifyCharacteristicUUID)
    }
    
    private func isTargetWriteCharacteristic(_ uuid: CBUUID) -> Bool {
        return uuid.uuidString.hasSuffix(targetWriteCharacteristicUUID)
    }
}

// MARK: - CBCentralManagerDelegate
extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            self.logger.info("蓝牙已开启")
        case .poweredOff:
            self.logger.error("蓝牙已关闭")
        case .unsupported:
            self.logger.error("设备不支持蓝牙")
        case .unauthorized:
            self.logger.error("未授权使用蓝牙")
        case .resetting:
            self.logger.error("蓝牙重置中")
        case .unknown:
            self.logger.error("蓝牙状态未知")
        @unknown default:
            self.logger.error("未知状态")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !self.discoveredPeripherals.contains(peripheral) {
            self.discoveredPeripherals.append(peripheral)
            
            // 记录设备详细信息
            var details = "名称: \(peripheral.name ?? "未知")\n"
            details += "标识: \(peripheral.identifier.uuidString)\n"
            details += "RSSI: \(RSSI) dBm\n"
            
            if let manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data {
                details += "制造商数据: \(manufacturerData.map { String(format: "%02X", $0) }.joined())\n"
            }
            
            if let serviceUUIDs = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID] {
                details += "服务UUID列表:\n"
                for uuid in serviceUUIDs {
                    details += "- \(uuid.uuidString)\n"
                    if self.isTargetService(uuid) {
                        details += "⭐️ 这是Android发布的目标服务\n"
                    }
                }
            }
            
            if let localName = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
                details += "本地名称: \(localName)\n"
            }
            
            self.logger.info("发现设备: \(details)")
            self.deviceDetails[peripheral.identifier.uuidString] = details
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.connectedPeripheral = peripheral
        peripheral.discoverServices(nil)
        self.logger.info("已连接到设备: \(peripheral.name ?? "未知")")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        self.connectedPeripheral = nil
        self.discoveredServices.removeAll()
        self.discoveredCharacteristics.removeAll()
        self.writeCharacteristic = nil
        self.canSendData = false
        if let error = error {
            self.logger.error("设备断开连接出错: \(error.localizedDescription)")
        } else {
            self.logger.info("设备已断开连接")
        }
    }
}

// MARK: - CBPeripheralDelegate
extension BluetoothManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else {
            self.logger.error("发现服务出错: \(error!.localizedDescription)")
            return
        }
        
        self.discoveredServices = peripheral.services ?? []
        for service in peripheral.services ?? [] {
            peripheral.discoverCharacteristics(nil, for: service)
            self.logger.info("发现服务: \(service.uuid.uuidString)")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil else {
            self.logger.error("发现特性出错: \(error!.localizedDescription)")
            return
        }
        
        for characteristic in service.characteristics ?? [] {
            self.logger.info("发现特性: \(characteristic.uuid.uuidString)")
            self.discoveredCharacteristics.append(characteristic)
            
            if characteristic.properties.contains(.notify) {
                self.logger.info("发现可通知特性，自动订阅")
                peripheral.setNotifyValue(true, for: characteristic)
            }
            
            if characteristic.properties.contains(.write) || characteristic.properties.contains(.writeWithoutResponse) {
                self.logger.info("发现可写入特性")
                self.writeCharacteristic = characteristic
                self.canSendData = true
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            self.logger.error("读取特性值出错: \(error!.localizedDescription)")
            return
        }
        
        if let data = characteristic.value {
            let value: String
            if let stringValue = String(data: data, encoding: .utf8) {
                value = stringValue
            } else {
                value = data.map { String(format: "%02X", $0) }.joined()
            }
            characteristicValues[characteristic.uuid] = value
            self.logger.info("收到数据 [\(characteristic.uuid.uuidString)]: \(value)")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            self.logger.error("写入数据失败: \(error.localizedDescription)")
        } else {
            self.logger.info("写入数据成功")
        }
    }
} 
