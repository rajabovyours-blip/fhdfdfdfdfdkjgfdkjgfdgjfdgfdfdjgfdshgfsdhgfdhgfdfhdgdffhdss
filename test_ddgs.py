from duckduckgo_search import DDGS

try:
    results = DDGS().images("water pump isolated white background", max_results=1)
    if results:
        print(f"Success: {results[0]['image']}")
    else:
        print("No results")
except Exception as e:
    print(f"Error: {e}")
