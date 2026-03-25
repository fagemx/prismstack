# Dual-Layer Guide

`/tool-builder` 的雙層架構指南。進入時先判斷走哪一層，鎖定後不切換。

---

## Layer 1: Hands-on Mode（直接做）

### 什麼時候用

- 用戶要自動化一個**具體目標**
- 用戶要的是**結果**，不是一個工具
- 一次性或特定場景的自動化

### 典型觸發

- "幫我自動化即夢的影片生成"
- "寫一個腳本幫我批次下載這個 API 的資料"
- "自動化這個網站的操作"
- "幫我串接 Stripe API"

### 產出

- Working script / plugin / automation code
- 可直接執行的東西

### 流程

```
Phase 1: Requirements → 問清楚要自動化什麼
Phase 2: Plan        → 讀 exploration-methodology.md，建 checklist
Phase 3: Environment → 建立 auth / config / dependencies
Phase 4: Explore     → Core loop: 試 → 驗證 → 記錄
Phase 5: Integration → 發現 API / events / formats
Phase 6: Build       → 產出 working script/plugin
Phase 7: Verify      → 端到端測試
```

---

## Layer 2: Meta Mode（產出 skill）

### 什麼時候用

- 用戶要一個**可重複使用的工具**
- 用戶會在**多個目標**上使用同一個模式
- 用戶明確說要建一個 skill

### 典型觸發

- "幫我做一個能探索新網站的 skill"
- "建一個工具型 skill"
- "做一個通用的 API 串接 skill"
- "我想要一個能自動化任何網站的 skill"

### 產出

- SKILL.md + references/ + scripts/
- 一個完整的、可被其他人（或未來的自己）使用的 skill

### 流程

```
Phase 1: Design   → 什麼類型的 tool-skill？（browser / API / CLI / etc.）
Phase 2: Structure → 設計 skill 結構（用 exploration-methodology 當 template）
Phase 3: Generate → 產出 SKILL.md + references/ + scripts/
Phase 4: Check    → /skill-check design（7Q）
Phase 5: Wire     → 接進 domain stack
```

---

## Mode Routing

進入 `/tool-builder` 時，解析用戶意圖：

```
"自動化 X"          → Layer 1
"幫我做 X"          → Layer 1
"寫腳本做 X"        → Layer 1
"串接 X API"        → Layer 1

"做一個能做 X 的 skill"  → Layer 2
"建一個工具"             → Layer 2
"做一個通用的 X"         → Layer 2

不確定               → AskUserQuestion
  問：「你要我直接幫你做這件事（Layer 1），
      還是要我建一個可重複使用的 skill 來做這類事（Layer 2）？」
```

### 判斷原則

| 信號 | Layer 1 | Layer 2 |
|------|---------|---------|
| 目標 | 具體的（一個網站、一個 API） | 通用的（一類網站、一類 API） |
| 用詞 | 「幫我做」「自動化這個」 | 「建一個工具」「做一個 skill」 |
| 預期使用次數 | 一次或幾次 | 多次，跨不同目標 |
| 用戶想要的 | 結果 | 能力 |

### 鎖定規則

- 一旦進入某一層，**不切換**
- 如果做到一半發現應該切層 → 完成當前工作 → 告知用戶 → 結束後建議重新啟動另一層
- 絕對不要在 Layer 1 做到一半突然開始產出 SKILL.md
