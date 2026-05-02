# Case Import Guide

> 用途：外部來源（skill repo、SDK、framework）附帶大量 examples / cases / fixtures /
> preset templates 時，用來判斷怎麼處理。
>
> 不是「全收 vs 全丟」的二元選擇，是按數量分級的處理規則。

---

## 為什麼需要這個

`/source-convert` 移植 multi-skill stack 時常遇到：
- 知識萃取工具帶 80+ YAML preset templates
- ECC skill repo 帶 20+ example markdown
- API SDK 帶 50+ code samples

沒有規則 → 要嘛全部 copy（資料量爆、目錄混亂）要嘛全部丟（失去領域 context）。
這份 guide 給出按數量分級的處理規則。

---

## 數量分級規則

| 數量 | 處理方式 | 落點 |
|------|---------|------|
| **< 10** | 全部複製 | 目標 skill 的 `cases/` |
| **10-30** | 擇優選 1-3 個代表 + 連結原始來源 | `cases/` + `references/external-cases.md` |
| **> 30** | 擇優選 5 個典型 + 跨 repo 引用 + 索引檔 | `cases/` + `references/case-index.md` |

「代表」/「典型」的判斷標準見下方「擇優準則」。

---

## 落點檔案結構

### 規則 A：< 10 個（全收）

```
skills/{skill-name}/
└── cases/
    ├── {case-1}.{ext}
    ├── {case-2}.{ext}
    └── ...
```

每個 case 加 metadata header（不破壞檔案格式）：

```yaml
# Source: {original-repo}/{path}
# Imported: 2026-05-02
# Why: representative of {pattern}
```

### 規則 B：10-30 個（擇優 + 連結）

```
skills/{skill-name}/
├── cases/
│   ├── {case-1}.{ext}     # 選 1-3 個
│   ├── {case-2}.{ext}
│   └── {case-3}.{ext}
└── references/
    └── external-cases.md   # 列出全部來源
```

`external-cases.md` 格式：

```markdown
# External Cases (Not Imported)

來源：{repo URL or path}
總數：{N} 個

## Imported (in cases/)
- {case-1}.yaml — {pattern X}
- {case-2}.yaml — {pattern Y}

## Not Imported (reference only)
| Name | Pattern | Original Path |
|------|---------|---------------|
| earnings-summary | record/finance | finance/earnings.yaml |
| ... |

需要時去原 repo 拿。不直接 copy 的原因：避免 repo 重量、避免 stale。
```

### 規則 C：> 30 個（典型 + 跨引）

```
skills/{skill-name}/
├── cases/
│   ├── {typical-1}.{ext}   # 選 5 個
│   ├── {typical-2}.{ext}
│   ├── {typical-3}.{ext}
│   ├── {typical-4}.{ext}
│   └── {typical-5}.{ext}
└── references/
    └── case-index.md        # 分類索引 + 跨 repo 引用
```

`case-index.md` 格式：

```markdown
# Case Index

來源：{repo URL or path}
總數：{N} 個

## 分類索引

### By Domain
- finance（{n} 個）：{repo}/finance/
- legal（{n} 個）：{repo}/legal/
- ...

### By Pattern
- record type：{n} 個
- graph type：{n} 個
- ...

## Imported Typical (in cases/)
- {typical-1}.yaml — finance/record，最常用
- {typical-2}.yaml — legal/graph，複雜度最高
- ...

## How to Find Others

```bash
# 在原 repo 用 grep 找特定 pattern
grep -r "type: graph" {repo}/templates/
```
```

---

## 擇優準則

選哪幾個當代表 / 典型，按以下優先序：

1. **覆蓋面**：不同 pattern / type / domain 各選一個
2. **複雜度梯度**：最簡單 + 中等 + 最複雜，各一個
3. **使用頻率**：原來源標註「最常用」/「推薦」的優先
4. **教學價值**：能凸顯這個 skill 核心判斷邏輯的優先
5. **獨立性**：不依賴外部資源、可獨立運作的優先

❌ **不該選**：
- 邊緣案例（除非要當 gotcha）
- 半成品 / 被棄用的範例
- 跟其他 case 高度重複的

---

## 跨 repo 引用的注意事項

當外部 repo 是公開且穩定（GitHub、官方 docs）：
- 可在 `references/case-index.md` 中放 URL
- 標註 commit SHA 或 release tag（避免 stale）

當外部 repo 是私人 / 不穩定 / 本地路徑：
- **必須 copy 進來**（不能跨引用）
- 即使超過 30 個也要 copy（用規則 A 的擴充版）
- 或要求用戶決定哪些必須留

---

## metadata header 標準

每個被 import 的 case，檔案頂部加 metadata（語法依檔案類型調整）：

| 檔案類型 | metadata 語法 |
|---------|--------------|
| YAML | `# Source: ...` 註解 |
| Markdown | YAML frontmatter `Source: ...` |
| JSON | 不加 metadata，改在 `case-index.md` 統一記 |
| Code (`.py`/`.js`/...) | 檔頭註解 `# Source: ...` |

**必填欄位：**
- `Source: {original-repo-or-path}` — 從哪來
- `Imported: {YYYY-MM-DD}` — 何時 import
- `Why: {one-line reason}` — 為什麼選這個

---

## Gotchas

| 陷阱 | 後果 | 修正 |
|------|------|------|
| 30+ 個全部 copy | 目錄混亂、git diff 爆量、難維護 | 用規則 C，擇 5 個典型 |
| 只 copy 不加 metadata | 半年後不知道哪來、為何選 | 強制 metadata header |
| 跨 repo 引用私人 repo | 別人 clone 後 reference 失效 | 私人 repo 必須 copy |
| 選代表時偏向自己熟悉的 | 失去 case 的覆蓋面 | 強制按「擇優準則」5 條走 |
| Cases 和 references 混用 | 一個放執行範例一個放說明，混了找不到 | `cases/` = 可執行範例｜`references/` = 說明文件 |

---

## 引用此 guide 的 skill

- `/source-convert`（Level 6 Stack Import 處理 cases）
- `/domain-plan` brownfield path（forcing question 3：cases 數量）
- `/skill-gen`（新建 skill 時若帶 examples）
