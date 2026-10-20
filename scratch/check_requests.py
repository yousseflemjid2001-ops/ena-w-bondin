import json, re

with open(r'C:\Users\lemji\.gemini\antigravity-ide\brain\7c14422d-0b09-4ad7-9380-6786a0981f56\.system_generated\logs\transcript_full.jsonl', 'r', encoding='utf-8') as f:
    for line in f:
        obj = json.loads(line)
        if obj.get('source') == 'USER_EXPLICIT':
            text = obj.get('content', '')
            m = re.search(r'<USER_REQUEST>(.*?)</USER_REQUEST>', text, re.DOTALL)
            req = m.group(1).strip() if m else text[:50]
            print(f"{obj.get('step_index')}: {req}")
