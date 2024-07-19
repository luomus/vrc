#!/bin/bash

i="XXX-XXX-XXXX"
v="1"
f=""

while getopts ":i:v:f::" flag; do
  case $flag in
    i) i=${OPTARG} ;;
    v) v=${OPTARG} ;;
    f) f=${OPTARG} ;;
  esac
done

cat "$f" | \
yq -o=json | \
jq '
walk(
  if type == "object" then 
    with_entries(
     .key |= 
       if   . == "creator" then "dcterms:creator" 
       elif . == "orcid" then "ods:id"
       elif . == "collection" then "ltc:ObjectGroup"
       elif . == "name" then "ltc:collectionName"
       elif . == "description" then "ltc:description"
       elif . == "content" then "ods:searchFilters"
       elif . == "reference" then "filterkey"
       elif . == "identifiers" then "filterValue" 
       else . end
    ) 
  else . end
)' | \
xargs -0 echo '
{
  "rdf:type": "VirtualCollections",
  "ods:id": "https://hdl.handle.net/20.5000.1025/'"$i"'",
  "ods:version": '"$v"',
  "dcterms:creator": {
    "ods:type": "foaf:Person"
  }
}
' | \
jq -s '.[0] * .[1]'

