import SwiftUI
import CoreBluetooth

struct DeviceListView: View {
    @StateObject private var bluetoothManager = BluetoothManager()
    @State private var showingDeviceDetails = false
    @State private var selectedPeripheral: CBPeripheral?
    
    var body: some View {
        NavigationStack {
            List {
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
                }
            }
        }
    }
} 