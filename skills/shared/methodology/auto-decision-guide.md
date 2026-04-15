# 自動決策指南

> 用途：Auto Mode 下所有 skill 的決策依據。
> 語境：你正在自動模式下執行，STOP gates 不問用戶，由此指南的原則代替用戶判斷。

---

## 6 條 Decision Principles

| # | 原則 | 說明 | 適用場景 |
|---|------|------|---------|
| P1 | **保留用戶意圖** | 用戶說過的維度、權重、角色定義，永遠優先於 AI 推導的。讀 domain-config.json 的 accumulated context。 | scoring formula、role identity、gotchas |
| P2 | **覆蓋優先** | 選覆蓋更多生命週期階段的方案。缺口比冗餘更危險。 | skill map 規劃、缺口填補 |
| P3 | **獨立性** | 如果兩個選項都可以，選讓 skill 更獨立的。依賴越少越好。 | skill merge/split 決策 |
| P4 | **品質對等** | 輸入多少，產出多少。一句話不假裝 Production，完整 spec 不降級 Draft。 | skill 生成深度 |
| P5 | **最小改動** | 修 skill 時只改有問題的部分。不重寫、不重構、不加新功能。 | fix loop、skill-edit |
| P6 | **向前推進** | 有疑問但不阻塞時，選較安全的預設值繼續。不停在非關鍵問題上。 | 自動模式全程 |

### 衝突解決（per phase）

- **Plan 階段：** P2（覆蓋）+ P3（獨立性）主導
- **Build 階段：** P4（品質對等）+ P1（用戶意圖）主導
- **Check 階段：** 無自動決策（評判者只看 rubric，不受原則影響）
- **Fix 階段：** P5（最小改動）+ P1（用戶意圖）主導

---

## Decision Classification

每個 STOP gate 遇到的決策分三類：

### Mechanical — 有明確正確答案

靜默自動決策，記入 audit log。不呈現給用戶。

範例：
- YAML 缺 `origin:` → 加上 `origin: prismstack-generated`
- 沒有 completion protocol → 加 STATUS: DONE section
- 沒有 artifact discovery → 加 Phase 0 discovery bash block
- description 缺 anti-trigger → 加 "Do NOT use when:"
- SKILL.md > 250 行但沒有 references/ → 把長 section 拆到 references/
- 沒有 STOP gates → 在每個 phase 結尾加 STOP

### Taste — 合理的人可能有不同選擇

自動決策（用 6 原則選較好的），但標記 `"surfaced": true`，存入最終審批門讓用戶確認。

三種自然來源：
1. **Close approaches** — 前兩名都可行，各有不同 tradeoff
2. **Borderline scope** — 獨立性測試剛好 2/3，合併或保持獨立都說得通
3. **Weight ambiguity** — scoring formula 的權重分配，用戶沒明確說過

範例：
- 兩個 skill 該 merge 還是保持獨立（獨立性測試 2/3）
- scoring formula 的權重分配（用戶沒說過偏好）
- 某個生命週期階段要不要拆成兩個 skill

### User Required — 涉及用戶的領域知識

**永不自動決策**，即使在 auto mode 也不行。處理方式：

1. 讀 `domain-config.json` accumulated context → 用 P1（保留用戶意圖）
2. 如果有相關 context → 用那個值作為預設，標記 `"deferred": true`
3. 如果沒有 context → 用最保守的預設值（不改變用戶同意過的東西），標記 `"deferred": true`
4. 最終審批門列出所有 deferred decisions 讓用戶確認

範例：
- 用戶說「CTA 最重要」但 AI 推導出品牌一致性權重更高 → 必須問
- 增減 skill（改變用戶同意過的 skill map）
- 改變角色定義

---

## Audit Trail

每個自動決策記入 `$_STATE_DIR/auto-decisions.jsonl`（append-only）：

```json
{"ts":"2026-04-15T10:05:00Z","phase":"build","skill":"ad-check","type":"mechanical","decision":"added completion protocol","principle":"P6"}
{"ts":"2026-04-15T10:12:00Z","phase":"plan","skill":"market-research","type":"taste","decision":"kept independent (2/3 tests passed)","principle":"P3","surfaced":true}
{"ts":"2026-04-15T10:20:00Z","phase":"build","skill":"brand-voice","type":"user_required","decision":"kept user weight: CTA 30%","principle":"P1","deferred":true}
```

| 欄位 | 說明 |
|------|------|
| `ts` | UTC timestamp |
| `phase` | `plan` / `build` / `fix` |
| `skill` | 受影響的 skill 名稱 |
| `type` | `mechanical` / `taste` / `user_required` |
| `decision` | 一句話描述做了什麼決定 |
| `principle` | 用了哪條原則（P1-P6） |
| `surfaced` | 僅 taste：是否呈現到最終審批門 |
| `deferred` | 僅 user_required：是否延遲到最終審批門 |

---

## 最終審批門

Auto mode 結束前（交付階段），列出所有 `"surfaced": true` 和 `"deferred": true` 的決策：

```
自動搭建完成前，以下決策需要你確認：

Taste Decisions（自動選了，但你可能有不同看法）：
1. /market-research — 保持獨立（獨立性測試 2/3）。理由：P3 獨立性。
   → A) 同意  B) 改成合併到 /campaign-strategy

User Required（用了預設值，需要你確認）：
1. /brand-voice — 保持用戶權重 CTA 30%。理由：P1 保留用戶意圖。
   → A) 確認  B) 改成 ...

A) 全部確認  B) 逐個修改  C) 全部接受，之後再調
```

---

## Spawned Session 行為規則

如果 preamble 偵測到 `SPAWNED` 是 `"true"`，你正在自動模式下被 orchestrator 執行。調整行為：

### 1. STOP gates
不呼叫 AskUserQuestion。用上方的 6 原則 + 3 分類自動決策：
- Mechanical → 靜默決策
- Taste → 自動決策 + 記入 auto-decisions.jsonl（`"surfaced": true`）
- User Required → 不自動。記入 auto-decisions.jsonl（`"deferred": true`）。用 P1 + 最安全預設值繼續。

### 2. Completion Protocol
正常執行（Operational Reflection + 萃取 + timeline complete event 寫入）。
但不印 welcome-back、不印 predictive suggestion（沒有用戶在看）。

### 3. 錯誤處理
不問用戶。能自修的自修（例：validate-repo.sh 失敗 → 讀錯誤訊息 → 修），不能的標記 BLOCKED 讓 orchestrator 處理。

### 4. 互動風格
精簡。不解釋決策理由（記在 audit log 就好），只輸出 STATUS + 關鍵數字 + artifact 路徑。
