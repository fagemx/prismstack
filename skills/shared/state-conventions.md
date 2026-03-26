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
      {"content": "審素材看構圖、品牌一致、CTA", "extracted_as": "scoring 3 dimensions", "session": "2026-03-25"}
    ],
    "corrections": [
      {"content": "gotcha 不對，要查字型大小", "skill": "/ad-check", "section": "gotchas", "session": "2026-03-25"}
    ],
    "preferences": [
      {"content": "STOP gates 太多", "applied_to": "simple Review skills", "session": "2026-03-25"}
    ],
    "benchmarks": [
      {"content": "CPM 超過 280 要警告", "skill": "/performance-review", "session": "2026-03-25"}
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
