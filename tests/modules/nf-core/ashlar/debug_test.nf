nextflow.enable.dsl=2

process DEBUG_TEST {

    input:
    tuple val(meta), file(file_in)

    script:

    """

    echo -n $meta

    echo -n $file_in

    """

}
