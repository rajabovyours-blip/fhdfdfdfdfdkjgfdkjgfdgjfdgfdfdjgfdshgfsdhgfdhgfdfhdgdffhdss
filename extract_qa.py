import re

with open('phase4.txt', 'r', encoding='utf-8') as f:
    text = f.read()

# Extract from KENG QAMROVLI TAHLILIY HISOBOT to the end of the text
match = re.search(r'KENG QAMROVLI TAHLILIY HISOBOT.*', text, re.DOTALL)
if match:
    with open('qa_report.txt', 'w', encoding='utf-8') as out:
        out.write(match.group(0))
        print("Extracted QA report")
else:
    print("QA report not found")
