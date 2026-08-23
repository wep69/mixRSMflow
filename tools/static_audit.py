#!/usr/bin/env python3
"""Offline static audit for the mixRSMflow source snapshot.

This does not substitute for an R parser, testthat, vignette execution, or
R CMD check. It checks package-level structural invariants without network
access or external commands.
"""
from __future__ import annotations
from pathlib import Path
import json, re, sys

ROOT = Path(__file__).resolve().parents[1]


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def strip_r_strings_comments(text: str) -> str:
    out=[]; i=0; n=len(text); quote=None; esc=False
    while i<n:
        c=text[i]
        if quote:
            if esc:
                esc=False; out.append(' ')
            elif c=='\\':
                esc=True; out.append(' ')
            elif c==quote:
                quote=None; out.append(' ')
            else:
                out.append('\n' if c=='\n' else ' ')
            i+=1; continue
        if c in ('"', "'"):
            quote=c; out.append(' '); i+=1; continue
        if c=='#':
            while i<n and text[i]!='\n': out.append(' '); i+=1
            continue
        out.append(c); i+=1
    return ''.join(out)


def balanced(text: str):
    clean=strip_r_strings_comments(text)
    pairs={')':'(',']':'[','}':'{'}; stack=[]
    for pos,c in enumerate(clean):
        if c in '([{': stack.append((c,pos))
        elif c in ')]}':
            if not stack or stack[-1][0]!=pairs[c]: return False, f"mismatch at {pos}: {c}"
            stack.pop()
    if stack: return False, f"unclosed {stack[-1][0]} at {stack[-1][1]}"
    return True, ""

# DESCRIPTION parse (simple DCF continuation handling)
desc_lines=read(ROOT/'DESCRIPTION').splitlines()
desc={}; key=None
for line in desc_lines:
    if line.startswith((' ', '\t')) and key:
        desc[key] += ' ' + line.strip()
    elif ':' in line:
        key,val=line.split(':',1); key=key.strip(); desc[key]=val.strip()
required_desc={'Package','Type','Title','Version','Authors@R','Description','License'}
missing_desc=sorted(required_desc-set(desc))

def dep_names(field):
    raw=desc.get(field,'')
    return {re.sub(r'\s*\(.*?\)\s*','',x).strip() for x in raw.split(',') if x.strip()}
deps=dep_names('Imports')|dep_names('Suggests')|dep_names('Depends')|{'base'}

# NAMESPACE
ns=read(ROOT/'NAMESPACE')
exports=set(re.findall(r'^export\(([^)]+)\)',ns,re.M))
s3=set(tuple(x) for x in re.findall(r'^S3method\(([^,]+),([^)]+)\)',ns,re.M))

# R definitions and namespace calls
defs=set(); ns_calls=set(); balance_fail=[]
for f in sorted((ROOT/'R').glob('*.R')):
    t=read(f)
    ok,msg=balanced(t)
    if not ok: balance_fail.append(f"{f.name}: {msg}")
    clean=strip_r_strings_comments(t)
    defs.update(re.findall(r'(?m)^\s*([A-Za-z.][A-Za-z0-9._]*)\s*<-\s*function\s*\(',clean))
    ns_calls.update(re.findall(r'\b([A-Za-z][A-Za-z0-9.]*):::{0,1}[A-Za-z.][A-Za-z0-9._]*',t))

missing_defs=sorted(exports-defs)
missing_s3_defs=sorted(f"{g}.{cl}" for g,cl in s3 if f"{g}.{cl}" not in defs)

# .Rd aliases
aliases=set()
for f in (ROOT/'man').glob('*.Rd'):
    aliases.update(re.findall(r'\\alias\{([^}]+)\}',read(f)))
missing_aliases=sorted((exports|{f"{g}.{cl}" for g,cl in s3})-aliases)

# Namespace dependency declarations
base_pkgs={'base','compiler','datasets','methods','parallel','splines','stats4','tcltk'}
undeclared=sorted(ns_calls-deps-base_pkgs)

# Vignette/test counts and basic files
vignettes=sorted((ROOT/'vignettes').glob('*.Rmd'))
tests=sorted((ROOT/'tests/testthat').glob('*.R'))
required_files=['DESCRIPTION','NAMESPACE','README.md','NEWS.md','LICENSE','CITATION.cff','_pkgdown.yml']
missing_files=[x for x in required_files if not (ROOT/x).exists()]

# Known safety/integrity guards
scan_roots=[ROOT/'R',ROOT/'data-raw',ROOT/'inst'/'extdata',ROOT/'vignettes']
scan_files=[]
for sr in scan_roots:
    if sr.exists(): scan_files.extend(f for f in sr.rglob('*') if f.is_file())
scan_files.extend([ROOT/'README.md'])
all_text='\n'.join(read(f) for f in scan_files if f.suffix.lower() in {'.r','.md','.rmd','.csv'} )
placeholder_email='REPLACE_WITH_MAINTAINER_EMAIL@example.invalid' in read(ROOT/'DESCRIPTION')
cornell_raw_markers=['Fruit Punch General Acceptance Ratings','Table 10.1. Fruit Punch','Watermelon x1 Pineapple']
textbook_data_embedded=[m for m in cornell_raw_markers if m in all_text]

report={
    'status':'PASS' if not any([missing_desc,balance_fail,missing_defs,missing_s3_defs,missing_aliases,undeclared,missing_files,textbook_data_embedded]) else 'FAIL',
    'r_runtime_validation':'NOT_RUN',
    'counts':{'exports':len(exports),'s3_methods':len(s3),'r_definitions':len(defs),'vignettes':len(vignettes),'test_files':len(tests),'rd_aliases':len(aliases)},
    'checks':{
        'description_missing_fields':missing_desc,
        'delimiter_failures':balance_fail,
        'exports_without_definitions':missing_defs,
        's3_without_definitions':missing_s3_defs,
        'namespace_entries_without_rd_alias':missing_aliases,
        'namespace_calls_undeclared':undeclared,
        'missing_required_files':missing_files,
        'textbook_raw_markers_found':textbook_data_embedded,
        'maintainer_placeholder_present':placeholder_email,
    },
    'limitations':['Static audit is not an R syntax/parser check.','No examples, tests, vignettes, package build, or R CMD check are executed by this script.']
}
out=ROOT/'STATIC_AUDIT.json'
out.write_text(json.dumps(report,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
print(json.dumps(report,indent=2,ensure_ascii=False))
sys.exit(0 if report['status']=='PASS' else 1)
