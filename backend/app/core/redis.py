class FakeRedis:
    def __init__(self):
        self.data = {}
    async def ping(self):
        return True
    async def get(self, key):
        return self.data.get(key)
    async def set(self, key, value, ex=None):
        self.data[key] = value
    async def delete(self, key):
        if key in self.data:
            del self.data[key]
    async def aclose(self):
        pass

redis_client = FakeRedis()

async def get_redis():
    return redis_client
