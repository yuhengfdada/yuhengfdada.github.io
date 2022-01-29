#!/bin/zsh
for file in $(ls)
do
	if [ ${file} != "replace.sh" ]
	then 
	sed -i '.bak' 's:/Users/apple/yuhengfdada.github.io::g' ${file}
	#echo $file
	#echo "!"
fi
done
find . -name "*.bak" | xargs rm