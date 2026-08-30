import re
text = open('qa_report_full.txt', encoding='utf-8').read()
sections = re.split(r'\n(?=\d+\.\s)', text)
with open('extracted_qa.txt', 'w', encoding='utf-8') as f:
    for s in sections:
        if s.startswith('4. ') or s.startswith('6. ') or s.startswith('7. ') or s.startswith('14. ') or s.startswith('16. ') or s.startswith('8. '):
            f.write(s + '\n' + '-'*50 + '\n')
