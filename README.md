# iOS Simulator Skill

一個讓 **Claude Code / GitHub Copilot** 直接控制 iOS Simulator 的 Shell Script 工具集。
優化 Flutter iOS App 的開發、測試、部署流程。

## 核心原則：優先用 screen_map，而非截圖

| 方式 | Token 消耗 | 使用時機 |
|------|-----------|---------|
| `screen_map.sh` | ~10 tokens | 查看 UI 元素、決定點哪裡 |
| `screenshot.sh --size quarter` | ~800 tokens | 確認佈局 |
| `screenshot.sh --size half` | ~1,600 tokens | 視覺驗證（預設） |
| `screenshot.sh --size full` | 數千 tokens | 需要像素級細節時才用 |

## 可用 Scripts

| Script | 功能 |
|--------|------|
| `health_check.sh` | 檢查環境與依賴 |
| `list_simulators.sh` | 列出所有 simulator（JSON） |
| `boot.sh` | 啟動 simulator（名稱或 UDID） |
| `screenshot.sh` | 截圖（full / half / quarter） |
| `screen_map.sh` | 讀取 UI 元素，不需截圖 |
| `tap.sh` | 點擊座標 |
| `swipe.sh` | 滑動手勢 |
| `type_text.sh` | 輸入文字 |
| `install_app.sh` | 安裝 .app bundle |
| `launch_app.sh` | 啟動 App |
| `logs.sh` | 查看 Log（可過濾 severity / bundle_id） |
| `set_status_bar.sh` | 設定狀態列（clean preset） |
| `flutter_build.sh` | Flutter build for simulator |
| `flutter_run.sh` | Flutter run on simulator |
| `flutter_test.sh` | 執行 Flutter 測試 |

## 環境需求

- macOS 14+
- Xcode + iOS Simulator（`xcode-select --install`）
- Flutter（可選，用於 flutter_*.sh）
- idb（可選，但強烈建議）

### 安裝 idb（強烈建議）

idb 讓 `tap.sh`、`swipe.sh`、`screen_map.sh` 發揮完整功能：

```bash
brew install idb-companion
pip install fb-idb
```

> 沒有 idb 時，部分腳本 fallback 到 AppleScript（精度較低）。

### 確認環境

```bash
bash scripts/health_check.sh
```

---

## Scripts 使用說明

### List / Boot Simulator

```bash
bash scripts/list_simulators.sh
# 回傳 JSON: [{name, udid, state, runtime}]

bash scripts/boot.sh "iPhone 16 Pro"
bash scripts/boot.sh "A1B2C3D4-1234-1234-1234-A1B2C3D4E5F6"
```

### 截圖

```bash
bash scripts/screenshot.sh                       # half size（預設）
bash scripts/screenshot.sh --size quarter        # 省 token
bash scripts/screenshot.sh --size full           # 像素級細節
bash scripts/screenshot.sh --udid "iPhone 16 Pro" --size half
```

### 讀取 UI 元素（無截圖）

```bash
bash scripts/screen_map.sh           # 列出所有互動元素
bash scripts/screen_map.sh --verbose # 含座標
```

### 點擊 / 滑動

```bash
# 座標為邏輯點（points），iPhone 16 Pro 為 393 × 852 pts
bash scripts/tap.sh 196 400
bash scripts/swipe.sh 196 600 196 200            # 向上滑
bash scripts/swipe.sh 196 600 196 200 --duration 0.5
```

### 輸入文字

```bash
bash scripts/tap.sh 196 300                      # 先點欄位
bash scripts/type_text.sh "hello@example.com"
```

### App 管理

```bash
bash scripts/install_app.sh /path/to/MyApp.app
bash scripts/launch_app.sh com.example.MyApp
```

### 查看 Log

```bash
bash scripts/logs.sh
bash scripts/logs.sh --lines 100 --severity error
bash scripts/logs.sh --bundle com.example.MyApp
```

### 狀態列（截圖前整理）

```bash
bash scripts/set_status_bar.sh --preset clean    # 9:41, 100% 電量, Wi-Fi
bash scripts/set_status_bar.sh --clear
```

### Flutter 操作

```bash
bash scripts/flutter_build.sh /path/to/flutter_project
bash scripts/flutter_build.sh /path/to/flutter_project --mode release
bash scripts/flutter_run.sh /path/to/flutter_project
bash scripts/flutter_run.sh /path/to/flutter_project --udid "iPhone 16 Pro"
bash scripts/flutter_test.sh /path/to/flutter_project
bash scripts/flutter_test.sh /path/to/flutter_project test/widget_test.dart
```

---

## 常用工作流程

### A. Flutter 功能端到端測試

```
1. bash scripts/health_check.sh
2. bash scripts/boot.sh "iPhone 16 Pro"
3. bash scripts/flutter_build.sh /path/to/project
4. bash scripts/install_app.sh /path/to/project/build/ios/iphonesimulator/Runner.app
5. bash scripts/launch_app.sh com.example.myapp
6. bash scripts/screen_map.sh              # 看畫面上有哪些元素
7. bash scripts/tap.sh <x> <y>            # 點擊按鈕
8. bash scripts/screenshot.sh --size half  # 確認結果
```

### B. 截圖（文件 / PR 用）

```
1. bash scripts/set_status_bar.sh --preset clean
2. # 導航到目標畫面
3. bash scripts/screenshot.sh --size half
4. bash scripts/set_status_bar.sh --clear
```

### C. Debug Crash

```
1. bash scripts/launch_app.sh com.example.myapp
2. # 重現 crash
3. bash scripts/logs.sh --lines 200 --severity error --bundle com.example.myapp
```

---

## 座標系統

- 座標單位為 **邏輯點 (points)**，不是像素
- iPhone 16 Pro：**393 × 852 pts**
- iPhone 15 Pro Max：**430 × 932 pts**
- iPhone SE 3rd gen：**375 × 667 pts**

不知道座標時：`screen_map.sh --verbose` 取得元素 frame，計算中心點 `x = frame.x + frame.width/2`。

---

## 故障排除

**"No booted simulator found"**  
→ `bash scripts/boot.sh "iPhone 16 Pro"`

**"idb not found"**  
→ `brew install idb-companion && pip install fb-idb`

**Flutter build 失敗**  
→ `sudo xcodebuild -license accept`  
→ `cd /project && flutter pub get`

**xcrun simctl: No such file or directory**  
→ `xcode-select --install`
