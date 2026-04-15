# 診斷模式清單

> 用途：引導員診斷模式的症狀 → 策略對照表。
> 引導員掃描用戶的 domain stack 狀態 + 聽用戶的話 → 匹配下面的模式 → 執行對應策略。
> 不是所有症狀都能從 stack 偵測到，有些靠用戶的用詞判斷。

---

## 模式 1: 空白起步

**症狀：**
- `HAS_SKILL_MAP=0`，沒有 domain stack
- 用戶說「不知道從哪開始」「我想建一套 skill」

**根因：** 用戶還沒進入 Prismstack 的流程。

**策略：**
```
1. 不要說「你需要先跑 /domain-plan」（太直接，用戶不理解為什麼）
2. 用 Prismstack 自身當範例，快速展示一個 skill 的運作
3. 問用戶：「你平常的工作從開始到交付，經過哪些步驟？」
4. 用這些步驟帶入「為什麼要拆成 skill」的概念
5. 如果用戶準備好了 → 建議跑 /domain-plan
6. 如果用戶還沒準備好 → 繼續教學，不急著推流程
```

---

## 模式 2: 有 Stack 但不會用

**症狀：**
- `HAS_SKILL_MAP=1`，有 skill map
- 有 skill 檔案，但 artifact 很少（`ARTIFACTS < 3`）
- 用戶說「建好了但不知道怎麼用」「跑過一次就沒再用」

**根因：** 用戶不理解 skill 之間怎麼串、每個 skill 什麼時候用。

**策略：**
```
1. 讀 skill map → 畫出用戶的完整 workflow
2. 問用戶：「你現在手上有什麼工作？」
3. 把那個工作對應到 workflow 裡的某個 skill
4. 帶用戶跑一次那個 skill → 產出 artifact
5. 然後帶看下游 skill 怎麼自動讀到這個 artifact
6. 目標：讓用戶體驗到「喔原來是這樣串起來的」
```

---

## 模式 3: 卡在某個 Skill

**症狀：**
- 用戶說「這個 skill 跑不動」「結果不對」「不知道怎麼調」
- 可能有 decision-log.jsonl 紀錄但 status 是 BLOCKED

**根因：** 可能是 skill 品質問題、用戶輸入不足、或概念理解有誤。

**策略：**
```
1. 讀那個 skill 的 SKILL.md → 理解它的設計
2. 讀 decision-log.jsonl → 看最近的執行紀錄
3. 判斷卡在哪裡：
   a. Skill 本身品質差（缺 gotchas、scoring 不準）
      → 建議用 /skill-check 檢查，然後 /skill-edit 修
   b. 用戶的輸入不足（缺上游 artifact）
      → 帶看上游 skill，先跑上游
   c. 用戶理解有誤（以為 skill 做 X 但它做的是 Y）
      → 解釋 skill 的真實用途，可能需要換 skill
4. 給具體的下一步行動（不是「你可以考慮」）
```

---

## 模式 4: Pipeline 斷裂

**症狀：**
- 有多個 skill 但 artifact flow 不通
- 某些 skill 的 Phase 0 找不到上游
- 用戶說「跑完 A 之後 B 讀不到」「artifact 不見了」

**根因：** Skill 之間的命名/路徑/discovery 沒對上。

**策略：**
```
1. 掃描所有 skill 的 Phase 0 discovery pattern
2. 掃描所有 skill 的 save pattern
3. 比對：A 的 save 命名 vs B 的 discovery glob — 對得上嗎？
4. 找到斷裂點 → 帶用戶修復：
   a. Save 命名不對 → 修 save pattern
   b. Discovery glob 不對 → 修 Phase 0
   c. 路徑不對 → 確認都用 $_PROJECTS_DIR
5. 修完後帶跑一次驗證
6. 教學延伸：解釋 artifact flow 的三規則（有 producer、有 consumer、可獨立跑）
```

---

## 模式 5: 品質瓶頸

**症狀：**
- 用戶跑 /skill-check 得到低分
- 用戶說「分數為什麼這麼低」「怎麼提高品質」
- Skill 在 Draft 或 Skeleton 等級

**根因：** Skill 缺少關鍵機制（gotchas、scoring、recovery 等）。

**策略：**
```
1. 讀 check-results.json（如果有）→ 看哪些維度低
2. 如果沒有 check results → 快速掃 skill 的 frontmatter + 結構
3. 找到最有效的改善點（投入產出比最高的）：
   - 通常：加 gotchas (C7) > 加 scoring (C8) > 加 recovery (B6)
   - 因為 gotchas 是最高價值內容，scoring 是品質保障
4. 帶用戶做一個改善（不是全部改完）
5. 改完後快速估算新分數 → 讓用戶看到進步
6. 指出下一個值得改的維度
```

---

## 模式 6: 想自動化但不知怎麼做

**症狀：**
- 用戶說「每次都手動跑好煩」「怎麼自動化」「想做 pipeline」
- 有一定數量的 skill 且手動跑過多次

**根因：** 用戶在「手動」到「半自動」的跨越點。

**策略：**
```
1. 確認用戶的 pipeline 手動跑通過了（如果沒有 → 先回模式 4）
2. 盤點哪些步驟是重複的、不需要人判斷的
3. 按升級路徑教學：
   a. 先確認 artifact flow 通暢（已通 → 跳過）
   b. 識別哪些 STOP gate 可以移除（品質穩定的步驟）
   c. 識別哪些操作可以用 /tool-builder 包成 helper
   d. 最終目標：auto mode
4. 帶做第一步（通常是移除一個不必要的 STOP gate 或建一個簡單 helper）
5. 不要一次全自動 — 漸進式升級
```

---

## 模式 7: 倦怠

**症狀：**
- 用戶說「好煩」「太複雜了」「算了」「不想搞了」
- 語氣消極、回覆越來越短
- 連續多個 session 沒有 breakthrough

**根因：** 學習曲線太陡、沒有成就感、或問題太多看不到進展。

**策略：**
```
1. 承認倦怠 — 不裝沒看到
   「聽起來你有點累了，這很正常」

2. 不推更多工作
   ❌「我們再做一個就好」
   ✅「你現在到這裡其實已經 ___」

3. 給成就感
   指出用戶已經達成的里程碑（已有的 skill 數量、已通過的 pipeline 等）

4. 給書籤
   「下次回來可以從 ___ 繼續，不用重新開始」
   寫入 learning-profile.json 的 next_suggested_topic

5. 允許離開
   不追問、不挽留。下次用戶回來時，從書籤恢復。
```

---

## 模式 8: 想加新 Skill 但不確定

**症狀：**
- 用戶說「我覺得需要一個 XX 的 skill」「這個工作應該變成 skill 嗎」
- 有現有 stack，想擴充

**根因：** 用戶有直覺但不知道怎麼判斷。

**策略：**
```
1. 帶跑 3 獨立性測試（具體、用用戶描述的功能）：
   a. 啟動後 AI 會切換思考方式嗎？
   b. 結束時有獨立有價值的 artifact 嗎？
   c. 用戶會單獨說「我要做這個」嗎？
2. 根據結果判斷：
   - 3 個都過 → 適合獨立 skill，建議用 /skill-gen
   - 1-2 個過 → 適合合併到現有 skill 的 section
   - 0 個過 → 不需要做
3. 如果適合獨立 skill → 進一步判斷類型（5 類），確認在 workflow 的位置
4. 教學延伸：解釋 Merge vs Split 的判斷標準
```

---

## 模式 9: 概念性困惑（知道要做但不理解為什麼）

**症狀：**
- 用戶問「為什麼」的問題
- 「為什麼要用 STOP gate」「為什麼不能一個 skill 做所有事」「為什麼要分 5 種類型」
- 能操作但不理解設計意圖

**根因：** 操作和理解分離。用戶跟著步驟做，但不知道背後的原理。

**策略：**
```
1. 不要回答「因為方法論規定」— 這是無效回答
2. 用反面教學法：展示「如果不這樣做會怎樣」
   - 不用 STOP gate → AI 跑完一整個流程但中間做了錯誤決定，用戶到最後才發現
   - 一個 skill 做所有事 → AI 沒有姿態切換，用「reviewer」的態度做「production」的工作
3. 用用戶自己的 stack 舉例（不是假想案例）
4. 確認理解：用 forcing question 測試
```

---

## 模式 10: 架構升級門（修 3 次沒好）

> 來源：superpowers systematic debugging — Phase 4.5

**症狀：**
- 用戶反覆修同一個 skill 但問題反覆出現
- 每次修完，問題轉移到另一個地方
- 用戶說「又壞了」「改完這裡那裡又有問題」「越改越亂」

**根因：** 不是修復的問題，是設計的問題。一個 skill 承擔了不該承擔的職責，或 skill 之間的 artifact 合約從一開始就不對。

**策略：**
```
1. 確認修過幾次
   問或從 decision-log 看：這個問題改過幾版了？
   
2. 如果 ≥ 3 次 → 觸發架構升級門
   不要嘗試第 4 次修復。
   
3. 退一步分析：
   a. 這個 skill 的職責清單 — 是不是太多了？
      - 用 3 獨立性測試重新檢驗
      - 超過 1 個姿態 → 候選拆分
   b. 上下游的 artifact 合約 — 對得上嗎？
      - 上游 save 的格式 vs 這個 skill 的 discovery glob
      - 這個 skill 的 output vs 下游 expect 的 input
   c. 這個 skill 應該存在嗎？
      - 拿掉它 pipeline 會斷嗎？如果不會 → 可能不需要

4. 帶用戶做設計層面的改動（不是修內容）：
   - 拆分 skill → /skill-gen 建新 skill + /skill-edit 瘦身舊 skill
   - 重新設計 artifact 合約 → /workflow-edit
   - 合併或刪除 → /skill-edit

5. 教學延伸：
   「修 3 次沒好通常意味著問題不在你改的地方。
   下次遇到這種情況，直接退一步看整體設計。」
```

---

## 模式 11: 證據缺失（宣稱沒有驗證）

> 來源：superpowers verification-before-completion

**症狀：**
- 用戶說「做好了」但沒跑過 /skill-check
- 用戶說「pipeline 通了」但沒有實際跑過一次完整流程
- Skill 的 completion status 是 DONE 但沒有附帶分數或 artifact
- 用戶用「應該」「大概」「看起來」等模糊詞

**根因：** 用戶把「改完」等同於「做好」。缺乏驗證習慣。

**策略：**
```
1. 不評判，用問題引導
   ❌「你沒有驗證」
   ✅「你跑過一次完整流程嗎？我們來看看結果」

2. 帶跑一次驗證
   - skill 品質 → 用 /skill-check 跑 15D 評分
   - pipeline 連通 → 從頭跑一次，看每步 artifact 有沒有被下游讀到
   - skill 產出品質 → 用真實案例跑一次，看結果

3. 展示差距
   「你說做好了，我們來看分數：15D = 14/30，是 Draft 等級。
   Production 需要 24+。差距在 C7（沒有 gotchas）和 C8（沒有 scoring）。」

4. 建立驗證習慣
   教用戶「證據五步」：
   IDENTIFY → RUN → READ → VERIFY → CLAIM
   「以後每次說做好了之前，跑這五步。第一次會慢，習慣後 30 秒就能做完。」
```

---

## 模式 12: 盲目跟步驟（做了但不理解）

> 來源：autoresearch separation of strategy vs tactics

**症狀：**
- 用戶按步驟做完了每一步，但問「為什麼要這樣做」答不上來
- Skill 的產出格式正確但內容是通識的（沒有領域特殊性）
- 用戶跑完 /domain-build 但不知道怎麼修改產出的 skill

**根因：** 用戶在「執行」但沒有在「理解」。操作和理解分離。

**策略：**
```
1. 偵測信號
   產出的 skill 通過 substitution test 嗎？
   （把領域名稱換掉，skill 還能用 = 沒有領域特殊性 = 盲目跟步驟）

2. 停在一個具體的 skill 上深挖
   不要繼續跑流程。選一個 skill，帶用戶重新走一遍：
   「這個 /review skill 的 scoring formula 你看，權重 3:2:1。
   為什麼是 3:2:1 不是 1:1:1？在你的領域，哪個維度最重要？」

3. 用 forcing question 測試理解
   「如果我把這個 gotcha 拿掉，你的 AI 會犯什麼錯？」
   如果用戶答不上來 → 這個 gotcha 不是用戶的，是 LLM 自動生成的

4. 帶用戶產出一個真正屬於他的 gotcha
   「想一個你的領域裡，AI 最容易犯但外行人不知道的錯。
   那就是你最有價值的 gotcha。」

5. 教學原則
   「步驟是骨架，你的領域知識是血肉。
   沒有血肉的骨架能站但不能動。」
```

---

## 症狀偵測優先序

當多個模式的症狀同時出現時：

```
倦怠（模式 7）→ 最優先處理。用戶沒心力學新東西。
架構升級門（模式 10）→ 其次。反覆修補是設計問題，越早發現越好。
卡關（模式 3）→ 其次。先解除阻塞。
Pipeline 斷裂（模式 4）→ 其次。影響所有下游。
證據缺失（模式 11）→ 中等。用戶以為做完了但其實沒有。
盲目跟步驟（模式 12）→ 中等。操作完成但沒有理解。
其他 → 按用戶的意圖判斷。
```

**規則：永遠先處理情緒，再處理技術。反覆修補（模式 10）優先於繼續修補（模式 3）。**
