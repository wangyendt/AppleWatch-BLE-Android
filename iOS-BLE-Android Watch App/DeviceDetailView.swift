import SwiftUI
import CoreBluetooth

struct DeviceDetailView: View {
    @ObservedObject var bluetoothManager: BluetoothManager
    let peripheral: CBPeripheral
    @Environment(\.dismiss) private var dismiss
    @State private var messageToSend: String = ""
    
    var body: some View {
        List {
            // 设备信息
            Section("设备信息") {
                VStack(alignment: .leading) {
                    Text("名称: \(peripheral.name ?? "未知")")
                        .font(.caption2)
                    Text("ID: \(peripheral.identifier.uuidString)")
                        .font(.caption2)
                }
            }
            
            // 服务和特征列表
            Section("服务") {
                if bluetoothManager.discoveredServices.isEmpty {
                    Text("正在搜索服务...")
                        .font(.caption2)
                        .foregroundColor(.gray)
                } else {
                    ForEach(bluetoothManager.discoveredServices, id: \.uuid) { service in
                        VStack(alignment: .leading, spacing: 5) {
                            Text(service.uuid.uuidString)
                                .font(.caption2)
                                .bold()
                            
                            ForEach(bluetoothManager.discoveredCharacteristics.filter { $0.service?.uuid == service.uuid },
                                   id: \.uuid) { characteristic in
                                VStack(alignment: .leading) {
                                    Text(characteristic.uuid.uuidString)
                                        .font(.caption2)
                                    
                                    if characteristic.properties.contains(.notify) {
                                        HStack {
                                            if bluetoothManager.subscribedCharacteristics.contains(characteristic.uuid) {
                                                Button("取消订阅") {
                                                    bluetoothManager.unsubscribeFromCharacteristic(characteristic)
                                                }
                                                .buttonStyle(.bordered)
                                                .tint(.red)
                                                .font(.caption2)
                                            } else {
                                                Button("订阅") {
                                                    bluetoothManager.subscribeToCharacteristic(characteristic)
                                                }
                                                .buttonStyle(.bordered)
                                                .tint(.blue)
                                                .font(.caption2)
                                            }
                                        }
                                        
                                        if let value = bluetoothManager.characteristicValues[characteristic.uuid] {
                                            Text("收到: \(value)")
                                                .font(.caption2)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                                .padding(.leading, 10)
                            }
                        }
                    }
                }
            }
            
            // 发送消息
            if bluetoothManager.canSendData {
                Section("发送消息") {
                    HStack {
                        TextField("输入消息", text: $messageToSend)
                            .font(.caption2)
                    }
                    .padding(.vertical, 4)
                    
                    Button(action: {
                        if !messageToSend.isEmpty {
                            bluetoothManager.sendData(messageToSend)
                            messageToSend = ""
                        }
                    }) {
                        Text("发送")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(.blue)
                    .disabled(messageToSend.isEmpty)
                }
            }
            
            // 断开连接按钮
            Section {
                Button("断开连接", role: .destructive) {
                    bluetoothManager.disconnect()
                    dismiss()
                }
            }
        }
        .navigationTitle("设备详情")
        .onDisappear {
            bluetoothManager.unsubscribeFromAllCharacteristics()
        }
    }
} 