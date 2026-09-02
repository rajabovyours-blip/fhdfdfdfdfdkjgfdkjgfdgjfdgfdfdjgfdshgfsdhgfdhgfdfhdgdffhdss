import httpx
import asyncio
import sys

sys.stdout.reconfigure(encoding='utf-8')

async def test():
    try:
        async with httpx.AsyncClient() as client:
            r = await client.post(
                'https://devsms.uz/api/send_sms.php',
                headers={'Authorization': 'Bearer 6dd20a696a6e7486932fc841ceaf6a5216419f647fd1fa294b28abcf0aeeb912'},
                json={'phone': '998901234567', 'message': 'Test'}
            )
            print("Status:", r.status_code)
            print("Body:", r.text)
    except Exception as e:
        print(f"Error: {e}")

asyncio.run(test())
