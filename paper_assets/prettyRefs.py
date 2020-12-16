## This takes latex exported references from Zotero as an input file.
## It sorts the fields and removes any unwanted fields, then exports
## Them alphabetically by reference name

## python3 prettyRefs.py references.bib

import sys
import collections
import copy

## NOTE: the first field is very important - this is what follows the '@', e.g. 'article'
## This should be skipped when exporting the fields

## Comment these as needed
FIELDS = [
'citationtype', 
'address',
'author',
'booktitle',
'editor',
'institution',
'journal',
'number',
'pages',
'publisher',
'title',
'volume',
'year'
]

OUTFILE = 'references_pretty.bib'

def createItemsDict(file_name):
    ## Create outer dictionary to hold all entries
    items = {}

    ## Create template dictionary
    template_dict = collections.OrderedDict()
    for f in FIELDS:
        template_dict[f] = ''

    ## Loop through citations
    infile = open(file_name,'r')
    line = infile.readline()
    while line != '':
        if line[0] == '@':
            citationtype = line[1:line.find('{')]
            entry = line[line.find('{')+1:].rstrip(',\n')
            items[entry] = copy.deepcopy(template_dict)
            items[entry]['citationtype'] = citationtype
            
            ## Loop through fields within citation
            line = infile.readline()
            while line[0] != '}':
                idx = line.find('=')
                f = line[0:idx].strip()
                if f in FIELDS:
                    items[entry][f] = line[idx+1:].strip(' ,\n').replace('{','').replace('}','')
                line = infile.readline()

        line = infile.readline()

    infile.close()
    return items

def exportItemsDict(items):
    outfile = open(OUTFILE,'w')

    ## Loop through sorted keys
    for i in sorted(items):
        outfile.write('\n@' + items[i]['citationtype'] + '{' + i + ',')
        for f in items[i]:
            if f != 'citationtype':
                outfile.write('\n\t' + f + ' = {' + items[i][f] + '},')
        outfile.write('\n}\n')

    outfile.close()

def main():
    ## Create input and output files
    items = createItemsDict(sys.argv[1])
    exportItemsDict(items)

main()
