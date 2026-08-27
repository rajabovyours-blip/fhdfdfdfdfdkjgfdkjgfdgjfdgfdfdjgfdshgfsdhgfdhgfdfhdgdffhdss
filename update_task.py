import re

task_file = r'C:\Users\rajab\.gemini\antigravity-ide\brain\788c641f-09e4-472d-84a5-b6bcac760595\task.md'
with open(task_file, 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace('- [ ] Verification & Build (lutter analyze)', '- [x] Verification & Build (lutter analyze)')

with open(task_file, 'w', encoding='utf-8') as f:
    f.write(content)
