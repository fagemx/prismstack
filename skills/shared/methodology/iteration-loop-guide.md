# 迭代改進迴圈指南

> 用途：Production 和 Runtime Helper 類型的 domain skill，當任務需要「反覆改進直到滿意」時使用。
> 語境：你正在幫用戶設計一個需要迭代迴圈的 skill（例：素材生成 → 審查 → 修改 → 再審）。
> 不是 fix-loop-guide（那是修 skill 品質的）。這是 skill 內部的工作迭代迴圈。

---

## 何時使用

Domain skill 需要迭代迴圈的信號：
- 產出品質需要「越做越好」（例：廣告素材、課程教材、遊戲關卡）
- 有明確的品質指標可以量化改善（例：分數、通過率、錯誤數）
- 單次產出不太可能完美，需要多輪修正

不需要迭代迴圈的 skill：
- Review 類（看一次就夠，不改東西）
- Bridge 類（轉換格式，對就是對）
- Control 類（routing，不產出內容）

---

## 8 Phase 迭代迴圈

### Phase 1: Review（回顧）
讀取上一輪的結果。第一輪時讀取初始狀態 / baseline。
- 讀什麼：上一輪的產出 + 上一輪的評分 + 上一輪的修改記錄
- 目的：知道「現在在哪裡」

### Phase 2: Ideate（構思）
基於上一輪的結果，決定這一輪改什麼。
- 問：上一輪哪個維度最弱？哪個改動最可能提升整體分數？
- 規則：每輪只改一個面向（不要同時改 3 件事，因果無法追蹤）

### Phase 3: Modify（修改）
執行這一輪的改動。
- 最小改動原則：只改 Phase 2 決定要改的那一個面向
- 記錄改了什麼（為了 Phase 7 的 Decide 能比較）

### Phase 4: Snapshot（存檔）
在驗證之前，存下當前狀態。
- 為什麼：如果驗證失敗需要 revert，必須有存檔點
- 方式：git commit、存 artifact、或存 state file

### Phase 5: Verify（驗證）
用機械指標驗證改動的效果。
- 指標必須是機械的（數字、pass/fail、分數），不是主觀的（「看起來不錯」）
- 範例：scoring formula 算出的分數、checklist 通過率、錯誤數量

### Phase 6: Guard（護欄）
檢查改動有沒有破壞其他維度。
- Verify 只看「目標指標有沒有改善」
- Guard 看「其他指標有沒有變差」
- 範例：改了 CTA 的視覺效果（Verify: CTA 分數升了），但品牌一致性降了（Guard: 品牌分數降了）
- Guard 失敗 → 回 Phase 3 rework（最多 2 次），仍失敗 → revert

### Phase 7: Decide（決定）
根據 Verify + Guard 的結果決定 keep 或 revert。
- Verify 通過 + Guard 通過 → **Keep**（保留改動）
- Verify 通過 + Guard 失敗 → **Rework**（回 Phase 3，帶 Guard 失敗的約束）
- Verify 失敗 → **Revert**（回到 Phase 4 的存檔點）

### Phase 8: Log（記錄）
記錄這一輪的結果，供下一輪的 Phase 1 讀取。

```
round | action | metric_before | metric_after | delta | guard_pass | status | description
1     | 調整 CTA 大小 | 65 | 72 | +7 | yes | keep | CTA 從 36px 放大到 48px
2     | 改背景對比度 | 72 | 71 | -1 | - | revert | 對比度改了反而降分
3     | 加品牌浮水印 | 72 | 78 | +6 | yes | keep | 右下角加品牌標誌
```

---

## 停止條件

| 條件 | 動作 |
|------|------|
| 達到目標分數 | 停止，報告結果 |
| 連續 3 輪 revert（改什麼都變差） | 停止，報告「已達局部最優」 |
| 達到最大輪數（預設 10 輪） | 停止，報告當前最佳 |
| 用戶打斷 | 停止，報告進度 |

---

## 嵌入到 Domain Skill 的方式

Production 或 Runtime Helper 類型的 skill 可以這樣嵌入迭代迴圈：

```markdown
## Phase N: 迭代改進

按 `shared/methodology/iteration-loop-guide.md` 的 8 Phase 迴圈執行。

指標：[這個 skill 的 scoring formula]
Guard：[這個 skill 的其他維度分數不能降]
停止條件：[目標分數] 或 [最大輪數]

每輪結束後 STOP gate，讓用戶看到進度和當前狀態。
```

---

## 5 條迭代原則

1. **每輪只改一件事** — 同時改多件無法追蹤因果
2. **指標必須機械** — 「看起來不錯」不算指標。用 scoring formula 算出的數字才算
3. **先存檔再驗證** — 驗證失敗時要能回退
4. **Guard 和 Verify 分開** — 目標改善了但其他東西壞了 = 不算成功
5. **記錄每一輪** — 下一輪需要知道上一輪做了什麼、結果如何
