import os
import json
import sys

def load_all_bookmarks(data):
    result = []
    visit_stack = []
    visit_stack.append(data['roots']['bookmark_bar'])
    visit_stack.append(data['roots']['other'])
    while(len(visit_stack) > 0):
        top = visit_stack.pop()
        if 'children' in top:
            for child in top['children']:
                if 'children' in child:
                    visit_stack.append(child)
                else:
                    result.append({
                        'text': child['name'],
                        'subText': child['url'],
                        'arg': child['url'],
                        'plugin': 'seal_chrome_bookmarks',
                    })
    return result



def run(query):
    bookmark_path = os.path.join(os.getenv("HOME"), 'Library', 'Application Support', 'Google', 'Chrome', 'Default', 'Bookmarks')
    bookmark_data = None
    with open(bookmark_path, 'r') as f:
        bookmark_data = json.loads(f.read())
    all_bookmarks = load_all_bookmarks(bookmark_data)
    if query is not None:
        print(json.dumps([b for b in all_bookmarks if query.lower() in b['text'].lower()]))
    else:
        print(json.dumps([b for b in all_bookmarks]))

if __name__ == '__main__':
    if len(sys.argv) >= 2 and len(sys.argv[1]) > 0:
        run(sys.argv[1])
    else:
        run(None)
