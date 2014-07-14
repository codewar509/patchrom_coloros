

.PHONY: update
update:
	@echo "Update new code"
	cat ${PORT_ROOT}/smali/sourcechange.txt ${PORT_ROOT}/last_smali/sourcechange.txt | sort | uniq > ${PORT_ROOT}/device/sourcechange.txt
	${PORT_TOOLS}/patch_color_framework.sh ${PORT_ROOT}/last_smali/color ${PORT_ROOT}/smali/color ${PWD}/smali/ ${PORT_ROOT}/device/sourcechange.txt

firstpatch : getsmali resource
	@echo "First patch, We will autopatch changed smali files, you should modify files in dir temp/reject"
	${PORT_TOOLS}/patch_color_framework.sh ${PORT_ROOT}/smali/android ${PORT_ROOT}/smali/color ${PWD}/smali/ ${PORT_ROOT}/smali/sourcechange.txt
