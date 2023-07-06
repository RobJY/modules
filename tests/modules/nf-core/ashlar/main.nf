#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

params.enable_conda = true

include { ASHLAR } from '../../../../modules/nf-core/ashlar/main.nf'
// we zero out the UUID of output tiff images with ZERO_UUID so we get a consistent md5sum
include { ZERO_UUID } from './zero_uuid.nf'
include { INPUT_CHECK } from '../../../../modules/nf-core/ashlar/input_check.nf'
include { validateParameters; paramsHelp; paramsSummaryLog; fromSamplesheet } from 'plugin/nf-validation'

TEST_SHEET = "/home/pollen/github/modules/tests/modules/nf-core/ashlar/test_sheet_url.csv"

workflow test_ashlar_sheet {

    if(params.help) {
        log.info paramsHelp("nextflow run -entry test_ashlar_sheet -plugins nf-validation main.nf")
        exit 0
    }

    validateParameters()

    // ch_input_ss = Channel.fromSamplesheet()

    ch_input = file(TEST_SHEET)

    INPUT_CHECK (
        ch_input
    )
    .images
    .map {
        it ->
            meta = [id: it.sample, args: ""]
            file_list_str = it.file_list.split(' ')
            def file_list_file = file_list_str.collect { x -> file(x) }
            [ meta, file_list_file ]
    }
    .set { input_maps }

    ASHLAR ( input_maps )

    ZERO_UUID ( ASHLAR.out[0], "8390123" )

}
