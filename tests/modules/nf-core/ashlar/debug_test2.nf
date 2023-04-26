nextflow.enable.dsl=2

process DEBUG_TEST2 {

    input:
    file(file_in)

    script:

    """

    echo -n $file_in

    """

}
