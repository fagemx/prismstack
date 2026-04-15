# 方法論錨點

> 用途：引導員教學時的概念骨架。不是教案，是推理的起點。
> 每個錨點提供：一句話定義 → 常見混淆 → 教學鉤子 → 連結到哪裡學更多。
> 引導員讀完錨點後，結合用戶的 domain stack 即時生成具體教學內容。

---

## 錨點 1: 10 個工作姿態

**一句話：** 任何領域的工作都需要 10 種思考方式，skill stack 就是把這 10 種分開、讓 AI 每次只戴一頂帽子。

| # | 姿態 | 核心行為 | 教學鉤子（類比） |
|---|------|---------|----------------|
| 1 | Ideator | 結構化想法、挑戰前提 | 腦力激盪白板 |
| 2 | Decision Maker | 砍 scope、評估風險 | 老闆拍板 |
| 3 | Reviewer | 檢查品質 | 品管部門 |
| 4 | Tester | 系統性找問題 | QA 測試員 |
| 5 | Shipper | 打包上線 | 物流出貨 |
| 6 | Debugger | 找根因、修問題 | 偵探辦案 |
| 7 | Retrospective | 反思和改善 | 賽後檢討 |
| 8 | Safety | 防破壞性操作 | 安全閥 |
| 9 | Docs | 更新文件 | 歸檔員 |
| 10 | Second Opinion | 獨立對抗性審查 | 法庭對造 |

**常見混淆：**
- 「這 10 個一定都要嗎？」→ 是的，但不一定各一個 skill。一個 skill 可以包含多個姿態，只要通過獨立性測試。
- 「Reviewer 和 Tester 有什麼不同？」→ Reviewer 看品質（這好不好），Tester 找問題（哪裡會壞）。Reviewer 是主觀判斷，Tester 是系統檢驗。
- 「Safety 不是每個 skill 都該有的嗎？」→ 對，但有些高風險操作需要獨立的 Safety skill（例如 deploy、刪除）。

**深入：** `shared/methodology/skill-map-methodology.md` Step 2

---

## 錨點 2: 5 種 Skill 類型

**一句話：** 每個 skill 歸入 5 類之一，類型決定了 skill 的結構模板和品質標準。

| 類型 | 一句話 | 辨識法 | 教學鉤子 |
|------|--------|--------|---------|
| Review | 判斷品質 | 跑完後你得到的是「分數或判斷」 | 考官打分 |
| Bridge | 轉譯交接 | 輸入和輸出是不同格式 | 翻譯官 |
| Production | 讓東西出現 | 跑完後多了新的 artifact | 工廠產線 |
| Control | 編排治理 | 決定「用哪個 skill」或「狀態如何」 | 交通警察 |
| Runtime Helper | 外部工具整合 | 需要呼叫外部 API/CLI/瀏覽器 | 外包廠商 |

**常見混淆：**
- 「一個 skill 可以是兩種類型嗎？」→ 不行。如果你覺得是兩種，它可能需要拆成兩個 skill。
- 「Review 和 Control 怎麼分？」→ Review 判斷「這個東西」的品質；Control 判斷「接下來做什麼」。一個看成品，一個看流程。

**健康比例：** Review ≤40%，必須有 Bridge（否則斷裂），必須有 Production（否則只審不做）。

**深入：** `shared/methodology/skill-map-methodology.md` Step 6

---

## 錨點 3: 3 獨立性測試

**一句話：** 一個功能要變成獨立 skill，必須同時通過三個測試。沒通過的合併到其他 skill 的 section。

| 測試 | 問什麼 | 過了 | 沒過 |
|------|--------|------|------|
| 獨立姿態 | 啟動它會改變 AI 的思考方式嗎？ | AI 切換了角色 | 只是做了一個子步驟 |
| 獨立產出 | 結束時有獨立有價值的 artifact 嗎？ | 有可以交給下游的東西 | 只有中間結果 |
| 獨立觸發 | 用戶會單獨說「我要做這件事」嗎？ | 用戶會主動要求 | 只會在其他工作中順便做 |

**教學鉤子：** 想像你在餐廳 — 廚師、服務生、洗碗工是三個獨立角色（過 3 測試）。但「把盤子從左手換到右手」不是獨立角色，是服務生的子動作（沒過測試 1）。

**常見錯誤：**
- 過度拆分：每個小功能一個 skill → 用戶迷失在 30 個 skill 裡
- 過度合併：一個 skill 做所有事 → AI 沒有姿態切換，品質下降

**深入：** `shared/methodology/skill-map-methodology.md` Step 4

---

## 錨點 4: Artifact Flow（串接）

**一句話：** Skill 之間不靠 API 溝通，靠「把成品放在固定位置，下一站來拿」。

**運作方式：**
```
Skill A 完成 → 存 artifact 到 ~/.prismstack/projects/{slug}/
                 ↓
Skill B 啟動 → Phase 0 自動搜尋上游 artifact → 找到就讀、沒找到就獨立跑
```

**教學鉤子：** 工廠的流水線 — 每一站做完把半成品放在輸送帶上的固定位置。下一站不需要打電話問「做好了嗎？」，直接看輸送帶就知道。

**三個規則：**
1. 每個 artifact 必須有 producer 和 consumer（沒人讀 = 浪費）
2. 沒有斷點（每個 skill 都找得到上游）
3. 每個 skill 可以獨立跑（只是少了上游 context）

**常見混淆：**
- 「所以用戶要手動把檔案傳給下一個 skill？」→ 不用。skill 的 Phase 0 會自動搜尋。
- 「如果兩個 skill 同時產出同一種 artifact？」→ 用 timestamp 排序，取最新的。

**深入：** `shared/methodology/system-wiring-guide.md`

---

## 錨點 5: 15D 品質標準

**一句話：** 每個 skill 用 15 個維度評分（每項 0-2 分，滿分 30），分四個等級。

| 等級 | 分數 | 意思 |
|------|------|------|
| Production | 24-30 | 可以上線用 |
| Usable | 18-23 | 能用但有改善空間 |
| Draft | 12-17 | 草稿，需要迭代 |
| Skeleton | 0-11 | 骨架，還不能用 |

**5 層 15 維度（簡記）：**
- **A 入口層**（A1 Trigger / A2 Role / A3 Mode）— 用戶第一秒
- **B 流程層**（B4 Flow / B5 STOP / B6 Recovery）— 執行骨架
- **C 知識層**（C7 Gotchas / C8 Scoring / C9 Benchmarks）— 教 AI 什麼
- **D 結構層**（D10 Disclosure / D11 Scripts / D12 Config）— 檔案組織
- **E 系統層**（E13 Discovery / E14 Output / E15 Position）— 生態關係

**教學鉤子：** 把 skill 想像成一個員工的履歷 — 入口層是「面試第一印象」，知識層是「專業能力」，系統層是「跟團隊合作的能力」。

**常見錯誤：**
- Claude 審查時傾向全部給 2 分 → 規則：至少 5 個維度 < 2
- 改進建議太模糊 → 規則：必須指定哪個 section、改什麼、改成什麼樣

**深入：** `shared/methodology/quality-standards.md`

---

## 錨點 6: Skill 撰寫 8 大原則

**一句話：** 寫 skill 不是寫文件，是設計一個 AI 的行為模式。

| # | 原則 | 一句話 | 反面教材 |
|---|------|--------|---------|
| 1 | Trigger 先寫 | description 是 routing 規則，不是介紹 | 「A skill for reviewing.」 |
| 2 | Skill = 姿態切換 | 啟動要改變 AI 的行為模式 | 「You are a helpful assistant」 |
| 3 | Flow 外化 | 流程不能靠 AI 記住 | 靠 Claude 記「我在第幾輪」 |
| 4 | Gotchas > 教學 | AI 不知道的比已知的值錢 | 塞一堆通識教學 |
| 5 | 脆弱處嚴格 | 高風險任務每步都要 STOP | deploy 不設 gate |
| 6 | 骨架 + 細節分離 | SKILL.md ≤200 行，details 放 references/ | 500 行的單一檔案 |
| 7 | 定義 recovery | 中斷了怎麼恢復 | 只有 happy path |
| 8 | 產出可被下游讀 | 輸出是結構化 artifact，不是聊天文字 | 完成時只說「做好了」 |

**教學鉤子：** 寫 skill 就像設計遊戲關卡 — 你不是在寫攻略（教學），而是在設計地形（讓玩家自然做出正確行為）。

**深入：** `shared/methodology/skill-craft-guide.md`

---

## 錨點 7: Pipeline 與自動化

**一句話：** 多個 skill 串成 pipeline 就是讓工作從頭到尾自動流過每個站，人只在關鍵點做決定。

**手動 vs 自動：**

| 層級 | 做法 | 人的角色 |
|------|------|---------|
| 手動 | 用戶一個一個跑 skill | 每步都決定 |
| 半自動 | skill 之間靠 artifact flow 串接，用戶只在 STOP gate 決定 | 關鍵點決定 |
| 全自動 | Auto mode（跳過所有 STOP gate） | 只看最終結果 |

**怎麼從手動升級到自動：**
1. 先手動跑通整條 pipeline，確認每步的輸入輸出正確
2. 把 STOP gate 減少到只留「真正需要人判斷」的
3. 用 `/tool-builder` 把重複的操作包成 Runtime Helper
4. 最終用 orchestrator 的 `--auto` flag 跑全自動

**常見混淆：**
- 「自動化 = 不要 STOP gate？」→ 不是。STOP gate 是品質保護，只在確認品質穩定後才減少。
- 「pipeline 壞了怎麼辦？」→ 每個 skill 有 recovery 機制，可以從斷點繼續。

**教學鉤子：** 像開車 — 新手每個路口停下來看地圖（手動），熟練後只在紅燈停（半自動），最終用導航自動（全自動）。但在危險路口永遠要停。

---

## 錨點 8: STOP Gate 與 AskUserQuestion

**一句話：** STOP gate 是 skill 裡的「暫停鍵」，讓 AI 在關鍵決定前停下來問用戶。

**可靠格式（唯一有效的寫法）：**
```markdown
**STOP.** AskUserQuestion to confirm [什麼事]:

> [重新定位 + 白話解釋 + 推薦 + 選項]

**One question only. Wait for answer before proceeding.**
```

**為什麼格式這麼嚴格：**
- AI 模型需要特定格式才能可靠觸發 AskUserQuestion 工具
- 其他格式（表情符號、標題風格、裝飾框）模型會當成普通文字印出來
- 不是「建議」而是「唯一有效的做法」

**四段內容：**
1. Re-ground — 你在哪個 skill、做到哪（假設用戶離開 20 分鐘了）
2. Simplify — 16 歲也能懂的白話
3. Recommend — 永遠給推薦（「選 A，因為...」）
4. Options — A/B/C + D 逃生門

**教學鉤子：** STOP gate 就像遊戲的存檔點 — 讓你在安全的地方停下來，確認方向，然後才進入下一段。

**深入：** `shared/ask-format.md`

---

## 錨點 9: 約束即賦能

> 來源：autoresearch 7 大原則

**一句話：** 自主性靠的不是「沒有限制」，而是「精準的限制」— 範圍越小、指標越清、驗證越快，AI 能做的越多。

**三個約束維度：**

| 約束 | 怎麼約束 | 為什麼有用 |
|------|---------|-----------|
| **範圍約束** | 一次只改一個 skill、一個 section | 小範圍 = 容易驗證 = 容易回滾 |
| **指標約束** | 用可量化的標準判斷成功 | 「更好」不是指標，「15D 分數從 14 升到 20」是 |
| **時間約束** | 設定迭代次數上限 | 逼迫優先排序，避免無限修改 |

**教學鉤子：** 想像你在一條很寬的馬路上開車，沒有車道線 — 你反而開不快，因為不確定方向。車道線（約束）讓你敢踩油門（自主）。

**常見混淆：**
- 「STOP gate 太多會不會拖慢速度？」→ STOP gate 是車道線，不是路障。品質穩定後可以減少，但不是一開始就拿掉。
- 「約束不就是限制嗎？」→ 沒有約束的 AI 什麼都試但什麼都做不好。約束讓 AI 在小範圍內做到最好。

**實戰應用：**
- 新 stack：多約束（每步 STOP gate + 嚴格 scoring）
- 成熟 stack：少約束（只在高風險點 STOP + auto mode）
- 升級路徑：手動 → 半自動 → 全自動 = 約束逐漸放鬆

---

## 錨點 10: 機械驗證

> 來源：autoresearch mechanical verification gate

**一句話：** 如果你不能用一行命令得到一個數字來判斷成功，那你就不能自動迭代。

**四個驗證條件：**

| 條件 | 解釋 | 反例 |
|------|------|------|
| **輸出是數字** | 不是字串、不是「PASS」、不是感覺 | 「看起來好多了」 |
| **可用命令取得** | `grep`、`jq`、`wc` 等可以提取 | 需要人眼判斷 |
| **確定性** | 同樣輸入 → 同樣輸出 | 每次跑結果不同 |
| **快速** | < 30 秒，最好 < 10 秒 | 需要跑 5 分鐘才知道結果 |

**教學鉤子：** 「好不好」是意見，「15D 品質分數 22/30」是事實。意見可以吵，事實不行。機械驗證就是把意見變成事實的方法。

**在 Prismstack 裡的對應：**
- 15D 品質標準 = 機械驗證框架（每個維度 0-2 分，有明確判斷基準）
- skill-check 的評分 = 機械驗證的實例
- artifact flow 的 discovery = 機械驗證（搜到 = 通，搜不到 = 斷）

**常見混淆：**
- 「不是所有東西都能量化啊」→ 對。但能量化的先量化，不能量化的用 forcing question 處理（「如果移除這個 skill，pipeline 會斷嗎？」）
- 「分數高 = 品質好？」→ 分數是訊號，不是真理。但沒有分數你連訊號都沒有。

---

## 錨點 11: 鏈式組合

> 來源：autoresearch chaining & composition

**一句話：** 複雜的工作流程不是一口氣設計出來的，而是把簡單迴圈串成序列 — 每一段的輸出自動變成下一段的輸入。

**三層組合：**

```
Layer 1: 單一 Skill（一個迴圈）
  /review → 讀 artifact → 逐維度審查 → 輸出 review report

Layer 2: Skill 鏈（迴圈序列）
  /extract → /transform → /review → /edit
  每個 skill 的 artifact 自動被下一個 discovery

Layer 3: Pipeline（帶分支的鏈）
  /import → 偵測類型
    ├─ 圖片 → /image-review → /image-edit
    └─ 文字 → /text-review → /text-edit
  → /qa → /ship
```

**教學鉤子：** 積木。一塊積木（skill）很簡單。但把 10 塊按順序接起來（chain），就能蓋出一棟房子（pipeline）。重點不是每塊積木多厲害，而是接口對得上。

**關鍵原則：**
1. **先手動跑通再串** — 不確定每步的輸入輸出之前，不要串
2. **每步可獨立跑** — 少了上游 context 只是少了參考，不會壞掉
3. **輸出格式 = 下游的輸入合約** — artifact naming 就是 API contract

**常見混淆：**
- 「pipeline 很複雜」→ 不。pipeline 是簡單的東西排隊。複雜的是每個 skill 的內部邏輯，但那已經被封裝了。
- 「一定要按順序跑嗎？」→ 不一定。有些 skill 可以並行（都讀同一個上游 artifact）。但有依賴關係的必須順序。

**升級路徑：**
```
手動一個一個跑 → 理解 artifact flow 讓它自動串
→ 減少 STOP gate → 包成 helper → 跑 auto mode
```

---

## 錨點 12: 證據先於宣稱

> 來源：superpowers verification-before-completion

**一句話：** 沒跑過驗證命令就說「做完了」，不是效率，是不誠實。

**驗證五步：**

```
1. IDENTIFY — 什麼命令能證明這個宣稱？
2. RUN     — 跑完整命令（不是部分、不是上次的結果）
3. READ    — 讀完整輸出（不是只看最後一行）
4. VERIFY  — 輸出是否確認宣稱？
5. CLAIM   — 只有通過才能說「做完了」
```

**紅旗（說了這些 = 沒有證據）：**
- 「應該可以了」「看起來對了」「大概沒問題」
- 「我已經改了」（但沒跑測試）
- 「跟上次一樣」（但上次的結果可能已經失效）

**教學鉤子：** 法庭不接受「我覺得他有罪」，要證據。Skill 的品質宣稱也一樣 —「我覺得這個 skill 很好」不算，「15D 評分 24/30，每個維度的分數是...」才算。

**在 Prismstack 裡的對應：**
- `/skill-check` 的 15D 評分 = 證據
- artifact flow 的 discovery test = 證據（跑一次看搜到沒）
- completion protocol 的 STATUS = 基於證據的宣稱

---

## 錨點 13: 根因追溯

> 來源：autoresearch debug workflow + superpowers systematic debugging

**一句話：** 問題出現的地方不是問題的來源。永遠向後追蹤，找到源頭再修。

**5 Whys 方法：**

```
症狀：/review skill 的評分不準
Why 1：scoring formula 的權重不對
Why 2：權重是從通識領域複製的，沒有針對用戶領域調整
Why 3：/domain-build 生成 skill 時沒有讀取 domain-config 裡的 benchmarks
Why 4：domain-config 裡沒有 benchmarks（用戶沒提供）
Why 5（根因）：/domain-plan 沒有在 Phase 3 問用戶要 benchmarks
→ 修 /domain-plan，不是修 /review 的權重
```

**教學鉤子：** 頭痛不一定是頭的問題 — 可能是頸椎壓迫。吃止痛藥（修症狀）只是暫時的，看骨科（追根因）才能根治。

**追溯工具：**
- artifact 的 Supersedes chain → 看這個 artifact 是怎麼演變的
- decision-log.jsonl → 看 skill 的決策歷史
- git log → 看什麼時候改了什麼

**架構升級門（3 次修不好 = 設計問題）：**

```
修第 1 次 → 問題換個地方出現
修第 2 次 → 又出現新的問題
修第 3 次 → STOP.

這不是修復問題，是設計問題。
退一步，問：
- 這個 skill 的職責是不是太大了？（拆分）
- 上下游的 artifact 合約對嗎？（重新設計接口）
- 這個 skill 應該存在嗎？（合併或刪除）
```

---

## 怎麼用這份文件

引導員不應該把錨點原文貼給用戶。正確用法：

1. 判斷用戶想學的主題 → 找到對應的錨點
2. 讀錨點的「一句話」和「教學鉤子」→ 作為推理起點
3. 讀用戶的 domain stack → 找到具體的 skill 或 artifact 當例子
4. 用推理框架（SKILL.md Phase 1）即時生成教學內容
5. 教學鉤子是類比的起點，不是唯一的類比 → 根據用戶的領域生成更貼切的類比
