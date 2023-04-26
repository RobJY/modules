nextflow.enable.dsl=2

process DEBUG_TEST {

    input:
    tuple val(meta), path(file_in)

    script:

    file_in_type = file_in.getClass()

    """

    echo -n $meta

    echo -n $file_in

    echo -n $file_in_type

    """

}
