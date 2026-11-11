# 宿舍洗衣日

行動裝置程式設計 Godot 作業，第 10 題：宿舍洗衣間 × 推箱子解謎。

作者：資通四勤 121271020 周柏睿。

## 遊戲規則

用方向鍵、WASD 或畫面上的方向按鈕移動，把洗衣籃推到圓形洗衣機前。只能推，不能拉。三關依序有 1、2、3 個洗衣籃，地形也逐步變難。每關有倒數計時，時間歸零即失敗；三關全過即獲勝。

每關成績為 `max(100, 1000 + 剩餘秒數 × 5 − 步數 × 10)`。推入死角時可按「重置本關」或 R，重置不恢復時間和累計步數。可重玩、回首頁與關閉音效。

## 開啟專案

使用 Godot **4.7.2 標準版**開啟 `project.godot`，按 F6 或 F5 執行。採 Compatibility 算繪器。

主要檔案：

- `main.tscn`、`main.gd`：首頁、遊玩、結算三個畫面與流程。
- `puzzle.gd`：地圖及推箱子規則。
- `board.gd`：棋盤、角色、洗衣籃與操作回饋。
- `assets/`：中文字型、授權及四種音效。
- `docs/`：已匯出的網頁遊戲，GitHub Pages 從 main 分支的 /docs 發布。

## 本機網頁預覽

```sh
python3 -m http.server 8765 --bind 127.0.0.1 --directory docs
```

開啟 http://127.0.0.1:8765/ 。勿直接以檔案方式開啟 index.html。

## 匯出與測試

```sh
bash tools/export.sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script tests/run.gd
```

匯出腳本使用本機 Godot 與相同版本的官方 Web 範本，關閉 Thread Support，輸出至 `docs/index.html`。`.godot/`、`.build/` 不上傳。

測試覆蓋三關解法、阻擋、只能推不能拉、重置、完整過關、逾時、重玩和返回首頁。

## 素材來源

- 字型：[Noto Sans CJK TC](https://github.com/notofonts/noto-cjk)，SIL Open Font License 1.1；完整聲明在 `assets/FONT-LICENSE.txt`。
- 所有圖形由 Godot 程式繪製。
- 四種音效由 `tools/generate_audio.py` 產生，未使用外部音樂或圖片。

## 作業要求對照

首頁含名稱、操作說明、開始按鈕、中文署名與素材來源；具備首頁→遊玩→結算流程、重玩與返回首頁；遊玩顯示時間、步數、歸位進度及分數；關卡增加洗衣籃及障礙；提供視覺回饋及四種音效；方向按鈕支援觸控；遊戲依視窗縮放並保持完整畫面。
