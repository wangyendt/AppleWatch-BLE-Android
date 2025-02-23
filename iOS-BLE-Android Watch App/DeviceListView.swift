import SwiftUI
import CoreBluetooth

struct DeviceListView: View {
    @StateObject private var bluetoothManager = BluetoothManager()
    @State private var showingDeviceDetails = false
    @State private var selectedPeripheral: CBPeripheral?
    
    var body: some View {
        NavigationStack {
            List {
                if bluetoothManager.discoveredPeripherals.isEmpty {
                    Text(bluetoothManager.isScanning ? "正在扫描..." : "未发现设备")
                        .foregroundColor(.gray)
                }
                
                ForEach(bluetoothManager.discoveredPeripherals, id: \.identifier) { peripheral in
                    VStack(alignment: .leading) {
                        NavigationLink {
                            DeviceDetailView(bluetoothManager: bluetoothManager, peripheral: peripheral)
                                .onAppear {
                                    bluetoothManager.connect(to: peripheral)
                                }
                        } label: {
                            VStack(alignment: .leading) {
                                Text(peripheral.name ?? "未知设备")
                                    .font(.headline)
                                Text(peripheral.identifier.uuidString)
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                                if let details = bluetoothManager.deviceDetails[peripheral.identifier.uuidString] {
                                    Text(details)
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("BLE设备")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        if bluetoothManager.isScanning {
                            bluetoothManager.stopScanning()
                        } else {
                            bluetoothManager.startScanning()
                        }
                    }) {
                        Image(systemName: bluetoothManager.isScanning ? "stop.circle.fill" : "arrow.clockwise.circle.fill")
                    }
                    .tint(bluetoothManager.isScanning ? .red : .blue)
                }
            }
            .onChange(of: bluetoothManager.isScanning) { scanning in
                if scanning {
                    WKInterfaceDevice.current().play(.click)
                }
            }
        }
    }
} 