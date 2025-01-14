#!/usr/bin/python

from glob import glob
from os import makedirs
from shutil import copyfile
from os.path import isdir
import re

htmls = glob('*.phtml')

htmls.remove('template.phtml')
htmls.remove('menu.phtml')
htmls.remove('index.phtml')

with open('template.phtml', encoding='utf-8') as f:
    template = f.read()

with open('menu.phtml', encoding='utf-8') as f:
    menu = f.read()

if not isdir('_build/contents'):
    makedirs('_build/contents')
copyfile('help.css', '_build/contents/help.css')

for h in htmls:
    with open(h, encoding='utf-8') as f:
        hs = f.read()
    t = hs.split('\n')
    title = t[0]
    content = '\n'.join(t[1:])

    result = template % (title, title, menu, content)

    with open('_build/contents/' + h.replace('.phtml', '.html'), 'w', encoding='utf-8') as f:
        f.write(result)

template = template.replace('href="', 'href="contents/')
menu = re.sub('href="([^:"]+)"', r'href="contents/\1"', menu)

with open('index.phtml', encoding='utf-8') as f:
    hs = f.read()
t = hs.split('\n')
title = t[0]
content = '\n'.join(t[1:])

result = template % (title, title, menu, content)

with open('_build/index.html', 'w', encoding='utf-8') as f:
    f.write(result)
