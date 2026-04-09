# Universal Exploration Methodology

從 explore-site 實戰經驗提取的通用探索方法論。
適用於任何需要自動化的目標：網站 UI、REST API、CLI 工具、檔案處理、外部服務。

---

## 7-Phase Universal Exploration

```
Phase 1: Requirements     — 要自動化什麼？輸入/輸出是什麼？
Phase 2: Discovery Plan   — 列出要找的元素/端點/操作清單（checklist）
Phase 3: Environment      — 建立執行環境（auth / config / dependencies）
Phase 4: Exploration      — 核心迴圈：試 → 驗證 → 記錄 → 下一項
Phase 5: Integration      — 發現 API、事件、檔案格式、CLI flags
Phase 6: Build            — 從發現中產出 artifact
Phase 7: Verify           — 端到端測試
```

---

## Phase 4: Core Loop（最重要）

這是整個方法論的核心。不管目標是什麼，都用這個迴圈：

```
1. 觀察當前狀態（screenshot / output / response）
2. 假設操作方式（selector / endpoint / command）
3. 測試假設
4. 驗證結果
5. 成功 → 記錄到 discovery notes
   失敗 → 調整假設 → 回到 3
6. 下一個 checklist 項目
```

### 核心原則

- **一次只探索一個元素** — 不要同時測試多個東西
- **每次操作前後都留證據** — screenshot / log / response dump
- **Discovery notes 是核心產出** — 不是程式碼，是記錄
- **假設 → 測試 → 驗證 → 記錄** — 永遠不要跳過驗證

---

## Target-Specific Strategies

| Target | Phase 4 Method | Phase 5 Discovery | Phase 6 Output |
|--------|---------------|-------------------|----------------|
| Browser UI | screenshot → selector → test | intercept network requests | plugin / automation script |
| REST API | read docs → try endpoint → verify | auth flow, rate limits, pagination | API wrapper |
| CLI tool | read help → try flags → verify | pipe, file format, exit codes | shell script |
| File processing | analyze format → try transform → verify | batch processing, error handling | processing script |
| External service | read SDK → try call → verify | webhook, async, quota | service integration |

---

## Browser UI Exploration

### Phase 3: Environment Setup

```javascript
// 標準探索腳本結構
import { chromium } from 'playwright';

const browser = await chromium.launch({ headless: false, channel: 'chrome' });
const context = await browser.newContext({ storageState: AUTH_FILE });
const page = await context.newPage();
await page.setViewportSize({ width: 1440, height: 900 });
await page.goto(URL, { waitUntil: 'domcontentloaded' });
await page.waitForTimeout(5000);
```

### Phase 4: UI Element Discovery

每個 UI 元素的探索流程：

1. Screenshot 當前頁面
2. 辨識目標元素的位置和類型
3. 偵測 UI framework：
   ```javascript
   const framework = await page.evaluate(() => {
     if (document.querySelector('.ant-select')) return 'Ant Design';
     if (document.querySelector('.lv-select')) return 'Arco Design';
     if (document.querySelector('[class*="MuiSelect"]')) return 'Material UI';
     if (document.querySelector('select')) return 'native select';
     return 'unknown';
   });
   ```
4. 列出 selector candidates，逐一測試
5. 確認 visible + clickable + 功能正常
6. 記錄到 discovery notes

### Phase 5: API Interception

```javascript
// 攔截所有 POST 請求
page.on('request', (req) => {
  if (req.method() === 'POST' && !req.url().includes('analytics')) {
    console.log(`POST ${req.url()}`);
    console.log(`Body: ${req.postData()?.slice(0, 500)}`);
  }
});
```

記錄：endpoint URL、request body 結構、response body 結構、status codes。

### Browser-Specific Gotchas

這些是從 explore-site（即夢 AI）實戰中踩出來的坑：

1. **不用 `networkidle`** — AI 生成網站有持久 WebSocket/polling，`networkidle` 永遠不會觸發。用 `domcontentloaded` + `waitForTimeout`。
2. **Modal/popup 先清掉** — 會 block 一切操作。用 `page.evaluate(() => el.remove())` 移除。
3. **React/Vue selects 需要 Playwright `.click()`** — `page.mouse.click()` 和 JS `.click()` 在合成事件組件上常常失敗。
4. **contenteditable 編輯器需要 `keyboard.type()`** — `.fill()` 對 TipTap、ProseMirror、Slate 等無效。
5. **Class names with hashes 會變** — 用 `[class*="partial-name"]` 而不是完整 class name。
6. **`force: true` 是你的朋友** — overlays 和隱形層常常擋住 click。
7. **Upload inputs 可能是隱藏的** — 用 `setInputFiles()` 即使 input 不可見。
8. **API calls 需要 page cookies** — 用 `page.evaluate(() => fetch(...))` 而不是 Node.js fetch。
9. **每次操作都 screenshot** — 操作前和操作後，用來驗證狀態。
10. **Upload 後要等** — 檔案處理是 async 的，`waitForTimeout(3000-5000)` after `setInputFiles`。

---

## REST API Exploration

### Phase 3: Environment Setup

- 取得 API key / OAuth token
- 確認 base URL + API version
- 安裝 HTTP client（curl / httpie / SDK）

### Phase 4: Endpoint Discovery

```
1. 讀 API 文件（如果有）
2. 試 endpoint：curl -X GET {base_url}/{resource}
3. 檢查 response status + body
4. 記錄：URL, method, headers, body, response schema
5. 下一個 endpoint
```

### Phase 5: Integration Discovery

- Auth flow（API key / OAuth / JWT）
- Rate limits（headers: X-RateLimit-*）
- Pagination（offset / cursor / link header）
- Error format（status codes + error body structure）
- Webhook support（如果有）

---

## CLI Tool Exploration

### Phase 4: Command Discovery

```
1. 讀 help：{tool} --help / {tool} -h / man {tool}
2. 列出 subcommands 和 flags
3. 試最基本的用法
4. 逐一加 flag，觀察輸出變化
5. 記錄：command, flags, input format, output format, exit codes
```

### Phase 5: Integration Discovery

- Pipe support（stdin / stdout）
- Config file format + location
- Environment variables
- Exit codes meaning
- Output format（JSON / text / table）

---

## File Processing Exploration

### Phase 4: Format Discovery

```
1. 取得 sample files
2. 分析 file format（binary header / text encoding / structure）
3. 試 parse / transform
4. 驗證 output 正確性
5. 記錄：format spec, parsing method, edge cases
```

### Phase 5: Integration Discovery

- Batch processing capability
- Memory / performance limits
- Error handling（corrupt files, encoding issues）
- Output format options

---

## Discovery Notes Template

每次探索都要維護一個 discovery notes 文件：

```markdown
# {Target} Exploration Notes

## Requirements
- [summary from Phase 1]

## Checklist
- [ ] item 1
- [ ] item 2
- ...

## Discoveries

### {Element/Endpoint/Command Name}
- Type: {component type / HTTP method / command}
- Selector/URL/Command: {exact value}
- Method: {how to interact}
- Tested: YES/NO
- Notes: {edge cases, gotchas}
```

---

## STOP Gates

| Phase | Gate |
|-------|------|
| Phase 1 | 用戶確認需求理解正確 |
| Phase 3 | 環境可用、auth 可用 |
| Phase 4 | 每 3 個 discovery 暫停，回報進度 |
| Phase 7 | 端到端測試通過 |

---

## 外部 CLI 整合常見踩坑模式

以下是從實戰中歸納的通用踩坑模式，不限特定工具：

| 模式 | 描述 | 繞過策略 |
|------|------|---------|
| 路徑解析 | 工具安裝在非標準路徑，或 shell 展開 `~` 不一致 | 用絕對路徑或複製到已知位置 |
| 版本不符 | 文件描述 v2 但安裝的是 v1 | 用 `--version` 確認，固定在已測試版本 |
| 未記載 Flag | 常用 flag 不在 `--help` 裡 | 試錯 + 讀 source code + 社群搜尋 |
| 並行上限 | 工具允許 N 但 N+1 時崩潰或靜默失敗 | 實測找出真實上限，寫入 config |
| 間歇性失敗 | 操作 80% 成功 20% 失敗，無明確原因 | 加入重試機制 + 記錄失敗模式 |
| 產出 URL 過期 | 下載連結在 N 小時後失效 | 成功後立即下載，不存 URL |
| 上傳路徑限制 | 某些路徑格式工具不接受 | 統一複製到工具接受的路徑再上傳 |
| 認證靜默失效 | Token 過期但不回傳錯誤，只回空結果 | 每次執行前先做 health check |
