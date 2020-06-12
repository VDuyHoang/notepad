#/bin/bash
SOURCE_DIR="$HOME/rpmbuild/SOURCES/"
function Build(){
    echo "Build file $1"
    filename=$(basename -- "$1")
    extension="${filename##*.}"
    filename="${filename%.*}"
    macro="";
    if [ -d "$SOURCE_DIR$filename" ]
    then
        macro="-D '_sourcedir $SOURCE_DIR$filename'"
    fi
    SRPMFile=$(eval "rpmbuild -bs $1 $macro" |cut -d':' -f 2)        
    ##SRPMFile=$(rpmbuild -bs "$1" $macro | cut -d':' -f 2)     ## didn't work "'" in variable
    if [ -f ${SRPMFile##*( )} ] 
    then    
    mock -r epel-7-x86_64 --define "debug_package %{nil}" rebuild ${SRPMFile##*( )}
    files=$(find /var/lib/mock/epel-7-x86_64/result -name *.el7.x86_64.rpm)    
    else
        echo "SRPM file not found"
        exit 1;
    fi
    exit 0
}
file="$HOME/rpmbuild/SPECS/$1";
PYTHON=$(echo $1 | grep 'python3')
if [ ! -z "$PYTHON" ] ; then
    p=${PYTHON:6:1}
    n=${PYTHON:8}
    file="$HOME/rpmbuild/SPECS/python$p/python$p-$n.spec"
    if [ -f "$file" ]
    then
        Build $file
    fi    
    echo "Pyp2rpm : $n"
    pyp2rpm -p$p $n > $file    
fi

if [ -f "$file.spec" ] ; then    
    file="$HOME/rpmbuild/SPECS/$1.spec";
fi
if [ -f "$file" ]
then
    Build $file
else
    file=$(find /opt/mock/rpmbuild/SOURCES -name $1)
    if [ -f "$file" ]; then
        Build $file
    fi
    file=$(find /opt/mock/rpmbuild/SOURCES -name $1.spec)
    if [ -f "$file" ]; then
        Build $file
    fi
    echo "Couln't found specfile $1";
    exit 1;
fi