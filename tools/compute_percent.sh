#!/bin/bash

DIFF_CNT=`find ./temp -name '*.diff' | wc -l`
REJ_CNT=`find ./temp -name '*.rej' | wc -l`

PERCENT=`echo "scale=2; (${DIFF_CNT} - ${REJ_CNT})*100/${DIFF_CNT}" | bc -l`
echo -e "diff count: ${DIFF_CNT}\t\treject count: ${REJ_CNT}"
echo -e "Success percent : `echo "${PERCENT}" | bc -l`%"