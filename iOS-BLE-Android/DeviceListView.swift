import SwiftUI
import CoreBluetooth

struct DeviceListView: View {
    @StateObject private var bluetoothManager = BluetoothManager()
    @State private var showingDeviceDetail = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(bluetoothManager.discoveredPeripherals, id: \.identifier) { peripheral in
                    Button(action: {
                        bluetoothManager.connect(to: peripheral)
                        showingDeviceDetail = true
                    }) {
                        VStack(alignment: .leading) {
                            Text(peripheral.name ?? "未知设备")
                                .font(.headline)
                            Text(peripheral.identifier.uuidString)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("BLE设备")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if bluetoothManager.isScanning {
                            bluetoothManager.stopScanning()
                        } else {
                            bluetoothManager.startScanning()
                        }
                    }) {
                        Text(bluetoothManager.isScanning ? "停止扫描" : "开始扫描")
                    }
                }
            }
            .sheet(isPresented: $showingDeviceDetail) {
                if let peripheral = bluetoothManager.connectedPeripheral {
                    DeviceDetailView(bluetoothManager: bluetoothManager, peripheral: peripheral)
                }
            }
        }
    }
} 