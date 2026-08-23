#!/usr/bin/env python3
from pathlib import Path
import json,re
ROOT=Path(__file__).resolve().parents[1]

def bal(text,start):
    dep=0; q=None; esc=False
    for i in range(start,len(text)):
        c=text[i]
        if q:
            if esc: esc=False
            elif c=='\\': esc=True
            elif c==q: q=None
            continue
        if c in "'\"": q=c; continue
        if c=='(': dep+=1
        elif c==')':
            dep-=1
            if dep==0:return text[start+1:i]
    return None

def split(s):
    out=[]; st=0; dep=0; q=None; esc=False
    for i,c in enumerate(s):
        if q:
            if esc:esc=False
            elif c=='\\':esc=True
            elif c==q:q=None
            continue
        if c in "'\"":q=c;continue
        if c in '([{':dep+=1
        elif c in ')]}':dep-=1
        elif c==',' and dep==0:out.append(s[st:i]);st=i+1
    out.append(s[st:]);return out

def argnames(s):
    out=[]
    for z in split(s):
        z=z.strip()
        if not z:continue
        if z=='...':out.append('...');continue
        out.append(z.split('=',1)[0].strip())
    return out

ns=(ROOT/'NAMESPACE').read_text(); exports=sorted(re.findall(r'^export\(([^)]+)\)',ns,re.M))
source={}
for p in (ROOT/'R').glob('*.R'):
    t=p.read_text()
    for name in exports:
        m=re.search(r'(?m)^'+re.escape(name)+r'\s*<-\s*function\s*\(',t)
        if m:
            source[name]=argnames(bal(t,m.end()-1));
issues=[]
for name in exports:
    p=ROOT/'man'/f'{name}.Rd'
    if not p.exists():
        issues.append({'function':name,'issue':'missing Rd'});continue
    t=p.read_text(); um=re.search(r'\\usage\{',t)
    if not um:
        issues.append({'function':name,'issue':'missing usage'});continue
    # extract until matching usage brace, then find name(
    dep=1;i=um.end();q=None;esc=False
    while i<len(t) and dep:
        c=t[i]
        if c=='\\': i+=2; continue
        if c=='{': dep+=1
        elif c=='}':dep-=1
        i+=1
    usage=t[um.end():i-1]
    cm=re.search(re.escape(name)+r'\s*\(',usage)
    if not cm:
        issues.append({'function':name,'issue':'function absent from usage'});continue
    rdargs=argnames(bal(usage,cm.end()-1))
    if source.get(name)!=rdargs:
        issues.append({'function':name,'source_formals':source.get(name),'rd_usage_formals':rdargs})
res={'status':'PASS' if not issues else 'FAIL','exports_checked':len(exports),'issues':issues,'limitations':['Static textual comparison; roxygen2 regeneration and R parsing remain part of the runtime gate.']}
(ROOT/'STATIC_RD_AUDIT.json').write_text(json.dumps(res,indent=2)+'\n')
print(json.dumps(res,indent=2))
raise SystemExit(0 if not issues else 1)
