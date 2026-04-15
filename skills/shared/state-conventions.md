# Prismstack State Conventions

## State Directory
每個 domain project 的 Prismstack 狀態存在：
`~/.prismstack/projects/{slug}/.prismstack/`

## State Files
| File | Written By | Read By | Purpose |
|------|-----------|---------|---------|
| `domain-config.json` | /domain-plan | All skills | Domain name, lifecycle, viewer roles |
| `skill-map.json` | /domain-plan | /domain-build, /skill-gen, /workflow-edit | Structured skill map (machine-readable) |
| `build-progress.md` | /domain-build | /domain-build (resume) | Build status per skill |
| `check-results.json` | /skill-check | /domain-upgrade, /skill-edit | Last review scores per skill |
| `edit-log.jsonl` | /skill-edit | /domain-upgrade | Edit history (append-only) |
| `convert-log.jsonl` | /source-convert | /domain-upgrade | Conversion history |
| `upgrade-log.jsonl` | /domain-upgrade | /domain-upgrade (resume) | Upgrade dispatch history |
| `workflow-snapshot.md` | /workflow-edit | /workflow-edit (resume) | Last known workflow graph |
| `discovery-notes.md` | /tool-builder | /tool-builder (resume) | Exploration discoveries |
| `timeline.jsonl` | Preamble (start) + Completion (complete) | Preamble (recovery, prediction) | Skill 使用歷史（append-only） |

## Convention Rules
1. State dir created on first skill run (mkdir -p)
2. JSON for machine-readable data, .md for human-readable, .jsonl for append-only logs
3. Skills read state but never delete other skills' state files
4. State is per-project (not global) — different domains have different state
5. If state file doesn't exist, skill runs normally (first time)

## domain-config.json Schema
```json
{
  "domain": "行銷創意生產",
  "created": "2026-03-25",
  "lifecycle_stages": ["策略", "發想", "規格", "生產", "驗證", "投放"],
  "skill_count": 31,
  "last_build": "2026-03-25T14:30:00Z",
  "last_check": null,
  "last_upgrade": null
}
```

## timeline.jsonl Schema

每行一筆 JSON，append-only：
```json
{"ts":"2026-04-15T10:00:00Z","skill":"domain-plan","event":"started","branch":"main","session":"12345-1713168000"}
{"ts":"2026-04-15T10:32:00Z","skill":"domain-plan","event":"completed","branch":"main","outcome":"done","duration_s":"1920","session":"12345-1713168000"}
```

| 欄位 | 說明 | 存在 |
|------|------|------|
| `ts` | UTC timestamp | 全部 |
| `skill` | Skill 名稱（從 YAML frontmatter `name:` 讀取） | 全部 |
| `event` | `started` / `completed` | 全部 |
| `branch` | Git branch | 全部 |
| `outcome` | `done` / `done_with_concerns` / `blocked` / `needs_context` | 僅 completed |
| `duration_s` | 從 start 到 complete 的秒數 | 僅 completed |
| `session` | `$$-$(date +%s)` — 辨識同一個 session | 全部 |

## Context Accumulation（跨 session 脈絡累積）

### 設計原則（來自 OpenSpace + edda 經驗）
1. **執行中不記錄** — 代理做正事時完全不管記錄，不分心
2. **Completion 時萃取** — 自然收尾動作裡做一步萃取（~5 秒，不影響體驗）
3. **啟動時讀取** — Phase 0 讀 domain-config.json，自然知道之前的脈絡
4. **Append-only log** — decision-log.jsonl 只追加不修改，歷史可追溯

### 新增 State Files

| File | 寫入時機 | 讀取時機 | 格式 |
|------|---------|---------|------|
| `domain-config.json` (擴展) | Completion 萃取 | Phase 0 | JSON snapshot |
| `decision-log.jsonl` (新增) | Completion 萃取 | 需要歷史時 | JSONL append-only |

### domain-config.json 擴展 Schema

```json
{
  "domain": "行銷創意生產",
  "created": "2026-03-25",
  "lifecycle_stages": ["策略", "發想", "規格", "生產", "驗證", "投放"],
  "skill_count": 31,
  "last_build": "2026-03-25T14:30:00Z",
  "last_check": null,
  "last_upgrade": null,

  "accumulated": {
    "expertise": [
      {"content": "審素材看構圖、品牌一致、CTA", "extracted_as": "scoring 3 dimensions", "confidence": 9, "source": "user-stated", "ts": "2026-03-25T14:00:00Z"}
    ],
    "corrections": [
      {"content": "gotcha 不對，要查字型大小", "skill": "/ad-check", "section": "gotchas", "confidence": 9, "source": "correction", "ts": "2026-03-25T15:00:00Z"}
    ],
    "preferences": [
      {"content": "STOP gates 太多", "applied_to": "simple Review skills", "confidence": 9, "source": "user-stated", "ts": "2026-03-25T16:00:00Z"}
    ],
    "benchmarks": [
      {"content": "CPM 超過 280 要警告", "skill": "/performance-review", "confidence": 9, "source": "user-stated", "ts": "2026-03-25T17:00:00Z"}
    ],
    "operational": [
      {"content": "這個領域的 review 不能用數字評分，用戶偏好 pass/fail", "confidence": 7, "source": "observed", "ts": "2026-03-26T10:00:00Z"}
    ]
  }
}
```

### decision-log.jsonl 格式

每行一筆，append-only：
```jsonl
{"ts":"2026-03-25T14:00:00Z","skill":"/domain-plan","type":"expertise","content":"審素材看構圖、品牌一致、CTA","extracted_as":"scoring 3 dimensions for /ad-check"}
{"ts":"2026-03-25T15:00:00Z","skill":"/skill-edit","type":"correction","content":"gotcha 不對，要查字型","extracted_as":"new gotcha for /ad-check"}
{"ts":"2026-03-25T16:00:00Z","skill":"/domain-upgrade","type":"preference","content":"STOP 太多","extracted_as":"reduce STOP frequency for simple Review skills"}
```

## Auto Mode State (auto-run-state.json)

自動模式的進度追蹤檔案，位於 `$_STATE_DIR/auto-run-state.json`。

```json
{
  "mode": "auto",
  "domain": "行銷",
  "domain_input": "用戶原始輸入（可能 1 句話或整份 spec path）",
  "quality_threshold": 18,
  "max_fix_rounds": 3,
  "current_state": "PLAN|BUILD|CHECK|FIX|DONE|DONE_WITH_CONCERNS",
  "round": 1,
  "started_at": "2026-03-26T10:00:00Z",
  "plan": {
    "status": "pending|done",
    "skill_count": null,
    "artifact": null
  },
  "build": {
    "status": "pending|done",
    "repo_path": null,
    "skills_generated": null
  },
  "check": {
    "status": "pending|done",
    "round": 0,
    "avg_score": null,
    "below_threshold": []
  },
  "fix": {
    "rounds_completed": 0,
    "total_fixes": 0,
    "last_avg_score": null
  }
}
```

---

## 批次佇列約定（Batch Queue Conventions）

### 1. queue.json schema — 通用批次任務佇列格式

```json
{
  "config": {
    "max_concurrent": 10,
    "poll_interval_seconds": 300,
    "retry_max": 3,
    "retry_backoff_base": 30
  },
  "tasks": [
    {
      "id": "task-001",
      "type": "text2video",
      "input": {},
      "status": "pending",
      "submitted_at": null,
      "completed_at": null,
      "attempt": 0,
      "error": null,
      "output": null
    }
  ]
}
```

欄位說明：
- `config.max_concurrent`：最大並行任務數
- `config.poll_interval_seconds`：輪詢間隔（秒）
- `config.retry_max`：最大重試次數
- `config.retry_backoff_base`：重試退避基數（秒）
- `tasks[].id`：唯一 ID
- `tasks[].type`：任務類型（由 skill 定義）
- `tasks[].input`：任務輸入（由 skill 定義）
- `tasks[].status`：pending / submitted / processing / success / failed / blocked
- `tasks[].output`：成功後的產出路徑或資料

### 2. batch-state.json schema — Runtime 追蹤

```json
{
  "started_at": "2026-04-09T...",
  "last_poll_at": "2026-04-09T...",
  "total_tasks": 69,
  "completed": 35,
  "failed": 34,
  "remaining": 0,
  "failure_rate": 0.49,
  "credits_spent": 5775
}
```

### 3. Poll-and-retry 通用演算法

```
while 有 pending 或 submitted:
  available = max_concurrent - count(submitted)
  submit(pending[:available])
  for each submitted:
    poll status
    if success → download output, mark success, release slot
    if failed → attempt++, if attempt < retry_max → reset to pending with backoff, else mark failed
    if blocked → mark blocked (不重試)
  sleep poll_interval_seconds
```

### 4. State Files 表格新增

| File | Written By | Read By | Purpose |
|------|-----------|---------|---------|
| `queue.json` | Production/Runtime Helper | batch-engine scripts | 批次任務佇列 |
| `batch-state.json` | batch-engine scripts | skills（進度報告）| 批次執行狀態 |
| `functional-test-log.jsonl` | 手動測試 / /domain-upgrade | /domain-upgrade, /skill-edit | 功能測試歷史 |
| `experiments.jsonl` | Production/Runtime Helper | /domain-upgrade | A/B 實驗歷史 |

### 5. Convention Rules

- 佇列檔案 per-task-type（不共用一個全域佇列）
- batch-state 為暫態（完成後可刪除，重要事件記入 decision-log.jsonl）
- skill 不同步輪詢 — 委派給 scripts/
