package com.wayne.android_as_ble;

import android.Manifest;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothManager;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.widget.TextView;
import android.widget.Toast;

import androidx.activity.EdgeToEdge;
import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

public class MainActivity extends AppCompatActivity implements BlePeripheralService.BleCallback {

    private BluetoothAdapter bluetoothAdapter;
    private BlePeripheralService blePeripheralService;
    private static final int PERMISSION_REQUEST_CODE = 1;
    private MessageAdapter messageAdapter;
    private TextView statusText;
    private TextView counterText;

    private final ActivityResultLauncher<Intent> enableBtLauncher = registerForActivityResult(
            new ActivityResultContracts.StartActivityForResult(),
            result -> {
                if (result.getResultCode() == RESULT_OK) {
                    startBlePeripheral();
                } else {
                    Toast.makeText(this, "需要开启蓝牙才能使用此功能", Toast.LENGTH_SHORT).show();
                }
            });

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_main);

        // 初始化视图
        statusText = findViewById(R.id.statusText);
        counterText = findViewById(R.id.counterText);
        RecyclerView messageList = findViewById(R.id.messageList);
        messageAdapter = new MessageAdapter();
        messageList.setLayoutManager(new LinearLayoutManager(this));
        messageList.setAdapter(messageAdapter);

        BluetoothManager bluetoothManager = (BluetoothManager) getSystemService(Context.BLUETOOTH_SERVICE);
        bluetoothAdapter = bluetoothManager.getAdapter();

        if (bluetoothAdapter == null) {
            Toast.makeText(this, "此设备不支持蓝牙", Toast.LENGTH_SHORT).show();
            finish();
            return;
        }

        checkPermissionsAndStart();
    }

    private void checkPermissionsAndStart() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            String[] permissions = {
                    Manifest.permission.BLUETOOTH_ADVERTISE,
                    Manifest.permission.BLUETOOTH_CONNECT,
                    Manifest.permission.ACCESS_FINE_LOCATION
            };
            requestPermissions(permissions);
        } else {
            String[] permissions = {
                    Manifest.permission.ACCESS_FINE_LOCATION
            };
            requestPermissions(permissions);
        }
    }

    private void requestPermissions(String[] permissions) {
        boolean allGranted = true;
        for (String permission : permissions) {
            if (ActivityCompat.checkSelfPermission(this, permission) != PackageManager.PERMISSION_GRANTED) {
                allGranted = false;
                break;
            }
        }

        if (allGranted) {
            enableBluetooth();
        } else {
            ActivityCompat.requestPermissions(this, permissions, PERMISSION_REQUEST_CODE);
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == PERMISSION_REQUEST_CODE) {
            boolean allGranted = true;
            for (int result : grantResults) {
                if (result != PackageManager.PERMISSION_GRANTED) {
                    allGranted = false;
                    break;
                }
            }

            if (allGranted) {
                enableBluetooth();
            } else {
                Toast.makeText(this, "需要相关权限才能使用此功能", Toast.LENGTH_SHORT).show();
            }
        }
    }

    private void enableBluetooth() {
        if (!bluetoothAdapter.isEnabled()) {
            Intent enableBtIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
            enableBtLauncher.launch(enableBtIntent);
        } else {
            startBlePeripheral();
        }
    }

    private void startBlePeripheral() {
        blePeripheralService = new BlePeripheralService(this);
        blePeripheralService.setCallback(this);
        blePeripheralService.startAdvertising();
        statusText.setText("BLE外围设备已启动");
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (blePeripheralService != null) {
            blePeripheralService.stop();
        }
    }

    @Override
    public void onDeviceConnected(String deviceAddress) {
        runOnUiThread(() -> {
            statusText.setText("设备已连接: " + deviceAddress);
            Toast.makeText(this, "设备已连接", Toast.LENGTH_SHORT).show();
        });
    }

    @Override
    public void onDeviceDisconnected(String deviceAddress) {
        runOnUiThread(() -> {
            statusText.setText("设备已断开连接");
            Toast.makeText(this, "设备已断开连接", Toast.LENGTH_SHORT).show();
        });
    }

    @Override
    public void onCounterUpdated(int value) {
        runOnUiThread(() -> counterText.setText("当前计数: " + value));
    }

    @Override
    public void onMessageReceived(String message) {
        runOnUiThread(() -> {
            messageAdapter.addMessage(message);
            Toast.makeText(this, "收到消息: " + message, Toast.LENGTH_SHORT).show();
        });
    }
}