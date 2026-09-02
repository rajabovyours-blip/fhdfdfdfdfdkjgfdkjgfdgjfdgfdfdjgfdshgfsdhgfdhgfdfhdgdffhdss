import asyncio
import httpx

async def test_devsms():
    url = "https://devsms.uz/api/send_sms.php"
    token = "6dd20a696a6e7486932fc841ceaf6a5216419f647fd1fa294b28abcf0aeeb912"
    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
    
    payload = {"phone": "998901234567", "message": "hello world unapproved text 123"}
    
    async with httpx.AsyncClient() as client:
        r = await client.post(url, headers=headers, json=payload)
        print("Response code:", r.status_code)
        try:
            print("Response json:", r.json())
        except Exception as e:
            print("Exception:", e)

if __name__ == "__main__":
    asyncio.run(test_devsms())
