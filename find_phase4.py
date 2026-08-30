import json
with open(r'C:\Users\rajab\.gemini\antigravity-ide\brain\0c426c39-979d-4fcb-a9df-a3e0b5162443\.system_generated\logs\transcript.jsonl', 'r', encoding='utf-8') as f:
    for line in f:
        data = json.loads(line)
        if data.get('type') == 'USER_INPUT' and 'Phase 4' in data.get('content', ''):
            print(data['content'])
