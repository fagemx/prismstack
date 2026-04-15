# 累積紀錄格式

> 用途：引導員記錄用戶的學習歷程。讓下次教學更精準。
> 存放位置：`~/.prismstack/projects/{slug}/.prismstack/guide-logs/`
> 兩個檔案：`learning-profile.json`（當前快照）+ `session-log.jsonl`（歷史紀錄）

---

## learning-profile.json

用戶的學習畫像。每次對話結束時更新（覆寫）。

```json
{
  "last_session": "2026-04-15T14:30:00+08:00",
  "sessions_count": 5,
  "user_level": "intermediate",
  "domain": "ecommerce",

  "topics_covered": [
    {
      "topic": "artifact-flow",
      "depth": "full",
      "date": "2026-04-10",
      "subtopics": ["discovery-pattern", "save-pattern", "supersedes-chain"]
    },
    {
      "topic": "skill-types",
      "depth": "partial",
      "date": "2026-04-12",
      "subtopics": ["review", "bridge"],
      "remaining": ["production", "control", "runtime-helper"]
    }
  ],

  "confusions": [
    {
      "topic": "stop-gates",
      "detail": "不理解為什麼格式這麼嚴格，以為任何格式都能觸發 AskUserQuestion",
      "resolved": true,
      "resolution_date": "2026-04-12"
    },
    {
      "topic": "independence-test",
      "detail": "把「獨立姿態」跟「獨立產出」搞混",
      "resolved": false
    }
  ],

  "breakthroughs": [
    {
      "topic": "artifact-flow",
      "insight": "理解了 skill 之間靠 filesystem 串接而不是 API",
      "date": "2026-04-10"
    }
  ],

  "preferences": {
    "learning_style": "prefer-code-over-diagrams",
    "pace": "fast",
    "detail_level": "show-me-the-file",
    "notes": "不喜歡長篇解釋，喜歡直接看 code 然後問"
  },

  "domain_insights": [
    {
      "insight": "電商的退貨流程跟下單流程是反向的，需要獨立的 bridge skill",
      "date": "2026-04-13"
    }
  ],

  "next_suggested_topic": "production-type-skills",
  "next_reason": "已學完 review 和 bridge 類型，production 是下一個自然進度"
}
```

### 欄位說明

| 欄位 | 類型 | 說明 |
|------|------|------|
| `last_session` | ISO datetime | 最後一次對話時間 |
| `sessions_count` | number | 總對話次數 |
| `user_level` | string | `beginner` / `intermediate` / `advanced`（從行為判斷，不問用戶） |
| `domain` | string | 用戶的領域（從 domain-config 或對話推斷） |
| `topics_covered` | array | 教過的主題。`depth`: `intro` / `partial` / `full` |
| `confusions` | array | 用戶的困惑點。`resolved`: 是否已解決 |
| `breakthroughs` | array | 用戶的突破時刻。記錄原始洞察 |
| `preferences` | object | 學習風格偏好 |
| `domain_insights` | array | 用戶透露的領域知識（可能影響教學舉例） |
| `next_suggested_topic` | string | 下次建議的主題 |
| `next_reason` | string | 為什麼建議這個主題 |

### user_level 判斷基準

| 等級 | 行為信號 |
|------|---------|
| `beginner` | 不知道什麼是 skill、問基礎概念、stack 是空的 |
| `intermediate` | 有 domain stack、能跑 skill、但不理解設計原理或不會串接 |
| `advanced` | 理解方法論、能自己設計 skill、想學自動化或優化 |

---

## session-log.jsonl

每次對話的紀錄。Append-only（只加不改）。

每行一筆 JSON：

```json
{"date":"2026-04-10T14:30:00+08:00","mode":"teaching","topic":"artifact-flow","subtopics":["discovery","save"],"outcome":"full-understanding","user_questions":["怎麼讓兩個 skill 串起來"],"confusions_found":[],"breakthroughs":["理解 filesystem 串接"],"duration_estimate":"15min"}
{"date":"2026-04-12T10:00:00+08:00","mode":"qa","topic":"stop-gates","subtopics":["format"],"outcome":"resolved","user_questions":["為什麼 STOP gate 格式這麼嚴格"],"confusions_found":["以為任何格式都行"],"breakthroughs":["理解模型需要特定格式才觸發工具"],"duration_estimate":"5min"}
{"date":"2026-04-13T16:00:00+08:00","mode":"diagnostic","topic":"stack-health","subtopics":[],"outcome":"action-plan-given","user_questions":["不知道下一步"],"confusions_found":[],"breakthroughs":[],"notes":"用戶有倦怠信號，給了書籤，沒推進","duration_estimate":"8min"}
```

### 欄位說明

| 欄位 | 說明 |
|------|------|
| `mode` | `teaching` / `qa` / `diagnostic` |
| `topic` | 主要主題（對應 methodology-anchors.md 的錨點名稱） |
| `subtopics` | 細分主題 |
| `outcome` | `full-understanding` / `partial` / `resolved` / `unresolved` / `action-plan-given` |
| `user_questions` | 用戶原始問題（保留原文） |
| `confusions_found` | 這次發現的困惑 |
| `breakthroughs` | 這次的突破 |
| `duration_estimate` | 估算時長 |
| `notes` | 特殊備註（例如倦怠信號） |

---

## 讀寫規則

### 讀取（Phase 0）

```
1. 如果 learning-profile.json 存在 → 讀取
2. 掃描 confusions 裡 resolved=false 的 → 注意這次對話中機會再次教導
3. 讀 next_suggested_topic → 作為建議（不強制）
4. 讀 preferences → 調整教學風格
5. 讀 topics_covered → 不重複教已經 depth=full 的主題（除非用戶主動問）
```

### 寫入（Phase 4 / Completion）

```
1. 回顧對話中用戶的所有輸入
2. 萃取 5 種信號：confusion / breakthrough / preference / progress / domain-insight
3. 更新 learning-profile.json：
   - topics_covered: 新增或更新 depth
   - confusions: 新增或標記 resolved
   - breakthroughs: 新增
   - preferences: 更新（如果用戶表達了新偏好）
   - domain_insights: 新增
   - next_suggested_topic: 根據本次進度推算
4. Append session-log.jsonl
5. 更新 sessions_count 和 last_session
```

### 衝突解決

| 衝突 | 處理 |
|------|------|
| 之前記「用戶不懂 X」，這次用戶展現了 X 的理解 | 標記 `resolved=true` |
| 之前記「用戶偏好 A」，這次用戶說不要 A | 更新 preferences，在 session-log 記錄變化 |
| 同一主題記了 depth=full，用戶又問同一主題 | 不改 depth，但在 session-log 記錄「revisited」 |

### 什麼不記

- 「好」「繼續」「A」等操作指令
- 已在 domain-config.json 的 accumulated section 裡的資訊
- 跟學習無關的閒聊
- 用戶的個人資訊（不記名字、公司等）
