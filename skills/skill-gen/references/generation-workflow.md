# Single Skill Generation Workflow

> 在現有 domain stack 中新增一個 skill 的完整流程。
> 每一步都有明確的 STOP gate — 不跳步。

---

## Phase 1: Understand Intent

用戶想讓這個 skill 做什麼？

1. 用一句話描述這個 skill 的職責
2. 確認這不是現有 skill 的一部分 — 問：「現有的哪個 skill 最接近這件事？」
3. 跑 3 項獨立性測試：

**獨立性測試（全過才能建新 skill）：**

| 測試 | 問題 | PASS 條件 |
|------|------|----------|
| 姿勢獨立 | 這個 skill 需要的工作姿勢跟現有任何 skill 不同嗎？ | 角色、語氣、自由度至少一項不同 |
| 產出獨立 | 這個 skill 的 artifact 跟現有任何 skill 的產出不重疊嗎？ | 輸出檔案類型或命名 pattern 不同 |
| 觸發獨立 | 用戶會用不同的語句觸發它嗎？ | trigger phrases 跟現有 skill 不重疊 |

- 3/3 PASS → 繼續
- 1-2 PASS → 提出合併建議，讓用戶決定
- 0 PASS → 建議加到現有 skill 的 section

**STOP gate:** 確認用戶同意建新 skill。

---

## Phase 2: Classify & Position

1. **決定類型** — 用決策樹：
   ```
   這個 skill 主要做什麼？
   ├─ 評估/審查某個東西 → Review
   ├─ 把 A 格式轉成 B 格式 → Bridge
   ├─ 從零建造新的 artifact → Production
   ├─ 調度/路由/狀態檢查 → Control
   └─ 提供計算/搜尋/格式化功能 → Runtime Helper
   ```

2. **定位上游** — 哪些 skill 的產出是這個 skill 的輸入？
3. **定位下游** — 這個 skill 的產出給誰用？
4. **Artifact 命名** — 確定輸出檔案的命名 pattern（跟 domain 現有慣例一致）

**STOP gate:** 向用戶確認類型 + 上下游定位。

---

## Phase 3: Generate

1. 根據類型，從 `skill-template-guide.md` 取對應模板
2. 生成 SKILL.md（目標 ~150 行骨架）
3. 若內容會超過 200 行 → 拆 references/
4. 必須包含的元素：

**SKILL.md 必要元素：**
- [ ] YAML frontmatter（name, version, origin, description, allowed-tools）
- [ ] description 含 trigger / do-not-use / 上游 / 下游 / 產出
- [ ] Role identity（一句話角色定義）
- [ ] Mode routing（參數解析）
- [ ] Phase 0: Artifact Discovery
- [ ] Phase 1-N: 主流程（每 phase 有 STOP gate）
- [ ] Anti-sycophancy rules
- [ ] Gotchas（至少 3 條）
- [ ] Completion protocol（STATUS + 產出 + 推薦下一步）

**references/ 常見拆法：**
- `gotchas.md` — 超過 5 條坑就拆
- `checklist.md` — 品質檢查清單
- `examples.md` — 範例
- `prompts.md` — sub-agent prompt templates

**STOP gate:** 呈現生成的 SKILL.md 給用戶 review。

---

## Phase 4: Quality Gate

對新 skill 跑 /skill-check design（7Q）：

1. Trigger 準確度 — description 能正確觸發嗎？
2. 姿勢鎖定 — 開頭有沒有鎖 agent 進工作模式？
3. 流程外部化 — 有沒有用 phase / checklist / driver？
4. Gotchas 密度 — 有沒有寫真正的坑？
5. 自由度控制 — 該死板的地方死板了嗎？
6. 骨架 vs 細節 — SKILL.md < 200 行？references 拆得合理嗎？
7. 輸出可接下一步 — 完成時產出的東西下游能用嗎？

判定：
- 7/7 PASS → 繼續
- 5-6 PASS → 修正後繼續
- < 5 PASS → 重新生成
- 獨立性 FAIL → 建議合併到現有 skill

**STOP gate:** 如果 FAIL，呈現問題 → 修正 → 重跑。

---

## Phase 5: Wire Into Workflow

1. **更新 routing skill** — 在 domain 的 routing table 加入新 skill 的觸發條件
2. **驗證 artifact flow：**
   - 上游 skill 確實會產出這個 skill 需要的 artifact
   - 這個 skill 的產出格式，下游 skill 確實能解析
3. **更新 skill-map.md**（如果存在）

**STOP gate:** 確認 wiring 完成。

---

## Phase 6: Verify

最終檢查清單：

- [ ] YAML frontmatter 格式正確
- [ ] name 跟目錄名一致
- [ ] version 為 0.1.0
- [ ] origin 為 prismstack-generated
- [ ] allowed-tools 只列需要的工具
- [ ] SKILL.md < 200 行
- [ ] references/ 檔案有被 SKILL.md 引用
- [ ] ECC 相容（Claude Code 環境可執行）

---

## 寫作原則速查（生成前跑一遍）

| # | 原則 | 檢查問題 |
|---|------|---------|
| 1 | 先寫 trigger | description 包含 trigger + do-not-use + 上下游嗎？ |
| 2 | Skill = 工作姿勢 | 開頭有切換 agent 行為模式嗎？ |
| 3 | 流程外部化 | 用了 phase / checklist / driver 嗎？不靠記憶？ |
| 4 | 最高價值 = gotchas | 寫了真正的坑，不是泛用建議？ |
| 5 | 該死板就死板 | 高風險步驟有 guardrail？ |
| 6 | 主 skill = 骨架 | SKILL.md < 200 行？細節在 references/？ |
| 7 | 定義 recovery | 中斷後怎麼恢復有寫嗎？ |
| 8 | 輸出可接下一步 | 完成時產出的是 artifact，不是聊天回應？ |
