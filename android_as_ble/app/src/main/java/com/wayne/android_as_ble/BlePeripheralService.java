package com.wayne.android_as_ble;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothGatt;
import android.bluetooth.BluetoothGattCharacteristic;
import android.bluetooth.BluetoothGattServer;
import android.bluetooth.BluetoothGattServerCallback;
import android.bluetooth.BluetoothGattService;
import android.bluetooth.BluetoothManager;
import android.bluetooth.le.AdvertiseCallback;
import android.bluetooth.le.AdvertiseData;
import android.bluetooth.le.AdvertiseSettings;
import android.bluetooth.le.BluetoothLeAdvertiser;
import android.content.Context;
import android.os.Handler;
import android.os.ParcelUuid;
import android.util.Log;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class BlePeripheralService {
    private static final String TAG = "BlePeripheralService";

    // 自定义UUID
    public static final UUID SERVICE_UUID = UUID.fromString("0000180D-0000-1000-8000-00805F9B34FB");
    public static final UUID CHARACTERISTIC_UUID = UUID.fromString("00002A37-0000-1000-8000-00805F9B34FB");

    private Context context;
    private BluetoothManager bluetoothManager;
    private BluetoothAdapter bluetoothAdapter;
    private BluetoothLeAdvertiser advertiser;
    private BluetoothGattServer gattServer;
    private List<BluetoothDevice> connectedDevices = new ArrayList<>();

    private int currentValue = 0;
    private Handler handler = new Handler();
    private boolean isRunning = false;

    public BlePeripheralService(Context context) {
        this.context = context;
        bluetoothManager = (BluetoothManager) context.getSystemService(Context.BLUETOOTH_SERVICE);
        bluetoothAdapter = bluetoothManager.getAdapter();
    }

    public void startAdvertising() {
        advertiser = bluetoothAdapter.getBluetoothLeAdvertiser();
        if (advertiser == null) {
            Log.e(TAG, "设备不支持BLE广播");
            return;
        }

        AdvertiseSettings settings = new AdvertiseSettings.Builder()
                .setAdvertiseMode(AdvertiseSettings.ADVERTISE_MODE_LOW_LATENCY)
                .setConnectable(true)
                .setTimeout(0)
                .setTxPowerLevel(AdvertiseSettings.ADVERTISE_TX_POWER_HIGH)
                .build();

        AdvertiseData data = new AdvertiseData.Builder()
                .setIncludeDeviceName(true)
                .addServiceUuid(new ParcelUuid(SERVICE_UUID))
                .build();

        advertiser.startAdvertising(settings, data, advertiseCallback);
        startGattServer();
    }

    private void startGattServer() {
        gattServer = bluetoothManager.openGattServer(context, gattServerCallback);
        BluetoothGattService service = new BluetoothGattService(SERVICE_UUID, BluetoothGattService.SERVICE_TYPE_PRIMARY);
        
        BluetoothGattCharacteristic characteristic = new BluetoothGattCharacteristic(
                CHARACTERISTIC_UUID,
                BluetoothGattCharacteristic.PROPERTY_READ | BluetoothGattCharacteristic.PROPERTY_NOTIFY,
                BluetoothGattCharacteristic.PERMISSION_READ
        );
        
        service.addCharacteristic(characteristic);
        gattServer.addService(service);
        startValueUpdates();
    }

    private void startValueUpdates() {
        isRunning = true;
        handler.postDelayed(new Runnable() {
            @Override
            public void run() {
                if (!isRunning) return;
                
                currentValue = (currentValue + 1) % 1000;
                notifyValueChanged();
                handler.postDelayed(this, 100); // 每100毫秒更新一次
            }
        }, 100);
    }

    private void notifyValueChanged() {
        if (connectedDevices.isEmpty()) return;

        BluetoothGattCharacteristic characteristic = gattServer
                .getService(SERVICE_UUID)
                .getCharacteristic(CHARACTERISTIC_UUID);

        byte[] value = String.valueOf(currentValue).getBytes();
        characteristic.setValue(value);

        for (BluetoothDevice device : connectedDevices) {
            gattServer.notifyCharacteristicChanged(device, characteristic, false);
        }
    }

    public void stop() {
        isRunning = false;
        if (advertiser != null) {
            advertiser.stopAdvertising(advertiseCallback);
        }
        if (gattServer != null) {
            gattServer.close();
        }
        connectedDevices.clear();
    }

    private final AdvertiseCallback advertiseCallback = new AdvertiseCallback() {
        @Override
        public void onStartSuccess(AdvertiseSettings settingsInEffect) {
            Log.i(TAG, "BLE广播已启动");
        }

        @Override
        public void onStartFailure(int errorCode) {
            Log.e(TAG, "BLE广播启动失败: " + errorCode);
        }
    };

    private final BluetoothGattServerCallback gattServerCallback = new BluetoothGattServerCallback() {
        @Override
        public void onConnectionStateChange(BluetoothDevice device, int status, int newState) {
            if (newState == BluetoothGatt.STATE_CONNECTED) {
                connectedDevices.add(device);
                Log.i(TAG, "设备已连接: " + device.getAddress());
            } else if (newState == BluetoothGatt.STATE_DISCONNECTED) {
                connectedDevices.remove(device);
                Log.i(TAG, "设备已断开: " + device.getAddress());
            }
        }
    };
} 