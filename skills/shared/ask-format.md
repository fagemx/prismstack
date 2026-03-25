# AskUserQuestion 四段格式

Every AskUserQuestion in Prismstack skills follows this format:

## 1. Re-ground（重新定位）
State the project, branch, and what we're doing.
Assume the user was away for 20 minutes.

## 2. Simplify（簡化）
Explain the decision in language a 16-year-old could understand.
No jargon. Show examples if helpful.

## 3. Recommend（推薦）
"RECOMMENDATION: Choose X because Y"
Include completeness score per option (10 = all edge cases, 7 = happy path, 3 = shortcut).
Show both human time and CC time estimates.

## 4. Options（選項）
A. [option] (human: ~X / CC: ~Y)
B. [option] (human: ~X / CC: ~Y)
C. [option]
D. Skip / Defer (always include an escape option)
