# Review — 15 維度 + 6 雷區掃描

> 完成後品質審查。對單一 skill 的 SKILL.md + references/ 做深度評估。
> 觸發時機：`/domain-build` 完成後、`/skill-gen` 完成後、`/domain-upgrade` 改完後，或手動 `/skill-check review`。

---

## 評分方式

每個維度 **0-2 分**：
- **0** = 不存在 / 完全缺失
- **1** = 有但不完整或品質不夠
- **2** = 到位

滿分 **30 分**。分級：
- **24-30**: Production — 可以直接用於真實工作
- **18-23**: Usable — 能用但有明顯缺口
- **12-17**: Draft — 骨架在但需要補充
- **0-11**: Skeleton — 只有結構殼

---

## A. 入口層（Entry Layer — 用戶碰到 skill 的第一秒）

### A1. Trigger Description — 什麼時候用很清楚嗎

- **0** = 沒有觸發描述，或描述是功能摘要（「A skill for reviewing quality」）
- **1** = 有 when to use，但缺 when NOT to use 或缺 trigger phrases
- **2** = 完整：何時用 + 何時不用 + 相鄰 skill 區分 + trigger phrases

**證據要求：** 引用 SKILL.md 的 description 或 Trigger 段落，說明哪些條件滿足/不滿足。

**2 分門檻：** 必須同時存在四個元素：(1) 功能描述、(2) 使用時機、(3) 不使用時機、(4) 觸發短語或相鄰 skill 區分。缺任何一個 → 1 分。

---

### A2. Role Identity — 角色定義有多鋒利

- **0** = 沒有明確角色，或泛型角色（「you are a helpful assistant」）
- **1** = 有角色但模糊（「you are a game reviewer」）—— 沒有限制行為邊界
- **2** = 一句話鎖死角色 + 行為邊界（「you are an economy mathematician — show numbers, not feelings」）

**證據要求：** 引用 Role section 的原文。2 分必須看到角色定義包含行為限制（不只是身份宣告）。

**測試方法：** 讀完 Role，能不能用一句話回答「這個 skill 不做什麼」？如果不能 → 最多 1 分。

---

### A3. Mode Routing — 入口分流是否明確

- **0** = 沒有模式區分，一條路到底
- **1** = 有模式但靠 Claude 自己判斷（隱式路由）
- **2** = 開頭明確解析 args 或用 AskUserQuestion 路由，鎖死後不回頭

**證據要求：** 引用 args parsing 邏輯或 AskUserQuestion 路由段落。2 分必須看到 (1) 明確的 args → mode mapping，(2) 無 args 時的 fallback 路由，(3) mode lock 聲明。

**邊界案例：** 只有一個 mode 的 skill，如果明確聲明「只有一個 mode」→ 1 分（有意識的選擇）。如果完全沒提 → 0 分。

---

## B. 流程層（Flow Layer — skill 執行的骨架）

### B4. Flow Externalization — 流程有沒有外部化追蹤

- **0** = 靠 Claude 記憶走流程（沒有 phase gate、沒有 status output）
- **1** = 有 phase/section 標記但沒有外部追蹤機制（純文字描述步驟）
- **2** = 用 TodoWrite / driver script / status table / explicit phase gates，流程進度可被外部觀察

**證據要求：** 引用流程追蹤機制。2 分必須看到 (1) 明確的 phase/step 定義，(2) 可被觀察的狀態輸出（不只是「按步驟做」的文字）。

**區分 1 和 2 的關鍵：** 1 是「有步驟列表」，2 是「步驟狀態可被追蹤」。如果中斷後無法從外部觀察判斷做到哪裡 → 最多 1 分。

---

### B5. STOP Gates — 什麼時候停下來問用戶

- **0** = 沒有 STOP 規則（一口氣跑完、不問用戶，或每步都問）
- **1** = 有「one issue per AskUserQuestion」但覆蓋不完整（不是每個需要判斷的節點都有）
- **2** = 每個需要用戶判斷的節點都有 STOP + 明確的「resolve all before proceeding」

**證據要求：** 列出所有 STOP gate 的位置和觸發條件。2 分必須看到 STOP gates 分布在合理的決策點（不是隨便放的）。

**反模式（自動 0 分）：** 完全沒有 AskUserQuestion 或 STOP 關鍵字。
**反模式（最多 1 分）：** 只在開頭問一次，後面全自動跑。

---

### B6. Recovery / Interrupt Handling — 中斷後能恢復嗎

- **0** = 沒有任何恢復機制
- **1** = 有基本的 error handling（錯誤訊息或 retry 邏輯），但沒有狀態重建
- **2** = 有完整的 recovery procedure：(1) 如何偵測中斷點，(2) 如何重建狀態，(3) 從哪裡續跑

**證據要求：** 引用 recovery/中斷恢復 section。2 分必須看到三個元素：偵測、重建、續跑。缺任何一個 → 1 分。

**常見缺失：** 很多 skill 有 error handling 但沒有「如何從對話歷史重建狀態」的邏輯。這最多只能給 1 分。

---

## C. 知識層（Knowledge Layer — skill 帶給 Claude 的東西）

### C7. Gotchas — Claude 執行此任務時會犯什麼錯

- **0** = 沒有 gotchas section
- **1** = 有 anti-sycophancy forbidden phrases，但缺操作層面的具體錯誤
- **2** = 有操作層面的 gotchas（Claude 做此任務時具體會犯什麼錯）+ forbidden phrases + forcing questions

**證據要求：** 引用 gotchas 內容。2 分的每個 gotcha 必須是操作性的（「Claude 會做 X，對策是 Y」），不能是泛泛的警告。

**Substitution Test for Gotchas：** 把 gotchas 裡的領域名稱替換掉，如果全部仍然適用 → 這些不是真正的領域 gotchas，是 generic gotchas，最多 1 分。

**2 分門檻：** 至少 3 個操作性 gotchas + 至少 2 個 forbidden phrases + 至少 1 個 forcing question。

---

### C8. Scoring / Quantitative Rigor — 評判有量化基礎嗎

- **0** = 沒有評分，只有定性判斷（「這個不太好」「建議改進」）
- **1** = 有評分但靠 AI 直覺（沒有明確公式，分數定義模糊）
- **2** = 有明確公式 + 每個維度有獨立分數 + 分數有校準基準（calibration）

**證據要求：** 引用評分公式或 scoring rubric。2 分必須看到 (1) 每個分數等級的具體條件，(2) 防止膨脹的校準機制。

**適用範圍：** 不是所有 skill 都需要量化評分。如果 skill 本質不涉及評判（純 production 或 pure automation）→ 這個維度的 2 分標準降為「有明確的 success criteria」。

---

### C9. Domain Benchmarks — 有領域基準數據嗎

- **0** = 沒有行業參考數據（所有判斷都是 Claude 自己編的）
- **1** = 有一些參考數據但零散（散落在文字中，沒有結構）
- **2** = 有結構化的基準表（retention rates, session lengths, economy ratios, conversion funnels, etc.）

**證據要求：** 引用 benchmark 表格或數據。2 分必須是結構化的（表格或清單），不能是散落的數字。

**適用範圍：** Review/Analysis 類 skill 這個維度最重要。Production 類 skill 如果沒有 benchmark 需求（例如 scaffolding skill），0 分不扣分但需在報告中說明原因。

**Substitution Test for Benchmarks：** 這些數字換到另一個領域還適用嗎？如果是 → 不是真正的領域 benchmark，最多 1 分。

---

## D. 結構層（Structure Layer — 檔案組織）

### D10. Progressive Disclosure — 資訊是漸進揭示的嗎

- **0** = 所有內容在一個 SKILL.md（monolith），超過 300 行
- **1** = 有 references/ 但只有 1-2 個檔案，或 SKILL.md 仍然 > 200 行
- **2** = SKILL.md 是骨架（< 200 行），details 拆到 references/（gotchas, examples, checklists, benchmarks）

**證據要求：** 報告 SKILL.md 行數 + references/ 檔案數量和名稱。2 分的 SKILL.md 必須 < 200 行且 references/ 至少 2 個有實質內容的檔案。

**為什麼重要：** Claude 的 context window 是有限的。SKILL.md 是每次都會載入的，references/ 只在需要時載入。Monolith SKILL.md 浪費 context。

---

### D11. Helper Code / Scripts — 有可執行的輔助工具嗎

- **0** = 純 markdown，沒有可執行的東西
- **1** = 有 bash code blocks 但都是 inline（嵌在 SKILL.md 或 references/ 裡）
- **2** = 有 scripts/ 目錄或 bundled helper（driver scripts, calculation tools, templates）

**證據要求：** 列出 scripts/ 目錄內容或 inline bash blocks。2 分必須有獨立的可執行檔案（不只是 code fence 裡的命令）。

**適用範圍：** 不是所有 skill 都需要 scripts/。如果 skill 的工作完全是文字分析（不需要跑命令）→ 1 分即可（有 inline bash for discovery）。0 分表示連基本的檔案搜尋命令都沒有。

---

### D12. Config / Memory — 有跨次執行的記憶嗎

- **0** = 沒有任何持久化機制（每次從零開始）
- **1** = 有 review log 或 output file，但沒有 per-project config
- **2** = 有 config.json（記住 project-specific 設定）+ review history（上次發現什麼、趨勢追蹤）

**證據要求：** 引用 config/state 相關的 Read/Write 邏輯。2 分必須看到 (1) 設定檔讀取，(2) 結果寫入，(3) 下次執行時讀取上次結果的邏輯。

**為什麼重要：** 沒有 memory 的 skill 每次都是無狀態的。用戶跑第二次時，skill 不知道上次發現了什麼、改了什麼。重複發現同樣的問題是浪費。

---

## E. 系統層（System Layer — skill 與其他 skill 的關係）

### E13. Artifact Discovery — 會找上游產出嗎

- **0** = 不找上游 artifact，每次從零開始
- **1** = 開頭有基本檢查（例如找 GDD 或 config），但不找其他 skill 的輸出
- **2** = 自動搜尋上游 design doc + 其他 skill 的 review 結果 + 上次自己的 review 紀錄

**證據要求：** 列出 skill 開頭搜尋了哪些上游 artifact（引用 bash commands 或 Read 邏輯）。2 分必須搜尋至少 (1) 領域 config，(2) 上游 skill output，(3) 自己的歷史 output。

**區分 1 和 2 的關鍵：** 1 是「找自己需要的 input」，2 是「找整個 ecosystem 的相關 artifact」。

---

### E14. Output Contract — 輸出是下一步的接口嗎

- **0** = 輸出是聊天文字（對話結束後就消失了）
- **1** = 有 completion summary 或 structured output，但沒有寫到檔案
- **2** = 輸出寫到持久化位置（`~/.prismstack/projects/` 或 project 內）+ structured format + 可被下游 skill 讀取

**證據要求：** 描述 artifact 的格式和存放位置。2 分必須看到 (1) 明確的寫入路徑，(2) 結構化格式（JSON / Markdown with headers），(3) 下游 skill 有讀取此 artifact 的邏輯。

**測試方法：** 如果跑完這個 skill 後關掉對話，下次另一個 skill 能不能找到並讀取這次的結果？如果不能 → 最多 1 分。

---

### E15. Workflow Position — 知道自己在工作流的哪裡嗎

- **0** = 不知道自己在工作流的哪裡（不找上游、不推下游）
- **1** = 結尾有推薦下一步，但開頭不讀上游 artifact；或反過來
- **2** = 開頭知道上游是誰（讀 artifact）+ 結尾知道下游是誰（推薦 + 寫 artifact）+ 跑完後工作有明確推進

**證據要求：** 列出 (1) skill 讀了哪些上游 artifact，(2) 推薦了哪些下游 skill，(3) 跑完後用戶的工作狀態如何改變。

**2 分的額外條件：** 不只是「知道位置」，還要「推進工作」。跑完後如果只多了一份報告但用戶不知道下一步 → 最多 1 分。推薦下游 + 有 actionable items → 2 分。

---

## 評分卡模板

```
=== Skill Review: [skill 名稱] ===

A. 入口層:
  A1. Trigger Description:    _/2  | 證據：___
  A2. Role Identity:          _/2  | 證據：___
  A3. Mode Routing:           _/2  | 證據：___

B. 流程層:
  B4. Flow Externalization:   _/2  | 證據：___
  B5. STOP Gates:             _/2  | 證據：___
  B6. Recovery:               _/2  | 證據：___

C. 知識層:
  C7. Gotchas:                _/2  | 證據：___
  C8. Scoring Rigor:          _/2  | 證據：___
  C9. Domain Benchmarks:      _/2  | 證據：___

D. 結構層:
  D10. Progressive Disclosure: _/2  | 證據：___
  D11. Helper Code:            _/2  | 證據：___
  D12. Config / Memory:        _/2  | 證據：___

E. 系統層:
  E13. Artifact Discovery:     _/2  | 證據：___
  E14. Output Contract:        _/2  | 證據：___
  E15. Workflow Position:       _/2  | 證據：___

TOTAL: _/30 → Grade: ___
```

---

## 6 雷區掃描

> 雷區是 score card 抓不到的結構性問題。即使分數不低，踩雷也代表 skill 有根本缺陷。

### Mine 1: Generic 包裝

**檢測方法：Substitution Test**
把 skill 中的領域名稱（例：「game design」→「web app」）全部替換，重讀一遍。
- 如果 85%+ 內容讀起來仍然合理 → 踩雷。
- 如果核心判斷邏輯因為替換而變得荒謬 → 沒踩。

**踩雷後行動：** 補充領域特化的 benchmarks、gotchas、forcing questions。generic 的部分降為 shared/ 通用模組。

---

### Mine 2: 前深後淺

**檢測方法：段落密度對比**
比較 skill 前半段（通常是 context / setup）和後半段（通常是 judgment / output）的訊號密度。
- 如果前半有具體邏輯但後半只是「根據以上分析給出建議」→ 踩雷。
- 如果前後密度均勻 → 沒踩。

**踩雷後行動：** 後半段補充具體的判斷公式、scoring rubric、output template。

---

### Mine 3: Review 當 Production

**檢測方法：Artifact 檢查**
跑完 skill 後，除了一份報告/分析之外，工作有沒有實際推進？
- 如果只多了一份報告但沒有改任何東西 → 踩雷（除非 skill 類型本身就是 Review）。
- 如果有產出改動、或有明確的 actionable items 推到下游 → 沒踩。

**踩雷後行動：** 如果不是 Review 類 skill，要補實際的 production 產出。如果是 Review 類，確保 output 有 actionable items。

---

### Mine 4: 缺 Runtime

**檢測方法：Runtime Dependency 盤點**
列出 skill 依賴的所有 runtime（工具、API、檔案、資料庫）。
- 如果依賴的 runtime 在目標環境中不存在或不穩定 → 踩雷。
- 如果 runtime 都可取得且穩定 → 沒踩。

**踩雷後行動：** 加 runtime 檢查邏輯（skill 開頭驗證 runtime 是否就位）。缺的 runtime 加 setup 指引或 fallback。

---

### Mine 5: 過度拆分

**檢測方法：Standalone Value Test**
這個 skill 單獨拿出來跑，有沒有獨立價值？
- 如果單獨跑沒意義（必須配合另一個 skill 才有用）且 work unit 太小 → 踩雷。
- 如果單獨跑有完整的價值 → 沒踩。

**踩雷後行動：** 合併到主 skill 的 section。或者加大 work unit scope。

---

### Mine 6: 低密度

**檢測方法：行數 vs 訊號比**
算 skill 總行數和高訊號行數的比例。
- 如果 > 200 行但高訊號 < 40% → 踩雷。
- 如果行數合理或訊號密度高 → 沒踩。

**踩雷後行動：** 刪除重複說明、合併相似段落、把樣板文字移到 template。目標：高訊號 > 70%。

---

## 雷區報告格式

```
=== Mine Scan: [skill 名稱] ===

Mine 1 Generic 包裝:    ✅ 安全 / ⚠️ 邊緣 / 💣 踩雷
  → 證據：___
Mine 2 前深後淺:        ✅ / ⚠️ / 💣
  → 證據：___
Mine 3 Review 當 Production: ✅ / ⚠️ / 💣
  → 證據：___
Mine 4 缺 Runtime:      ✅ / ⚠️ / 💣
  → 證據：___
Mine 5 過度拆分:        ✅ / ⚠️ / 💣
  → 證據：___
Mine 6 低密度:          ✅ / ⚠️ / 💣
  → 證據：___

雷區數：_/6
踩雷項改進優先順序：
  1. ___
  2. ___
```

---

## 綜合判定

```
Score: _/30 → Grade: ___
Mines: _/6 踩雷

綜合判定：
  Grade >= Production + 0 mines → 可直接使用
  Grade >= Usable + 0 mines → 可用
  Grade >= Usable + 1-2 mines → 可用但必須修雷區
  Grade = Draft + 0 mines → 需要補充但方向對
  Grade = Draft + mines → 需要重新設計踩雷的部分
  Grade = Skeleton → 需要重寫

改進優先順序：
  1. [最高優先] ___
  2. ___
  3. ___
```

---

## Calibration Benchmarks

### What scores mean in practice
| Score Range | Grade | What It Means | Action |
|-------------|-------|---------------|--------|
| 24-30 | Production | Ready to ship. Minor polish only. | Ship it. |
| 18-23 | Usable | Works but has gaps. Users will hit rough edges. | Prioritize top 2 weak dimensions. |
| 12-17 | Draft | Structure exists but judgment is shallow. | Major revision needed. |
| 0-11 | Skeleton | Just an outline. Not usable. | Rewrite or merge into another skill. |

### Typical score distributions
| Skill Origin | Expected Avg | Why |
|-------------|-------------|-----|
| gstack fork + domain vocab | 18-22 | Proven methodology, just needs domain terms |
| LLM auto-generated | 12-16 | Structure OK, judgment shallow, gotchas generic |
| Expert-upgraded | 20-26 | Deep domain knowledge, calibrated scoring |
| Tool-type skill | 14-18 | Scripts solid, interaction design varies |

### Red flags in scoring
- All 2s → you're not being honest. Re-examine each with evidence.
- All dimensions same score → you're not differentiating. Some must be stronger.
- Layer C (Knowledge) all 0 → skill exists but teaches Claude nothing. Rethink purpose.
- Layer E (System) all 0 → skill is an island. No ecosystem integration.
- Layer B (Flow) all 2 but Layer C all 0 → well-structured skeleton with no substance.
