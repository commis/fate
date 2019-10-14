#!/bin/bash
set -e
module_name="fate_flow"
cwd=$(cd `dirname $0`; pwd)
cd ${cwd}
source ./configurations.sh

config_path=$2
if [[ ${config_path} == "" ]] || [[ ! -f ${config_path} ]]
then
	echo "usage: $0 {install} {configurations path}."
	exit
fi
source ${config_path}


package_source() {
    cd ${output_packages_dir}/source
	if [ -e "${module_name}" ]
	then
		rm ${module_name}
	fi
	cp -r ${source_code_dir}/${module_name} ${output_packages_dir}/source
	return 0
}

source_build() {
    echo "[INFO][$module_name] build from source code"
	return 0
}

build() {
	return 0
}

config() {
    node_label=$3
	cd ${output_packages_dir}/config/${node_label}
	if [ -e "${module_name}" ]
	then
		rm ${module_name}
	fi
	mkdir -p ./${module_name}/conf
	cp ${source_code_dir}/${module_name}/service.sh ./${module_name}/conf
	cp ${source_code_dir}/${module_name}/settings.py ./${module_name}/conf
	cd ./${module_name}/conf

	sed -i "s#PYTHONPATH=.*#PYTHONPATH=${deploy_dir}/python#g" ./service.sh
	sed -i "s#venv=.*#venv=${venv_dir}#g" ./service.sh
	
	sed -i "s/WORK_MODE =.*/WORK_MODE = 1/g" ./settings.py
	sed -i "s/'user':.*/'user': '${db_user}',/g" ./settings.py
	sed -i "s/'passwd':.*/'passwd': '${db_password}',/g" ./settings.py
	sed -i "s/'host':.*/'host': '${db_ip}',/g" ./settings.py
	sed -i "s/'name':.*/'name': '${db_name}',/g" ./settings.py
	sed -i "s/'password':.*/'password': '${redis_password}',/g" ./settings.py
	sed "/'host':.*/{x;s/^/./;/^\.\{2\}$/{x;s/.*/    'host': '${redis_ip}',/;x};x;}" ./settings.py

	cd ../
    cp ${cwd}/install.sh ./
    cp ${cwd}/${config_path} ./configurations.sh
	return 0
}

install () {
    mkdir -p ${deploy_dir}/python/${module_name}
    cp -r ${deploy_packages_dir}/source/${module_name} ${deploy_dir}/python
    cp -r ${deploy_packages_dir}/config/${module_name}/conf/* ${deploy_dir}/python/${module_name}
}

init (){
	return 0
}

case "$1" in
    package_source)
        package_source $*
        ;;
    source_build)
        source_build $*
        ;;
    build)
        build $*
        ;;
    config)
        config $*
        ;;
    init)
        init $*
        ;;
    install)
        install $*
        ;;		
	*)
		echo "usage: $0 {source_build|build|config|init|install} {configurations path}."
        exit -1
esac