#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { ASHLAR } from '../../../../modules/nf-core/ashlar/main.nf'
// we zero out the UUID of output tiff images with ZERO_UUID so we get a consistent md5sum
include { ZERO_UUID } from './zero_uuid.nf'


include { INPUT_CHECK } from '../../../../modules/nf-core/ashlar/input_check.nf'

TEST_SHEET = "/home/pollen/github/modules/tests/modules/nf-core/ashlar/test_sheet.csv"

workflow test_ashlar_sheet {

    ch_input = file(TEST_SHEET)

    INPUT_CHECK (
        ch_input
    )
    .images
    .map {
        it -> [ [ id: it.sample, args: '' ],
                it.file_list ]
    }
    .set { input_maps }

    ASHLAR ( input_maps )

    ZERO_UUID ( ASHLAR.out[0], "12586923" )

}
