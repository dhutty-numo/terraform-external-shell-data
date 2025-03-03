#!/usr/bin/env bash

set -eu

IFS='"' read -ra JSON <<< $(cat)
_command=$(echo -n "${JSON[3]}" | sed -e 's/__TF_MAGIC_BACKSLASH_STRING/\\/g' -e $'s/__TF_MAGIC_QUOTE_STRING/\"/g;s/__TF_MAGIC_TAB_STRING/\t/g;s/__TF_MAGIC_LT_STRING/</g;s/__TF_MAGIC_GT_STRING/>/g;s/__TF_MAGIC_AMP_STRING/\&/g;s/__TF_MAGIC_2028_STRING/\u2028/g;s/__TF_MAGIC_2029_STRING/\u2029/g')
_environment=$(echo -n "${JSON[7]}" | sed -e 's/__TF_MAGIC_BACKSLASH_STRING/\\/g' -e $'s/__TF_MAGIC_QUOTE_STRING/\"/g;s/__TF_MAGIC_TAB_STRING/\t/g;s/__TF_MAGIC_LT_STRING/</g;s/__TF_MAGIC_GT_STRING/>/g;s/__TF_MAGIC_AMP_STRING/\&/g;s/__TF_MAGIC_2028_STRING/\u2028/g;s/__TF_MAGIC_2029_STRING/\u2029/g')
_exitonfail="${JSON[11]}"
_path=$(echo -n "${JSON[15]}" | sed -e $'s/__TF_MAGIC_QUOTE_STRING/\"/g')

_id="$RANDOM-$RANDOM-$RANDOM-$RANDOM"
_stderrfile="$_path/stderr.$_id"
_stdoutfile="$_path/stdout.$_id"

IFS=';' read -ra ENVRNMT <<< "$_environment"
for ((i=0; i<${#ENVRNMT[@]}; i+=2)); do
    _key=$(echo -n "${ENVRNMT[$i]}" | sed -e 's/__TF_MAGIC_SC_STRING/;/g')
    _val=$(echo -n "${ENVRNMT[$(($i+1))]}" | sed -e 's/__TF_MAGIC_SC_STRING/;/g;')
    export "$_key"="$_val"
done

set +e
    2>"$_stderrfile" >"$_stdoutfile" bash -c "$_command"
    _exitcode=$?
set -e

_stderr=$(cat "$_stderrfile")

if [ "$_exitonfail" = "true" ] && [ $_exitcode -ne 0 ] ; then
    >&2 echo "$_stderr"
    exit $_exitcode
fi

echo -n "{\"stderrfile\": \"$_stderrfile\", \"stdoutfile\": \"$_stdoutfile\", \"exitcode\": \"$_exitcode\"}"
