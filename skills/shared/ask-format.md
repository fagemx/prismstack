# AskUserQuestion — 可靠觸發格式

> 這份文件定義的不只是「問什麼」，更重要的是「怎麼寫才能讓模型可靠地呼叫 AskUserQuestion 工具」。
> 格式不對 → 模型把選項印成文字 → 用戶看到的是一堆字不是按鈕 → STOP gate 失效。

## 可靠觸發語法

在 SKILL.md 中，STOP gate 必須用以下格式寫：

```markdown
**STOP.** AskUserQuestion to confirm [什麼事]:

> [摘要：剛完成什麼 + 接下來要做什麼]
>
> RECOMMENDATION: Choose A — [理由]
>
> A) [選項] — [說明]
> B) [選項] — [說明]
> C) [選項] — [說明]
> D) Skip / 先停在這裡

**One question only. Wait for answer before proceeding.**
```

### 為什麼是這個格式

| 元素 | 作用 | 不寫會怎樣 |
|------|------|-----------|
| `**STOP.**` | 模型辨識為停止點 | 模型可能自動跳過 |
| `AskUserQuestion to confirm` | 明確指示呼叫工具 | 模型可能把選項印成文字 |
| `>` blockquote | 模型辨識為工具的 input | 模型可能混淆內容邊界 |
| 字母選項 `A) B) C)` | 映射成 options 陣列 | 模型可能產出非結構化選項 |
| `**One question only.**` | 防止模型一次問多題 | 模型可能把 3 個問題塞一起 |

### 已驗證的模型行為

用此格式時，模型會：
1. 先呼叫 `ToolSearch` 找到 AskUserQuestion 工具
2. 呼叫 AskUserQuestion，產出結構化的 `{ questions: [{ header, question, options }] }`
3. 等待用戶回應後才繼續

## 四段內容格式

AskUserQuestion 的 `question` 欄位內容遵循四段格式：

### 1. Re-ground（重新定位）
說明目前在哪個 skill、哪個 Phase、做到哪裡。
假設用戶離開了 20 分鐘。

### 2. Simplify（簡化）
用白話解釋。16 歲的人也能聽懂。不用術語。

### 3. Recommend（推薦）
`RECOMMENDATION: Choose X — 因為 Y`

### 4. Options（選項）
```
A) [選項] — [說明]
B) [選項]
C) [選項]
D) Skip / 先停在這裡（永遠保留逃生門）
```

## ❌ 不可靠的格式（不要用）

```markdown
# 這些格式模型不一定會呼叫 AskUserQuestion 工具：

❌ 🛑 STOP Gate：AskUserQuestion      ← 標題風格，模型當裝飾
❌ ### STOP Gate 1：確認鏡頭            ← 標題風格
❌ 請確認：A. 繼續 B. 調整              ← 文字風格，不會觸發工具
❌ ━━━ Phase 1 完成 ━━━                ← 裝飾邊框，模型照印
```

## 範例

### Review skill 的 section STOP

```markdown
**STOP.** AskUserQuestion to confirm scoring:

> 完成構圖維度審查。評分：7/10（扣分：CTA 位置偏高 -2、前景空白 -1）。
>
> RECOMMENDATION: Choose A — 分數合理，繼續下一維度。
>
> A) 確認分數，繼續審查下一維度
> B) 調整構圖分數（告訴我理由）
> C) 先停在這裡

**One question only. Wait for answer before proceeding.**
```

### Pipeline 的分流 STOP

```markdown
**STOP.** AskUserQuestion to confirm routing:

> 已提取 3 支廣告。分流：2 圖片、1 影片。
> 圖片走 ad-prompt，影片走 script-breakdown → shotgen。
>
> RECOMMENDATION: Choose A — 分流正確就開始生產。
>
> A) 確認分流，開始 Phase 3
> B) 修改某支的類型
> C) 只跑圖片
> D) 取消

**One question only. Wait for answer before proceeding.**
```
