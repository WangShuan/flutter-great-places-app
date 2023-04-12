# great_places_app

主要建立一個紀錄地點的應用程式
使用手機本身的相機/相片與地圖功能保存地點資訊(標題、簡介、地址、地圖快照)

可通過執行 `flutter pub get` 安裝依賴，並開啟任一模擬器，利用 VS Code 的快捷鍵 control + F5 啟動項目。

## 使用 `sqflite` 套件將資料存儲在手機本身的空間裡

首先需要安裝 `sqflite` 套件
接著在專案中新增一個 `helper` 資料夾，於裡面建立 `db_helper.dart` 檔案
引入 `sqflite` 與 `path` 套件，變建立存儲資料相關的方法：
```dart=
import 'package:sqflite/sqflite.dart' as sql; // 引入 sqflite
import 'package:path/path.dart' as path; // 引入 path
import 'package:sqflite/sqlite_api.dart'; // 引入 sqlite_api

class DBHelper {
  static Future<Database> database() async { // 建立方法 database
    final dbPath = await sql.getDatabasesPath(); // 獲取資料庫存儲的路徑
    return sql.openDatabase( // 開啟資料庫(如果資料庫不存在就會建立一個資料庫)
      path.join(dbPath, 'places.db'), // 要開啟的路徑(這邊需要用 path 提供的 join 方法，因為要開啟的不是資料夾而是資料夾中的文件，places.db 就是要開啟的文件名稱)
      onCreate: (db, version) { // 傳入建立資料庫的方法，假設資料庫不存在就會執行此方法建立一個資料庫
        return db.execute( // 使用 db.execute 執行 sql 語句
            'CREATE TABLE user_places(id TEXT PRIMARY KEY, title TEXT, description TEXT, image TEXT, loc_lat REAL, loc_lng REAL, address TEXT)');
      },
      version: 1, // 設置當前版本，假設有更動數據結構則該版本號應該跟著變動
    );
  }

  static Future<void> insert(String table, Map<String, Object> data) async { // 建立方法 insert 以插入數據資料
    final db = await DBHelper.database(); // 獲取資料庫
    db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace); // 使用 db.insert 往資料庫中插入數據(第三個參數來自 sqlite_api，當我們往已存在的 id 中插入數據則通過 ConflictAlgorithm.replace 告知資料庫覆蓋原本的數據)
  }

  static Future<List<Map<String, dynamic>>> getTableData(String table) async { // 建立方法 getTableData 以獲取數據資料
    final db = await DBHelper.database();
    return db.query(table); // 使用 db.query 查詢整個 TABLE 的資料
  }
}
```
>在 `db.insert` 與 `db.query` 中傳入的 `table` 應為 CREATE TABLE 時設置的 TABLE 名稱(即 `user_places`)
>sql 語句解析：
>`CREATE TABLE user_places(id TEXT PRIMARY KEY, title TEXT, description TEXT, image TEXT, loc_lat REAL, loc_lng REAL, address TEXT)`
>CREATE TABLE=>建立TABLE
>user_places=>TABLE的名稱
>user_places()傳入的資料：id 為 TEXT PRIMARY KEY、title 為 TEXT, loc_lat 為 REAL
>每個 TABLE 中只能有一個 PRIMARY KEY，通常為 id
>REAL 等同於 double 小數點的意思

## 使用手機的相機與照片庫

### 安裝與設置 `image_picker` 套件

安裝 `image_picker` 套件以通過相機或照片庫獲取圖片，
安裝後請先根據說明設置好 `/ios/Runner/Info.plist` 檔案內容([參考](https://pub.dev/packages/image_picker#ios))
主要設置內容如下：
```plist=
<key>NSCameraUsageDescription</key>
<string>Places App need to use Camera.</string> // 輸入為什麼要存取相機
<key>NSPhotoLibraryUsageDescription</key>
<string>Places App need to use PhotoLibrary.</string> // 輸入為什麼要存取照片庫
```
>通常都是一個 key配一個 value，在新增上方四行時，
>需注意不要將其放置在某組 key 與 value 的中間。

#### 安裝 `path_provider` 與 `path` 套件以獲取圖片路徑

直接在終端機中輸入 `flutter pub add path` 以及 `flutter pub add path_provider` 即可安裝

#### 使用 `image_picker` 套件開啟相機拍照或相簿選照片，並將照片存到檔案系統中

接著於要使用的 .dart 檔案中引入：
```dard=
import 'dart:io'; // 使用 File 類型須引入 dart:io

import 'package:image_picker/image_picker.dart'; // 使用 ImagePicker
import 'package:path/path.dart' as path; // 用於各種 path 相關的方法
import 'package:path_provider/path_provider.dart' as syspaths; // 獲取常用的檔案系統路徑(這邊用於獲取應用程式的文檔目錄)
```

創建一個獲取圖片的函數：
```dart=
Future<void> _takePicture([isCamera = false]) async { // 創建一個 Future 類型的函數
  final imageFile = await ImagePicker().pickImage( // picker.pickImage 為 Future 類型，需加上 await
    source: ImageSource.camera, // 開啟相機拍攝照片
    maxWidth: 500, // 設置照片最大寬度
  );
  if (imageFile == null) { // 假設點進去又反悔，沒拍照，則 return 
    return;
  }
  final appDir = await syspaths.getApplicationDocumentsDirectory(); // 獲取應用程式的文檔目錄路徑
  final fileName = path.basename(imageFile.path); // 獲取圖片的名稱
  final savedImage = await _storedImage.copy('${appDir.path}/$fileName'); // 將圖片拷貝到應用程式的文檔目錄中
}
```
並於用來當拍攝照片的按鈕小部件中的 onTap() 設置為剛才創建一個獲取圖片的函數
>假設不是拍攝照片，而是從照片庫中選擇照片，
>則將 `ImageSource.camera` 改為 `ImageSource.gallery` 即可

## 使用手機的地圖

### 安裝與設置 `location` 套件

安裝 `location` 套件以通過地圖獲取經緯度
安裝後請先根據說明設置好 `/ios/Runner/Info.plist` 檔案內容([參考](https://pub.dev/packages/location#ios))
主要設置內容如下：
```plist=
<key>NSLocationWhenInUseUsageDescription<key>
<string>Places App need to use Location.</string> // 輸入為什麼要存取位置
<key>NSLocationAlwaysAndWhenInUseUsageDescription<key>
<string>Places App need to use Location.</string> // 輸入為什麼要存取位置
```
>通常都是一個 key配一個 value，在新增上方四行時，
>需注意不要將其放置在某組 key 與 value 的中間。

接著針對 Android 也須設置好 `/android/app/src/main/AndroidManifest.xml` 檔案內容([參考](https://pub.dev/packages/location#android))
主要設置內容如下：
```xml=
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION"/>
```
>`<uses-permission>` 標籤必須放在 `<manifest>` 標籤裡面，且位在 `<application>` 標籤之上

#### 使用 `Location` 套件獲取用戶當前位置

建立一個函數 `_getUserLocation`，通過 Location().getLocation() 獲取用戶當前位置：
```javascript=
Future<void> _getUserLocation() async {
  try {
    final locData = await Location().getLocation();
  } catch (err) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('無法取得當前位置。')),
    );
    return;
  }
}
```

#### 安裝與設置 `google_maps_flutter` 套件

安裝 `google_maps_flutter` 套件以使用 Google Map

這邊需要先獲取 GOOGLE MAPS API KEY：
1. 請進入[此官網](https://mapsplatform.google.com/)點擊 `Get started`
2. 登入你的 google 帳號，按照提示建立好信用卡資料開啟免費試用

完成後會看到 `API 金鑰`，請先將其複製到專案中存放
接著回到專案中，按照說明文件設置好 `android/app/build.gradle` 檔案內容([參考](https://pub.dev/packages/google_maps_flutter#android))
並在 `android/app/src/main/AndroidManifest.xml` 檔案內容中放置你的 API 金鑰
```xml=
<meta-data android:name="com.google.android.geo.API_KEY"
           android:value="YOUR KEY HERE"/>
```
>`<meta-data>` 標籤必須放在 `<application>` 標籤裡面
針對 IOS 也按照說明文件設置好 `ios/Runner/AppDelegate.m` 或 `ios/Runner/AppDelegate.swift` 檔案
>這邊可以看自己的專案中有無 `.m` 檔，如無就設置 `.swift` 檔即可

#### 使用 `.env` 保存 `API KEY` 並在 `.xml` 中傳遞 `API KEY`

1. 安裝 `flutter_config` 套件，並在專案的根目錄中新增 `.env` 檔案
2. 將 `GOOGLE_API_KEY` 存放到 `.env` 檔案中 `GOOGLE_API_KEY=balabalabalabala-balabala-balabala`
3. 開啟 `android/app/build.gradle` 檔案，在 `apply from: "$flutterRoot/packages/flutter_tools/gradle/flutter.gradle"` 下方新增一行 `apply from: project(':flutter_config').projectDir.getPath() + "/dotenv.gradle"`
4. 拷貝 `defaultConfig` 中的 `applicationId` 內容
5. 建立檔案 `android/app/proguard-rules.pro` ，裡面放入 `-keep applicationId的值.BuildConfig { *; }`(EX:`-keep class com.example.places_app.BuildConfig { *; }`)
6. 在 `android/app/src/main/AndroidManifest.xml` 檔案中改寫為 `<meta-data android:name="com.google.android.geo.API_KEY" android:value="@string/GOOGLE_API_KEY"/>`
>以上參考 [Android 設置說明](https://github.com/ByneappLLC/flutter_config/blob/master/doc/ANDROID.md)
>(感謝估狗大神)

#### 使用 `Maps Static API` 獲取地圖快照

這邊需要使用 `Maps Static API` 生成地圖預覽(可參考[官方說明文件](https://developers.google.com/maps/documentation/maps-static/start?hl=zh-tw))
首先建立一個函數 `locationPreviewImg` ，可傳入參數 `lat` 與 `long`(經緯度)
接著從官方說明文件中拷貝一個範例進行修改，作為函數要回傳的值：
```htmlembedded=
static String locationPreviewImg({double long, double lat}) {
  return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$long&scale=2&zoom=15&size=400x300&key=$googleApiKey&markers=color:red%7Clabel:%7C$lat%2C$long';
}
```

#### 使用 `Geocoding API` 獲取完整地址

這邊需要使用 `Geocoding API` 的『反向地理編碼』利用經緯度取得完整地址(可參考[官方說明文件](https://developers.google.com/maps/documentation/geocoding/start?hl=zh-tw#reverse))
首先安裝 `http` 套件以用來發送 HTTP Request
接著建立一個函數 `getAddressByLatLng` ，可傳入參數 `lat` 與 `long`(經緯度)：
```javascript=
static Future<String> getAddressByLatLng(double lat, double lng) async {
  final url = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
    "latlng": "$lat,$lng", // 傳入經緯度
    "key": googleApiKey, // 傳入 API KEY
    "language": "zh-TW", // 設置語系
  });
  final res = await http.get(url); // 發送請求
  return json.decode(res.body)['results'][0]['formatted_address']; // 獲取完整地址
}
```

#### 使用 `google_maps_flutter` 套件開啟地圖

`google_maps_flutter` 套件提供了 `GoogleMap` 小部件用以顯示地圖
使用方式如下：
```dart=
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('地圖'),
      actions: [
        if (widget.isSelecting && _markerLocation != null)
          IconButton(
            onPressed: () {
              Navigator.of(context).pop(_markerLocation);
            },
            icon: const Icon(Icons.check),
          )
      ],
    ),
    body: GoogleMap( // 使用 GoogleMap 小部件
      initialCameraPosition: CameraPosition( // 設置地圖預設位置
        target: LatLng(widget.initLat, widget.initLng),
        zoom: 16, // 設置縮放程度
      ),
      onTap: widget.isSelecting ? _selectedLocation : null, // 點擊地圖上某個位置後要執行的動作
      markers: (_markerLocation == null && widget.isSelecting) // 在地圖上標記一個位置
        ? {} // 如果沒選取位置則回傳空物件 {} 給 markers
        : {
            Marker(
              markerId: const MarkerId('m1'), // 設置 ID
              position: _markerLocation ?? LatLng(widget.initLat, widget.initLng),
            ),
          },
    ),
  );
}
```

## 使用真實設備進行測試的方式(iPhone 為主)

1. 將 iPhone 使用 USB 的方式連結電腦，並依序點擊信任此裝置、輸入手機密碼等等，
2. 開啟電腦的 Xcode 應用程式，點擊 “Open a project or file” ，選擇想開啟的 Flutter 專案底下的 ios 資料夾
3. 在 Xcode 上方選單列中的 Device 中選擇你的 iPhone
4. 在 Xcode 左側選單中點選 Runner ，檢查 Signing 是否有選擇 Team (沒有的話就用自己的 apple ID 申請一個)
5. 在 Xcode 中點擊左上角的播放鍵進行 build
    a. 假設出現 “build failed” ，請開啟終端機 cd 到想開啟的 Flutter 專案目錄中，執行 `flutter clean` 再執行 `flutter build ios`
    b. 假設出現錯誤 “Error (Xcode): No profiles for 'com.example.xxxxApp' were found: Xcode couldn't find any iOS App Development” 則將 Team 下方的 Bundle Identifier 更新成唯一的值(比如加上自己的名字之類的)，再重新執行一次 `flutter build ios`
6. 完成後手機會出現 Flutter APP 的 icon，但開啟失敗，並顯示提示 “開發者不受裝置信任的通知”，此時請到手機的 “設定>一般>VPN與裝置管理” 將自己的開發者帳號設為信任
7. 再次回到 Xcode 中點擊一次播放鍵，即可成功開啟 APP 進行實測