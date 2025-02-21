import SwiftUI
import CoreBluetooth

struct DeviceDetailView: View {
    @ObservedObject var bluetoothManager: BluetoothManager
    let peripheral: CBPeripheral
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("设备信息")) {
                    Text("名称: \(peripheral.name ?? "未知设备")")
                    Text("ID: \(peripheral.identifier.uuidString)")
                }
                
                Section(header: Text("服务")) {
                    ForEach(bluetoothManager.discoveredServices, id: \.uuid) { service in
                        VStack(alignment: .leading) {
                            Text("服务: \(service.uuid.uuidString)")
                                .font(.headline)
                            
                            ForEach(bluetoothManager.discoveredCharacteristics.filter { $0.service?.uuid == service.uuid },
                                   id: \.uuid) { characteristic in
                                VStack(alignment: .leading) {
                                    Text("特性: \(characteristic.uuid.uuidString)")
                                        .font(.subheadline)
                                    
                                    if characteristic.properties.contains(.notify) {
                                        Button("订阅数据") {
                                            peripheral.setNotifyValue(true, for: characteristic)
                                        }
                                    }
                                }
                                .padding(.leading)
                            }
                        }
                    }
                }
                
                Section(header: Text("IMU数据")) {
                    Text(bluetoothManager.imuData)
                }
            }
            .navigationTitle("设备详情")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("断开连接") {
                        bluetoothManager.disconnect()
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
} 