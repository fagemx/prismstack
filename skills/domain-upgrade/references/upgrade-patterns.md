# Upgrade Patterns Reference

## User Brings Needs

| User Says | Real Need | Action |
|-----------|-----------|--------|
| 「加一個 X skill」 | Maybe new skill, maybe section | Clarify → /skill-gen or /skill-edit |
| 「這個 skill 不好用」 | Something specific is wrong | Diagnose → /skill-edit |
| 「工作流程變了」 | Workflow restructure | Analyze → /workflow-edit |
| 「這篇文章的方法很好」 | Source conversion | → /source-convert |
| 「幫我自動化 X」 | Tool building | → /tool-builder |

## User Brings Test Feedback (Step 4 Mode)

Feedback classification:

- **A類（自動修）：** 詞彙不對、artifact 格式不接、trigger 描述不準
- **B類（討論後修）：** 判斷維度缺了、判斷方向錯了、互動節奏不對
- **C類（需要升級材料）：** gotchas 太淺、benchmark 不對、缺領域深度

## Upgrade Effect Check

3-question quick check after each change:

1. Workflow 更有用了嗎？
2. 判斷比 baseline 更準了嗎？
3. 有沒有破壞其他 skill 的銜接？

## Upgrade Granularity

不一定要替換整個 skill。可以只升級一個 section：

- 替換整個 skill（用外部 skill 取代）
- 替換 scoring formula（用更好的評分方式）
- 加 gotchas（加幾條實戰踩過的坑）
- 換 benchmarks（用真實數據替換大模型猜的）
- 加 forcing questions（加幾個更尖銳的問題）
- 改 review dimensions（調整審查維度和權重）
- 改 anti-sycophancy（加領域特定的空洞讚美禁止清單）

## User-Driven Upgrade Paths

When user says "I want to upgrade /X", ask:

- A. 我有一個現成的 skill/prompt 做這件事 → 匯入，評估 fit，替換或合併
- B. 我有相關的代碼庫/資料/文件 → 分析提取判斷規則，填入對應 section
- C. 我知道一個好的外部方法/框架（文章、影片、書）→ 告訴我來源，我讀完整合進去
- D. 我自己有經驗想分享 → 我先給你看現在的版本，你在上面改
- E. 我不確定怎麼升級，但覺得現在的版本不夠好 → 告訴我哪裡不好，我們一起改

## Need Clarification Pattern

When user wants to add something, think:

- 他真的需要一個獨立的 skill 嗎？
- 還是在現有 skill 裡加一個 section 就夠了？
- 他的 workflow 裡這個 skill 在哪個位置？
- 有上游 artifact 嗎？有下游消費者嗎？

Offer options:
- A. 每次都需要獨立做一次完整的 X → 獨立 skill
- B. 做某件事的時候順便看一下 → 加到現有 skill 裡
- C. 不確定 → 先加成 section，用看看，太重再拆出來
