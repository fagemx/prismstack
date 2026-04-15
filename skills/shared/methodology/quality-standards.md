# 品質標準

> 用途：/skill-check 審查、/skill-edit 修改、/domain-build 生成後驗收。
> 語境：你正在幫用戶判斷他的 skill 品質夠不夠。

---

## 15D Rubric（快速參考版）

完整 15D 已在 skill-check/references/review-15d-6mines.md。這裡是快速參考：

| Layer | Dimensions | 重點 |
|-------|-----------|------|
| A Entry (A1-A3) | Trigger, Role, Mode Routing | 用戶第一秒接觸 |
| B Flow (B4-B6) | Externalization, STOP Gates, Recovery | 執行骨架 |
| C Knowledge (C7-C9) | Gotchas, Scoring, Benchmarks | skill 教 Claude 什麼 |
| D Structure (D10-D12) | Disclosure, Helper Code, Config | 檔案組織 |
| E System (E13-E15) | Discovery, Output, Workflow Position | 生態關係 |

### 每維度 0-2 分

- **0** = 沒有 / 完全缺失
- **1** = 有但不完整或品質不夠
- **2** = 到位

滿分 30 分。分級：**24-30** Production / **18-23** Usable / **12-17** Draft / **0-11** Skeleton

### 各維度判斷基準

**A1 Trigger Description**
- 0 = description 只是功能摘要
- 1 = 有 when to use，沒有 when NOT to use
- 2 = 做什麼 + 何時用 + 何時不用 + 相鄰 skill + trigger phrases

**A2 Role Identity**
- 0 = 沒有明確角色
- 1 = 有但模糊（"you are a helper"）
- 2 = 一句話鎖死（"you are an economy mathematician — show numbers, not feelings"）

**A3 Mode Routing**
- 0 = 一條路到底
- 1 = 有模式但靠 Claude 自己判斷
- 2 = 開頭明確解析 args 或用 AskUserQuestion 路由，鎖死後不回頭

**B4 Task Flow Externalization**
- 0 = 靠 Claude 記憶走流程
- 1 = 有 phase/section 但沒有外部追蹤
- 2 = 用 TodoWrite / driver script / status table / explicit phase gates

**B5 STOP Gates**
- 0 = 沒有 STOP 規則
- 1 = 有但不是每個 section 都有
- 2 = 每個 section 結尾都有 STOP + 明確的 "resolve all before proceeding" + 修改後有 guard check（驗證其他維度沒被破壞）

**B6 Recovery / Interrupt Handling**
- 0 = 沒有
- 1 = 有基本 error handling table
- 2 = 有完整 recovery procedure（怎麼重建狀態、從哪裡續跑）

**C7 Gotchas**
- 0 = 沒有
- 1 = 有 anti-sycophancy forbidden phrases
- 2 = 有操作層面的 gotchas（Claude 做這個任務時具體會犯什麼錯）+ forbidden phrases + forcing questions

**C8 Scoring / Quantitative Rigor**
- 0 = 沒有評分，只有定性判斷
- 1 = 有評分但靠 AI 直覺
- 2 = 有明確公式 + 每個維度有分數 + 分數有校準基準 + 每個分數必須附證據（file:line 或 specific example），禁止「整體不錯」等模糊語言

**C9 Domain Benchmarks**
- 0 = 沒有參考數據
- 1 = 有一些但零散
- 2 = 有結構化的基準表

**D10 Progressive Disclosure**
- 0 = 所有內容在一個 SKILL.md
- 1 = 有 references/ 但只有 1-2 個檔案
- 2 = SKILL.md 是骨架（<200 行），details 在 references/

**D11 Helper Code / Scripts**
- 0 = 純 markdown，且 skill 需要呼叫外部工具但沒有任何呼叫指令
- 1 = Layer 1（純 prompt 驅動）：SKILL.md 直接呼叫專案已有 CLI 或 inline bash（<50 行）
- 2 = Layer 2/3（工具型腳本或批次引擎）：有 scripts/ 目錄、有 CLI 介面、有 exit code 規範

**Layer 判定（參考 skill-craft-guide.md How-To 11）：**
- 專案已有 CLI 且 skill 直接呼叫 → Layer 1 = D11 滿分（不需要多餘的 scripts/）
- 需要封裝 API 客戶端、資料轉換等可重用工具 → Layer 2，需要 scripts/
- 需要批次處理 >10 項任務 → Layer 3，需要 scripts/ + queue.json
- **關鍵：** 不是「有 scripts/ = 分高」，是「用對 Layer = 分高」
- Layer 1 skill 硬加 scripts/ wrapper 反而扣分（過度包裝）
- 需要 Layer 2/3 卻只用 inline bash → D11 最高 1 分

**D12 Config / Memory**
- 0 = 沒有
- 1 = 有 review log 但沒有 per-project config
- 2 = 有 config.json + review history

**E13 Artifact Discovery**
- 0 = 不找上游 artifact，每次從零開始
- 1 = 開頭有 check 但不找其他 skill 的輸出
- 2 = 自動搜尋上游 artifact + 上次 review 紀錄

**E14 Output Contract**
- 0 = 輸出是聊天文字
- 1 = 有 completion summary 但沒有寫到檔案
- 2 = 輸出寫到 projects/（可被下游 skill 讀取）+ structured format

**E15 Workflow Position**
- 0 = 不知道自己在工作流的哪裡
- 1 = 結尾推薦下一個 skill
- 2 = 開頭知道上游是誰（讀 artifact），結尾知道下游是誰（推薦 + 寫 artifact）

### 審查原則（跨維度）

以下原則適用於所有維度的審查：

1. **Evidence Before Score** — 每個 2 分建議附具體證據。Production 審查（24+ 分門檻）中，沒有證據的 2 分降為 1 分。Draft/Usable 審查中不降分，但會標記「建議補證據」。
2. **Guard Awareness** — 修改一個維度時，掃描相鄰維度有沒有被影響（詳見 fix-loop-guide.md 的 Guard Check）。
3. **Mechanical Over Subjective** — 能用數字量化的維度（C8 Scoring、C9 Benchmarks），不接受主觀判斷。

---

## 評分校準基準

**什麼分數長什麼樣（從真實案例萃取）：**

### 10-12/30 = Skeleton
- 有 YAML frontmatter 和基本結構
- 沒有 scoring formula
- 沒有 gotchas
- 不知道上下游
- 例：一個只有 phase 標題但沒有具體指令的 skill

### 15-17/30 = Draft
- 有角色、有 phases、有 STOP gates
- Gotchas 是通識級（不是 Claude-specific）
- Scoring 存在但不嚴格
- 有上下游意識但 artifact discovery 是手動的
- 例：LLM 自動生成的 domain-specific skill（沒經過人工校準）

### 20-22/30 = Usable
- 尖銳角色、explicit scoring formula、Claude-specific gotchas
- Anti-sycophancy 有 deny list + forcing questions
- Artifact discovery 自動化
- Progressive disclosure（SKILL.md + references/）
- 例：經過 1-2 輪迭代的 skill

### 26-30/30 = Production
- 所有維度 >= 1，多數 = 2
- Helper scripts、config.json、review log
- Recovery 完整、state reconstruction
- 經過真實案例測試 + 專家校準

---

## 6 大 Review 原則

### 1. 先分類再判斷
不要直接問「這個 skill 好不好」。先分類：
- 什麼類型？（Review / Bridge / Production / Control / Runtime Helper）
- 然後用該類型的標準判斷

### 2. Scoring 要顯式公式
❌ 「AI 覺得這個 8/10」
✅ 「Trigger: 2/2（有 trigger + anti-trigger + adjacent）, Role: 1/2（有但不夠尖銳）...」

### 3. Action Triage
每個發現分類：
- **AUTO-FIX**：機械問題（格式、命名、缺少 field）→ 直接修
- **ASK**：判斷問題（scoring 公式對不對、gotcha 準不準）→ 問用戶
- **ESCALATE**：結構問題（skill 不該存在、workflow 要重設計）→ 停下來報告

### 4. 結構化提問
用 AskUserQuestion 四段格式（Re-ground / Simplify / Recommend / Options）。一個問題一個問題問。

### 5. 多維度交叉檢查
不要一 pass 看完。分層看：
- Pass 1: Entry + Flow（結構對不對）
- Pass 2: Knowledge + Structure（內容對不對）
- Pass 3: System（串接對不對）

### 6. Anti-Sycophancy
❌ 「This skill is well-structured」
✅ 「A1=2, A2=1（角色寫了但太 generic：'you are a helper' 不是尖銳角色）, A3=0（沒有 mode routing）」

---

## 6 雷區（快速參考）

1. **Generic 包裝** — substitution test：換掉領域名稱還能用 = 踩雷
2. **前深後淺** — 前半段有邏輯，後半段只有「根據以上分析」
3. **Review 當 Production** — 跑完只多報告沒推進工作
4. **缺 Runtime** — skill 寫得好但依賴的工具不存在
5. **過度拆分** — 太薄，單獨沒價值
6. **低密度** — 很長但拿掉大半內容行為不變

---

## Claude 審查時的常見錯誤

- **給所有維度 2/2** → 規則：至少 5 個維度 < 2
- **跳過雷區掃描** → 規則：mandatory，不可跳
- **改進建議太模糊** → 規則：必須指定哪個 section、改什麼、改成什麼樣
- **審完想幫忙改** → 規則：/skill-check 只判斷，改的事交給 /skill-edit

---

## 快速評估模板

```
Skill: _______________

A. 入口層
  A1. Trigger Description:    _/2
  A2. Role Identity:          _/2
  A3. Mode Routing:           _/2

B. 流程層
  B4. Flow Externalization:   _/2
  B5. STOP Gates:             _/2
  B6. Recovery:               _/2

C. 知識層
  C7. Gotchas:                _/2
  C8. Scoring Rigor:          _/2
  C9. Domain Benchmarks:      _/2

D. 結構層
  D10. Progressive Disclosure: _/2
  D11. Helper Code:            _/2
  D12. Config / Memory:        _/2

E. 系統層
  E13. Artifact Discovery:     _/2
  E14. Output Contract:        _/2
  E15. Workflow Position:       _/2

TOTAL:                         _/30
Grade: Skeleton / Draft / Usable / Production
```
