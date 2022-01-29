#!/bin/zsh
files=$(ls)
for file in $files
do
	if [file != "replace.sh"]; then 
	[sed -i '.bak' 's:/Users/apple/yuhengfdada.github.io::g' ${file}];
fi
done