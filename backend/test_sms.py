import asyncio
import httpx

async def test_devsms():
    url = "https://devsms.uz/api/send_sms.php"
    token = "6dd20a696a6e7486932fc841ceaf6a5216419f647fd1fa294b28abcf0aeeb912"
    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
    
    # Try with "text"
    payload1 = {"phone": "998901234567", "text": "Milliy Metr ilovasiga kirish uchun tasdiqlash kodingiz: 1234. Kodni hech kimga bermang. Milliy Metr xodimlari ham ushbu kodni so‘ramaydi."}
    
    # Try with "message"
    payload2 = {"phone": "998901234567", "message": "Milliy Metr ilovasiga kirish uchun tasdiqlash kodingiz: 1234. Kodni hech kimga bermang. Milliy Metr xodimlari ham ushbu kodni so‘ramaydi."}
    
    async with httpx.AsyncClient() as client:
        r1 = await client.post(url, headers=headers, json=payload1)
        print("Payload with 'text':", r1.status_code, r1.text)
        
        r2 = await client.post(url, headers=headers, json=payload2)
        print("Payload with 'message':", r2.status_code, r2.text)

if __name__ == "__main__":
    asyncio.run(test_devsms())
