#!/usr/bin/env nextflow

import java.io.File

nextflow.enable.dsl = 2

params.enable_conda = true

include { ASHLAR } from '../../../../modules/nf-core/ashlar/main.nf'
// we zero out the UUID of output tiff images with ZERO_UUID so we get a consistent md5sum
include { ZERO_UUID } from './zero_uuid.nf'
include { DEBUG_TEST } from './debug_test.nf'
include { INPUT_CHECK } from '../../../../modules/nf-core/ashlar/input_check.nf'

TEST_SHEET = "/home/pollen/github/modules/tests/modules/nf-core/ashlar/test_sheet_url.csv"

workflow test_ashlar_sheet {

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

    // input_channel = Channel.from(input_maps)

    // DEBUG_TEST ( input_maps )

    ASHLAR ( input_maps )

    ZERO_UUID ( ASHLAR.out[0], "8390123" )

}
