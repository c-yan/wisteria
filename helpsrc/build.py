#!/usr/bin/python2

from glob import glob
from os import makedirs
from shutil import copyfile
from os.path import isdir
import re

htmls = glob('*.phtml')

htmls.remove('template.phtml')
htmls.remove('menu.phtml')
htmls.remove('index.phtml')

with open('template.phtml') as f:
    template = f.read().decode('utf-8')

with open('menu.phtml') as f:
    menu = f.read().decode('utf-8')

if not isdir('_build/contents'):
    makedirs('_build/contents')
copyfile('help.css', '_build/contents/help.css')

for h in htmls:
    with open(h) as f:
        hs = f.read().decode('utf-8')
    t = hs.split('\n')
    title = t[0]
    content = '\n'.join(t[1:])

    result = template % (title, title, menu, content)

    with open('_build/contents/' + h.replace('.phtml', '.html'), 'wb') as f:
        f.write(result.encode('utf-8'))

template = template.replace('href="', 'href="contents/')
menu = re.sub('href="([^:"]+)"', r'href="contents/\1"', menu)

with open('index.phtml') as f:
    hs = f.read().decode('utf-8')
t = hs.split('\n')
title = t[0]
content = '\n'.join(t[1:])

result = template % (title, title, menu, content)

with open('_build/index.html', 'wb') as f:
    f.write(result.encode('utf-8'))
