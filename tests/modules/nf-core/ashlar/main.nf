#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { ASHLAR } from '../../../../modules/nf-core/ashlar/main.nf'
include { ASHLAR as ASHLAR_TILE } from '../../../../modules/nf-core/ashlar/main.nf'

// we zero out the UUID of output tiff images with ZERO_UUID so we get a consistent md5sum
include { ZERO_UUID } from './zero_uuid.nf'
include { INPUT_CHECK } from '../../../../modules/nf-core/ashlar/input_check.nf'
include { validateParameters; paramsHelp; paramsSummaryLog; fromSamplesheet } from 'plugin/nf-validation'

if (params.help) {
    log.info paramsHelp("nextflow run -plugins nf-validation --help")
    exit 0
}

if (params.validate_params) {
    validateParameters()
    exit 0
}

workflow test_ashlar_sheet {

    // ch_input = Channel.fromSamplesheet(TEST_SHEET)

    ch_input = file(params.input)

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

    ASHLAR ( input_maps, [], [] )

    ZERO_UUID ( ASHLAR.out[0], "8390123" )

}
