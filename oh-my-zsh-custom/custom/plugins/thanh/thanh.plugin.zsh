
cpath=`echo $0:A | sed 's#/[^/]*$##'`/../../../../oh-my-zsh-custom/custom

for i in $cpath/*; do
    source $i
done
