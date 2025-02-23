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
            
            // 服务列表
            Section("服务") {
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
                                    Button("订阅") {
                                        peripheral.setNotifyValue(true, for: characteristic)
                                    }
                                    .buttonStyle(.bordered)
                                    .tint(.blue)
                                    .font(.caption2)
                                }
                            }
                            .padding(.leading, 10)
                        }
                    }
                }
            }
            
            // IMU数据
            Section("IMU数据") {
                Text(bluetoothManager.imuData)
                    .font(.caption2)
                    .multilineTextAlignment(.leading)
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
    }
} 