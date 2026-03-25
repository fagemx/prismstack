# 15D 品質評估標準

> 每個維度 0-2 分，滿分 30。
> /domain-build 生成的 skill 使用此標準自檢。

---

## 分級

| 分數 | 等級 | 意義 |
|------|------|------|
| 24-30 | Production | 可以直接使用 |
| 18-23 | Usable | 能用但有明顯缺口 |
| 12-17 | Draft | 骨架在但需大量補充 |
| 0-11 | Skeleton | 只有結構 |

---

## A. 入口層

**A1. Trigger Description（觸發條件）**
- 0 = 缺失或只是功能摘要（「Game balance review」）
- 1 = 有 when to use，沒有 when NOT to use
- 2 = 完整：做什麼 + 何時用 + 何時不用 + 相鄰 skill + trigger phrases

**A2. Role Identity（角色定義）**
- 0 = 沒有明確角色或泛型（「you are a helpful assistant」）
- 1 = 有角色但模糊（「you are a game reviewer」）
- 2 = 一句話鎖死（「you are an economy mathematician — show numbers, not feelings」）

**A3. Mode Routing（模式路由）**
- 0 = 沒有模式區分，一條路到底
- 1 = 有模式但靠 Claude 自己判斷
- 2 = 開頭明確解析 args 或用 AskUserQuestion 路由，鎖死後不回頭

---

## B. 流程層

**B4. Flow Externalization（流程外部化）**
- 0 = 靠 Claude 記憶走流程
- 1 = 有 phase/section 但沒有外部追蹤
- 2 = 用 TodoWrite / driver script / status table / explicit phase gates

**B5. STOP Gates（停止門）**
- 0 = 沒有 STOP 規則
- 1 = 有「one issue per AskUserQuestion」但不是每個 section 都有
- 2 = 每個 section 結尾都有 STOP + 明確的「resolve all before proceeding」

**B6. Recovery / Interrupt Handling（中斷恢復）**
- 0 = 沒有恢復機制
- 1 = 有基本 error handling table
- 2 = 有完整 recovery procedure（重建狀態 + 從斷點續跑）

---

## C. 知識層

**C7. Gotchas（Claude 常犯的錯）**
- 0 = 沒有
- 1 = 有 anti-sycophancy / forbidden phrases
- 2 = 有操作層面 gotchas（Claude 做此任務具體會犯什麼錯）+ forbidden phrases + forcing questions

**C8. Scoring / Quantitative Rigor（量化評分）**
- 0 = 沒有評分，只有定性判斷
- 1 = 有評分但靠 AI 直覺
- 2 = 有明確公式 + 每個維度有分數 + 分數有校準基準

**C9. Domain Benchmarks（領域基準數據）**
- 0 = 沒有行業參考數據
- 1 = 有一些但零散
- 2 = 有結構化基準表（retention rates, session lengths, economy ratios 等）

---

## D. 結構層

**D10. Progressive Disclosure（漸進式揭示）**
- 0 = 所有內容在一個 SKILL.md（monolith）
- 1 = 有 references/ 但只有 1-2 個檔案
- 2 = SKILL.md < 200 行為骨架，details 拆到 references/（gotchas, examples, checklists, benchmarks）

**D11. Helper Code / Scripts（輔助腳本）**
- 0 = 純 markdown，沒有可執行的東西
- 1 = 有 bash code blocks 但都是 inline
- 2 = 有 scripts/ 目錄或 bundled helper（driver scripts, calculation tools, templates）

**D12. Config / Memory（設定與記憶）**
- 0 = 沒有
- 1 = 有 review log 但沒有 per-project config
- 2 = 有 config.json（記住設定）+ review history（上次發現什麼）

---

## E. 系統層

**E13. Artifact Discovery（上游 artifact 發現）**
- 0 = 不找上游 artifact，每次從零開始
- 1 = 開頭有檢查但不找其他 skill 的輸出
- 2 = 自動搜尋上游 design doc + 其他 review 結果 + 上次 review 紀錄

**E14. Output Contract（輸出是下一步的接口）**
- 0 = 輸出是聊天文字
- 1 = 有 completion summary 但沒有寫到檔案
- 2 = 輸出寫到 `~/.gstack/projects/` + structured format + 可被下游 skill 讀取

**E15. Workflow Position（在工作流中的位置）**
- 0 = 不知道自己在工作流的哪裡
- 1 = 結尾推薦下一個 skill
- 2 = 開頭知道上游是誰（讀 artifact），結尾知道下游是誰（推薦 + 寫 artifact）

---

## /domain-build 輸出的目標分數

| skill 類別 | 目標等級 | 目標分數 | 說明 |
|-----------|---------|---------|------|
| 通用底盤 | Usable | 18-23 | 從 gstack 模式 fork，成熟度高 |
| 規劃視角 | Draft-Usable | 15-20 | 策略/設計/工程，需領域調整 |
| 領域專屬 | Draft | 12-17 | LLM 生成，需實際使用迭代 |
| 入口 | Usable | 18-23 | 格式轉換，邏輯明確 |
| 路由 | Usable | 18-23 | 從 skill map 直接衍生 |

**重要：** /domain-build 的目標是「Draft-Usable」，不是「Production」。
生成的 skill 預期需要 2-3 輪實際使用後的迭代才能到 Production。
不要假裝第一次生成就是 Production 品質。

---

## 快速自檢模板

```
Skill: _______________
Type: Review / Bridge / Production / Control / Runtime Helper

A1. Trigger:     _/2    A2. Role:      _/2    A3. Mode:     _/2
B4. Flow:        _/2    B5. STOP:      _/2    B6. Recovery: _/2
C7. Gotchas:     _/2    C8. Scoring:   _/2    C9. Benchmarks: _/2
D10. Disclosure: _/2    D11. Scripts:  _/2    D12. Config:  _/2
E13. Discovery:  _/2    E14. Output:   _/2    E15. Position: _/2

TOTAL: _/30  →  Grade: ___________
```
