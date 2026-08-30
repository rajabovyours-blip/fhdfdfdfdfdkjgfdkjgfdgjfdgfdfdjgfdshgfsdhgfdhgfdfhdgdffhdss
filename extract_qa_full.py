import json
import re

with open(r'C:\Users\rajab\.gemini\antigravity-ide\brain\0c426c39-979d-4fcb-a9df-a3e0b5162443\.system_generated\logs\transcript_full.jsonl', 'r', encoding='utf-8') as f:
    for line in f:
        data = json.loads(line)
        if data.get('type') == 'USER_INPUT' and 'KENG QAMROVLI TAHLILIY HISOBOT' in data.get('content', ''):
            with open('qa_report_full.txt', 'w', encoding='utf-8') as out:
                out.write(data['content'])
            print("Extracted full QA report to qa_report_full.txt")
            break
