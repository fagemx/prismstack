# Review — 9 維度 + 6 雷區掃描

> 完成後品質審查。對單一 skill 的 SKILL.md + references/ 做深度評估。
> 觸發時機：`/domain-build` 完成後、`/skill-gen` 完成後、`/domain-upgrade` 改完後，或手動 `/skill-check review`。

---

## 評分方式

每個維度 **0-2 分**：
- **0** = 不存在 / 完全缺失
- **1** = 有但不完整或品質不夠
- **2** = 到位

滿分 **18 分**。分級：
- **14-18**: Production — 可以直接用於真實工作
- **10-13**: Usable — 能用但有明顯缺口
- **6-9**: Draft — 骨架在但需要補充
- **0-5**: Skeleton — 只有結構殼

---

## Skill 本體（6 維度）

### D1. Trigger Fit — 什麼時候用很清楚嗎

- **0** = 沒有觸發描述，或描述是功能摘要（「A skill for reviewing quality」）
- **1** = 有 when to use，但缺 when NOT to use 或缺 trigger phrases
- **2** = 完整：何時用 + 何時不用 + 相鄰 skill 區分 + trigger phrases

**證據要求：** 引用 SKILL.md 的 description 或 Trigger 段落，說明哪些條件滿足/不滿足。

---

### D2. Workflow Fit — 在 pack 裡的位置清楚嗎

- **0** = 不知道自己在 workflow 的哪裡（不找上游、不推下游）
- **1** = 結尾有推薦下一步，但開頭不讀上游 artifact
- **2** = 開頭讀上游 artifact + 結尾推薦下游 + 知道自己前後是誰

**證據要求：** 列出 skill 讀了哪些上游 artifact、推薦了哪些下游 skill。

---

### D3. Judgment Depth — 有真的領域判斷嗎

- **0** = 只有 generic 判斷（任何 domain 都一樣的建議）
- **1** = 有部分領域特化（例如有領域 benchmarks 但 gotchas 是通用的）
- **2** = 判斷邏輯、benchmarks、gotchas、forcing questions 都是領域特化的

**證據要求：** 舉出一個具體的判斷邏輯或 benchmark，說明為什麼是領域特化的（替換到其他 domain 會不適用）。

**Substitution Test:** 把 skill 的領域名稱替換掉，如果 85% 內容不變 → 不是領域判斷，是 generic 包裝。

---

### D4. Interaction Quality — 問得剛好嗎

- **0** = 沒有互動設計（一口氣跑完、不問用戶）
- **1** = 有互動但太多（每步都問）或太少（只開頭問一次）
- **2** = 互動節奏對：需要用戶判斷時 STOP，不需要時自動跑。有 AskUserQuestion + STOP gates 設計。

**證據要求：** 列出 STOP gate 數量和位置，評估是否在對的地方停。

---

### D5. Output Clarity — 產出清楚嗎，下游能接嗎

- **0** = 輸出是聊天文字，沒有結構
- **1** = 有 structured output 但沒寫到檔案（只在對話中）
- **2** = 有明確的 artifact 輸出（寫檔案或 structured format），下游 skill 可以讀取

**證據要求：** 描述 artifact 的格式和存放位置，確認下游 skill 是否有讀取邏輯。

---

### D6. Density — 高訊號內容比例

- **0** = 大量樣板文字（boilerplate），高訊號內容 < 30%
- **1** = 混合，高訊號內容 40-70%
- **2** = 精煉，高訊號內容 > 70%（每段都有具體的判斷邏輯、數據、或操作指令）

**證據要求：** 估算 SKILL.md + references/ 的總行數中，有多少是具體判斷/數據/操作 vs 多少是說明文字/格式框架。

**高訊號的定義：** 拿掉這段後 skill 的行為會改變。
**低訊號的定義：** 拿掉這段 skill 行為不變（純說明、重複、或過度格式化）。

---

## Skill 效果（3 維度）

### D7. Work Helpfulness — 真的幫工作推進嗎

- **0** = 跑完之後工作沒有推進（只多了一份報告但不知道接下來做什麼）
- **1** = 有推進但不完整（知道問題但不知道怎麼修）
- **2** = 跑完後有明確的下一步行動（具體的修改建議 + 推薦下一個 skill）

**證據要求：** 描述跑完這個 skill 後，用戶的工作狀態會怎麼改變。

---

### D8. Automation Leverage — 省了判斷/切換/整理成本嗎

- **0** = 沒省什麼（用戶自己做也差不多）
- **1** = 省了部分（自動整理，但判斷還是用戶做）
- **2** = 省了大量成本（自動判斷 + 整理 + 推薦，用戶只需確認）

**證據要求：** 描述沒有這個 skill 時用戶要手動做什麼，有了之後省了哪些步驟。

---

### D9. Reusability — 換個相似專案還能用嗎

- **0** = 完全跟特定專案綁定，換專案要重寫
- **1** = 核心邏輯可重用，但需要修改 30%+ 的內容
- **2** = 換到相似領域的專案可以直接用或只改 config

**證據要求：** 假設換一個同領域的專案，列出哪些部分要改、哪些不用改。

---

## 評分卡模板

```
=== Skill Review: [skill 名稱] ===

本體（6D）:
  D1. Trigger Fit:        _/2  | 證據：___
  D2. Workflow Fit:       _/2  | 證據：___
  D3. Judgment Depth:     _/2  | 證據：___
  D4. Interaction Quality: _/2  | 證據：___
  D5. Output Clarity:     _/2  | 證據：___
  D6. Density:            _/2  | 證據：___

效果（3D）:
  D7. Work Helpfulness:   _/2  | 證據：___
  D8. Automation Leverage: _/2  | 證據：___
  D9. Reusability:        _/2  | 證據：___

TOTAL: _/18
Grade: Production / Usable / Draft / Skeleton
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
Score: _/18 → Grade: ___
Mines: _/6 踩雷

綜合判定：
  Grade ≥ Usable + 0 mines → 可用
  Grade ≥ Usable + 1-2 mines → 可用但必須修雷區
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
| 14-18 | Production | Ready to ship. Minor polish only. | Ship it. |
| 10-13 | Usable | Works but has gaps. Users will hit rough edges. | Prioritize top 2 weak dimensions. |
| 6-9 | Draft | Structure exists but judgment is shallow. | Major revision needed. |
| 0-5 | Skeleton | Just an outline. Not usable. | Rewrite or merge into another skill. |

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
- Dimension 7-9 (effects) all 0 → skill exists but doesn't help anyone. Rethink purpose.
