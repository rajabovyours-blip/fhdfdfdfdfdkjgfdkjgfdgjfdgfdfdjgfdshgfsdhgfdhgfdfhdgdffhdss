import re

CYRILLIC_TO_LATIN = {
    'а': 'a', 'б': 'b', 'в': 'v', 'г': 'g', 'д': 'd', 'е': 'e', 'ё': 'yo', 'ж': 'j', 'з': 'z',
    'и': 'i', 'й': 'y', 'к': 'k', 'л': 'l', 'м': 'm', 'н': 'n', 'о': 'o', 'п': 'p', 'р': 'r',
    'с': 's', 'т': 't', 'у': 'u', 'ф': 'f', 'х': 'x', 'ц': 'ts', 'ч': 'ch', 'ш': 'sh', 'щ': 'shch',
    'ъ': '', 'ы': 'y', 'ь': '', 'э': 'e', 'ю': 'yu', 'я': 'ya',
    'қ': 'q', 'ғ': 'g\'', 'ҳ': 'h', 'ў': 'o\'',
}

# General mapping of keywords to target category-like intents or broad SQL search terms
INTENT_MAP = {
    # Building materials
    'shpaklyovka': ['shpaklyovka', 'shpatlevka', 'dry mixture', 'quruq aralashma', 'smes'],
    'sement': ['cement', 'sement', 'tsement'],
    'kley': ['yelim', 'glue', 'kley'],
    'gipsokarton': ['gips', 'karton', 'drywall'],
    
    # Metal
    'armatura': ['temir', 'armatura', 'metal', 'steel', 'metall'],
    'truba': ['quvur', 'pipe', 'truba', 'tube'],
    'shurup': ['vint', 'screw', 'samorez', 'mih', 'gvozd'],
    
    # Finish & Decor
    'oboy': ['gulqog\'oz', 'oboy', 'wallpaper', 'oboi'],
    'kraska': ['bo\'yoq', 'paint', 'kraska'],
    'laminat': ['pol', 'laminat', 'tarkett'],
    'kafel': ['plitka', 'kafel', 'keramika', 'tile'],
    
    # Electrical
    'rozetka': ['tok', 'rozetka', 'elektrik', 'viklyuchatel'],
    'kabel': ['sim', 'kabel', 'wire', 'provod'],
    
    # Tools
    'drel': ['perforator', 'drel', 'matkap'],
    'bolgarka': ['ushm', 'bolgarka'],
    
    # Misc user terms
    'telefon': ['smartfon', 'telefon', 'aloqa'], # Even though this is construction, user mentioned it
}

def transliterate(text: str) -> str:
    """Translates cyrillic characters to latin"""
    if not text:
        return text
    text = text.lower()
    res = []
    for char in text:
        res.append(CYRILLIC_TO_LATIN.get(char, char))
    return "".join(res)

def normalize_search_term(term: str) -> str:
    """Normalizes the search term by transliterating and removing special characters."""
    term = transliterate(term)
    # Remove apostrophes and quotes
    term = term.replace("'", "").replace('"', "").replace("`", "")
    # Remove extra spaces
    term = re.sub(r'\s+', ' ', term).strip()
    return term

def get_intent_keywords(normalized_term: str) -> list[str]:
    """Returns a list of keywords based on intent mapping, or just the normalized term if no match."""
    keywords = [normalized_term]
    
    # Simple fuzzy-like check (if search term is in any of the intent keys or values)
    # Allows partial matches for robustness e.g. "shpaklefka" (mispelled) might match if we used Levenshtein,
    # but for simplicity we match substrings if they are long enough (>=4 chars) or exact match
    
    for intent, synonyms in INTENT_MAP.items():
        all_terms = [intent] + synonyms
        matched = False
        for t in all_terms:
            # Exact match or substring if term is significant
            if normalized_term == t or (len(normalized_term) >= 4 and normalized_term in t) or (len(t) >= 4 and t in normalized_term):
                matched = True
                break
                
        if matched:
            keywords.extend(all_terms)
            
    # Remove duplicates and empty
    return list(set([k for k in keywords if k]))
