import requests
import json

try:
    res = requests.get('http://127.0.0.1:8000/api/v1/products', params={'min_price': 0, 'max_price': 1970000})
    with open('test_products_output.json', 'w', encoding='utf-8') as f:
        f.write(res.text)
except Exception as e:
    print(e)
