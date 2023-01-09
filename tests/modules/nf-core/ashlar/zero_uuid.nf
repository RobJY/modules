nextflow.enable.dsl=2

process ZERO_UUID {

    input:
    each path(file_in)

    script:
    """
    TARG_PATHS_ARRAY=(\$(find ../.. -name "ashlar_output.ome.tif" -printf "%k %p\n" | sort -n | awk -F ' ' '{print \$2}'))
    echo "\${TARG_PATHS_ARRAY[@]}" >> test.log

    TARG_ARRAY_LEN=\${#TARG_PATHS_ARRAY[@]}
    if [[ \$(( \$TARG_ARRAY_LEN % 2 )) != 0 ]]; then
        exit 0
    fi

    for (( idx=0; idx<\${TARG_ARRAY_LEN}; idx+=2 )); do
        echo "loop start: \$idx" >> test.log
        TARG_OFFSET=\$(cmp "\${TARG_PATHS_ARRAY[\$idx]}" "\${TARG_PATHS_ARRAY[\$idx+1]}" | awk -F ' ' '{print substr(\$5,1,length(\$5)-1)}')
        echo "offset:" >> test.log
        echo "\$TARG_OFFSET" >> test.log
        while [ \$TARG_OFFSET ]; do
            echo "editing file..." >> test.log
            TARG_OFFSET="\$((TARG_OFFSET - 1))"
            echo "updated target offset:" >> test.log
            echo "\$TARG_OFFSET" >> test.log
            echo -n "0" | dd of=\${TARG_PATHS_ARRAY[\$idx]} bs=1 seek=\${TARG_OFFSET} conv=notrunc
            echo -n "0" | dd of=\${TARG_PATHS_ARRAY[\$idx+1]} bs=1 seek=\${TARG_OFFSET} conv=notrunc
            TARG_OFFSET=\$(cmp "\${TARG_PATHS_ARRAY[\$idx]}" "\${TARG_PATHS_ARRAY[\$idx+1]}" | awk -F ' ' '{print substr(\$5,1,length(\$5)-1)}')
#            echo -n "00000000-0000-0000-0000-000000000000" | dd of=\${TARG_PATHS_ARRAY[\$idx]} bs=1 seek=\${TARG_OFFSET} conv=notrunc
#            echo -n "00000000-0000-0000-0000-000000000000" | dd of=\${TARG_PATHS_ARRAY[\$idx+1]} bs=1 seek=\${TARG_OFFSET} conv=notrunc
        done
        echo "after:" >> test.log
        TARG_OFFSET=\$(cmp "\${TARG_PATHS_ARRAY[\$idx]}" "\${TARG_PATHS_ARRAY[\$idx+1]}" | awk -F ' ' '{print substr(\$5,1,length(\$5)-1)}')
        echo "\$TARG_OFFSET" >> test.log

    done

    """

}
