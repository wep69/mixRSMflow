#!/usr/bin/env python3
"""Static named-argument audit for mixRSMflow documentation and tests.

This is deliberately conservative. It compares named arguments in calls to exported
functions against source-level formals. It is not an R parser and never replaces
runtime validation.
"""
from pathlib import Path
import json, re
ROOT = Path(__file__).resolve().parents[1]

def balanced(text, start, op='(', cl=')'):
    depth=0; quote=None; esc=False
    for i in range(start,len(text)):
        c=text[i]
        if quote:
            if esc: esc=False
            elif c=='\\': esc=True
            elif c==quote: quote=None
            continue
        if c in "'\"": quote=c; continue
        if c==op: depth+=1
        elif c==cl:
            depth-=1
            if depth==0: return text[start+1:i], i+1
    return None, None

def split_top(text):
    out=[]; start=0; depth=0; quote=None; esc=False
    opens='([{'; closes=')]}'; pairs=dict(zip(opens,closes))
    for i,c in enumerate(text):
        if quote:
            if esc: esc=False
            elif c=='\\': esc=True
            elif c==quote: quote=None
            continue
        if c in "'\"": quote=c; continue
        if c in opens: depth+=1
        elif c in closes: depth-=1
        elif c==',' and depth==0:
            out.append(text[start:i]); start=i+1
    out.append(text[start:])
    return out

def source_formals():
    funcs={}
    for p in (ROOT/'R').glob('*.R'):
        text=p.read_text(encoding='utf-8')
        for m in re.finditer(r'(?m)^([A-Za-z][A-Za-z0-9._]*)\s*<-\s*function\s*\(', text):
            content,_=balanced(text,m.end()-1)
            if content is None: continue
            args=[]
            for token in split_top(content):
                token=token.strip()
                if not token: continue
                args.append(token.split('=',1)[0].strip())
            funcs[m.group(1)]={'args':set(args),'dots':'...' in args,'source':str(p.relative_to(ROOT))}
    return funcs

def exports():
    ns=(ROOT/'NAMESPACE').read_text(encoding='utf-8')
    return set(re.findall(r'^export\(([^)]+)\)',ns,re.M))

def main():
    funcs=source_formals(); ex=exports()
    sources=[ROOT/'README.md'] + sorted((ROOT/'R').glob('*.R')) + sorted((ROOT/'vignettes').glob('*.Rmd')) + sorted((ROOT/'tests').rglob('*.R')) + sorted((ROOT/'inst').rglob('*.R')) + sorted((ROOT/'data-raw').rglob('*.R'))
    issues=[]; checked_calls=0; checked_named=0
    for p in sources:
        text=p.read_text(encoding='utf-8')
        for name in sorted(ex):
            if name not in funcs: continue
            pattern=r'(?<![A-Za-z0-9._])'+re.escape(name)+r'\s*\('
            for m in re.finditer(pattern,text):
                content,_=balanced(text,m.end()-1)
                if content is None: continue
                checked_calls += 1
                spec=funcs[name]
                for token in split_top(content):
                    mm=re.match(r'\s*([A-Za-z][A-Za-z0-9._]*)\s*=',token)
                    if not mm: continue
                    checked_named += 1
                    arg=mm.group(1)
                    if arg not in spec['args'] and not spec['dots']:
                        issues.append({
                            'file':str(p.relative_to(ROOT)),
                            'line':text.count('\n',0,m.start())+1,
                            'function':name,
                            'unknown_named_argument':arg,
                            'source_formals':sorted(spec['args'])
                        })
    result={
        'status':'PASS' if not issues else 'FAIL',
        'checked_exported_calls':checked_calls,
        'checked_named_arguments':checked_named,
        'unknown_named_argument_issues':issues,
        'limitations':['This is a static heuristic, not an R parser or runtime test.','Calls assembled programmatically may not be inspected.']
    }
    (ROOT/'STATIC_API_AUDIT.json').write_text(json.dumps(result,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
    print(json.dumps(result,indent=2,ensure_ascii=False))
    raise SystemExit(0 if not issues else 1)

if __name__=='__main__': main()
