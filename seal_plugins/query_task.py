import json
from subprocess import Popen, PIPE
import sys
import dateutil.parser

def call_taskwarrior(cmd):
    'call taskwarrior, returning output and error'
    tw = Popen(['/usr/local/bin/task'] + cmd, stdout=PIPE, stderr=PIPE)
    return tw.communicate()[0].decode('utf-8')

if __name__ == '__main__':
    cmd, *args = sys.argv[1:]
    if cmd == 'list':
        if len(args) == 0:
            tasks = json.loads(call_taskwarrior(['export'] + ['status:pending']))
        else:
            tasks = json.loads(call_taskwarrior(['export'] + args))

        items = []
        for t in tasks:
            i = {}
            subtitle = ''
            if 'due' in t:
                due = dateutil.parser.parse(t['due']).strftime('%Y-%m-%d')
                subtitle += 'Due:%s ' % (due)
            if 'project' in t:
                subtitle += 'Project:%s ' % (t['project'])
            if 'tags' in t:
                subtitle += 'Tags:%s ' % (','.join(t['tags']))
            if 'status' in t:
                subtitle += 'Status:%s ' % (t['status'])
            i['subText'] = subtitle
            i['text'] = str(t['id']) + '-' + t['description'].replace('\n', '~')
            i['plugin'] = 'seal_task'
            i['type'] = 'list'
            items.append(i)
        print(json.dumps(items))
    else:
        cmd = ' '.join(['task'] + sys.argv[1:])
        print(json.dumps([{
            'text': cmd,
            'type': 'cmd',
            'arg': '/usr/local/bin/' + cmd,
            'plugin': 'seal_task',
        }]))

